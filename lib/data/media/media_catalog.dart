import 'package:photo_manager/photo_manager.dart';

import '../../domain/models/models.dart';

class MediaCatalog {
  static const PermissionRequestOption _permissionOption = PermissionRequestOption(
    androidPermission: AndroidPermission(
      type: RequestType.image,
      mediaLocation: false,
    ),
  );

  /// Fast MediaStore inventory — metadata only, no pixel decode.
  ///
  /// [onProgress] reports `(loaded, total)` after each page.
  Future<List<CatalogAsset>> loadAllImages({
    void Function(int loaded, int total)? onProgress,
  }) async {
    final paths = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      onlyAll: true,
      filterOption: FilterOptionGroup(
        imageOption: const FilterOption(
          sizeConstraint: SizeConstraint(ignoreSize: true),
        ),
        orders: [
          const OrderOption(type: OrderOptionType.updateDate, asc: false),
        ],
      ),
    );

    if (paths.isEmpty) return const [];

    final all = paths.first;
    final total = await all.assetCountAsync;
    onProgress?.call(0, total);

    const pageSize = 500;
    final assets = <CatalogAsset>[];

    for (var page = 0; page * pageSize < total; page++) {
      final batch = await all.getAssetListPaged(page: page, size: pageSize);
      for (final entity in batch) {
        // Constructed MediaStore URI — avoids a getMediaUrl() IPC per photo.
        final uri = 'content://media/external/images/media/${entity.id}';
        assets.add(
          CatalogAsset(
            mediaId: entity.id,
            uri: uri,
            path: entity.relativePath,
            width: entity.width,
            height: entity.height,
            sizeBytes: await entity.fileSize,
            modifiedMs: (entity.modifiedDateSecond ?? 0) * 1000,
            createdMs: (entity.createDateSecond ?? 0) * 1000,
            mime: entity.mimeType,
            album: entity.relativePath,
          ),
        );
      }
      onProgress?.call(assets.length, total);
    }

    onProgress?.call(assets.length, total);
    return assets;
  }

  Future<PermissionState> requestPermission() {
    return PhotoManager.requestPermissionExtend(
      requestOption: _permissionOption,
    );
  }

  Future<PermissionState> currentPermission() {
    return PhotoManager.getPermissionState(
      requestOption: _permissionOption,
    );
  }

  bool isPermissionGranted(PermissionState state) => state.hasAccess;
}
