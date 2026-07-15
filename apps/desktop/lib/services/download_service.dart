import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/download_task.dart';
import 'settings_service.dart';
import 'storage.dart';

const String _apiBase = 'http://127.0.0.1:4578';

class DownloadService extends ChangeNotifier {
  DownloadService(this._settings);

  final SettingsService _settings;
  final List<DownloadTask> _tasks = [];
  final Map<String, double> _baseSpeeds = {};
  final Random _random = Random();

  final StreamController<DownloadTask> _completedController =
      StreamController<DownloadTask>.broadcast();
  Stream<DownloadTask> get onCompleted => _completedController.stream;

  Timer? _timer;
  String _connectionStatus = 'Disconnected';
  String get connectionStatus => _connectionStatus;

  List<DownloadTask> get all => List.unmodifiable(_tasks);

  List<DownloadTask> get active {
    return _tasks.where((t) => t.status == DownloadStatus.active || t.status == DownloadStatus.pending).toList();
  }

  List<DownloadTask> get history {
    return _tasks.where((t) => t.status.isTerminal).toList()
      ..sort((a, b) => (b.completedAt ?? b.createdAt).compareTo(a.completedAt ?? a.createdAt));
  }

  int get activeCount => _tasks.where((t) => t.status == DownloadStatus.active).length;

  void init() {
    _load();
    if (_tasks.isEmpty) _seedSamples();
    _startTimer();
    _checkConnection();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 500), (_) => _tick());
  }

  void _tick() {
    final maxConcurrent = _settings.settings.maxConcurrent;
    var running = _tasks.where((t) => t.status == DownloadStatus.active).length;

    // Promote queued downloads while concurrency slots are available.
    for (final task in _tasks.where((t) => t.status == DownloadStatus.pending)) {
      if (running >= maxConcurrent) break;
      _promote(task);
      running++;
    }

    var changed = false;
    final dt = 0.5;
    for (final task in _tasks.where((t) => t.status == DownloadStatus.active)) {
      final base = _baseSpeeds[task.id] ?? _assignBaseSpeed(task);
      final jitter = 0.75 + _random.nextDouble() * 0.5;
      final speed = base * jitter;
      task.speedBytesPerSec = speed;
      task.downloadedBytes = min(task.downloadedBytes + speed * dt, task.totalBytes);
      changed = true;

      if (task.downloadedBytes >= task.totalBytes) {
        task.downloadedBytes = task.totalBytes;
        task.speedBytesPerSec = 0;
        task.status = DownloadStatus.completed;
        task.completedAt = DateTime.now();
        final dir = _settings.settings.directoryFor(task.category);
        final sep = dir.contains('\\') ? '\\' : '/';
        task.downloadPath = dir.endsWith(sep) ? '$dir${task.name}' : '$dir$sep${task.name}';
        _baseSpeeds.remove(task.id);
        _completedController.add(task);
        if (_settings.settings.notifications) {
          _notify('Download complete', task.name);
        }
      }
    }

    if (changed) {
      _schedulePersist();
      notifyListeners();
    }
  }

  double _assignBaseSpeed(DownloadTask task) {
    final base = (1.5 + _random.nextDouble() * 9) * 1000 * 1000; // 1.5 - 10.5 MB/s
    _baseSpeeds[task.id] = base;
    return base;
  }

  void _promote(DownloadTask task) {
    task.status = DownloadStatus.active;
    _assignBaseSpeed(task);
    if (task.totalBytes <= 0) task.totalBytes = _estimateSize(task);
  }

  double _estimateSize(DownloadTask task) {
    final seeds = <DownloadCategory, List<int>>{
      DownloadCategory.music: [4, 6, 8, 10, 15, 20],
      DownloadCategory.video: [50, 100, 150, 200, 350, 500],
      DownloadCategory.documents: [2, 5, 8, 12, 20, 35],
      DownloadCategory.programs: [50, 150, 300, 600, 1200, 2500],
      DownloadCategory.other: [5, 10, 25, 50, 100, 200],
    };
    final pool = seeds[task.category] ?? seeds[DownloadCategory.other]!;
    final mb = pool[_random.nextInt(pool.length)];
    return mb * 1000 * 1000;
  }

  Future<void> addDownload(String url, {DownloadCategory? category}) async {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return;

    final name = _deriveName(trimmed);
    final cat = category ?? inferCategory(trimmed, name);
    final task = DownloadTask(
      id: _newId(),
      name: name,
      url: trimmed,
      category: cat,
      status: DownloadStatus.pending,
    );
    _tasks.insert(0, task);
    _schedulePersist();
    notifyListeners();
    _dispatchToBackend(trimmed, cat);
  }

  String _deriveName(String url) {
    final lower = url.toLowerCase();
    if (lower.contains('youtube.com') || lower.contains('youtu.be') || lower.contains('music.youtube.com')) {
      if (lower.contains('music.youtube.com') || lower.contains('&list=') || lower.contains('?list=')) {
        return 'youtube-music-${_newId().substring(0, 6)}.mp3';
      }
      return 'youtube-video-${_newId().substring(0, 6)}.mp4';
    }
    final cleaned = url.split('?').first;
    final segments = cleaned.split('/').where((s) => s.isNotEmpty).toList();
    final last = segments.isNotEmpty ? segments.last : cleaned;
    final hasExt = RegExp(r'\.\w{1,5}$').hasMatch(last);
    if (last.isEmpty || last.contains(':') || (!hasExt && last.length < 6)) {
      if (hasExt) return last;
      return 'download-${_newId().substring(0, 6)}';
    }
    return last;
  }

  Future<void> _dispatchToBackend(String url, DownloadCategory category) async {
    try {
      await http.post(
        Uri.parse('$_apiBase/download'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'url': url,
          'category': category.name,
          'dir': _settings.settings.directoryFor(category),
        }),
      );
    } catch (_) {
      // Backend is optional; local simulation continues regardless.
    }
  }

  void pause(String id) {
    final task = _find(id);
    if (task != null && task.status == DownloadStatus.active) {
      task.status = DownloadStatus.paused;
      task.speedBytesPerSec = 0;
      _baseSpeeds.remove(id);
      _schedulePersist();
      notifyListeners();
    }
  }

  void resume(String id) {
    final task = _find(id);
    if (task != null && task.status == DownloadStatus.paused) {
      task.status = DownloadStatus.pending;
      _schedulePersist();
      notifyListeners();
    }
  }

  void retry(String id) {
    final task = _find(id);
    if (task != null && task.status == DownloadStatus.failed) {
      task.status = DownloadStatus.pending;
      task.errorMessage = null;
      task.downloadedBytes = 0;
      _schedulePersist();
      notifyListeners();
    }
  }

  void remove(String id) {
    _tasks.removeWhere((t) => t.id == id);
    _baseSpeeds.remove(id);
    _schedulePersist();
    notifyListeners();
  }

  void clearHistory() {
    _tasks.removeWhere((t) => t.status.isTerminal);
    _schedulePersist();
    notifyListeners();
  }

  DownloadTask? _find(String id) {
    for (final task in _tasks) {
      if (task.id == id) return task;
    }
    return null;
  }

  String _newId() =>
      '${DateTime.now().microsecondsSinceEpoch}-${(_random.nextInt(1 << 31)).toRadixString(16)}';

  void _notify(String title, String body) {
    // Desktop notifications are surfaced via the OS where supported. The local
    // simulation keeps this lightweight; a real build would call a notification
    // plugin here.
    debugPrint('[notify] $title: $body');
  }

  Future<void> _checkConnection() async {
    try {
      final response = await http.get(Uri.parse('$_apiBase/status')).timeout(const Duration(seconds: 2));
      _connectionStatus = response.statusCode == 200 ? 'Connected' : 'Disconnected';
    } catch (_) {
      _connectionStatus = 'Disconnected';
    }
    notifyListeners();
  }

  void refreshConnection() => _checkConnection();

  // ---- Persistence ----

  void _load() {
    final file = tasksFile();
    if (!file.existsSync()) return;
    try {
      final list = jsonDecode(file.readAsStringSync()) as List<dynamic>;
      _tasks.clear();
      for (final item in list) {
        final task = DownloadTask.fromJson(item as Map<String, dynamic>);
        // Resume anything that was mid-flight into a queued state.
        if (task.status == DownloadStatus.active) task.status = DownloadStatus.pending;
        _tasks.add(task);
      }
    } catch (_) {
      // Ignore unreadable history.
    }
  }

  Timer? _persistTimer;
  void _schedulePersist() {
    _persistTimer?.cancel();
    _persistTimer = Timer(const Duration(seconds: 1), _persist);
  }

  Future<void> _persist() async {
    final file = tasksFile();
    final json = _tasks.map((t) => t.toJson()).toList();
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(json));
  }

  void _seedSamples() {
    final now = DateTime.now();
    final sep = _settings.settings.downloadDir.contains('\\') ? '\\' : '/';
    String joinDir(DownloadCategory cat) {
      final dir = _settings.settings.directoryFor(cat);
      return dir.endsWith(sep) ? dir : '$dir$sep';
    }
    _tasks.addAll([
      DownloadTask(
        id: _newId(),
        name: 'ubuntu-24.04-desktop-amd64.iso',
        url: 'https://releases.ubuntu.com/24.04/ubuntu-24.04-desktop-amd64.iso',
        category: DownloadCategory.programs,
        totalBytes: 5.1 * 1000 * 1000 * 1000,
        downloadedBytes: 2.3 * 1000 * 1000 * 1000,
        status: DownloadStatus.active,
      ),
      DownloadTask(
        id: _newId(),
        name: 'introduction-to-rust.pdf',
        url: 'https://example.com/books/introduction-to-rust.pdf',
        category: DownloadCategory.documents,
        totalBytes: 12.4 * 1000 * 1000,
        status: DownloadStatus.pending,
      ),
      DownloadTask(
        id: _newId(),
        name: 'big-buck-bunny-1080p.mp4',
        url: 'https://example.com/video/big-buck-bunny-1080p.mp4',
        category: DownloadCategory.video,
        totalBytes: 680 * 1000 * 1000,
        downloadedBytes: 680 * 1000 * 1000,
        status: DownloadStatus.completed,
        completedAt: now.subtract(const Duration(hours: 2)),
        downloadPath: '${joinDir(DownloadCategory.video)}big-buck-bunny-1080p.mp4',
      ),
      DownloadTask(
        id: _newId(),
        name: 'album-flavors-of-jazz.zip',
        url: 'https://example.com/music/album-flavors-of-jazz.zip',
        category: DownloadCategory.music,
        totalBytes: 142 * 1000 * 1000,
        downloadedBytes: 142 * 1000 * 1000,
        status: DownloadStatus.completed,
        completedAt: now.subtract(const Duration(days: 1)),
        downloadPath: '${joinDir(DownloadCategory.music)}album-flavors-of-jazz.zip',
      ),
      DownloadTask(
        id: _newId(),
        name: 'setup-wizard-v2.exe',
        url: 'https://example.com/install/setup-wizard-v2.exe',
        category: DownloadCategory.programs,
        totalBytes: 88 * 1000 * 1000,
        downloadedBytes: 51 * 1000 * 1000,
        status: DownloadStatus.failed,
        errorMessage: 'Connection reset by peer',
        completedAt: now.subtract(const Duration(days: 1, hours: 5)),
      ),
    ]);
    _schedulePersist();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _persistTimer?.cancel();
    _completedController.close();
    super.dispose();
  }
}
