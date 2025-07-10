import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:bandspace_mobile/features/dashboard/cubit/projects/projects_cubit.dart';
import 'package:bandspace_mobile/features/dashboard/widgets/dashboard_project_card.dart';
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
      child: ListView(
        padding: const EdgeInsets.only(bottom: 56.0),
        children: projects.map(
          (project) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: DashboardProjectCard(
                project: project,
                createdTime: project.createdAt,
              ),
            );
          },
        ).toList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.folderPlus,
              size: 48,
              color: Color(0xFF9CA3AF),
            ),
            SizedBox(height: 16),
            Text(
              'Nie masz jeszcze żadnych projektów',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Color(0xFF9CA3AF),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Utwórz swój pierwszy projekt, aby rozpocząć',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
