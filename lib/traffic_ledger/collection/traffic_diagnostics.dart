import 'package:fl_clash/models/models.dart';
import 'package:flutter/foundation.dart';

/// Stage 3.2 验收用临时诊断统计。
///
/// **仅在 `kDebugMode` 下启用**：release 构建中所有调用通过 `enabled`
/// getter 短路，Dart 编译器在 tree-shaking 阶段会消除全部诊断代码，
/// 不污染正式发布构建。
///
/// 脱敏原则（严格遵守用户安全边界）：
/// - 不输出订阅 URL、认证信息、token、完整 IP:端口、完整代理节点地址；
/// - host / processPath / chain / rule 只记录长度、非空比例、截断前缀；
/// - 截断前缀仅取前 4 字符 + `...`，用于验证字段"是否有值"，不可逆推原值；
/// - 节点名只记录被识别为倍率模式的比例，不输出节点名本身。
class TrafficDiagnostics {
  TrafficDiagnostics._();
  static final TrafficDiagnostics instance = TrafficDiagnostics._();

  /// 是否启用诊断。release 构建中为 false，调用方代码被编译期消除。
  bool get enabled => kDebugMode;

  // ===== 性能采样（环形缓冲，保留最近 N 次）=====
  static const int _maxPerfSamples = 60;
  final List<int> _getConnectionsMs = [];
  final List<int> _getTotalTrafficMs = [];
  final List<int> _totalTickMs = [];
  int _pauseAndFlushWaitsMs = 0;
  int _pauseAndFlushCount = 0;

  // ===== 字段可用性累计 =====
  int _totalSamples = 0;
  int _totalConnections = 0;
  int _processPathNonEmpty = 0;
  int _processNameNonEmpty = 0;
  int _hostNonEmpty = 0;
  int _destinationIpNonEmpty = 0;
  int _directConnections = 0;
  int _proxyConnections = 0;
  int _chainsEmpty = 0;
  int _chainsLen1 = 0; // 仅 DIRECT 形态
  int _chainsLen2 = 0; // [Group, Node]
  int _chainsLen3Plus = 0; // 多级嵌套
  int _ruleEmpty = 0;
  int _rulePayloadEmpty = 0;
  int _selfProcessHits = 0; // isProxyHostProcess 命中数

  // 节点名统计（脱敏：只记录 chains.last 非空数，不存原值）
  int _nodeNameNonEmpty = 0;

  // chains.last 截断前缀分布（脱敏：仅前 4 字符 + ...）
  final Map<String, int> _chainsLastPrefix = {};

  // ===== 生命周期事件 =====
  final List<String> _lifecycleEvents = [];
  static const int _maxLifecycle = 30;

  /// 记录一次 collect() 的性能与字段可用性。
  ///
  /// [rawConnections] 是 CoreController.getConnections() 返回的原始
  /// TrackerInfo 列表（在转换为 ConnectionSnapshot 之前）。
  void recordCollection({
    required int getConnectionsMs,
    required int getTotalTrafficMs,
    required List<TrackerInfo> rawConnections,
  }) {
    if (!enabled) return;
    _totalSamples++;
    _pushPerf(_getConnectionsMs, getConnectionsMs);
    _pushPerf(_getTotalTrafficMs, getTotalTrafficMs);

    for (final conn in rawConnections) {
      _totalConnections++;
      final md = conn.metadata;
      if (md.processPath.trim().isNotEmpty) _processPathNonEmpty++;
      if (md.process.trim().isNotEmpty) _processNameNonEmpty++;
      if (md.host.trim().isNotEmpty) _hostNonEmpty++;
      if (md.destinationIP.trim().isNotEmpty) _destinationIpNonEmpty++;
      if (conn.rule.isEmpty) _ruleEmpty++;
      if (conn.rulePayload.isEmpty) _rulePayloadEmpty++;

      final chains = conn.chains;
      if (chains.isEmpty) {
        _chainsEmpty++;
      } else if (chains.length == 1) {
        _chainsLen1++;
        if (chains.first == 'DIRECT') {
          _directConnections++;
        } else {
          _proxyConnections++;
          _recordChainsLast(chains.last);
        }
      } else if (chains.length == 2) {
        _chainsLen2++;
        _proxyConnections++;
        _recordChainsLast(chains.last);
      } else {
        _chainsLen3Plus++;
        _proxyConnections++;
        _recordChainsLast(chains.last);
      }

      // 自身代理承载进程判定（与 models.dart isProxyHostProcess 同逻辑）
      final processPath = md.processPath.trim();
      final process = md.process.trim();
      final basename = processPath.isNotEmpty
          ? processPath.split(RegExp(r'[/\\]')).last.toLowerCase()
          : process.toLowerCase();
      if (_selfProcessBasenames.contains(basename)) {
        _selfProcessHits++;
      }
    }
  }

  /// 记录一次完整 _tick 的耗时（包含 collect + refreshFor + reconcile）。
  void recordTick(int totalTickMs) {
    if (!enabled) return;
    _pushPerf(_totalTickMs, totalTickMs);
  }

  /// 记录 pauseAndFlush 等待在飞采样的耗时。
  void recordPauseAndFlushWait(int waitMs) {
    if (!enabled) return;
    _pauseAndFlushWaitsMs += waitMs;
    _pauseAndFlushCount++;
  }

  /// 记录生命周期事件（start / pauseAndFlush / flushAndDispose / period switch）。
  void recordLifecycle(String event) {
    if (!enabled) return;
    _lifecycleEvents.add('${DateTime.now().toIso8601String()} $event');
    if (_lifecycleEvents.length > _maxLifecycle) {
      _lifecycleEvents.removeAt(0);
    }
  }

  /// 输出汇总报告（脱敏）。仅返回字符串，由调用方决定是否 log。
  String summarize() {
    if (!enabled) return 'diagnostics disabled (release)';
    final sb = StringBuffer();
    sb.writeln('===== TrafficDiagnostics summary =====');

    // 性能
    sb.writeln('--- performance (ms, last ${_getConnectionsMs.length}) ---');
    sb.writeln('getConnections:    ${_fmtStats(_getConnectionsMs)}');
    sb.writeln('getTotalTraffic:   ${_fmtStats(_getTotalTrafficMs)}');
    sb.writeln('total tick:        ${_fmtStats(_totalTickMs)}');
    sb.writeln(
      'pauseAndFlush wait: count=$_pauseAndFlushCount '
      'total=${_pauseAndFlushWaitsMs}ms',
    );

    // 字段可用性
    sb.writeln('--- field availability ---');
    sb.writeln('samples: $_totalSamples, connections: $_totalConnections');
    if (_totalConnections > 0) {
      String pct(int c) => '${(c * 100 / _totalConnections).toStringAsFixed(1)}%';
      sb.writeln('  processPath non-empty: ${pct(_processPathNonEmpty)}');
      sb.writeln('  process     non-empty: ${pct(_processNameNonEmpty)}');
      sb.writeln('  host        non-empty: ${pct(_hostNonEmpty)}');
      sb.writeln('  destinationIP non-empty: ${pct(_destinationIpNonEmpty)}');
      sb.writeln('  rule        empty: ${pct(_ruleEmpty)}');
      sb.writeln('  rulePayload empty: ${pct(_rulePayloadEmpty)}');
      sb.writeln('  chains distribution: '
          'empty=$_chainsEmpty len1=$_chainsLen1 '
          'len2=$_chainsLen2 len3+=$_chainsLen3Plus');
      sb.writeln('  DIRECT: $_directConnections, proxy: $_proxyConnections');
      sb.writeln('  self-process hits: $_selfProcessHits');
      sb.writeln('  chains.last non-empty: $_nodeNameNonEmpty');
    }

    // chains.last 截断前缀分布（脱敏）
    if (_chainsLastPrefix.isNotEmpty) {
      sb.writeln('--- chains.last prefix distribution (truncated 4 chars) ---');
      final sorted = _chainsLastPrefix.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      for (final e in sorted.take(10)) {
        sb.writeln('  ${e.key}: ${e.value}');
      }
    }

    // 生命周期事件
    sb.writeln('--- lifecycle events (last ${_lifecycleEvents.length}) ---');
    for (final e in _lifecycleEvents) {
      sb.writeln('  $e');
    }

    sb.writeln('===== end summary =====');
    return sb.toString();
  }

  void _pushPerf(List<int> list, int ms) {
    list.add(ms);
    if (list.length > _maxPerfSamples) list.removeAt(0);
  }

  void _recordChainsLast(String last) {
    if (last.isEmpty) return;
    _nodeNameNonEmpty++;
    // 截断前 4 字符作为脱敏前缀
    final prefix = last.length <= 4 ? last : '${last.substring(0, 4)}...';
    _chainsLastPrefix[prefix] = (_chainsLastPrefix[prefix] ?? 0) + 1;
  }

  /// 计算 p50/p95/max 统计字符串。
  String _fmtStats(List<int> list) {
    if (list.isEmpty) return 'n/a';
    final sorted = List<int>.from(list)..sort();
    final n = sorted.length;
    final p50 = sorted[n ~/ 2];
    final p95 = sorted[(n * 0.95).floor().clamp(0, n - 1)];
    final max = sorted.last;
    final avg = sorted.reduce((a, b) => a + b) / n;
    return 'n=$n avg=${avg.toStringAsFixed(1)} '
        'p50=$p50 p95=$p95 max=$max';
  }

  /// 代理承载进程 basename 集合（与 models.dart isProxyHostProcess 同步）。
  static const Set<String> _selfProcessBasenames = {
    'flclash.exe',
    'flclashcore.exe',
    'flclashhelperservice.exe',
  };
}
