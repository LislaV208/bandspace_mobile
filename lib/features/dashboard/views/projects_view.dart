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
    return BlocBuilder<ProjectsCubit, ProjectsState>(
      builder: (context, state) {
        return switch (state) {
          ProjectsInitial() => const SliverToBoxAdapter(child: SizedBox()),
          ProjectsLoading() => SliverToBoxAdapter(
            child: Column(
              children: [
                _buildHeader(context, state),
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ),
                ),
              ],
            ),
          ),
          ProjectsReady() => ProjectsList(state: state),
          ProjectsLoadFailure() => SliverToBoxAdapter(
            child: Column(
              children: [
                _buildHeader(context, state),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: LoadFailureView(
                    title: 'Błąd pobierania projektów',
                    errorMessage: state.message,
                    onRetry: () =>
                        context.read<ProjectsCubit>().refreshProjects(),
                  ),
                ),
              ],
            ),
          ),
          ProjectsState() => const SliverToBoxAdapter(child: SizedBox()),
        };
      },
    );
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
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 4),
              Text(
                'Zarządzaj i organizuj swoje projekty muzyczne',
              ),
            ],
          ),
          Visibility(
            visible: state is ProjectsReady,
            child: IconButton(
              onPressed: () {
                context.read<ProjectsCubit>().refreshProjects();
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
