import 'package:flutter_test/flutter_test.dart';
import 'package:image_finder/domain/models/models.dart';

void main() {
  test('ScanProgress fraction clamps', () {
    const p = ScanProgress(phase: ScanPhase.catalog, processed: 5, total: 10);
    expect(p.fraction, 0.5);
    const empty = ScanProgress(phase: ScanPhase.idle);
    expect(empty.fraction, 0);
  });
}
