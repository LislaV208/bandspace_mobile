import 'package:bandspace_mobile/core/models/song.dart';

/// Stan dla zarządzania utworami projektu
enum ProjectSongsStatus { initial, loading, loaded, error }

/// Klasa stanu dla Cubit zarządzającego utworami projektu
class ProjectSongsState {
  final ProjectSongsStatus status;
  final List<Song> songs;
  final String? errorMessage;
  final bool isCreatingSong;
  final bool isDeletingSong;

  const ProjectSongsState({
    this.status = ProjectSongsStatus.initial,
    this.songs = const [],
    this.errorMessage,
    this.isCreatingSong = false,
    this.isDeletingSong = false,
  });

  /// Metoda copyWith umożliwiająca tworzenie nowej instancji z wybranymi zmianami
  ProjectSongsState copyWith({
    ProjectSongsStatus? status,
    List<Song>? songs,
    String? errorMessage,
    bool? isCreatingSong,
    bool? isDeletingSong,
  }) {
    return ProjectSongsState(
      status: status ?? this.status,
      songs: songs ?? this.songs,
      errorMessage: errorMessage,
      isCreatingSong: isCreatingSong ?? this.isCreatingSong,
      isDeletingSong: isDeletingSong ?? this.isDeletingSong,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProjectSongsState &&
        other.status == status &&
        other.songs == songs &&
        other.errorMessage == errorMessage &&
        other.isCreatingSong == isCreatingSong &&
        other.isDeletingSong == isDeletingSong;
  }

  @override
  int get hashCode {
    return Object.hash(status, songs, errorMessage, isCreatingSong, isDeletingSong);
  }
}