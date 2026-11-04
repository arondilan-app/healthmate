import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/date_utils.dart';
import '../../../shared/widgets/empty_state.dart';
import '../models/health_record.dart';
import '../viewmodel/health_provider.dart';
import 'add_edit_record_screen.dart';
import 'widgets/record_tile.dart';

/// Health Record List screen: all past records + search/filter by date.
class RecordListScreen extends StatelessWidget {
  const RecordListScreen({super.key});

  Future<void> _pickFilterDate(BuildContext context) async {
    final provider = context.read<HealthProvider>();
    final now = DateTime.now();
    final initial = provider.filterDate != null
        ? AppDateUtils.parseKey(provider.filterDate!)
        : now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: now,
      helpText: 'Search records by date',
    );
    if (picked != null) {
      await provider.setFilterDate(AppDateUtils.toKey(picked));
    }
  }

  Future<void> _confirmDelete(BuildContext context, HealthRecord record) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete record?'),
        content: Text(
          'The record for ${AppDateUtils.pretty(record.date)} will be removed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await _delete(context, record);
    }
  }

  Future<void> _delete(BuildContext context, HealthRecord record) async {
    final provider = context.read<HealthProvider>();
    final messenger = ScaffoldMessenger.of(context);
    await provider.deleteRecord(record);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const Text('Record deleted'),
          action: SnackBarAction(
            label: 'UNDO',
            onPressed: () => provider.undoDelete(),
          ),
        ),
      );
  }

  void _openEdit(BuildContext context, HealthRecord record) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => AddEditRecordScreen(record: record)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final health = context.watch<HealthProvider>();
    final theme = Theme.of(context);
    final records = health.records;

    return Scaffold(
      appBar: AppBar(title: const Text('Health Records')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    key: const Key('btn_filter_date'),
                    onPressed: () => _pickFilterDate(context),
                    icon: const Icon(Icons.search),
                    label: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        health.filterDate == null
                            ? 'Search by date'
                            : AppDateUtils.pretty(health.filterDate!),
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                  ),
                ),
                if (health.isFiltered)
                  IconButton(
                    key: const Key('btn_clear_filter'),
                    tooltip: 'Clear filter',
                    icon: const Icon(Icons.close),
                    onPressed: () =>
                        context.read<HealthProvider>().clearFilter(),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${records.length} ${records.length == 1 ? 'record' : 'records'}'
                '${health.isFiltered ? ' found' : ''}',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.outline),
              ),
            ),
          ),
          Expanded(child: _buildList(context, health, records)),
        ],
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    HealthProvider health,
    List<HealthRecord> records,
  ) {
    if (health.isLoading && records.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (records.isEmpty) {
      return health.isFiltered
          ? const EmptyState(
              icon: Icons.search_off,
              title: 'No records for this date',
              message: 'Try another date or clear the filter.',
            )
          : const EmptyState(
              icon: Icons.favorite_border,
              title: 'No records yet',
              message: 'Tap "Add Record" to save your first entry.',
            );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 96),
      itemCount: records.length,
      itemBuilder: (context, index) {
        final record = records[index];
        return Dismissible(
          key: ValueKey('record_${record.id}'),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 24),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.delete,
              color: Theme.of(context).colorScheme.onErrorContainer,
            ),
          ),
          onDismissed: (_) => _delete(context, record),
          child: RecordTile(
            record: record,
            onTap: () => _openEdit(context, record),
            onDelete: () => _confirmDelete(context, record),
          ),
        );
      },
    );
  }
}
