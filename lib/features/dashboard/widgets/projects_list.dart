import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:bandspace_mobile/features/dashboard/cubit/projects/projects_state.dart';
import 'package:bandspace_mobile/features/dashboard/widgets/project_list_item.dart';
import 'package:bandspace_mobile/features/dashboard/widgets/invitation_list_item.dart';
import 'package:bandspace_mobile/shared/cubits/user_invitations/user_invitations_cubit.dart';
import 'package:bandspace_mobile/shared/cubits/user_invitations/user_invitations_state.dart';

class ProjectsList extends StatelessWidget {
  final ProjectsReady state;

  const ProjectsList({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final projects = state.projects;

    return BlocBuilder<UserInvitationsCubit, UserInvitationsState>(
      builder: (context, invitationsState) {
        final invitations = _getInvitations(invitationsState);
        
        // Pokaż empty state tylko gdy nie ma ani projektów ani zaproszeń
        if (projects.isEmpty && invitations.isEmpty) {
          return _buildEmptyState(context);
        }

        return _buildProjectsList(context, projects);
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          _buildRefreshStatusContent(context),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 32, 16, 80),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      LucideIcons.folderPlus,
                      size: 48,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Nie masz jeszcze żadnych projektów',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Utwórz swój pierwszy projekt, aby rozpocząć',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectsList(BuildContext context, List projects) {
    return Expanded(
      child: BlocBuilder<UserInvitationsCubit, UserInvitationsState>(
        builder: (context, invitationsState) {
          final invitations = _getInvitations(invitationsState);
          
          return ListView(
            children: [
              _buildRefreshStatusContent(context),
              // Wyświetl zaproszenia przed projektami
              ...invitations.asMap().entries.map(
                (entry) {
                  final index = entry.key;
                  final invitation = entry.value;
                  return Padding(
                    padding: EdgeInsets.fromLTRB(
                      16.0,
                      (index == 0 && projects.isEmpty) ? 0 : 8.0,
                      16.0,
                      8.0,
                    ),
                    child: ReceivedInvitationListItem(invitation: invitation),
                  );
                },
              ),
              // Następnie wyświetl projekty
              ...projects.asMap().entries.map(
                (entry) {
                  final index = entry.key;
                  final project = entry.value;
                  return Padding(
                    padding: EdgeInsets.fromLTRB(
                      16.0,
                      (index == 0 && invitations.isEmpty) ? 0 : 8.0,
                      16.0,
                      8.0,
                    ),
                    child: ProjectListItem(project: project),
                  );
                },
              ),
              const SizedBox(height: 80), // Space for FAB
            ],
          );
        },
      ),
    );
  }

  Widget _buildRefreshStatusContent(BuildContext context) {
    return AnimatedCrossFade(
      sizeCurve: Curves.easeInOut,
      firstCurve: Curves.easeIn,
      secondCurve: Curves.easeOut,
      duration: const Duration(milliseconds: 300),
      firstChild: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: state is ProjectsRefreshFailure
              ? ListTile(
                  dense: true,
                  title: Text(
                    'Brak połączenia z internetem',
                  ),
                  textColor: Theme.of(context).colorScheme.onErrorContainer,
                  tileColor: Theme.of(context).colorScheme.errorContainer,
                  leading: Icon(
                    Icons.error_outline,
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                  subtitle: Text(
                    'Dane mogą być nieaktualne',
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 12,
                  children: [
                    SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.0,
                      ),
                    ),
                    Text('Odświeżanie danych...'),
                  ],
                ),
        ),
      ),
      secondChild: Row(
        children: [],
      ),
      crossFadeState:
          state is ProjectsRefreshing || state is ProjectsRefreshFailure
          ? CrossFadeState.showFirst
          : CrossFadeState.showSecond,
    );
  }

  /// Pobiera listę zaproszeń ze stanu UserInvitationsCubit
  List _getInvitations(UserInvitationsState state) {
    return switch (state) {
      UserInvitationsLoadSuccess() => state.invitations,
      UserInvitationsActionSuccess() => state.invitations,
      _ => <dynamic>[],
    };
  }
}
