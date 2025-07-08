import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:bandspace_mobile/features/dashboard/cubit/dashboard_cubit.dart';
import 'package:bandspace_mobile/features/dashboard/cubit/dashboard_state.dart';
import 'package:bandspace_mobile/features/dashboard/repository/dashboard_repository.dart';
import 'package:bandspace_mobile/features/dashboard/widgets/create_project_bottom_sheet.dart';
import 'package:bandspace_mobile/features/dashboard/widgets/dashboard_project_card.dart';
import 'package:bandspace_mobile/shared/widgets/member_avatar.dart';
import 'package:bandspace_mobile/shared/widgets/user_drawer.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => DashboardCubit(
            dashboardRepository: context.read<DashboardRepository>(),
          ),
        ),
      ],
      child: _buildDashboardContent(context),
    );
  }

  Widget _buildDashboardContent(BuildContext context) {
    return Scaffold(
      endDrawer: UserDrawer(),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            Expanded(
              child: _buildContent(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'BandSpace',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          Builder(
            builder: (context) {
              return GestureDetector(
                onTap: () => _openUserDrawer(context),
                child: UserAvatar(
                  size: 40,
                  borderWidth: 2,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _openUserDrawer(BuildContext context) {
    Scaffold.of(context).openEndDrawer();
  }

  Widget _buildContent(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          _buildProjectsSection(context),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
  // Widget _buildContent(BuildContext context) {
  //   return BlocListener<UserInvitationsCubit, UserInvitationsState>(
  //     listener: (context, state) {
  //       if (state.errorMessage != null) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(
  //             content: Text(state.errorMessage!),
  //             backgroundColor: Theme.of(context).colorScheme.error,
  //           ),
  //         );
  //         context.read<UserInvitationsCubit>().clearError();
  //       }

  //       if (state.successMessage != null) {
  //         ScaffoldMessenger.of(
  //           context,
  //         ).showSnackBar(
  //           SnackBar(
  //             content: Text(state.successMessage!),
  //             backgroundColor: Colors.green,
  //           ),
  //         );
  //         context.read<UserInvitationsCubit>().clearSuccess();
  //         // Odśwież listę projektów po akceptacji zaproszenia
  //         context.read<DashboardCubit>().loadProjects();
  //       }
  //     },
  //     child: SingleChildScrollView(
  //       padding: const EdgeInsets.symmetric(horizontal: 16.0),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           const SizedBox(height: 16),
  //           _buildProjectsSection(context),
  //           const SizedBox(height: 16),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildInvitationsSection(BuildContext context) {
  //   return BlocBuilder<UserInvitationsCubit, UserInvitationsState>(
  //     builder: (context, state) {
  //       if (state.invitations.isEmpty) {
  //         return const SizedBox.shrink();
  //       }

  //       return Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           ...state.invitations.map(
  //             (invitation) => InvitationItem(
  //               invitation: invitation,
  //               onTap: () => _showInvitationDetails(context, invitation),
  //             ),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  Widget _buildProjectsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Moje Projekty',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        Text(
          'Zarządzaj i organizuj swoje projekty muzyczne',
        ),
        const SizedBox(height: 16),
        _buildNewProjectButton(context),
        // const SizedBox(height: 16),
        // _buildInvitationsSection(context),
        const SizedBox(height: 16),
        _buildProjectsList(context),
      ],
    );
  }

  Widget _buildProjectsList(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        return switch (state.status) {
          DashboardStatus.initial || DashboardStatus.loading => const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            ),
          ),
          DashboardStatus.error => Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withAlpha(25), // 0.1 * 255 = 25
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.red.withAlpha(76),
                ), // 0.3 * 255 = 76
              ),
              child: Text(
                state.errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ),

          DashboardStatus.success || DashboardStatus.creatingProject => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Wyświetlanie komunikatu błędu, jeśli wystąpił

              // Wyświetlanie wskaźnika ładowania, jeśli trwa ładowanie

              // Wyświetlanie projektów, jeśli są dostępne
              if (state.projects.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32.0),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(
                          LucideIcons.folderPlus,
                          size: 48,
                          color: Color(0xFF9CA3AF),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Nie masz jeszcze żadnych projektów',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                color: const Color(0xFF9CA3AF),
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Utwórz swój pierwszy projekt, aby rozpocząć',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: const Color(0xFF6B7280),
                              ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Wyświetlanie listy projektów
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
          ),
        };
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
            onPressed: state.status == DashboardStatus.creatingProject
                ? null
                : () => _showCreateProjectDialog(context),
          ),
        );
      },
    );
  }

  /// Wyświetla bottom sheet tworzenia nowego projektu
  void _showCreateProjectDialog(BuildContext context) {
    // Wyczyść pola formularza przed otwarciem
    final cubit = context.read<DashboardCubit>();

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      isScrollControlled:
          true, // Pozwala na dostosowanie wysokości do zawartości
      backgroundColor: Colors
          .transparent, // Przezroczyste tło, aby widoczne były zaokrąglone rogi
      builder: (context) => BlocProvider.value(
        value: cubit,
        child: const CreateProjectBottomSheet(),
      ),
    );
  }

  /// Wyświetla modal ze szczegółami zaproszenia
  // void _showInvitationDetails(BuildContext context, invitation) {
  //   showModalBottomSheet(
  //     context: context,
  //     backgroundColor: Colors.transparent,
  //     isScrollControlled: true,
  //     builder: (_) => BlocProvider.value(
  //       value: context.read<UserInvitationsCubit>(),
  //       child: InvitationDetailsModal(invitation: invitation),
  //     ),
  //   );
  // }
}
