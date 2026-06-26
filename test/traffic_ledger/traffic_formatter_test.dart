import 'package:fl_clash/common/traffic_formatter.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:test/test.dart';

void main() {
  group('TrafficFormatter.format', () {
    test('bytes for small values', () {
      final r = TrafficFormatter.format(500);
      expect(r.value, '500');
      expect(r.unit, TrafficUnit.B.name);
    });
    test('KB', () {
      final r = TrafficFormatter.format(1536);
      expect(r.value, '1.5');
      expect(r.unit, TrafficUnit.KB.name);
    });
    test('MB', () {
      final r = TrafficFormatter.format(1024 * 1024 * 2.5.toInt());
      expect(r.unit, TrafficUnit.MB.name);
    });
    test('GB', () {
      final r = TrafficFormatter.format(1024 * 1024 * 1024 * 3);
      expect(r.value, '3');
      expect(r.unit, TrafficUnit.GB.name);
    });
    test('zero', () {
      final r = TrafficFormatter.format(0);
      expect(r.value, '0');
      expect(r.unit, TrafficUnit.B.name);
    });
    test('trims trailing zeros', () {
      final r = TrafficFormatter.format(1024 * 1024 * 2.0.toInt());
      expect(r.value, '2');
    });
  });

  group('TrafficFormatter.formatCompact', () {
    test('no decimals', () {
      final r = TrafficFormatter.formatCompact(1536);
      expect(r.value, '2');
      expect(r.unit, ' KB');
    });
    test('bytes', () {
      final r = TrafficFormatter.formatCompact(500);
      expect(r.value, '500');
      expect(r.unit, ' B');
    });
  });

  group('TrafficFormatter.formatWithBilled', () {
    test('1x multiplier -> billed equals actual', () {
      final r = TrafficFormatter.formatWithBilled(
        actualBytes: 1024,
        multiplier: 1.0,
      );
      expect(r.actual.value, r.billed.value);
      expect(r.actual.unit, r.billed.unit);
      expect(r.multiplier, 1.0);
    });
    test('2x multiplier -> billed doubles', () {
      final r = TrafficFormatter.formatWithBilled(
        actualBytes: 1024,
        multiplier: 2.0,
      );
      // 1024 bytes actual = 1 KB; billed = 2048 = 2 KB
      expect(r.actual.unit, TrafficUnit.KB.name);
      expect(r.billed.unit, TrafficUnit.KB.name);
      expect(r.billed.value, '2');
      expect(r.actual.value, '1');
    });
    test('0.5x multiplier -> billed halves', () {
      final r = TrafficFormatter.formatWithBilled(
        actualBytes: 2048,
        multiplier: 0.5,
      );
      // 2048 actual = 2 KB; billed = 1024 = 1 KB
      expect(r.actual.value, '2');
      expect(r.billed.value, '1');
    });
  });

  group('TrafficLedgerShow', () {
    test('toString contains actual and billed', () {
      final r = TrafficFormatter.formatWithBilled(
        actualBytes: 1024,
        multiplier: 2.0,
      );
      final s = r.toString();
      expect(s, contains('actual='));
      expect(s, contains('billed='));
      expect(s, contains('multiplier=2.0x'));
    });
  });

  group('TrafficShow consistency', () {
    test('format and num.traffic agree on unit boundaries', () {
      // 1024 bytes should be 1 KB in both
      final f = TrafficFormatter.format(1024);
      expect(f.value, '1');
      expect(f.unit, TrafficUnit.KB.name);
    });
  });
}
