import 'package:bandspace_mobile/core/models/song_detail.dart';
import 'package:bandspace_mobile/core/models/song_file.dart';

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

/// Stan ekranu szczegółów utworu
class SongDetailState {
  final SongDetailStatus status;
  final SongDetail? songDetail;
  final List<SongFile> files;
  final String? errorMessage;
  final FileOperationStatus fileOperationStatus;
  final String? fileOperationError;
  final bool isUpdatingSong;

  const SongDetailState({
    this.status = SongDetailStatus.initial,
    this.songDetail,
    this.files = const [],
    this.errorMessage,
    this.fileOperationStatus = FileOperationStatus.idle,
    this.fileOperationError,
    this.isUpdatingSong = false,
  });

  SongDetailState copyWith({
    SongDetailStatus? status,
    SongDetail? songDetail,
    List<SongFile>? files,
    String? errorMessage,
    FileOperationStatus? fileOperationStatus,
    String? fileOperationError,
    bool? isUpdatingSong,
  }) {
    return SongDetailState(
      status: status ?? this.status,
      songDetail: songDetail ?? this.songDetail,
      files: files ?? this.files,
      errorMessage: errorMessage,
      fileOperationStatus: fileOperationStatus ?? this.fileOperationStatus,
      fileOperationError: fileOperationError,
      isUpdatingSong: isUpdatingSong ?? this.isUpdatingSong,
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
        other.isUpdatingSong == isUpdatingSong;
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
}