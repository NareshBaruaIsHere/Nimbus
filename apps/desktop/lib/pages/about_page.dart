import 'package:flutter/material.dart';

import '../services/settings_service.dart';
import '../services/storage.dart';
import '../widgets/page_header.dart';
import '../app/navigation.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageHeader(title: 'About', subtitle: 'Information about Nimbus.'),
          const SizedBox(height: 28),
          Center(
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(Icons.downloading_rounded, size: 40, color: Colors.white),
                ),
                const SizedBox(height: 18),
                Text('Nimbus', style: theme.textTheme.headlineMedium?.copyWith(fontSize: 26)),
                const SizedBox(height: 6),
                Text(
                  'Version $packageVersion (build $packageBuild)',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 14),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Text(
                    packageDescription,
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                children: [
                  _InfoRow(
                    icon: Icons.storage_outlined,
                    label: 'Configuration folder',
                    value: appDataDirectory().path,
                  ),
                  const Divider(),
                  ListenableBuilder(
                    listenable: context.downloads,
                    builder: (context, _) => _InfoRow(
                      icon: Icons.cloud_outlined,
                      label: 'Backend service',
                      value: '${context.downloads.connectionStatus} (port 4578)',
                    ),
                  ),
                  const Divider(),
                  _InfoRow(
                    icon: Icons.code_outlined,
                    label: 'Engine',
                    value: 'aria2 · Rust API',
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '© ${DateTime.now().year} Nimbus. Built with Flutter.',
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 6),
                InkWell(
                  onTap: () {},
                  child: Text.rich(
                    TextSpan(
                      text: 'Developer: ',
                      style: theme.textTheme.bodySmall,
                      children: [
                        TextSpan(
                          text: 'IFELSEGHOST',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const TextSpan(text: ' · '),
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: InkWell(
                            onTap: () {},
                            child: Icon(
                              Icons.link,
                              size: 13,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                        TextSpan(
                          text: ' github.com/NareshBaruaIsHere',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontSize: 11.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 12),
          SizedBox(
            width: 150,
            child: Text(label, style: theme.textTheme.bodyMedium),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontFamily: 'monospace',
                fontSize: 12.5,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
