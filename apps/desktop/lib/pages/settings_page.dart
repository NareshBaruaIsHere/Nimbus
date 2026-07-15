import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

import '../models/download_task.dart';
import '../models/settings.dart';
import '../services/storage.dart';
import '../widgets/page_header.dart';
import '../app/navigation.dart';
import '../app/theme.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late double _concurrent;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _concurrent = context.settings.settings.maxConcurrent.toDouble();
  }

  Future<void> _pickDirectory(DownloadCategory? category) async {
    final path = await getDirectoryPath();
    if (path == null || !mounted) return;
    final settings = context.settings.settings;
    final updatedDirs = Map<DownloadCategory, String>.from(settings.categoryDirs);
    if (category == null) {
      await context.settings.update((s) => s.copyWith(
            downloadDir: path,
            categoryDirs: {
              for (final c in DownloadCategory.values)
                c: c == DownloadCategory.other ? path : AppSettings.defaultCategoryPath(c, path),
            },
          ));
    } else {
      updatedDirs[category] = path;
      await context.settings.update((s) => s.copyWith(categoryDirs: updatedDirs));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageHeader(title: 'Settings', subtitle: 'Configure storage, performance and appearance.'),
          const SizedBox(height: 22),
          Expanded(
            child: ListenableBuilder(
              listenable: context.settings,
              builder: (context, _) {
                final settings = context.settings.settings;
                return ListView(
                  children: [
                    _Section(
                      title: 'File Management',
                      description: 'Choose where downloads are saved by category.',
                      children: [
                        _PathRow(
                          label: 'Default download directory',
                          value: settings.downloadDir,
                          onBrowse: () => _pickDirectory(null),
                          onReset: () => _resetDownloadDir(),
                        ),
                        const Divider(),
                        for (final category in [
                          DownloadCategory.music,
                          DownloadCategory.video,
                          DownloadCategory.documents,
                          DownloadCategory.programs,
                        ])
                          Column(
                            children: [
                              _PathRow(
                                label: '${category.label} folder',
                                value: settings.directoryFor(category),
                                onBrowse: () => _pickDirectory(category),
                                onReset: () => _resetCategory(category),
                              ),
                              if (category != DownloadCategory.programs) const Divider(),
                            ],
                          ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _Section(
                      title: 'Performance',
                      description: 'Balance speed against system load.',
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Max concurrent downloads', style: theme.textTheme.bodyLarge),
                                  Text(
                                    settings.maxConcurrent.toString(),
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Slider(
                                value: _concurrent,
                                min: AppSettings.minConcurrent.toDouble(),
                                max: AppSettings.maxConcurrentLimit.toDouble(),
                                divisions: AppSettings.maxConcurrentLimit - AppSettings.minConcurrent,
                                label: _concurrent.round().toString(),
                                onChanged: (value) => setState(() => _concurrent = value),
                                onChangeEnd: (value) => context.settings.update(
                                  (s) => s.copyWith(maxConcurrent: value.round()),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _Section(
                      title: 'System',
                      description: 'Notifications and startup behaviour.',
                      children: [
                        _SwitchRow(
                          label: 'Desktop notifications',
                          description: 'Show a notification when a download finishes.',
                          value: settings.notifications,
                          onChanged: (v) => context.settings.update((s) => s.copyWith(notifications: v)),
                        ),
                        const Divider(),
                        _SwitchRow(
                          label: 'Launch on system startup',
                          description: 'Start Nimbus automatically when you sign in.',
                          value: settings.launchOnStartup,
                          onChanged: (v) => context.settings.update((s) => s.copyWith(launchOnStartup: v)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _Section(
                      title: 'Appearance',
                      description: 'Choose how Nimbus looks.',
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Theme', style: theme.textTheme.bodyLarge),
                              _ThemeSelector(
                                value: settings.themeMode,
                                onChanged: (mode) => context.settings.update((s) => s.copyWith(themeMode: mode)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _resetDownloadDir() async {
    await context.settings.update((s) => s.copyWith(
          downloadDir: defaultDownloadDir(),
          categoryDirs: {
            for (final c in DownloadCategory.values)
              c: c == DownloadCategory.other ? defaultDownloadDir() : AppSettings.defaultCategoryPath(c, defaultDownloadDir()),
          },
        ));
  }

  Future<void> _resetCategory(DownloadCategory category) async {
    final settings = context.settings.settings;
    final updatedDirs = Map<DownloadCategory, String>.from(settings.categoryDirs);
    updatedDirs[category] = AppSettings.defaultCategoryPath(category, settings.downloadDir);
    await context.settings.update((s) => s.copyWith(categoryDirs: updatedDirs));
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.description,
    required this.children,
  });

  final String title;
  final String description;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(description, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }
}

class _PathRow extends StatelessWidget {
  const _PathRow({
    required this.label,
    required this.value,
    required this.onBrowse,
    required this.onReset,
  });

  final String label;
  final String value;
  final VoidCallback onBrowse;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.bodyLarge),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(NimbusRadius.small),
                    border: Border.all(color: theme.dividerColor),
                  ),
                  child: Text(
                    value,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontFamily: 'monospace',
                      fontSize: 12.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          TextButton.icon(
            onPressed: onBrowse,
            icon: const Icon(Icons.folder_open_outlined, size: 18),
            label: const Text('Browse'),
          ),
          TextButton(
            onPressed: onReset,
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.label,
    required this.description,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String description;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.bodyLarge),
                const SizedBox(height: 2),
                Text(description, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _ThemeSelector extends StatelessWidget {
  const _ThemeSelector({required this.value, required this.onChanged});

  final ThemeMode value;
  final ValueChanged<ThemeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final options = [
      (ThemeMode.light, 'Light', Icons.light_mode_outlined),
      (ThemeMode.dark, 'Dark', Icons.dark_mode_outlined),
      (ThemeMode.system, 'System', Icons.brightness_auto_outlined),
    ];
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(NimbusRadius.small),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: options.map((option) {
          final selected = option.$1 == value;
          return Padding(
            padding: const EdgeInsets.only(right: 2),
            child: Material(
              color: selected ? theme.colorScheme.surface : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              child: InkWell(
                onTap: () => onChanged(option.$1),
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  child: Row(
                    children: [
                      Icon(
                        option.$3,
                        size: 16,
                        color: selected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        option.$2,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: selected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
