import 'package:fl_clash/core/controller.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/traffic_ledger/collection/models.dart';
import 'package:fl_clash/traffic_ledger/collection/reconciler.dart';
import 'package:fl_clash/traffic_ledger/multiplier_parser.dart';
import 'package:fl_clash/traffic_ledger/node_multiplier_service.dart';

/// 采样数据源接口。负责从核心获取一次原始采样。
///
/// 实现应：
/// - 不抛异常（核心未就绪、IPC 失败时返回 null）；
/// - 返回的 [TrafficSample] 字段均为核心返回的**累计**值；
/// - [observedAt] 由调用方传入或实现内部使用 `DateTime.now()`。
abstract class TrafficSampleSource {
  Future<TrafficSample?> collect({DateTime? now});
}

/// 基于 [CoreController] 的采样数据源实现。
///
/// 始终使用 `onlyStatisticsProxy: true` 获取代理流量累计值，因为
/// 流量账本的总量权威是"总代理流量"，DIRECT 流量不进入账本
/// （见 Stage 3 需求五）。
///
/// 字段映射（TrackerInfo → ConnectionSnapshot）：
/// - `appIdentifier` = `metadata.process`（进程名，可能为空）；
/// - `nodeName` = `chains.isNotEmpty && chains.last != 'DIRECT'`
///    ? `chains.last` : `''`（叶子出口节点）；
/// - `domain` = `metadata.host.isNotEmpty ? metadata.host : metadata.destinationIP`；
/// - `rule` = `${rule} ${rulePayload}`.trim()；
/// - `isProxy` = chains 非空且不是单纯 `['DIRECT']`。
class CoreControllerSampleSource implements TrafficSampleSource {
  CoreControllerSampleSource(this._controller);

  final CoreController _controller;

  @override
  Future<TrafficSample?> collect({DateTime? now}) async {
    try {
      final totalTraffic = await _controller.getTotalTraffic(true);
      final connections = await _controller.getConnections();
      return TrafficSample(
        observedAt: now ?? DateTime.now(),
        totalProxyUp: totalTraffic.up.toInt(),
        totalProxyDown: totalTraffic.down.toInt(),
        connections: connections.map(_toSnapshot).toList(growable: false),
      );
    } catch (_) {
      // 核心未就绪、IPC 失败、JSON 解析失败等：返回 null，跳过本次采样。
      return null;
    }
  }

  /// 将 [TrackerInfo] 转为 [ConnectionSnapshot]。
  static ConnectionSnapshot _toSnapshot(TrackerInfo conn) {
    final chains = conn.chains;
    final isDirect = chains.length == 1 && chains.first == 'DIRECT';
    final isProxy = chains.isNotEmpty && !isDirect;

    // 叶子出口节点：chains 的最后一个元素（非 DIRECT 时）。
    // 若 chains 为空或仅含 DIRECT，nodeName 为空字符串。
    final nodeName = isProxy ? chains.last : '';

    // 域名：host 优先，无则 destinationIP。
    final host = conn.metadata.host;
    final destIp = conn.metadata.destinationIP;
    final domain = host.isNotEmpty ? host : destIp;

    // 规则：rule + rulePayload 拼接。
    final rule = '${conn.rule} ${conn.rulePayload}'.trim();

    return ConnectionSnapshot(
      id: conn.id,
      upload: conn.upload,
      download: conn.download,
      appIdentifier: conn.metadata.process,
      nodeName: nodeName,
      domain: domain,
      rule: rule,
      chains: chains,
      isProxy: isProxy,
    );
  }
}

/// 缓存式倍率解析器。包装 [NodeMultiplierService]，提供同步查询接口
/// 给 [Reconciler] 使用。
///
/// 缓存语义：
/// - `nodeName` 为空 → 返回 null（不可估算）；
/// - DB 有记录 → `manualMultiplier ?? parsedMultiplier`（可靠）；
/// - DB 无记录但节点名含倍率模式（如 "2x"）→ 解析值（可靠）；
/// - DB 无记录且名称无倍率模式 → null（不可估算，不默认 1× 冒充）。
///
/// 缓存按节点名缓存，倍率变更后需调用 [clearCache] 刷新。
/// Stage 3 不提供倍率变更 UI，缓存仅在服务生命周期内有效；
/// Stage 4 在倍率变更时调用 [clearCache] 即可让后续采样使用新倍率。
class CachedMultiplierResolver implements MultiplierResolver {
  CachedMultiplierResolver(this._service);

  final NodeMultiplierService _service;
  final Map<String, double?> _cache = {};

  @override
  double? effectiveMultiplierFor(String nodeName) {
    if (nodeName.isEmpty) return null;
    return _cache[nodeName];
  }

  /// 为给定节点名列表刷新缓存。已缓存的节点跳过（避免每秒查库）。
  /// 新节点会查询 [NodeMultiplierService] 并缓存结果（含 null）。
  Future<void> refreshFor(Iterable<String> nodeNames) async {
    for (final name in nodeNames) {
      if (name.isEmpty) continue;
      if (_cache.containsKey(name)) continue;
      final record = await _service.getRecord(name);
      if (record != null) {
        _cache[name] = record.manualMultiplier ?? record.parsedMultiplier;
      } else {
        // 无 DB 记录：尝试从名称解析。无模式则缓存 null（不可估算）。
        _cache[name] = MultiplierParser.parse(name);
      }
    }
  }

  /// 清空缓存。倍率变更后调用，让后续采样重新查询。
  void clearCache() => _cache.clear();
}
