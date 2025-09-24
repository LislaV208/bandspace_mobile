import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bandspace_mobile/features/track_versions/cubit/track_versions_cubit.dart';
import 'package:bandspace_mobile/features/track_versions/cubit/track_versions_state.dart';
import 'package:bandspace_mobile/features/track_versions/widgets/track_versions_list_widget.dart';
import 'package:bandspace_mobile/features/track_versions/widgets/track_versions_player_widget.dart';
import 'package:bandspace_mobile/shared/models/version.dart';

class TrackVersionsWithPlayerWidget extends StatelessWidget {
  final TrackVersionsWithData state;
  final VoidCallback onRefresh;
  final VoidCallback onAddVersion;

  const TrackVersionsWithPlayerWidget({
    super.key,
    required this.state,
    required this.onRefresh,
    required this.onAddVersion,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async => onRefresh(),
            child: TrackVersionsListWidget(
              versions: state.versions,
              currentVersion: state.currentVersion,
              onVersionSelected: (Version version) {
                context.read<TrackVersionsCubit>().selectVersion(version);
              },
              onAddVersion: onAddVersion,
            ),
          ),
        ),

        Container(
          height: 1,
          color: Theme.of(context).dividerColor,
        ),

        TrackVersionsPlayerWidget(
          currentVersion: state.currentVersion,
          isPlaying: state.playerUiStatus == PlayerUiStatus.playing,
          currentPosition: state.currentPosition,
          totalDuration: state.totalDuration,
          onPlayPause: () {
            context.read<TrackVersionsCubit>().togglePlayPause();
          },
          onPrevious: state.hasPrevious
              ? () {
                  context.read<TrackVersionsCubit>().playPrevious();
                }
              : null,
          onNext: state.hasNext
              ? () {
                  context.read<TrackVersionsCubit>().playNext();
                }
              : null,
          onSeek: (value) {
            context.read<TrackVersionsCubit>().seek(value);
          },
        ),
      ],
    );
  }
}
