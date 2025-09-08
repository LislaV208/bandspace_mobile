import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bandspace_mobile/features/track_player/cubit/track_player_cubit.dart';
import 'package:bandspace_mobile/features/track_player/cubit/track_player_state.dart';
import 'package:bandspace_mobile/shared/models/project.dart';
import 'package:bandspace_mobile/shared/models/track.dart';

class TrackInfoWidget extends StatelessWidget {
  final Project project;
  final bool isCompact;

  const TrackInfoWidget({
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
          BlocSelector<TrackPlayerCubit, TrackPlayerState, Track?>(
            selector: (state) => state.currentTrack,
            builder: (context, track) {
              return Text(
                track?.title ?? '',
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
          Text(
            project.name,
            style: isCompact
                ? Theme.of(context).textTheme.bodyMedium
                : Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}
