import 'dart:developer' as developer;

/// Lightweight step timer for scan pipeline diagnostics.
///
/// Filter logcat / DevTools with name `ImageFinder.Scan`.
class ScanTiming {
  ScanTiming() : _scanStarted = DateTime.now();

  final DateTime _scanStarted;
  DateTime _stepStarted = DateTime.now();
  final Map<String, int> _stepMs = {};

  void begin(String step) {
    _stepStarted = DateTime.now();
    developer.log(
      '▶ START $step (total ${elapsedMs}ms)',
      name: 'ImageFinder.Scan',
    );
  }

  void end(String step, {String? detail}) {
    final stepMs = DateTime.now().difference(_stepStarted).inMilliseconds;
    _stepMs[step] = stepMs;
    final extra = detail == null || detail.isEmpty ? '' : ' | $detail';
    developer.log(
      '■ END $step — ${stepMs}ms (total ${elapsedMs}ms)$extra',
      name: 'ImageFinder.Scan',
    );
  }

  void info(String message) {
    developer.log(
      '· $message (total ${elapsedMs}ms)',
      name: 'ImageFinder.Scan',
    );
  }

  /// Mid-step milestone (e.g. every N similar hashes).
  void milestone(String step, String detail) {
    final stepMs = DateTime.now().difference(_stepStarted).inMilliseconds;
    developer.log(
      '… $step @ ${stepMs}ms — $detail (total ${elapsedMs}ms)',
      name: 'ImageFinder.Scan',
    );
  }

  void summary(String message) {
    final parts = _stepMs.entries.map((e) => '${e.key}=${e.value}ms').join(', ');
    developer.log(
      '★ $message | steps: $parts | total ${elapsedMs}ms',
      name: 'ImageFinder.Scan',
    );
  }

  int get elapsedMs => DateTime.now().difference(_scanStarted).inMilliseconds;
}
