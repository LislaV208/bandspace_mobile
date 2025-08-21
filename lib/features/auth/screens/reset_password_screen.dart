import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

import 'package:bandspace_mobile/features/auth/cubit/reset_password_cubit.dart';
import 'package:bandspace_mobile/features/auth/cubit/reset_password_state.dart';
import 'package:bandspace_mobile/features/auth/repository/auth_repository.dart';

class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key});

  static Widget create() {
    return BlocProvider(
      create: (context) => ResetPasswordCubit(
        authRepository: context.read<AuthRepository>(),
      ),
      child: const ResetPasswordScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const _ResetPasswordContent();
  }
}

class _ResetPasswordContent extends StatefulWidget {
  const _ResetPasswordContent();

  @override
  State<_ResetPasswordContent> createState() => _ResetPasswordContentState();
}

class _ResetPasswordContentState extends State<_ResetPasswordContent> {
  final TextEditingController _emailController = TextEditingController();
  final FocusNode _emailFocus = FocusNode();

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resetowanie hasła'),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: BlocConsumer<ResetPasswordCubit, ResetPasswordState>(
        listener: (context, state) {
          if (state is ResetPasswordSuccess) {
            // Można dodać dodatkowe akcje po sukcesie
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
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
                if (state is ResetPasswordFailure)
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
                          color: Theme.of(context).colorScheme.onErrorContainer,
                          size: 20,
                        ),
                        const Gap(12),
                        Expanded(
                          child: Text(
                            state.message,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onErrorContainer,
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
                      controller: _emailController,
                      focusNode: _emailFocus,
                      keyboardType: TextInputType.emailAddress,
                      enabled: state is! ResetPasswordLoading,
                      decoration: InputDecoration(
                        hintText: 'nazwa@przykład.pl',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      onFieldSubmitted: (value) {
                        if (state is! ResetPasswordLoading) {
                          _handleSendLink(context);
                        }
                      },
                    ),
                  ],
                ),
                const Gap(32),

                // Send Button
                ElevatedButton(
                  onPressed: state is ResetPasswordLoading
                      ? null
                      : () => _handleSendLink(context),
                  child: state is ResetPasswordLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
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

                if (state is ResetPasswordSuccess)
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(top: 24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimaryContainer,
                          size: 20,
                        ),
                        const Gap(12),
                        Expanded(
                          child: Text(
                            state.message,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimaryContainer,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _handleSendLink(BuildContext context) {
    final email = _emailController.text.trim();
    context.read<ResetPasswordCubit>().requestPasswordReset(email);
  }
}
