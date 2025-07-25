import 'package:flutter/material.dart';

import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:bandspace_mobile/features/dashboard/cubit/projects/projects_state.dart';
import 'package:bandspace_mobile/features/dashboard/widgets/project_list_item.dart';

class ProjectsList extends StatelessWidget {
  final ProjectsReady state;

  const ProjectsList({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final projects = state.projects;

    if (projects.isEmpty) {
      return _buildEmptyState();
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 56.0),
      children: [
        AnimatedCrossFade(
          sizeCurve: Curves.easeInOut,
          firstCurve: Curves.easeIn,
          secondCurve: Curves.easeOut,
          duration: const Duration(milliseconds: 300),
          firstChild: Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
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
        ),
        ...projects.map(
          (project) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: ProjectListItem(
                project: project,
              ),
            );
          },
        ),
      ],
      // children: projects.map(
      //   (project) {
      //     return Padding(
      //       padding: const EdgeInsets.only(bottom: 16.0),
      //       child: ProjectListItem(
      //         project: project,
      //       ),
      //     );
      //   },
      // ).toList(),
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
