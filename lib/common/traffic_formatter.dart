import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/common.dart';

/// Traffic Ledger 统一流量格式化器。
///
/// 与现有 num.traffic / num.shortTraffic 不同，这里面向流量账本场景，
/// 同时处理"实际代理流量"和"按节点倍率计算的预计扣量"，并保持单位一致。
class TrafficFormatter {
  const TrafficFormatter._();

  /// 将字节数格式化为 [TrafficShow]。沿用项目既有约定：1024 进制，
  /// 单位为 TrafficUnit (B/KB/MB/GB/TB)，小数位默认 2 位但去掉尾随 0。
  static TrafficShow format(int bytes, {int decimals = 2}) {
    const units = TrafficUnit.values;
    var size = bytes.toDouble();
    var unitIndex = 0;
    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }
    return TrafficShow(
      value: _trimTrailingZeros(size.toStringAsFixed(decimals)),
      unit: units[unitIndex].name,
    );
  }

  /// 紧凑格式（无小数位），用于摘要卡和列表项。
  static TrafficShow formatCompact(int bytes) {
    const units = TrafficUnit.values;
    var size = bytes.toDouble();
    var unitIndex = 0;
    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }
    return TrafficShow(
      value: size.toStringAsFixed(0),
      unit: ' ${units[unitIndex].name}',
    );
  }

  /// 同时返回实际流量与预计扣量的展示值。
  static TrafficLedgerShow formatWithBilled({
    required int actualBytes,
    required double multiplier,
  }) {
    final billed = (actualBytes * multiplier).round();
    return TrafficLedgerShow(
      actual: format(actualBytes),
      billed: format(billed),
      multiplier: multiplier,
    );
  }

  static String _trimTrailingZeros(String s) {
    if (!s.contains('.')) return s;
    var out = s.replaceAll(RegExp(r'0+$'), '');
    if (out.endsWith('.')) {
      out = out.substring(0, out.length - 1);
    }
    return out;
  }
}

/// 流量账本展示值：实际代理流量 + 预计扣量 + 倍率。
class TrafficLedgerShow {
  final TrafficShow actual;
  final TrafficShow billed;
  final double multiplier;

  const TrafficLedgerShow({
    required this.actual,
    required this.billed,
    required this.multiplier,
  });

  @override
  String toString() =>
      'actual=${actual.show}, billed=${billed.show}, multiplier=${multiplier}x';
}
