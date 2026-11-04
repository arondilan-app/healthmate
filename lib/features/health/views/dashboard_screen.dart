import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_utils.dart';
import '../../settings/viewmodel/settings_provider.dart';
import '../models/day_summary.dart';
import '../viewmodel/health_provider.dart';
import 'widgets/metric_card.dart';
import 'widgets/weekly_bar_chart.dart';

enum _ChartMetric { steps, calories, water }

/// Dashboard: summary of today's activities + last 7 days chart.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  _ChartMetric _metric = _ChartMetric.steps;

  @override
  Widget build(BuildContext context) {
    final health = context.watch<HealthProvider>();
    final settings = context.watch<SettingsProvider>();
    final theme = Theme.of(context);
    final today = health.today;

    return Scaffold(
      appBar: AppBar(title: const Text(AppConstants.appName)),
      body: health.isLoading && health.lastDays.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => context.read<HealthProvider>().loadAll(),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                children: [
                  Text(
                    'Today – ${AppDateUtils.pretty(AppDateUtils.todayKey())}',
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    today.entries == 0
                        ? 'No entries yet today. Tap "Add Record" to start.'
                        : '${today.entries} ${today.entries == 1 ? 'entry' : 'entries'} recorded today',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: theme.colorScheme.outline),
                  ),
                  if (health.errorMessage != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      health.errorMessage!,
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                  ],
                  const SizedBox(height: 16),
                  MetricCard(
                    icon: Icons.directions_walk,
                    label: 'Steps',
                    value: today.steps,
                    unit: 'steps',
                    goal: settings.stepsGoal,
                    color: AppColors.steps,
                  ),
                  const SizedBox(height: 12),
                  MetricCard(
                    icon: Icons.local_fire_department,
                    label: 'Calories Burned',
                    value: today.calories,
                    unit: 'kcal',
                    goal: settings.caloriesGoal,
                    color: AppColors.calories,
                  ),
                  const SizedBox(height: 12),
                  MetricCard(
                    icon: Icons.water_drop,
                    label: 'Water Intake',
                    value: today.water,
                    unit: 'ml',
                    goal: settings.waterGoal,
                    color: AppColors.water,
                  ),
                  const SizedBox(height: 24),
                  _buildChartCard(context, health.lastDays),
                ],
              ),
            ),
    );
  }

  Widget _buildChartCard(BuildContext context, List<DaySummary> days) {
    final theme = Theme.of(context);

    final Color color;
    final int Function(DaySummary) valueOf;
    switch (_metric) {
      case _ChartMetric.steps:
        color = AppColors.steps;
        valueOf = (d) => d.steps;
        break;
      case _ChartMetric.calories:
        color = AppColors.calories;
        valueOf = (d) => d.calories;
        break;
      case _ChartMetric.water:
        color = AppColors.water;
        valueOf = (d) => d.water;
        break;
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Last ${AppConstants.chartDays} days',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Steps'),
                  selected: _metric == _ChartMetric.steps,
                  onSelected: (_) => setState(() => _metric = _ChartMetric.steps),
                ),
                ChoiceChip(
                  label: const Text('Calories'),
                  selected: _metric == _ChartMetric.calories,
                  onSelected: (_) =>
                      setState(() => _metric = _ChartMetric.calories),
                ),
                ChoiceChip(
                  label: const Text('Water'),
                  selected: _metric == _ChartMetric.water,
                  onSelected: (_) => setState(() => _metric = _ChartMetric.water),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (days.isEmpty)
              const SizedBox(
                height: 150,
                child: Center(child: Text('No data yet')),
              )
            else
              WeeklyBarChart(days: days, color: color, valueOf: valueOf),
          ],
        ),
      ),
    );
  }
}
