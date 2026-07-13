import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Photos,
    ScanMeta,
    ExactGroups,
    ExactGroupMembers,
    SimilarGroups,
    SimilarGroupMembers,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'image_finder'));

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.addColumn(photos, photos.meanLuminance);
            await m.addColumn(photos, photos.blurScore);
            await m.addColumn(photos, photos.isDark);
            await m.addColumn(photos, photos.isBlurry);
            await m.addColumn(scanMeta, scanMeta.darkCount);
            await m.addColumn(scanMeta, scanMeta.blurryCount);
          }
        },
      );

  Future<List<Photo>> getAllPhotos() => select(photos).get();

  Future<Map<String, Photo>> getPhotosByMediaId() async {
    final rows = await getAllPhotos();
    return {for (final row in rows) row.mediaId: row};
  }

  Future<void> upsertPhotos(List<PhotosCompanion> rows) async {
    if (rows.isEmpty) return;
    await batch((b) {
      b.insertAllOnConflictUpdate(photos, rows);
    });
  }

  Future<void> deletePhotosByIds(Iterable<String> ids) async {
    final list = ids.toList();
    if (list.isEmpty) return;
    await (delete(photos)..where((t) => t.mediaId.isIn(list))).go();
  }

  Future<void> updateHashes({
    required String mediaId,
    String? contentHash,
    String? dHash,
    String? pHash,
    double? meanLuminance,
    double? blurScore,
    bool? isDark,
    bool? isBlurry,
  }) {
    return (update(photos)..where((t) => t.mediaId.equals(mediaId))).write(
      PhotosCompanion(
        contentHash: contentHash != null
            ? Value(contentHash)
            : const Value.absent(),
        dHash: dHash != null ? Value(dHash) : const Value.absent(),
        pHash: pHash != null ? Value(pHash) : const Value.absent(),
        meanLuminance: meanLuminance != null
            ? Value(meanLuminance)
            : const Value.absent(),
        blurScore:
            blurScore != null ? Value(blurScore) : const Value.absent(),
        isDark: isDark != null ? Value(isDark) : const Value.absent(),
        isBlurry: isBlurry != null ? Value(isBlurry) : const Value.absent(),
      ),
    );
  }

  Future<List<Photo>> getDarkPhotos() {
    return (select(photos)
          ..where((t) => t.isDark.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.meanLuminance)]))
        .get();
  }

  Future<List<Photo>> getBlurryPhotos() {
    return (select(photos)
          ..where((t) => t.isBlurry.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.blurScore)]))
        .get();
  }

  Future<void> replaceExactGroups(
    List<({String contentHash, List<String> mediaIds, int totalBytes})> groups,
  ) async {
    await transaction(() async {
      await delete(exactGroupMembers).go();
      await delete(exactGroups).go();
      for (final g in groups) {
        final id = await into(exactGroups).insert(
          ExactGroupsCompanion.insert(
            contentHash: g.contentHash,
            memberCount: g.mediaIds.length,
            totalBytes: Value(g.totalBytes),
          ),
        );
        await batch((b) {
          b.insertAll(
            exactGroupMembers,
            g.mediaIds
                .map(
                  (m) => ExactGroupMembersCompanion.insert(
                    groupId: id,
                    mediaId: m,
                  ),
                )
                .toList(),
          );
        });
      }
    });
  }

  Future<void> replaceSimilarGroups(
    List<({List<String> mediaIds, int maxDistance})> groups,
  ) async {
    await transaction(() async {
      await delete(similarGroupMembers).go();
      await delete(similarGroups).go();
      for (final g in groups) {
        final id = await into(similarGroups).insert(
          SimilarGroupsCompanion.insert(
            memberCount: g.mediaIds.length,
            maxDistance: Value(g.maxDistance),
          ),
        );
        await batch((b) {
          b.insertAll(
            similarGroupMembers,
            g.mediaIds
                .map(
                  (m) => SimilarGroupMembersCompanion.insert(
                    groupId: id,
                    mediaId: m,
                  ),
                )
                .toList(),
          );
        });
      }
    });
  }

  Future<void> upsertScanMeta({
    required int photoCount,
    required int exactGroupCount,
    required int similarGroupCount,
    required int darkCount,
    required int blurryCount,
    required String lastPhase,
  }) {
    return into(scanMeta).insertOnConflictUpdate(
      ScanMetaCompanion(
        id: const Value(1),
        lastScanAtMs: Value(DateTime.now().millisecondsSinceEpoch),
        photoCount: Value(photoCount),
        exactGroupCount: Value(exactGroupCount),
        similarGroupCount: Value(similarGroupCount),
        darkCount: Value(darkCount),
        blurryCount: Value(blurryCount),
        lastPhase: Value(lastPhase),
      ),
    );
  }

  Future<ScanMetaData?> getScanMeta() {
    return (select(scanMeta)..where((t) => t.id.equals(1))).getSingleOrNull();
  }

  Future<List<ExactGroupView>> getExactGroupViews() async {
    final groups = await (select(
      exactGroups,
    )..orderBy([(t) => OrderingTerm.desc(t.totalBytes)])).get();
    final result = <ExactGroupView>[];
    for (final g in groups) {
      final members =
          await (select(exactGroupMembers)
                ..where((t) => t.groupId.equals(g.id)))
              .get();
      final photosForGroup = await (select(
        photos,
      )..where((t) => t.mediaId.isIn(members.map((m) => m.mediaId)))).get();
      result.add(
        ExactGroupView(group: g, photos: photosForGroup),
      );
    }
    return result;
  }

  Future<List<SimilarGroupView>> getSimilarGroupViews() async {
    final groups = await (select(
      similarGroups,
    )..orderBy([(t) => OrderingTerm.desc(t.memberCount)])).get();
    final result = <SimilarGroupView>[];
    for (final g in groups) {
      final members =
          await (select(similarGroupMembers)
                ..where((t) => t.groupId.equals(g.id)))
              .get();
      final photosForGroup = await (select(
        photos,
      )..where((t) => t.mediaId.isIn(members.map((m) => m.mediaId)))).get();
      result.add(
        SimilarGroupView(group: g, photos: photosForGroup),
      );
    }
    return result;
  }
}

class ExactGroupView {
  ExactGroupView({required this.group, required this.photos});
  final ExactGroup group;
  final List<Photo> photos;
}

class SimilarGroupView {
  SimilarGroupView({required this.group, required this.photos});
  final SimilarGroup group;
  final List<Photo> photos;
}
