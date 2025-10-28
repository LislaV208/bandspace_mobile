import 'package:flutter/material.dart';

import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:bandspace_mobile/shared/utils/formatters.dart';
import 'package:bandspace_mobile/shared/models/version.dart';

class TrackVersionsPlayerWidget extends StatelessWidget {
  final List<Version> versions;
  final Version? currentVersion;
  final bool isPlaying;
  final bool isSeeking;
  final Duration currentPosition;
  final Duration? seekPosition;
  final Duration totalDuration;
  final VoidCallback? onPlayPause;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final ValueChanged<double>? onSeekStart;
  final ValueChanged<double>? onSeekUpdate;
  final ValueChanged<double>? onSeekEnd;

  const TrackVersionsPlayerWidget({
    super.key,
    required this.versions,
    this.currentVersion,
    this.isPlaying = false,
    this.isSeeking = false,
    this.currentPosition = Duration.zero,
    this.seekPosition,
    this.totalDuration = Duration.zero,
    this.onPlayPause,
    this.onPrevious,
    this.onNext,
    this.onSeekStart,
    this.onSeekUpdate,
    this.onSeekEnd,
  });

  String _getVersionNumberText() {
    if (currentVersion == null) {
      return 'Wersja utworu';
    }

    final currentIndex = versions.indexWhere((v) => v.id == currentVersion!.id);
    if (currentIndex == -1) {
      return 'Wersja utworu';
    }

    final versionNumber = versions.length - currentIndex;
    return 'Wersja $versionNumber';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (currentVersion != null) ...[
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(context).dividerColor,
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    LucideIcons.music,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentVersion!.file?.filename ?? 'Nieznany plik',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getVersionNumberText(),
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Column(
              children: [
                // Progress bar z takim samym stylem jak w TrackPlayer
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 4.0,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 6.0,
                    ),
                    activeTrackColor: Theme.of(context).colorScheme.secondary,
                    inactiveTrackColor: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHigh,
                    thumbColor: Theme.of(context).colorScheme.secondary,
                  ),
                  child: Slider(
                    value: totalDuration.inMilliseconds > 0
                        ? ((isSeeking && seekPosition != null
                                      ? seekPosition!.inMilliseconds
                                      : currentPosition.inMilliseconds) /
                                  totalDuration.inMilliseconds)
                              .clamp(0.0, 1.0)
                        : 0.0,
                    onChangeStart: (value) {
                      onSeekStart?.call(value);
                    },
                    onChanged: (value) {
                      onSeekUpdate?.call(value);
                    },
                    onChangeEnd: (value) {
                      onSeekEnd?.call(value);
                    },
                  ),
                ),

                const SizedBox(height: 4),

                // Time labels
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        Formatters.formatDuration(
                          isSeeking && seekPosition != null
                              ? seekPosition!
                              : currentPosition,
                        ),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        Formatters.formatDuration(totalDuration),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: onPrevious,
                      icon: const Icon(
                        LucideIcons.skipBack,
                      ),
                    ),
                    const SizedBox(width: 16),

                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: onPlayPause,
                        icon: Icon(
                          isPlaying ? LucideIcons.pause : LucideIcons.play,
                          size: 28,
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),
                    IconButton(
                      onPressed: onNext,
                      icon: const Icon(
                        LucideIcons.skipForward,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ] else
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                'Wybierz wersję do odtworzenia',
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
