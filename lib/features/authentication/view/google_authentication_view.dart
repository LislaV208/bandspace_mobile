import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';

import 'package:bandspace_mobile/features/authentication/cubit/authentication/authentication_cubit.dart';
import 'package:bandspace_mobile/features/authentication/cubit/authentication_screen/authentication_screen_cubit.dart';
import 'package:bandspace_mobile/features/authentication/cubit/authentication/authentication_state.dart';

class GoogleAuthenticationView extends StatelessWidget {
  const GoogleAuthenticationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Google button
        Container(
          height: 64,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface, // #1F2937
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline, // #374151
              width: 1.5,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                context.read<AuthenticationCubit>().authenticateWithGoogle();
              },
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: BlocSelector<AuthenticationCubit, AuthenticationState, bool>(
                  selector: (state) {
                    return state is Authenticating;
                  },
                  builder: (context, isLoading) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isLoading)
                          SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          )
                        else ...[
                          Brand(Brands.google, size: 24),
                          const SizedBox(width: 16),
                          Text(
                            "Kontynuuj z kontem Google",
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface, // Colors.white
                              letterSpacing: 0.1,
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 32),

        // Email button
        Center(
          child: TextButton.icon(
            onPressed: () => context.read<AuthenticationScreenCubit>().useEmailAuthentication(),
            label: const Text(
              "Użyj adresu email i hasła",
            ),
            icon: const Icon(
              Icons.alternate_email,
            ),
          ),
        ),
      ],
    );
  }
}
