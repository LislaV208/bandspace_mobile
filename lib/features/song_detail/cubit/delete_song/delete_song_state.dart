import 'package:equatable/equatable.dart';

/// Stan procesu usuwania utworu
abstract class DeleteSongState extends Equatable {
  const DeleteSongState();

  @override
  List<Object?> get props => [];
}

/// Stan początkowy
class DeleteSongInitial extends DeleteSongState {
  const DeleteSongInitial();
}

/// Stan ładowania - trwa usuwanie utworu
class DeleteSongLoading extends DeleteSongState {
  const DeleteSongLoading();
}

/// Stan sukcesu - utwór został usunięty
class DeleteSongSuccess extends DeleteSongState {
  const DeleteSongSuccess();
}

/// Stan błędu - usuwanie nie powiodło się
class DeleteSongFailure extends DeleteSongState {
  final String message;

  const DeleteSongFailure({
    required this.message,
  });

  @override
  List<Object?> get props => [message];
}
