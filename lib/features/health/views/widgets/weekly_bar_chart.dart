import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/date_utils.dart';
import '../../models/day_summary.dart';

/// Simple bar chart (no external chart library) for the last N days.
class WeeklyBarChart extends StatelessWidget {
  const WeeklyBarChart({
    super.key,
    required this.days,
    required this.color,
    required this.valueOf,
  });

  final List<DaySummary> days;
  final Color color;
  final int Function(DaySummary) valueOf;

  static const double _maxBarHeight = 90;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final compact = NumberFormat.compact();
    var maxValue = 0;
    for (final d in days) {
      final v = valueOf(d);
      if (v > maxValue) maxValue = v;
    }
    if (maxValue == 0) maxValue = 1;

    return SizedBox(
      height: 150,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final d in days)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      compact.format(valueOf(d)),
                      style: theme.textTheme.labelSmall,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: valueOf(d) == 0
                          ? 4
                          : (_maxBarHeight * valueOf(d) / maxValue)
                              .clamp(4.0, _maxBarHeight),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      AppDateUtils.weekday(d.date),
                      style: theme.textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
