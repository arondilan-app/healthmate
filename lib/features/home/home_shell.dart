import 'package:flutter/material.dart';

import '../health/views/add_edit_record_screen.dart';
import '../health/views/dashboard_screen.dart';
import '../health/views/record_list_screen.dart';
import '../settings/views/settings_screen.dart';

/// Root screen with Material 3 bottom navigation (Dashboard / Records / Settings).
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _pages = <Widget>[
    DashboardScreen(),
    RecordListScreen(),
    SettingsScreen(),
  ];

  void _openAdd() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AddEditRecordScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      floatingActionButton: _index == 2
          ? null
          : FloatingActionButton.extended(
              key: const Key('fab_add_record'),
              onPressed: _openAdd,
              icon: const Icon(Icons.add),
              label: const Text('Add Record'),
            ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.list_alt_outlined),
            selectedIcon: Icon(Icons.list_alt),
            label: 'Records',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
