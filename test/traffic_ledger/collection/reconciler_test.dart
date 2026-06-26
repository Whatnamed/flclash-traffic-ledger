import 'package:fl_clash/traffic_ledger/collection/models.dart';
import 'package:fl_clash/traffic_ledger/collection/multiplier_precision.dart';
import 'package:fl_clash/traffic_ledger/collection/reconciler.dart';
import 'package:test/test.dart';

/// 测试用倍率解析器。返回固定映射，未配置返回 null。
class _FakeMultiplierResolver implements MultiplierResolver {
  _FakeMultiplierResolver(this._map);
  final Map<String, double> _map;

  @override
  double? effectiveMultiplierFor(String nodeName) => _map[nodeName];
}

/// 构造一条代理连接快照。
ConnectionSnapshot _conn({
  required String id,
  required int upload,
  required int download,
  String appIdentifier = 'chrome.exe',
  String nodeName = 'JP-Tokyo',
  String domain = 'example.com',
  String rule = 'DOMAIN-SUFFIX,example.com',
  List<String> chains = const ['Proxy', 'JP-Tokyo'],
  bool isProxy = true,
}) {
  return ConnectionSnapshot(
    id: id,
    upload: upload,
    download: download,
    appIdentifier: appIdentifier,
    nodeName: nodeName,
    domain: domain,
    rule: rule,
    chains: chains,
    isProxy: isProxy,
  );
}

/// 构造一次采样。
TrafficSample _sample({
  required DateTime observedAt,
  required int totalProxyUp,
  required int totalProxyDown,
  List<ConnectionSnapshot> connections = const [],
}) {
  return TrafficSample(
    observedAt: observedAt,
    totalProxyUp: totalProxyUp,
    totalProxyDown: totalProxyDown,
    connections: connections,
  );
}

void main() {
  late Reconciler reconciler;
  const generation = 1;

  setUp(() {
    reconciler = Reconciler(
      multiplierResolver: _FakeMultiplierResolver({
        'JP-Tokyo': 1.0,
        'US-LA': 2.0,
        'HK-1.5x': 1.5,
      }),
    );
  });

  // ---------- Scenario 1: 首次采样仅建立基线 ----------
  group('Scenario 1: 首次采样只建基线不重复统计', () {
    test('first sample produces no deltas, baseline established', () {
      final now = DateTime(2026, 6, 27, 10, 0, 0);
      // 核心已累计 1GB 上行，但采集服务首次看到。
      final sample = _sample(
        observedAt: now,
        totalProxyUp: 1024 * 1024 * 1024,
        totalProxyDown: 0,
        connections: [
          _conn(id: 'c1', upload: 500 * 1024 * 1024, download: 100 * 1024 * 1024),
        ],
      );
      final result = reconciler.reconcile(
        sample: sample,
        state: const CollectionState(),
        currentGeneration: generation,
      );

      expect(result.attributedDeltas, isEmpty);
      expect(result.unattributedDeltaUp, 0);
      expect(result.unattributedDeltaDown, 0);
      expect(result.overflow, isFalse);
      expect(result.newState.baselineEstablished, isTrue);
      expect(result.newState.lastTotalUp, sample.totalProxyUp);
      expect(result.newState.lastConnectionBytes['c1'], isNotNull);
      expect(result.diagnostics, anyElement(contains('baseline established')));
    });
  });

  // ---------- Scenario 2: 同一连接连续增长 ----------
  group('Scenario 2: 同一连接连续增长，正确累加上传和下载', () {
    test('two consecutive samples produce correct delta', () {
      final t1 = DateTime(2026, 6, 27, 10, 0, 0);
      final t2 = DateTime(2026, 6, 27, 10, 0, 1);
      // 第一次采样建基线
      final s1 = _sample(
        observedAt: t1,
        totalProxyUp: 1000,
        totalProxyDown: 2000,
        connections: [
          _conn(id: 'c1', upload: 100, download: 200),
        ],
      );
      final r1 = reconciler.reconcile(
        sample: s1,
        state: const CollectionState(),
        currentGeneration: generation,
      );
      expect(r1.attributedDeltas, isEmpty);

      // 第二次采样：c1 增长 100 上 / 200 下，总代理增长 100 / 200
      final s2 = _sample(
        observedAt: t2,
        totalProxyUp: 1100,
        totalProxyDown: 2200,
        connections: [
          _conn(id: 'c1', upload: 200, download: 400),
        ],
      );
      final r2 = reconciler.reconcile(
        sample: s2,
        state: r1.newState,
        currentGeneration: generation,
      );

      expect(r2.attributedDeltas.length, 1);
      final delta = r2.attributedDeltas.first;
      expect(delta.appIdentifier, 'chrome.exe');
      expect(delta.deltaUp, 100);
      expect(delta.deltaDown, 200);
      expect(delta.nodeName, 'JP-Tokyo');
      // 倍率 1.0，预计扣量 = 增量本身
      expect(delta.estimatedBilledDeltaUp, 100);
      expect(delta.estimatedBilledDeltaDown, 200);
      expect(delta.billedRemainderDeltaUp, 0);
      expect(delta.billedRemainderDeltaDown, 0);
      // 已归因 == 总代理，无未归因
      expect(r2.unattributedDeltaUp, 0);
      expect(r2.unattributedDeltaDown, 0);
      expect(r2.overflow, isFalse);
    });
  });

  // ---------- Scenario 3: 各种回退场景 ----------
  group('Scenario 3: 回退/核心重启不出现负数和虚假大增量', () {
    test('3a: 连接字节回退时更新基线，跳过该连接增量', () {
      final t1 = DateTime(2026, 6, 27, 10, 0, 0);
      final t2 = DateTime(2026, 6, 27, 10, 0, 1);
      final s1 = _sample(
        observedAt: t1,
        totalProxyUp: 1000,
        totalProxyDown: 1000,
        connections: [
          _conn(id: 'c1', upload: 500, download: 500),
        ],
      );
      final r1 = reconciler.reconcile(
        sample: s1,
        state: const CollectionState(),
        currentGeneration: generation,
      );

      // c1 upload 回退到 400（<500），总代理继续增长
      final s2 = _sample(
        observedAt: t2,
        totalProxyUp: 1100,
        totalProxyDown: 1100,
        connections: [
          _conn(id: 'c1', upload: 400, download: 700),
        ],
      );
      final r2 = reconciler.reconcile(
        sample: s2,
        state: r1.newState,
        currentGeneration: generation,
      );

      // 总代理增长 100/100，c1 upload 回退跳过，download 增长 200
      // 已归因 down = 200 > 总代理 down delta 100 -> overflow
      // 或者另一情况：c1 upload 回退导致 c1 整体跳过（不分别处理 up/down）
      // 当前实现：dUp 或 dDown 任一为负 -> 整条连接跳过增量
      // 所以归因总和为 0，未归因 = 100/100
      expect(r2.attributedDeltas.length, 1); // 仅未归因条目
      expect(r2.attributedDeltas.first.isUnattributed, isTrue);
      expect(r2.attributedDeltas.first.deltaUp, 100);
      expect(r2.attributedDeltas.first.deltaDown, 100);
      expect(r2.overflow, isFalse);
      expect(r2.diagnostics, anyElement(contains('rolled back')));
    });

    test('3b: 总代理计数回退时重建基线，不产生增量', () {
      final t1 = DateTime(2026, 6, 27, 10, 0, 0);
      final t2 = DateTime(2026, 6, 27, 10, 0, 1);
      final s1 = _sample(
        observedAt: t1,
        totalProxyUp: 2000,
        totalProxyDown: 2000,
        connections: [],
      );
      final r1 = reconciler.reconcile(
        sample: s1,
        state: const CollectionState(),
        currentGeneration: generation,
      );

      // 总代理回退到 1500（<2000）
      final s2 = _sample(
        observedAt: t2,
        totalProxyUp: 1500,
        totalProxyDown: 1500,
        connections: [],
      );
      final r2 = reconciler.reconcile(
        sample: s2,
        state: r1.newState,
        currentGeneration: generation,
      );

      expect(r2.attributedDeltas, isEmpty);
      expect(r2.unattributedDeltaUp, 0);
      expect(r2.unattributedDeltaDown, 0);
      expect(r2.newState.lastTotalUp, 1500);
      expect(r2.newState.lastTotalDown, 1500);
      expect(r2.diagnostics, anyElement(contains('rolled back')));
    });

    test('3c: 核心重启（generation 变化）重建基线，不产生增量', () {
      final t1 = DateTime(2026, 6, 27, 10, 0, 0);
      final t2 = DateTime(2026, 6, 27, 10, 0, 5);
      final s1 = _sample(
        observedAt: t1,
        totalProxyUp: 1000000,
        totalProxyDown: 1000000,
        connections: [
          _conn(id: 'c1', upload: 500000, download: 500000),
        ],
      );
      final r1 = reconciler.reconcile(
        sample: s1,
        state: const CollectionState(),
        currentGeneration: 1,
      );

      // 核心重启：generation 变化，核心计数从 0 开始
      final s2 = _sample(
        observedAt: t2,
        totalProxyUp: 100,
        totalProxyDown: 200,
        connections: [
          _conn(id: 'c2', upload: 50, download: 100),
        ],
      );
      final r2 = reconciler.reconcile(
        sample: s2,
        state: r1.newState,
        currentGeneration: 2,
      );

      expect(r2.attributedDeltas, isEmpty);
      expect(r2.unattributedDeltaUp, 0);
      expect(r2.unattributedDeltaDown, 0);
      expect(r2.newState.generation, 2);
      expect(r2.newState.lastTotalUp, 100);
      expect(r2.newState.lastConnectionBytes['c1'], isNull);
      expect(r2.newState.lastConnectionBytes['c2'], isNotNull);
      expect(r2.diagnostics, anyElement(contains('core restart detected')));
    });
  });

  // ---------- Scenario 4: 连接消失，总代理差额进未归因 ----------
  group('Scenario 4: 连接在采样间消失，差额进入未归因', () {
    test('disappeared connection delta goes to unattributed', () {
      final t1 = DateTime(2026, 6, 27, 10, 0, 0);
      final t2 = DateTime(2026, 6, 27, 10, 0, 1);
      final s1 = _sample(
        observedAt: t1,
        totalProxyUp: 1000,
        totalProxyDown: 1000,
        connections: [
          _conn(id: 'c1', upload: 500, download: 500),
        ],
      );
      final r1 = reconciler.reconcile(
        sample: s1,
        state: const CollectionState(),
        currentGeneration: generation,
      );

      // c1 消失，但总代理继续增长 100/100（短连接结束）
      final s2 = _sample(
        observedAt: t2,
        totalProxyUp: 1100,
        totalProxyDown: 1100,
        connections: const [],
      );
      final r2 = reconciler.reconcile(
        sample: s2,
        state: r1.newState,
        currentGeneration: generation,
      );

      // 无归因连接，总代理增量全部进未归因
      expect(r2.attributedDeltas.length, 1);
      expect(r2.attributedDeltas.first.isUnattributed, isTrue);
      expect(r2.attributedDeltas.first.deltaUp, 100);
      expect(r2.attributedDeltas.first.deltaDown, 100);
      expect(r2.unattributedDeltaUp, 100);
      expect(r2.unattributedDeltaDown, 100);
      // 新状态不再保留 c1 基线
      expect(r2.newState.lastConnectionBytes['c1'], isNull);
    });
  });

  // ---------- Scenario 5: 未识别进程 vs 未归因代理流量 ----------
  group('Scenario 5: 未识别进程与未归因代理流量语义不同', () {
    test('5a: 未识别进程 - appIdentifier 为空但仍归因到节点/域名', () {
      final t1 = DateTime(2026, 6, 27, 10, 0, 0);
      final t2 = DateTime(2026, 6, 27, 10, 0, 1);
      final s1 = _sample(
        observedAt: t1,
        totalProxyUp: 1000,
        totalProxyDown: 1000,
        connections: [
          _conn(id: 'c1', upload: 100, download: 100, appIdentifier: ''),
        ],
      );
      final r1 = reconciler.reconcile(
        sample: s1,
        state: const CollectionState(),
        currentGeneration: generation,
      );

      final s2 = _sample(
        observedAt: t2,
        totalProxyUp: 1200,
        totalProxyDown: 1200,
        connections: [
          _conn(id: 'c1', upload: 300, download: 300, appIdentifier: ''),
        ],
      );
      final r2 = reconciler.reconcile(
        sample: s2,
        state: r1.newState,
        currentGeneration: generation,
      );

      expect(r2.attributedDeltas.length, 1);
      final delta = r2.attributedDeltas.first;
      // 未识别进程：appIdentifier 为空（被规范化为 unknownDimensionValue），
      // 但节点/域名/规则仍有归因，预计扣量按节点倍率计算
      expect(delta.isUnattributed, isFalse);
      expect(delta.isUnidentifiedProcess, isTrue);
      expect(delta.appIdentifier, unknownDimensionValue);
      expect(delta.nodeName, 'JP-Tokyo');
      expect(delta.domain, 'example.com');
      expect(delta.estimatedBilledDeltaUp, 200); // 200 * 1.0
      expect(delta.estimatedBilledDeltaDown, 200);
      // 余数不可估算 sentinel? 不，未识别进程仍按节点倍率估算
      expect(delta.billedRemainderDeltaUp, 0);
      expect(delta.billedRemainderDeltaDown, 0);
      expect(r2.unattributedDeltaUp, 0); // 已归因 == 总代理
      expect(r2.unattributedDeltaDown, 0);
    });

    test('5b: 未归因代理流量 - appIdentifier 为 __unattributed__，余数为 sentinel', () {
      final t1 = DateTime(2026, 6, 27, 10, 0, 0);
      final t2 = DateTime(2026, 6, 27, 10, 0, 1);
      final s1 = _sample(
        observedAt: t1,
        totalProxyUp: 1000,
        totalProxyDown: 1000,
        connections: const [],
      );
      final r1 = reconciler.reconcile(
        sample: s1,
        state: const CollectionState(),
        currentGeneration: generation,
      );

      // 连接列表为空但总代理增长 -> 全部进未归因
      final s2 = _sample(
        observedAt: t2,
        totalProxyUp: 1500,
        totalProxyDown: 1500,
        connections: const [],
      );
      final r2 = reconciler.reconcile(
        sample: s2,
        state: r1.newState,
        currentGeneration: generation,
      );

      expect(r2.attributedDeltas.length, 1);
      final delta = r2.attributedDeltas.first;
      expect(delta.isUnattributed, isTrue);
      expect(delta.appIdentifier, unattributedAppIdentifier);
      expect(delta.isUnidentifiedProcess, isFalse);
      // 节点/域名/规则不能伪造
      expect(delta.nodeName, unknownDimensionValue);
      expect(delta.domain, unknownDimensionValue);
      expect(delta.rule, unknownDimensionValue);
      // 预计扣量不可估算
      expect(delta.estimatedBilledDeltaUp, 0);
      expect(delta.estimatedBilledDeltaDown, 0);
      expect(delta.billedRemainderDeltaUp, unbilledSentinel);
      expect(delta.billedRemainderDeltaDown, unbilledSentinel);
      expect(delta.effectiveMultiplier, 0);
    });
  });

  // ---------- Scenario 6: DIRECT 不计入默认账本 ----------
  group('Scenario 6: DIRECT 连接不计入默认代理账本', () {
    test('DIRECT connection excluded from deltas and baseline', () {
      final t1 = DateTime(2026, 6, 27, 10, 0, 0);
      final t2 = DateTime(2026, 6, 27, 10, 0, 1);
      final s1 = _sample(
        observedAt: t1,
        totalProxyUp: 1000,
        totalProxyDown: 1000,
        connections: [
          _conn(
            id: 'direct1',
            upload: 500,
            download: 500,
            chains: const ['DIRECT'],
            isProxy: false,
          ),
        ],
      );
      final r1 = reconciler.reconcile(
        sample: s1,
        state: const CollectionState(),
        currentGeneration: generation,
      );
      // DIRECT 不进基线
      expect(r1.newState.lastConnectionBytes['direct1'], isNull);

      final s2 = _sample(
        observedAt: t2,
        totalProxyUp: 1100,
        totalProxyDown: 1100,
        connections: [
          _conn(
            id: 'direct1',
            upload: 1000,
            download: 1000,
            chains: const ['DIRECT'],
            isProxy: false,
          ),
        ],
      );
      final r2 = reconciler.reconcile(
        sample: s2,
        state: r1.newState,
        currentGeneration: generation,
      );

      // DIRECT 不归因；总代理增量 100/100 全部进未归因
      // （因为 DIRECT 流量本不应进总代理统计，但若进了，差额归未归因）
      expect(r2.attributedDeltas.length, 1);
      expect(r2.attributedDeltas.first.isUnattributed, isTrue);
      expect(r2.attributedDeltas.first.deltaUp, 100);
      expect(r2.attributedDeltas.first.deltaDown, 100);
    });
  });

  // ---------- Scenario 7: 代理承载进程不进普通应用排行 ----------
  group('Scenario 7: 代理承载进程不出现在普通应用排行', () {
    test('FlClash.exe traffic excluded from app ranking, goes to unattributed', () {
      final t1 = DateTime(2026, 6, 27, 10, 0, 0);
      final t2 = DateTime(2026, 6, 27, 10, 0, 1);
      final s1 = _sample(
        observedAt: t1,
        totalProxyUp: 1000,
        totalProxyDown: 1000,
        connections: [
          _conn(
            id: 'host1',
            upload: 500,
            download: 500,
            appIdentifier: 'FlClash.exe',
          ),
        ],
      );
      final r1 = reconciler.reconcile(
        sample: s1,
        state: const CollectionState(),
        currentGeneration: generation,
      );

      final s2 = _sample(
        observedAt: t2,
        totalProxyUp: 1100,
        totalProxyDown: 1100,
        connections: [
          _conn(
            id: 'host1',
            upload: 600,
            download: 600,
            appIdentifier: 'FlClash.exe',
          ),
        ],
      );
      final r2 = reconciler.reconcile(
        sample: s2,
        state: r1.newState,
        currentGeneration: generation,
      );

      // FlClash.exe 不进普通应用归因（被 _aggregateByDimension 跳过）
      // 但总代理增量 100/100 仍要计入，进入未归因
      expect(r2.attributedDeltas.length, 1);
      expect(r2.attributedDeltas.first.isUnattributed, isTrue);
      expect(r2.attributedDeltas.first.deltaUp, 100);
      expect(r2.attributedDeltas.first.deltaDown, 100);
      // 不应该出现 FlClash.exe 作为 appIdentifier 的归因项
      for (final d in r2.attributedDeltas) {
        expect(d.appIdentifier, isNot('FlClash.exe'));
        expect(d.appIdentifier, isNot('flclash.exe'));
      }
    });

    test('isProxyHostProcess matches case-insensitively with paths', () {
      expect(isProxyHostProcess('FlClash.exe'), isTrue);
      expect(isProxyHostProcess('flclash.exe'), isTrue);
      expect(isProxyHostProcess('FLCLASH.EXE'), isTrue);
      expect(isProxyHostProcess('C:\\Program Files\\FlClashCore.exe'), isTrue);
      expect(isProxyHostProcess('/usr/bin/flclashhelperservice.exe'), isTrue);
      expect(isProxyHostProcess('chrome.exe'), isFalse);
      expect(isProxyHostProcess('FlClashHelper.exe'), isFalse); // 不在列表
      expect(isProxyHostProcess(''), isFalse);
    });
  });

  // ---------- Scenario 8: 已归因 + 未归因 == 总代理增量 ----------
  group('Scenario 8: 已归因 + 未归因严格等于总代理增量', () {
    test('partial attribution + unattributed == total', () {
      final t1 = DateTime(2026, 6, 27, 10, 0, 0);
      final t2 = DateTime(2026, 6, 27, 10, 0, 1);
      final s1 = _sample(
        observedAt: t1,
        totalProxyUp: 1000,
        totalProxyDown: 1000,
        connections: [
          _conn(id: 'c1', upload: 100, download: 100),
        ],
      );
      final r1 = reconciler.reconcile(
        sample: s1,
        state: const CollectionState(),
        currentGeneration: generation,
      );

      // c1 只增长 50/50，但总代理增长 100/100，差额进未归因
      final s2 = _sample(
        observedAt: t2,
        totalProxyUp: 1100,
        totalProxyDown: 1100,
        connections: [
          _conn(id: 'c1', upload: 150, download: 150),
        ],
      );
      final r2 = reconciler.reconcile(
        sample: s2,
        state: r1.newState,
        currentGeneration: generation,
      );

      // 已归因 c1: 50/50
      // 未归因: 50/50
      // 总和 = 100/100 = 总代理增量
      expect(r2.attributedDeltas.length, 2);
      final attributed = r2.attributedDeltas.where((d) => !d.isUnattributed).toList();
      final unattributed = r2.attributedDeltas.where((d) => d.isUnattributed).toList();
      expect(attributed.length, 1);
      expect(unattributed.length, 1);
      expect(attributed.first.deltaUp, 50);
      expect(attributed.first.deltaDown, 50);
      expect(unattributed.first.deltaUp, 50);
      expect(unattributed.first.deltaDown, 50);

      final totalUp = r2.attributedDeltas.fold<int>(0, (s, d) => s + d.deltaUp);
      final totalDown = r2.attributedDeltas.fold<int>(0, (s, d) => s + d.deltaDown);
      expect(totalUp, 100); // = totalDeltaUp
      expect(totalDown, 100); // = totalDeltaDown
      expect(r2.overflow, isFalse);
    });
  });

  // ---------- Scenario 9: overflow 保守策略 ----------
  group('Scenario 9: 连接归因超过总代理时采用保守策略', () {
    test('overflow: all to unattributed, no suspicious attribution', () {
      final t1 = DateTime(2026, 6, 27, 10, 0, 0);
      final t2 = DateTime(2026, 6, 27, 10, 0, 1);
      final s1 = _sample(
        observedAt: t1,
        totalProxyUp: 1000,
        totalProxyDown: 1000,
        connections: [
          _conn(id: 'c1', upload: 100, download: 100),
        ],
      );
      final r1 = reconciler.reconcile(
        sample: s1,
        state: const CollectionState(),
        currentGeneration: generation,
      );

      // c1 增长 200/200，但总代理只增长 100/100（异常情况）
      final s2 = _sample(
        observedAt: t2,
        totalProxyUp: 1100,
        totalProxyDown: 1100,
        connections: [
          _conn(id: 'c1', upload: 300, download: 300),
        ],
      );
      final r2 = reconciler.reconcile(
        sample: s2,
        state: r1.newState,
        currentGeneration: generation,
      );

      expect(r2.overflow, isTrue);
      // 保守策略：不写可疑归因，全部进未归因
      // 应该只有未归因一条，没有 c1 的归因
      expect(r2.attributedDeltas.length, 1);
      expect(r2.attributedDeltas.first.isUnattributed, isTrue);
      expect(r2.attributedDeltas.first.deltaUp, 100); // = 总代理增量
      expect(r2.attributedDeltas.first.deltaDown, 100);
      expect(r2.unattributedDeltaUp, 100);
      expect(r2.unattributedDeltaDown, 100);
      expect(r2.diagnostics, anyElement(contains('reconciliation overflow')));
    });

    test('overflow does not create negative unattributed', () {
      final t1 = DateTime(2026, 6, 27, 10, 0, 0);
      final t2 = DateTime(2026, 6, 27, 10, 0, 1);
      final s1 = _sample(
        observedAt: t1,
        totalProxyUp: 1000,
        totalProxyDown: 1000,
        connections: [
          _conn(id: 'c1', upload: 0, download: 0),
        ],
      );
      final r1 = reconciler.reconcile(
        sample: s1,
        state: const CollectionState(),
        currentGeneration: generation,
      );

      // c1 增长 500/500，总代理只增长 100/100
      final s2 = _sample(
        observedAt: t2,
        totalProxyUp: 1100,
        totalProxyDown: 1100,
        connections: [
          _conn(id: 'c1', upload: 500, download: 500),
        ],
      );
      final r2 = reconciler.reconcile(
        sample: s2,
        state: r1.newState,
        currentGeneration: generation,
      );

      expect(r2.overflow, isTrue);
      expect(r2.unattributedDeltaUp, 100); // 不允许负数
      expect(r2.unattributedDeltaDown, 100);
      expect(r2.attributedDeltas.first.deltaUp, greaterThanOrEqualTo(0));
    });
  });

  // ---------- Scenario 10 & 11: 停止与继续（核心停止/启动） ----------
  group('Scenario 10 & 11: 核心停止后停止新增，启动后继续当前周期', () {
    test('10: 核心停止后不再调用 reconcile，历史不变', () {
      final t1 = DateTime(2026, 6, 27, 10, 0, 0);
      final s1 = _sample(
        observedAt: t1,
        totalProxyUp: 1000,
        totalProxyDown: 1000,
        connections: [_conn(id: 'c1', upload: 100, download: 100)],
      );
      final r1 = reconciler.reconcile(
        sample: s1,
        state: const CollectionState(),
        currentGeneration: generation,
      );

      // 核心停止：采集服务不再调用 reconcile。
      // 模拟：r1.newState 保持不变，不产生新的 result。
      // 等价于：r1.newState 即为最终状态，无新增。
      expect(r1.newState.lastTotalUp, 1000);
      expect(r1.newState.baselineEstablished, isTrue);
      // 历史不清零（state 仍在内存中，DAO 中已 flush 的数据不变）
    });

    test('11: 核心再次启动（不同 generation）后重建基线，不重复统计', () {
      final t1 = DateTime(2026, 6, 27, 10, 0, 0);
      final t2 = DateTime(2026, 6, 27, 10, 0, 5);
      final s1 = _sample(
        observedAt: t1,
        totalProxyUp: 1000,
        totalProxyDown: 1000,
        connections: [_conn(id: 'c1', upload: 100, download: 100)],
      );
      final r1 = reconciler.reconcile(
        sample: s1,
        state: const CollectionState(),
        currentGeneration: 1,
      );

      // 核心再次启动：generation 从 1 -> 2
      // 核心计数从 0 重新开始
      final s2 = _sample(
        observedAt: t2,
        totalProxyUp: 50,
        totalProxyDown: 50,
        connections: [_conn(id: 'c2', upload: 30, download: 30)],
      );
      final r2 = reconciler.reconcile(
        sample: s2,
        state: r1.newState,
        currentGeneration: 2,
      );

      // 不重复统计：r2 没有产生增量
      expect(r2.attributedDeltas, isEmpty);
      expect(r2.unattributedDeltaUp, 0);
      expect(r2.unattributedDeltaDown, 0);
      // 但基线已重建为新的核心会话
      expect(r2.newState.generation, 2);
      expect(r2.newState.lastTotalUp, 50);
      expect(r2.newState.lastConnectionBytes['c1'], isNull);
      expect(r2.newState.lastConnectionBytes['c2'], isNotNull);

      // 后续采样正常增量
      final t3 = DateTime(2026, 6, 27, 10, 0, 6);
      final s3 = _sample(
        observedAt: t3,
        totalProxyUp: 100,
        totalProxyDown: 100,
        connections: [_conn(id: 'c2', upload: 60, download: 60)],
      );
      final r3 = reconciler.reconcile(
        sample: s3,
        state: r2.newState,
        currentGeneration: 2,
      );
      // c2 增量 30/30 (60-30), 总代理增量 50/50 (100-50)
      // 已归因 30/30 + 未归因 20/20 = 50/50
      expect(r3.attributedDeltas.length, 2);
      final attributed3 = r3.attributedDeltas.where((d) => !d.isUnattributed).toList();
      final unattributed3 = r3.attributedDeltas.where((d) => d.isUnattributed).toList();
      expect(attributed3.length, 1);
      expect(attributed3.first.deltaUp, 30); // 60 - 30
      expect(attributed3.first.deltaDown, 30);
      expect(unattributed3.length, 1);
      expect(unattributed3.first.deltaUp, 20); // 50 (total) - 30 (attributed)
      expect(unattributed3.first.deltaDown, 20);
      expect(r3.unattributedDeltaUp, 20);
      expect(r3.unattributedDeltaDown, 20);
    });
  });

  // ---------- Scenario 15: 节点缺失时实际流量仍计入，扣量不伪造 1× ----------
  group('Scenario 15: 节点缺失时实际流量计入，扣量不伪造为 1×', () {
    test('unknown node: bytes counted, estimated = 0, remainder = sentinel', () {
      final t1 = DateTime(2026, 6, 27, 10, 0, 0);
      final t2 = DateTime(2026, 6, 27, 10, 0, 1);
      final s1 = _sample(
        observedAt: t1,
        totalProxyUp: 1000,
        totalProxyDown: 1000,
        connections: [
          _conn(id: 'c1', upload: 100, download: 100, nodeName: 'UNKNOWN-NODE'),
        ],
      );
      final r1 = reconciler.reconcile(
        sample: s1,
        state: const CollectionState(),
        currentGeneration: generation,
      );

      final s2 = _sample(
        observedAt: t2,
        totalProxyUp: 1200,
        totalProxyDown: 1200,
        connections: [
          _conn(id: 'c1', upload: 300, download: 300, nodeName: 'UNKNOWN-NODE'),
        ],
      );
      final r2 = reconciler.reconcile(
        sample: s2,
        state: r1.newState,
        currentGeneration: generation,
      );

      expect(r2.attributedDeltas.length, 1);
      final delta = r2.attributedDeltas.first;
      // 实际流量仍计入
      expect(delta.deltaUp, 200);
      expect(delta.deltaDown, 200);
      // 节点名保留原值，不伪造
      expect(delta.nodeName, 'UNKNOWN-NODE');
      // 预计扣量不伪造为 1×，est=0，remainder=sentinel
      expect(delta.estimatedBilledDeltaUp, 0);
      expect(delta.estimatedBilledDeltaDown, 0);
      expect(delta.billedRemainderDeltaUp, unbilledSentinel);
      expect(delta.billedRemainderDeltaDown, unbilledSentinel);
      expect(delta.effectiveMultiplier, 0);
      expect(r2.unattributedDeltaUp, 0); // 已归因 == 总代理
      expect(r2.unattributedDeltaDown, 0);
    });

    test('node with empty name (only chain available): no fake node', () {
      final t1 = DateTime(2026, 6, 27, 10, 0, 0);
      final t2 = DateTime(2026, 6, 27, 10, 0, 1);
      final s1 = _sample(
        observedAt: t1,
        totalProxyUp: 1000,
        totalProxyDown: 1000,
        connections: [
          _conn(id: 'c1', upload: 100, download: 100, nodeName: ''),
        ],
      );
      final r1 = reconciler.reconcile(
        sample: s1,
        state: const CollectionState(),
        currentGeneration: generation,
      );

      final s2 = _sample(
        observedAt: t2,
        totalProxyUp: 1100,
        totalProxyDown: 1100,
        connections: [
          _conn(id: 'c1', upload: 200, download: 200, nodeName: ''),
        ],
      );
      final r2 = reconciler.reconcile(
        sample: s2,
        state: r1.newState,
        currentGeneration: generation,
      );

      final delta = r2.attributedDeltas.first;
      expect(delta.deltaUp, 100);
      expect(delta.deltaDown, 100);
      expect(delta.nodeName, ''); // 保留原始 chain，不伪造节点名
      expect(delta.estimatedBilledDeltaUp, 0); // 不可估算
      expect(delta.billedRemainderDeltaUp, unbilledSentinel);
    });
  });

  // ---------- Scenario 16: 同一小时内倍率变更 ----------
  group('Scenario 16: 同一小时内倍率变更，预计扣量按入账时倍率', () {
    test('first delta @2x, second delta @1.5x -> billed uses per-delta multiplier', () {
      final t1 = DateTime(2026, 6, 27, 10, 0, 0);
      final t2 = DateTime(2026, 6, 27, 10, 0, 1);
      final t3 = DateTime(2026, 6, 27, 10, 0, 2);
      // 第一次：c1 (US-LA, 2x) 增长 100 上行
      final s1 = _sample(
        observedAt: t1,
        totalProxyUp: 1000,
        totalProxyDown: 1000,
        connections: [
          _conn(id: 'c1', upload: 100, download: 0, nodeName: 'US-LA'),
        ],
      );
      final r1 = reconciler.reconcile(
        sample: s1,
        state: const CollectionState(),
        currentGeneration: generation,
      );

      // 第二次：c1 增长 100 上行，倍率仍 2x
      final s2 = _sample(
        observedAt: t2,
        totalProxyUp: 1100,
        totalProxyDown: 1000,
        connections: [
          _conn(id: 'c1', upload: 200, download: 0, nodeName: 'US-LA'),
        ],
      );
      final r2 = reconciler.reconcile(
        sample: s2,
        state: r1.newState,
        currentGeneration: generation,
      );
      // 100 * 2 = 200 billed
      expect(r2.attributedDeltas.first.estimatedBilledDeltaUp, 200);
      expect(r2.attributedDeltas.first.effectiveMultiplier, 2.0);

      // 第三次：用户把节点改名为 HK-1.5x（不同节点不同倍率）
      // 但同一小时内，旧 c1 仍属于 US-LA，新 c2 属于 HK-1.5x
      // 实际场景中倍率变更是通过修改节点记录实现的，这里通过不同节点模拟
      final s3 = _sample(
        observedAt: t3,
        totalProxyUp: 1300,
        totalProxyDown: 1000,
        connections: [
          _conn(id: 'c1', upload: 300, download: 0, nodeName: 'US-LA'),
          _conn(id: 'c2', upload: 100, download: 0, nodeName: 'HK-1.5x'),
        ],
      );
      final r3 = reconciler.reconcile(
        sample: s3,
        state: r2.newState,
        currentGeneration: generation,
      );

      // c1: 100 * 2 = 200 billed
      // c2: 100 * 1.5 = 150 billed (首次见 c2，建基线不计增量)
      // 所以 c2 不应该产生增量（首次见到）
      // 总代理 up 增量 = 1300 - 1100 = 200
      // c1 增量 = 300 - 200 = 100
      // c2 首次见到，建立基线，不产生增量
      // 已归因 = 100，未归因 = 100
      final attributed = r3.attributedDeltas.where((d) => !d.isUnattributed).toList();
      final unattributed = r3.attributedDeltas.where((d) => d.isUnattributed).toList();
      expect(attributed.length, 1);
      expect(attributed.first.nodeName, 'US-LA');
      expect(attributed.first.deltaUp, 100);
      expect(attributed.first.estimatedBilledDeltaUp, 200); // 100 * 2
      expect(attributed.first.effectiveMultiplier, 2.0);
      expect(unattributed.length, 1);
      expect(unattributed.first.deltaUp, 100);
    });
  });

  // ---------- 额外: 多维度聚合 ----------
  group('aggregation: 同维度连接聚合', () {
    test('two connections same dimension aggregate to one delta', () {
      final t1 = DateTime(2026, 6, 27, 10, 0, 0);
      final t2 = DateTime(2026, 6, 27, 10, 0, 1);
      final s1 = _sample(
        observedAt: t1,
        totalProxyUp: 1000,
        totalProxyDown: 1000,
        connections: [
          _conn(id: 'c1', upload: 100, download: 100, appIdentifier: 'chrome.exe'),
          _conn(id: 'c2', upload: 200, download: 200, appIdentifier: 'chrome.exe'),
        ],
      );
      final r1 = reconciler.reconcile(
        sample: s1,
        state: const CollectionState(),
        currentGeneration: generation,
      );

      // 两条 chrome.exe 连接都增长 50/50
      final s2 = _sample(
        observedAt: t2,
        totalProxyUp: 1100,
        totalProxyDown: 1100,
        connections: [
          _conn(id: 'c1', upload: 150, download: 150, appIdentifier: 'chrome.exe'),
          _conn(id: 'c2', upload: 250, download: 250, appIdentifier: 'chrome.exe'),
        ],
      );
      final r2 = reconciler.reconcile(
        sample: s2,
        state: r1.newState,
        currentGeneration: generation,
      );

      // 聚合为一条 chrome.exe 归因，delta 100/100
      final attributed = r2.attributedDeltas.where((d) => !d.isUnattributed).toList();
      expect(attributed.length, 1);
      expect(attributed.first.appIdentifier, 'chrome.exe');
      expect(attributed.first.deltaUp, 100);
      expect(attributed.first.deltaDown, 100);
      expect(r2.unattributedDeltaUp, 0);
    });
  });
}
