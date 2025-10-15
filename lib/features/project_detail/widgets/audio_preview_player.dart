import 'dart:io';

import 'package:flutter/material.dart';

import 'package:just_audio/just_audio.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:bandspace_mobile/core/utils/formatters.dart';

class AudioPreviewPlayer extends StatefulWidget {
  final File? audioFile;
  final VoidCallback? onRemoveFile;

  const AudioPreviewPlayer({
    super.key,
    this.audioFile,
    this.onRemoveFile,
  });

  @override
  State<AudioPreviewPlayer> createState() => _AudioPreviewPlayerState();
}

class _AudioPreviewPlayerState extends State<AudioPreviewPlayer> {
  AudioPlayer? _player;
  bool _isPlaying = false;
  bool _isLoading = true;
  bool _hasError = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  @override
  void dispose() {
    _player?.dispose();
    super.dispose();
  }

  Future<void> _initializePlayer() async {
    // Jeśli nie ma pliku, nie inicjalizujemy odtwarzacza
    if (widget.audioFile == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      _player = AudioPlayer();
      await _player!.setFilePath(widget.audioFile!.path);

      _player!.playerStateStream.listen((state) {
        if (mounted) {
          setState(() {
            _isPlaying = state.playing;
          });
        }
      });

      _player!.durationStream.listen((duration) {
        if (mounted && duration != null) {
          setState(() {
            _duration = duration;
          });
        }
      });

      _player!.positionStream.listen((position) {
        if (mounted) {
          setState(() {
            _position = position;
          });
        }
      });

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  void _togglePlayPause() async {
    // Jeśli nie ma pliku, nie można odtwarzać
    if (widget.audioFile == null || _player == null) return;

    try {
      if (_isPlaying) {
        await _player!.pause();
      } else {
        await _player!.play();
      }
    } catch (e) {
      setState(() {
        _hasError = true;
      });
    }
  }

  String _getFileName() {
    return widget.audioFile != null
        ? widget.audioFile!.path.split('/').last
        : 'Brak pliku';
  }

  String _getFileSize() {
    if (widget.audioFile == null) return '';
    final bytes = widget.audioFile!.lengthSync();
    final mb = bytes / (1024 * 1024);
    return '${mb.toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // File info
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  widget.audioFile != null
                      ? LucideIcons.fileAudio
                      : Icons.music_off,
                  size: 24,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getFileName(),
                      style: Theme.of(context).textTheme.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (widget.audioFile != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        _getFileSize(),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
              if (widget.onRemoveFile != null)
                IconButton(
                  onPressed: widget.onRemoveFile,
                  icon: Icon(
                    LucideIcons.x,
                    size: 18,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  tooltip: 'Usuń plik',
                ),
            ],
          ),

          const SizedBox(height: 16),

          // Player controls
          if (widget.audioFile == null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Brak pliku audio',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
                  ),
                ],
              ),
            )
          else if (_hasError)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    LucideIcons.triangle,
                    size: 16,
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Nie można odtworzyć pliku',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                  ),
                ],
              ),
            )
          else if (_isLoading)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Ładowanie...',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            )
          else
            Column(
              children: [
                // Play button and duration
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: IconButton(
                        onPressed: _togglePlayPause,
                        icon: Icon(
                          _isPlaying ? LucideIcons.pause : LucideIcons.play,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                Formatters.formatDuration(_position),
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                              Text(
                                Formatters.formatDuration(_duration),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Progress bar
                          Stack(
                            children: [
                              // Tło progress bara
                              Container(
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.surfaceContainerHigh,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              // Progress
                              if (_duration.inMilliseconds > 0)
                                FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor:
                                      (_position.inMilliseconds /
                                              _duration.inMilliseconds)
                                          .clamp(0.0, 1.0),
                                  child: Container(
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }
}
