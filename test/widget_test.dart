import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthmate/core/theme/app_theme.dart';
import 'package:healthmate/features/health/views/widgets/metric_card.dart';
import 'package:healthmate/shared/widgets/empty_state.dart';

void main() {
  testWidgets('MetricCard shows value, unit, goal and percentage',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: MetricCard(
            icon: Icons.water_drop,
            label: 'Water Intake',
            value: 2000,
            unit: 'ml',
            goal: 4000,
            color: AppColors.water,
          ),
        ),
      ),
    );

    expect(find.text('2,000 ml'), findsOneWidget);
    expect(find.text('Goal: 4,000 ml'), findsOneWidget);
    expect(find.text('50%'), findsOneWidget);
  });

  testWidgets('MetricCard progress never goes above 100%',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: MetricCard(
            icon: Icons.directions_walk,
            label: 'Steps',
            value: 15000,
            unit: 'steps',
            goal: 10000,
            color: AppColors.steps,
          ),
        ),
      ),
    );

    expect(find.text('100%'), findsOneWidget);
  });

  testWidgets('EmptyState shows title and message', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: EmptyState(
            icon: Icons.search_off,
            title: 'No records yet',
            message: 'Tap Add Record',
          ),
        ),
      ),
    );

    expect(find.text('No records yet'), findsOneWidget);
    expect(find.text('Tap Add Record'), findsOneWidget);
  });
}
