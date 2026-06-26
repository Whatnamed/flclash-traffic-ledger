import 'package:fl_clash/models/traffic_ledger.dart'
    show unattributedAppIdentifier;
import 'package:fl_clash/traffic_ledger/collection/multiplier_precision.dart';

// 重新导出，方便 collection 模块内部统一引用。
export 'package:fl_clash/models/traffic_ledger.dart'
    show unattributedAppIdentifier, unknownDimensionValue;

/// 一次采样的原始数据（来自 CoreController）。
///
/// 所有字段都是核心返回的**累计**值，采集服务负责计算增量。
/// [observedAt] 是采样观察时间，用于决定归属周期（见 Stage 3 需求六）。
class TrafficSample {
  const TrafficSample({
    required this.observedAt,
    required this.totalProxyUp,
    required this.totalProxyDown,
    required this.connections,
  });

  final DateTime observedAt;
  final int totalProxyUp;
  final int totalProxyDown;
  final List<ConnectionSnapshot> connections;
}

/// 单连接快照。从 [TrackerInfo] 提取的字段，去除无关信息。
class ConnectionSnapshot {
  const ConnectionSnapshot({
    required this.id,
    required this.upload,
    required this.download,
    required this.appIdentifier,
    required this.nodeName,
    required this.domain,
    required this.rule,
    required this.chains,
    required this.isProxy,
  });

  /// mihomo 核心连接 ID。
  final String id;

  /// 该连接累计上传字节。
  final int upload;

  /// 该连接累计下载字节。
  final int download;

  /// 发起进程名（空字符串表示未识别进程）。
  final String appIdentifier;

  /// 叶子出口节点名（空字符串表示仅 chain 可用、无叶子节点）。
  final String nodeName;

  /// 目标域名（host 优先，无则 destinationIP）。
  final String domain;

  /// 命中规则（rule + rulePayload 拼接，空字符串表示未知）。
  final String rule;

  /// 原始代理链（用于 DIRECT 判定与诊断）。
  final List<String> chains;

  /// 是否经过代理（chains 不含 DIRECT 或含非 DIRECT 出口）。
  final bool isProxy;
}

/// 采集状态（跨采样保持，不落库，仅在内存中）。
class CollectionState {
  const CollectionState({
    this.generation = 0,
    this.lastTotalUp = 0,
    this.lastTotalDown = 0,
    this.lastConnectionBytes = const {},
    this.lastSampleAt,
    this.baselineEstablished = false,
  });

  /// 核心会话标识。每次核心启动/重启时递增，用于检测会话切换。
  final int generation;

  /// 上一次总代理上传字节基线。
  final int lastTotalUp;

  /// 上一次总代理下载字节基线。
  final int lastTotalDown;

  /// 按连接 ID 保存的上次字节基线。
  final Map<String, ConnectionBaseline> lastConnectionBytes;

  /// 上一次成功采样时间。
  final DateTime? lastSampleAt;

  /// 是否已完成首次基线建立。
  final bool baselineEstablished;

  CollectionState copyWith({
    int? generation,
    int? lastTotalUp,
    int? lastTotalDown,
    Map<String, ConnectionBaseline>? lastConnectionBytes,
    DateTime? lastSampleAt,
    bool? baselineEstablished,
  }) {
    return CollectionState(
      generation: generation ?? this.generation,
      lastTotalUp: lastTotalUp ?? this.lastTotalUp,
      lastTotalDown: lastTotalDown ?? this.lastTotalDown,
      lastConnectionBytes:
          lastConnectionBytes ?? this.lastConnectionBytes,
      lastSampleAt: lastSampleAt ?? this.lastSampleAt,
      baselineEstablished:
          baselineEstablished ?? this.baselineEstablished,
    );
  }
}

/// 单连接基线。
class ConnectionBaseline {
  const ConnectionBaseline({
    required this.upload,
    required this.download,
  });

  final int upload;
  final int download;
}

/// Reconciliation 结果。
class ReconciliationResult {
  const ReconciliationResult({
    required this.attributedDeltas,
    required this.unattributedDeltaUp,
    required this.unattributedDeltaDown,
    required this.overflow,
    required this.newState,
    required this.diagnostics,
  });

  /// 已归因增量列表（按应用/节点/域名/规则维度）。
  final List<AttributedDelta> attributedDeltas;

  /// 未归因代理流量增量（上行）。
  final int unattributedDeltaUp;

  /// 未归因代理流量增量（下行）。
  final int unattributedDeltaDown;

  /// 是否发生了 reconciliation overflow（连接归因总和 > 总代理增量）。
  final bool overflow;

  /// 新的采集状态。
  final CollectionState newState;

  /// 轻量诊断信息（overflow、核心重启等）。
  final List<String> diagnostics;
}

/// 单维度已归因增量。
///
/// [estimatedBilledDeltaUp/Down] 是整数部分，
/// [billedRemainderDeltaUp/Down] 是毫字节余数（0–999）或
/// [unbilledSentinel]（-1，表示无法可靠估算扣量）。
class AttributedDelta {
  const AttributedDelta({
    required this.appIdentifier,
    required this.nodeName,
    required this.domain,
    required this.rule,
    required this.deltaUp,
    required this.deltaDown,
    required this.effectiveMultiplier,
    required this.estimatedBilledDeltaUp,
    required this.estimatedBilledDeltaDown,
    required this.billedRemainderDeltaUp,
    required this.billedRemainderDeltaDown,
  });

  final String appIdentifier;
  final String nodeName;
  final String domain;
  final String rule;

  /// 实际增量字节。
  final int deltaUp;
  final int deltaDown;

  /// 当时有效倍率（展示用途）。
  final double effectiveMultiplier;

  /// 预计扣量增量（整数部分）。
  final int estimatedBilledDeltaUp;
  final int estimatedBilledDeltaDown;

  /// 预计扣量余数（milliBytes，0–999）或 [unbilledSentinel]。
  final int billedRemainderDeltaUp;
  final int billedRemainderDeltaDown;

  /// 是否为未归因代理流量。
  bool get isUnattributed => appIdentifier == unattributedAppIdentifier;

  /// 是否为未识别进程（有归因但无进程名）。
  bool get isUnidentifiedProcess =>
      !isUnattributed && appIdentifier.isEmpty;
}

/// 代理承载进程名集合。这些进程的连接流量不作为普通应用排行项，
/// 改归入未归因代理流量。
///
/// 注意：进程名比较时不区分大小写（Windows 文件系统不区分）。
const Set<String> proxyHostProcessNames = {
  'flclash.exe',
  'flclashcore.exe',
  'flclashhelperservice.exe',
};

/// 判断进程名是否为代理承载进程（大小写不敏感）。
bool isProxyHostProcess(String processName) {
  final lower = processName.toLowerCase();
  // 取 basename（去掉路径）
  final lastSep = lower.lastIndexOf(RegExp(r'[/\\]'));
  final basename = lastSep >= 0 ? lower.substring(lastSep + 1) : lower;
  return proxyHostProcessNames.contains(basename);
}
