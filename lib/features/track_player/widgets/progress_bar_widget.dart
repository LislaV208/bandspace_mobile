import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bandspace_mobile/core/utils/duration_format_utils.dart';
import 'package:bandspace_mobile/features/track_player/cubit/track_player_cubit.dart';
import 'package:bandspace_mobile/features/track_player/cubit/track_player_state.dart';

class ProgressBarWidget extends StatelessWidget {
  const ProgressBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TrackPlayerCubit, TrackPlayerState>(
      builder: (context, state) {
        // Sprawdź czy utwór ma plik na podstawie Song.file
        final hasFile = state.currentTrack?.mainVersion?.file != null;

        // Jeśli nie ma pliku, pokaż komunikat
        if (!hasFile) {
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
        final progress = state.progress.clamp(0.0, 1.0);

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
                  context.read<TrackPlayerCubit>().startSeeking();
                },
                onChanged: (value) {
                  context.read<TrackPlayerCubit>().updateSeekPosition(value);
                },
                onChangeEnd: (value) {
                  context.read<TrackPlayerCubit>().endSeeking();
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
                      state.isSeeking && state.seekPosition != null
                          ? state.seekPosition!
                          : state.currentPosition,
                    ),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    DurationFormatUtils.formatDuration(
                      state.totalDuration,
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
  }
}
