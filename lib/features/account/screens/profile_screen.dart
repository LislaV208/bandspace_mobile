import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

import 'package:bandspace_mobile/features/account/cubit/user_profile_cubit.dart';
import 'package:bandspace_mobile/features/account/cubit/user_profile_state.dart';
import 'package:bandspace_mobile/features/account/repository/user_repository.dart';
import 'package:bandspace_mobile/features/account/screens/change_password_screen.dart';
import 'package:bandspace_mobile/features/auth/cubit/auth_cubit.dart';
import 'package:bandspace_mobile/features/auth/screens/auth_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) => UserProfileCubit(
            userRepository: context.read<UserRepository>(),
            onUserUpdated: (updatedUser) {
              // Aktualizuj dane użytkownika w AuthCubit
              context.read<AuthCubit>().updateUserData(updatedUser);
            },
            onAccountDeleted: () async {
              // Wyczyść lokalną sesję użytkownika po usunięciu konta (bez wywoływania API logout)
              await context.read<AuthCubit>().clearUserSession();

              // Nawiguj bezpośrednio do ekranu logowania, usuwając wszystkie poprzednie ekrany
              if (context.mounted) {
                Navigator.of(
                  context,
                ).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const AuthScreen()), (route) => false);
              }
            },
          )..loadProfile(),
      child: const _ProfileContent(),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  const _ProfileContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        actions: [
          BlocBuilder<UserProfileCubit, UserProfileState>(
            builder: (context, state) {
              if (state.isEditing) {
                return Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        context.read<UserProfileCubit>().toggleEditing();
                      },
                      child: const Text('Anuluj'),
                    ),
                    const Gap(8),
                    FilledButton.icon(
                      onPressed:
                          state.isLoading
                              ? null
                              : () {
                                context.read<UserProfileCubit>().updateProfile();
                              },
                      icon:
                          state.isLoading
                              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Icon(Icons.check, size: 16),
                      label: const Text('Zapisz'),
                      style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
                    ),
                    const Gap(16),
                  ],
                );
              } else {
                return Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        context.read<UserProfileCubit>().toggleEditing();
                      },
                      icon: const Icon(Icons.edit),
                    ),
                    const Gap(8),
                  ],
                );
              }
            },
          ),
        ],
      ),
      body: BlocListener<UserProfileCubit, UserProfileState>(
        listener: (context, state) {
          if (state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.successMessage!), backgroundColor: Theme.of(context).colorScheme.primary),
            );
          }
        },
        child: BlocBuilder<UserProfileCubit, UserProfileState>(
          builder: (context, state) {
            if (state.isLoading && state.user == null) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Profile Header
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.person, size: 40, color: Theme.of(context).colorScheme.onPrimary),
                        ),
                        const Gap(16),
                        Text(
                          state.user?.name?.isNotEmpty == true ? state.user!.name! : 'Brak nazwy',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const Gap(4),
                        Text(
                          state.user?.email ?? '',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const Gap(32),

                  // Error Message
                  if (state.errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error, size: 20),
                          const Gap(12),
                          Expanded(
                            child: Text(
                              state.errorMessage!,
                              style: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.error),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Profile Information
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'Informacje osobiste',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        const Divider(height: 1),

                        // Name Field
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Nazwa',
                                style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              const Gap(8),
                              if (state.isEditing)
                                TextFormField(
                                  controller: context.read<UserProfileCubit>().nameController,
                                  focusNode: context.read<UserProfileCubit>().nameFocus,
                                  decoration: InputDecoration(
                                    hintText: 'Wprowadź swoją nazwę',
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                    filled: true,
                                    fillColor: Theme.of(context).colorScheme.surface,
                                  ),
                                )
                              else
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Theme.of(context).colorScheme.outline),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    state.user?.name?.isNotEmpty == true ? state.user!.name! : 'Nie ustawiono',
                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color:
                                          state.user?.name?.isNotEmpty == true
                                              ? Theme.of(context).colorScheme.onSurface
                                              : Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),

                        const Divider(height: 1),

                        // Email Field (Read-only)
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Email',
                                style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              const Gap(8),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.surfaceContainer,
                                  border: Border.all(color: Theme.of(context).colorScheme.outline),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        state.user?.email ?? '',
                                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      Icons.lock_outline,
                                      size: 16,
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                                  ],
                                ),
                              ),
                              const Gap(4),
                              Text(
                                'Email nie może być zmieniony',
                                style: Theme.of(
                                  context,
                                ).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Gap(24),

                  // Security Section
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'Bezpieczeństwo',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        const Divider(height: 1),

                        // Change Password
                        ListTile(
                          leading: Icon(Icons.lock_reset, color: Theme.of(context).colorScheme.primary),
                          title: const Text('Zmień hasło'),
                          subtitle: const Text('Zaktualizuj swoje hasło'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.of(
                              context,
                            ).push(MaterialPageRoute(builder: (context) => const ChangePasswordScreen()));
                          },
                        ),
                      ],
                    ),
                  ),
                  const Gap(24),

                  // Danger Zone
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.errorContainer.withAlpha(50),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Theme.of(context).colorScheme.error.withAlpha(50)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'Strefa zagrożenia',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ),
                        const Divider(height: 1),

                        // Delete Account
                        ListTile(
                          leading: Icon(Icons.delete_forever, color: Theme.of(context).colorScheme.error),
                          title: Text('Usuń konto', style: TextStyle(color: Theme.of(context).colorScheme.error)),
                          subtitle: const Text('Ta operacja jest nieodwracalna'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _showDeleteAccountDialog(context),
                        ),
                      ],
                    ),
                  ),
                  const Gap(32),

                  // Logout Button
                  OutlinedButton.icon(
                    onPressed: () {
                      context.read<AuthCubit>().logout();
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Wyloguj się'),
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('Usuń konto'),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Czy na pewno chcesz usunąć swoje konto?'),
                Gap(16),
                Text('Ta operacja:', style: TextStyle(fontWeight: FontWeight.bold)),
                Gap(8),
                Text('• Usunie wszystkie Twoje dane'),
                Text('• Usunie wszystkie projekty, których jesteś jedynym członkiem'),
                Text('• Nie może być cofnięta'),
                Gap(16),
                Text('Czy na pewno chcesz kontynuować?', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Anuluj')),
              FilledButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  context.read<UserProfileCubit>().deleteAccount();
                },
                style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
                child: const Text('Usuń konto'),
              ),
            ],
          ),
    );
  }
}
