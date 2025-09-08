import 'package:bandspace_mobile/shared/models/song.dart';
import 'package:equatable/equatable.dart';

/// Stan procesu edycji utworu
abstract class EditSongState extends Equatable {
  const EditSongState();

  @override
  List<Object?> get props => [];
}

/// Stan początkowy
class EditSongInitial extends EditSongState {
  const EditSongInitial();
}

/// Stan ładowania - trwa edycja utworu
class EditSongLoading extends EditSongState {
  const EditSongLoading();
}

/// Stan sukcesu - utwór został zaktualizowany
class EditSongSuccess extends EditSongState {
  final Song song;

  const EditSongSuccess(this.song);

  @override
  List<Object?> get props => [song];
}

/// Stan błędu - edycja nie powiodła się
class EditSongFailure extends EditSongState {
  final String message;

  const EditSongFailure({
    required this.message,
  });

  @override
  List<Object?> get props => [message];
}
