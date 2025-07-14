import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:bandspace_mobile/features/song_detail/cubit/song_detail/song_detail_cubit.dart';
import 'package:bandspace_mobile/features/song_detail/cubit/song_detail/song_detail_state.dart';

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
              builder: (context, state) {
                return ListView.builder(
                  itemCount: state.songs.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: const Icon(LucideIcons.music),
                      title: Text(state.songs[index].title),
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