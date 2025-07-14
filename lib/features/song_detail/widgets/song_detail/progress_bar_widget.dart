import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bandspace_mobile/core/cubits/audio_player/audio_player_cubit.dart';
import 'package:bandspace_mobile/core/cubits/audio_player/audio_player_state.dart';
import 'package:bandspace_mobile/core/utils/duration_format_utils.dart';

class ProgressBarWidget extends StatelessWidget {
  const ProgressBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
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
                activeTrackColor: Theme.of(context).colorScheme.primary,
                inactiveTrackColor: Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant
                    .withValues(alpha: 0.3),
                thumbColor: Theme.of(context).colorScheme.primary,
              ),
              child: Slider(
                value: progress,
                onChangeStart: (value) {
                  context.read<AudioPlayerCubit>().startSeeking();
                },
                onChanged: (value) {
                  context.read<AudioPlayerCubit>().updateSeekPosition(value);
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
  }
}