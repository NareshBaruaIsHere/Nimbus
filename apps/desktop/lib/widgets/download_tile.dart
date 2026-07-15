import 'package:flutter/material.dart';

import '../models/download_task.dart';
import '../services/download_service.dart';
import '../app/navigation.dart';
import 'status_pill.dart';
import '../app/theme.dart';

class DownloadTile extends StatelessWidget {
  const DownloadTile({required this.task, super.key});

  final DownloadTask task;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final service = context.downloads;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.name,
                        style: theme.textTheme.titleMedium?.copyWith(fontSize: 14.5),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _subtitle(context),
                        style: theme.textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                CategoryChip(category: task.category),
                const SizedBox(width: 8),
                StatusPill(status: task.status),
              ],
            ),
            const SizedBox(height: 14),
            if (task.status == DownloadStatus.active || task.status == DownloadStatus.paused)
              _progress(context, task: task),
            if (task.status == DownloadStatus.active || task.status == DownloadStatus.paused)
              const SizedBox(height: 10),
            if (task.status == DownloadStatus.pending)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  'Waiting for an available slot',
                  style: theme.textTheme.bodySmall,
                ),
              ),
            if (task.status == DownloadStatus.failed && task.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  task.errorMessage!,
                  style: theme.textTheme.bodySmall?.copyWith(color: NimbusColors.failed),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: _actions(context, task, service),
            ),
          ],
        ),
      ),
    );
  }

  String _subtitle(BuildContext context) {
    switch (task.status) {
      case DownloadStatus.completed:
        return '${formatBytes(task.totalBytes)} · ${_relative(task.completedAt)}';
      case DownloadStatus.failed:
        return '${formatBytes(task.downloadedBytes)} of ${formatBytes(task.totalBytes)}';
      case DownloadStatus.active:
        return formatBytes(task.totalBytes);
      case DownloadStatus.paused:
        return '${formatBytes(task.downloadedBytes)} of ${formatBytes(task.totalBytes)}';
      case DownloadStatus.pending:
        return formatBytes(task.totalBytes);
    }
  }

  Widget _progress(BuildContext context, {required DownloadTask task}) {
    final theme = Theme.of(context);
    return Column(
      children: [
        LinearProgressIndicator(
          value: task.progress,
          minHeight: 6,
          borderRadius: BorderRadius.circular(3),
          color: task.status == DownloadStatus.paused
              ? theme.colorScheme.onSurfaceVariant
              : theme.colorScheme.primary,
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              task.status == DownloadStatus.paused ? 'Paused' : formatSpeed(task.speedBytesPerSec),
              style: theme.textTheme.bodySmall?.copyWith(
                color: task.status == DownloadStatus.active
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${(task.progress * 100).round()}%  ·  ${formatBytes(task.downloadedBytes)} / ${formatBytes(task.totalBytes)}',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ],
    );
  }

  List<Widget> _actions(BuildContext context, DownloadTask task, DownloadService service) {
    final buttons = <Widget>[];
    switch (task.status) {
      case DownloadStatus.active:
        buttons.add(_IconAction(icon: Icons.pause_rounded, tooltip: 'Pause', onTap: () => service.pause(task.id)));
        buttons.add(_IconAction(icon: Icons.close_rounded, tooltip: 'Cancel', onTap: () => service.remove(task.id)));
      case DownloadStatus.paused:
        buttons.add(_IconAction(icon: Icons.play_arrow_rounded, tooltip: 'Resume', onTap: () => service.resume(task.id)));
        buttons.add(_IconAction(icon: Icons.close_rounded, tooltip: 'Remove', onTap: () => service.remove(task.id)));
      case DownloadStatus.pending:
        buttons.add(_IconAction(icon: Icons.close_rounded, tooltip: 'Remove', onTap: () => service.remove(task.id)));
      case DownloadStatus.completed:
        buttons.add(_IconAction(icon: Icons.delete_outline_rounded, tooltip: 'Remove from history', onTap: () => service.remove(task.id)));
      case DownloadStatus.failed:
        buttons.add(_TextAction(label: 'Retry', onTap: () => service.retry(task.id)));
        buttons.add(_IconAction(icon: Icons.delete_outline_rounded, tooltip: 'Remove', onTap: () => service.remove(task.id)));
    }
    return buttons;
  }
}

class _IconAction extends StatelessWidget {
  const _IconAction({required this.icon, required this.tooltip, required this.onTap});

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: IconButton(
        icon: Icon(icon, size: 18),
        tooltip: tooltip,
        onPressed: onTap,
        constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
      ),
    );
  }
}

class _TextAction extends StatelessWidget {
  const _TextAction({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          foregroundColor: theme.colorScheme.primary,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
      ),
    );
  }
}

String _relative(DateTime? date) {
  if (date == null) return '';
  final diff = DateTime.now().difference(date);
  if (diff.inSeconds < 60) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays < 30) return '${diff.inDays}d ago';
  return '${(diff.inDays / 30).floor()}mo ago';
}
