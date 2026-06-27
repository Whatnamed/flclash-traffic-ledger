import 'dart:io'; // DIAGNOSTIC-TEMP: 文件日志

import 'package:fl_clash/core/controller.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/traffic_ledger/collection/app_identifier.dart';
import 'package:fl_clash/traffic_ledger/collection/domain_normalizer.dart';
import 'package:fl_clash/traffic_ledger/collection/models.dart';
import 'package:fl_clash/traffic_ledger/collection/reconciler.dart';
import 'package:fl_clash/traffic_ledger/collection/traffic_diagnostics.dart';
import 'package:fl_clash/traffic_ledger/multiplier_parser.dart';
import 'package:fl_clash/traffic_ledger/node_multiplier_service.dart';
import 'package:flutter/foundation.dart'; // DIAGNOSTIC-TEMP: kDebugMode

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
      // Stage 3.2: 诊断计时（kDebugMode 下生效，release 编译期消除）。
      final diag = TrafficDiagnostics.instance;
      final sw = diag.enabled ? (Stopwatch()..start()) : null;
      final connections = await _controller.getConnections();
      final t1 = sw?.elapsedMilliseconds ?? 0;
      sw?.reset();
      final totalTraffic = await _controller.getTotalTraffic(true);
      final t2 = sw?.elapsedMilliseconds ?? 0;
      // observedAt 在两次读取之后记录，代表"采样观察时刻"。
      // 由调用方传入的 now 优先（测试可控时钟），否则用系统时钟。
      final observedAt = now ?? DateTime.now();
      if (diag.enabled) {
        diag.recordCollection(
          getConnectionsMs: t1,
          getTotalTrafficMs: t2,
          rawConnections: connections,
        );
      }
      // DIAGNOSTIC-TEMP: reconciliation overflow root cause probe.
      // 输出脱敏聚合统计，定位 observed ≈ 2× total 的根因。
      // 验收后恢复（搜索 DIAGNOSTIC-TEMP 移除整块）。
      if (kDebugMode) {
        _emitDiagnosticLog(connections, totalTraffic);
      }
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

  /// DIAGNOSTIC-TEMP: 脱敏诊断日志。
  /// 输出连接快照结构统计，不输出原始 id/host/ip/port/node/process。
  static void _emitDiagnosticLog(
    List<TrackerInfo> connections,
    Traffic totalTraffic,
  ) {
    final total = connections.length;
    final proxyConns = connections.where((c) {
      final chains = c.chains;
      return chains.isNotEmpty && !(chains.length == 1 && chains.first == 'DIRECT');
    }).toList();
    final proxyCount = proxyConns.length;
    final idCounts = <String, int>{};
    for (final c in proxyConns) {
      idCounts[c.id] = (idCounts[c.id] ?? 0) + 1;
    }
    final uniqueIdCount = idCounts.length;
    final dupIdEntries = idCounts.values.where((v) => v > 1).fold<int>(0, (a, b) => a + b);
    final dupIdGroups = idCounts.values.where((v) => v > 1).length;
    final dupSizeDist = <int, int>{};
    for (final v in idCounts.values.where((v) => v > 1)) {
      dupSizeDist[v] = (dupSizeDist[v] ?? 0) + 1;
    }
    // 脱敏指纹：network/进程是否存在/chain长度
    final fingerprintCounts = <String, int>{};
    for (final c in proxyConns) {
      final hasProcess = c.metadata.process.isNotEmpty ? 'P1' : 'P0';
      final net = c.metadata.network.isEmpty ? 'N?' : c.metadata.network;
      final chainLen = c.chains.length.toString();
      final fp = '$net|chain$chainLen|$hasProcess';
      fingerprintCounts[fp] = (fingerprintCounts[fp] ?? 0) + 1;
    }
    // 连接级 upload/download 累加（与核心 totalProxy 对比）
    int sumConnUp = 0;
    int sumConnDown = 0;
    for (final c in proxyConns) {
      sumConnUp += c.upload;
      sumConnDown += c.download;
    }
    final line = '[DIAG-SAMPLE] total=$total proxy=$proxyCount '
        'uniqueId=$uniqueIdCount dupEntries=$dupIdEntries dupGroups=$dupIdGroups '
        'dupSizeDist=$dupSizeDist '
        'totalUp=${totalTraffic.up} totalDown=${totalTraffic.down} '
        'sumConnUp=$sumConnUp sumConnDown=$sumConnDown '
        'fingerprints=$fingerprintCounts\n';
    // DIAGNOSTIC-TEMP: 写文件绕过 stdout 缓冲，验收后恢复
    try {
      final logFile = File(r'C:\Users\hasee\diag_sample.log');
      logFile.writeAsStringSync(line, mode: FileMode.append);
    } catch (_) {}
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
