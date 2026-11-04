import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/validators.dart';
import '../viewmodel/settings_provider.dart';

/// Extra feature: dark mode switch and editable daily goals.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _stepsCtrl;
  late final TextEditingController _caloriesCtrl;
  late final TextEditingController _waterCtrl;

  @override
  void initState() {
    super.initState();
    final s = context.read<SettingsProvider>();
    _stepsCtrl = TextEditingController(text: s.stepsGoal.toString());
    _caloriesCtrl = TextEditingController(text: s.caloriesGoal.toString());
    _waterCtrl = TextEditingController(text: s.waterGoal.toString());
  }

  @override
  void dispose() {
    _stepsCtrl.dispose();
    _caloriesCtrl.dispose();
    _waterCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveGoals() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final settings = context.read<SettingsProvider>();
    final messenger = ScaffoldMessenger.of(context);
    FocusScope.of(context).unfocus();
    await settings.setGoals(
      steps: int.parse(_stepsCtrl.text.trim()),
      calories: int.parse(_caloriesCtrl.text.trim()),
      water: int.parse(_waterCtrl.text.trim()),
    );
    messenger.showSnackBar(const SnackBar(content: Text('Daily goals saved')));
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          SwitchListTile(
            key: const Key('switch_dark_mode'),
            contentPadding: EdgeInsets.zero,
            secondary: const Icon(Icons.dark_mode_outlined),
            title: const Text('Dark mode'),
            subtitle: const Text('Use a dark colour scheme'),
            value: settings.darkMode,
            onChanged: (v) => context.read<SettingsProvider>().setDarkMode(v),
          ),
          const Divider(height: 32),
          Text('Daily goals', style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            'Goals control the progress bars on the dashboard.',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.outline),
          ),
          const SizedBox(height: 16),
          Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              children: [
                _goalField(
                  controller: _stepsCtrl,
                  label: 'Steps goal',
                  suffix: 'steps',
                  icon: Icons.directions_walk,
                  color: AppColors.steps,
                  max: AppConstants.maxSteps,
                ),
                const SizedBox(height: 16),
                _goalField(
                  controller: _caloriesCtrl,
                  label: 'Calories goal',
                  suffix: 'kcal',
                  icon: Icons.local_fire_department,
                  color: AppColors.calories,
                  max: AppConstants.maxCalories,
                ),
                const SizedBox(height: 16),
                _goalField(
                  controller: _waterCtrl,
                  label: 'Water goal',
                  suffix: 'ml',
                  icon: Icons.water_drop,
                  color: AppColors.water,
                  max: AppConstants.maxWaterMl,
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  key: const Key('btn_save_goals'),
                  onPressed: _saveGoals,
                  icon: const Icon(Icons.check),
                  label: const Text('Save goals'),
                ),
              ],
            ),
          ),
          const Divider(height: 40),
          const ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.info_outline),
            title: Text('HealthMate v1.0.0'),
            subtitle: Text('Personal Health & Wellness Tracker'),
          ),
        ],
      ),
    );
  }

  Widget _goalField({
    required TextEditingController controller,
    required String label,
    required String suffix,
    required IconData icon,
    required Color color,
    required int max,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      textInputAction: TextInputAction.next,
      validator: (v) => Validators.goal(v, label: label.split(' ').first, max: max),
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
        prefixIcon: Icon(icon, color: color),
      ),
    );
  }
}
