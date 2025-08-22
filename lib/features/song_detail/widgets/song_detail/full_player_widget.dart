import 'package:flutter/material.dart';

import 'package:bandspace_mobile/features/song_detail/widgets/song_detail/song_details_widget.dart';
import 'package:bandspace_mobile/shared/models/project.dart';

import 'album_art_widget.dart';
import 'player_controls_widget.dart';
import 'progress_bar_widget.dart';
import 'song_info_widget.dart';

class FullPlayerWidget extends StatelessWidget {
  final Project project;
  final double screenWidth;
  final double percentageScrolled;

  const FullPlayerWidget({
    super.key,
    required this.project,
    required this.screenWidth,
    required this.percentageScrolled,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: (1 - percentageScrolled).clamp(0.0, 1.0),
      child: Column(
        children: [
          const SongDetailsWidget(),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                AlbumArtWidget(
                  size: ((screenWidth * 0.7) * (1 - percentageScrolled)).clamp(
                    54.0,
                    320.0,
                  ),
                  borderRadius: 20,
                  iconSize: (80 * (1 - percentageScrolled)).clamp(24.0, 80.0),
                ),
                SongInfoWidget(project: project),
                const ProgressBarWidget(),
                const PlayerControlsWidget(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
