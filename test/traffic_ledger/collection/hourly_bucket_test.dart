import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/traffic_ledger/collection/hourly_bucket.dart';
import 'package:fl_clash/traffic_ledger/collection/models.dart';
import 'package:fl_clash/traffic_ledger/collection/multiplier_precision.dart';
import 'package:test/test.dart';

AttributedDelta _delta({
  String appIdentifier = 'chrome.exe',
  String nodeName = 'JP-Tokyo',
  String domain = 'example.com',
  String rule = 'DOMAIN',
  int deltaUp = 0,
  int deltaDown = 0,
  double effectiveMultiplier = 1.0,
  int estimatedBilledDeltaUp = 0,
  int estimatedBilledDeltaDown = 0,
  int billedRemainderDeltaUp = 0,
  int billedRemainderDeltaDown = 0,
}) {
  return AttributedDelta(
    appIdentifier: appIdentifier,
    nodeName: nodeName,
    domain: domain,
    rule: rule,
    deltaUp: deltaUp,
    deltaDown: deltaDown,
    effectiveMultiplier: effectiveMultiplier,
    estimatedBilledDeltaUp: estimatedBilledDeltaUp,
    estimatedBilledDeltaDown: estimatedBilledDeltaDown,
    billedRemainderDeltaUp: billedRemainderDeltaUp,
    billedRemainderDeltaDown: billedRemainderDeltaDown,
  );
}

void main() {
  group('HourlyBucket', () {
    test('accumulate adds bytes and estimated', () {
      final b = HourlyBucket(
        periodId: 1,
        hourStart: DateTime(2026, 6, 27, 10),
        appIdentifier: 'chrome.exe',
        nodeName: 'JP-Tokyo',
        domain: 'example.com',
        rule: 'DOMAIN',
        firstMultiplier: 1.0,
      );
      b.accumulate(_delta(
        deltaUp: 100,
        deltaDown: 200,
        effectiveMultiplier: 1.0,
      ));
      expect(b.bytesUp, 100);
      expect(b.bytesDown, 200);
      // 倍率 1.0 -> 100 * 1000 / 1000 = 100
      expect(b.estimatedBilledBytesUp, 100);
      expect(b.estimatedBilledBytesDown, 200);
      expect(b.billedRemainderUp, 0);
      expect(b.billedRemainderDown, 0);
      expect(b.isUnbilled, isFalse);
    });

    test('unattributed delta marks bucket as unbilled sentinel', () {
      final b = HourlyBucket(
        periodId: 1,
        hourStart: DateTime(2026, 6, 27, 10),
        appIdentifier: unattributedAppIdentifier,
        nodeName: unknownDimensionValue,
        domain: unknownDimensionValue,
        rule: unknownDimensionValue,
        firstMultiplier: 0,
      );
      b.accumulate(_delta(
        appIdentifier: unattributedAppIdentifier,
        nodeName: unknownDimensionValue,
        domain: unknownDimensionValue,
        rule: unknownDimensionValue,
        deltaUp: 100,
        deltaDown: 100,
        effectiveMultiplier: 0,
        billedRemainderDeltaUp: unbilledSentinel,
        billedRemainderDeltaDown: unbilledSentinel,
      ));
      expect(b.bytesUp, 100);
      expect(b.bytesDown, 100);
      expect(b.estimatedBilledBytesUp, 0);
      expect(b.estimatedBilledBytesDown, 0);
      expect(b.billedRemainderUp, unbilledSentinel);
      expect(b.billedRemainderDown, unbilledSentinel);
      expect(b.isUnbilled, isTrue);

      // 再加一条不可估算的，依然保持 sentinel
      b.accumulate(_delta(
        appIdentifier: unattributedAppIdentifier,
        nodeName: unknownDimensionValue,
        domain: unknownDimensionValue,
        rule: unknownDimensionValue,
        deltaUp: 50,
        deltaDown: 50,
        effectiveMultiplier: 0,
        billedRemainderDeltaUp: unbilledSentinel,
        billedRemainderDeltaDown: unbilledSentinel,
      ));
      expect(b.bytesUp, 150);
      expect(b.bytesDown, 150);
      expect(b.estimatedBilledBytesUp, 0); // 仍不增加
      expect(b.billedRemainderUp, unbilledSentinel);
    });

    test('toModel preserves all fields including remainder', () {
      final b = HourlyBucket(
        periodId: 1,
        hourStart: DateTime(2026, 6, 27, 10),
        appIdentifier: 'chrome.exe',
        nodeName: 'JP-Tokyo',
        domain: 'example.com',
        rule: 'DOMAIN',
        firstMultiplier: 1.5,
      );
      b.accumulate(_delta(
        deltaUp: 10,
        deltaDown: 10,
        effectiveMultiplier: 1.5,
      ));
      // 10 * 1500 = 15000 milliBytes -> 15 estimated, 0 remainder
      expect(b.estimatedBilledBytesUp, 15);
      expect(b.billedRemainderUp, 0);

      final model = b.toModel(updatedAt: DateTime(2026, 6, 27, 10, 0, 30));
      expect(model.periodId, 1);
      expect(model.bytesUp, 10);
      expect(model.bytesDown, 10);
      expect(model.multiplier, 1.5);
      expect(model.estimatedBilledBytesUp, 15);
      expect(model.estimatedBilledBytesDown, 15);
      expect(model.billedRemainderUp, 0);
      expect(model.billedRemainderDown, 0);
    });

    test('toModel preserves unbilled sentinel', () {
      final b = HourlyBucket(
        periodId: 1,
        hourStart: DateTime(2026, 6, 27, 10),
        appIdentifier: unattributedAppIdentifier,
        nodeName: unknownDimensionValue,
        domain: unknownDimensionValue,
        rule: unknownDimensionValue,
        firstMultiplier: 0,
      );
      b.accumulate(_delta(
        appIdentifier: unattributedAppIdentifier,
        nodeName: unknownDimensionValue,
        domain: unknownDimensionValue,
        rule: unknownDimensionValue,
        deltaUp: 100,
        deltaDown: 100,
        effectiveMultiplier: 0,
        billedRemainderDeltaUp: unbilledSentinel,
        billedRemainderDeltaDown: unbilledSentinel,
      ));
      final model = b.toModel(updatedAt: DateTime(2026, 6, 27, 10, 0, 30));
      expect(model.billedRemainderUp, unbilledSentinel);
      expect(model.billedRemainderDown, unbilledSentinel);
      expect(model.isUnbilled, isTrue);
    });
  });

  group('FlushBatch', () {
    test('add accumulates by dimension key, drain returns and clears', () {
      final batch = FlushBatch();
      expect(batch.isEmpty, isTrue);

      final t = DateTime(2026, 6, 27, 10, 30);
      batch.add(
        periodId: 1,
        observedAt: t,
        delta: _delta(deltaUp: 100, deltaDown: 100, effectiveMultiplier: 1.0),
      );
      batch.add(
        periodId: 1,
        observedAt: t,
        delta: _delta(deltaUp: 50, deltaDown: 50, effectiveMultiplier: 1.0),
      );
      expect(batch.length, 1); // 同维度聚合

      final stats = batch.drain(updatedAt: DateTime(2026, 6, 27, 10, 30, 5));
      expect(stats.length, 1);
      expect(stats.first.bytesUp, 150);
      expect(stats.first.bytesDown, 150);
      expect(stats.first.estimatedBilledBytesUp, 150);
      expect(batch.isEmpty, isTrue);
    });

    test('add separates by hour', () {
      final batch = FlushBatch();
      batch.add(
        periodId: 1,
        observedAt: DateTime(2026, 6, 27, 10, 30),
        delta: _delta(deltaUp: 100, deltaDown: 0),
      );
      batch.add(
        periodId: 1,
        observedAt: DateTime(2026, 6, 27, 11, 30),
        delta: _delta(deltaUp: 100, deltaDown: 0),
      );
      expect(batch.length, 2);
      final stats = batch.drain(updatedAt: DateTime(2026, 6, 27, 12, 0));
      expect(stats.length, 2);
      final hours = stats.map((s) => s.hourStart).toSet();
      expect(hours.contains(DateTime(2026, 6, 27, 10)), isTrue);
      expect(hours.contains(DateTime(2026, 6, 27, 11)), isTrue);
    });

    test('add separates by periodId', () {
      final batch = FlushBatch();
      batch.add(
        periodId: 1,
        observedAt: DateTime(2026, 6, 27, 10, 30),
        delta: _delta(deltaUp: 100, deltaDown: 0),
      );
      batch.add(
        periodId: 2,
        observedAt: DateTime(2026, 6, 27, 10, 30),
        delta: _delta(deltaUp: 100, deltaDown: 0),
      );
      expect(batch.length, 2);
    });

    test('Scenario 14: 1.5x multiplier 1000 small deltas via FlushBatch = 1500 bytes', () {
      final batch = FlushBatch();
      final t = DateTime(2026, 6, 27, 10, 30);
      for (var i = 0; i < 1000; i++) {
        batch.add(
          periodId: 1,
          observedAt: t,
          delta: _delta(
            deltaUp: 1,
            deltaDown: 0,
            effectiveMultiplier: 1.5,
          ),
        );
      }
      final stats = batch.drain(updatedAt: t);
      expect(stats.length, 1);
      expect(stats.first.bytesUp, 1000);
      // 1000 * 1.5 = 1500 (毫字节余数方案)
      expect(stats.first.estimatedBilledBytesUp, 1500);
      expect(stats.first.billedRemainderUp, 0);
    });

    test('Scenario 16: same hour multiplier change via FlushBatch keeps per-delta multiplier', () {
      final batch = FlushBatch();
      final t = DateTime(2026, 6, 27, 10, 30);
      // 第一次 1GB @ 2x
      batch.add(
        periodId: 1,
        observedAt: t,
        delta: _delta(
          deltaUp: 1024 * 1024 * 1024,
          deltaDown: 0,
          effectiveMultiplier: 2.0,
        ),
      );
      // 第二次 1GB @ 3x（用户修改了节点倍率）
      batch.add(
        periodId: 1,
        observedAt: t,
        delta: _delta(
          deltaUp: 1024 * 1024 * 1024,
          deltaDown: 0,
          effectiveMultiplier: 3.0,
        ),
      );
      final stats = batch.drain(updatedAt: t);
      expect(stats.length, 1);
      // 实际流量 = 2GB
      expect(stats.first.bytesUp, 2 * 1024 * 1024 * 1024);
      // 预计扣量 = 2GB + 3GB = 5GB
      expect(stats.first.estimatedBilledBytesUp, 5 * 1024 * 1024 * 1024);
      // firstMultiplier 保留首次值 2.0（展示用途）
      expect(stats.first.multiplier, 2.0);
    });
  });

  group('FlushBatch.mergeBack（Stage 3.1 并发安全）', () {
    test('drain 后 mergeBack 同 key 数据累加', () {
      final batch = FlushBatch();
      final t = DateTime(2026, 6, 27, 10);
      batch.add(
        periodId: 1,
        observedAt: t,
        delta: const AttributedDelta(
          appIdentifier: 'chrome.exe',
          nodeName: 'JP',
          domain: 'example.com',
          rule: 'DOMAIN-SUFFIX',
          deltaUp: 1000,
          deltaDown: 2000,
          effectiveMultiplier: 1.0,
          estimatedBilledDeltaUp: 1000,
          estimatedBilledDeltaDown: 2000,
          billedRemainderDeltaUp: 0,
          billedRemainderDeltaDown: 0,
        ),
      );
      final stats = batch.drain(updatedAt: t);
      expect(stats.length, 1);
      expect(batch.isEmpty, true);

      // mergeBack 后数据恢复到桶中。
      batch.mergeBack(stats);
      expect(batch.length, 1);
      final stats2 = batch.drain(updatedAt: t);
      expect(stats2.first.bytesUp, 1000);
      expect(stats2.first.bytesDown, 2000);
    });

    test('mergeBack 与新写入数据累加（不覆盖）', () {
      final batch = FlushBatch();
      final t = DateTime(2026, 6, 27, 10);
      batch.add(
        periodId: 1,
        observedAt: t,
        delta: const AttributedDelta(
          appIdentifier: 'chrome.exe',
          nodeName: 'JP',
          domain: 'example.com',
          rule: 'DOMAIN-SUFFIX',
          deltaUp: 1000,
          deltaDown: 1000,
          effectiveMultiplier: 1.0,
          estimatedBilledDeltaUp: 1000,
          estimatedBilledDeltaDown: 1000,
          billedRemainderDeltaUp: 0,
          billedRemainderDeltaDown: 0,
        ),
      );
      final stats = batch.drain(updatedAt: t);

      // 在 mergeBack 之前，新数据先写入空桶。
      batch.add(
        periodId: 1,
        observedAt: t,
        delta: const AttributedDelta(
          appIdentifier: 'chrome.exe',
          nodeName: 'JP',
          domain: 'example.com',
          rule: 'DOMAIN-SUFFIX',
          deltaUp: 500,
          deltaDown: 500,
          effectiveMultiplier: 1.0,
          estimatedBilledDeltaUp: 500,
          estimatedBilledDeltaDown: 500,
          billedRemainderDeltaUp: 0,
          billedRemainderDeltaDown: 0,
        ),
      );
      // mergeBack：累加而非覆盖。
      batch.mergeBack(stats);
      final stats2 = batch.drain(updatedAt: t);
      expect(stats2.length, 1);
      expect(stats2.first.bytesUp, 1500); // 1000 + 500
      expect(stats2.first.bytesDown, 1500);
    });

    test('mergeBack 含 sentinel 余数时正确传播', () {
      final batch = FlushBatch();
      final t = DateTime(2026, 6, 27, 10);
      batch.add(
        periodId: 1,
        observedAt: t,
        delta: const AttributedDelta(
          appIdentifier: unattributedAppIdentifier,
          nodeName: unknownDimensionValue,
          domain: unknownDimensionValue,
          rule: unknownDimensionValue,
          deltaUp: 1000,
          deltaDown: 1000,
          effectiveMultiplier: 0,
          estimatedBilledDeltaUp: 0,
          estimatedBilledDeltaDown: 0,
          billedRemainderDeltaUp: unbilledSentinel,
          billedRemainderDeltaDown: unbilledSentinel,
        ),
      );
      final stats = batch.drain(updatedAt: t);
      batch.mergeBack(stats);
      final stats2 = batch.drain(updatedAt: t);
      expect(stats2.first.billedRemainderUp, unbilledSentinel);
      expect(stats2.first.billedRemainderDown, unbilledSentinel);
      expect(stats2.first.isUnbilled, true);
    });
  });

  group('HourlyTrafficStat isUnbilled extension', () {
    test('isUnbilled true when either remainder is -1', () {
      final stat = HourlyTrafficStat(
        periodId: 1,
        hourStart: DateTime(2026, 6, 27, 10),
        appIdentifier: unattributedAppIdentifier,
        nodeName: '',
        domain: '',
        rule: '',
        bytesUp: 100,
        bytesDown: 100,
        multiplier: 0,
        estimatedBilledBytesUp: 0,
        estimatedBilledBytesDown: 0,
        billedRemainderUp: unbilledSentinel,
        billedRemainderDown: unbilledSentinel,
        updatedAt: DateTime(2026, 6, 27, 10, 30),
      );
      expect(stat.isUnbilled, isTrue);
    });

    test('isUnbilled false when both remainders are non-negative', () {
      final stat = HourlyTrafficStat(
        periodId: 1,
        hourStart: DateTime(2026, 6, 27, 10),
        appIdentifier: 'chrome.exe',
        nodeName: 'JP-Tokyo',
        domain: '',
        rule: '',
        bytesUp: 100,
        bytesDown: 100,
        multiplier: 1.0,
        estimatedBilledBytesUp: 100,
        estimatedBilledBytesDown: 100,
        billedRemainderUp: 0,
        billedRemainderDown: 0,
        updatedAt: DateTime(2026, 6, 27, 10, 30),
      );
      expect(stat.isUnbilled, isFalse);
    });
  });
}
