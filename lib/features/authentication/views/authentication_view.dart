import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bandspace_mobile/features/authentication/cubit/authentication_cubit.dart';
import 'package:bandspace_mobile/features/authentication/cubit/authentication_state.dart';
import 'package:bandspace_mobile/features/authentication/views/email_authentication_view.dart';
import 'package:bandspace_mobile/features/authentication/views/google_authentication_view.dart';
import 'package:bandspace_mobile/features/authentication/views/widgets/authentication_header.dart';

class AuthenticationView extends StatelessWidget {
  const AuthenticationView({super.key});

  static const transitionDuration = Duration(milliseconds: 300);
  static const transitionCurve = Curves.easeInOut;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const AuthenticationHeader(),

          // Main content area
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight:
                      MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom -
                      120, // Header height approximation
                ),
                child: BlocBuilder<AuthenticationCubit, AuthenticationState>(
                  builder: (context, state) {
                    return AnimatedSwitcher(
                      duration: transitionDuration,
                      transitionBuilder:
                          (
                            Widget child,
                            Animation<double> animation,
                          ) {
                            final offsetAnimation =
                                Tween<Offset>(
                                  begin: const Offset(0.0, 0.1),
                                  end: Offset.zero,
                                ).animate(
                                  CurvedAnimation(
                                    parent: animation,
                                    curve: transitionCurve,
                                  ),
                                );
                            return SlideTransition(
                              position: offsetAnimation,
                              child: FadeTransition(
                                opacity: animation,
                                child: child,
                              ),
                            );
                          },
                      child: switch (state) {
                        GoogleAuthentication() => const GoogleAuthenticationView(),
                        EmailAuthentication() => EmailAuthenticationView(state: state),
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
