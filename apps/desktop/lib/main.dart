import 'package:flutter/material.dart';

import 'app/app_shell.dart';
import 'app/navigation.dart';
import 'app/theme.dart';
import 'services/download_service.dart';
import 'services/settings_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final settings = SettingsService();
  final downloads = DownloadService(settings);
  downloads.init();

  runApp(NimbusApp(settings: settings, downloads: downloads));
}

class NimbusApp extends StatelessWidget {
  const NimbusApp({required this.settings, required this.downloads, super.key});

  final SettingsService settings;
  final DownloadService downloads;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) {
        return MaterialApp(
          title: 'Nimbus Downloader',
          debugShowCheckedModeBanner: false,
          theme: NimbusTheme.light,
          darkTheme: NimbusTheme.dark,
          themeMode: settings.settings.themeMode,
          home: AppServices(
            settings: settings,
            downloads: downloads,
            child: const AppShell(),
          ),
        );
      },
    );
  }
}
