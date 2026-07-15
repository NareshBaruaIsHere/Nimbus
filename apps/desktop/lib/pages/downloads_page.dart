import 'package:flutter/material.dart';

import '../models/download_task.dart';
import '../widgets/download_tile.dart';
import '../widgets/empty_state.dart';
import '../widgets/page_header.dart';
import '../app/navigation.dart';
import '../app/theme.dart';

class DownloadsPage extends StatelessWidget {
  const DownloadsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final service = context.downloads;

    return ListenableBuilder(
      listenable: service,
      builder: (context, _) {
        final active = service.all.where((t) => t.status == DownloadStatus.active).toList();
        final queued = service.all.where((t) => t.status == DownloadStatus.pending).toList();
        final paused = service.all.where((t) => t.status == DownloadStatus.paused).toList();
        final total = active.length + queued.length + paused.length;

        return Padding(
          padding: const EdgeInsets.fromLTRB(28, 24, 28, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PageHeader(
                title: 'Downloads',
                subtitle: total == 0
                    ? 'No active downloads'
                    : '$total item${total > 1 ? 's' : ''} · ${active.length} active · ${queued.length} queued',
              ),
              const SizedBox(height: 20),
              const AddDownloadBar(),
              const SizedBox(height: 24),
              Expanded(
                child: total == 0
                    ? EmptyState(
                        icon: Icons.download_outlined,
                        title: 'Nothing downloading yet',
                        description: 'Paste a URL above to add your first download.',
                      )
                    : ListView(
                        children: [
                          if (active.isNotEmpty) ...[
                            _SectionLabel('In progress', active.length, theme),
                            const SizedBox(height: 12),
                            ...active.map((t) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: DownloadTile(task: t),
                                )),
                          ],
                          if (paused.isNotEmpty) ...[
                            if (active.isNotEmpty) const SizedBox(height: 8),
                            _SectionLabel('Paused', paused.length, theme),
                            const SizedBox(height: 12),
                            ...paused.map((t) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: DownloadTile(task: t),
                                )),
                          ],
                          if (queued.isNotEmpty) ...[
                            if (active.isNotEmpty || paused.isNotEmpty) const SizedBox(height: 8),
                            _SectionLabel('Queued', queued.length, theme),
                            const SizedBox(height: 12),
                            ...queued.map((t) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: DownloadTile(task: t),
                                )),
                          ],
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text, this.count, this.theme);

  final String text;
  final int count;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(text.toUpperCase(), style: theme.textTheme.labelMedium?.copyWith(fontSize: 11, letterSpacing: 0.6)),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(count.toString(), style: theme.textTheme.bodySmall?.copyWith(fontSize: 11)),
        ),
      ],
    );
  }
}

class AddDownloadBar extends StatefulWidget {
  const AddDownloadBar({super.key});

  @override
  State<AddDownloadBar> createState() => _AddDownloadBarState();
}

class _AddDownloadBarState extends State<AddDownloadBar> {
  final _controller = TextEditingController();
  DownloadCategory _category = DownloadCategory.other;
  final _focus = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text;
    if (text.trim().isEmpty) return;
    context.downloads.addDownload(text, category: _category);
    _controller.clear();
    _focus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focus,
                onSubmitted: (_) => _submit(),
                decoration: InputDecoration(
                  hintText: 'Paste a URL (HTTP, HTTPS or magnet)',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
                ),
                style: theme.textTheme.bodyLarge,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              height: 42,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                border: Border.all(color: theme.dividerColor),
                borderRadius: BorderRadius.circular(NimbusRadius.small),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<DownloadCategory>(
                  value: _category,
                  items: DownloadCategory.values
                      .map((c) => DropdownMenuItem(value: c, child: Text(c.label)))
                      .toList(),
                  onChanged: (value) => setState(() => _category = value ?? DownloadCategory.other),
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ),
            const SizedBox(width: 12),
            FilledButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}
