import 'package:flutter/material.dart';

import '../services/download_service.dart';
import '../services/settings_service.dart';

enum NavSection {
  downloads,
  history,
  settings,
  about;

  String get label {
    switch (this) {
      case NavSection.downloads:
        return 'Downloads';
      case NavSection.history:
        return 'History';
      case NavSection.settings:
        return 'Settings';
      case NavSection.about:
        return 'About';
    }
  }

  IconData get icon {
    switch (this) {
      case NavSection.downloads:
        return Icons.download_outlined;
      case NavSection.history:
        return Icons.history_outlined;
      case NavSection.settings:
        return Icons.settings_outlined;
      case NavSection.about:
        return Icons.info_outline;
    }
  }

  IconData get selectedIcon {
    switch (this) {
      case NavSection.downloads:
        return Icons.download_rounded;
      case NavSection.history:
        return Icons.history_rounded;
      case NavSection.settings:
        return Icons.settings_rounded;
      case NavSection.about:
        return Icons.info_rounded;
    }
  }
}

/// Shared application state, exposed to the widget tree.
class AppServices extends InheritedWidget {
  const AppServices({
    super.key,
    required super.child,
    required this.settings,
    required this.downloads,
  });

  final SettingsService settings;
  final DownloadService downloads;

  static AppServices of(BuildContext context) {
    final result = context.dependOnInheritedWidgetOfExactType<AppServices>();
    assert(result != null, 'AppServices not found in widget tree');
    return result!;
  }

  @override
  bool updateShouldNotify(AppServices oldWidget) => false;
}

extension AppServicesExtension on BuildContext {
  SettingsService get settings => AppServices.of(this).settings;
  DownloadService get downloads => AppServices.of(this).downloads;
}
