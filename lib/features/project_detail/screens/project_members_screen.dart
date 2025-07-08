import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:bandspace_mobile/features/project_detail/cubit/project_members_cubit.dart';
import 'package:bandspace_mobile/features/project_detail/cubit/project_members_state.dart';
import 'package:bandspace_mobile/features/project_detail/repository/project_members_repository.dart';
import 'package:bandspace_mobile/features/project_detail/widgets/empty_members_state.dart';
import 'package:bandspace_mobile/features/project_detail/widgets/member_list_item.dart';
import 'package:bandspace_mobile/shared/models/project.dart';
import 'package:bandspace_mobile/shared/models/project_member.dart';
import 'package:bandspace_mobile/shared/models/user.dart';

/// Ekran wyświetlający członków projektu
class ProjectMembersScreen extends StatelessWidget {
  final Project project;

  const ProjectMembersScreen({super.key, required this.project});

  static Widget create(Project project) {
    return BlocProvider(
      create: (context) => ProjectMembersCubit(
        projectMembersRepository: context.read<ProjectMembersRepository>(),
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
      body: Column(
        children: [
          // _buildHeader(context),
          // const Gap(16),
          // _buildInviteButton(context),
          // const Gap(16),
          Expanded(
            child: BlocBuilder<ProjectMembersCubit, ProjectMembersState>(
              builder: (context, state) {
                return switch (state.status) {
                  ProjectMembersStatus.initial ||
                  ProjectMembersStatus.loading => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  ProjectMembersStatus.error => _buildErrorState(
                    context,
                    state.errorMessage,
                  ),
                  ProjectMembersStatus.success => _buildMembersList(
                    context,
                    state.members,
                  ),
                };
              },
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildHeader(BuildContext context) {
  //   return ListTile(
  //     leading: Icon(
  //       LucideIcons.users,
  //       color: Theme.of(context).colorScheme.onSurface,
  //       size: 20,
  //     ),
  //     title: Text(
  //       project.name,
  //       style: Theme.of(context).textTheme.titleMedium?.copyWith(
  //         color: Theme.of(context).colorScheme.onSurface,
  //       ),
  //     ),
  //     trailing: Container(
  //       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  //       decoration: BoxDecoration(
  //         color: Theme.of(
  //           context,
  //         ).colorScheme.primary.withValues(alpha: 0.5),
  //         borderRadius: BorderRadius.circular(12),
  //       ),
  //       child: Text(
  //         '${project.membersCount}',
  //         style: Theme.of(context).textTheme.bodySmall?.copyWith(
  //           // color: Theme.of(context).colorScheme.primary,
  //           fontWeight: FontWeight.w600,
  //         ),
  //       ),
  //     ),
  //   );
  //   // return Padding(
  //   //   padding: const EdgeInsets.all(16),
  //   //   child: Row(
  //   //     children: [
  //   //       Icon(
  //   //         LucideIcons.users,
  //   //         color: Theme.of(context).colorScheme.onSurface,
  //   //         size: 20,
  //   //       ),
  //   //       const Gap(8),
  //   //       Text(
  //   //         project.name,
  //   //         style: Theme.of(context).textTheme.titleMedium?.copyWith(
  //   //           color: Theme.of(context).colorScheme.onSurface,
  //   //         ),
  //   //       ),
  //   //       const Spacer(),
  //   //       Container(
  //   //         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  //   //         decoration: BoxDecoration(
  //   //           color: Theme.of(
  //   //             context,
  //   //           ).colorScheme.primary.withValues(alpha: 0.1),
  //   //           borderRadius: BorderRadius.circular(12),
  //   //         ),
  //   //         child: Text(
  //   //           '${project.membersCount}',
  //   //           style: Theme.of(context).textTheme.bodySmall?.copyWith(
  //   //             color: Theme.of(context).colorScheme.primary,
  //   //             fontWeight: FontWeight.w600,
  //   //           ),
  //   //         ),
  //   //       ),
  //   //     ],
  //   //   ),
  //   // );
  // }

  Widget _buildInviteButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => _navigateToInviteUser(context),
          icon: const Icon(LucideIcons.userPlus),
          label: const Text('Zaproś użytkownika'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMembersList(BuildContext context, List<ProjectMember> members) {
    if (members.isEmpty) {
      return _buildEmptyState(context);
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: members.length,
      separatorBuilder: (context, index) => const Gap(8),
      itemBuilder: (context, index) {
        final member = members[index];
        return MemberListItem(member: member.user);
      },
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
                  context.read<ProjectMembersCubit>().loadProjectMembers(),

              child: const Text('Spróbuj ponownie'),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToInviteUser(BuildContext context) {
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (context) => InviteUserScreen.create(project)),
    // );
  }
}
