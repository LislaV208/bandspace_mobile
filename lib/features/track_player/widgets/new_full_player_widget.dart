import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:bandspace_mobile/features/track_player/cubit/track_player_cubit.dart';
import 'package:bandspace_mobile/features/track_player/cubit/track_player_state.dart';
import 'package:bandspace_mobile/features/track_player/widgets/album_art_widget.dart';
import 'package:bandspace_mobile/features/track_player/widgets/player_controls_widget.dart';
import 'package:bandspace_mobile/features/track_player/widgets/progress_bar_widget.dart';
import 'package:bandspace_mobile/features/track_player/widgets/track_details_widget.dart';
import 'package:bandspace_mobile/features/track_player/widgets/track_info_widget.dart';
import 'package:bandspace_mobile/shared/models/project.dart';

class NewFullPlayerWidget extends StatelessWidget {
  final Project project;
  final double percentageScrolled;

  const NewFullPlayerWidget({
    super.key,
    required this.project,
    required this.percentageScrolled,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return BlocBuilder<TrackPlayerCubit, TrackPlayerState>(
      builder: (context, state) {
        final track = state.currentTrack;
        final hasFile = track?.mainVersion?.file != null;

        return Opacity(
          opacity: (1 - percentageScrolled).clamp(0.0, 1.0),
          child: Column(
            children: [
              const TrackVersionDetailsWidget(),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    AlbumArtWidget(
                      size: ((screenWidth * 0.7) * (1 - percentageScrolled))
                          .clamp(
                            54.0,
                            320.0,
                          ),
                      borderRadius: 20,
                      iconSize: (80 * (1 - percentageScrolled)).clamp(
                        24.0,
                        80.0,
                      ),
                    ),

                    TrackInfoWidget(project: project),
                    const ProgressBarWidget(),
                    if (hasFile)
                      const PlayerControlsWidget()
                    else
                      _buildNoFileControls(context),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNoFileControls(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              BlocBuilder<TrackPlayerCubit, TrackPlayerState>(
                builder: (context, state) {
                  return IconButton(
                    onPressed: state.hasPrevious
                        ? () {
                            context.read<TrackPlayerCubit>().seekToPrevious();
                          }
                        : null,
                    icon: const Icon(LucideIcons.skipBack),
                    iconSize: 32,
                  );
                },
              ),
              // Przycisk dodania pliku zamiast play/pause
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.primary,
                ),
                child: IconButton(
                  onPressed: () async {
                    // TODO: implement adding file to track

                    // final songDetailCubit = context.read<SongDetailCubit>();
                    // final projectId = songDetailCubit.projectId;
                    // final songId = songDetailCubit.songId;

                    // final result = await Navigator.of(context).push(
                    //   MaterialPageRoute(
                    //     builder: (context) => AddSongFileScreen.create(
                    //       project,
                    //       projectId,
                    //       songId,
                    //       (updatedSong) {
                    //         songDetailCubit.updateSong(updatedSong);
                    //         Navigator.of(context).pop(updatedSong);
                    //       },
                    //     ),
                    //   ),
                    // );

                    // if (result != null && result is Song) {
                    //   songDetailCubit.updateSong(result);
                    // }
                  },
                  icon: const Icon(LucideIcons.upload),
                  iconSize: 32,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
              BlocBuilder<TrackPlayerCubit, TrackPlayerState>(
                builder: (context, state) {
                  return IconButton(
                    onPressed: state.hasNext
                        ? () {
                            context.read<TrackPlayerCubit>().seekToNext();
                          }
                        : null,
                    icon: const Icon(LucideIcons.skipForward),
                    iconSize: 32,
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
