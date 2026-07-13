import 'package:photo_manager/photo_manager.dart';

import '../../domain/models/models.dart';
import '../native/native_hash_client.dart';

class MediaCatalog {
  MediaCatalog({NativeHashClient? hashClient})
      : _hash = hashClient ?? NativeHashClient();

  final NativeHashClient _hash;

  static const PermissionRequestOption _permissionOption = PermissionRequestOption(
    androidPermission: AndroidPermission(
      type: RequestType.image,
      mediaLocation: false,
    ),
  );

  /// Fast inventory: prefers native bulk MediaStore cursor; falls back to photo_manager.
  ///
  /// [onProgress] reports `(loaded, total)` — native path reports 0 then full count.
  Future<List<CatalogAsset>> loadAllImages({
    void Function(int loaded, int total)? onProgress,
  }) async {
    try {
      onProgress?.call(0, 0);
      final native = await _hash.catalogImages();
      if (native.isNotEmpty) {
        onProgress?.call(native.length, native.length);
        return native;
      }
    } catch (_) {
      // Fall through to photo_manager path.
    }
    return _loadViaPhotoManager(onProgress: onProgress);
  }

  Future<List<CatalogAsset>> _loadViaPhotoManager({
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

    const pageSize = 1000;
    final assets = <CatalogAsset>[];

    for (var page = 0; page * pageSize < total; page++) {
      final batch = await all.getAssetListPaged(page: page, size: pageSize);
      // Parallelize fileSize — slow path only when native catalog unavailable.
      final sizes = List<int>.filled(batch.length, 0);
      const sizeConcurrency = 8;
      var next = 0;
      await Future.wait(
        List.generate(sizeConcurrency, (_) async {
          while (true) {
            final i = next;
            next++;
            if (i >= batch.length) return;
            sizes[i] = await batch[i].fileSize;
          }
        }),
      );

      for (var i = 0; i < batch.length; i++) {
        final entity = batch[i];
        final uri = 'content://media/external/images/media/${entity.id}';
        assets.add(
          CatalogAsset(
            mediaId: entity.id,
            uri: uri,
            path: entity.relativePath,
            width: entity.width,
            height: entity.height,
            sizeBytes: sizes[i],
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
