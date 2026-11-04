import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Reusable card that shows one metric (steps / calories / water)
/// together with a progress bar towards the daily goal.
class MetricCard extends StatelessWidget {
  const MetricCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    required this.goal,
    required this.color,
  });

  final IconData icon;
  final String label;
  final int value;
  final String unit;
  final int goal;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formatter = NumberFormat.decimalPattern();
    final double progress =
        goal <= 0 ? 0.0 : (value / goal).clamp(0.0, 1.0).toDouble();
    final percent = (progress * 100).round();

    return Card(
      elevation: 0,
      color: color.withAlpha(25),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color.withAlpha(80)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: color,
                  radius: 22,
                  child: Icon(icon, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label, style: theme.textTheme.labelLarge),
                      Text(
                        '${formatter.format(value)} $unit',
                        key: Key('metric_value_$label'),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '$percent%',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                color: color,
                backgroundColor: color.withAlpha(40),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Goal: ${formatter.format(goal)} $unit',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
