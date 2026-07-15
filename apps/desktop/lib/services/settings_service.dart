import 'dart:convert';

import 'package:flutter/material.dart';

import '../models/settings.dart';
import 'storage.dart';

class SettingsService extends ChangeNotifier {
  SettingsService() {
    _settings = _load();
  }

  late AppSettings _settings;
  AppSettings get settings => _settings;

  AppSettings _load() {
    final file = settingsFile();
    if (file.existsSync()) {
      try {
        final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
        return AppSettings.fromJson(json, defaultDownloadDir());
      } catch (_) {
        // Corrupted config: fall back to defaults.
      }
    }
    return AppSettings.defaults(defaultDownloadDir());
  }

  Future<void> _persist() async {
    final file = settingsFile();
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(_settings.toJson()));
  }

  Future<void> update(AppSettings Function(AppSettings current) mutate) async {
    _settings = mutate(_settings);
    notifyListeners();
    await _persist();
  }
}

const String packageName = 'Nimbus';
const String packageVersion = '1.0.0';
const String packageBuild = '1';
const String packageDescription = 'A focused, lightweight download manager.';
