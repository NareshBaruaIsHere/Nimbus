import 'dart:math';

enum DownloadStatus {
  active,
  pending,
  paused,
  completed,
  failed;

  bool get isActive => this == DownloadStatus.active;
  bool get isTerminal => this == DownloadStatus.completed || this == DownloadStatus.failed;
}

enum DownloadCategory {
  music,
  video,
  documents,
  programs,
  other;

  String get label {
    switch (this) {
      case DownloadCategory.music:
        return 'Music';
      case DownloadCategory.video:
        return 'Video';
      case DownloadCategory.documents:
        return 'Documents';
      case DownloadCategory.programs:
        return 'Programs';
      case DownloadCategory.other:
        return 'Other';
    }
  }
}

class DownloadTask {
  DownloadTask({
    required this.id,
    required this.name,
    required this.url,
    this.category = DownloadCategory.other,
    this.totalBytes = 0,
    this.downloadedBytes = 0,
    this.speedBytesPerSec = 0,
    this.status = DownloadStatus.pending,
    DateTime? createdAt,
    this.completedAt,
    this.errorMessage,
  }) : createdAt = createdAt ?? DateTime.now();

  final String id;
  final String name;
  final String url;
  final DownloadCategory category;

  double totalBytes;
  double downloadedBytes;
  double speedBytesPerSec;
  DownloadStatus status;

  final DateTime createdAt;
  DateTime? completedAt;
  String? errorMessage;

  double get progress {
    if (totalBytes <= 0) return 0;
    return (downloadedBytes / totalBytes).clamp(0, 1);
  }

  DownloadTask copyWith({
    String? name,
    DownloadCategory? category,
    double? totalBytes,
    double? downloadedBytes,
    double? speedBytesPerSec,
    DownloadStatus? status,
    DateTime? completedAt,
    String? errorMessage,
  }) {
    return DownloadTask(
      id: id,
      url: url,
      name: name ?? this.name,
      category: category ?? this.category,
      totalBytes: totalBytes ?? this.totalBytes,
      downloadedBytes: downloadedBytes ?? this.downloadedBytes,
      speedBytesPerSec: speedBytesPerSec ?? this.speedBytesPerSec,
      status: status ?? this.status,
      createdAt: createdAt,
      completedAt: completedAt ?? this.completedAt,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'url': url,
        'category': category.name,
        'totalBytes': totalBytes,
        'downloadedBytes': downloadedBytes,
        'speedBytesPerSec': speedBytesPerSec,
        'status': status.name,
        'createdAt': createdAt.toIso8601String(),
        'completedAt': completedAt?.toIso8601String(),
        'errorMessage': errorMessage,
      };

  factory DownloadTask.fromJson(Map<String, dynamic> json) {
    return DownloadTask(
      id: json['id'] as String,
      name: json['name'] as String,
      url: json['url'] as String,
      category: DownloadCategory.values.firstWhere(
        (c) => c.name == json['category'],
        orElse: () => DownloadCategory.other,
      ),
      totalBytes: (json['totalBytes'] as num?)?.toDouble() ?? 0,
      downloadedBytes: (json['downloadedBytes'] as num?)?.toDouble() ?? 0,
      speedBytesPerSec: (json['speedBytesPerSec'] as num?)?.toDouble() ?? 0,
      status: DownloadStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => DownloadStatus.failed,
      ),
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.tryParse(json['completedAt'] as String),
      errorMessage: json['errorMessage'] as String?,
    );
  }
}

String formatBytes(double bytes) {
  if (bytes <= 0) return '0 B';
  const units = ['B', 'KB', 'MB', 'GB', 'TB'];
  final i = (log(bytes) / ln10 / 3).floor().clamp(0, units.length - 1);
  final value = bytes / pow(1000, i);
  final formatted = value >= 100 || i == 0 ? value.toStringAsFixed(0) : value.toStringAsFixed(1);
  return '$formatted ${units[i]}';
}

String formatSpeed(double bytesPerSec) {
  if (bytesPerSec <= 0) return '—';
  return '${formatBytes(bytesPerSec)}/s';
}

DownloadCategory inferCategory(String url, String name) {
  final lower = '${name.toLowerCase()} ${url.toLowerCase()}';
  if (RegExp(r'\.(mp3|flac|wav|m4a|ogg|aac)$').hasMatch(lower) || lower.contains('music')) {
    return DownloadCategory.music;
  }
  if (RegExp(r'\.(mp4|mkv|mov|avi|webm|m4v)$').hasMatch(lower) || lower.contains('video')) {
    return DownloadCategory.video;
  }
  if (RegExp(r'\.(exe|msi|dmg|appimage|deb|rpm|apk)$').hasMatch(lower) || lower.contains('install')) {
    return DownloadCategory.programs;
  }
  if (RegExp(r'\.(pdf|docx?|xlsx?|pptx?|txt|epub|csv)$').hasMatch(lower)) {
    return DownloadCategory.documents;
  }
  return DownloadCategory.other;
}
