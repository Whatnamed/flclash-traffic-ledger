import 'package:fl_clash/traffic_ledger/collection/models.dart';
import 'package:fl_clash/traffic_ledger/collection/multiplier_precision.dart';

/// 节点有效倍率解析器接口。
///
/// Reconciler 通过此接口查询节点当前有效倍率（manual ?? parsed）。
/// 实现可包装 [NodeMultiplierService]；测试用 fake 实现。
abstract class MultiplierResolver {
  /// 返回节点 [nodeName] 的有效倍率。
  /// 若节点无记录且无法从名称解析，返回 null（表示不可估算）。
  double? effectiveMultiplierFor(String nodeName);
}

/// Reconciler 负责把 [TrafficSample] 与上一次 [CollectionState] 比对，
/// 计算出已归因增量 + 未归因增量，并产生新的 [CollectionState]。
///
/// 所有逻辑为纯函数（除通过 [MultiplierResolver] 查询倍率），可单元测试。
class Reconciler {
  const Reconciler({required this.multiplierResolver});

  final MultiplierResolver multiplierResolver;

  /// 对一次采样执行 reconciliation。
  ///
  /// [currentGeneration] 是当前核心会话标识。若与 [state.generation] 不一致，
  /// 视为核心重启，重建基线（不产生增量）。
  ReconciliationResult reconcile({
    required TrafficSample sample,
    required CollectionState state,
    required int currentGeneration,
  }) {
    final diagnostics = <String>[];

    // 1. 首次采样：只建基线，不产生增量。
    // 优先于 generation 检测：尚未建立基线时不算"重启"，而是首次建立。
    if (!state.baselineEstablished) {
      if (currentGeneration != state.generation) {
        diagnostics.add(
          'baseline established on first sample (generation ${state.generation} -> $currentGeneration)',
        );
      } else {
        diagnostics.add('baseline established on first sample');
      }
      return ReconciliationResult(
        attributedDeltas: const [],
        unattributedDeltaUp: 0,
        unattributedDeltaDown: 0,
        overflow: false,
        newState: _establishBaseline(sample, currentGeneration),
        diagnostics: diagnostics,
      );
    }

    // 2. 核心重启检测：generation 变化，重建基线，不产生增量。
    if (currentGeneration != state.generation) {
      diagnostics.add(
        'core restart detected: generation ${state.generation} -> $currentGeneration',
      );
      return ReconciliationResult(
        attributedDeltas: const [],
        unattributedDeltaUp: 0,
        unattributedDeltaDown: 0,
        overflow: false,
        newState: _establishBaseline(sample, currentGeneration),
        diagnostics: diagnostics,
      );
    }

    // 3. 计算总代理增量。回退时重建基线，不产生增量。
    final totalDeltaUp = sample.totalProxyUp - state.lastTotalUp;
    final totalDeltaDown = sample.totalProxyDown - state.lastTotalDown;
    if (totalDeltaUp < 0 || totalDeltaDown < 0) {
      diagnostics.add(
        'total proxy bytes rolled back: '
        'up $totalDeltaUp down $totalDeltaDown, rebuilding baseline',
      );
      return ReconciliationResult(
        attributedDeltas: const [],
        unattributedDeltaUp: 0,
        unattributedDeltaDown: 0,
        overflow: false,
        newState: _establishBaseline(sample, currentGeneration),
        diagnostics: diagnostics,
      );
    }

    // 4. 计算连接归因增量。
    final connectionDeltas = <_ConnectionDelta>[];
    final newConnectionBytes = <String, ConnectionBaseline>{};
    for (final conn in sample.connections) {
      // 仅统计经过代理的连接。
      if (!conn.isProxy) continue;

      final prev = state.lastConnectionBytes[conn.id];
      // 首次见到的连接：建立基线，不计增量。
      if (prev == null) {
        newConnectionBytes[conn.id] = ConnectionBaseline(
          upload: conn.upload,
          download: conn.download,
        );
        continue;
      }

      final dUp = conn.upload - prev.upload;
      final dDown = conn.download - prev.download;
      // 连接字节回退：更新基线，跳过此连接增量。
      if (dUp < 0 || dDown < 0) {
        diagnostics.add(
          'connection ${conn.id} bytes rolled back: '
          'up $dUp down $dDown, updating baseline',
        );
        newConnectionBytes[conn.id] = ConnectionBaseline(
          upload: conn.upload,
          download: conn.download,
        );
        continue;
      }

      // 有正增量才记录。
      if (dUp > 0 || dDown > 0) {
        connectionDeltas.add(_ConnectionDelta(
          snapshot: conn,
          deltaUp: dUp,
          deltaDown: dDown,
        ));
      }
      newConnectionBytes[conn.id] = ConnectionBaseline(
        upload: conn.upload,
        download: conn.download,
      );
    }

    // 5. 聚合同维度连接增量。
    final aggregated = _aggregateByDimension(connectionDeltas);

    // 6. 计算已归因增量总和。
    final observedUp = aggregated.fold<int>(
      0,
      (sum, d) => sum + d.deltaUp,
    );
    final observedDown = aggregated.fold<int>(
      0,
      (sum, d) => sum + d.deltaDown,
    );

    // 7. Reconciliation overflow 检测。
    final overflow = observedUp > totalDeltaUp || observedDown > totalDeltaDown;

    final List<AttributedDelta> attributedDeltas;
    int unattributedUp;
    int unattributedDown;

    if (overflow) {
      // 保守策略：总代理增量全部记入未归因，不写入可疑连接归因。
      diagnostics.add(
        'reconciliation overflow: observed up=$observedUp down=$observedDown '
        '> total up=$totalDeltaUp down=$totalDeltaDown; '
        'attributing all to unattributed',
      );
      attributedDeltas = <AttributedDelta>[];
      unattributedUp = totalDeltaUp;
      unattributedDown = totalDeltaDown;
    } else {
      // 正常情况：归因到应用/节点/域名/规则，差额进未归因。
      attributedDeltas = _toAttributedDeltas(aggregated);
      unattributedUp = totalDeltaUp - observedUp;
      unattributedDown = totalDeltaDown - observedDown;
    }

    // 8. 构建未归因增量（若有）。
    if (unattributedUp > 0 || unattributedDown > 0) {
      attributedDeltas.add(_buildUnattributedDelta(
        deltaUp: unattributedUp,
        deltaDown: unattributedDown,
      ));
    }

    // 9. 产生新状态。
    final newState = CollectionState(
      generation: currentGeneration,
      lastTotalUp: sample.totalProxyUp,
      lastTotalDown: sample.totalProxyDown,
      lastConnectionBytes: newConnectionBytes,
      lastSampleAt: sample.observedAt,
      baselineEstablished: true,
    );

    return ReconciliationResult(
      attributedDeltas: attributedDeltas,
      unattributedDeltaUp: overflow ? totalDeltaUp : unattributedUp,
      unattributedDeltaDown: overflow ? totalDeltaDown : unattributedDown,
      overflow: overflow,
      newState: newState,
      diagnostics: diagnostics,
    );
  }

  /// 建立基线，不产生增量。
  CollectionState _establishBaseline(
    TrafficSample sample,
    int generation,
  ) {
    final connectionBytes = <String, ConnectionBaseline>{};
    for (final conn in sample.connections) {
      if (!conn.isProxy) continue;
      connectionBytes[conn.id] = ConnectionBaseline(
        upload: conn.upload,
        download: conn.download,
      );
    }
    return CollectionState(
      generation: generation,
      lastTotalUp: sample.totalProxyUp,
      lastTotalDown: sample.totalProxyDown,
      lastConnectionBytes: connectionBytes,
      lastSampleAt: sample.observedAt,
      baselineEstablished: true,
    );
  }

  /// 按维度聚合同一连接的增量。
  List<_AggregatedDelta> _aggregateByDimension(
    List<_ConnectionDelta> deltas,
  ) {
    final map = <String, _AggregatedDelta>{};
    for (final d in deltas) {
      // 代理承载进程：跳过，不作为普通应用排行项。
      if (isProxyHostProcess(d.snapshot.appIdentifier)) {
        continue;
      }
      final key =
          '${d.snapshot.appIdentifier}\u0000${d.snapshot.nodeName}\u0000'
          '${d.snapshot.domain}\u0000${d.snapshot.rule}';
      final existing = map[key];
      if (existing == null) {
        map[key] = _AggregatedDelta(
          appIdentifier: d.snapshot.appIdentifier,
          nodeName: d.snapshot.nodeName,
          domain: d.snapshot.domain,
          rule: d.snapshot.rule,
          deltaUp: d.deltaUp,
          deltaDown: d.deltaDown,
        );
      } else {
        map[key] = _AggregatedDelta(
          appIdentifier: existing.appIdentifier,
          nodeName: existing.nodeName,
          domain: existing.domain,
          rule: existing.rule,
          deltaUp: existing.deltaUp + d.deltaUp,
          deltaDown: existing.deltaDown + d.deltaDown,
        );
      }
    }
    return map.values.toList();
  }

  /// 把聚合增量转为 [AttributedDelta]，查询倍率并计算预计扣量。
  List<AttributedDelta> _toAttributedDeltas(
    List<_AggregatedDelta> aggregated,
  ) {
    return aggregated.map((d) {
      final mult = multiplierResolver.effectiveMultiplierFor(d.nodeName);
      final int multMillis;
      final int estUp;
      final int estDown;
      final int remUp;
      final int remDown;
      if (mult == null) {
        // 节点无法可靠识别：实际流量计入，预计扣量不可估算。
        multMillis = 0;
        estUp = 0;
        estDown = 0;
        remUp = unbilledSentinel;
        remDown = unbilledSentinel;
      } else {
        multMillis = MultiplierPrecision.toMillis(mult);
        final up = MultiplierPrecision.split(
          d.deltaUp * multMillis,
        );
        final down = MultiplierPrecision.split(
          d.deltaDown * multMillis,
        );
        estUp = up.estimated;
        estDown = down.estimated;
        remUp = up.remainder;
        remDown = down.remainder;
      }
      return AttributedDelta(
        appIdentifier: d.appIdentifier.isEmpty
            ? unknownDimensionValue
            : d.appIdentifier,
        nodeName: d.nodeName,
        domain: d.domain,
        rule: d.rule,
        deltaUp: d.deltaUp,
        deltaDown: d.deltaDown,
        effectiveMultiplier: mult ?? 0,
        estimatedBilledDeltaUp: estUp,
        estimatedBilledDeltaDown: estDown,
        billedRemainderDeltaUp: remUp,
        billedRemainderDeltaDown: remDown,
      );
    }).toList();
  }

  /// 构建未归因代理流量增量。无可靠节点，预计扣量不可估算。
  AttributedDelta _buildUnattributedDelta({
    required int deltaUp,
    required int deltaDown,
  }) {
    return AttributedDelta(
      appIdentifier: unattributedAppIdentifier,
      nodeName: unknownDimensionValue,
      domain: unknownDimensionValue,
      rule: unknownDimensionValue,
      deltaUp: deltaUp,
      deltaDown: deltaDown,
      effectiveMultiplier: 0,
      estimatedBilledDeltaUp: 0,
      estimatedBilledDeltaDown: 0,
      billedRemainderDeltaUp: unbilledSentinel,
      billedRemainderDeltaDown: unbilledSentinel,
    );
  }
}

/// 内部：单连接增量。
class _ConnectionDelta {
  const _ConnectionDelta({
    required this.snapshot,
    required this.deltaUp,
    required this.deltaDown,
  });
  final ConnectionSnapshot snapshot;
  final int deltaUp;
  final int deltaDown;
}

/// 内部：按维度聚合后的增量。
class _AggregatedDelta {
  const _AggregatedDelta({
    required this.appIdentifier,
    required this.nodeName,
    required this.domain,
    required this.rule,
    required this.deltaUp,
    required this.deltaDown,
  });
  final String appIdentifier;
  final String nodeName;
  final String domain;
  final String rule;
  final int deltaUp;
  final int deltaDown;
}
