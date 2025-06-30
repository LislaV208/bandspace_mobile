import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

import 'package:bandspace_mobile/core/cubit/reset_password_cubit.dart';
import 'package:bandspace_mobile/core/cubit/reset_password_state.dart';
import 'package:bandspace_mobile/core/repositories/auth_repository.dart';

class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ResetPasswordCubit(
        authRepository: context.read<AuthRepository>(),
      ),
      child: const _ResetPasswordContent(),
    );
  }
}

class _ResetPasswordContent extends StatelessWidget {
  const _ResetPasswordContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Resetowanie hasła'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: BlocBuilder<ResetPasswordCubit, ResetPasswordState>(
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Progress indicator
                _buildProgressIndicator(context, state.step),
                const Gap(32),
                
                // Content based on current step
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _buildStepContent(context, state),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProgressIndicator(BuildContext context, ResetPasswordStep step) {
    return Row(
      children: [
        _buildProgressStep(
          context,
          stepNumber: 1,
          title: 'Email',
          isActive: step == ResetPasswordStep.enterEmail,
          isCompleted: step.index > ResetPasswordStep.enterEmail.index,
        ),
        Expanded(
          child: Container(
            height: 2,
            color: step.index > ResetPasswordStep.enterEmail.index
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline,
          ),
        ),
        _buildProgressStep(
          context,
          stepNumber: 2,
          title: 'Nowe hasło',
          isActive: step == ResetPasswordStep.enterToken,
          isCompleted: step == ResetPasswordStep.completed,
        ),
      ],
    );
  }

  Widget _buildProgressStep(
    BuildContext context, {
    required int stepNumber,
    required String title,
    required bool isActive,
    required bool isCompleted,
  }) {
    final color = isCompleted || isActive
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.outline;

    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted || isActive
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.surface,
            border: Border.all(color: color, width: 2),
          ),
          child: Center(
            child: isCompleted
                ? Icon(
                    Icons.check,
                    size: 16,
                    color: Theme.of(context).colorScheme.onPrimary,
                  )
                : Text(
                    stepNumber.toString(),
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: isActive
                          ? Theme.of(context).colorScheme.onPrimary
                          : color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const Gap(8),
        Text(
          title,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: color,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildStepContent(BuildContext context, ResetPasswordState state) {
    switch (state.step) {
      case ResetPasswordStep.enterEmail:
        return _buildEmailStep(context, state);
      case ResetPasswordStep.enterToken:
        return _buildTokenStep(context, state);
      case ResetPasswordStep.completed:
        return _buildCompletedStep(context, state);
    }
  }

  Widget _buildEmailStep(BuildContext context, ResetPasswordState state) {
    final cubit = context.read<ResetPasswordCubit>();

    return Column(
      key: const ValueKey('email_step'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Wprowadź adres email',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const Gap(8),
        Text(
          'Wyślemy Ci link do resetowania hasła na podany adres email.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                Icon(
                  Icons.error_outline,
                  color: Theme.of(context).colorScheme.error,
                  size: 20,
                ),
                const Gap(12),
                Expanded(
                  child: Text(
                    state.errorMessage!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Email Field
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Adres email',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const Gap(8),
            TextFormField(
              controller: cubit.emailController,
              focusNode: cubit.emailFocus,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'nazwa@przykład.pl',
                prefixIcon: Icon(
                  Icons.email_outlined,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
            ),
          ],
        ),
        const Gap(32),

        // Send Button
        FilledButton(
          onPressed: state.isLoading ? null : cubit.requestPasswordReset,
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
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
                    Icon(Icons.send, size: 20),
                    Gap(8),
                    Text('Wyślij link'),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildTokenStep(BuildContext context, ResetPasswordState state) {
    final cubit = context.read<ResetPasswordCubit>();

    return Column(
      key: const ValueKey('token_step'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: cubit.goBack,
              icon: const Icon(Icons.arrow_back),
            ),
            Expanded(
              child: Text(
                'Nowe hasło',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const Gap(8),

        // Success message from previous step
        if (state.successMessage != null)
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const Gap(12),
                Expanded(
                  child: Text(
                    state.successMessage!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),

        Text(
          'Wprowadź token resetowania oraz nowe hasło.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const Gap(24),

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
                  color: Theme.of(context).colorScheme.error,
                  size: 20,
                ),
                const Gap(12),
                Expanded(
                  child: Text(
                    state.errorMessage!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Token Field
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Token resetowania',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const Gap(8),
            TextFormField(
              controller: cubit.tokenController,
              focusNode: cubit.tokenFocus,
              decoration: InputDecoration(
                hintText: 'Wprowadź token z emaila',
                prefixIcon: Icon(
                  Icons.key_outlined,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
            ),
          ],
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
          onToggleVisibility: cubit.toggleConfirmPasswordVisibility,
        ),
        const Gap(32),

        // Reset Password Button
        FilledButton(
          onPressed: state.isLoading ? null : cubit.resetPassword,
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
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
                    Icon(Icons.lock_reset, size: 20),
                    Gap(8),
                    Text('Resetuj hasło'),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildCompletedStep(BuildContext context, ResetPasswordState state) {
    return Column(
      key: const ValueKey('completed_step'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check,
                  size: 32,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
              const Gap(16),
              Text(
                'Hasło zostało zresetowane!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const Gap(8),
              if (state.successMessage != null)
                Text(
                  state.successMessage!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),
        const Gap(32),
        
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.login, size: 20),
              Gap(8),
              Text('Przejdź do logowania'),
            ],
          ),
        ),
      ],
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
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const Gap(8),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: Icon(
              Icons.lock_outline,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                obscureText ? Icons.visibility : Icons.visibility_off,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              onPressed: onToggleVisibility,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
        ),
      ],
    );
  }
}