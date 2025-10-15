import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bandspace_mobile/features/track_player/cubit/track_player_cubit.dart';
import 'package:bandspace_mobile/features/track_player/cubit/track_player_state.dart';
import 'package:bandspace_mobile/features/track_player/widgets/track_list_item_widget.dart';

class TrackListWidget extends StatelessWidget {
  final double opacity;

  const TrackListWidget({
    super.key,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Column(
        children: [
          const Divider(),
          Expanded(
            child: BlocBuilder<TrackPlayerCubit, TrackPlayerState>(
              builder: (context, state) {
                return ListView.builder(
                  itemCount: state.tracks.length,
                  padding: const EdgeInsets.only(top: 8),
                  itemBuilder: (context, index) {
                    final track = state.tracks[index];
                    final isCurrentTrack = track.id == state.currentTrack?.id;
                    final isPlaying =
                        state.playerUiStatus == PlayerUiStatus.playing &&
                        isCurrentTrack;

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8.0,
                        horizontal: 16.0,
                      ),
                      child: TrackListItemWidget(
                        track: track,
                        isCurrentTrack: isCurrentTrack,
                        isPlaying: isPlaying,
                        onTap: () {
                          context
                              .read<TrackPlayerCubit>()
                              .onTracklistItemSelected(
                                index,
                              );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
