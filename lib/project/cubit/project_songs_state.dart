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
  final bool isOfflineMode;
  final bool isSyncing;

  const ProjectSongsState({
    this.status = ProjectSongsStatus.initial,
    this.songs = const [],
    this.errorMessage,
    this.isCreatingSong = false,
    this.isDeletingSong = false,
    this.isOfflineMode = false,
    this.isSyncing = false,
  });

  /// Metoda copyWith umożliwiająca tworzenie nowej instancji z wybranymi zmianami
  ProjectSongsState copyWith({
    ProjectSongsStatus? status,
    List<Song>? songs,
    String? errorMessage,
    bool? isCreatingSong,
    bool? isDeletingSong,
    bool? isOfflineMode,
    bool? isSyncing,
  }) {
    return ProjectSongsState(
      status: status ?? this.status,
      songs: songs ?? this.songs,
      errorMessage: errorMessage,
      isCreatingSong: isCreatingSong ?? this.isCreatingSong,
      isDeletingSong: isDeletingSong ?? this.isDeletingSong,
      isOfflineMode: isOfflineMode ?? this.isOfflineMode,
      isSyncing: isSyncing ?? this.isSyncing,
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
        other.isDeletingSong == isDeletingSong &&
        other.isOfflineMode == isOfflineMode &&
        other.isSyncing == isSyncing;
  }

  @override
  int get hashCode {
    return Object.hash(status, songs, errorMessage, isCreatingSong, isDeletingSong, isOfflineMode, isSyncing);
  }
}