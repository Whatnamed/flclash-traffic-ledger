import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/traffic_ledger/collection/app_identifier.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 流量账本主页面（Stage 4A）。
///
/// 展示当前活动计费周期的总览、应用维度列表、未归因代理流量、
/// 采集状态、开发版诊断摘要。提供"新建计费周期"入口。
class TrafficLedgerView extends ConsumerWidget {
  const TrafficLedgerView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshotAsync = ref.watch(trafficLedgerSnapshotProvider);
    final isCollectingAsync = ref.watch(collectionStatusProvider);
    final isCollecting = isCollectingAsync.value ?? false;

    return CommonScaffold(
      title: '流量账本',
      body: snapshotAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('加载失败: $e')),
        data: (snapshot) => _Body(
          snapshot: snapshot,
          isCollecting: isCollecting,
        ),
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.snapshot, required this.isCollecting});

  final TrafficLedgerSnapshot snapshot;
  final bool isCollecting;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: [
        _HeaderSection(
          period: snapshot.period,
          isCollecting: isCollecting,
          hasData: snapshot.hasData,
        ),
        if (snapshot.hasData) ...[
          _OverviewSection(overview: snapshot.overview),
          const SizedBox(height: 16),
          _UnattributedSection(unattributed: snapshot.unattributed),
          const SizedBox(height: 16),
          _AppListSection(
            apps: snapshot.apps,
            totalBytes: snapshot.overview.totalBytes,
          ),
        ] else
          const _EmptyState(),
        if (kDebugMode) ...[
          const SizedBox(height: 24),
          const _DiagnosticsSection(),
        ],
      ],
    );
  }
}

// ---------- 顶部标题区 ----------

class _HeaderSection extends StatelessWidget {
  const _HeaderSection({
    required this.period,
    required this.isCollecting,
    required this.hasData,
  });

  final BillingPeriod? period;
  final bool isCollecting;
  final bool hasData;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _periodTitle(),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      isCollecting ? Icons.circle : Icons.pause_circle_outline,
                      size: 12,
                      color: isCollecting
                          ? Colors.green
                          : Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _collectingStatus(),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
          FilledButton.tonalIcon(
            onPressed: () => _showNewPeriodDialog(context),
            icon: const Icon(Icons.restart_alt, size: 18),
            label: const Text('新建周期'),
          ),
        ],
      ),
    );
  }

  String _periodTitle() {
    if (period == null) return '暂无活动周期';
    final label = period!.label;
    if (label != null && label.isNotEmpty) return label;
    final start = period!.startAt;
    return '周期 ${start.year}-${start.month.toString().padLeft(2, '0')}-${start.day.toString().padLeft(2, '0')}';
  }

  String _collectingStatus() {
    if (!hasData && !isCollecting) return '暂无数据';
    return isCollecting ? '正在采集' : '已暂停';
  }

  void _showNewPeriodDialog(BuildContext context) async {
    final container = ProviderScope.containerOf(context, listen: false);
    final res = await globalState.showMessage(
      title: '新建计费周期',
      message: const TextSpan(
        text: '将结束当前计费周期，并从现在开始记录新周期。\n已有历史记录不会删除。',
      ),
    );
    if (res != true) return;
    await container
        .read(trafficCollectionServiceProvider)
        .createNewBillingPeriod();
    await container
        .read(trafficLedgerSnapshotProvider.notifier)
        .refresh();
  }
}

// ---------- 当前周期总览 ----------

class _OverviewSection extends StatelessWidget {
  const _OverviewSection({required this.overview});

  final PeriodOverview overview;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('当前周期总览', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 12),
          _StatGrid(overview: overview),
          const SizedBox(height: 8),
          if (overview.totalUnbilled > 0)
            Text(
              '预计扣量基于已识别节点的倍率估算，'
              '${TrafficFormatter.format(overview.totalUnbilled).show} 实际流量无法可靠估算扣量',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
        ],
      ),
    );
  }
}

class _StatGrid extends StatelessWidget {
  const _StatGrid({required this.overview});

  final PeriodOverview overview;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatItem(
                label: '实际代理流量',
                value: TrafficFormatter.format(overview.totalBytes).show,
                icon: Icons.swap_vert,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatItem(
                label: '预计扣量',
                value: TrafficFormatter.format(overview.totalEstimatedBilled).show,
                icon: Icons.calculate,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatItem(
                label: '上传',
                value: TrafficFormatter.format(overview.bytesUp).show,
                icon: Icons.arrow_upward,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatItem(
                label: '下载',
                value: TrafficFormatter.format(overview.bytesDown).show,
                icon: Icons.arrow_downward,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: cs.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- 未归因代理流量 ----------

class _UnattributedSection extends StatelessWidget {
  const _UnattributedSection({required this.unattributed});

  final PeriodOverview unattributed;

  @override
  Widget build(BuildContext context) {
    if (unattributed.totalBytes == 0) return const SizedBox.shrink();
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cs.secondaryContainer.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Row(
          children: [
            Icon(Icons.help_outline, size: 20, color: cs.secondary),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '未归因代理流量',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '部分总代理流量无法由当前连接快照可靠归属到具体应用。',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    TrafficFormatter.format(unattributed.totalBytes).show,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------- 应用列表 ----------

class _AppListSection extends StatelessWidget {
  const _AppListSection({required this.apps, required this.totalBytes});

  final List<AppAggregation> apps;
  final int totalBytes;

  @override
  Widget build(BuildContext context) {
    if (apps.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          '当前周期尚未记录代理流量',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('应用', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          ...apps.map((app) => _AppListItem(
                app: app,
                totalBytes: totalBytes,
              )),
        ],
      ),
    );
  }
}

class _AppListItem extends StatelessWidget {
  const _AppListItem({required this.app, required this.totalBytes});

  final AppAggregation app;
  final int totalBytes;

  @override
  Widget build(BuildContext context) {
    final displayName = AppIdentifierResolver.displayName(app.appIdentifier);
    final name = displayName.isEmpty ? '未识别进程' : displayName;
    final ratio = totalBytes > 0 ? (app.totalBytes / totalBytes * 100) : 0.0;
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: cs.primaryContainer,
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: TextStyle(color: cs.onPrimaryContainer),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: Theme.of(context).textTheme.bodyLarge,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      TrafficFormatter.format(app.totalBytes).show,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      '↑${TrafficFormatter.format(app.bytesUp).show} '
                      '↓${TrafficFormatter.format(app.bytesDown).show}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '扣量 ${TrafficFormatter.format(app.totalEstimatedBilled).show}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                    ),
                    const Spacer(),
                    Text(
                      '${ratio.toStringAsFixed(1)}%',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: cs.outline,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: totalBytes > 0 ? app.totalBytes / totalBytes : 0,
                  backgroundColor: cs.surfaceContainerHighest,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- 空状态 ----------

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              '暂无流量数据',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              '启动代理核心后，流量将自动采集并显示在此处',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------- 开发版诊断摘要 ----------

class _DiagnosticsSection extends ConsumerWidget {
  const _DiagnosticsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(trafficDiagnosticsSummaryProvider);
    if (summary == 'diagnostics disabled (release)') {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ExpansionTile(
        title: Text(
          '采集诊断',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        initiallyExpanded: false,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(8),
            ),
            child: SelectableText(
              summary,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
