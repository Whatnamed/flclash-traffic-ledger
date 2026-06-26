import 'package:fl_clash/traffic_ledger/collection/multiplier_precision.dart';
import 'package:test/test.dart';

void main() {
  group('MultiplierPrecision', () {
    test('toMillis rounds 1.5x to 1500', () {
      expect(MultiplierPrecision.toMillis(1.5), 1500);
    });

    test('toMillis rounds 0.1x to 100', () {
      expect(MultiplierPrecision.toMillis(0.1), 100);
    });

    test('toMillis rounds 2.0x to 2000', () {
      expect(MultiplierPrecision.toMillis(2.0), 2000);
    });

    test('split returns integer and milliParts', () {
      final r = MultiplierPrecision.split(12345);
      expect(r.estimated, 12);
      expect(r.remainder, 345);
    });

    test('accumulate adds new delta to existing', () {
      // existing: 10 estimated, 500 remainder
      // delta: 1 byte * 1500 millis = 1500 milliBytes (1 estimated, 500 remainder)
      // total remainder: 500 + 500 = 1000 -> carry 1
      // new estimated: 10 + 1 + 1 = 12
      // new remainder: 0
      final r = MultiplierPrecision.accumulate(
        existingEstimated: 10,
        existingRemainder: 500,
        deltaBytes: 1,
        multiplierMillis: 1500,
      );
      expect(r.estimated, 12);
      expect(r.remainder, 0);
    });

    test('accumulate rejects negative delta', () {
      expect(
        () => MultiplierPrecision.accumulate(
          existingEstimated: 0,
          existingRemainder: 0,
          deltaBytes: -1,
          multiplierMillis: 1000,
        ),
        throwsArgumentError,
      );
    });

    test('isValidRemainder bounds', () {
      expect(MultiplierPrecision.isValidRemainder(0), isTrue);
      expect(MultiplierPrecision.isValidRemainder(999), isTrue);
      expect(MultiplierPrecision.isValidRemainder(1000), isFalse);
      expect(MultiplierPrecision.isValidRemainder(-1), isFalse);
    });

    test('multiplierEquals matches in milli precision', () {
      expect(MultiplierPrecision.multiplierEquals(1.5, 1.5), isTrue);
      expect(MultiplierPrecision.multiplierEquals(1.5001, 1.5), isTrue);
      expect(MultiplierPrecision.multiplierEquals(1.5, 2.0), isFalse);
    });
  });

  group('MultiplierPrecision - Scenario 14: 非整数倍率多次小增量不低估', () {
    test('1.5x multiplier, 1000 次 1 byte 累加 = 1500 bytes 预计扣量', () {
      // 真实值: 1000 * 1 * 1.5 = 1500 字节
      // 浮点截断方案每次 (1 * 1.5).floor() = 1，1000 次累加 = 1000（低估 500）
      // 毫字节余数方案应严格等于 1500
      var estimated = 0;
      var remainder = 0;
      const multMillis = 1500; // 1.5x
      for (var i = 0; i < 1000; i++) {
        final r = MultiplierPrecision.accumulate(
          existingEstimated: estimated,
          existingRemainder: remainder,
          deltaBytes: 1,
          multiplierMillis: multMillis,
        );
        estimated = r.estimated;
        remainder = r.remainder;
      }
      expect(estimated, 1500);
      expect(remainder, 0);
    });

    test('0.1x multiplier, 10000 次 1 byte 累加 = 1000 bytes 预计扣量', () {
      // 真实值: 10000 * 1 * 0.1 = 1000 字节
      // 浮点截断方案每次 (1 * 0.1).floor() = 0，10000 次累加 = 0（完全低估）
      // 毫字节余数方案应严格等于 1000
      var estimated = 0;
      var remainder = 0;
      const multMillis = 100; // 0.1x
      for (var i = 0; i < 10000; i++) {
        final r = MultiplierPrecision.accumulate(
          existingEstimated: estimated,
          existingRemainder: remainder,
          deltaBytes: 1,
          multiplierMillis: multMillis,
        );
        estimated = r.estimated;
        remainder = r.remainder;
      }
      expect(estimated, 1000);
      expect(remainder, 0);
    });

    test('3.7x multiplier, 1000 次 1 byte 累加 = 3700 bytes', () {
      // 真实值: 1000 * 1 * 3.7 = 3700
      // 毫倍率 3700, 1000 * 3700 = 3700000 milliBytes, /1000 = 3700
      var estimated = 0;
      var remainder = 0;
      const multMillis = 3700; // 3.7x
      for (var i = 0; i < 1000; i++) {
        final r = MultiplierPrecision.accumulate(
          existingEstimated: estimated,
          existingRemainder: remainder,
          deltaBytes: 1,
          multiplierMillis: multMillis,
        );
        estimated = r.estimated;
        remainder = r.remainder;
      }
      expect(estimated, 3700);
      expect(remainder, 0);
    });

    test('1.5x 不可估算 sentinel 加入后保持 sentinel，estimated 不再增加', () {
      // 先正常累加 10 bytes 1.5x = 15 bytes estimated, 0 remainder
      final r = MultiplierPrecision.accumulate(
        existingEstimated: 0,
        existingRemainder: 0,
        deltaBytes: 10,
        multiplierMillis: 1500,
      );
      expect(r.estimated, 15);
      expect(r.remainder, 0);

      // 后续逻辑层应跳过 accumulate（直接置 sentinel），不在此处模拟。
      // 这里只验证 sentinel 常量与判定函数。
      expect(unbilledSentinel, -1);
      expect(isUnbilled(unbilledSentinel), isTrue);
      expect(isUnbilled(0), isFalse);
      expect(isUnbilled(999), isFalse);
    });
  });
}
