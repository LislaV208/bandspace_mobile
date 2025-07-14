import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:bandspace_mobile/core/cubits/audio_player/audio_player_cubit.dart';
import 'package:bandspace_mobile/core/cubits/audio_player/audio_player_state.dart';
import 'package:bandspace_mobile/core/cubits/audio_player/player_status.dart';

class PlayerControlsWidget extends StatelessWidget {
  const PlayerControlsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioPlayerCubit, AudioPlayerState>(
      builder: (context, audioState) {
        final isPlaying = audioState.status == PlayerStatus.playing;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                onPressed: () {
                  context.read<AudioPlayerCubit>().playPrevious();
                },
                icon: const Icon(LucideIcons.skipBack),
                iconSize: 32,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: () {
                    context.read<AudioPlayerCubit>().togglePlayPause();
                  },
                  icon: Icon(
                    isPlaying ? LucideIcons.pause : LucideIcons.play,
                  ),
                  iconSize: 32,
                  color: Colors.white,
                ),
              ),
              IconButton(
                onPressed: () {
                  context.read<AudioPlayerCubit>().playNext();
                },
                icon: const Icon(LucideIcons.skipForward),
                iconSize: 32,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        );
      },
    );
  }
}
