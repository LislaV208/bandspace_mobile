import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:bandspace_mobile/features/dashboard/cubit/projects/projects_cubit.dart';
import 'package:bandspace_mobile/features/dashboard/widgets/project_list_item.dart';
import 'package:bandspace_mobile/shared/models/project.dart';

class ProjectsList extends StatelessWidget {
  final List<Project> projects;

  const ProjectsList({super.key, required this.projects});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await context.read<ProjectsCubit>().refreshProjects();
      },
      displacement: 0.0,
      color: Theme.of(context).colorScheme.tertiary,
      child: projects.isEmpty
          ? _buildEmptyState()
          : ListView(
              padding: const EdgeInsets.only(bottom: 56.0),
              children: projects.map(
                (project) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: ProjectListItem(
                      project: project,
                    ),
                  );
                },
              ).toList(),
            ),
    );
  }

  Widget _buildEmptyState() {
    return CustomScrollView(
      slivers: [
        SliverFillRemaining(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 56),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  LucideIcons.folderPlus,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'Nie masz jeszcze żadnych projektów',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Utwórz swój pierwszy projekt, aby rozpocząć',
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
