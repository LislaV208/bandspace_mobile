import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:bandspace_mobile/features/account/screens/change_password_screen.dart';
import 'package:bandspace_mobile/features/auth/cubit/authentication_cubit.dart';
import 'package:bandspace_mobile/shared/cubits/user_profile/user_profile_cubit.dart';
import 'package:bandspace_mobile/shared/cubits/user_profile/user_profile_state.dart';
import 'package:bandspace_mobile/shared/utils/error_logger.dart';
import 'package:bandspace_mobile/shared/widgets/dialogs/error_dialog.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _nameFocus = FocusNode();

  @override
  void initState() {
    super.initState();

    final cubit = context.read<UserProfileCubit>();
    final state = cubit.state;
    if (state is UserProfileLoadSuccess) {
      _nameController.text = state.user.name ?? '';
    }

    cubit.refreshProfile();
  }

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
        listener: (context, state) async {
          if (state is UserProfileLoadSuccess) {
            if (state is! UserProfileEditNameSubmitting) {
              _nameController.text = state.user.name ?? '';
            }
            if (state is UserProfileEditingName) {
              _nameFocus.requestFocus();
            }
          }

          if (state is UserProfileEditNameFailure) {
            ErrorDialog.show(context, error: state.error);
          }

          if (state is UserProfileDeleteSuccess) {
            await context.read<AuthenticationCubit>().onSignedOut();
          }

          if (state is UserProfileDeleteFailure) {
            if (!context.mounted) return;
            ErrorDialog.show(context, error: state.error);
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
                getErrorMessage(state.error),
              ),
              _ => const SizedBox(),
            };
          },
        ),
      ),
    );
  }

  Widget _buildProfileView(BuildContext context, UserProfileLoadSuccess state) {
    final userAuthProviders = state.user.authProviders;

    //TODO: jakis enum czy cos
    final canChangePassword = (userAuthProviders ?? []).contains('local');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Profile Information
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                spacing: 20,
                children: [
                  // Name Field
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 3.0),
                        child: Text(
                          'Nazwa',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ),
                      const Gap(8),
                      TextFormField(
                        controller: _nameController,
                        focusNode: _nameFocus,
                        readOnly: state is! UserProfileEditingName,
                        decoration: InputDecoration(
                          hintText: 'Uzupełnij swoją nazwę',
                          suffixIcon: switch (state) {
                            UserProfileEditingName() => IconButton(
                              icon: const Icon(Icons.check),
                              onPressed: () {
                                context.read<UserProfileCubit>().submitEditingName(
                                  _nameController.text.trim(),
                                );
                              },
                            ),
                            UserProfileEditNameSubmitting() => Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ],
                            ),
                            _ => IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                context.read<UserProfileCubit>().startEditingName();
                              },
                            ),
                          },
                          focusedBorder: state is UserProfileEditingName
                              ? Theme.of(
                                  context,
                                ).inputDecorationTheme.focusedBorder
                              : Theme.of(
                                  context,
                                ).inputDecorationTheme.border,
                        ),
                        onFieldSubmitted: (value) {
                          context.read<UserProfileCubit>().submitEditingName(
                            value.trim(),
                          );
                        },
                        textInputAction: TextInputAction.done,
                        onEditingComplete: () {
                          context.read<UserProfileCubit>().submitEditingName(
                            _nameController.text.trim(),
                          );
                        },
                      ),
                    ],
                  ),
                  // Email Field (Read-only)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 3.0),
                        child: Text(
                          'Email',
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Gap(8),
                      TextFormField(
                        initialValue: state.user.email,
                        readOnly: true,
                        decoration: InputDecoration(
                          focusedBorder: Theme.of(
                            context,
                          ).inputDecorationTheme.border,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const Gap(24),

          // Security Section
          if (canChangePassword)
            Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: ListTile(
                leading: Icon(Icons.lock_reset),
                title: const Text('Zmień hasło'),
                subtitle: const Text('Zaktualizuj swoje hasło'),
                trailing: const Icon(Icons.chevron_right),
                tileColor: Theme.of(context).cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
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
            ),

          // Danger Zone
          BlocBuilder<UserProfileCubit, UserProfileState>(
            builder: (context, state) {
              final isDeleting = state is UserProfileDeleteLoading;

              return ListTile(
                leading: Icon(
                  Icons.delete_forever,
                  color: Theme.of(context).colorScheme.error,
                ),
                title: Text(
                  'Usuń konto',
                ),
                subtitle: const Text('Ta operacja jest nieodwracalna'),
                trailing: isDeleting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.chevron_right),
                tileColor: Theme.of(
                  context,
                ).colorScheme.errorContainer.withAlpha(90),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                onTap: isDeleting ? null : () => _showDeleteAccountDialog(context),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Usuń konto'),
        content: const Text(
          'Czy na pewno chcesz usunąć swoje konto? Ta operacja jest nieodwracalna '
          'i spowoduje trwałe usunięcie wszystkich twoich danych.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Anuluj'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<UserProfileCubit>().deleteAccount();
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Usuń konto'),
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
              onPressed: () => context.read<UserProfileCubit>().refreshProfile(),
              child: const Text('Spróbuj ponownie'),
            ),
          ],
        ),
      ),
    );
  }
}
