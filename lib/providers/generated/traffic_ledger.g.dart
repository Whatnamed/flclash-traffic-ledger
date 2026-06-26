// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../traffic_ledger.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 节点倍率服务。单例，包装 [TrafficLedgerDao] 的倍率读写。

@ProviderFor(nodeMultiplierService)
final nodeMultiplierServiceProvider = NodeMultiplierServiceProvider._();

/// 节点倍率服务。单例，包装 [TrafficLedgerDao] 的倍率读写。

final class NodeMultiplierServiceProvider
    extends
        $FunctionalProvider<
          NodeMultiplierService,
          NodeMultiplierService,
          NodeMultiplierService
        >
    with $Provider<NodeMultiplierService> {
  /// 节点倍率服务。单例，包装 [TrafficLedgerDao] 的倍率读写。
  NodeMultiplierServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'nodeMultiplierServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$nodeMultiplierServiceHash();

  @$internal
  @override
  $ProviderElement<NodeMultiplierService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  NodeMultiplierService create(Ref ref) {
    return nodeMultiplierService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NodeMultiplierService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NodeMultiplierService>(value),
    );
  }
}

String _$nodeMultiplierServiceHash() =>
    r'e82f63fdd6b5699a50e96b0c7506a60395abce60';

/// 计费周期管理器。单例，包装 [TrafficLedgerDao] 的周期逻辑。

@ProviderFor(billingPeriodManager)
final billingPeriodManagerProvider = BillingPeriodManagerProvider._();

/// 计费周期管理器。单例，包装 [TrafficLedgerDao] 的周期逻辑。

final class BillingPeriodManagerProvider
    extends
        $FunctionalProvider<
          BillingPeriodManager,
          BillingPeriodManager,
          BillingPeriodManager
        >
    with $Provider<BillingPeriodManager> {
  /// 计费周期管理器。单例，包装 [TrafficLedgerDao] 的周期逻辑。
  BillingPeriodManagerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'billingPeriodManagerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$billingPeriodManagerHash();

  @$internal
  @override
  $ProviderElement<BillingPeriodManager> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  BillingPeriodManager create(Ref ref) {
    return billingPeriodManager(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BillingPeriodManager value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BillingPeriodManager>(value),
    );
  }
}

String _$billingPeriodManagerHash() =>
    r'2aa2d765399f5d679018ea5d2447baecb021f359';

/// 采样数据源。单例，包装 [CoreController]。

@ProviderFor(trafficSampleSource)
final trafficSampleSourceProvider = TrafficSampleSourceProvider._();

/// 采样数据源。单例，包装 [CoreController]。

final class TrafficSampleSourceProvider
    extends
        $FunctionalProvider<
          TrafficSampleSource,
          TrafficSampleSource,
          TrafficSampleSource
        >
    with $Provider<TrafficSampleSource> {
  /// 采样数据源。单例，包装 [CoreController]。
  TrafficSampleSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'trafficSampleSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$trafficSampleSourceHash();

  @$internal
  @override
  $ProviderElement<TrafficSampleSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  TrafficSampleSource create(Ref ref) {
    return trafficSampleSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TrafficSampleSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TrafficSampleSource>(value),
    );
  }
}

String _$trafficSampleSourceHash() =>
    r'74d31306ae9916933d833f996a63061fd6da8923';

/// 缓存式倍率解析器。单例，包装 [NodeMultiplierService]。

@ProviderFor(cachedMultiplierResolver)
final cachedMultiplierResolverProvider = CachedMultiplierResolverProvider._();

/// 缓存式倍率解析器。单例，包装 [NodeMultiplierService]。

final class CachedMultiplierResolverProvider
    extends
        $FunctionalProvider<
          CachedMultiplierResolver,
          CachedMultiplierResolver,
          CachedMultiplierResolver
        >
    with $Provider<CachedMultiplierResolver> {
  /// 缓存式倍率解析器。单例，包装 [NodeMultiplierService]。
  CachedMultiplierResolverProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cachedMultiplierResolverProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cachedMultiplierResolverHash();

  @$internal
  @override
  $ProviderElement<CachedMultiplierResolver> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CachedMultiplierResolver create(Ref ref) {
    return cachedMultiplierResolver(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CachedMultiplierResolver value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CachedMultiplierResolver>(value),
    );
  }
}

String _$cachedMultiplierResolverHash() =>
    r'9322dda5ac564b13f0108730313814896577d298';

/// Reconciler 单例。依赖 [CachedMultiplierResolver]。

@ProviderFor(trafficReconciler)
final trafficReconcilerProvider = TrafficReconcilerProvider._();

/// Reconciler 单例。依赖 [CachedMultiplierResolver]。

final class TrafficReconcilerProvider
    extends $FunctionalProvider<Reconciler, Reconciler, Reconciler>
    with $Provider<Reconciler> {
  /// Reconciler 单例。依赖 [CachedMultiplierResolver]。
  TrafficReconcilerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'trafficReconcilerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$trafficReconcilerHash();

  @$internal
  @override
  $ProviderElement<Reconciler> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Reconciler create(Ref ref) {
    return trafficReconciler(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Reconciler value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Reconciler>(value),
    );
  }
}

String _$trafficReconcilerHash() => r'c2998def927eb6bad969f08dbce07101454b45b9';

/// 后台流量采集服务。单例，生命周期由 [SetupAction]/[SystemAction] 管理：
/// - 核心启动/重启时调用 `start()`；
/// - 核心停止时调用 `pause()`；
/// - 应用退出前调用 `flushAndDispose()`。
///
/// 服务本身不监听核心状态，由调用方驱动生命周期。

@ProviderFor(trafficCollectionService)
final trafficCollectionServiceProvider = TrafficCollectionServiceProvider._();

/// 后台流量采集服务。单例，生命周期由 [SetupAction]/[SystemAction] 管理：
/// - 核心启动/重启时调用 `start()`；
/// - 核心停止时调用 `pause()`；
/// - 应用退出前调用 `flushAndDispose()`。
///
/// 服务本身不监听核心状态，由调用方驱动生命周期。

final class TrafficCollectionServiceProvider
    extends
        $FunctionalProvider<
          TrafficCollectionService,
          TrafficCollectionService,
          TrafficCollectionService
        >
    with $Provider<TrafficCollectionService> {
  /// 后台流量采集服务。单例，生命周期由 [SetupAction]/[SystemAction] 管理：
  /// - 核心启动/重启时调用 `start()`；
  /// - 核心停止时调用 `pause()`；
  /// - 应用退出前调用 `flushAndDispose()`。
  ///
  /// 服务本身不监听核心状态，由调用方驱动生命周期。
  TrafficCollectionServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'trafficCollectionServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$trafficCollectionServiceHash();

  @$internal
  @override
  $ProviderElement<TrafficCollectionService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  TrafficCollectionService create(Ref ref) {
    return trafficCollectionService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TrafficCollectionService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TrafficCollectionService>(value),
    );
  }
}

String _$trafficCollectionServiceHash() =>
    r'cc02fd62bc128b672f65db10560004a8e8e547bf';
