import 'package:just_audio/just_audio.dart';

/// Wrapper nad AudioPlayer z just_audio.
/// Enkapsuluje playback primitives i zarządza lifecycle AudioPlayer instance.
class AudioPlayerService {
  final AudioPlayer _audioPlayer;

  AudioPlayerService(this._audioPlayer);

  // Streams
  Stream<Duration> get positionStream => _audioPlayer.positionStream;

  Stream<Duration> get bufferedPositionStream =>
      _audioPlayer.bufferedPositionStream;

  Stream<Duration?> get durationStream => _audioPlayer.durationStream;

  Stream<PlayerState> get playerStateStream => _audioPlayer.playerStateStream;

  // Properties
  List<IndexedAudioSource> get sequence => _audioPlayer.sequence;

  Duration get position => _audioPlayer.position;

  int? get currentIndex => _audioPlayer.currentIndex;

  // Playback control
  Future<void> play() => _audioPlayer.play();

  Future<void> pause() => _audioPlayer.pause();

  Future<void> stop() => _audioPlayer.stop();

  Future<void> seek(Duration position, {int? index}) =>
      _audioPlayer.seek(position, index: index);

  Future<void> seekToNext() => _audioPlayer.seekToNext();

  Future<void> seekToPrevious() => _audioPlayer.seekToPrevious();

  Future<void> setLoopMode(LoopMode mode) => _audioPlayer.setLoopMode(mode);

  Future<void> setAudioSources(List<AudioSource> sources) async {
    if (sources.isEmpty) {
      return;
    }
    await _audioPlayer.setAudioSources(sources);
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}
