import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:bandspace_mobile/features/dashboard/cubit/projects/projects_cubit.dart';
import 'package:bandspace_mobile/features/dashboard/cubit/projects/projects_state.dart';
import 'package:bandspace_mobile/features/dashboard/widgets/project_list_item.dart';

class ProjectsList extends StatelessWidget {
  final ProjectsReady state;

  const ProjectsList({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final projects = state.projects;

    if (projects.isEmpty) {
      return _buildEmptySliver(context);
    }

    return _buildProjectsSliver(context, projects);
  }

  Widget _buildEmptySliver(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 32, 16, 80),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    LucideIcons.folderPlus,
                    size: 48,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Nie masz jeszcze żadnych projektów',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Utwórz swój pierwszy projekt, aby rozpocząć',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectsSliver(BuildContext context, List projects) {
    return SliverToBoxAdapter(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(context),
          _buildRefreshStatusContent(context),
          ...projects.asMap().entries.map(
            (entry) {
              final index = entry.key;
              final project = entry.value;
              return Padding(
                padding: EdgeInsets.fromLTRB(
                  16.0,
                  index == 0 ? 0 : 8.0,
                  16.0,
                  8.0,
                ),
                child: ProjectListItem(project: project),
              );
            },
          ),
          const SizedBox(height: 80), // Space for FAB
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Moje projekty',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 4),
              Text(
                'Zarządzaj i organizuj swoje projekty muzyczne',
              ),
            ],
          ),
          IconButton(
            onPressed: () {
              context.read<ProjectsCubit>().refreshProjects();
            },
            icon: AnimatedRotation(
              duration: const Duration(milliseconds: 200),
              turns: state is ProjectsRefreshing ? 0.4 : 0,
              child: Icon(Icons.refresh),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRefreshStatusContent(BuildContext context) {
    return AnimatedCrossFade(
      sizeCurve: Curves.easeInOut,
      firstCurve: Curves.easeIn,
      secondCurve: Curves.easeOut,
      duration: const Duration(milliseconds: 300),
      firstChild: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: state is ProjectsRefreshFailure
              ? ListTile(
                  dense: true,
                  title: Text(
                    'Brak połączenia z internetem',
                  ),
                  textColor: Theme.of(context).colorScheme.onErrorContainer,
                  tileColor: Theme.of(context).colorScheme.errorContainer,
                  leading: Icon(
                    Icons.error_outline,
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                  subtitle: Text(
                    'Dane mogą być nieaktualne',
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 12,
                  children: [
                    SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.0,
                      ),
                    ),
                    Text('Odświeżanie danych...'),
                  ],
                ),
        ),
      ),
      secondChild: const SizedBox(),
      crossFadeState:
          state is ProjectsRefreshing || state is ProjectsRefreshFailure
          ? CrossFadeState.showFirst
          : CrossFadeState.showSecond,
    );
  }
}
