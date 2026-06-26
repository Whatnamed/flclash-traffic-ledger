import 'package:fl_clash/common/navigation.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/traffic_ledger.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/traffic_ledger/traffic_ledger_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Fake snapshot notifier that returns a fixed value, for widget tests.
class _FakeSnapshotNotifier extends TrafficLedgerSnapshotNotifier {
  _FakeSnapshotNotifier(this._snapshot);
  final TrafficLedgerSnapshot _snapshot;
  @override
  Future<TrafficLedgerSnapshot> build() async => _snapshot;
}

/// Fake collection status notifier that returns a fixed bool.
class _FakeCollectionStatusNotifier extends CollectionStatusNotifier {
  _FakeCollectionStatusNotifier(this._isRunning);
  final bool _isRunning;
  @override
  Future<bool> build() async => _isRunning;
}

const _emptySnapshot = TrafficLedgerSnapshot(
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

TrafficLedgerSnapshot _snapshotWith({
  int? bytesUp,
  int? bytesDown,
  int? estimatedUp,
  int? estimatedDown,
  int? unattributedBytes,
  List<AppAggregation>? apps,
}) {
  final up = bytesUp ?? 0;
  final down = bytesDown ?? 0;
  final estUp = estimatedUp ?? 0;
  final estDown = estimatedDown ?? 0;
  final unattrTotal = unattributedBytes ?? 0;
  return TrafficLedgerSnapshot(
    period: BillingPeriod(
      id: 1,
      label: '测试周期',
      startAt: DateTime(2026, 6, 1),
      endAt: null,
      createdAt: DateTime(2026, 6, 1),
    ),
    overview: PeriodOverview(
      bytesUp: up,
      bytesDown: down,
      estimatedBilledBytesUp: estUp,
      estimatedBilledBytesDown: estDown,
      unbilledBytesUp: 0,
      unbilledBytesDown: 0,
    ),
    unattributed: PeriodOverview(
      bytesUp: unattrTotal,
      bytesDown: 0,
      estimatedBilledBytesUp: 0,
      estimatedBilledBytesDown: 0,
      unbilledBytesUp: 0,
      unbilledBytesDown: 0,
    ),
    apps: apps ?? [],
  );
}

Widget _wrapWithProviders(
  Widget child, {
  TrafficLedgerSnapshot? snapshot,
  bool isCollecting = false,
  String diagnostics = 'test diagnostics',
}) {
  return ProviderScope(
    overrides: [
      trafficLedgerSnapshotProvider.overrideWith(
        () => _FakeSnapshotNotifier(snapshot ?? _emptySnapshot),
      ),
      collectionStatusProvider.overrideWith(
        () => _FakeCollectionStatusNotifier(isCollecting),
      ),
      trafficDiagnosticsSummaryProvider.overrideWithValue(diagnostics),
      // CommonDialog 依赖 viewSizeProvider 计算 maxHeight/width
      viewSizeProvider.overrideWithBuild((_, _) => const Size(800, 600)),
    ],
    child: MaterialApp(
      navigatorKey: globalState.navigatorKey,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.delegate.supportedLocales,
      home: child,
    ),
  );
}

void main() {
  group('Navigation entry', () {
    test('sidebar includes trafficLedger entry', () {
      final items = navigation.getItems();
      final labels = items.map((e) => e.label).toList();
      expect(labels, contains(PageLabel.trafficLedger));
    });

    testWidgets('trafficLedger entry builds TrafficLedgerView', (tester) async {
      final items = navigation.getItems();
      final entry = items.firstWhere((e) => e.label == PageLabel.trafficLedger);
      // 通过 Builder 在 widget tree 中调用 builder，避免 BuildContext 为 null。
      Widget? built;
      await tester.pumpWidget(
        Builder(
          builder: (ctx) {
            built = entry.builder(ctx);
            return const SizedBox.shrink();
          },
        ),
      );
      expect(built, isA<TrafficLedgerView>());
    });
  });

  group('TrafficLedgerView - empty state', () {
    testWidgets('shows empty state when no data', (tester) async {
      await tester.pumpWidget(
        _wrapWithProviders(const TrafficLedgerView()),
      );
      await tester.pumpAndSettle();
      expect(find.text('流量账本'), findsOneWidget);
      expect(find.text('暂无流量数据'), findsOneWidget);
    });

    testWidgets('shows collecting status text', (tester) async {
      await tester.pumpWidget(
        _wrapWithProviders(
          const TrafficLedgerView(),
          isCollecting: true,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('正在采集'), findsOneWidget);
    });
  });

  group('TrafficLedgerView - with data', () {
    testWidgets('displays overview and app list', (tester) async {
      final snapshot = _snapshotWith(
        bytesUp: 1024,
        bytesDown: 2048,
        estimatedUp: 2048,
        estimatedDown: 4096,
        apps: [
          const AppAggregation(
            appIdentifier: 'c:/app/chrome.exe',
            bytesUp: 1024,
            bytesDown: 2048,
            estimatedBilledBytesUp: 2048,
            estimatedBilledBytesDown: 4096,
            hasUnbilled: false,
          ),
        ],
      );
      await tester.pumpWidget(
        _wrapWithProviders(
          const TrafficLedgerView(),
          snapshot: snapshot,
          isCollecting: true,
        ),
      );
      await tester.pumpAndSettle();
      // 页面标题
      expect(find.text('流量账本'), findsOneWidget);
      // 周期名称
      expect(find.text('测试周期'), findsOneWidget);
      // 采集状态
      expect(find.text('正在采集'), findsOneWidget);
      // 总览区域标题
      expect(find.text('当前周期总览'), findsOneWidget);
      // 应用列表区域标题
      expect(find.text('应用'), findsOneWidget);
      // 应用友好名称（basename）
      expect(find.text('chrome.exe'), findsOneWidget);
    });

    testWidgets('shows unattributed section when unattributed > 0', (tester) async {
      final snapshot = _snapshotWith(
        bytesUp: 1024,
        bytesDown: 2048,
        estimatedUp: 2048,
        estimatedDown: 4096,
        unattributedBytes: 500,
        apps: [
          const AppAggregation(
            appIdentifier: 'c:/app/chrome.exe',
            bytesUp: 1024,
            bytesDown: 2048,
            estimatedBilledBytesUp: 2048,
            estimatedBilledBytesDown: 4096,
            hasUnbilled: false,
          ),
        ],
      );
      await tester.pumpWidget(
        _wrapWithProviders(
          const TrafficLedgerView(),
          snapshot: snapshot,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('未归因代理流量'), findsOneWidget);
      expect(
        find.text('部分总代理流量无法由当前连接快照可靠归属到具体应用。'),
        findsOneWidget,
      );
    });

    testWidgets('hides unattributed section when unattributed = 0', (tester) async {
      final snapshot = _snapshotWith(
        bytesUp: 1024,
        bytesDown: 2048,
        estimatedUp: 2048,
        estimatedDown: 4096,
        unattributedBytes: 0,
        apps: [
          const AppAggregation(
            appIdentifier: 'c:/app/chrome.exe',
            bytesUp: 1024,
            bytesDown: 2048,
            estimatedBilledBytesUp: 2048,
            estimatedBilledBytesDown: 4096,
            hasUnbilled: false,
          ),
        ],
      );
      await tester.pumpWidget(
        _wrapWithProviders(
          const TrafficLedgerView(),
          snapshot: snapshot,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('未归因代理流量'), findsNothing);
    });
  });

  group('TrafficLedgerView - diagnostics', () {
    testWidgets('shows diagnostics section in debug mode', (tester) async {
      // kDebugMode is true in test environment
      await tester.pumpWidget(
        _wrapWithProviders(const TrafficLedgerView()),
      );
      await tester.pumpAndSettle();
      expect(find.text('采集诊断'), findsOneWidget);
    });

    testWidgets('diagnostics content visible after expansion', (tester) async {
      await tester.pumpWidget(
        _wrapWithProviders(
          const TrafficLedgerView(),
          diagnostics: 'sample diagnostics line',
        ),
      );
      await tester.pumpAndSettle();
      // Tap to expand
      await tester.tap(find.text('采集诊断'));
      await tester.pumpAndSettle();
      expect(find.text('sample diagnostics line'), findsOneWidget);
    });
  });

  group('TrafficLedgerView - new period button', () {
    testWidgets('new period button exists', (tester) async {
      await tester.pumpWidget(
        _wrapWithProviders(const TrafficLedgerView()),
      );
      await tester.pumpAndSettle();
      expect(find.text('新建周期'), findsOneWidget);
    });

    testWidgets('tapping new period shows confirmation dialog', (tester) async {
      await tester.pumpWidget(
        _wrapWithProviders(const TrafficLedgerView()),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('新建周期'));
      await tester.pumpAndSettle();
      // 确认弹窗内容
      expect(find.text('新建计费周期'), findsOneWidget);
      expect(
        find.text('将结束当前计费周期，并从现在开始记录新周期。\n已有历史记录不会删除。'),
        findsOneWidget,
      );
    });
  });
}
