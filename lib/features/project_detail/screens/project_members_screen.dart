import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:bandspace_mobile/features/project_detail/cubit/project_members/project_members_cubit.dart';
import 'package:bandspace_mobile/features/project_detail/cubit/project_members/project_members_state.dart';
import 'package:bandspace_mobile/features/project_detail/widgets/invite_user_sheet.dart';
import 'package:bandspace_mobile/features/project_detail/widgets/project_members/empty_members_state.dart';
import 'package:bandspace_mobile/features/project_detail/widgets/project_members/member_list_item.dart';
import 'package:bandspace_mobile/shared/models/project.dart';
import 'package:bandspace_mobile/shared/models/project_user.dart';
import 'package:bandspace_mobile/shared/repositories/projects_repository.dart';

/// Ekran wyświetlający członków projektu
class ProjectMembersScreen extends StatelessWidget {
  final Project project;

  const ProjectMembersScreen({super.key, required this.project});

  static Widget create(Project project) {
    return BlocProvider(
      create: (context) => ProjectMembersCubit(
        projectsRepository: context.read<ProjectsRepository>(),
        projectId: project.id,
      ),
      child: ProjectMembersScreen(project: project),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Członkowie projektu',
        ),
      ),
      body: BlocBuilder<ProjectMembersCubit, ProjectMembersState>(
        builder: (context, state) {
          return switch (state) {
            ProjectMembersInitial() => const SizedBox(),
            ProjectMembersLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
            ProjectMembersLoadSuccess() => _buildMembersList(
              context,
              state.members,
            ),
            ProjectMembersLoadFailure() => _buildErrorState(
              context,
              state.message,
            ),
            _ => const SizedBox(),
          };
        },
      ),
    );
  }

  Widget _buildMembersList(BuildContext context, List<ProjectMember> members) {
    if (members.isEmpty) {
      return _buildEmptyState(context);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                LucideIcons.users,
                color: Theme.of(context).colorScheme.onSurface,
                size: 20,
              ),
              const Gap(8),
              Text(
                'Członkowie (${members.length})',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => InviteUserSheet.show(context, project),
                icon: const Icon(LucideIcons.userPlus),
                label: const Text('Zaproś'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: members.length,
            separatorBuilder: (context, index) => const Gap(8),
            itemBuilder: (context, index) {
              final member = members[index];
              return MemberListItem(member: member.user);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return const EmptyMembersState();
  }

  Widget _buildErrorState(BuildContext context, String? errorMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.x,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const Gap(16),
            Text(
              'Wystąpił błąd podczas ładowania członków projektu',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  errorMessage,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () =>
                  context.read<ProjectMembersCubit>().refreshProjectMembers(),

              child: const Text('Spróbuj ponownie'),
            ),
          ],
        ),
      ),
    );
  }

  // void _navigateToInviteUser(BuildContext context) {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(builder: (context) => InviteUserScreen.create(project)),
  //   );
  // }
}
