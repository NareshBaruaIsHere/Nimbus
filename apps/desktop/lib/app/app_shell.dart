import 'package:flutter/material.dart';

import 'navigation.dart';
import 'sidebar.dart';
import '../pages/about_page.dart';
import '../pages/downloads_page.dart';
import '../pages/history_page.dart';
import '../pages/settings_page.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  NavSection _selected = NavSection.downloads;

  Widget _pageFor(NavSection section) {
    switch (section) {
      case NavSection.downloads:
        return const DownloadsPage();
      case NavSection.history:
        return const HistoryPage();
      case NavSection.settings:
        return const SettingsPage();
      case NavSection.about:
        return const AboutPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Sidebar(
            selected: _selected,
            onSelect: (section) => setState(() => _selected = section),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              child: _pageFor(_selected),
            ),
          ),
        ],
      ),
    );
  }
}
