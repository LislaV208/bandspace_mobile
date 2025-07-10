import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:bandspace_mobile/features/dashboard/cubit/projects/projects_cubit.dart';
import 'package:bandspace_mobile/features/dashboard/views/projects_view.dart';
import 'package:bandspace_mobile/features/dashboard/widgets/create_project_bottom_sheet.dart';
import 'package:bandspace_mobile/shared/repositories/projects_repository.dart';
import 'package:bandspace_mobile/shared/widgets/member_avatar.dart';
import 'package:bandspace_mobile/shared/widgets/user_drawer.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  static Widget create() {
    return BlocProvider(
      create: (context) => ProjectsCubit(
        projectsRepository: context.read<ProjectsRepository>(),
      ),
      child: const DashboardScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: UserDrawer(),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'BandSpace',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  Builder(
                    builder: (context) {
                      return GestureDetector(
                        onTap: () => Scaffold.of(context).openEndDrawer(),
                        child: UserAvatar(
                          size: 40,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ProjectsView(),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Builder(
        builder: (context) {
          return FloatingActionButton.extended(
            backgroundColor: Theme.of(context).colorScheme.secondary,
            onPressed: () async {
              final cubit = context.read<ProjectsCubit>();
              cubit.pauseUpdates();
              final created = await CreateProjectBottomSheet.show(context);

              if (created == true) {
                cubit.resumeUpdates();
                cubit.refreshProjects();
              }
            },
            label: const Text('Nowy projekt'),
            icon: const Icon(LucideIcons.plus),
          );
        },
      ),
    );
  }
}
