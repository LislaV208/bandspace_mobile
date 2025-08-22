import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bandspace_mobile/features/song_detail/cubit/song_detail/song_detail_cubit.dart';
import 'package:bandspace_mobile/features/song_detail/cubit/song_detail/song_detail_state.dart';
import 'package:bandspace_mobile/shared/models/song.dart';

class SongDetailsWidget extends StatelessWidget {
  const SongDetailsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<SongDetailCubit, SongDetailState, Song>(
      selector: (state) => state.currentSong,
      builder: (context, song) {
        if (song.bpm == null) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(32.0, 16.0, 32.0, 0.0),
          child: _buildDetailRow(
            context,
            icon: Icons.speed,
            label: 'Tempo',
            value: '${song.bpm} BPM',
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
