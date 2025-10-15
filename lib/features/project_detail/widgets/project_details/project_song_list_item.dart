import 'package:flutter/material.dart';

import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:bandspace_mobile/core/theme/theme.dart';
import 'package:bandspace_mobile/core/utils/formatters.dart';
import 'package:bandspace_mobile/shared/models/song.dart';

/// Komponent elementu listy utworów
class ProjectSongListItem extends StatelessWidget {
  final List<Song> songsList;
  final Song song;

  const ProjectSongListItem({
    super.key,
    required this.songsList,
    required this.song,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          print('Navigating to TrackPlayerScreen');
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (_) => TrackPlayerScreen.create(
          //       projectId: context.read<ProjectDetailCubit>().state.project.id,
          //       initialTrackId: song.id,
          //     ),
          //   ),
          // );
        },
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: _buildContent(context),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          _buildSongIcon(context),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  song.title,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  Formatters.formatRelativeTime(song.createdAt),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            LucideIcons.chevronRight,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }

  /// Buduje ikonę utworu
  Widget _buildSongIcon(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primaryContainer,
          ], // from-blue-900 to-indigo-900
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        LucideIcons.music,
        size: 20,
        color: Colors.white.withAlpha(200),
      ),
    );
  }
}
