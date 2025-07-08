import 'package:flutter/material.dart';

import 'package:gap/gap.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:bandspace_mobile/shared/models/project_invitation.dart';

/// Element zaproszenia w liście projektów
class InvitationItem extends StatelessWidget {
  final ProjectInvitation invitation;
  final VoidCallback onTap;

  const InvitationItem({
    super.key,
    required this.invitation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.orange.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildIcon(context),
                const Gap(12),
                Expanded(child: _buildContent(context)),
                _buildArrow(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(BuildContext context) {
    return Container(
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
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                invitation.project?.name ?? 'Projekt',
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'ZAPROSZENIE',
                style: Theme.of(context).textTheme.labelSmall
                    ?.copyWith(
                      color: Colors.orange,
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                    ),
              ),
            ),
          ],
        ),
        const Gap(4),
        Text(
          'Zaproszenie od ${invitation.invitedByUser?.name ?? invitation.invitedByUser?.email ?? 'użytkownika'}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const Gap(2),
        Text(
          _getTimeText(),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildArrow(BuildContext context) {
    return Icon(
      LucideIcons.chevronRight,
      color: Theme.of(context).colorScheme.onSurfaceVariant,
      size: 20,
    );
  }

  String _getTimeText() {
    final now = DateTime.now();
    final difference = now.difference(invitation.createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'dzień' : 'dni'} temu';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'godzinę' : 'godzin'} temu';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minutę' : 'minut'} temu';
    } else {
      return 'Właśnie teraz';
    }
  }
}
