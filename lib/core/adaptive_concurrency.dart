import 'dart:io';

/// Device-adaptive worker count for native hash calls.
class AdaptiveConcurrency {
  static int resolve() {
    final processors = Platform.numberOfProcessors;
    // Approx RAM heuristic via processors as a stand-in; keep conservative.
    if (processors <= 4) return 2;
    if (processors <= 6) return 3;
    return (processors - 1).clamp(2, 6);
  }
}
