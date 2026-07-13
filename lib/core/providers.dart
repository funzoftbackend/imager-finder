import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/db/app_database.dart';
import '../domain/models/models.dart';
import '../domain/scan/scan_orchestrator.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final scanOrchestratorProvider = Provider<ScanOrchestrator>((ref) {
  return ScanOrchestrator(db: ref.watch(appDatabaseProvider));
});

final scanProgressProvider =
    NotifierProvider<ScanProgressNotifier, ScanProgress>(
      ScanProgressNotifier.new,
    );

class ScanProgressNotifier extends Notifier<ScanProgress> {
  @override
  ScanProgress build() => const ScanProgress(phase: ScanPhase.idle);

  Future<void> startScan({bool forceFullSimilar = false}) async {
    if (state.phase != ScanPhase.idle &&
        state.phase != ScanPhase.done &&
        state.phase != ScanPhase.error) {
      return;
    }
    final orchestrator = ref.read(scanOrchestratorProvider);
    try {
      await for (final progress in orchestrator.run(
        forceFullSimilar: forceFullSimilar,
      )) {
        state = progress;
      }
    } catch (e) {
      state = ScanProgress(
        phase: ScanPhase.error,
        message: 'Scan failed',
        error: e.toString(),
      );
    }
  }

  void resetIdle() {
    state = const ScanProgress(phase: ScanPhase.idle);
  }
}

/// Reload groups/meta only when phase or persisted counts change —
/// not on every similar hashing tick (that caused Duplicates card flicker).
final _scanResultsReloadKeyProvider = Provider<(ScanPhase, int, int)>((ref) {
  return ref.watch(
    scanProgressProvider.select(
      (p) => (p.phase, p.exactGroups, p.similarGroups),
    ),
  );
});

final exactGroupsProvider = FutureProvider<List<ExactGroupView>>((ref) async {
  ref.watch(_scanResultsReloadKeyProvider);
  return ref.read(appDatabaseProvider).getExactGroupViews();
});

final similarGroupsProvider =
    FutureProvider<List<SimilarGroupView>>((ref) async {
  ref.watch(_scanResultsReloadKeyProvider);
  return ref.read(appDatabaseProvider).getSimilarGroupViews();
});

final scanMetaProvider = FutureProvider<ScanMetaData?>((ref) async {
  ref.watch(_scanResultsReloadKeyProvider);
  return ref.read(appDatabaseProvider).getScanMeta();
});

/// Bottom nav: 0 Home, 1 Clean, 2 Info
final navIndexProvider = NotifierProvider<NavIndexNotifier, int>(
  NavIndexNotifier.new,
);

class NavIndexNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setIndex(int index) => state = index;
}

enum CleanCategory { duplicates, similar }

final cleanCategoryProvider =
    NotifierProvider<CleanCategoryNotifier, CleanCategory>(
      CleanCategoryNotifier.new,
    );

class CleanCategoryNotifier extends Notifier<CleanCategory> {
  @override
  CleanCategory build() => CleanCategory.duplicates;

  void setCategory(CleanCategory category) => state = category;
}

/// mediaIds marked for deletion in Clean tab.
final cleanSelectionProvider =
    NotifierProvider<CleanSelectionNotifier, Set<String>>(
      CleanSelectionNotifier.new,
    );

class CleanSelectionNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => <String>{};

  void toggle(String mediaId) {
    final next = {...state};
    if (!next.add(mediaId)) next.remove(mediaId);
    state = next;
  }

  void selectAllExcept(String keepId, Iterable<String> mediaIds) {
    state = {
      for (final id in mediaIds)
        if (id != keepId) id,
    };
  }

  /// For every group: keep the best photo (largest file), select the rest.
  void applySmartDefaults(Iterable<List<Photo>> groups) {
    final selected = <String>{};
    for (final photos in groups) {
      if (photos.length < 2) continue;
      final keepId = bestPhotoId(photos);
      for (final photo in photos) {
        if (photo.mediaId != keepId) {
          selected.add(photo.mediaId);
        }
      }
    }
    state = selected;
  }

  /// Merge smart defaults for a single group into the current selection.
  void applySmartDefaultsForGroup(List<Photo> photos) {
    if (photos.length < 2) return;
    final keepId = bestPhotoId(photos);
    final next = {...state};
    for (final photo in photos) {
      if (photo.mediaId == keepId) {
        next.remove(photo.mediaId);
      } else {
        next.add(photo.mediaId);
      }
    }
    state = next;
  }

  void clear() => state = <String>{};

  static String bestPhotoId(List<Photo> photos) {
    Photo best = photos.first;
    for (final photo in photos.skip(1)) {
      if (photo.sizeBytes > best.sizeBytes) {
        best = photo;
      } else if (photo.sizeBytes == best.sizeBytes &&
          photo.modifiedMs > best.modifiedMs) {
        best = photo;
      }
    }
    return best.mediaId;
  }
}
