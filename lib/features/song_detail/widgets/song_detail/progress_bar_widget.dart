import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bandspace_mobile/core/cubits/audio_player/audio_player_cubit.dart';
import 'package:bandspace_mobile/core/cubits/audio_player/audio_player_state.dart';
import 'package:bandspace_mobile/core/utils/duration_format_utils.dart';
import 'package:bandspace_mobile/features/song_detail/cubit/song_detail/song_detail_cubit.dart';
import 'package:bandspace_mobile/features/song_detail/cubit/song_detail/song_detail_state.dart';

class ProgressBarWidget extends StatelessWidget {
  const ProgressBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SongDetailCubit, SongDetailState>(
      builder: (context, songState) {
        // Sprawdź czy utwór ma plik na podstawie SongDetailState
        final hasFileInfo = songState.hasFileInfo;
        final hasFile = hasFileInfo && songState.currentSongHasFile;

        // Jeśli nie ma pliku (po załadowaniu URL-ów), pokaż komunikat
        if (hasFileInfo && !hasFile) {
          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 16.0,
            ),
            child: Column(
              children: [
                Container(
                  height: 4.0,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Brak pliku audio',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          );
        }

        // Teraz potrzebujemy AudioPlayerState dla progress i duration
        return BlocBuilder<AudioPlayerCubit, AudioPlayerState>(
          builder: (context, audioState) {
            final progress = audioState.progress.clamp(0.0, 1.0);

            return Column(
              children: [
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
                    value: progress,
                    onChangeStart: (value) {
                      context.read<AudioPlayerCubit>().startSeeking();
                    },
                    onChanged: (value) {
                      context.read<AudioPlayerCubit>().updateSeekPosition(
                        value,
                      );
                    },
                    onChangeEnd: (value) {
                      context.read<AudioPlayerCubit>().endSeeking();
                    },
                  ),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DurationFormatUtils.formatDuration(
                          audioState.seekPosition ?? audioState.currentPosition,
                        ),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        DurationFormatUtils.formatDuration(
                          audioState.totalDuration,
                        ),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
