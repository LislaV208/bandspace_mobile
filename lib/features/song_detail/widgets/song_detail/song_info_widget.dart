import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bandspace_mobile/features/song_detail/cubit/song_detail/song_detail_cubit.dart';
import 'package:bandspace_mobile/features/song_detail/cubit/song_detail/song_detail_state.dart';
import 'package:bandspace_mobile/shared/models/project.dart';
import 'package:bandspace_mobile/shared/models/song.dart';

class SongInfoWidget extends StatelessWidget {
  final Project project;
  final bool isCompact;

  const SongInfoWidget({
    super.key,
    required this.project,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: isCompact
          ? EdgeInsets.zero
          : const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisSize: isCompact ? MainAxisSize.min : MainAxisSize.max,
        crossAxisAlignment: isCompact
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          BlocSelector<SongDetailCubit, SongDetailState, Song>(
            selector: (state) => state.currentSong,
            builder: (context, song) {
              return Text(
                song.title,
                style: isCompact
                    ? Theme.of(context).textTheme.labelLarge?.copyWith()
                    : Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                textAlign: isCompact ? TextAlign.start : TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              );
            },
          ),
          if (!isCompact) const SizedBox(height: 8),
          BlocSelector<SongDetailCubit, SongDetailState, Song>(
            selector: (state) => state.currentSong,
            builder: (context, song) {
              return Row(
                mainAxisAlignment: isCompact
                    ? MainAxisAlignment.start
                    : MainAxisAlignment.center,
                children: [
                  Text(
                    project.name,
                    style: isCompact
                        ? Theme.of(context).textTheme.bodyMedium
                        : Theme.of(context).textTheme.bodyLarge,
                  ),
                  if (song.bpm != null)
                    Text(
                      ' • ${song.bpm} BPM',
                      style: isCompact
                          ? Theme.of(context).textTheme.bodyMedium
                          : Theme.of(context).textTheme.bodyLarge,
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
