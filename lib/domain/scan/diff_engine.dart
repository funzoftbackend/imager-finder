import '../../data/db/app_database.dart';
import '../models/models.dart';

class DiffEngine {
  /// Classifies catalog assets against the local DB for incremental scans.
  DiffResult diff({
    required List<CatalogAsset> catalog,
    required Map<String, Photo> existing,
  }) {
    final added = <CatalogAsset>[];
    final modified = <CatalogAsset>[];
    final unchanged = <String>[];
    final seen = <String>{};

    for (final asset in catalog) {
      seen.add(asset.mediaId);
      final prev = existing[asset.mediaId];
      if (prev == null) {
        added.add(asset);
        continue;
      }
      if (prev.sizeBytes != asset.sizeBytes ||
          prev.modifiedMs != asset.modifiedMs) {
        modified.add(asset);
      } else {
        unchanged.add(asset.mediaId);
      }
    }

    final deleted = existing.keys.where((id) => !seen.contains(id)).toList();

    return DiffResult(
      added: added,
      modified: modified,
      deletedIds: deleted,
      unchangedIds: unchanged,
    );
  }
}
