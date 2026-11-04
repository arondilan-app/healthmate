import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'data/database/database_helper.dart';
import 'features/health/repository/health_repository.dart';
import 'features/health/viewmodel/health_provider.dart';
import 'features/settings/viewmodel/settings_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Dependency wiring: Database -> Repository -> ViewModel (Provider)
  final repository = HealthRepository(DatabaseHelper.instance);
  final settings = SettingsProvider();
  await settings.load();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingsProvider>.value(value: settings),
        ChangeNotifierProvider<HealthProvider>(
          create: (_) => HealthProvider(repository)..loadAll(),
        ),
      ],
      child: const HealthMateApp(),
    ),
  );
}
