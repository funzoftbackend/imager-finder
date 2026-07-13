// Thresholds for dark / blurry classification from native thumbnail scores.
//
// Scores come from a 64×64 gray plane:
// - meanLuminance: 0–255 Rec.601 luma
// - blurScore: Laplacian variance (higher = sharper)

/// Mean luma at or below this → dark photo.
const double kDarkMeanLuminanceMax = 42.0;

/// Laplacian variance at or below this → blurry (when not near-black).
const double kBlurryLaplacianMax = 90.0;

/// Skip blur labeling when the frame is too dark for edge signal.
const double kBlurryMinLuminance = 22.0;

bool isDarkPhoto(double meanLuminance) => meanLuminance <= kDarkMeanLuminanceMax;

bool isBlurryPhoto(double meanLuminance, double blurScore) {
  if (meanLuminance < kBlurryMinLuminance) return false;
  return blurScore <= kBlurryLaplacianMax;
}

/// Result of native thumbnail fingerprinting (dHash + quality).
class PhotoFingerprint {
  const PhotoFingerprint({
    required this.dHash,
    required this.meanLuminance,
    required this.blurScore,
  });

  final String dHash;
  final double meanLuminance;
  final double blurScore;

  bool get isDark => isDarkPhoto(meanLuminance);
  bool get isBlurry => isBlurryPhoto(meanLuminance, blurScore);
}
