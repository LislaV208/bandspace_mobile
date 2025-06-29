import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/api/invitation_api.dart';
import '../../core/models/project.dart';
import '../components/widgets/invitation_list_item.dart';
import '../cubit/project_invitations_cubit.dart';
import '../cubit/project_invitations_state.dart';

/// Ekran do zapraszania użytkowników do projektu
class InviteUserScreen extends StatefulWidget {
  final Project project;

  const InviteUserScreen({super.key, required this.project});

  @override
  State<InviteUserScreen> createState() => _InviteUserScreenState();

  static Widget create(Project project) {
    return BlocProvider(
      create:
          (context) =>
              ProjectInvitationsCubit(invitationApi: InvitationApi(), projectId: project.id)..loadInvitations(),
      child: InviteUserScreen(project: project),
    );
  }
}

class _InviteUserScreenState extends State<InviteUserScreen> {
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
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!), backgroundColor: Theme.of(context).colorScheme.error),
          );
          context.read<ProjectInvitationsCubit>().clearError();
        }

        if (state.successMessage != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.successMessage!), backgroundColor: Colors.green));
          context.read<ProjectInvitationsCubit>().clearSuccess();
          _emailController.clear();
        }
      },
      child: Scaffold(
        appBar: _buildAppBar(context),
        body: Column(
          children: [
            _buildProjectInfo(context),
            const Gap(24),
            _buildInviteForm(context),
            const Gap(24),
            _buildInvitationsHeader(context),
            const Gap(16),
            Expanded(child: _buildInvitationsList(context)),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(
        'Zaproś do projektu',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).colorScheme.onSurface),
      ),
      leading: IconButton(icon: const Icon(LucideIcons.arrowLeft), onPressed: () => Navigator.pop(context)),
    );
  }

  Widget _buildProjectInfo(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.folder, color: Theme.of(context).colorScheme.primary),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.project.name,
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface),
                ),
                const Gap(4),
                Text(
                  '${widget.project.membersCount} członków',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
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
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSurface),
              decoration: InputDecoration(
                labelText: 'Adres email',
                hintText: 'Wprowadź adres email użytkownika',
                prefixIcon: Icon(LucideIcons.mail, color: Theme.of(context).colorScheme.onSurfaceVariant),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Wprowadź adres email';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                  return 'Wprowadź poprawny adres email';
                }
                return null;
              },
            ),
            const Gap(16),
            BlocBuilder<ProjectInvitationsCubit, ProjectInvitationsState>(
              builder: (context, state) {
                return ElevatedButton(
                  onPressed: state.isSendingInvitation ? null : _sendInvitation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child:
                      state.isSendingInvitation
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

  Widget _buildInvitationsHeader(BuildContext context) {
    return BlocBuilder<ProjectInvitationsCubit, ProjectInvitationsState>(
      builder: (context, state) {
        if (state.invitations.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(LucideIcons.mail, color: Theme.of(context).colorScheme.onSurface, size: 20),
              const Gap(8),
              Text(
                'Wysłane zaproszenia (${state.invitations.length})',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInvitationsList(BuildContext context) {
    return BlocBuilder<ProjectInvitationsCubit, ProjectInvitationsState>(
      builder: (context, state) {
        if (state.status == ProjectInvitationsStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.invitations.isEmpty) {
          return _buildEmptyInvitationsState(context);
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: state.invitations.length,
          separatorBuilder: (context, index) => const Gap(12),
          itemBuilder: (context, index) {
            final invitation = state.invitations[index];
            return InvitationListItem(
              invitation: invitation,
              onCancel: invitation.isPending ? () => _cancelInvitation(invitation.id) : null,
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyInvitationsState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.mail, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant),
          const Gap(16),
          Text(
            'Brak wysłanych zaproszeń',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          const Gap(8),
          Text(
            'Zaproszenia pojawią się tutaj po wysłaniu',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _sendInvitation() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<ProjectInvitationsCubit>().sendInvitation(_emailController.text.trim());
    }
  }

  void _cancelInvitation(int invitationId) {
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            backgroundColor: Theme.of(context).colorScheme.surface,
            title: Text(
              'Anuluj zaproszenie',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface),
            ),
            content: Text(
              'Czy na pewno chcesz anulować to zaproszenie?',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text('Anuluj', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  context.read<ProjectInvitationsCubit>().cancelInvitation(invitationId);
                },
                child: Text('Usuń zaproszenie', style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ),
            ],
          ),
    );
  }
}
