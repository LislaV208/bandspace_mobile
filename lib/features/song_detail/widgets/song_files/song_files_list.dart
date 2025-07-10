import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:bandspace_mobile/features/song_detail/cubit/song_files/song_files_cubit.dart';
import 'package:bandspace_mobile/features/song_detail/cubit/song_files/song_files_state.dart';
import 'package:bandspace_mobile/features/song_detail/widgets/song_files/song_file_audio_player.dart';
import 'package:bandspace_mobile/features/song_detail/widgets/song_files/song_file_list_item.dart';
// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:bandspace_mobile/shared/cubits/audio_player/audio_player_cubit.dart';

class SongFilesList extends StatelessWidget {
  final SongFilesLoadSuccess state;

  const SongFilesList({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<SongFilesCubit, SongFilesState>(
      listener: (context, state) {
        if (state is SongFilesFileUrlLoadFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
        if (state is SongFilesFileUrlLoaded) {
          context.read<AudioPlayerCubit>().loadUrl(state.url);
        }
      },
      child: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await context.read<SongFilesCubit>().refreshSongFiles();
              },
              displacement: 0.0,
              color: Theme.of(context).colorScheme.tertiary,
              child: state.files.isEmpty
                  ? _buildEmptyState(context)
                  : Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ListView(
                        padding: const EdgeInsets.only(bottom: 56.0),
                        children: state.files.map(
                          (file) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: SongFileListItem(
                                songFile: file,
                                isSelected:
                                    state is SongFilesFileSelected &&
                                    (state as SongFilesFileSelected)
                                            .selectedFile
                                            .id ==
                                        file.id,
                              ),
                            );
                          },
                        ).toList(),
                      ),
                    ),
            ),
          ),
          if (state is SongFilesFileSelected)
            SongFileAudioPlayer(
              currentFile: (state as SongFilesFileSelected).selectedFile,
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
      child: Column(
        children: [
          Icon(
            LucideIcons.fileAudio,
            size: 64,
            color: Theme.of(
              context,
            ).colorScheme.onSurfaceVariant.withAlpha(127),
          ),
          const SizedBox(height: 16),
          Text(
            'Brak plików audio',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Dodaj pierwszy plik audio',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
