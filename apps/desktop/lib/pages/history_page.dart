import 'package:flutter/material.dart';

import '../models/download_task.dart';
import '../widgets/download_tile.dart';
import '../widgets/empty_state.dart';
import '../widgets/page_header.dart';
import '../app/navigation.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  DownloadStatus? _filter;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListenableBuilder(
            listenable: context.downloads,
            builder: (context, _) {
              final items = context.downloads.history;
              final completed = items.where((t) => t.status == DownloadStatus.completed).length;
              final failed = items.where((t) => t.status == DownloadStatus.failed).length;
              return PageHeader(
                title: 'History',
                subtitle: items.isEmpty
                    ? 'No completed or failed downloads'
                    : '$completed completed · $failed failed',
                actions: [
                  if (items.isNotEmpty)
                    OutlinedButton.icon(
                      onPressed: () => _confirmClear(context),
                      icon: const Icon(Icons.delete_sweep_outlined, size: 18),
                      label: const Text('Clear history'),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 18),
          _FilterRow(
            filter: _filter,
            onChanged: (f) => setState(() => _filter = f),
          ),
          const SizedBox(height: 18),
          Expanded(
            child: ListenableBuilder(
              listenable: context.downloads,
              builder: (context, _) {
                final items = context.downloads.history.where((t) {
                  if (_filter == null) return true;
                  return t.status == _filter;
                }).toList();

                if (items.isEmpty) {
                  return EmptyState(
                    icon: Icons.history_outlined,
                    title: 'No matching records',
                    description: 'Completed and failed downloads will appear here.',
                  );
                }

                return ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) => DownloadTile(task: items[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _confirmClear(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear history?'),
        content: const Text('This removes all completed and failed records. Active downloads are not affected.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              context.downloads.clearHistory();
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  const _FilterRow({required this.filter, required this.onChanged});

  final DownloadStatus? filter;
  final ValueChanged<DownloadStatus?> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final options = <(String, DownloadStatus?)>[
      ('All', null),
      ('Completed', DownloadStatus.completed),
      ('Failed', DownloadStatus.failed),
    ];
    return Row(
      children: options.map((option) {
        final selected = option.$2 == filter;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ChoiceChip(
            label: Text(option.$1),
            selected: selected,
            onSelected: (_) => onChanged(option.$2),
            showCheckmark: false,
            visualDensity: VisualDensity.compact,
            labelStyle: theme.textTheme.bodyMedium?.copyWith(
              color: selected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            ),
            side: BorderSide(color: theme.dividerColor),
          ),
        );
      }).toList(),
    );
  }
}
