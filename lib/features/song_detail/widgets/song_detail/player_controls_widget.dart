import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:bandspace_mobile/core/cubits/audio_player/audio_player_cubit.dart';
import 'package:bandspace_mobile/core/cubits/audio_player/audio_player_state.dart';
import 'package:bandspace_mobile/core/cubits/audio_player/player_status.dart';
import 'package:bandspace_mobile/features/song_detail/cubit/song_detail/song_detail_cubit.dart';
import 'package:bandspace_mobile/features/song_detail/cubit/song_detail/song_detail_state.dart';

class PlayerControlsWidget extends StatelessWidget {
  const PlayerControlsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioPlayerCubit, AudioPlayerState>(
      builder: (context, audioState) {
        final isPlaying = audioState.status == PlayerStatus.playing;
        final hasFile = audioState.currentPlayingUrl != null && audioState.currentPlayingUrl!.isNotEmpty;

        return BlocBuilder<SongDetailCubit, SongDetailState>(
          builder: (context, songState) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    onPressed: songState.canGoPrevious
                        ? () {
                            context.read<SongDetailCubit>().goToPreviousSong();
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
                  onPressed: hasFile
                      ? () {
                          context.read<AudioPlayerCubit>().togglePlayPause();
                        }
                      : null,
                  icon: Icon(
                    isPlaying ? LucideIcons.pause : LucideIcons.play,
                  ),
                  iconSize: 32,
                  color: Colors.white,
                ),
              ),
                  IconButton(
                    onPressed: songState.canGoNext
                        ? () {
                            context.read<SongDetailCubit>().goToNextSong();
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
      },
    );
  }
}
