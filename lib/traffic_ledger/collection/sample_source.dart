import 'package:fl_clash/core/controller.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/traffic_ledger/collection/app_identifier.dart';
import 'package:fl_clash/traffic_ledger/collection/domain_normalizer.dart';
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
  /// 采集一次采样。
  ///
  /// 实现必须遵循以下读取顺序（Stage 3.1 一致性要求）：
  /// 1. 先读取连接列表；
  /// 2. 再读取总代理流量；
  /// 3. 最后记录 observedAt。
  ///
  /// 这样总代理快照覆盖连接快照之前的流量，避免连接归因 > 总代理
  /// 的假 overflow。两者之间新增流量自然成为未归因差额。
  Future<TrafficSample?> collect({DateTime? now});
}

/// 基于 [CoreController] 的采样数据源实现。
///
/// 读取顺序（Stage 3.1 修正）：先 `getConnections()`，后
/// `getTotalTraffic(true)`，最后 `observedAt`。理由见 [TrafficSampleSource]。
///
/// 字段映射（TrackerInfo → ConnectionSnapshot）：
/// - `appIdentifier` = processPath 非空 ? 规范化 processPath : process；
/// - `nodeName` = `chains.isNotEmpty && chains.last != 'DIRECT'`
///    ? `chains.last` : `''`（叶子出口节点）；
/// - `domain` = 规范化 host（非空）或 destinationIP；
/// - `rule` = `${rule} ${rulePayload}`.trim()；
/// - `isProxy` = chains 非空且不是单纯 `['DIRECT']`。
class CoreControllerSampleSource implements TrafficSampleSource {
  CoreControllerSampleSource(this._controller);

  final CoreController _controller;

  @override
  Future<TrafficSample?> collect({DateTime? now}) async {
    try {
      // Stage 3.1: 先连接、后总代理，避免假 overflow。
      final connections = await _controller.getConnections();
      final totalTraffic = await _controller.getTotalTraffic(true);
      // observedAt 在两次读取之后记录，代表"采样观察时刻"。
      // 由调用方传入的 now 优先（测试可控时钟），否则用系统时钟。
      final observedAt = now ?? DateTime.now();
      return TrafficSample(
        observedAt: observedAt,
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
  ///
  /// Stage 3.1: appIdentifier 优先使用规范化 processPath，仅当 processPath
  /// 为空时退回 process 名。两者均空时为未识别进程（''）。
  static ConnectionSnapshot _toSnapshot(TrackerInfo conn) {
    final chains = conn.chains;
    final isDirect = chains.length == 1 && chains.first == 'DIRECT';
    final isProxy = chains.isNotEmpty && !isDirect;

    // 叶子出口节点：chains 的最后一个元素（非 DIRECT 时）。
    final nodeName = isProxy ? chains.last : '';

    // appIdentifier：processPath 优先，process 兜底。
    final appIdentifier = AppIdentifierResolver.resolve(
      processPath: conn.metadata.processPath,
      process: conn.metadata.process,
    );

    // domain：host 优先（规范化），无则 destinationIP。
    final rawHost = conn.metadata.host;
    final domain = rawHost.isNotEmpty
        ? DomainNormalizer.normalize(rawHost)
        : conn.metadata.destinationIP;

    // 规则：rule + rulePayload 拼接。
    final rule = '${conn.rule} ${conn.rulePayload}'.trim();

    return ConnectionSnapshot(
      id: conn.id,
      upload: conn.upload,
      download: conn.download,
      appIdentifier: appIdentifier,
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
