import 'dart:typed_data';

import 'package:image/image.dart' as img;

/// Pure-Dart perceptual hashes computed from already-decoded thumbnail bytes.
class DartImageHash {
  /// 64-bit difference hash (9x8 grayscale, horizontal gradients).
  static String dHash(Uint8List bytes) {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      throw StateError('Unable to decode image bytes for dHash');
    }
    final resized = img.copyResize(
      decoded,
      width: 9,
      height: 8,
      interpolation: img.Interpolation.linear,
    );

    var hash = 0;
    var bit = 0;
    for (var y = 0; y < 8; y++) {
      for (var x = 0; x < 8; x++) {
        final left = _luma(resized.getPixel(x, y));
        final right = _luma(resized.getPixel(x + 1, y));
        if (left > right) {
          hash |= (1 << bit);
        }
        bit++;
      }
    }
    // Keep unsigned decimal string compatible with native ULong hashes.
    return hash.toUnsigned(64).toString();
  }

  /// Batch helper for [Isolate.run] — one isolate per chunk, not per photo.
  static List<String?> dHashBatch(List<Uint8List?> batch) {
    return [
      for (final bytes in batch)
        if (bytes == null || bytes.isEmpty)
          null
        else
          (() {
            try {
              return dHash(bytes);
            } catch (_) {
              return null;
            }
          })(),
    ];
  }

  static double _luma(img.Pixel pixel) {
    return 0.299 * pixel.r.toDouble() +
        0.587 * pixel.g.toDouble() +
        0.114 * pixel.b.toDouble();
  }
}

/// Top-level wrapper so [Isolate.run] can invoke batch hashing safely.
List<String?> dHashBatchInIsolate(List<Uint8List?> batch) {
  return DartImageHash.dHashBatch(batch);
}
