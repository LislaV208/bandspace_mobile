import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bandspace_mobile/features/track_player/cubit/track_player_cubit.dart';
import 'package:bandspace_mobile/features/track_player/cubit/track_player_state.dart';
import 'package:bandspace_mobile/shared/models/version.dart';

class TrackVersionDetailsWidget extends StatelessWidget {
  const TrackVersionDetailsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<TrackPlayerCubit, TrackPlayerState, Version?>(
      selector: (state) => state.currentTrack?.mainVersion,
      builder: (context, trackVersion) {
        return AnimatedOpacity(
          duration: const Duration(milliseconds: 150),
          opacity: trackVersion?.bpm != null ? 1.0 : 0.0,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(32.0, 16.0, 32.0, 0.0),
            child: _buildDetailRow(
              context,
              icon: Icons.speed,
              label: 'Tempo',
              value: '${trackVersion?.bpm ?? ''} BPM',
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 16),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        const Spacer(),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
