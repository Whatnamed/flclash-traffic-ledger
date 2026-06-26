import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/traffic_ledger/collection/models.dart';
import 'package:fl_clash/traffic_ledger/collection/multiplier_precision.dart';

/// 内存中的小时聚合桶。采集服务每次采样得到的 [AttributedDelta] 先写入
/// 此桶，每 15–30 秒批量 flush 到 Drift DAO。
///
/// 桶 key = (periodId, hourStart, appIdentifier, nodeName, domain, rule)。
/// 同 key 的多次增量累加 bytesUp/Down、estimatedBilledBytes、billedRemainder。
/// [firstMultiplier] 仅首次入账时写入（展示用途，历史不变性）。
class HourlyBucket {
  HourlyBucket({
    required this.periodId,
    required this.hourStart,
    required this.appIdentifier,
    required this.nodeName,
    required this.domain,
    required this.rule,
    required this.firstMultiplier,
  });

  final int periodId;
  final DateTime hourStart;
  final String appIdentifier;
  final String nodeName;
  final String domain;
  final String rule;

  /// 首次入账时的有效倍率（展示用途，历史不变性）。
  final double firstMultiplier;

  int bytesUp = 0;
  int bytesDown = 0;
  int estimatedBilledBytesUp = 0;
  int estimatedBilledBytesDown = 0;

  /// 毫字节余数（0–999）或 [unbilledSentinel]（-1，不可估算）。
  int billedRemainderUp = 0;
  int billedRemainderDown = 0;

  /// 是否为不可估算扣量。
  bool get isUnbilled =>
      billedRemainderUp == unbilledSentinel ||
      billedRemainderDown == unbilledSentinel;

  /// 累加一次 [AttributedDelta]。
  void accumulate(AttributedDelta delta) {
    bytesUp += delta.deltaUp;
    bytesDown += delta.deltaDown;

    if (delta.billedRemainderDeltaUp == unbilledSentinel ||
        delta.billedRemainderDeltaDown == unbilledSentinel) {
      // 不可估算：标记为 sentinel，estimated 保持 0。
      billedRemainderUp = unbilledSentinel;
      billedRemainderDown = unbilledSentinel;
      return;
    }

    // 上行
    if (billedRemainderUp != unbilledSentinel) {
      final up = MultiplierPrecision.accumulate(
        existingEstimated: estimatedBilledBytesUp,
        existingRemainder: billedRemainderUp,
        deltaBytes: delta.deltaUp,
        multiplierMillis: MultiplierPrecision.toMillis(
          delta.effectiveMultiplier,
        ),
      );
      estimatedBilledBytesUp = up.estimated;
      billedRemainderUp = up.remainder;
    }

    // 下行
    if (billedRemainderDown != unbilledSentinel) {
      final down = MultiplierPrecision.accumulate(
        existingEstimated: estimatedBilledBytesDown,
        existingRemainder: billedRemainderDown,
        deltaBytes: delta.deltaDown,
        multiplierMillis: MultiplierPrecision.toMillis(
          delta.effectiveMultiplier,
        ),
      );
      estimatedBilledBytesDown = down.estimated;
      billedRemainderDown = down.remainder;
    }
  }

  /// 转为 [HourlyTrafficStat]（用于 flush 到 DAO）。
  HourlyTrafficStat toModel({required DateTime updatedAt}) {
    return HourlyTrafficStat(
      periodId: periodId,
      hourStart: hourStart,
      appIdentifier: appIdentifier,
      nodeName: nodeName,
      domain: domain,
      rule: rule,
      bytesUp: bytesUp,
      bytesDown: bytesDown,
      multiplier: firstMultiplier,
      estimatedBilledBytesUp: estimatedBilledBytesUp,
      estimatedBilledBytesDown: estimatedBilledBytesDown,
      billedRemainderUp: billedRemainderUp,
      billedRemainderDown: billedRemainderDown,
      updatedAt: updatedAt,
    );
  }
}

/// 内存聚合桶管理器。按 key 维度维护多个 [HourlyBucket]。
class FlushBatch {
  final Map<String, HourlyBucket> _buckets = {};

  /// 是否有待写入数据。
  bool get isEmpty => _buckets.isEmpty;
  bool get isNotEmpty => _buckets.isNotEmpty;

  /// 添加一次 [AttributedDelta] 到对应桶。
  void add({
    required int periodId,
    required DateTime observedAt,
    required AttributedDelta delta,
  }) {
    final hourStart = DateTime(
      observedAt.year,
      observedAt.month,
      observedAt.day,
      observedAt.hour,
    );
    final key =
        '$periodId\u0000${hourStart.millisecondsSinceEpoch}\u0000'
        '${delta.appIdentifier}\u0000${delta.nodeName}\u0000'
        '${delta.domain}\u0000${delta.rule}';
    final bucket = _buckets[key];
    if (bucket == null) {
      final b = HourlyBucket(
        periodId: periodId,
        hourStart: hourStart,
        appIdentifier: delta.appIdentifier,
        nodeName: delta.nodeName,
        domain: delta.domain,
        rule: delta.rule,
        firstMultiplier: delta.effectiveMultiplier,
      );
      b.accumulate(delta);
      _buckets[key] = b;
    } else {
      bucket.accumulate(delta);
    }
  }

  /// 取出所有待写入的 [HourlyTrafficStat]，并清空桶。
  ///
  /// [updatedAt] 为 flush 时刻（用于 updatedAt 列）。
  List<HourlyTrafficStat> drain({required DateTime updatedAt}) {
    final result =
        _buckets.values.map((b) => b.toModel(updatedAt: updatedAt)).toList();
    _buckets.clear();
    return result;
  }

  /// 将 flush 失败的数据合并回桶（Stage 3.1 并发安全）。
  ///
  /// 语义：DAO 写入失败时调用，把 [stats] 重新累加回当前桶。
  /// - 同 key 的桶：累加 bytesUp/Down、estimated、remainder；
  /// - 新 key：创建新桶；
  /// - 调用方需保证 [stats] 是最近一次 drain 的结果（同 updatedAt）。
  ///
  /// 注意：drain 后到 mergeBack 之间新写入的增量不会被覆盖，
  /// mergeBack 是"累加"而非"替换"。
  void mergeBack(Iterable<HourlyTrafficStat> stats) {
    for (final s in stats) {
      final key =
          '${s.periodId}\u0000${s.hourStart.millisecondsSinceEpoch}\u0000'
          '${s.appIdentifier}\u0000${s.nodeName}\u0000'
          '${s.domain}\u0000${s.rule}';
      final bucket = _buckets[key];
      if (bucket == null) {
        final b = HourlyBucket(
          periodId: s.periodId,
          hourStart: s.hourStart,
          appIdentifier: s.appIdentifier,
          nodeName: s.nodeName,
          domain: s.domain,
          rule: s.rule,
          firstMultiplier: s.multiplier,
        )
          ..bytesUp = s.bytesUp
          ..bytesDown = s.bytesDown
          ..estimatedBilledBytesUp = s.estimatedBilledBytesUp
          ..estimatedBilledBytesDown = s.estimatedBilledBytesDown
          ..billedRemainderUp = s.billedRemainderUp
          ..billedRemainderDown = s.billedRemainderDown;
        _buckets[key] = b;
      } else {
        bucket
          ..bytesUp += s.bytesUp
          ..bytesDown += s.bytesDown;
        // 余数合并：任一为 sentinel → sentinel；否则相加（不进位，留给下次 flush 累加）。
        if (bucket.billedRemainderUp == unbilledSentinel ||
            s.billedRemainderUp == unbilledSentinel) {
          bucket.billedRemainderUp = unbilledSentinel;
          bucket.estimatedBilledBytesUp = 0;
        } else {
          bucket.estimatedBilledBytesUp += s.estimatedBilledBytesUp;
          bucket.billedRemainderUp += s.billedRemainderUp;
        }
        if (bucket.billedRemainderDown == unbilledSentinel ||
            s.billedRemainderDown == unbilledSentinel) {
          bucket.billedRemainderDown = unbilledSentinel;
          bucket.estimatedBilledBytesDown = 0;
        } else {
          bucket.estimatedBilledBytesDown += s.estimatedBilledBytesDown;
          bucket.billedRemainderDown += s.billedRemainderDown;
        }
      }
    }
  }

  /// 仅查看当前桶数量（用于测试与诊断）。
  int get length => _buckets.length;
}
