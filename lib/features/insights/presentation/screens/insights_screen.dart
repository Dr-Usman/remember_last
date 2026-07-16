import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/status_indicator.dart';
import '../providers/insights_providers.dart';

class InsightsScreen extends ConsumerStatefulWidget {
  const InsightsScreen({super.key});

  @override
  ConsumerState<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends ConsumerState<InsightsScreen> {
  int? _selectedActivityId;

  @override
  Widget build(BuildContext context) {
    final insightsAsync = ref.watch(insightsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Insights')),
      body: insightsAsync.when(
        data: (insights) {
          if (insights.activityInsights.isEmpty) {
            return const Center(child: Text('No data yet. Log some activities!'));
          }

          final selected = _selectedActivityId == null
              ? insights.activityInsights.first
              : insights.activityInsights.firstWhere(
                  (i) => i.activity.id == _selectedActivityId,
                  orElse: () => insights.activityInsights.first,
                );

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _GlobalStatsCard(insights: insights),
              const SizedBox(height: 16),
              Text(
                'Activity breakdown',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ...insights.activityInsights.map(
                (item) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(item.activity.title),
                    subtitle: Text(
                      '${item.totalLogs} logs'
                      '${item.averageIntervalDays != null ? ' • avg ${item.averageIntervalDays!.toStringAsFixed(1)} days' : ''}',
                    ),
                    trailing: StatusIndicator(status: item.status, compact: true),
                    selected: selected.activity.id == item.activity.id,
                    onTap: () =>
                        setState(() => _selectedActivityId = item.activity.id),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Intervals — ${selected.activity.title}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              if (selected.intervals.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('Need at least 2 logs to show intervals'),
                  ),
                )
              else
                SizedBox(
                  height: 200,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: selected.intervals.reduce((a, b) => a > b ? a : b) * 1.2,
                          barTouchData: BarTouchData(enabled: false),
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  return Text('#${value.toInt() + 1}',
                                      style: const TextStyle(fontSize: 10));
                                },
                              ),
                            ),
                            leftTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: true, reservedSize: 32),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          gridData: const FlGridData(show: true, drawVerticalLine: false),
                          borderData: FlBorderData(show: false),
                          barGroups: [
                            for (var i = 0; i < selected.intervals.length; i++)
                              BarChartGroupData(
                                x: i,
                                barRods: [
                                  BarChartRodData(
                                    toY: selected.intervals[i],
                                    color: AppColors.primary,
                                    width: 16,
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(4),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _GlobalStatsCard extends StatelessWidget {
  const _GlobalStatsCard({required this.insights});

  final GlobalInsight insights;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Overview', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Row(
              children: [
                _StatChip(
                  label: 'Activities',
                  value: '${insights.totalActivities}',
                ),
                const SizedBox(width: 12),
                _StatChip(
                  label: 'Total logs',
                  value: '${insights.totalLogs}',
                ),
              ],
            ),
            if (insights.mostOverdue != null) ...[
              const SizedBox(height: 12),
              Text(
                'Most overdue: ${insights.mostOverdue!.activity.title}',
                style: TextStyle(color: AppColors.overdue),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.labelSmall),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
