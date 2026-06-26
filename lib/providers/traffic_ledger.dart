import 'dart:async';

import 'package:fl_clash/core/controller.dart';
import 'package:fl_clash/database/database.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/traffic_ledger/billing_period_manager.dart';
import 'package:fl_clash/traffic_ledger/collection/collection_service.dart';
import 'package:fl_clash/traffic_ledger/collection/reconciler.dart';
import 'package:fl_clash/traffic_ledger/collection/sample_source.dart';
import 'package:fl_clash/traffic_ledger/collection/traffic_diagnostics.dart';
import 'package:fl_clash/traffic_ledger/node_multiplier_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'generated/traffic_ledger.g.dart';

/// 节点倍率服务。单例，包装 [TrafficLedgerDao] 的倍率读写。
@Riverpod(keepAlive: true)
NodeMultiplierService nodeMultiplierService(Ref ref) {
  return NodeMultiplierService(database.trafficLedgerDao);
}

/// 计费周期管理器。单例，包装 [TrafficLedgerDao] 的周期逻辑。
@Riverpod(keepAlive: true)
BillingPeriodManager billingPeriodManager(Ref ref) {
  return BillingPeriodManager(database.trafficLedgerDao);
}

/// 采样数据源。单例，包装 [CoreController]。
@Riverpod(keepAlive: true)
TrafficSampleSource trafficSampleSource(Ref ref) {
  return CoreControllerSampleSource(coreController);
}

/// 缓存式倍率解析器。单例，包装 [NodeMultiplierService]。
@Riverpod(keepAlive: true)
CachedMultiplierResolver cachedMultiplierResolver(Ref ref) {
  return CachedMultiplierResolver(ref.read(nodeMultiplierServiceProvider));
}

/// Reconciler 单例。依赖 [CachedMultiplierResolver]。
@Riverpod(keepAlive: true)
Reconciler trafficReconciler(Ref ref) {
  return Reconciler(
    multiplierResolver: ref.read(cachedMultiplierResolverProvider),
  );
}

/// 后台流量采集服务。单例，生命周期由 [SetupAction]/[SystemAction] 管理：
/// - 核心启动/重启时调用 `start()`；
/// - 核心停止时调用 `pause()`；
/// - 应用退出前调用 `flushAndDispose()`。
///
/// 服务本身不监听核心状态，由调用方驱动生命周期。
@Riverpod(keepAlive: true)
TrafficCollectionService trafficCollectionService(Ref ref) {
  final service = TrafficCollectionService(
    sampleSource: ref.read(trafficSampleSourceProvider),
    multiplierResolver: ref.read(cachedMultiplierResolverProvider),
    periodManager: ref.read(billingPeriodManagerProvider),
    reconciler: ref.read(trafficReconcilerProvider),
  );
  ref.onDispose(service.flushAndDispose);
  return service;
}

/// 流量账本页面数据快照（Stage 4A）。
///
/// 聚合当前活动周期的总览 + 应用列表 + 未归因项。
/// 通过定时器每 5 秒刷新一次（避免高频 rebuild 影响 1 秒采样），
/// 也可通过 [TrafficLedgerRefreshNotifier] 手动触发刷新。
class TrafficLedgerSnapshot {
  const TrafficLedgerSnapshot({
    required this.period,
    required this.overview,
    required this.unattributed,
    required this.apps,
  });

  final BillingPeriod? period;
  final PeriodOverview overview;
  final PeriodOverview unattributed;
  final List<AppAggregation> apps;

  bool get hasData => period != null && !overview.isEmpty;
  bool get hasUnattributed => unattributed.totalBytes > 0;
}

/// 流量账本页面数据 provider（Stage 4A）。
///
/// 每 5 秒自动刷新一次；手动调用 [TrafficLedgerRefreshNotifier.refresh]
/// 可立即触发刷新。刷新时重新查询 DAO 聚合方法。
@riverpod
class TrafficLedgerSnapshotNotifier extends _$TrafficLedgerSnapshotNotifier {
  Timer? _timer;

  @override
  Future<TrafficLedgerSnapshot> build() async {
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      refresh();
    });
    ref.onDispose(() => _timer?.cancel());
    return _fetch();
  }

  Future<TrafficLedgerSnapshot> _fetch() async {
    final dao = database.trafficLedgerDao;
    final period = await dao.getActivePeriod();
    if (period == null) {
      return const TrafficLedgerSnapshot(
        period: null,
        overview: PeriodOverview(
          bytesUp: 0,
          bytesDown: 0,
          estimatedBilledBytesUp: 0,
          estimatedBilledBytesDown: 0,
          unbilledBytesUp: 0,
          unbilledBytesDown: 0,
        ),
        unattributed: PeriodOverview(
          bytesUp: 0,
          bytesDown: 0,
          estimatedBilledBytesUp: 0,
          estimatedBilledBytesDown: 0,
          unbilledBytesUp: 0,
          unbilledBytesDown: 0,
        ),
        apps: [],
      );
    }
    final overview = await dao.queryPeriodOverview(periodId: period.id);
    final unattributed =
        await dao.queryUnattributedOverview(periodId: period.id);
    final apps = await dao.queryAppAggregations(periodId: period.id);
    return TrafficLedgerSnapshot(
      period: period.toModel(),
      overview: overview,
      unattributed: unattributed,
      apps: apps,
    );
  }

  /// 手动触发刷新（例如新建周期后）。
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }
}

/// 采集服务运行状态（Stage 4A）。
///
/// 用于页面顶部"正在采集 / 已暂停 / 核心未运行"状态显示。
/// 每 2 秒刷新一次（比 snapshot 更轻量，仅读取 service.isRunning）。
@riverpod
class CollectionStatusNotifier extends _$CollectionStatusNotifier {
  Timer? _timer;

  @override
  Future<bool> build() async {
    _timer = Timer.periodic(const Duration(seconds: 2), (_) {
      state = AsyncData(ref.read(trafficCollectionServiceProvider).isRunning);
    });
    ref.onDispose(() => _timer?.cancel());
    return ref.read(trafficCollectionServiceProvider).isRunning;
  }
}

/// 诊断汇总字符串（仅 debug）。release 构建中返回空字符串。
@riverpod
String trafficDiagnosticsSummary(Ref ref) {
  return TrafficDiagnostics.instance.summarize();
}
