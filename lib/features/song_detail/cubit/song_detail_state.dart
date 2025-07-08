import 'package:bandspace_mobile/shared/models/song_detail.dart';
import 'package:bandspace_mobile/shared/models/song_file.dart';

/// Status stanu ekranu szczegółów utworu
enum SongDetailStatus {
  initial,
  loading,
  loaded,
  error,
}

/// Status operacji na plikach
enum FileOperationStatus {
  idle,
  loading,
  success,
  error,
}

/// Status uploadu pliku
enum FileUploadStatus {
  idle,
  picking,
  uploading,
  success,
  error,
}

/// Stan ekranu szczegółów utworu
class SongDetailState {
  final SongDetailStatus status;
  final SongDetail? songDetail;
  final List<SongFile> files;
  final String? errorMessage;
  final FileOperationStatus fileOperationStatus;
  final String? fileOperationError;
  final bool isUpdatingSong;
  final FileUploadStatus uploadStatus;
  final double uploadProgress;
  final String? uploadError;
  final bool isOfflineMode;
  final bool isSyncing;

  const SongDetailState({
    this.status = SongDetailStatus.initial,
    this.songDetail,
    this.files = const [],
    this.errorMessage,
    this.fileOperationStatus = FileOperationStatus.idle,
    this.fileOperationError,
    this.isUpdatingSong = false,
    this.uploadStatus = FileUploadStatus.idle,
    this.uploadProgress = 0.0,
    this.uploadError,
    this.isOfflineMode = false,
    this.isSyncing = false,
  });

  SongDetailState copyWith({
    SongDetailStatus? status,
    SongDetail? songDetail,
    List<SongFile>? files,
    String? errorMessage,
    FileOperationStatus? fileOperationStatus,
    String? fileOperationError,
    bool? isUpdatingSong,
    FileUploadStatus? uploadStatus,
    double? uploadProgress,
    String? uploadError,
    bool? isOfflineMode,
    bool? isSyncing,
  }) {
    return SongDetailState(
      status: status ?? this.status,
      songDetail: songDetail ?? this.songDetail,
      files: files ?? this.files,
      errorMessage: errorMessage,
      fileOperationStatus: fileOperationStatus ?? this.fileOperationStatus,
      fileOperationError: fileOperationError,
      isUpdatingSong: isUpdatingSong ?? this.isUpdatingSong,
      uploadStatus: uploadStatus ?? this.uploadStatus,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      uploadError: uploadError,
      isOfflineMode: isOfflineMode ?? this.isOfflineMode,
      isSyncing: isSyncing ?? this.isSyncing,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SongDetailState &&
        other.status == status &&
        other.songDetail == songDetail &&
        other.files == files &&
        other.errorMessage == errorMessage &&
        other.fileOperationStatus == fileOperationStatus &&
        other.fileOperationError == fileOperationError &&
        other.isUpdatingSong == isUpdatingSong &&
        other.uploadStatus == uploadStatus &&
        other.uploadProgress == uploadProgress &&
        other.uploadError == uploadError &&
        other.isOfflineMode == isOfflineMode &&
        other.isSyncing == isSyncing;
  }

  @override
  int get hashCode {
    return Object.hash(
      status,
      songDetail,
      files,
      errorMessage,
      fileOperationStatus,
      fileOperationError,
      isUpdatingSong,
      uploadStatus,
      uploadProgress,
      uploadError,
      isOfflineMode,
      isSyncing,
    );
  }

  /// Czy dane są w trakcie ładowania
  bool get isLoading => status == SongDetailStatus.loading;

  /// Czy wystąpił błąd
  bool get hasError => status == SongDetailStatus.error;

  /// Czy dane zostały załadowane
  bool get isLoaded => status == SongDetailStatus.loaded;

  /// Czy operacja na plikach jest w trakcie
  bool get isFileOperationInProgress => fileOperationStatus == FileOperationStatus.loading;

  /// Czy utwór ma pliki audio
  bool get hasAudioFiles => files.isNotEmpty;

  /// Czy upload jest w trakcie
  bool get isUploading => uploadStatus == FileUploadStatus.uploading;

  /// Czy wybieranie pliku jest w trakcie
  bool get isPicking => uploadStatus == FileUploadStatus.picking;

  /// Czy wystąpił błąd uploadu
  bool get hasUploadError => uploadStatus == FileUploadStatus.error;
}