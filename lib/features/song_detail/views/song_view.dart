import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:bandspace_mobile/core/cubits/audio_player/audio_player_cubit.dart';
import 'package:bandspace_mobile/core/cubits/audio_player/audio_player_state.dart';
import 'package:bandspace_mobile/core/cubits/audio_player/player_status.dart';
import 'package:bandspace_mobile/core/utils/duration_format_utils.dart';
import 'package:bandspace_mobile/features/song_detail/cubit/song_detail/song_detail_cubit.dart';
import 'package:bandspace_mobile/features/song_detail/cubit/song_detail/song_detail_state.dart';
import 'package:bandspace_mobile/shared/models/project.dart';
import 'package:bandspace_mobile/shared/models/song.dart';

class SongView extends StatefulWidget {
  final Project project;

  const SongView({
    super.key,
    required this.project,
  });

  @override
  State<SongView> createState() => _SongViewState();
}

class _SongViewState extends State<SongView> {
  static const _minBottomHeight = 68.0;

  final _currentBottomHeight = _minBottomHeight;

  final _draggableScrollableController = DraggableScrollableController();

  Color getColor(int pixels) {
    if (pixels > _minBottomHeight + 1) {
      return Colors.blue;
    } else {
      return Colors.red;
    }
  }

  double normalizeValue(
    double value,
    double originalMin,
    double originalMax,
  ) {
    double originalRange = originalMax - originalMin;
    if (originalRange == 0) {
      return 0.0;
    }
    return (value - originalMin) / originalRange;
  }

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
                final maxHeight = constraints.maxHeight;
                final playerHeight = maxHeight - _minBottomHeight;

                final minDraggableScrollSize =
                    1 -
                    normalizeValue(
                      maxHeight - _minBottomHeight,
                      0,
                      maxHeight,
                    );

                final maxDraggableScrollSize =
                    1 -
                    normalizeValue(
                      _minBottomHeight,
                      0,
                      maxHeight,
                    );
                print('playerBasePercentage: $minDraggableScrollSize');
                return Stack(
                  children: [
                    SizedBox(
                      height: playerHeight,
                      child: ListenableBuilder(
                        listenable: _draggableScrollableController,
                        builder: (context, _) {
                          final percentageScrolled =
                              _draggableScrollableController.isAttached
                              ? normalizeValue(
                                  _draggableScrollableController.pixels
                                      .roundToDouble(),
                                  _minBottomHeight,
                                  maxHeight - _minBottomHeight,
                                )
                              : 0.0;

                          return Stack(
                            children: [
                              Opacity(
                                opacity: percentageScrolled,
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () {
                                    _draggableScrollableController.animateTo(
                                      0.0,
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      curve: Curves.easeInOut,
                                    );
                                  },
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20.0,
                                        ),
                                        child: _buildAlbumArtSmall(
                                          context,
                                          percentageScrolled,
                                        ),
                                      ),
                                      Expanded(
                                        child: _buildSongInfoSmall(
                                          context,
                                          widget.project,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          right: 16.0,
                                        ),
                                        child:
                                            BlocBuilder<
                                              AudioPlayerCubit,
                                              AudioPlayerState
                                            >(
                                              builder: (context, state) {
                                                final isPlaying =
                                                    state.status ==
                                                    PlayerStatus.playing;
                                                return IconButton(
                                                  onPressed: () {
                                                    context
                                                        .read<
                                                          AudioPlayerCubit
                                                        >()
                                                        .togglePlayPause();
                                                  },
                                                  icon: Icon(
                                                    isPlaying
                                                        ? LucideIcons.pause
                                                        : LucideIcons.play,
                                                  ),
                                                );
                                              },
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Opacity(
                                opacity: 1 - percentageScrolled,
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _buildAlbumArt(
                                      context,
                                      screenWidth,
                                      percentageScrolled,
                                    ),
                                    _buildSongInfo(context, widget.project),
                                    _buildProgressBar(context),
                                    _buildControls(context),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    DraggableScrollableSheet(
                      controller: _draggableScrollableController,
                      initialChildSize: minDraggableScrollSize,
                      minChildSize: minDraggableScrollSize,
                      maxChildSize: maxDraggableScrollSize,
                      snap: true,
                      snapAnimationDuration: const Duration(milliseconds: 200),
                      builder: (context, scrollController) {
                        return SingleChildScrollView(
                          controller: scrollController,
                          child: ListenableBuilder(
                            listenable: _draggableScrollableController,
                            builder: (context, _) {
                              final percentageScrolled = normalizeValue(
                                _draggableScrollableController.pixels
                                    .roundToDouble(),
                                _minBottomHeight,
                                maxHeight - _minBottomHeight,
                              );

                              return Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.surface
                                      .withValues(alpha: percentageScrolled),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(
                                      percentageScrolled * 16,
                                    ),
                                    topRight: Radius.circular(
                                      percentageScrolled * 16,
                                    ),
                                  ),
                                ),
                                height: maxHeight - _minBottomHeight,
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: _minBottomHeight,
                                      child: Center(
                                        child: TextButton.icon(
                                          style: TextButton.styleFrom(
                                            foregroundColor: Theme.of(
                                              context,
                                            ).colorScheme.onSurfaceVariant,
                                            disabledForegroundColor: Theme.of(
                                              context,
                                            ).colorScheme.onSurfaceVariant,
                                          ),
                                          onPressed: percentageScrolled >= 0.9
                                              ? null
                                              : () {
                                                  _draggableScrollableController
                                                      .animateTo(
                                                        1.0,
                                                        duration:
                                                            const Duration(
                                                              milliseconds: 400,
                                                            ),
                                                        curve: Curves.easeInOut,
                                                      );
                                                },
                                          label: const Text('WIĘCEJ UTWORÓW'),
                                          icon: const Icon(
                                            LucideIcons.listMusic,
                                            // size: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Opacity(
                                        opacity: percentageScrolled,
                                        child: Column(
                                          children: [
                                            const Divider(),
                                            Expanded(
                                              child:
                                                  BlocBuilder<
                                                    SongDetailCubit,
                                                    SongDetailState
                                                  >(
                                                    builder: (context, state) {
                                                      return ListView.builder(
                                                        itemCount:
                                                            state.songs.length,
                                                        itemBuilder:
                                                            (context, index) {
                                                              return ListTile(
                                                                leading: Icon(
                                                                  LucideIcons
                                                                      .music,
                                                                ),
                                                                title: Text(
                                                                  state
                                                                      .songs[index]
                                                                      .title,
                                                                ),
                                                              );
                                                            },
                                                      );
                                                    },
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAlbumArt(
    BuildContext context,
    double screenWidth,
    double percentageScrolled,
  ) {
    // Responsywny rozmiar - maksymalnie 70% szerokości ekranu, ale nie więcej niż 320px
    // final size = (screenWidth * 0.7).clamp(200.0, 320.0);
    final size = ((screenWidth * 0.7) * (1 - percentageScrolled)).clamp(
      54.0,
      320.0,
    );

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
            color: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Icon(
        LucideIcons.music,
        size: (80 * (1 - percentageScrolled)).clamp(24.0, 80.0),
        color: Colors.white.withValues(alpha: 0.9),
      ),
    );
  }

  Widget _buildAlbumArtSmall(
    BuildContext context,
    double percentageScrolled,
  ) {
    // Responsywny rozmiar - maksymalnie 70% szerokości ekranu, ale nie więcej niż 320px

    final size = (50 * (percentageScrolled));

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
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
            color: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Icon(
        LucideIcons.music,
        size: (24 * (percentageScrolled)),
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

  Widget _buildSongInfoSmall(BuildContext context, Project project) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BlocSelector<SongDetailCubit, SongDetailState, Song>(
          selector: (state) => state.currentSong,
          builder: (context, song) {
            return Text(
              song.title,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            );
          },
        ),
        Text(
          project.name,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
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
