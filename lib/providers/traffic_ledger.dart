import 'package:fl_clash/core/controller.dart';
import 'package:fl_clash/database/database.dart';
import 'package:fl_clash/traffic_ledger/billing_period_manager.dart';
import 'package:fl_clash/traffic_ledger/collection/collection_service.dart';
import 'package:fl_clash/traffic_ledger/collection/reconciler.dart';
import 'package:fl_clash/traffic_ledger/collection/sample_source.dart';
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
