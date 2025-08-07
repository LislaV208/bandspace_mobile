import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:bandspace_mobile/core/utils/date_format_utils.dart';
import 'package:bandspace_mobile/shared/cubits/user_invitations/user_invitations_cubit.dart';
import 'package:bandspace_mobile/shared/cubits/user_invitations/user_invitations_state.dart';
import 'package:bandspace_mobile/shared/models/project_invitation.dart';

/// Bottom sheet z szczegółami zaproszenia i akcjami accept/reject
class InvitationDetailsBottomSheet extends StatelessWidget {
  final ProjectInvitation invitation;

  const InvitationDetailsBottomSheet({
    super.key,
    required this.invitation,
  });

  static Future<bool?> show(
    BuildContext context,
    ProjectInvitation invitation,
  ) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          InvitationDetailsBottomSheet(invitation: invitation),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserInvitationsCubit, UserInvitationsState>(
      listener: (context, state) {
        if (state is UserInvitationsActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            ),
          );
          Navigator.of(
            context,
          ).pop(true); // true oznacza że została wykonana akcja
        } else if (state is UserInvitationsActionFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Theme.of(context).colorScheme.errorContainer,
            ),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const Gap(24),
                _buildProjectInfo(context),
                const Gap(24),
                _buildInviterInfo(context),
                const Gap(24),
                _buildDateInfo(context),
                const Gap(32),
                _buildActions(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.secondary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            LucideIcons.mail,
            size: 24,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        const Gap(16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Zaproszenie do projektu',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(
            LucideIcons.x,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildProjectInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Color(0xFF1E3A8A),
                  Color(0xFF312E81),
                ],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              LucideIcons.music,
              size: 20,
              color: Color(0xFF60A5FA),
            ),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  invitation.project?.name ?? 'Nieznany projekt',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.secondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              LucideIcons.user,
              size: 20,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Zapraszający',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const Gap(2),
                Text(
                  invitation.invitedBy?.name ??
                      invitation.invitedBy?.email ??
                      'Nieznany użytkownik',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateInfo(BuildContext context) {
    return Row(
      children: [
        Icon(
          LucideIcons.clock,
          size: 16,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const Gap(8),
        Text(
          'Otrzymano ${DateFormatUtils.formatRelativeTime(invitation.createdAt)}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    return BlocBuilder<UserInvitationsCubit, UserInvitationsState>(
      builder: (context, state) {
        final isLoading =
            state is UserInvitationsAccepting ||
            state is UserInvitationsRejecting;

        return Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : () => _acceptInvitation(context),
                icon: isLoading && state is UserInvitationsAccepting
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      )
                    : Icon(LucideIcons.check),
                label: Text('Akceptuj zaproszenie'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const Gap(12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: isLoading ? null : () => _rejectInvitation(context),
                icon: isLoading && state is UserInvitationsRejecting
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Theme.of(context).colorScheme.error,
                        ),
                      )
                    : Icon(LucideIcons.x),
                label: Text('Odrzuć zaproszenie'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                  side: BorderSide(
                    color: Theme.of(
                      context,
                    ).colorScheme.error.withValues(alpha: 0.5),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _acceptInvitation(BuildContext context) {
    context.read<UserInvitationsCubit>().acceptInvitation(invitation.id);
  }

  void _rejectInvitation(BuildContext context) {
    context.read<UserInvitationsCubit>().rejectInvitation(invitation.id);
  }
}
