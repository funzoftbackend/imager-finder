import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:image_finder/domain/scan/dart_image_hash.dart';

Uint8List _solidJpeg({required int r, required int g, required int b}) {
  final image = img.Image(width: 32, height: 32);
  img.fill(image, color: img.ColorRgb8(r, g, b));
  return Uint8List.fromList(img.encodeJpg(image));
}

void main() {
  test('DartImageHash produces stable dHash for same image', () {
    final bytes = _solidJpeg(r: 40, g: 80, b: 120);
    final a = DartImageHash.dHash(bytes);
    final b = DartImageHash.dHash(bytes);
    expect(a, b);
    expect(a.isNotEmpty, isTrue);
  });

  test('DartImageHash differs for clearly different images', () {
    final dark = DartImageHash.dHash(_solidJpeg(r: 0, g: 0, b: 0));
    // Gradient-like difference via two fills isn't great for dHash on solids;
    // encode a horizontal gradient instead.
    final left = img.Image(width: 32, height: 32);
    final right = img.Image(width: 32, height: 32);
    for (var y = 0; y < 32; y++) {
      for (var x = 0; x < 32; x++) {
        left.setPixelRgb(x, y, x * 8, x * 8, x * 8);
        right.setPixelRgb(x, y, (31 - x) * 8, (31 - x) * 8, (31 - x) * 8);
      }
    }
    final a = DartImageHash.dHash(Uint8List.fromList(img.encodeJpg(left)));
    final b = DartImageHash.dHash(Uint8List.fromList(img.encodeJpg(right)));
    expect(a == b, isFalse);
    expect(dark.isNotEmpty, isTrue);
  });
}
