import 'package:flutter/material.dart';

import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:bandspace_mobile/shared/models/project_invitation.dart';

import 'invitation_details_bottom_sheet.dart';

/// Komponent elementu otrzymanego zaproszenia dla listy projektów na dashboardzie.
class ReceivedInvitationListItem extends StatelessWidget {
  final ProjectInvitation invitation;

  const ReceivedInvitationListItem({
    super.key,
    required this.invitation,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showInvitationDetails(context),
        borderRadius: BorderRadius.circular(8),
        child: Ink(
          decoration: BoxDecoration(
            // Używamy różnego koloru dla zaproszeń aby je odróżnić od projektów
            color: Theme.of(
              context,
            ).colorScheme.secondaryContainer.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildContent(context),
            ],
          ),
        ),
      ),
    );
  }

  /// Buduje zawartość elementu zaproszenia z informacjami
  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            spacing: 16,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.secondary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Icon(
                    LucideIcons.mail,
                    size: 24,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            invitation.project?.name ?? 'Nieznany projekt',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Zaproszenie',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Od: ${invitation.invitedBy?.name ?? invitation.invitedBy?.email ?? 'Nieznany użytkownik'}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Pokazuje bottom sheet ze szczegółami zaproszenia
  void _showInvitationDetails(BuildContext context) {
    InvitationDetailsBottomSheet.show(context, invitation);
  }
}
