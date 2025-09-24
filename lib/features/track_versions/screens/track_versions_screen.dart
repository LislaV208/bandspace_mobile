import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bandspace_mobile/core/theme/app_colors.dart';
import 'package:bandspace_mobile/features/track_versions/cubit/add_track_version/add_track_version_cubit.dart';
import 'package:bandspace_mobile/features/track_versions/cubit/track_versions_cubit.dart';
import 'package:bandspace_mobile/features/track_versions/cubit/track_versions_state.dart';
import 'package:bandspace_mobile/features/track_versions/screens/add_track_version_screen.dart';
import 'package:bandspace_mobile/features/track_versions/widgets/track_versions_with_player_widget.dart';
import 'package:bandspace_mobile/shared/models/track.dart';
import 'package:bandspace_mobile/shared/repositories/projects_repository.dart';

class TrackVersionsScreen extends StatefulWidget {
  final Track track;
  final int projectId;

  const TrackVersionsScreen({
    super.key,
    required this.track,
    required this.projectId,
  });

  @override
  State<TrackVersionsScreen> createState() => _TrackVersionsScreenState();
}

class _TrackVersionsScreenState extends State<TrackVersionsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<TrackVersionsCubit>().initialize(
      projectId: widget.projectId,
      trackId: widget.track.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Wersje utworu',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              widget.track.title,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
      body: BlocBuilder<TrackVersionsCubit, TrackVersionsState>(
        builder: (context, state) {
          return switch (state) {
            TrackVersionsInitial() => const SizedBox.shrink(),
            TrackVersionsLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
            TrackVersionsError() => _buildErrorState(state.message),
            TrackVersionsWithData() => TrackVersionsWithPlayerWidget(
              state: state,
              onRefresh: () =>
                  context.read<TrackVersionsCubit>().refreshVersions(),
              onAddVersion: () => _navigateToAddVersion(),
            ),
          };
        },
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Błąd ładowania wersji',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<TrackVersionsCubit>().loadVersions();
            },
            child: const Text('Spróbuj ponownie'),
          ),
        ],
      ),
    );
  }

  void _navigateToAddVersion() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => AddTrackVersionCubit(
            repository: context.read<ProjectsRepository>(),
            projectId: widget.projectId,
            trackId: widget.track.id,
            track: widget.track,
          ),
          child: AddTrackVersionScreen(
            track: widget.track,
            projectId: widget.projectId,
          ),
        ),
      ),
    );

    // Jeśli wersja została dodana, odśwież listę
    if (result != null && mounted) {
      context.read<TrackVersionsCubit>().refreshVersions();
    }
  }
}
