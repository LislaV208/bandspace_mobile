import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

import 'package:bandspace_mobile/features/authentication/cubit/reset_password/reset_password_cubit.dart';
import 'package:bandspace_mobile/features/authentication/cubit/reset_password/reset_password_state.dart';
import 'package:bandspace_mobile/shared/utils/validators.dart';
import 'package:bandspace_mobile/shared/widgets/dialogs/error_dialog.dart';
import 'package:bandspace_mobile/shared/widgets/dialogs/info_dialog.dart';

class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key});

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
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
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
      body: Form(
        key: _formKey,
        child: BlocConsumer<ResetPasswordCubit, ResetPasswordState>(
          listener: (context, state) {
            if (state is ResetPasswordSuccess) {
              Navigator.of(context).pop();
              InfoDialog.show(
                context,
                title: 'Reset hasła',
                message:
                    'Link do resetowania hasła został wysłany na podany adres email. Sprawdź skrzynkę odbiorczą i kliknij w link, aby dokończyć proces resetowania hasła',
              );
            }
            if (state is ResetPasswordFailure) {
              ErrorDialog.show(
                context,
                error: state.error,
              );
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
                        validator: validateEmail,
                      ),
                    ],
                  ),
                  const Gap(32),

                  // Send Button
                  ElevatedButton(
                    onPressed: state is ResetPasswordLoading ? null : () => _handleSendLink(context),
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
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _handleSendLink(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    context.read<ResetPasswordCubit>().requestPasswordReset(email);
  }
}
