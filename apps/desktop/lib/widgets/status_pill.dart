import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../models/download_task.dart';

class StatusPill extends StatelessWidget {
  const StatusPill({required this.status, super.key});

  final DownloadStatus status;

  (Color, String) _resolve() {
    switch (status) {
      case DownloadStatus.active:
        return (NimbusColors.success, 'Downloading');
      case DownloadStatus.pending:
        return (NimbusColors.pending, 'Queued');
      case DownloadStatus.paused:
        return (NimbusColors.paused, 'Paused');
      case DownloadStatus.completed:
        return (NimbusColors.success, 'Completed');
      case DownloadStatus.failed:
        return (NimbusColors.failed, 'Failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    final (color, label) = _resolve();
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
          const SizedBox(width: 7),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryChip extends StatelessWidget {
  const CategoryChip({required this.category, super.key});

  final DownloadCategory category;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        category.label,
        style: theme.textTheme.bodySmall?.copyWith(fontSize: 11.5),
      ),
    );
  }
}
