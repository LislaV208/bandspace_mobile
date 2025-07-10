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
    if (projects.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 32.0),
          child: Column(
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

    return RefreshIndicator(
      onRefresh: () async {
        await context.read<ProjectsCubit>().refreshProjects();
      },
      displacement: 0.0,
      color: Theme.of(context).colorScheme.tertiary,
      child: ListView(
        children: projects.map(
          (project) {
            // Formatowanie czasu utworzenia projektu
            final createdTime = _formatCreatedTime(
              project.createdAt,
            );

            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: DashboardProjectCard(
                project: project,
                createdTime: createdTime,
              ),
            );
          },
        ).toList(),
      ),
    );
  }

  // TODO: wyodrębnić do osobnego pliku
  /// Formatuje czas utworzenia projektu w formie względnej (np. "2h temu")
  String _formatCreatedTime(DateTime? createdAt) {
    if (createdAt == null) return 'niedawno';

    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1
          ? 'rok'
          : years < 5
          ? 'lata'
          : 'lat'} temu';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1
          ? 'miesiąc'
          : months < 5
          ? 'miesiące'
          : 'miesięcy'} temu';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'dzień' : 'dni'} temu';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h temu';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m temu';
    } else {
      return 'przed chwilą';
    }
  }
}
