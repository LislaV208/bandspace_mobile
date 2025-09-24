import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:bandspace_mobile/core/theme/app_colors.dart';
import 'package:bandspace_mobile/features/track_versions/cubit/add_track_version/add_track_version_cubit.dart';
import 'package:bandspace_mobile/features/track_versions/cubit/track_versions_cubit.dart';
import 'package:bandspace_mobile/features/track_versions/cubit/track_versions_state.dart';
import 'package:bandspace_mobile/features/track_versions/screens/add_track_version_screen.dart';
import 'package:bandspace_mobile/features/track_versions/widgets/track_version_list_item.dart';
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
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      backgroundColor: AppColors.background,
      body: BlocBuilder<TrackVersionsCubit, TrackVersionsState>(
        builder: (context, state) {
          return switch (state) {
            TrackVersionsInitial() => const SizedBox.shrink(),
            TrackVersionsLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
            TrackVersionsError() => _buildErrorState(state.message),
            TrackVersionsWithData() => _buildVersionsList(state),
          };
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddVersion(),
        backgroundColor: AppColors.primary,
        child: const Icon(
          LucideIcons.plus,
          color: Colors.white,
        ),
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

  Widget _buildVersionsList(TrackVersionsWithData state) {
    if (state.versions.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.layers,
              size: 64,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: 16),
            Text(
              'Brak wersji',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Dodaj pierwszą wersję tego utworu',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<TrackVersionsCubit>().refreshVersions(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.versions.length,
        itemBuilder: (context, index) {
          final version = state.versions[index];
          final versionNumber = state.versions.length - index; // Od najnowszej
          final isLatest = index == 0; // Pierwsza w liście jest najnowsza

          return TrackVersionListItem(
            version: version,
            versionNumber: versionNumber,
            isLatest: isLatest,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Odtwarzanie wersji będzie wkrótce dostępne'),
                ),
              );
            },
          );
        },
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