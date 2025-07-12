import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:bandspace_mobile/features/song_detail/cubit/song_detail/song_detail_state.dart';
import 'package:bandspace_mobile/shared/cubits/audio_player/audio_player_cubit.dart';
import 'package:bandspace_mobile/shared/cubits/audio_player/audio_player_state.dart';
import 'package:bandspace_mobile/shared/models/project.dart';
import 'package:bandspace_mobile/shared/models/song.dart';
import 'package:bandspace_mobile/shared/utils/duration_format_utils.dart';

class SongView extends StatelessWidget {
  final Project project;
  final SongDetailLoadSuccess state;

  const SongView({
    super.key,
    required this.project,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(),
        _buildAlbumArt(context),
        const SizedBox(height: 48),
        _buildSongInfo(context, project, state.song),
        const SizedBox(height: 64),
        _buildProgressBar(context),
        const SizedBox(height: 48),
        _buildControls(context),
        const Spacer(),
      ],
    );
  }

  Widget _buildAlbumArt(BuildContext context) {
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

  Widget _buildSongInfo(BuildContext context, Project project, Song song) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        children: [
          Text(
            song.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            project.name,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context) {
    return BlocBuilder<AudioPlayerCubit, AudioPlayerState>(
      builder: (context, audioState) {
        final progress = audioState.progress.clamp(0.0, 1.0);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 4.0,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 6.0,
                  ),
                  activeTrackColor: Theme.of(context).colorScheme.primary,
                  inactiveTrackColor: Theme.of(
                    context,
                  ).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                  thumbColor: Theme.of(context).colorScheme.primary,
                ),
                child: Slider(
                  value: progress,
                  onChanged: (value) {
                    context.read<AudioPlayerCubit>().seek(value);
                  },
                ),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DurationFormatUtils.formatDuration(
                        audioState.currentPosition,
                      ),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      DurationFormatUtils.formatDuration(
                        audioState.totalDuration,
                      ),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildControls(BuildContext context) {
    return BlocBuilder<AudioPlayerCubit, AudioPlayerState>(
      builder: (context, audioState) {
        final isPlaying = audioState.status == PlayerStatus.playing;

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
                child: !audioState.isReady
                    ? const Padding(
                        padding: EdgeInsets.all(20.0),
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : IconButton(
                        onPressed: () {
                          context.read<AudioPlayerCubit>().togglePlayPause();
                        },
                        icon: Icon(
                          isPlaying ? LucideIcons.pause : LucideIcons.play,
                        ),
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
      },
    );
  }
}
