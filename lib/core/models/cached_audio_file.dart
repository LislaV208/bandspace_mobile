import 'package:equatable/equatable.dart';

/// Status cache'owania pliku audio
enum CacheStatus {
  /// Plik nie jest cache'owany
  notCached,
  /// Plik jest w trakcie pobierania
  downloading,
  /// Plik jest cache'owany i dostępny offline
  cached,
  /// Błąd podczas pobierania
  error,
  /// Plik jest w kolejce do pobrania
  queued,
}

/// Rozszerzenie enum CacheStatus o helper methods
extension CacheStatusExtension on CacheStatus {
  /// Czy plik jest dostępny offline
  bool get isAvailableOffline => this == CacheStatus.cached;

  /// Czy plik jest w trakcie pobierania
  bool get isDownloading => this == CacheStatus.downloading;

  /// Czy można rozpocząć pobieranie
  bool get canStartDownload => this == CacheStatus.notCached || this == CacheStatus.error;

  /// Opis statusu w języku polskim
  String get displayName {
    switch (this) {
      case CacheStatus.notCached:
        return 'Nie pobrano';
      case CacheStatus.downloading:
        return 'Pobieranie...';
      case CacheStatus.cached:
        return 'Pobrano';
      case CacheStatus.error:
        return 'Błąd pobierania';
      case CacheStatus.queued:
        return 'W kolejce';
    }
  }
}

/// Model cache'owanego pliku audio
class CachedAudioFile extends Equatable {
  /// ID pliku z bazy danych
  final int fileId;
  
  /// ID utworu, do którego należy plik
  final int songId;
  
  /// Nazwa pliku
  final String filename;
  
  /// Klucz pliku w storage
  final String fileKey;
  
  /// Typ MIME pliku
  final String mimeType;
  
  /// Rozmiar pliku w bajtach
  final int size;
  
  /// Lokalna ścieżka do cache'owanego pliku
  final String? localPath;
  
  /// Status cache'owania
  final CacheStatus status;
  
  /// Data pobrania
  final DateTime? downloadedAt;
  
  /// Data ostatniego dostępu
  final DateTime? lastAccessedAt;
  
  /// Liczba odtworzeń
  final int playCount;
  
  /// Suma kontrolna pliku (do weryfikacji integralności)
  final String? checksum;

  const CachedAudioFile({
    required this.fileId,
    required this.songId,
    required this.filename,
    required this.fileKey,
    required this.mimeType,
    required this.size,
    this.localPath,
    this.status = CacheStatus.notCached,
    this.downloadedAt,
    this.lastAccessedAt,
    this.playCount = 0,
    this.checksum,
  });

  /// Tworzy nową instancję z zmodyfikowanymi wartościami
  CachedAudioFile copyWith({
    int? fileId,
    int? songId,
    String? filename,
    String? fileKey,
    String? mimeType,
    int? size,
    String? localPath,
    CacheStatus? status,
    DateTime? downloadedAt,
    DateTime? lastAccessedAt,
    int? playCount,
    String? checksum,
  }) {
    return CachedAudioFile(
      fileId: fileId ?? this.fileId,
      songId: songId ?? this.songId,
      filename: filename ?? this.filename,
      fileKey: fileKey ?? this.fileKey,
      mimeType: mimeType ?? this.mimeType,
      size: size ?? this.size,
      localPath: localPath ?? this.localPath,
      status: status ?? this.status,
      downloadedAt: downloadedAt ?? this.downloadedAt,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
      playCount: playCount ?? this.playCount,
      checksum: checksum ?? this.checksum,
    );
  }

  /// Konwertuje z JSON
  factory CachedAudioFile.fromJson(Map<String, dynamic> json) {
    return CachedAudioFile(
      fileId: json['file_id'] as int,
      songId: json['song_id'] as int,
      filename: json['filename'] as String,
      fileKey: json['file_key'] as String,
      mimeType: json['mime_type'] as String,
      size: json['size'] as int,
      localPath: json['local_path'] as String?,
      status: CacheStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => CacheStatus.notCached,
      ),
      downloadedAt: json['downloaded_at'] != null 
          ? DateTime.parse(json['downloaded_at']) 
          : null,
      lastAccessedAt: json['last_accessed_at'] != null 
          ? DateTime.parse(json['last_accessed_at']) 
          : null,
      playCount: json['play_count'] as int? ?? 0,
      checksum: json['checksum'] as String?,
    );
  }

  /// Konwertuje do JSON
  Map<String, dynamic> toJson() {
    return {
      'file_id': fileId,
      'song_id': songId,
      'filename': filename,
      'file_key': fileKey,
      'mime_type': mimeType,
      'size': size,
      'local_path': localPath,
      'status': status.name,
      'downloaded_at': downloadedAt?.toIso8601String(),
      'last_accessed_at': lastAccessedAt?.toIso8601String(),
      'play_count': playCount,
      'checksum': checksum,
    };
  }

  /// Zwraca sformatowany rozmiar pliku
  String get formattedSize {
    if (size == 0) return '0 B';

    const suffixes = ['B', 'KB', 'MB', 'GB'];
    var i = 0;
    double sizeInBytes = size.toDouble();

    while (sizeInBytes >= 1024 && i < suffixes.length - 1) {
      sizeInBytes /= 1024;
      i++;
    }

    return '${sizeInBytes.toStringAsFixed(i == 0 ? 0 : 1)} ${suffixes[i]}';
  }

  /// Zwraca rozszerzenie pliku
  String get fileExtension {
    final lastDot = filename.lastIndexOf('.');
    if (lastDot == -1) return '';
    return filename.substring(lastDot + 1).toLowerCase();
  }

  /// Czy plik jest dostępny offline
  bool get isAvailableOffline => status.isAvailableOffline;

  /// Czy plik jest w trakcie pobierania
  bool get isDownloading => status.isDownloading;

  /// Czy można rozpocząć pobieranie
  bool get canStartDownload => status.canStartDownload;

  @override
  List<Object?> get props => [
        fileId,
        songId,
        filename,
        fileKey,
        mimeType,
        size,
        localPath,
        status,
        downloadedAt,
        lastAccessedAt,
        playCount,
        checksum,
      ];
}

/// Model postępu pobierania pliku
class DownloadProgress extends Equatable {
  /// ID pliku
  final int fileId;
  
  /// Liczba pobranych bajtów
  final int downloadedBytes;
  
  /// Całkowity rozmiar pliku w bajtach
  final int totalBytes;
  
  /// Procent postępu (0.0 - 1.0)
  final double progress;
  
  /// Prędkość pobierania w bajtach na sekundę
  final double? downloadSpeed;
  
  /// Szacowany czas pozostały w sekundach
  final int? estimatedTimeRemaining;
  
  /// Status pobierania
  final DownloadStatus status;
  
  /// Opcjonalny komunikat błędu
  final String? errorMessage;

  const DownloadProgress({
    required this.fileId,
    required this.downloadedBytes,
    required this.totalBytes,
    required this.progress,
    this.downloadSpeed,
    this.estimatedTimeRemaining,
    this.status = DownloadStatus.downloading,
    this.errorMessage,
  });

  /// Tworzy nową instancję z zmodyfikowanymi wartościami
  DownloadProgress copyWith({
    int? fileId,
    int? downloadedBytes,
    int? totalBytes,
    double? progress,
    double? downloadSpeed,
    int? estimatedTimeRemaining,
    DownloadStatus? status,
    String? errorMessage,
  }) {
    return DownloadProgress(
      fileId: fileId ?? this.fileId,
      downloadedBytes: downloadedBytes ?? this.downloadedBytes,
      totalBytes: totalBytes ?? this.totalBytes,
      progress: progress ?? this.progress,
      downloadSpeed: downloadSpeed ?? this.downloadSpeed,
      estimatedTimeRemaining: estimatedTimeRemaining ?? this.estimatedTimeRemaining,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  /// Tworzy instancję rozpoczynającą pobieranie
  factory DownloadProgress.started(int fileId, int totalBytes) {
    return DownloadProgress(
      fileId: fileId,
      downloadedBytes: 0,
      totalBytes: totalBytes,
      progress: 0.0,
      status: DownloadStatus.downloading,
    );
  }

  /// Tworzy instancję zakończoną sukcesem
  factory DownloadProgress.completed(int fileId, int totalBytes) {
    return DownloadProgress(
      fileId: fileId,
      downloadedBytes: totalBytes,
      totalBytes: totalBytes,
      progress: 1.0,
      status: DownloadStatus.completed,
    );
  }

  /// Tworzy instancję z błędem
  factory DownloadProgress.error(int fileId, String errorMessage) {
    return DownloadProgress(
      fileId: fileId,
      downloadedBytes: 0,
      totalBytes: 0,
      progress: 0.0,
      status: DownloadStatus.error,
      errorMessage: errorMessage,
    );
  }

  /// Czy pobieranie jest zakończone sukcesem
  bool get isCompleted => status == DownloadStatus.completed;

  /// Czy pobieranie jest w trakcie
  bool get isDownloading => status == DownloadStatus.downloading;

  /// Czy pobieranie zostało anulowane
  bool get isCancelled => status == DownloadStatus.cancelled;

  /// Czy wystąpił błąd
  bool get hasError => status == DownloadStatus.error;

  /// Procent postępu jako string
  String get progressPercentage => '${(progress * 100).toStringAsFixed(0)}%';

  /// Sformatowana prędkość pobierania
  String get formattedSpeed {
    if (downloadSpeed == null) return '--';
    
    if (downloadSpeed! < 1024) {
      return '${downloadSpeed!.toStringAsFixed(0)} B/s';
    } else if (downloadSpeed! < 1024 * 1024) {
      return '${(downloadSpeed! / 1024).toStringAsFixed(1)} KB/s';
    } else {
      return '${(downloadSpeed! / (1024 * 1024)).toStringAsFixed(1)} MB/s';
    }
  }

  /// Sformatowany czas pozostały
  String get formattedTimeRemaining {
    if (estimatedTimeRemaining == null) return '--';
    
    final minutes = estimatedTimeRemaining! ~/ 60;
    final seconds = estimatedTimeRemaining! % 60;
    
    if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  @override
  List<Object?> get props => [
        fileId,
        downloadedBytes,
        totalBytes,
        progress,
        downloadSpeed,
        estimatedTimeRemaining,
        status,
        errorMessage,
      ];
}

/// Status pobierania pliku
enum DownloadStatus {
  /// Pobieranie w trakcie
  downloading,
  /// Pobieranie zakończone sukcesem
  completed,
  /// Pobieranie anulowane
  cancelled,
  /// Błąd podczas pobierania
  error,
  /// Pobieranie wstrzymane
  paused,
}

/// Rozszerzenie enum DownloadStatus o helper methods
extension DownloadStatusExtension on DownloadStatus {
  /// Opis statusu w języku polskim
  String get displayName {
    switch (this) {
      case DownloadStatus.downloading:
        return 'Pobieranie...';
      case DownloadStatus.completed:
        return 'Pobrano';
      case DownloadStatus.cancelled:
        return 'Anulowano';
      case DownloadStatus.error:
        return 'Błąd';
      case DownloadStatus.paused:
        return 'Wstrzymano';
    }
  }
}