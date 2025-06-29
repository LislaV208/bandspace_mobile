import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:bandspace_mobile/auth/auth_screen.dart';
import 'package:bandspace_mobile/core/api/invitation_api.dart';
import 'package:bandspace_mobile/core/components/member_avatar.dart';
import 'package:bandspace_mobile/core/components/user_drawer.dart';
import 'package:bandspace_mobile/core/cubit/auth_cubit.dart';
import 'package:bandspace_mobile/core/cubit/auth_state.dart';
import 'package:bandspace_mobile/core/models/user.dart';
import 'package:bandspace_mobile/core/theme/theme.dart';
import 'package:bandspace_mobile/dashboard/components/create_project_bottom_sheet.dart';
import 'package:bandspace_mobile/dashboard/components/dashboard_project_card.dart';
import 'package:bandspace_mobile/dashboard/components/invitation_details_modal.dart';
import 'package:bandspace_mobile/dashboard/components/invitation_item.dart';
import 'package:bandspace_mobile/dashboard/cubit/dashboard_cubit.dart';
import 'package:bandspace_mobile/dashboard/cubit/dashboard_state.dart';
import 'package:bandspace_mobile/dashboard/cubit/user_invitations_cubit.dart';
import 'package:bandspace_mobile/dashboard/cubit/user_invitations_state.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    print('DashboardScreen build');
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        // Pobierz dane użytkownika z AuthState
        final user = authState.user;

        // Jeśli użytkownik nie jest zalogowany, przekieruj do ekranu logowania
        if (user == null) {
          // Użyj WidgetsBinding.instance.addPostFrameCallback, aby uniknąć błędu podczas budowania
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const AuthScreen()));
            }
          });
          // Pokaż ekran ładowania podczas przekierowania
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        // Użyj globalnego DashboardCubit z main.dart i dodaj UserInvitationsCubit
        return BlocProvider(
          create: (context) => UserInvitationsCubit(invitationApi: InvitationApi())..loadUserInvitations(),
          child: _buildDashboardContent(context, user),
        );
      },
    );
  }

  Widget _buildDashboardContent(BuildContext context, User user) {
    print('_buildDashboardContent');
    return Scaffold(
      backgroundColor: AppColors.background,
      endDrawer: UserDrawer(user: user),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [_buildHeader(context), Expanded(child: _buildContent(context))],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text('BandSpace', style: AppTextStyles.headlineMedium), _buildUserAvatar(context)],
      ),
    );
  }

  Widget _buildUserAvatar(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final user = state.user;

        return Builder(
          builder: (context) {
            if (user != null) {
              return GestureDetector(
                onTap: () => _openUserDrawer(context),
                child: MemberAvatar(user: user, size: 40, borderWidth: 2),
              );
            } else {
              return GestureDetector(
                onTap: () => _openUserDrawer(context),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary,
                    border: Border.all(color: AppColors.primary, width: 2),
                  ),
                  child: const Icon(Icons.person, color: Colors.white, size: 24),
                ),
              );
            }
          },
        );
      },
    );
  }

  void _openUserDrawer(BuildContext context) {
    // Otwiera drawer z prawej strony ekranu
    Scaffold.of(context).openEndDrawer();
  }

  Widget _buildContent(BuildContext context) {
    return BlocListener<UserInvitationsCubit, UserInvitationsState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!), backgroundColor: Theme.of(context).colorScheme.error),
          );
          context.read<UserInvitationsCubit>().clearError();
        }

        if (state.successMessage != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.successMessage!), backgroundColor: Colors.green));
          context.read<UserInvitationsCubit>().clearSuccess();
          // Odśwież listę projektów po akceptacji zaproszenia
          context.read<DashboardCubit>().loadProjects();
        }
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _buildInvitationsSection(context),
            _buildProjectsSection(context),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildInvitationsSection(BuildContext context) {
    return BlocBuilder<UserInvitationsCubit, UserInvitationsState>(
      builder: (context, state) {
        if (state.invitations.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(LucideIcons.mail, color: Colors.orange, size: 20),
                const SizedBox(width: 8),
                Text('Zaproszenia (${state.invitations.length})', style: AppTextStyles.headlineLarge),
              ],
            ),
            const SizedBox(height: 8),
            Text('Otrzymałeś zaproszenia do projektów', style: AppTextStyles.bodyMedium),
            const SizedBox(height: 16),
            ...state.invitations.map(
              (invitation) =>
                  InvitationItem(invitation: invitation, onTap: () => _showInvitationDetails(context, invitation)),
            ),
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }

  Widget _buildProjectsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Moje Projekty', style: AppTextStyles.headlineLarge),
        Text('Zarządzaj i organizuj swoje projekty muzyczne', style: AppTextStyles.bodyMedium),
        const SizedBox(height: 16),
        _buildNewProjectButton(context),
        const SizedBox(height: 16),
        _buildProjectsList(context),
      ],
    );
  }

  Widget _buildProjectsList(BuildContext context) {
    print('_buildProjectsList');
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Wyświetlanie komunikatu błędu, jeśli wystąpił
            if (state.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withAlpha(25), // 0.1 * 255 = 25
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withAlpha(76)), // 0.3 * 255 = 76
                  ),
                  child: Text(state.errorMessage!, style: const TextStyle(color: Colors.red)),
                ),
              ),

            // Wyświetlanie wskaźnika ładowania, jeśli trwa ładowanie
            if (state.status == DashboardStatus.loading)
              const Center(child: Padding(padding: EdgeInsets.all(32.0), child: CircularProgressIndicator())),

            // Wyświetlanie projektów, jeśli są dostępne
            if (state.status == DashboardStatus.loaded && state.projects.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32.0),
                child: Center(
                  child: Column(
                    children: [
                      const Icon(LucideIcons.folderPlus, size: 48, color: Color(0xFF9CA3AF)),
                      const SizedBox(height: 16),
                      Text(
                        'Nie masz jeszcze żadnych projektów',
                        style: AppTextStyles.bodyLarge.copyWith(color: const Color(0xFF9CA3AF)),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Utwórz swój pierwszy projekt, aby rozpocząć',
                        style: AppTextStyles.bodyMedium.copyWith(color: const Color(0xFF6B7280)),
                      ),
                    ],
                  ),
                ),
              ),

            // Wyświetlanie listy projektów
            if (state.status == DashboardStatus.loaded)
              ...state.projects.map((project) {
                // Formatowanie czasu utworzenia projektu
                final createdTime = _formatCreatedTime(project.createdAt);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: DashboardProjectCard(
                    project: project,
                    createdTime: createdTime,
                    onTap: () {
                      // TODO: Implementacja nawigacji do szczegółów projektu
                    },
                  ),
                );
              }),
          ],
        );
      },
    );
  }

  /// Formatuje czas utworzenia projektu w formie względnej (np. "2h temu")
  String _formatCreatedTime(DateTime? createdAt) {
    if (createdAt == null) return 'niedawno';

    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1
          ? 'rok'
          : years < 5
          ? 'lata'
          : 'lat'} temu';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1
          ? 'miesiąc'
          : months < 5
          ? 'miesiące'
          : 'miesięcy'} temu';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'dzień' : 'dni'} temu';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h temu';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m temu';
    } else {
      return 'przed chwilą';
    }
  }

  Widget _buildNewProjectButton(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(LucideIcons.plus, color: Colors.white),
            label: const Text('Nowy Projekt'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.buttonPrimary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: state.isCreatingProject ? null : () => _showCreateProjectDialog(context),
          ),
        );
      },
    );
  }

  /// Wyświetla bottom sheet tworzenia nowego projektu
  void _showCreateProjectDialog(BuildContext context) {
    // Wyczyść pola formularza przed otwarciem
    final cubit = context.read<DashboardCubit>();
    cubit.nameController.clear();
    cubit.descriptionController.clear();

    // Wyczyść ewentualne błędy
    cubit.clearError();

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      isScrollControlled: true, // Pozwala na dostosowanie wysokości do zawartości
      backgroundColor: Colors.transparent, // Przezroczyste tło, aby widoczne były zaokrąglone rogi
      builder: (context) => BlocProvider.value(value: cubit, child: const CreateProjectBottomSheet()),
    );
  }

  /// Wyświetla modal ze szczegółami zaproszenia
  void _showInvitationDetails(BuildContext context, invitation) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (_) => BlocProvider.value(
            value: context.read<UserInvitationsCubit>(),
            child: InvitationDetailsModal(invitation: invitation),
          ),
    );
  }
}
