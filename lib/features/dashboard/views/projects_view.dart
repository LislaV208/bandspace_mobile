import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bandspace_mobile/core/widgets/load_failure_view.dart';
import 'package:bandspace_mobile/features/dashboard/cubit/projects/projects_cubit.dart';
import 'package:bandspace_mobile/features/dashboard/cubit/projects/projects_state.dart';
import 'package:bandspace_mobile/features/dashboard/widgets/projects_list.dart';

class ProjectsView extends StatelessWidget {
  const ProjectsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
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
        const SizedBox(height: 32),
        Expanded(
          child: BlocBuilder<ProjectsCubit, ProjectsState>(
            builder: (context, state) {
              return switch (state) {
                ProjectsInitial() => const SizedBox(),
                ProjectsLoading() => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ),
                ),
                ProjectsLoadSuccess() => ProjectsList(
                  projects: state.projects,
                ),
                ProjectsLoadFailure() => LoadFailureView(
                  title: 'Bład pobierania projektów',
                  errorMessage: state.message,
                  onRetry: () =>
                      context.read<ProjectsCubit>().refreshProjects(),
                ),
                ProjectsState() => const SizedBox(),
              };
            },
          ),
        ),
      ],
    );
  }
}
