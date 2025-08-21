import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

import 'package:bandspace_mobile/features/account/cubit/change_password_cubit.dart';
import 'package:bandspace_mobile/features/account/cubit/change_password_state.dart';
import 'package:bandspace_mobile/features/auth/repository/auth_repository.dart';

class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ChangePasswordCubit(authRepository: context.read<AuthRepository>()),
      child: const _ChangePasswordContent(),
    );
  }
}

class _ChangePasswordContent extends StatelessWidget {
  const _ChangePasswordContent();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ChangePasswordCubit>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Zmiana hasła'),
      ),
      body: BlocListener<ChangePasswordCubit, ChangePasswordState>(
        listener: (context, state) {
          if (state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successMessage!),
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
            );
            // Opcjonalnie można zamknąć ekran po udanej zmianie hasła
            Navigator.of(context).pop();
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Wprowadź swoje aktualne hasło oraz nowe hasło, które chcesz ustawić.',
              ),
              const Gap(32),

              BlocBuilder<ChangePasswordCubit, ChangePasswordState>(
                builder: (context, state) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
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
                              Icon(
                                Icons.error_outline,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onErrorContainer,
                                size: 20,
                              ),
                              const Gap(12),
                              Expanded(
                                child: Text(
                                  state.errorMessage!,
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onErrorContainer,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Current Password Field
                      _buildPasswordField(
                        context: context,
                        controller: cubit.currentPasswordController,
                        focusNode: cubit.currentPasswordFocus,
                        labelText: 'Aktualne hasło',
                        hintText: 'Wprowadź swoje aktualne hasło',
                        obscureText: !state.showCurrentPassword,
                        onToggleVisibility:
                            cubit.toggleCurrentPasswordVisibility,
                        prefixIcon: Icons.lock_outline,
                      ),
                      const Gap(16),

                      // New Password Field
                      _buildPasswordField(
                        context: context,
                        controller: cubit.newPasswordController,
                        focusNode: cubit.newPasswordFocus,
                        labelText: 'Nowe hasło',
                        hintText: 'Wprowadź nowe hasło (min. 6 znaków)',
                        obscureText: !state.showNewPassword,
                        onToggleVisibility: cubit.toggleNewPasswordVisibility,
                        prefixIcon: Icons.lock_reset,
                      ),
                      const Gap(16),

                      // Confirm Password Field
                      _buildPasswordField(
                        context: context,
                        controller: cubit.confirmPasswordController,
                        focusNode: cubit.confirmPasswordFocus,
                        labelText: 'Potwierdź nowe hasło',
                        hintText: 'Wprowadź ponownie nowe hasło',
                        obscureText: !state.showConfirmPassword,
                        onToggleVisibility:
                            cubit.toggleConfirmPasswordVisibility,
                        prefixIcon: Icons.lock_person,
                      ),
                      const Gap(32),

                      // Change Password Button
                      ElevatedButton(
                        onPressed: state.isLoading
                            ? null
                            : cubit.changePassword,

                        child: state.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.check, size: 20),
                                  Gap(8),
                                  Text('Zmień hasło'),
                                ],
                              ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required BuildContext context,
    required TextEditingController controller,
    required FocusNode focusNode,
    required String labelText,
    required String hintText,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
    required IconData prefixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const Gap(8),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: Icon(prefixIcon),
            suffixIcon: IconButton(
              icon: Icon(
                obscureText ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: onToggleVisibility,
            ),
          ),
        ),
      ],
    );
  }
}
