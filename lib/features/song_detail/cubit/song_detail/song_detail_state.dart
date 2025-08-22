import 'package:equatable/equatable.dart';

import 'package:bandspace_mobile/shared/models/song.dart';
import 'package:bandspace_mobile/shared/models/song_download_url.dart';

abstract class SongDetailState extends Equatable {
  final List<Song> songs;
  final Song currentSong;

  const SongDetailState(this.songs, this.currentSong);

  // === METODY NAWIGACYJNE ===
  
  /// Sprawdza czy można przejść do następnego utworu
  bool get canGoNext {
    final currentIndex = _getCurrentSongIndex();
    return currentIndex < songs.length - 1;
  }
  
  /// Sprawdza czy można przejść do poprzedniego utworu
  bool get canGoPrevious {
    final currentIndex = _getCurrentSongIndex();
    return currentIndex > 0;
  }
  
  /// Zwraca aktualny indeks utworu w liście wszystkich utworów
  int get currentSongIndex => _getCurrentSongIndex();
  
  /// Sprawdza czy aktualny utwór ma plik audio (tylko jeśli URL-e są załadowane)
  bool get currentSongHasFile {
    // Jeśli to SongDetailLoadUrlsSuccess, sprawdź URL-e
    if (this is SongDetailLoadUrlsSuccess) {
      final urlsState = this as SongDetailLoadUrlsSuccess;
      return urlsState.downloadUrls.songUrls.any(
        (item) => item.songId == currentSong.id && item.url.isNotEmpty,
      );
    }
    // Dla innych stanów nie wiemy jeszcze czy ma plik
    return false;
  }
  
  /// Sprawdza czy informacja o plikach jest dostępna
  bool get hasFileInfo => this is SongDetailLoadUrlsSuccess;

  /// Prywatna metoda do znajdowania indeksu aktualnego utworu
  int _getCurrentSongIndex() {
    return songs.indexWhere((song) => song.id == currentSong.id);
  }

  @override
  List<Object?> get props => [songs, currentSong];
}

class SongDetailInitial extends SongDetailState {
  const SongDetailInitial(super.songs, super.currentSong);
}

class SongDetailLoadUrls extends SongDetailState {
  const SongDetailLoadUrls(super.songs, super.currentSong);
}

class SongDetailLoadUrlsFailure extends SongDetailState {
  final String message;

  const SongDetailLoadUrlsFailure(
    super.songs,
    super.currentSong,
    this.message,
  );

  @override
  List<Object?> get props => [songs, currentSong, message];
}

class SongDetailLoadUrlsSuccess extends SongDetailState {
  final SongListDownloadUrls downloadUrls;

  const SongDetailLoadUrlsSuccess(
    super.songs,
    super.currentSong,
    this.downloadUrls,
  );

  @override
  List<Object?> get props => [songs, currentSong, downloadUrls];
}

class SongDetailReady extends SongDetailState {
  const SongDetailReady(super.songs, super.currentSong);
}
