import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:bandspace_mobile/auth/auth_screen.dart';
import 'package:bandspace_mobile/core/components/user_avatar.dart';
import 'package:bandspace_mobile/core/components/user_drawer.dart';
import 'package:bandspace_mobile/core/cubit/auth_cubit.dart';
import 'package:bandspace_mobile/core/cubit/auth_state.dart';
import 'package:bandspace_mobile/core/models/user.dart';
import 'package:bandspace_mobile/core/repositories/project_repository.dart';
import 'package:bandspace_mobile/core/theme/theme.dart';
import 'package:bandspace_mobile/dashboard/components/dashboard_project_card.dart';
import 'package:bandspace_mobile/dashboard/cubit/dashboard_cubit.dart';
import 'package:bandspace_mobile/dashboard/cubit/dashboard_state.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
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

        // Utwórz DashboardCubit, jeśli jeszcze nie istnieje
        if (context.read<DashboardCubit?>() == null) {
          return BlocProvider(
            create: (context) => DashboardCubit(projectRepository: ProjectRepository())..loadProjects(),
            child: _buildDashboardContent(context, user),
          );
        }

        return _buildDashboardContent(context, user);
      },
    );
  }

  Widget _buildDashboardContent(BuildContext context, User user) {
    return Scaffold(
      backgroundColor: AppColors.background,
      endDrawer: UserDrawer(user: user),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [_buildHeader(context), Expanded(child: _buildProjectsList(context))],
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
              return UserAvatar(
                avatarUrl: user.avatarUrl,
                name: user.fullName,
                email: user.email,
                size: 40,
                borderWidth: 2,
                borderColor: AppColors.primary,
                backgroundColor: AppColors.primary,
                onTap: () => _openUserDrawer(context),
              );
            } else {
              return UserAvatar(
                email: 'user',
                size: 40,
                borderWidth: 2,
                borderColor: AppColors.primary,
                backgroundColor: AppColors.primary,
                onTap: () => _openUserDrawer(context),
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

  Widget _buildProjectsList(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text('Moje Projekty', style: AppTextStyles.headlineLarge),
              Text('Zarządzaj i organizuj swoje projekty muzyczne', style: AppTextStyles.bodyMedium),
              const SizedBox(height: 16),
              _buildNewProjectButton(context),
              const SizedBox(height: 16),

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

              const SizedBox(height: 16),
            ],
          ),
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
            icon: const Icon(Icons.add, color: Colors.white),
            label:
                state.isCreatingProject
                    ? const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        SizedBox(width: 8),
                        Text('Tworzenie...'),
                      ],
                    )
                    : const Text('Nowy Projekt'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB), // Jasny niebieski kolor z zrzutu ekranu
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

  /// Wyświetla dialog tworzenia nowego projektu
  void _showCreateProjectDialog(BuildContext context) {
    final cubit = context.read<DashboardCubit>();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Nowy Projekt'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: cubit.nameController,
                  decoration: const InputDecoration(labelText: 'Nazwa projektu', hintText: 'Wprowadź nazwę projektu'),

                  autofocus: true,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: cubit.descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Opis (opcjonalnie)',
                    hintText: 'Wprowadź opis projektu',
                  ),
                  maxLines: 3,
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Anuluj')),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  cubit.createProject();
                },
                child: const Text('Utwórz'),
              ),
            ],
          ),
    );
  }
}
