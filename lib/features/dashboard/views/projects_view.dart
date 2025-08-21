import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bandspace_mobile/core/widgets/load_failure_view.dart';
import 'package:bandspace_mobile/features/dashboard/cubit/projects/projects_cubit.dart';
import 'package:bandspace_mobile/features/dashboard/cubit/projects/projects_state.dart';
import 'package:bandspace_mobile/features/dashboard/widgets/projects_list.dart';
import 'package:bandspace_mobile/shared/cubits/user_invitations/user_invitations_cubit.dart';

class ProjectsView extends StatelessWidget {
  const ProjectsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        BlocBuilder<ProjectsCubit, ProjectsState>(
          builder: (context, state) => _buildHeader(context, state),
        ),
        BlocBuilder<ProjectsCubit, ProjectsState>(
          builder: (context, state) => _buildContent(context, state),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, ProjectsState state) {
    return switch (state) {
      ProjectsInitial() => const SizedBox(),
      ProjectsLoading() => const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      ),
      ProjectsReady() => ProjectsList(state: state),
      ProjectsLoadFailure() => Padding(
        padding: const EdgeInsets.all(16.0),
        child: LoadFailureView(
          title: 'Błąd pobierania projektów',
          errorMessage: state.message,
          onRetry: () => context.read<ProjectsCubit>().refreshProjects(),
        ),
      ),
      ProjectsState() => const SizedBox(),
    };
  }

  Widget _buildHeader(BuildContext context, ProjectsState state) {
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
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'Zarządzaj swoimi projektami muzycznymi',
              ),
            ],
          ),
          Visibility(
            visible: state is ProjectsReady,
            child: IconButton(
              onPressed: () {
                context.read<ProjectsCubit>().refreshProjects();
                context.read<UserInvitationsCubit>().refreshInvitations();
              },
              icon: AnimatedRotation(
                duration: const Duration(milliseconds: 200),
                turns: state is ProjectsRefreshing ? 0.4 : 0,
                child: Icon(Icons.refresh),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
