import 'package:flutter_test/flutter_test.dart';

import 'package:image_finder/domain/scan/quality_metrics.dart';

void main() {
  group('isDarkPhoto', () {
    test('flags low luminance', () {
      expect(isDarkPhoto(10), isTrue);
      expect(isDarkPhoto(kDarkMeanLuminanceMax), isTrue);
      expect(isDarkPhoto(kDarkMeanLuminanceMax + 1), isFalse);
      expect(isDarkPhoto(128), isFalse);
    });
  });

  group('isBlurryPhoto', () {
    test('flags low laplacian when there is enough light', () {
      expect(isBlurryPhoto(80, 20), isTrue);
      expect(isBlurryPhoto(80, kBlurryLaplacianMax), isTrue);
      expect(isBlurryPhoto(80, kBlurryLaplacianMax + 1), isFalse);
    });

    test('does not flag near-black frames as blurry', () {
      expect(isBlurryPhoto(5, 10), isFalse);
      expect(isBlurryPhoto(kBlurryMinLuminance - 1, 10), isFalse);
    });
  });

  group('PhotoFingerprint', () {
    test('exposes dark and blurry getters', () {
      const dark = PhotoFingerprint(
        dHash: '1',
        meanLuminance: 20,
        blurScore: 500,
      );
      expect(dark.isDark, isTrue);
      expect(dark.isBlurry, isFalse);

      const blurry = PhotoFingerprint(
        dHash: '1',
        meanLuminance: 90,
        blurScore: 40,
      );
      expect(blurry.isDark, isFalse);
      expect(blurry.isBlurry, isTrue);
    });
  });
}
