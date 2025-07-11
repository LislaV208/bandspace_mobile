import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:bandspace_mobile/features/song_detail/cubit/song_file/song_file_cubit.dart';
import 'package:bandspace_mobile/features/song_detail/cubit/song_file/song_file_state.dart';
import 'package:bandspace_mobile/shared/models/song_file.dart';

class SongFileView extends StatelessWidget {
  const SongFileView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SongFileCubit, SongFileState>(
      builder: (context, state) {
        return switch (state) {
          SongFileInitial() => const SizedBox(),
          SongFileLoading() => const Center(
            child: CircularProgressIndicator(),
          ),
          SongFileLoadSuccess() => _buildFileContent(context, state),
          SongFileEmpty() => _buildEmptyState(context),
          SongFileLoadFailure() => _buildErrorState(context, state.message),
        };
      },
    );
  }

  Widget _buildFileContent(BuildContext context, SongFileLoadSuccess state) {
    return BlocListener<SongFileCubit, SongFileState>(
      listener: (context, state) {
        if (state is SongFileUrlLoadFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          _buildAlbumArt(context, state.file),
          const SizedBox(height: 48),
          _buildSongInfo(context, state.file),
          const SizedBox(height: 64),
          _buildProgressBar(context),
          const SizedBox(height: 48),
          _buildControls(context, state.file),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildAlbumArt(BuildContext context, SongFile file) {
    return Container(
      width: 280,
      height: 280,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
            Theme.of(context).colorScheme.secondary.withValues(alpha: 0.6),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Icon(
        LucideIcons.music,
        size: 80,
        color: Colors.white.withValues(alpha: 0.9),
      ),
    );
  }

  Widget _buildSongInfo(BuildContext context, SongFile file) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        children: [
          Text(
            file.fileInfo.filename
                .replaceAll('.mp3', '')
                .replaceAll('.wav', ''),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            'Audio Track',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        children: [
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4.0,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.0),
              activeTrackColor: Theme.of(context).colorScheme.primary,
              inactiveTrackColor: Theme.of(
                context,
              ).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
              thumbColor: Theme.of(context).colorScheme.primary,
            ),
            child: Slider(
              value: 0.0, // TODO: Connect to actual playback
              onChanged: (value) {
                // TODO: Implement seek functionality
              },
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '0:00',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                '0:00', // TODO: Show actual duration
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControls(BuildContext context, SongFile file) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            onPressed: () {
              // TODO: Previous track
            },
            icon: const Icon(LucideIcons.skipBack),
            iconSize: 32,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: IconButton(
              onPressed: () {
                // Load file URL for future playback
                context.read<SongFileCubit>().loadFileUrl();

                // TODO: Implement actual audio playback
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Playing: ${file.fileInfo.filename}'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              icon: const Icon(LucideIcons.play),
              iconSize: 32,
              color: Colors.white,
            ),
          ),
          IconButton(
            onPressed: () {
              // TODO: Next track
            },
            icon: const Icon(LucideIcons.skipForward),
            iconSize: 32,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              child: Icon(
                LucideIcons.music,
                size: 48,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Audio File',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Upload an audio file to start playing music',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () {
                // TODO: Implement file upload
              },
              icon: const Icon(LucideIcons.upload),
              label: const Text('Upload Audio'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String errorMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
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
              'Error Loading File',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                context.read<SongFileCubit>().loadSongFile();
              },
              icon: const Icon(LucideIcons.refreshCw),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
