import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:bandspace_mobile/features/track_player/cubit/track_player_cubit.dart';
import 'package:bandspace_mobile/features/track_player/cubit/track_player_state.dart';

class PlayerControlsWidget extends StatelessWidget {
  const PlayerControlsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TrackPlayerCubit, TrackPlayerState>(
      builder: (context, state) {
        final isPlaying = state.playerUiStatus == PlayerUiStatus.playing;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                onPressed: state.hasPrevious
                    ? () {
                        context.read<TrackPlayerCubit>().seekToPrevious();
                      }
                    : null,
                icon: const Icon(LucideIcons.skipBack),
                iconSize: 32,
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
                      Theme.of(context).colorScheme.tertiary,
                      Theme.of(context).colorScheme.primary,
                    ],
                  ),
                ),
                child: IconButton(
                  onPressed: () {
                    context.read<TrackPlayerCubit>().togglePlayPause();
                  },
                  icon: Icon(
                    isPlaying ? LucideIcons.pause : LucideIcons.play,
                  ),
                  iconSize: 32,
                  color: Colors.white,
                ),
              ),
              IconButton(
                onPressed: state.hasNext
                    ? () {
                        context.read<TrackPlayerCubit>().seekToNext();
                      }
                    : null,
                icon: const Icon(LucideIcons.skipForward),
                iconSize: 32,
              ),
            ],
          ),
        );
      },
    );
  }
}
