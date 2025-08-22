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
        
        if (!hasFile) {
          // Jeśli utwór nie ma pliku, pokaż opcję dodania pliku
          return _buildNoFileView(context);
        }

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
                      size: ((screenWidth * 0.7) * (1 - percentageScrolled)).clamp(
                        54.0,
                        320.0,
                      ),
                      borderRadius: 20,
                      iconSize: (80 * (1 - percentageScrolled)).clamp(24.0, 80.0),
                    ),
                    SongInfoWidget(project: project),
                    const ProgressBarWidget(),
                    const PlayerControlsWidget(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNoFileView(BuildContext context) {
    return Opacity(
      opacity: (1 - percentageScrolled).clamp(0.0, 1.0),
      child: Column(
        children: [
          const SongDetailsWidget(),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AlbumArtWidget(
                    size: ((screenWidth * 0.7) * (1 - percentageScrolled)).clamp(
                      54.0,
                      320.0,
                    ),
                    borderRadius: 20,
                    iconSize: (80 * (1 - percentageScrolled)).clamp(24.0, 80.0),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Brak pliku audio',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Ten utwór nie ma przypisanego pliku audio',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: 200,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        // Pobierz projectId i songId z SongDetailCubit
                        final songDetailCubit = context.read<SongDetailCubit>();
                        final projectId = songDetailCubit.projectId;
                        final songId = songDetailCubit.songId;
                        
                        // Otwórz ekran dodawania pliku i poczekaj na wynik
                        final result = await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => AddSongFileScreen.create(
                              project,
                              projectId,
                              songId,
                              (updatedSong) {
                                // Zaktualizuj utwór w SongDetailCubit
                                songDetailCubit.updateSong(updatedSong);
                                // Wróć do ekranu utworu
                                Navigator.of(context).pop(updatedSong);
                              },
                            ),
                          ),
                        );
                        
                        // Jeśli otrzymaliśmy zaktualizowany utwór, zaktualizuj go w SongDetailCubit
                        if (result != null && result is Song) {
                          songDetailCubit.updateSong(result);
                        }
                      },
                      icon: const Icon(LucideIcons.upload),
                      label: const Text('Dodaj plik audio'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
