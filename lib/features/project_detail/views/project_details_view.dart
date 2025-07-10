import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:bandspace_mobile/features/project_detail/cubit/project_songs/project_songs_cubit.dart';
import 'package:bandspace_mobile/features/project_detail/cubit/project_songs/project_songs_state.dart';
import 'package:bandspace_mobile/features/project_detail/widgets/project_details/project_songs_list.dart';

class ProjectDetailsView extends StatelessWidget {
  const ProjectDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProjectSongsCubit, ProjectSongsState>(
      builder: (context, state) {
        return switch (state) {
          ProjectSongsInitial() => const SizedBox(),
          ProjectSongsLoading() => const Center(
            child: CircularProgressIndicator(),
          ),
          ProjectSongsLoadSuccess() => ProjectSongsList(
            songs: state.songs,
          ),
          ProjectSongsLoadFailure() => _buildErrorState(
            context,
            state.message,
          ),
          _ => const SizedBox(),
        };
      },
    );
  }

  Widget _buildErrorState(BuildContext context, String? errorMessage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.x,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Wystąpił błąd podczas ładowania utworów',
            // style: AppTextStyles.titleMedium.copyWith(
            //   color: AppColors.textSecondary,
            // ),
            textAlign: TextAlign.center,
          ),
          if (errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                errorMessage,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.read<ProjectSongsCubit>().refreshSongs(),
            style: ElevatedButton.styleFrom(
              // backgroundColor: AppColors.primary,
              // foregroundColor: AppColors.onPrimary,
            ),
            child: const Text('Spróbuj ponownie'),
          ),
        ],
      ),
    );
  }
}
