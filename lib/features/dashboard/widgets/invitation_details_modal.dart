import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:bandspace_mobile/shared/models/project_invitation.dart';

import '../cubit/user_invitations_cubit.dart';
import '../cubit/user_invitations_state.dart';

/// Modal do wyświetlania szczegółów zaproszenia i jego obsługi
class InvitationDetailsModal extends StatelessWidget {
  final ProjectInvitation invitation;

  const InvitationDetailsModal({
    super.key,
    required this.invitation,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserInvitationsCubit, UserInvitationsState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
          context.read<UserInvitationsCubit>().clearError();
        }

        if (state.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.successMessage!),
              backgroundColor: Colors.green,
            ),
          );
          context.read<UserInvitationsCubit>().clearSuccess();

          Navigator.pop(context);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(16),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHandle(),
              const Gap(20),
              _buildHeader(context),
              const Gap(24),
              _buildProjectInfo(context),
              const Gap(24),
              _buildInviterInfo(context),
              const Gap(32),
              _buildActions(context),
              const Gap(20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      width: 40,
      height: 4,
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              LucideIcons.mail,
              color: Colors.orange,
              size: 24,
            ),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Zaproszenie do projektu',
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const Gap(2),
                Text(
                  'Otrzymałeś zaproszenie do współpracy',
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectInfo(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            LucideIcons.folder,
            color: Theme.of(context).colorScheme.primary,
            size: 24,
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  invitation.project?.name ?? 'Projekt',
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const Gap(4),
                Text(
                  'Projekt muzyczny',
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInviterInfo(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.1),
            child: Text(
              () {
                final name = invitation.invitedByUser?.name;
                final email = invitation.invitedByUser?.email;

                if (name?.isNotEmpty == true) {
                  return name![0].toUpperCase();
                } else if (email?.isNotEmpty == true) {
                  return email![0].toUpperCase();
                } else {
                  return '?';
                }
              }(),
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  invitation.invitedByUser?.name ??
                      invitation.invitedByUser?.email ??
                      'Nieznany użytkownik',
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const Gap(2),
                Text(
                  'Zaprosił Cię do projektu',
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return BlocBuilder<UserInvitationsCubit, UserInvitationsState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: state.isProcessingInvitation
                      ? null
                      : () => _rejectInvitation(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(
                      context,
                    ).colorScheme.error,
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.error,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Odrzuć'),
                ),
              ),
              const Gap(12),
              Expanded(
                child: ElevatedButton(
                  onPressed: state.isProcessingInvitation
                      ? null
                      : () => _acceptInvitation(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primary,
                    foregroundColor: Theme.of(
                      context,
                    ).colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: state.isProcessingInvitation
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Theme.of(
                              context,
                            ).colorScheme.onPrimary,
                          ),
                        )
                      : const Text('Akceptuj'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _acceptInvitation(BuildContext context) {
    if (invitation.token != null) {
      context.read<UserInvitationsCubit>().acceptInvitation(
        invitation.token!,
      );
    }
  }

  void _rejectInvitation(BuildContext context) {
    if (invitation.token != null) {
      context.read<UserInvitationsCubit>().rejectInvitation(
        invitation.token!,
      );
    }
  }
}
