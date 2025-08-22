import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:bandspace_mobile/core/cubits/audio_player/audio_player_cubit.dart';
import 'package:bandspace_mobile/core/cubits/audio_player/audio_player_state.dart';
import 'package:bandspace_mobile/core/cubits/audio_player/player_status.dart';
import 'package:bandspace_mobile/shared/models/project.dart';

import 'album_art_widget.dart';
import 'song_info_widget.dart';

class MiniPlayerWidget extends StatelessWidget {
  final Project project;
  final double opacity;
  final VoidCallback onTap;

  const MiniPlayerWidget({
    super.key,
    required this.project,
    required this.opacity,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final clampedOpacity = opacity.clamp(0.0, 1.0);

    return Opacity(
      opacity: clampedOpacity,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: AlbumArtWidget(
                size: 50 * clampedOpacity,
                borderRadius: 10,
                iconSize: 24 * clampedOpacity,
              ),
            ),
            Expanded(
              child: SongInfoWidget(
                project: project,
                isCompact: true,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: BlocBuilder<AudioPlayerCubit, AudioPlayerState>(
                builder: (context, state) {
                  final isPlaying = state.status == PlayerStatus.playing;
                  final hasFile = state.currentPlayingUrl != null && state.currentPlayingUrl!.isNotEmpty;
                  
                  return IconButton(
                    onPressed: hasFile
                        ? () {
                            context.read<AudioPlayerCubit>().togglePlayPause();
                          }
                        : null,
                    icon: Icon(
                      isPlaying ? LucideIcons.pause : LucideIcons.play,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
