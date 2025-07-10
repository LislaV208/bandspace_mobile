import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:bandspace_mobile/features/song_detail/cubit/song_files/song_files_cubit.dart';
import 'package:bandspace_mobile/features/song_detail/widgets/song_files/song_file_list_item.dart';
import 'package:bandspace_mobile/shared/models/song_file.dart';

class SongFilesList extends StatelessWidget {
  final List<SongFile> files;

  const SongFilesList({
    super.key,
    required this.files,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await context.read<SongFilesCubit>().refreshSongFiles();
      },
      displacement: 0.0,
      color: Theme.of(context).colorScheme.tertiary,
      child: files.isEmpty
          ? _buildEmptyState(context)
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                padding: const EdgeInsets.only(bottom: 56.0),
                children: files.map(
                  (project) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: SongFileListItem(
                        songFile: project,
                      ),
                    );
                  },
                ).toList(),
              ),
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
