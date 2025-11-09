import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bandspace_mobile/core/authentication/cubit/app_authentication_cubit.dart';
import 'package:bandspace_mobile/core/authentication/cubit/app_authentication_state.dart';
import 'package:bandspace_mobile/features/authentication/views/authentication_initial_view.dart';
import 'package:bandspace_mobile/features/authentication/views/authentication_view.dart';

class AuthenticationScreen extends StatelessWidget {
  const AuthenticationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: BlocSelector<AppAuthenticationCubit, AppAuthenticationState, bool>(
        selector: (state) => state is AppAuthenticationInitial,
        builder: (context, showLoading) {
          return switch (showLoading) {
            true => const AuthenticationInitialView(),
            false => const AuthenticationView(),
          };
        },
      ),
    );
  }
}
