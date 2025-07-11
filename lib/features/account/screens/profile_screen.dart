import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:bandspace_mobile/features/account/cubit/user_profile/user_profile_cubit.dart';
import 'package:bandspace_mobile/features/account/cubit/user_profile/user_profile_state.dart';
import 'package:bandspace_mobile/features/account/repository/user_repository.dart';
import 'package:bandspace_mobile/features/account/screens/change_password_screen.dart';
import 'package:bandspace_mobile/features/auth/cubit/auth_cubit.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  static Widget create() {
    return BlocProvider(
      create: (context) => UserProfileCubit(
        userRepository: context.read<UserRepository>(),
        // onUserUpdated: (updatedUser) {
        //   // Aktualizuj dane użytkownika w AuthCubit
        //   context.read<AuthCubit>().updateUserData(updatedUser);
        // },
        // onAccountDeleted: () async {
        //   // Wyczyść lokalną sesję użytkownika po usunięciu konta (bez wywoływania API logout)
        //   await context.read<AuthCubit>().clearUserSession();

        //   // Nawiguj bezpośrednio do ekranu logowania, usuwając wszystkie poprzednie ekrany
        //   if (context.mounted) {
        //     Navigator.of(
        //       context,
        //     ).pushAndRemoveUntil(
        //       MaterialPageRoute(builder: (context) => const AuthScreen()),
        //       (route) => false,
        //     );
        //   }
        // },
      ),
      child: const ProfileScreen(),
    );
  }

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _nameFocus = FocusNode();

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocus.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
      ),
      body: BlocListener<UserProfileCubit, UserProfileState>(
        listener: (context, state) {
          if (state is UserProfileLoadSuccess) {
            _nameController.text = state.user.name ?? '';
          }
        },
        child: BlocBuilder<UserProfileCubit, UserProfileState>(
          builder: (context, state) {
            return switch (state) {
              UserProfileInitial() => const SizedBox(),
              UserProfileLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
              UserProfileLoadSuccess() => _buildProfileView(context, state),
              UserProfileLoadFailure() => _buildErrorState(
                context,
                state.message,
              ),
              _ => const SizedBox(),
            };
          },
        ),
      ),
    );
  }

  Widget _buildProfileView(BuildContext context, UserProfileLoadSuccess state) {
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
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                const Gap(16),
                Text(
                  state.user.name?.isNotEmpty == true
                      ? state.user.name!
                      : 'Brak nazwy',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Gap(4),
                Text(
                  state.user.email,
                  style:
                      Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const Gap(32),

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
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                Divider(color: Colors.black54),

                // Name Field
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nazwa',
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const Gap(8),
                      TextFormField(
                        controller: _nameController,
                        focusNode: _nameFocus,
                        readOnly: true,
                        decoration: InputDecoration(
                          hintText: 'Uzupełnij swoją nazwę',
                        ),
                      ),
                    ],
                  ),
                ),

                // Email Field (Read-only)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Email',
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const Gap(8),
                      TextField(
                        controller: TextEditingController(
                          text: state.user.email,
                        ),
                        readOnly: true,
                        decoration: InputDecoration(
                          focusedBorder: Theme.of(
                            context,
                          ).inputDecorationTheme.border,
                        ),
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
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                Divider(color: Colors.black54),

                // Change Password
                ListTile(
                  leading: Icon(Icons.lock_reset),
                  title: const Text('Zmień hasło'),
                  subtitle: const Text('Zaktualizuj swoje hasło'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(
                      context,
                    ).push(
                      MaterialPageRoute(
                        builder: (context) => const ChangePasswordScreen(),
                      ),
                    );
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
              border: Border.all(
                color: Theme.of(context).colorScheme.error.withAlpha(50),
              ),
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
                  leading: Icon(
                    Icons.delete_forever,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  title: Text(
                    'Usuń konto',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  subtitle: const Text('Ta operacja jest nieodwracalna'),
                  trailing: const Icon(Icons.chevron_right),
                  // onTap: () => _showDeleteAccountDialog(context),
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
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String? errorMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.x,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const Gap(16),
            Text(
              'Wystąpił błąd podczas ładowania profilu',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  errorMessage,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            const Gap(20),
            OutlinedButton(
              onPressed: () =>
                  context.read<UserProfileCubit>().refreshProfile(),
              child: const Text('Spróbuj ponownie'),
            ),
          ],
        ),
      ),
    );
  }
}
