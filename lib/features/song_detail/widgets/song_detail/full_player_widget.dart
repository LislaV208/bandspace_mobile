import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:bandspace_mobile/features/song_detail/cubit/song_detail/song_detail_cubit.dart';
import 'package:bandspace_mobile/features/song_detail/cubit/song_detail/song_detail_state.dart';
import 'package:bandspace_mobile/features/song_detail/screens/add_song_file_screen.dart';
import 'package:bandspace_mobile/features/song_detail/widgets/song_detail/song_details_widget.dart';
import 'package:bandspace_mobile/shared/models/project.dart';
import 'package:bandspace_mobile/shared/models/song.dart';

import 'album_art_widget.dart';
import 'player_controls_widget.dart';
import 'progress_bar_widget.dart';
import 'song_info_widget.dart';

class FullPlayerWidget extends StatelessWidget {
  final Project project;
  final double screenWidth;
  final double percentageScrolled;

  const FullPlayerWidget({
    super.key,
    required this.project,
    required this.screenWidth,
    required this.percentageScrolled,
  });

  @override
  Widget build(BuildContext context) {
    return BlocSelector<SongDetailCubit, SongDetailState, Song>(
      selector: (state) => state.currentSong,
      builder: (context, currentSong) {
        final hasFile = currentSong.file != null;

        return Opacity(
          opacity: (1 - percentageScrolled).clamp(0.0, 1.0),
          child: Column(
            children: [
              const SongDetailsWidget(),
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
                    SongInfoWidget(project: project),
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
          // Kontrolki nawigacji (prev/next) + przycisk dodania pliku w środku
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              BlocBuilder<SongDetailCubit, SongDetailState>(
                builder: (context, songState) {
                  return IconButton(
                    onPressed: songState.canGoPrevious
                        ? () {
                            context.read<SongDetailCubit>().goToPreviousSong();
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
                    final songDetailCubit = context.read<SongDetailCubit>();
                    final projectId = songDetailCubit.projectId;
                    final songId = songDetailCubit.songId;

                    final result = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => AddSongFileScreen.create(
                          project,
                          projectId,
                          songId,
                          (updatedSong) {
                            songDetailCubit.updateSong(updatedSong);
                            Navigator.of(context).pop(updatedSong);
                          },
                        ),
                      ),
                    );

                    if (result != null && result is Song) {
                      songDetailCubit.updateSong(result);
                    }
                  },
                  icon: const Icon(LucideIcons.upload),
                  iconSize: 32,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
              BlocBuilder<SongDetailCubit, SongDetailState>(
                builder: (context, songState) {
                  return IconButton(
                    onPressed: songState.canGoNext
                        ? () {
                            context.read<SongDetailCubit>().goToNextSong();
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
