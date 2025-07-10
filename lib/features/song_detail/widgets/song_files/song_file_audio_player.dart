import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:bandspace_mobile/shared/cubits/audio_player/audio_player_cubit.dart';
import 'package:bandspace_mobile/shared/cubits/audio_player/audio_player_state.dart';
import 'package:bandspace_mobile/shared/models/song_file.dart';
import 'package:bandspace_mobile/shared/utils/duration_format_utils.dart';

class SongFileAudioPlayer extends StatelessWidget {
  final SongFile currentFile;

  const SongFileAudioPlayer({
    super.key,
    required this.currentFile,
  });

  @override
  Widget build(BuildContext context) {
    // final progress = totalDuration.inMilliseconds > 0
    //     ? currentPosition.inMilliseconds / totalDuration.inMilliseconds
    //     : 0.0;

    // final progress = 0.0;

    return BlocBuilder<AudioPlayerCubit, AudioPlayerState>(
      builder: (context, state) {
        final progress = state.progress;
        final isLoading = !state.isReady;
        final isPlaying = state.status == PlayerStatus.playing;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
          ),
          child: Column(
            children: [
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
                      LucideIcons.music,
                      color: Theme.of(context).colorScheme.onPrimary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                currentFile.fileInfo.filename,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                      fontWeight: FontWeight.w500,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              '${currentFile.fileInfo.fileExtension.toUpperCase()} • ${currentFile.formattedSize}',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Column(
                children: [
                  Builder(
                    builder: (context) => SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 4,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 6,
                        ),
                        overlayShape: const RoundSliderOverlayShape(
                          overlayRadius: 12,
                        ),
                        activeTrackColor: Theme.of(context).colorScheme.primary,
                        inactiveTrackColor: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        thumbColor: Theme.of(context).colorScheme.primary,
                        overlayColor: Theme.of(
                          context,
                        ).colorScheme.primary.withAlpha(51),
                      ),
                      child: Slider(
                        value: progress.clamp(0.0, 1.0),
                        onChanged: (value) {
                          context.read<AudioPlayerCubit>().seek(value);
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          DurationFormatUtils.formatDuration(
                            state.currentPosition,
                          ),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                        Text(
                          DurationFormatUtils.formatDuration(
                            state.totalDuration,
                          ),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(LucideIcons.skipBack),
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    iconSize: 24,
                  ),
                  const SizedBox(width: 16),
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(28),
                        onTap: () {
                          context.read<AudioPlayerCubit>().togglePlayPause();
                        },
                        child: Container(
                          width: 56,
                          height: 56,
                          alignment: Alignment.center,
                          child: isLoading
                              ? SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onPrimary,
                                  ),
                                )
                              : Icon(
                                  isPlaying
                                      ? LucideIcons.pause
                                      : LucideIcons.play,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                  size: 28,
                                ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(LucideIcons.skipForward),
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    iconSize: 24,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
