import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:bandspace_mobile/core/theme/theme.dart';
import 'package:bandspace_mobile/features/project_detail/cubit/project_detail/project_detail_cubit.dart';
import 'package:bandspace_mobile/features/project_detail/cubit/project_detail/project_detail_state.dart';
import 'package:bandspace_mobile/features/project_detail/cubit/project_tracks/project_tracks_cubit.dart';
import 'package:bandspace_mobile/features/project_detail/screens/new_song_screen.dart';
import 'package:bandspace_mobile/features/project_detail/views/project_tracks_view.dart';
import 'package:bandspace_mobile/features/project_detail/widgets/project_details/manage_project_button.dart';
import 'package:bandspace_mobile/shared/models/project.dart';
import 'package:bandspace_mobile/shared/repositories/projects_repository.dart';

/// Ekran szczegółów projektu z listą utworów
class ProjectDetailScreen extends StatelessWidget {
  const ProjectDetailScreen({super.key});

  static Widget create(Project project) {
    return BlocProvider(
      create: (context) => ProjectDetailCubit(
        projectsRepository: context.read<ProjectsRepository>(),
        projectId: project.id,
        initialProject: project,
      ),
      child: ProjectDetailScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: BlocSelector<ProjectDetailCubit, ProjectDetailState, Project>(
          selector: (state) => state.project,
          builder: (context, project) {
            return Text(project.name);
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ManageProjectButton(),
          ),
        ],
      ),
      resizeToAvoidBottomInset: false,
      body: BlocProvider(
        create: (context) => ProjectTracksCubit(
          projectsRepository: context.read<ProjectsRepository>(),
          projectId: context.read<ProjectDetailCubit>().state.project.id,
        ),
        child: const ProjectTracksView(),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => NewSongScreen.create(
                context.read<ProjectDetailCubit>().state.project,
              ),
            ),
          );
        },
        icon: const Icon(LucideIcons.plus),
        label: const Text('Nowy utwór'),
      ),
    );
  }
}