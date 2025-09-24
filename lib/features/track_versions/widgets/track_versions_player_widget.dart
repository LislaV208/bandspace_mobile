import 'package:flutter/material.dart';

import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:bandspace_mobile/core/utils/formatters.dart';
import 'package:bandspace_mobile/shared/models/version.dart';

class TrackVersionsPlayerWidget extends StatelessWidget {
  final Version? currentVersion;
  final bool isPlaying;
  final Duration currentPosition;
  final Duration totalDuration;
  final VoidCallback? onPlayPause;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final ValueChanged<double>? onSeek;

  const TrackVersionsPlayerWidget({
    super.key,
    this.currentVersion,
    this.isPlaying = false,
    this.currentPosition = Duration.zero,
    this.totalDuration = Duration.zero,
    this.onPlayPause,
    this.onPrevious,
    this.onNext,
    this.onSeek,
  });

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
                        'Wersja utworu',
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
                Row(
                  children: [
                    Text(
                      Formatters.formatDuration(currentPosition),
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Expanded(
                      child: Slider(
                        value: totalDuration.inMilliseconds > 0
                            ? currentPosition.inMilliseconds /
                                  totalDuration.inMilliseconds
                            : 0.0,
                        onChanged: (value) {
                          if (totalDuration.inMilliseconds > 0 &&
                              onSeek != null) {
                            onSeek!(value);
                          }
                        },
                      ),
                    ),
                    Text(
                      Formatters.formatDuration(totalDuration),
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
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
