import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bandspace_mobile/core/cubits/audio_player/audio_player_cubit.dart';
import 'package:bandspace_mobile/core/cubits/audio_player/audio_player_state.dart';
import 'package:bandspace_mobile/core/cubits/audio_player/player_status.dart';
import 'package:bandspace_mobile/features/song_detail/cubit/song_detail/song_detail_cubit.dart';
import 'package:bandspace_mobile/features/song_detail/cubit/song_detail/song_detail_state.dart';

import 'song_list_item_widget.dart';

class SongListWidget extends StatelessWidget {
  final double opacity;

  const SongListWidget({
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
            child: BlocBuilder<SongDetailCubit, SongDetailState>(
              builder: (context, songState) {
                return BlocBuilder<AudioPlayerCubit, AudioPlayerState>(
                  builder: (context, audioState) {
                    return ListView.builder(
                      itemCount: songState.songs.length,
                      padding: const EdgeInsets.only(top: 8),
                      itemBuilder: (context, index) {
                        final song = songState.songs[index];
                        final isCurrentSong =
                            song.id == songState.currentSong.id;
                        final isPlaying =
                            audioState.status == PlayerStatus.playing &&
                            isCurrentSong;

                        return SongListItemWidget(
                          song: song,
                          isCurrentSong: isCurrentSong,
                          isPlaying: isPlaying,
                          onTap: () {
                            context.read<AudioPlayerCubit>().playTrackAt(index);
                          },
                        );
                      },
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
