import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bandspace_mobile/features/track_player/cubit/track_player_cubit.dart';
import 'package:bandspace_mobile/features/track_player/cubit/track_player_state.dart';
import 'package:bandspace_mobile/features/track_player/widgets/album_art_widget.dart';
import 'package:bandspace_mobile/features/track_player/widgets/track_info_widget.dart';
import 'package:bandspace_mobile/shared/models/project.dart';

class NewMiniPlayerWidget extends StatelessWidget {
  final Project project;
  final double opacity;
  final VoidCallback onTap;

  const NewMiniPlayerWidget({
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
              child: TrackInfoWidget(
                project: project,
                isCompact: true,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: BlocBuilder<TrackPlayerCubit, TrackPlayerState>(
                builder: (context, state) {
                  final isPlaying =
                      state.playerUiStatus == PlayerUiStatus.playing;

                  return IconButton(
                    icon: Icon(
                      isPlaying ? Icons.pause : Icons.play_arrow,
                    ),
                    onPressed: () =>
                        context.read<TrackPlayerCubit>().togglePlayPause(),
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
