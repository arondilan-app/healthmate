import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/validators.dart';
import '../models/health_record.dart';
import '../viewmodel/health_provider.dart';

/// Form screen used for both "Add Record" and "Edit Record".
/// When [record] is null a new record is created, otherwise it is updated.
class AddEditRecordScreen extends StatefulWidget {
  const AddEditRecordScreen({super.key, this.record});

  final HealthRecord? record;

  @override
  State<AddEditRecordScreen> createState() => _AddEditRecordScreenState();
}

class _AddEditRecordScreenState extends State<AddEditRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _dateCtrl;
  late final TextEditingController _stepsCtrl;
  late final TextEditingController _caloriesCtrl;
  late final TextEditingController _waterCtrl;
  bool _saving = false;

  bool get _isEditing => widget.record != null;

  @override
  void initState() {
    super.initState();
    final r = widget.record;
    _dateCtrl = TextEditingController(text: r?.date ?? AppDateUtils.todayKey());
    _stepsCtrl = TextEditingController(text: r?.steps.toString() ?? '');
    _caloriesCtrl = TextEditingController(text: r?.calories.toString() ?? '');
    _waterCtrl = TextEditingController(text: r?.water.toString() ?? '');
  }

  @override
  void dispose() {
    _dateCtrl.dispose();
    _stepsCtrl.dispose();
    _caloriesCtrl.dispose();
    _waterCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    DateTime initial;
    try {
      initial = AppDateUtils.parseKey(_dateCtrl.text);
    } catch (_) {
      initial = DateTime.now();
    }
    final today = DateTime.now();
    if (initial.isAfter(today)) initial = today;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: today, // future dates are not allowed
    );
    if (picked != null) {
      _dateCtrl.text = AppDateUtils.toKey(picked);
    }
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _saving = true);
    final provider = context.read<HealthProvider>();
    final record = HealthRecord(
      id: widget.record?.id,
      date: _dateCtrl.text.trim(),
      steps: int.parse(_stepsCtrl.text.trim()),
      calories: int.parse(_caloriesCtrl.text.trim()),
      water: int.parse(_waterCtrl.text.trim()),
    );

    final ok = _isEditing
        ? await provider.updateRecord(record)
        : await provider.addRecord(record);

    if (!mounted) return;
    setState(() => _saving = false);

    final messenger = ScaffoldMessenger.of(context);
    if (ok) {
      Navigator.of(context).pop();
      messenger.showSnackBar(
        SnackBar(
          content: Text(_isEditing ? 'Record updated' : 'Record added'),
        ),
      );
    } else {
      messenger.showSnackBar(
        SnackBar(content: Text(provider.errorMessage ?? 'Could not save record')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Record' : 'Add Record'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              children: [
                TextFormField(
                  key: const Key('field_date'),
                  controller: _dateCtrl,
                  readOnly: true,
                  onTap: _pickDate,
                  validator: Validators.date,
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    prefixIcon: Icon(Icons.calendar_today),
                    suffixIcon: Icon(Icons.arrow_drop_down),
                  ),
                ),
                const SizedBox(height: 16),
                _numberField(
                  fieldKey: 'field_steps',
                  controller: _stepsCtrl,
                  label: 'Steps walked',
                  suffix: 'steps',
                  icon: Icons.directions_walk,
                  color: AppColors.steps,
                  validator: Validators.steps,
                ),
                const SizedBox(height: 16),
                _numberField(
                  fieldKey: 'field_calories',
                  controller: _caloriesCtrl,
                  label: 'Calories burned',
                  suffix: 'kcal',
                  icon: Icons.local_fire_department,
                  color: AppColors.calories,
                  validator: Validators.calories,
                ),
                const SizedBox(height: 16),
                _numberField(
                  fieldKey: 'field_water',
                  controller: _waterCtrl,
                  label: 'Water intake',
                  suffix: 'ml',
                  icon: Icons.water_drop,
                  color: AppColors.water,
                  validator: Validators.water,
                ),
                const SizedBox(height: 28),
                FilledButton.icon(
                  key: const Key('btn_save'),
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save),
                  label: Text(_isEditing ? 'Update Record' : 'Save Record'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _numberField({
    required String fieldKey,
    required TextEditingController controller,
    required String label,
    required String suffix,
    required IconData icon,
    required Color color,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      key: Key(fieldKey),
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      validator: validator,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
        prefixIcon: Icon(icon, color: color),
      ),
    );
  }
}
