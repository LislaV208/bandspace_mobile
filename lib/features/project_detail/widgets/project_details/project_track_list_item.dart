import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:bandspace_mobile/core/theme/theme.dart';
import 'package:bandspace_mobile/core/utils/date_format_utils.dart';
import 'package:bandspace_mobile/features/project_detail/cubit/project_detail/project_detail_cubit.dart';
import 'package:bandspace_mobile/features/track_player/screens/track_player_screen.dart';
// import 'package:bandspace_mobile/features/track_detail/screens/track_detail_screen.dart';
import 'package:bandspace_mobile/shared/models/track.dart';

class ProjectTrackListItem extends StatelessWidget {
  final List<Track> tracksList;
  final Track track;

  const ProjectTrackListItem({
    super.key,
    required this.tracksList,
    required this.track,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          // TODO: Navigate to TrackDetailScreen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TrackPlayerScreen.create(
                project: context.read<ProjectDetailCubit>().state.project,
                initialTrackId: track.id,
              ),
            ),
          );
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
          _buildTrackIcon(context),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  track.title,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormatUtils.formatRelativeTime(track.createdAt),
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

  Widget _buildTrackIcon(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.secondary,
            Theme.of(context).colorScheme.secondaryContainer,
          ],
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        LucideIcons.music4,
        size: 20,
        color: Colors.white.withAlpha(200),
      ),
    );
  }
}
