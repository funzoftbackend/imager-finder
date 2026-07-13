import 'dart:async';
import 'dart:isolate';
import 'dart:math';

import 'package:drift/drift.dart';
import 'package:photo_manager/photo_manager.dart';

import '../../core/adaptive_concurrency.dart';
import '../../data/db/app_database.dart';
import '../../data/media/media_catalog.dart';
import '../../data/native/native_hash_client.dart';
import '../models/models.dart';
import 'dart_image_hash.dart';
import 'diff_engine.dart';
import 'groupers.dart';
import 'bk_tree.dart';
import 'scan_timing.dart';

/// Isolate entry must not close over [ScanOrchestrator.run]'s locals
/// (e.g. StreamController) — those are unsendable.
Future<List<({List<String> mediaIds, int maxDistance})>>
    runSimilarGroupingInIsolate(SimilarGroupIsolateArgs args) {
  return Isolate.run(() => groupSimilarInIsolate(args));
}

Future<List<String?>> runDHashBatchInIsolate(List<Uint8List?> batch) {
  return Isolate.run(() => dHashBatchInIsolate(batch));
}

/// Staged scan pipeline: catalog → diff → exact → similar → persist.
class ScanOrchestrator {
  ScanOrchestrator({
    required this._db,
    MediaCatalog? catalog,
    NativeHashClient? hashClient,
    DiffEngine? diffEngine,
    ExactGrouper? exactGrouper,
    SimilarGrouper? similarGrouper,
  }) : _catalog = catalog ?? MediaCatalog(),
       _hash = hashClient ?? NativeHashClient(),
       _diff = diffEngine ?? DiffEngine(),
       _exactGrouper = exactGrouper ?? ExactGrouper(),
       _similarGrouper = similarGrouper ?? SimilarGrouper();

  final AppDatabase _db;
  final MediaCatalog _catalog;
  final NativeHashClient _hash;
  final DiffEngine _diff;
  final ExactGrouper _exactGrouper;
  final SimilarGrouper _similarGrouper;

  bool _cancelRequested = false;

  void cancel() => _cancelRequested = true;

  Stream<ScanProgress> run({bool forceFullSimilar = false}) async* {
    _cancelRequested = false;
    final started = DateTime.now();
    final timing = ScanTiming();

    timing.begin('permission');
    yield const ScanProgress(
      phase: ScanPhase.permission,
      message: 'Checking gallery permission…',
    );

    final permission = await _catalog.requestPermission();
    timing.end('permission', detail: 'state=${permission.name}');
    if (!_catalog.isPermissionGranted(permission)) {
      yield ScanProgress(
        phase: ScanPhase.error,
        message: 'Permission denied',
        error:
            'Gallery permission is required to scan photos. '
            'Status: ${permission.name}. Open app settings and allow Photos access, then tap Scan again.',
      );
      return;
    }

    // —— Phase 1: Catalog ——
    timing.begin('catalog');
    yield const ScanProgress(
      phase: ScanPhase.catalog,
      message: 'Reading your gallery…',
    );

    // Keep StreamController out of this async* frame so later Isolate.run
    // closures do not capture an unsendable controller/Future.
    final assetsCompleter = Completer<List<CatalogAsset>>();
    await for (final p in _catalogProgressStream(assetsCompleter)) {
      yield p;
    }
    final assets = await assetsCompleter.future;
    if (_cancelRequested) return;

    timing.end(
      'catalog',
      detail: 'photos=${assets.length}',
    );
    yield ScanProgress(
      phase: ScanPhase.catalog,
      processed: assets.length,
      total: assets.length,
      message: 'Indexed ${assets.length} photos',
      photosPerSecond: _rate(started, assets.length),
    );

    // —— Phase 2: Diff ——
    timing.begin('diff');
    yield ScanProgress(
      phase: ScanPhase.diff,
      processed: 0,
      total: assets.length,
      message: 'Comparing with local cache…',
    );

    final existing = await _db.getPhotosByMediaId();
    final diff = _diff.diff(catalog: assets, existing: existing);

    if (diff.deletedIds.isNotEmpty) {
      await _db.deletePhotosByIds(diff.deletedIds);
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    final modifiedIds = {for (final m in diff.modified) m.mediaId};
    final upserts = <PhotosCompanion>[
      for (final a in [...diff.added, ...diff.modified])
        PhotosCompanion(
          mediaId: Value(a.mediaId),
          uri: Value(a.uri),
          path: Value(a.path),
          width: Value(a.width),
          height: Value(a.height),
          sizeBytes: Value(a.sizeBytes),
          modifiedMs: Value(a.modifiedMs),
          createdMs: Value(a.createdMs),
          mime: Value(a.mime),
          album: Value(a.album),
          contentHash: modifiedIds.contains(a.mediaId)
              ? const Value(null)
              : const Value.absent(),
          dHash: modifiedIds.contains(a.mediaId)
              ? const Value(null)
              : const Value.absent(),
          pHash: modifiedIds.contains(a.mediaId)
              ? const Value(null)
              : const Value.absent(),
          indexedAtMs: Value(now),
        ),
    ];
    await _db.upsertPhotos(upserts);

    timing.end(
      'diff',
      detail:
          'new=${diff.added.length} changed=${diff.modified.length} '
          'removed=${diff.deletedIds.length} unchanged=${diff.unchangedIds.length}',
    );
    yield ScanProgress(
      phase: ScanPhase.diff,
      processed: assets.length,
      total: assets.length,
      message:
          'New ${diff.added.length} · changed ${diff.modified.length} · '
          'removed ${diff.deletedIds.length} · unchanged ${diff.unchangedIds.length}',
    );

    if (_cancelRequested) return;

    // —— Phase 3: Exact duplicates (deferred hashing) ——
    timing.begin('exact_hash');
    var allPhotos = await _db.getAllPhotos();
    final sizeCandidates = _exactGrouper.sizeCollisionCandidates(allPhotos);
    final needContentHash = allPhotos
        .where(
          (p) =>
              sizeCandidates.contains(p.mediaId) &&
              (p.contentHash == null || p.contentHash!.isEmpty),
        )
        .toList();

    yield ScanProgress(
      phase: ScanPhase.exact,
      processed: 0,
      total: needContentHash.length,
      message: 'Hashing ${needContentHash.length} size-collision candidates…',
    );

    final concurrency = AdaptiveConcurrency.resolve();
    var exactDone = 0;
    final exactStarted = DateTime.now();

    await _mapLimited(
      needContentHash,
      concurrency: concurrency,
      run: (photo) async {
        try {
          final hash = await _hash.computeContentHash(photo.uri);
          await _db.updateHashes(mediaId: photo.mediaId, contentHash: hash);
        } catch (_) {}
      },
      onEach: () {
        exactDone++;
      },
    );

    timing.end(
      'exact_hash',
      detail: 'candidates=${needContentHash.length} hashed≈$exactDone',
    );
    yield ScanProgress(
      phase: ScanPhase.exact,
      processed: needContentHash.length,
      total: needContentHash.length,
      message: 'Exact hashing complete',
      photosPerSecond: _rate(exactStarted, exactDone),
    );

    if (_cancelRequested) return;

    timing.begin('exact_group');
    allPhotos = await _db.getAllPhotos();
    final exactGroups = _exactGrouper.group(allPhotos);
    await _db.replaceExactGroups(exactGroups);
    timing.end(
      'exact_group',
      detail:
          'groups=${exactGroups.length} '
          'photos=${exactGroups.fold<int>(0, (s, g) => s + g.mediaIds.length)}',
    );

    yield ScanProgress(
      phase: ScanPhase.exact,
      processed: needContentHash.length,
      total: needContentHash.length,
      exactGroups: exactGroups.length,
      message: 'Found ${exactGroups.length} exact duplicate groups',
    );

    // —— Phase 4: Similar (thumbnail → batched Dart dHash off UI) ——
    timing.begin('similar_hash');
    allPhotos = await _db.getAllPhotos();
    final needDHash = allPhotos;

    yield ScanProgress(
      phase: ScanPhase.similar,
      processed: 0,
      total: needDHash.length,
      exactGroups: exactGroups.length,
      message: 'Computing perceptual hashes for ${needDHash.length} photos…',
    );

    final similarStarted = DateTime.now();
    var similarDone = 0;
    var similarFailed = 0;
    String? lastError;

    // Thumbnail fetch stays light; hash decode runs in one isolate per chunk.
    final thumbConcurrency = min(2, concurrency);
    const chunkSize = 40;
    const milestoneEvery = 500;
    var nextMilestone = milestoneEvery;

    for (var i = 0; i < needDHash.length; i += chunkSize) {
      if (_cancelRequested) return;
      final chunk = needDHash.sublist(
        i,
        min(i + chunkSize, needDHash.length),
      );

      final thumbBytes = List<Uint8List?>.filled(chunk.length, null);
      await _mapLimited(
        List.generate(chunk.length, (index) => index),
        concurrency: thumbConcurrency,
        run: (index) async {
          try {
            thumbBytes[index] = await _loadThumbnailBytes(chunk[index]);
          } catch (e) {
            lastError ??= e.toString();
          }
        },
      );

      List<String?> hashes;
      try {
        hashes = await runDHashBatchInIsolate(thumbBytes);
      } catch (e) {
        // Fallback: hash on this isolate one-by-one if isolate spawn fails.
        hashes = DartImageHash.dHashBatch(thumbBytes);
        lastError ??= e.toString();
      }

      final chunkResults = <({String mediaId, String dHash})>[];
      for (var j = 0; j < chunk.length; j++) {
        final hashed = hashes[j];
        if (hashed != null && hashed.isNotEmpty) {
          chunkResults.add((mediaId: chunk[j].mediaId, dHash: hashed));
          continue;
        }
        // Thumbnail path failed — try native URI decode as last resort.
        try {
          final dHash = await _hash.computeDHash(chunk[j].uri);
          chunkResults.add((mediaId: chunk[j].mediaId, dHash: dHash));
        } catch (e) {
          similarFailed++;
          lastError ??= e.toString();
        }
      }

      if (chunkResults.isNotEmpty) {
        await _db.transaction(() async {
          for (final item in chunkResults) {
            await _db.updateHashes(mediaId: item.mediaId, dHash: item.dHash);
          }
        });
      }

      similarDone += chunk.length;
      if (similarDone >= nextMilestone || similarDone >= needDHash.length) {
        timing.milestone(
          'similar_hash',
          '$similarDone/${needDHash.length} failed=$similarFailed '
          'rate=${_rate(similarStarted, (similarDone - similarFailed).clamp(0, similarDone)).toStringAsFixed(1)}/s',
        );
        nextMilestone += milestoneEvery;
      }
      // Yield so the UI can paint between chunks (prevents ANR during hashing).
      await Future<void>.delayed(Duration.zero);
      yield ScanProgress(
        phase: ScanPhase.similar,
        processed: similarDone,
        total: needDHash.length,
        exactGroups: exactGroups.length,
        message: similarFailed > 0
            ? 'Scanning similar photos… ($similarFailed failed)'
            : 'Scanning similar photos…',
        photosPerSecond: _rate(
          similarStarted,
          (similarDone - similarFailed).clamp(0, similarDone),
        ),
      );
    }

    timing.end(
      'similar_hash',
      detail:
          'photos=${needDHash.length} failed=$similarFailed '
          'rate=${_rate(similarStarted, (similarDone - similarFailed).clamp(0, similarDone)).toStringAsFixed(1)}/s',
    );

    if (_cancelRequested) return;

    allPhotos = await _db.getAllPhotos();
    final hashedCount =
        allPhotos.where((p) => p.dHash != null && p.dHash!.isNotEmpty).length;

    // —— Phase 5: Grouping (must not look stuck at similar N/N) ——
    yield ScanProgress(
      phase: ScanPhase.grouping,
      processed: 0,
      total: 0,
      exactGroups: exactGroups.length,
      message: hashedCount == 0 && lastError != null
          ? 'No fingerprints yet ($lastError)'
          : 'Matching similar photos — this can take a moment…',
    );
    await Future<void>.delayed(Duration.zero);

    timing.begin('similar_group_prepare');
    final mediaIds = <String>[];
    final hashInts = <int>[];
    final contentHashes = <String?>[];
    for (final p in allPhotos) {
      final dHash = p.dHash;
      if (dHash == null || dHash.isEmpty) continue;
      mediaIds.add(p.mediaId);
      hashInts.add(BkTree.parseHash(dHash));
      contentHashes.add(p.contentHash);
    }
    timing.end(
      'similar_group_prepare',
      detail: 'fingerprints=${mediaIds.length}',
    );

    timing.begin('similar_group');
    final groupThreshold = _similarGrouper.threshold;
    final isolateArgs = (
      mediaIds: mediaIds,
      hashes: hashInts,
      contentHashes: contentHashes,
      threshold: groupThreshold,
    );

    late final List<({List<String> mediaIds, int maxDistance})> similarGroups;
    try {
      similarGroups = await runSimilarGroupingInIsolate(isolateArgs);
    } catch (e, st) {
      timing.info('similar_group FAILED: $e');
      timing.info(st.toString());
      yield ScanProgress(
        phase: ScanPhase.error,
        exactGroups: exactGroups.length,
        message: 'Similar grouping failed',
        error: 'Could not group similar photos: $e',
      );
      return;
    }
    timing.end(
      'similar_group',
      detail: 'fingerprints=${mediaIds.length} groups=${similarGroups.length}',
    );

    await Future<void>.delayed(Duration.zero);

    timing.begin('persist');
    yield ScanProgress(
      phase: ScanPhase.persist,
      processed: 0,
      total: 0,
      exactGroups: exactGroups.length,
      similarGroups: similarGroups.length,
      message: 'Saving results…',
    );
    await Future<void>.delayed(Duration.zero);

    await _db.replaceSimilarGroups(similarGroups);
    await _db.upsertScanMeta(
      photoCount: allPhotos.length,
      exactGroupCount: exactGroups.length,
      similarGroupCount: similarGroups.length,
      lastPhase: 'done',
    );
    timing.end(
      'persist',
      detail:
          'exactGroups=${exactGroups.length} similarGroups=${similarGroups.length}',
    );

    timing.summary(
      'SCAN COMPLETE photos=${allPhotos.length} '
      'exact=${exactGroups.length} similar=${similarGroups.length}',
    );

    yield ScanProgress(
      phase: ScanPhase.done,
      processed: allPhotos.length,
      total: allPhotos.length,
      exactGroups: exactGroups.length,
      similarGroups: similarGroups.length,
      message:
          'Scan complete · ${allPhotos.length} photos · '
          '${exactGroups.length} exact · ${similarGroups.length} similar',
      photosPerSecond: _rate(started, allPhotos.length),
    );
  }

  double _rate(DateTime started, int count) {
    final seconds =
        DateTime.now().difference(started).inMilliseconds / 1000.0;
    if (seconds <= 0) return 0;
    return count / seconds;
  }

  /// Catalog progress stream — controller lives here, not in [run].
  Stream<ScanProgress> _catalogProgressStream(
    Completer<List<CatalogAsset>> assetsCompleter,
  ) {
    final controller = StreamController<ScanProgress>();
    _catalog
        .loadAllImages(
          onProgress: (loaded, total) {
            if (controller.isClosed) return;
            controller.add(
              ScanProgress(
                phase: ScanPhase.catalog,
                processed: loaded,
                total: total,
                message: total > 0
                    ? 'Reading gallery… $loaded of $total'
                    : 'Reading gallery…',
              ),
            );
          },
        )
        .then((assets) {
          if (!assetsCompleter.isCompleted) {
            assetsCompleter.complete(assets);
          }
          if (!controller.isClosed) {
            controller.close();
          }
        })
        .catchError((Object e, StackTrace st) {
          if (!assetsCompleter.isCompleted) {
            assetsCompleter.completeError(e, st);
          }
          if (!controller.isClosed) {
            controller.addError(e, st);
            controller.close();
          }
        });
    return controller.stream;
  }

  Future<Uint8List?> _loadThumbnailBytes(Photo photo) async {
    final entity = await AssetEntity.fromId(photo.mediaId);
    if (entity == null) return null;
    return entity.thumbnailDataWithSize(
      const ThumbnailSize(64, 64),
      quality: 70,
    );
  }

  Future<void> _mapLimited<T>(
    List<T> items, {
    required int concurrency,
    required Future<void> Function(T item) run,
    void Function()? onEach,
  }) async {
    if (items.isEmpty) return;
    var next = 0;
    final workers = List.generate(concurrency.clamp(1, 8), (_) async {
      while (true) {
        if (_cancelRequested) return;
        final index = next;
        next++;
        if (index >= items.length) return;
        await run(items[index]);
        onEach?.call();
      }
    });
    await Future.wait(workers);
  }
}
