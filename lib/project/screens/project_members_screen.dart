import 'package:flutter/material.dart';

import 'package:gap/gap.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/models/project.dart';
import '../components/widgets/empty_members_state.dart';
import '../components/widgets/member_list_item.dart';

import 'invite_user_screen.dart';

/// Ekran wyświetlający członków projektu
class ProjectMembersScreen extends StatelessWidget {
  final Project project;

  const ProjectMembersScreen({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          _buildHeader(context),
          const Gap(16),
          _buildInviteButton(context),
          const Gap(16),
          Expanded(child: _buildMembersList(context)),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(
        'Członkowie projektu',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).colorScheme.onSurface),
      ),
      leading: IconButton(icon: const Icon(LucideIcons.arrowLeft), onPressed: () => Navigator.pop(context)),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(LucideIcons.users, color: Theme.of(context).colorScheme.onSurface, size: 20),
          const Gap(8),
          Text(
            project.name,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${project.membersCount}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }

  Widget _buildMembersList(BuildContext context) {
    if (project.members.isEmpty) {
      return _buildEmptyState(context);
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: project.members.length,
      separatorBuilder: (context, index) => const Gap(8),
      itemBuilder: (context, index) {
        final member = project.members[index];
        return MemberListItem(member: member);
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return const EmptyMembersState();
  }

  void _navigateToInviteUser(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => InviteUserScreen.create(project)));
  }
}
