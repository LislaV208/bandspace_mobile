import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:bandspace_mobile/features/song_detail/cubit/song_detail/song_detail_cubit.dart';
import 'package:bandspace_mobile/features/song_detail/cubit/song_detail/song_detail_state.dart';
import 'package:bandspace_mobile/shared/cubits/audio_player/audio_player_cubit.dart';
import 'package:bandspace_mobile/shared/cubits/audio_player/audio_player_state.dart';
import 'package:bandspace_mobile/shared/cubits/audio_player/player_status.dart';
import 'package:bandspace_mobile/shared/models/project.dart';
import 'package:bandspace_mobile/shared/models/song.dart';
import 'package:bandspace_mobile/shared/utils/duration_format_utils.dart';

class SongView extends StatelessWidget {
  final Project project;

  const SongView({
    super.key,
    required this.project,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return BlocListener<SongDetailCubit, SongDetailState>(
      listener: (context, state) {
        if (state is SongDetailLoadUrlsFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
        if (state is SongDetailLoadUrlsSuccess) {
          context.read<AudioPlayerCubit>().loadPlaylist(
            state.downloadUrls.map((url) => url.url).toList(),
            initialIndex: state.songs.indexOf(state.currentSong),
          );
        }
        if (state is SongDetailReady) {
          context.read<AudioPlayerCubit>().playTrackAt(
            state.songs.indexOf(state.currentSong),
          );
        }
      },
      child: BlocListener<AudioPlayerCubit, AudioPlayerState>(
        listener: (context, state) {
          if (state.isReady) {
            context.read<SongDetailCubit>().setReady();
          }
        },
        child: PopScope(
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) {
              context.read<AudioPlayerCubit>().stop();
            }
          },
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final availableHeight = constraints.maxHeight;

                // Responsywne spacing bazowane na wysokości ekranu
                final smallSpacing = availableHeight * 0.02; // 2% wysokości
                final mediumSpacing = availableHeight * 0.04; // 4% wysokości
                final largeSpacing = availableHeight * 0.06; // 6% wysokości

                return Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.05, // 5% szerokości jako margin
                    vertical: smallSpacing,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Górny spacer - elastyczny ale z limitem
                      SizedBox(height: smallSpacing.clamp(8.0, 24.0)),

                      _buildAlbumArt(context, screenWidth),

                      SizedBox(height: mediumSpacing.clamp(16.0, 48.0)),

                      _buildSongInfo(context, project),

                      SizedBox(height: largeSpacing.clamp(24.0, 64.0)),

                      _buildProgressBar(context),

                      SizedBox(height: mediumSpacing.clamp(16.0, 48.0)),

                      _buildControls(context),

                      // Dolny spacer - elastyczny ale z limitem
                      SizedBox(height: smallSpacing.clamp(8.0, 24.0)),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAlbumArt(BuildContext context, double screenWidth) {
    // Responsywny rozmiar - maksymalnie 70% szerokości ekranu, ale nie więcej niż 320px
    final size = (screenWidth * 0.7).clamp(200.0, 320.0);

    return Container(
      width: size,
      height: size,
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

  Widget _buildSongInfo(BuildContext context, Project project) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        children: [
          BlocSelector<SongDetailCubit, SongDetailState, Song>(
            selector: (state) => state.currentSong,
            builder: (context, song) {
              return Text(
                song.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              );
            },
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

        return Column(
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
                onChangeStart: (value) {
                  context.read<AudioPlayerCubit>().startSeeking();
                },
                onChanged: (value) {
                  context.read<AudioPlayerCubit>().updateSeekPosition(value);
                },
                onChangeEnd: (value) {
                  context.read<AudioPlayerCubit>().endSeeking();
                },
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DurationFormatUtils.formatDuration(
                      audioState.seekPosition ?? audioState.currentPosition,
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
                  context.read<SongDetailCubit>().previousSong();
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
                  context.read<SongDetailCubit>().nextSong();
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
