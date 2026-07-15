import 'dart:io';

import 'package:flutter/material.dart';

import 'download_task.dart';

class AppSettings {
  const AppSettings({
    required this.downloadDir,
    required this.categoryDirs,
    required this.maxConcurrent,
    required this.notifications,
    required this.launchOnStartup,
    required this.themeMode,
  });

  final String downloadDir;
  final Map<DownloadCategory, String> categoryDirs;
  final int maxConcurrent;
  final bool notifications;
  final bool launchOnStartup;
  final ThemeMode themeMode;

  static const int minConcurrent = 1;
  static const int maxConcurrentLimit = 16;

  static AppSettings defaults(String downloadDir) {
    return AppSettings(
      downloadDir: downloadDir,
      categoryDirs: {
        DownloadCategory.music: defaultCategoryPath(DownloadCategory.music, downloadDir),
        DownloadCategory.video: defaultCategoryPath(DownloadCategory.video, downloadDir),
        DownloadCategory.documents: defaultCategoryPath(DownloadCategory.documents, downloadDir),
        DownloadCategory.programs: defaultCategoryPath(DownloadCategory.programs, downloadDir),
        DownloadCategory.other: downloadDir,
      },
      maxConcurrent: 3,
      notifications: true,
      launchOnStartup: false,
      themeMode: ThemeMode.dark,
    );
  }

  static String defaultCategoryPath(DownloadCategory category, String base) {
    if (category == DownloadCategory.other) return base;
    return _join(base, category.label);
  }

  static String _join(String base, String name) {
    final sep = Platform.pathSeparator;
    return base.endsWith(sep) ? '$base$name' : '$base$sep$name';
  }

  String directoryFor(DownloadCategory category) {
    return categoryDirs[category] ?? downloadDir;
  }

  AppSettings copyWith({
    String? downloadDir,
    Map<DownloadCategory, String>? categoryDirs,
    int? maxConcurrent,
    bool? notifications,
    bool? launchOnStartup,
    ThemeMode? themeMode,
  }) {
    return AppSettings(
      downloadDir: downloadDir ?? this.downloadDir,
      categoryDirs: categoryDirs ?? this.categoryDirs,
      maxConcurrent: maxConcurrent ?? this.maxConcurrent,
      notifications: notifications ?? this.notifications,
      launchOnStartup: launchOnStartup ?? this.launchOnStartup,
      themeMode: themeMode ?? this.themeMode,
    );
  }

  Map<String, dynamic> toJson() => {
        'downloadDir': downloadDir,
        'categoryDirs': categoryDirs.map((k, v) => MapEntry(k.name, v)),
        'maxConcurrent': maxConcurrent,
        'notifications': notifications,
        'launchOnStartup': launchOnStartup,
        'themeMode': themeMode.name,
      };

  factory AppSettings.fromJson(Map<String, dynamic> json, String fallbackDir) {
    final defaults = AppSettings.defaults(fallbackDir);
    final rawDirs = json['categoryDirs'] as Map<String, dynamic>? ?? {};
    final categoryDirs = <DownloadCategory, String>{
      for (final category in DownloadCategory.values)
        category: rawDirs[category.name] as String? ?? defaults.directoryFor(category),
    };

    final themeName = json['themeMode'] as String? ?? 'dark';
    final themeMode = ThemeMode.values.firstWhere(
      (t) => t.name == themeName,
      orElse: () => ThemeMode.dark,
    );

    final concurrent = (json['maxConcurrent'] as num?)?.toInt() ?? defaults.maxConcurrent;

    return AppSettings(
      downloadDir: json['downloadDir'] as String? ?? defaults.downloadDir,
      categoryDirs: categoryDirs,
      maxConcurrent: concurrent.clamp(AppSettings.minConcurrent, AppSettings.maxConcurrentLimit),
      notifications: json['notifications'] as bool? ?? defaults.notifications,
      launchOnStartup: json['launchOnStartup'] as bool? ?? defaults.launchOnStartup,
      themeMode: themeMode,
    );
  }
}
