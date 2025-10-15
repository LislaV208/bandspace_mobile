import 'dart:developer';
import 'dart:io';

import 'package:just_audio/just_audio.dart';

/// Wrapper nad AudioPlayer z just_audio.
/// Enkapsuluje playback primitives i zarządza lifecycle AudioPlayer instance.
class AudioPlayerService {
  final AudioPlayer _audioPlayer;

  AudioPlayerService(this._audioPlayer) {
    // iOS optimization: Nie czekaj na pełny buffer przed rozpoczęciem playback
    // Redukuje initial load time dla AVPlayer
    if (Platform.isIOS) {
      _audioPlayer.setAutomaticallyWaitsToMinimizeStalling(false);
      log(
        'AudioPlayerService: iOS detected - set automaticallyWaitsToMinimizeStalling to false',
        name: 'AudioPlayerService',
      );
    }
  }

  // Streams
  Stream<Duration> get positionStream => _audioPlayer.positionStream;

  Stream<Duration> get bufferedPositionStream =>
      _audioPlayer.bufferedPositionStream;

  Stream<Duration?> get durationStream => _audioPlayer.durationStream;

  Stream<PlayerState> get playerStateStream => _audioPlayer.playerStateStream;

  Stream<int?> get currentIndexStream => _audioPlayer.currentIndexStream;

  // Properties
  List<IndexedAudioSource> get sequence => _audioPlayer.sequence;

  Duration get position => _audioPlayer.position;

  int? get currentIndex => _audioPlayer.currentIndex;

  // Playback control
  Future<void> play() => _audioPlayer.play();

  Future<void> pause() => _audioPlayer.pause();

  Future<void> stop() => _audioPlayer.stop();

  Future<void> seek(Duration position, {int? index}) async {
    log(
      'seek: BEFORE _audioPlayer.seek() - position=$position, index=$index',
      name: 'AudioPlayerService',
    );

    final startTime = DateTime.now();
    await _audioPlayer.seek(position, index: index);
    final duration = DateTime.now().difference(startTime);

    log(
      'seek: AFTER _audioPlayer.seek() - took ${duration.inMilliseconds}ms',
      name: 'AudioPlayerService',
    );
  }

  Future<void> seekToNext() => _audioPlayer.seekToNext();

  Future<void> seekToPrevious() => _audioPlayer.seekToPrevious();

  Future<void> setLoopMode(LoopMode mode) => _audioPlayer.setLoopMode(mode);

  Future<void> setAudioSources(List<AudioSource> sources) async {
    if (sources.isEmpty) {
      return;
    }

    log(
      'setAudioSources: BEFORE _audioPlayer.setAudioSources() - sources count: ${sources.length}, preload: false',
      name: 'AudioPlayerService',
    );

    final startTime = DateTime.now();
    // preload: false - opóźnia ładowanie audio sources do momentu play()
    // Zapobiega blokowaniu main thread podczas inicjalizacji (szczególnie na iOS AVPlayer)
    await _audioPlayer.setAudioSources(sources, preload: false);
    final duration = DateTime.now().difference(startTime);

    log(
      'setAudioSources: AFTER _audioPlayer.setAudioSources() - took ${duration.inMilliseconds}ms',
      name: 'AudioPlayerService',
    );
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}
