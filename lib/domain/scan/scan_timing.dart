import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Scan pipeline timing — visible in `flutter run` via [debugPrint]
/// and in DevTools via [developer.log] (`ImageFinder.Scan`).
class ScanTiming {
  ScanTiming() : _scanStarted = DateTime.now();

  static const _tag = 'ImageFinder.Scan';

  final DateTime _scanStarted;
  DateTime _stepStarted = DateTime.now();
  final List<_StepRecord> _steps = [];
  final List<String> _milestones = [];

  void begin(String step) {
    _stepStarted = DateTime.now();
    _emit('▶ START $step (total ${_fmt(elapsedMs)})');
  }

  void end(String step, {String? detail}) {
    final stepMs = DateTime.now().difference(_stepStarted).inMilliseconds;
    _steps.add(_StepRecord(name: step, ms: stepMs, detail: detail));
    final extra = detail == null || detail.isEmpty ? '' : ' | $detail';
    _emit('■ END $step — ${_fmt(stepMs)} (total ${_fmt(elapsedMs)})$extra');
  }

  void info(String message) {
    _emit('· $message (total ${_fmt(elapsedMs)})');
  }

  /// Mid-step milestone (e.g. every N similar hashes).
  void milestone(String step, String detail) {
    final stepMs = DateTime.now().difference(_stepStarted).inMilliseconds;
    final line = '… $step @ ${_fmt(stepMs)} — $detail (total ${_fmt(elapsedMs)})';
    _milestones.add(line);
    _emit(line);
  }

  /// Pretty hierarchical report for the terminal after a full scan.
  void summary(String message) {
    final exactMs = _sumMs(const ['exact_hash', 'exact_group']);
    final similarMs = _sumMs(const [
      'similar_hash',
      'similar_group_prepare',
      'similar_group',
    ]);
    final total = elapsedMs;

    final buf = StringBuffer()
      ..writeln('========== ImageFinder scan timing ==========')
      ..writeln(message);

    for (final step in _steps) {
      final detail =
          step.detail == null || step.detail!.isEmpty ? '' : '  | ${step.detail}';
      buf.writeln(
        '${step.name.padRight(24)} ${_fmt(step.ms).padLeft(12)}$detail',
      );
    }

    if (_milestones.isNotEmpty) {
      buf.writeln('--- similar_hash milestones ---');
      for (final m in _milestones) {
        buf.writeln('  $m');
      }
    }

    buf
      ..writeln('---------------------------------------------')
      ..writeln(
        '${'Duplicates (exact)'.padRight(24)} ${_fmt(exactMs).padLeft(12)}',
      )
      ..writeln(
        '${'Similar'.padRight(24)} ${_fmt(similarMs).padLeft(12)}',
      )
      ..writeln(
        '${'FULL SCAN'.padRight(24)} ${_fmt(total).padLeft(12)}',
      )
      ..writeln('=============================================');

    final report = buf.toString().trimRight();
    developer.log(report, name: _tag);
    for (final line in report.split('\n')) {
      debugPrint('[$_tag] $line');
    }
  }

  int get elapsedMs => DateTime.now().difference(_scanStarted).inMilliseconds;

  int _sumMs(List<String> names) {
    var total = 0;
    for (final step in _steps) {
      if (names.contains(step.name)) total += step.ms;
    }
    return total;
  }

  void _emit(String message) {
    developer.log(message, name: _tag);
    debugPrint('[$_tag] $message');
  }

  /// `120ms` or `3m 59s` when >= 60s (also keeps ms for precision when < 60s).
  static String _fmt(int ms) {
    if (ms < 1000) return '${ms}ms';
    if (ms < 60000) {
      final sec = ms / 1000.0;
      return '${sec.toStringAsFixed(1)}s (${ms}ms)';
    }
    final minutes = ms ~/ 60000;
    final seconds = (ms % 60000) / 1000.0;
    return '${minutes}m ${seconds.toStringAsFixed(0)}s (${ms}ms)';
  }
}

class _StepRecord {
  const _StepRecord({
    required this.name,
    required this.ms,
    this.detail,
  });

  final String name;
  final int ms;
  final String? detail;
}
