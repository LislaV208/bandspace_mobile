import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:bandspace_mobile/features/song_detail/utils/player_math_utils.dart';
import 'package:bandspace_mobile/features/track_player/cubit/track_player_cubit.dart';
import 'package:bandspace_mobile/features/track_player/cubit/track_player_state.dart';
import 'package:bandspace_mobile/features/track_player/widgets/new_full_player_widget.dart';
import 'package:bandspace_mobile/features/track_player/widgets/new_mini_player_widget.dart';
import 'package:bandspace_mobile/features/track_player/widgets/track_list_widget.dart';
import 'package:bandspace_mobile/shared/models/project.dart';

class TrackPlayerView extends StatefulWidget {
  const TrackPlayerView({
    super.key,
    required this.project,
  });

  final Project project;

  @override
  State<TrackPlayerView> createState() => _TrackPlayerViewState();
}

class _TrackPlayerViewState extends State<TrackPlayerView> {
  final DraggableScrollableController _draggableScrollableController =
      DraggableScrollableController();
  static const _minBottomHeight = 68.0;

  @override
  void dispose() {
    _draggableScrollableController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TrackPlayerCubit, TrackPlayerState>(
      builder: (context, state) {
        return SafeArea(
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
                                _draggableScrollableController.size,
                                minDraggableScrollSize,
                                maxDraggableScrollSize,
                              )
                            : 0.0;

                        return Stack(
                          children: [
                            NewMiniPlayerWidget(
                              project: widget.project,
                              opacity: percentageScrolled,
                              onTap: () {
                                _draggableScrollableController.animateTo(
                                  maxDraggableScrollSize,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              },
                            ),
                            NewFullPlayerWidget(
                              project: widget.project,
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
                                _draggableScrollableController.isAttached
                                ? PlayerMathUtils.calculatePercentageScrolled(
                                    _draggableScrollableController.size,
                                    minDraggableScrollSize,
                                    maxDraggableScrollSize,
                                  )
                                : 0.0;

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
                                        onPressed: () {
                                          if (percentageScrolled >= 0.9) {
                                            _draggableScrollableController
                                                .animateTo(
                                                  minDraggableScrollSize,
                                                  duration: const Duration(
                                                    milliseconds: 400,
                                                  ),
                                                  curve: Curves.easeInOut,
                                                );
                                            return;
                                          }

                                          _draggableScrollableController
                                              .animateTo(
                                                maxDraggableScrollSize,
                                                duration: const Duration(
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
                                    child: TrackListWidget(
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
        );
      },
    );
  }
}
