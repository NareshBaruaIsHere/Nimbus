import 'dart:io';

/// Resolves the directory used by Nimbus to store configuration and state.
Directory appDataDirectory() {
  final sep = Platform.pathSeparator;
  String base;

  if (Platform.isWindows) {
    final appData = Platform.environment['APPDATA'];
    base = appData != null ? '$appData${sep}Nimbus' : Directory.systemTemp.path;
  } else if (Platform.isMacOS) {
    final home = Platform.environment['HOME'] ?? Directory.systemTemp.path;
    base = '$home${sep}Library${sep}Application Support${sep}Nimbus';
  } else {
    final home = Platform.environment['HOME'] ?? Directory.systemTemp.path;
    base = '$home$sep.local${sep}share${sep}Nimbus';
  }

  final dir = Directory(base);
  if (!dir.existsSync()) {
    dir.createSync(recursive: true);
  }
  return dir;
}

File settingsFile() => File('${appDataDirectory().path}${Platform.pathSeparator}settings.json');

File tasksFile() => File('${appDataDirectory().path}${Platform.pathSeparator}downloads.json');

/// Best-effort default download location for the current user.
String defaultDownloadDir() {
  final sep = Platform.pathSeparator;
  final home = Platform.environment['HOME'] ??
      Platform.environment['USERPROFILE'] ??
      Directory.systemTemp.path;
  final candidates = [
    '$home${sep}Downloads',
    '$home${sep}downloads',
    home,
  ];
  for (final path in candidates) {
    final dir = Directory(path);
    if (dir.existsSync()) return path;
  }
  return home;
}
