import 'dart:io';

import 'package:equatable/equatable.dart';

import 'package:bandspace_mobile/features/track_versions/models/add_version_data.dart';
import 'package:bandspace_mobile/shared/models/version.dart';

sealed class AddTrackVersionState extends Equatable {
  const AddTrackVersionState();

  @override
  List<Object?> get props => [];
}

/// Stan początkowy - czeka na wybór pliku
class AddTrackVersionInitial extends AddTrackVersionState {
  const AddTrackVersionInitial();
}

/// Trwa wybieranie pliku
class AddTrackVersionSelecting extends AddTrackVersionState {
  const AddTrackVersionSelecting();
}

/// Plik został wybrany - przejście do metadanych
class AddTrackVersionFileSelected extends AddTrackVersionState {
  final File file;
  final String fileName;
  final AddVersionData metadata;

  const AddTrackVersionFileSelected({
    required this.file,
    required this.fileName,
    required this.metadata,
  });

  @override
  List<Object?> get props => [file, fileName, metadata];
}

/// Metadane zostały uzupełnione - gotowy do uploadu
class AddTrackVersionReadyToUpload extends AddTrackVersionState {
  final File file;
  final String fileName;
  final AddVersionData metadata;

  const AddTrackVersionReadyToUpload({
    required this.file,
    required this.fileName,
    required this.metadata,
  });

  @override
  List<Object?> get props => [file, fileName, metadata];
}

/// Trwa upload
class AddTrackVersionUploading extends AddTrackVersionState {
  final double progress;
  final File file;
  final String fileName;
  final AddVersionData metadata;

  const AddTrackVersionUploading({
    required this.progress,
    required this.file,
    required this.fileName,
    required this.metadata,
  });

  @override
  List<Object?> get props => [progress, file, fileName, metadata];
}

/// Upload zakończony sukcesem
class AddTrackVersionSuccess extends AddTrackVersionState {
  final Version newVersion;

  const AddTrackVersionSuccess(this.newVersion);

  @override
  List<Object?> get props => [newVersion];
}

/// Błąd w dowolnym kroku
class AddTrackVersionFailure extends AddTrackVersionState {
  final String message;
  final File? file;
  final String? fileName;
  final AddVersionData? metadata;

  const AddTrackVersionFailure(
    this.message, {
    this.file,
    this.fileName,
    this.metadata,
  });

  @override
  List<Object?> get props => [message, file, fileName, metadata];
}