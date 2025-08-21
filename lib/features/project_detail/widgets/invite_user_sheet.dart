import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:bandspace_mobile/features/project_detail/cubit/project_invitations_cubit.dart';
import 'package:bandspace_mobile/features/project_detail/cubit/project_invitations_state.dart';
import 'package:bandspace_mobile/features/project_detail/widgets/invitation_list_item.dart';
import 'package:bandspace_mobile/shared/models/project.dart';
import 'package:bandspace_mobile/shared/models/project_invitation.dart';
import 'package:bandspace_mobile/shared/repositories/invitations_repository.dart';

class InviteUserSheet extends StatefulWidget {
  final Project project;

  const InviteUserSheet({super.key, required this.project});

  @override
  State<InviteUserSheet> createState() => _InviteUserSheetState();

  static Widget create(Project project) {
    return BlocProvider(
      create: (context) => ProjectInvitationsCubit(
        invitationsRepository: context.read<InvitationsRepository>(),
        projectId: project.id,
      )..loadInvitations(),
      child: InviteUserSheet(project: project),
    );
  }

  static Future<void> show(BuildContext context, Project project) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => InviteUserSheet.create(project),
    );
  }
}

class _InviteUserSheetState extends State<InviteUserSheet> {
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProjectInvitationsCubit, ProjectInvitationsState>(
      listener: (context, state) {
        if (state is ProjectInvitationsSendSuccess) {
          _emailController.clear();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SafeArea(
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.9,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                _buildHeader(context),
                const Gap(24),
                _buildInviteForm(context),
                const Gap(24),
                Expanded(
                  child: _buildInvitationsList(context),
                ),
                SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorDisplay(
    BuildContext context,
    ProjectInvitationsState state,
  ) {
    String? errorMessage;

    if (state is ProjectInvitationsSendFailure) {
      errorMessage = state.message ?? 'Błąd podczas wysyłania zaproszenia';
    } else if (state is ProjectInvitationsLoadFailure) {
      errorMessage = state.message ?? 'Błąd podczas ładowania zaproszeń';
    } else if (state is ProjectInvitationsCancelFailure) {
      errorMessage = state.message ?? 'Błąd podczas anulowania zaproszenia';
    }

    if (errorMessage == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.error.withAlpha(51),
          width: 1,
        ),
      ),
      child: Text(
        errorMessage,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onErrorContainer,
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 4,
          margin: const EdgeInsets.only(top: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.outline,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const Gap(20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(
                LucideIcons.userPlus,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              const Gap(12),
              Text(
                'Zaproś do projektu',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInviteForm(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            BlocBuilder<ProjectInvitationsCubit, ProjectInvitationsState>(
              builder: (context, state) => _buildErrorDisplay(context, state),
            ),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Adres email',
                hintText: 'Wprowadź adres email użytkownika',
                prefixIcon: Icon(LucideIcons.mail),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Wprowadź adres email';
                }
                if (!RegExp(
                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                ).hasMatch(value)) {
                  return 'Wprowadź poprawny adres email';
                }
                return null;
              },
            ),
            const Gap(16),
            BlocBuilder<ProjectInvitationsCubit, ProjectInvitationsState>(
              builder: (context, state) {
                final isSending = state is ProjectInvitationsSending;
                final isCanceling = state is ProjectInvitationsCanceling;
                final isLoading = isSending || isCanceling;

                return ElevatedButton(
                  onPressed: isLoading ? null : _sendInvitation,

                  child: isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        )
                      : const Text('Wyślij zaproszenie'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvitationsList(BuildContext context) {
    return BlocBuilder<ProjectInvitationsCubit, ProjectInvitationsState>(
      builder: (context, state) {
        return switch (state) {
          ProjectInvitationsLoading() => const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          ),
          ProjectInvitationsWithData() when state.invitations.isEmpty =>
            Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    LucideIcons.mail,
                    size: 48,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const Gap(16),
                  Text(
                    'Brak wysłanych zaproszeń',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const Gap(8),
                  Text(
                    'Zaproszenia pojawią się tutaj po wysłaniu',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ProjectInvitationsWithData() => _buildInvitationsListContent(
            context,
            state,
          ),
          _ => const SizedBox(),
        };
      },
    );
  }

  Widget _buildInvitationsListContent(
    BuildContext context,
    ProjectInvitationsWithData state,
  ) {
    final invitations = state.invitations;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Wysłane zaproszenia (${invitations.length})',
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        const Gap(12),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: invitations.length,
            separatorBuilder: (context, index) => const Gap(8),
            itemBuilder: (context, index) {
              final invitation = invitations[index];
              return InvitationListItem(
                invitation: invitation,
                onCancel: invitation.status == ProjectInvitationStatus.pending
                    ? () => _cancelInvitation(invitation.id)
                    : null,
              );
            },
          ),
        ),
      ],
    );
  }

  void _sendInvitation() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<ProjectInvitationsCubit>().sendInvitation(
        _emailController.text.trim(),
      );
    }
  }

  void _cancelInvitation(int invitationId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          'Anuluj zaproszenie',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        content: Text(
          'Czy na pewno chcesz anulować to zaproszenie?',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Anuluj'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<ProjectInvitationsCubit>().cancelInvitation(
                invitationId,
              );
            },
            child: Text(
              'Usuń zaproszenie',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
