import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:bandspace_mobile/features/project_detail/cubit/project_songs_cubit.dart';
import 'package:bandspace_mobile/features/project_detail/cubit/project_songs_state.dart';
import 'package:bandspace_mobile/features/project_detail/widgets/project_song_delete_dialog.dart';
import 'package:bandspace_mobile/features/project_detail/widgets/song_list_item.dart';
import 'package:bandspace_mobile/shared/models/song.dart';

class ProjectSongsList extends StatelessWidget {
  const ProjectSongsList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProjectSongsCubit, ProjectSongsState>(
      builder: (context, state) {
        return switch (state.status) {
          ProjectSongsStatus.initial ||
          ProjectSongsStatus.loading => const Center(
            child: CircularProgressIndicator(),
          ),
          ProjectSongsStatus.error => _buildErrorState(
            context,
            state.errorMessage,
          ),
          ProjectSongsStatus.success => _buildSongsList(
            context,
            state.songs,
          ),
        };
      },
    );
  }

  Widget _buildSongsList(BuildContext context, List<Song> songs) {
    if (songs.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: songs.length,
      itemBuilder: (context, index) {
        final song = songs[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: SongListItem(
            song: song,
            onTap: () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => SongDetailScreen.fromSong(
              //       projectId: widget.project.id,
              //       song: song,
              //     ),
              //   ),
              // );
            },
            onDelete: () {
              ProjectSongDeleteDialog.show(context, song: song);
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    // final hasSearchQuery = _searchController.text.isNotEmpty;
    final hasSearchQuery = false;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            hasSearchQuery ? LucideIcons.searchX : LucideIcons.music,
            size: 64,
            // color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            hasSearchQuery
                ? 'Brak utworów pasujących do wyszukiwania'
                : 'Brak utworów w projekcie',
            // style: AppTextStyles.titleMedium.copyWith(
            //   color: AppColors.textSecondary,
            // ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            hasSearchQuery
                ? 'Spróbuj zmienić frazę wyszukiwania'
                : 'Dodaj pierwszy utwór, aby rozpocząć pracę',
            // style: AppTextStyles.bodyMedium.copyWith(
            //   color: AppColors.textSecondary,
            // ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String? errorMessage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.x,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Wystąpił błąd podczas ładowania utworów',
            // style: AppTextStyles.titleMedium.copyWith(
            //   color: AppColors.textSecondary,
            // ),
            textAlign: TextAlign.center,
          ),
          if (errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                errorMessage,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          const SizedBox(height: 16),
          ElevatedButton(
            // onPressed: () => context.read<ProjectDetailCubit>().loadSongs(),
            onPressed: () => {},
            style: ElevatedButton.styleFrom(
              // backgroundColor: AppColors.primary,
              // foregroundColor: AppColors.onPrimary,
            ),
            child: const Text('Spróbuj ponownie'),
          ),
        ],
      ),
    );
  }
}
