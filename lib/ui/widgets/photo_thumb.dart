import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';

import '../../data/db/app_database.dart';

class PhotoThumb extends StatelessWidget {
  const PhotoThumb({
    super.key,
    required this.photo,
    this.width,
    this.height,
    this.borderRadius = 12,
  });

  final Photo photo;
  final double? width;
  final double? height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AssetEntity?>(
      future: AssetEntity.fromId(photo.mediaId),
      builder: (context, snapshot) {
        final entity = snapshot.data;
        final radius = BorderRadius.circular(borderRadius);
        if (entity == null) {
          return Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: radius,
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.image_not_supported_outlined, size: 20),
          );
        }
        return ClipRRect(
          borderRadius: radius,
          child: AssetEntityImage(
            entity,
            isOriginal: false,
            thumbnailSize: const ThumbnailSize.square(300),
            fit: BoxFit.cover,
            width: width,
            height: height,
          ),
        );
      },
    );
  }
}
