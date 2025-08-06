import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:bandspace_mobile/shared/cubits/user_invitations/user_invitations_cubit.dart';
import 'package:bandspace_mobile/shared/cubits/user_invitations/user_invitations_state.dart';
import 'package:bandspace_mobile/shared/models/project_invitation.dart';

import 'invitation_card.dart';

class InvitationsSection extends StatelessWidget {
  const InvitationsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserInvitationsCubit, UserInvitationsState>(
      listener: (context, state) {
        if (state is UserInvitationsLoadFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Theme.of(context).colorScheme.errorContainer,
            ),
          );
        } else if (state is UserInvitationsActionFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      },
      child: BlocBuilder<UserInvitationsCubit, UserInvitationsState>(
        builder: (context, state) {
          return switch (state) {
            UserInvitationsLoadSuccess() when state.invitations.isNotEmpty =>
              _buildInvitationsSection(context, state.invitations),
            UserInvitationsActionSuccess() when state.invitations.isNotEmpty =>
              _buildInvitationsSection(context, state.invitations),
            _ => const SizedBox.shrink(),
          };
        },
      ),
    );
  }

  Widget _buildInvitationsSection(
    BuildContext context,
    List<ProjectInvitation> invitations,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(
                LucideIcons.mail,
                color: Theme.of(context).colorScheme.onSurface,
                size: 20,
              ),
              const Gap(8),
              Text(
                'Zaproszenia',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Gap(8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${invitations.length}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Gap(12),
        SizedBox(
          height: 140,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: invitations.length,
            separatorBuilder: (context, index) => const Gap(12),
            itemBuilder: (context, index) {
              final invitation = invitations[index];
              return InvitationCard(invitation: invitation);
            },
          ),
        ),
        const Gap(24),
      ],
    );
  }
}
