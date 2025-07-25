import 'dart:developer';

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:bandspace_mobile/core/cubits/audio_player/audio_player_cubit.dart';
import 'package:bandspace_mobile/core/cubits/audio_player/audio_player_state.dart';
import 'package:bandspace_mobile/features/song_detail/cubit/song_detail/song_detail_cubit.dart';
import 'package:bandspace_mobile/features/song_detail/cubit/song_detail/song_detail_state.dart';
import 'package:bandspace_mobile/features/song_detail/utils/player_math_utils.dart';
import 'package:bandspace_mobile/features/song_detail/widgets/song_detail/full_player_widget.dart';
import 'package:bandspace_mobile/features/song_detail/widgets/song_detail/mini_player_widget.dart';
import 'package:bandspace_mobile/features/song_detail/widgets/song_detail/song_list_widget.dart';
import 'package:bandspace_mobile/shared/models/project.dart';

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

  final _draggableScrollableController = DraggableScrollableController();
  Map<int, int> _songIndexMap = {};

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
          _songIndexMap = <int, int>{};
          for (int i = 0; i < state.downloadUrls.songUrls.length; i++) {
            _songIndexMap[state.downloadUrls.songUrls[i].songId] = i;
          }

          context.read<AudioPlayerCubit>().loadPlaylist(
            state.downloadUrls.songUrls.map((item) => item.url).toList(),
            initialIndex: _songIndexMap[state.currentSong.id] ?? 0,
          );
        }
        if (state is SongDetailReady) {
          final currentIndex = _songIndexMap[state.currentSong.id];
          if (currentIndex != null) {
            context.read<AudioPlayerCubit>().playTrackAt(currentIndex);
          }
        }
      },
      child: BlocListener<AudioPlayerCubit, AudioPlayerState>(
        listener: (context, state) {
          log(state.toString());

          if (state.isReady) {
            context.read<SongDetailCubit>().setReady();
          }

          final currentIndex = state.currentIndex;
          if (currentIndex != null) {
            final songDetailState = context.read<SongDetailCubit>().state;
            if (currentIndex >= 0 &&
                currentIndex < songDetailState.songs.length) {
              final songUnderIndex = songDetailState.songs[currentIndex];
              final currentSong = songDetailState.currentSong;
              if (songUnderIndex != currentSong) {
                context.read<SongDetailCubit>().selectSong(songUnderIndex);
              }
            }
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
                    PlayerMathUtils.calculateMinDraggableScrollSize(
                      maxHeight,
                      _minBottomHeight,
                    );

                final maxDraggableScrollSize =
                    PlayerMathUtils.calculateMaxDraggableScrollSize(
                      _minBottomHeight,
                      maxHeight,
                    );

                return Stack(
                  children: [
                    SizedBox(
                      height: playerHeight,
                      child: ListenableBuilder(
                        listenable: _draggableScrollableController,
                        builder: (context, _) {
                          final percentageScrolled =
                              _draggableScrollableController.isAttached
                              ? PlayerMathUtils.calculatePercentageScrolled(
                                  _draggableScrollableController.pixels,
                                  _minBottomHeight,
                                  maxHeight,
                                )
                              : 0.0;

                          return Stack(
                            children: [
                              MiniPlayerWidget(
                                project: widget.project,
                                opacity: percentageScrolled,
                                onTap: () {
                                  _draggableScrollableController.animateTo(
                                    0.0,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                },
                              ),
                              FullPlayerWidget(
                                project: widget.project,
                                screenWidth: screenWidth,
                                percentageScrolled: percentageScrolled,
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
                              final percentageScrolled =
                                  PlayerMathUtils.calculatePercentageScrolled(
                                    _draggableScrollableController.pixels,
                                    _minBottomHeight,
                                    maxHeight,
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
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: SongListWidget(
                                        opacity: percentageScrolled,
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
}
