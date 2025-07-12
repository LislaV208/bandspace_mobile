import 'dart:async';
import 'dart:developer';

import 'package:just_audio/just_audio.dart';

import 'package:bandspace_mobile/core/utils/value_wrapper.dart';
import 'audio_player_cubit.dart';
import 'audio_player_state.dart';
import 'playlist_audio_player_state.dart';

/// Cubit zarządzający stanem odtwarzacza audio z obsługą playlist.
/// Rozszerza AudioPlayerCubit o funkcjonalności playlist wykorzystując natywne API just_audio.
class PlaylistAudioPlayerCubit extends AudioPlayerCubit {
  StreamSubscription? _currentIndexSubscription;
  StreamSubscription? _sequenceStateSubscription;

  PlaylistAudioPlayerCubit() : super() {
    // Konwertuj początkowy stan na PlaylistAudioPlayerState
    emit(PlaylistAudioPlayerState(
      status: state.status,
      currentUrl: state.currentUrl,
      currentPosition: state.currentPosition,
      totalDuration: state.totalDuration,
      errorMessage: state.errorMessage,
      isReady: state.isReady,
      bufferedPosition: state.bufferedPosition,
      isSeeking: state.isSeeking,
      seekPosition: state.seekPosition,
    ));
    
    _listenToPlaylistEvents();
  }

  @override
  PlaylistAudioPlayerState get state => super.state as PlaylistAudioPlayerState;

  /// Nasłuchuje na zdarzenia specyficzne dla playlist
  void _listenToPlaylistEvents() {
    // Nasłuchiwanie na zmiany indeksu w playlist
    _currentIndexSubscription = audioPlayer.currentIndexStream.listen((index) {
      if (state.hasPlaylist) {
        emit(state.copyWith(currentIndex: Value(index)));
        
        // Aktualizuj currentUrl na podstawie nowego indeksu
        if (index != null && index < state.playlist.length) {
          emit(state.copyWith(currentUrl: Value(state.playlist[index])));
        }
      }
    });

    // Nasłuchiwanie na zmiany sekwencji (playlist)
    _sequenceStateSubscription = audioPlayer.sequenceStateStream.listen((sequenceState) {
      emit(state.copyWith(
        isShuffleEnabled: sequenceState.shuffleModeEnabled,
        loopMode: audioPlayer.loopMode,
      ));
    });
  }

  /// Override emit aby zawsze emitować PlaylistAudioPlayerState
  @override
  void emit(covariant PlaylistAudioPlayerState state) {
    super.emit(state);
  }

  /// Override metod bazowych aby emitować PlaylistAudioPlayerState
  @override
  Future<void> loadUrl(String url, {bool playWhenReady = false}) async {
    // Wywołaj bazową implementację, ale najpierw wyczyść playlist
    await clearPlaylist();
    await super.loadUrl(url, playWhenReady: playWhenReady);
  }

  // =======================================================
  // ===          PUBLICZNE API PLAYLIST                 ===
  // =======================================================

  /// Ładuje playlist z podanych URL-i
  Future<void> loadPlaylist(
    List<String> urls, {
    int? initialIndex,
    bool playWhenReady = false,
  }) async {
    if (urls.isEmpty) {
      await clearPlaylist();
      return;
    }

    try {
      // Tworzenie AudioSource dla każdego URL
      final audioSources = urls
          .map((url) => AudioSource.uri(Uri.parse(url)))
          .toList();

      // Aktualizuj stan z nową playlist
      emit(state.copyWith(
        status: PlayerStatus.loading,
        playlist: urls,
        currentIndex: Value(initialIndex ?? 0),
        hasPlaylist: true,
        errorMessage: Value(null),
        isReady: false,
      ));

      // Załaduj playlist w just_audio
      await audioPlayer.setAudioSources(
        audioSources,
        initialIndex: initialIndex ?? 0,
        initialPosition: Duration.zero,
      );

      if (playWhenReady) {
        await audioPlayer.play();
      }
    } catch (e) {
      emit(state.copyWith(
        status: PlayerStatus.error,
        errorMessage: Value(e.toString()),
        isReady: false,
      ));
    }
  }

  /// Przechodzi do następnego utworu w playlist
  Future<void> playNext() async {
    if (!state.hasPlaylist || !state.canPlayNext) return;
    
    try {
      await audioPlayer.seekToNext();
    } catch (e) {
      log('Error playing next track: $e');
    }
  }

  /// Przechodzi do poprzedniego utworu w playlist
  Future<void> playPrevious() async {
    if (!state.hasPlaylist || !state.canPlayPrevious) return;
    
    try {
      await audioPlayer.seekToPrevious();
    } catch (e) {
      log('Error playing previous track: $e');
    }
  }

  /// Przechodzi do konkretnego utworu w playlist
  Future<void> playTrackAt(int index) async {
    if (!state.hasPlaylist || index < 0 || index >= state.playlist.length) {
      return;
    }
    
    try {
      await audioPlayer.seek(Duration.zero, index: index);
    } catch (e) {
      log('Error playing track at index $index: $e');
    }
  }

  /// Włącza/wyłącza tryb shuffle
  Future<void> setShuffleMode(bool enabled) async {
    try {
      await audioPlayer.setShuffleModeEnabled(enabled);
      emit(state.copyWith(isShuffleEnabled: enabled));
    } catch (e) {
      log('Error setting shuffle mode: $e');
    }
  }

  /// Ustawia tryb zapętlenia
  Future<void> setLoopMode(LoopMode loopMode) async {
    try {
      await audioPlayer.setLoopMode(loopMode);
      emit(state.copyWith(loopMode: loopMode));
    } catch (e) {
      log('Error setting loop mode: $e');
    }
  }

  /// Dodaje nowy utwór do playlist
  Future<void> addToPlaylist(String url, {int? atIndex}) async {
    if (!state.hasPlaylist) return;
    
    try {
      final audioSource = AudioSource.uri(Uri.parse(url));
      
      if (atIndex != null) {
        await audioPlayer.insertAudioSource(atIndex, audioSource);
      } else {
        await audioPlayer.addAudioSource(audioSource);
      }
      
      // Aktualizuj lokalną listę URL-i
      final newPlaylist = List<String>.from(state.playlist);
      if (atIndex != null && atIndex >= 0 && atIndex <= newPlaylist.length) {
        newPlaylist.insert(atIndex, url);
      } else {
        newPlaylist.add(url);
      }
      
      emit(state.copyWith(playlist: newPlaylist));
    } catch (e) {
      log('Error adding to playlist: $e');
    }
  }

  /// Usuwa utwór z playlist
  Future<void> removeFromPlaylist(int index) async {
    if (!state.hasPlaylist || index < 0 || index >= state.playlist.length) {
      return;
    }
    
    try {
      await audioPlayer.removeAudioSourceAt(index);
      
      // Aktualizuj lokalną listę URL-i
      final newPlaylist = List<String>.from(state.playlist);
      newPlaylist.removeAt(index);
      
      if (newPlaylist.isEmpty) {
        await clearPlaylist();
      } else {
        emit(state.copyWith(playlist: newPlaylist));
      }
    } catch (e) {
      log('Error removing from playlist: $e');
    }
  }

  /// Czyści playlist i powraca do trybu pojedynczego pliku
  Future<void> clearPlaylist() async {
    await audioPlayer.stop();
    emit(state.copyWith(
      playlist: [],
      currentIndex: Value(null),
      hasPlaylist: false,
      isShuffleEnabled: false,
      loopMode: LoopMode.off,
    ));
  }

  @override
  Future<void> close() {
    _currentIndexSubscription?.cancel();
    _sequenceStateSubscription?.cancel();
    return super.close();
  }
}