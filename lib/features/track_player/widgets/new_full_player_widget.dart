import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:bandspace_mobile/features/track_player/cubit/track_player_cubit.dart';
import 'package:bandspace_mobile/features/track_player/cubit/track_player_state.dart';
import 'package:bandspace_mobile/features/track_player/screens/add_track_file_screen.dart';
import 'package:bandspace_mobile/features/track_player/widgets/album_art_widget.dart';
import 'package:bandspace_mobile/features/track_player/widgets/player_controls_widget.dart';
import 'package:bandspace_mobile/features/track_player/widgets/progress_bar_widget.dart';
import 'package:bandspace_mobile/features/track_player/widgets/track_details_widget.dart';
import 'package:bandspace_mobile/features/track_player/widgets/track_info_widget.dart';
import 'package:bandspace_mobile/shared/models/project.dart';
import 'package:bandspace_mobile/shared/models/track.dart';

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
                child: BlocBuilder<TrackPlayerCubit, TrackPlayerState>(
                  builder: (context, state) {
                    return IconButton(
                      onPressed: () {
                        _navigateToAddFile(context, state.currentTrack!, state);
                      },
                      icon: const Icon(LucideIcons.upload),
                      iconSize: 32,
                      color: Theme.of(context).colorScheme.onPrimary,
                    );
                  },
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


  void _navigateToAddFile(BuildContext context, Track track, TrackPlayerState state) {
    final trackPlayerCubit = context.read<TrackPlayerCubit>();
    final projectId = state.currentProjectId;
    
    if (projectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Błąd: Nie można określić projektu')),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddTrackFileScreen.create(
          projectId,
          track.id,
          track.title,
          (updatedTrack) {
            trackPlayerCubit.updateTrack(updatedTrack);
          },
        ),
      ),
    );
  }
}
