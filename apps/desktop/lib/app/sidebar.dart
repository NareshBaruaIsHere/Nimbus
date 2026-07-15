import 'package:flutter/material.dart';

import 'navigation.dart';
import 'theme.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({
    required this.selected,
    required this.onSelect,
    super.key,
  });

  final NavSection selected;
  final ValueChanged<NavSection> onSelect;

  static const width = 232.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sections = NavSection.values;

    return Container(
      width: width,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(right: BorderSide(color: theme.dividerColor)),
      ),
      child: Column(
        children: [
          _Brand(theme: theme),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              itemCount: sections.length,
              itemBuilder: (context, index) {
                final section = sections[index];
                return _NavItem(
                  section: section,
                  selected: section == selected,
                  onSelect: onSelect,
                );
              },
            ),
          ),
          const _ConnectionStatus(),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.downloading_rounded, size: 18, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Text(
            'Nimbus',
            style: theme.textTheme.titleLarge?.copyWith(
              fontSize: 18,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.section,
    required this.selected,
    required this.onSelect,
  });

  final NavSection section;
  final bool selected;
  final ValueChanged<NavSection> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fg = selected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: selected ? theme.colorScheme.surfaceContainerHighest : Colors.transparent,
        borderRadius: BorderRadius.circular(NimbusRadius.small),
        child: InkWell(
          onTap: () => onSelect(section),
          borderRadius: BorderRadius.circular(NimbusRadius.small),
          hoverColor: selected
              ? Colors.transparent
              : theme.brightness == Brightness.dark
                  ? Colors.white.withValues(alpha: 0.04)
                  : Colors.black.withValues(alpha: 0.03),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Icon(
                  selected ? section.selectedIcon : section.icon,
                  size: 20,
                  color: fg,
                ),
                const SizedBox(width: 12),
                Text(
                  section.label,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: selected ? theme.colorScheme.onSurface : theme.colorScheme.onSurfaceVariant,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ConnectionStatus extends StatelessWidget {
  const _ConnectionStatus();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListenableBuilder(
      listenable: AppServices.of(context).downloads,
      builder: (context, _) {
        final service = AppServices.of(context).downloads;
        final connected = service.connectionStatus == 'Connected';
        final dotColor = connected ? NimbusColors.success : NimbusColors.failed;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: dotColor,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Backend ${service.connectionStatus.toLowerCase()}',
                  style: theme.textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
