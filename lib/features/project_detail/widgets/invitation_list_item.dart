import 'package:flutter/material.dart';

import 'package:gap/gap.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:bandspace_mobile/shared/models/project_invitation.dart';

class InvitationListItem extends StatelessWidget {
  final ProjectInvitation invitation;
  final VoidCallback? onCancel;

  const InvitationListItem({super.key, required this.invitation, this.onCancel});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _buildIcon(context),
          const Gap(12),
          Expanded(child: _buildInfo(context)),
          _buildActions(context),
        ],
      ),
    );
  }

  Widget _buildIcon(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: _getStatusColor(context).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(_getStatusIcon(), color: _getStatusColor(context), size: 20),
    );
  }

  Widget _buildInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          invitation.email,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Gap(4),
        Text(
          _getStatusText(),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: _getStatusColor(context),
          ),
        ),
        const Gap(2),
        Text(
          'Zaproszony przez ${invitation.invitedBy.name ?? invitation.invitedBy.email}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    if (invitation.status != ProjectInvitationStatus.pending || onCancel == null) {
      return const SizedBox.shrink();
    }

    return IconButton(
      onPressed: onCancel,
      icon: Icon(
        LucideIcons.x,
        color: Theme.of(context).colorScheme.error,
        size: 20,
      ),
      tooltip: 'Anuluj zaproszenie',
    );
  }

  IconData _getStatusIcon() {
    switch (invitation.status) {
      case ProjectInvitationStatus.pending:
        return LucideIcons.mail;
      case ProjectInvitationStatus.accepted:
        return LucideIcons.check;
      case ProjectInvitationStatus.rejected:
        return LucideIcons.x;
    }
  }

  String _getStatusText() {
    switch (invitation.status) {
      case ProjectInvitationStatus.pending:
        return 'Oczekuje';
      case ProjectInvitationStatus.accepted:
        return 'Zaakceptowane';
      case ProjectInvitationStatus.rejected:
        return 'Odrzucone';
    }
  }

  Color _getStatusColor(BuildContext context) {
    switch (invitation.status) {
      case ProjectInvitationStatus.pending:
        return Colors.orange;
      case ProjectInvitationStatus.accepted:
        return Colors.green;
      case ProjectInvitationStatus.rejected:
        return Theme.of(context).colorScheme.error;
    }
  }
}
