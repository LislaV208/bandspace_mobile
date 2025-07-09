import 'dart:io';

import 'package:equatable/equatable.dart';

import 'package:bandspace_mobile/core/utils/value_wrapper.dart';

/// Status procesu tworzenia utworu
enum SongCreateStatus {
  initial,
  fileSelected,
  detailsUpdated,
  creating,
  uploadProgress,
  success,
  error,
}

/// Stan procesu tworzenia utworu
class SongCreateState extends Equatable {
  final SongCreateStatus status;
  final int currentStep;

  // Dane z Step 1 - wyb�r pliku
  final File? selectedFile;
  final String? fileName;

  // Dane z Step 2 - szczeg�By utworu
  final String songTitle;
  final String songDescription;

  // Stan uploadu
  final double uploadProgress;

  // ObsBuga bBd�w
  final String? errorMessage;

  const SongCreateState({
    this.status = SongCreateStatus.initial,
    this.currentStep = 0,
    this.selectedFile,
    this.fileName,
    this.songTitle = '',
    this.songDescription = '',
    this.uploadProgress = 0.0,
    this.errorMessage,
  });

  SongCreateState copyWith({
    SongCreateStatus? status,
    int? currentStep,
    Value<File?>? selectedFile,
    Value<String?>? fileName,
    String? songTitle,
    String? songDescription,
    double? uploadProgress,
    Value<String?>? errorMessage,
  }) {
    return SongCreateState(
      status: status ?? this.status,
      currentStep: currentStep ?? this.currentStep,
      selectedFile: selectedFile != null
          ? selectedFile.value
          : this.selectedFile,
      fileName: fileName != null ? fileName.value : this.fileName,
      songTitle: songTitle ?? this.songTitle,
      songDescription: songDescription ?? this.songDescription,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      errorMessage: errorMessage != null
          ? errorMessage.value
          : this.errorMessage,
    );
  }

  /// Czy mo|na przej[ do nastpnego kroku
  bool get canGoToNextStep {
    switch (currentStep) {
      case 0:
        return selectedFile != null;
      case 1:
        return songTitle.isNotEmpty;
      default:
        return false;
    }
  }

  /// Czy mo|na utworzy utw�r
  bool get canCreateSong {
    return selectedFile != null &&
        songTitle.isNotEmpty &&
        status != SongCreateStatus.creating;
  }

  /// Czy jest w trakcie tworzenia
  bool get isCreating {
    return status == SongCreateStatus.creating ||
        status == SongCreateStatus.uploadProgress;
  }

  @override
  List<Object?> get props => [
    status,
    currentStep,
    selectedFile,
    fileName,
    songTitle,
    songDescription,
    uploadProgress,
    errorMessage,
  ];
}
