import 'package:flutter/material.dart';

import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:bandspace_mobile/features/project_detail/cubit/create_song/new_song_state.dart';

/// Step 3: Upload progress
class SongUploadingView extends StatelessWidget {
  final NewSongState state;

  const SongUploadingView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    double progress = 0.0;
    String songName = '';

    if (state is NewSongUploading) {
      progress = (state as NewSongUploading).uploadProgress;
      songName = (state as NewSongUploading).songName;
    } else if (state is NewSongUploadFailure) {
      progress = (state as NewSongUploadFailure).uploadProgress;
      songName = (state as NewSongUploadFailure).songName;
    } else if (state is NewSongUploadSuccess) {
      progress = 1.0;
      songName = (state as NewSongUploadSuccess).songName;
    }

    return PopScope(
      canPop: false,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.secondaryContainer.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.secondaryContainer.withValues(alpha: 0.2),
                  width: 3,
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      LucideIcons.upload,
                      size: 40,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Tworzenie utworu',
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    songName.isNotEmpty ? songName : 'Przesyłanie...',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${(progress * 100).round()}%',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
