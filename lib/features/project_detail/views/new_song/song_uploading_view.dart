import 'package:flutter/material.dart';

import 'package:bandspace_mobile/core/theme/app_colors.dart';
import 'package:bandspace_mobile/features/project_detail/cubit/create_song/new_song_state.dart';

class SongUploadingView extends StatelessWidget {
  final NewSongState state;

  const SongUploadingView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final progress = state is NewSongUploading
        ? (state as NewSongUploading).uploadProgress
        : state is NewSongUploadSuccess
        ? 1.0
        : 0.0;
    final progressPercentage = (progress * 100).round();

    return PopScope(
      canPop: false,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Icon(
                  Icons.cloud_upload,
                  size: 40,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                state is NewSongUploading
                    ? 'Przesyłanie utworu...'
                    : 'Dodawanie utworu',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                state is NewSongUploading
                    ? (state as NewSongUploading).songName
                    : 'Brak pliku audio',

                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '$progressPercentage%',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
