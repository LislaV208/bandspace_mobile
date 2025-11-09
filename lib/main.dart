import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'package:bandspace_mobile/core/api/api_client.dart';
import 'package:bandspace_mobile/core/authentication/authentication_interceptor.dart';
import 'package:bandspace_mobile/core/authentication/cubit/app_authentication_cubit.dart';
import 'package:bandspace_mobile/core/authentication/cubit/app_authentication_state.dart';
import 'package:bandspace_mobile/core/bloc_observer.dart';
import 'package:bandspace_mobile/core/config/env_config.dart';
import 'package:bandspace_mobile/core/di/app_providers.dart';
import 'package:bandspace_mobile/core/navigation/custom_page_routes.dart';
import 'package:bandspace_mobile/features/authentication/authentication_screen.dart';
import 'package:bandspace_mobile/features/authentication/cubit/authentication_cubit.dart';
import 'package:bandspace_mobile/features/dashboard/screens/dashboard_screen.dart';
import 'package:bandspace_mobile/shared/cubits/user_profile/user_profile_cubit.dart';
import 'package:bandspace_mobile/shared/theme/theme.dart';
import 'package:bandspace_mobile/shared/widgets/dialogs/error_dialog.dart';

/// Główna funkcja uruchamiająca aplikację.
///
/// Parametr [envFileName] określa nazwę pliku konfiguracyjnego, który ma zostać załadowany.
/// Domyślnie używany jest plik '.env'.
Future<void> main({String envFileName = '.env'}) async {
  WidgetsFlutterBinding.ensureInitialized();

  // Załadowanie odpowiedniego pliku .env
  await EnvConfig().init(fileName: envFileName);

  // Ustawienie przezroczystego statusbara
  AppTheme.setStatusBarColor();

  Bloc.observer = AppBlocObserver();

  await SentryFlutter.init(
    (options) {
      options.dsn = EnvConfig().sentryDsn;
      options.attachScreenshot = true;
    },
    // Init your App.
    appRunner: () => runApp(
      SentryWidget(
        child: const MainApp(),
      ),
    ),
  );
}

final _navigatorKey = GlobalKey<NavigatorState>();

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: appProviders,
      // TODO
      // listener: (context, state) {
      //   // Synchronizuj kontekst użytkownika z Sentry przy każdej zmianie stanu auth
      //   final user = state.user;
      //   if (user != null) {
      //     // Użytkownik zalogowany - ustaw kontekst w Sentry
      //     setSentryUser(
      //       userId: user.id.toString(),
      //       email: user.email,
      //       username: user.name,
      //     );
      //   } else {
      //     // Użytkownik wylogowany - wyczyść kontekst w Sentry
      //     setSentryUser();
      //   }
      // },
      child: MaterialApp(
        title: 'BandSpace',
        navigatorKey: _navigatorKey,
        theme: AppTheme.darkTheme.copyWith(
          pageTransitionsTheme: const PageTransitionsTheme(
            builders: <TargetPlatform, PageTransitionsBuilder>{
              TargetPlatform.android: CupertinoPageTransitionsBuilder(),
              TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
              TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
              TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
              TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
            },
          ),
        ),
        builder: (context, child) {
          return BlocListener<AppAuthenticationCubit, AppAuthenticationState>(
            listenWhen: (previous, current) => previous is! AppAuthenticationInitial,
            listener: (context, state) {
              // zalogowany
              if (state is AppAuthenticated) {
                context.read<ApiClient>().addAuthenticationInterceptor(
                  AuthenticationInterceptor(
                    apiClient: context.read(),
                    storage: context.read(),
                    repository: context.read(),
                    onSessionExpired: () {
                      context.read<AppAuthenticationCubit>().onSignedOut();
                    },
                  ),
                );

                context.read<UserProfileCubit>().loadProfile();
                _navigatorKey.currentState?.pushReplacement(
                  FadePageRoute(page: DashboardScreen.create()),
                );
              } else if (state is AppUnauthenticated) {
                // logowanie
                if (state is AppAuthenticating) {
                  return;
                }

                // błąd podczas logowania - pokazujemy tylko blad i nic wiecej
                if (state is AppUnauthenticatedFailed) {
                  final context = _navigatorKey.currentContext;
                  if (context != null) {
                    ErrorDialog.show(context, error: state.error);
                  }
                }

                context.read<ApiClient>().removeAuthenticationInterceptor();

                if (state is AppUnauthenticatedExpired || state is AppUnauthenticatedSignedOut) {
                  _navigatorKey.currentState?.popUntil(
                    (route) => route.isFirst,
                  );
                  _navigatorKey.currentState?.pushReplacement(
                    FadePageRoute(
                      page: BlocProvider(
                        create: (context) => AuthenticationCubit(),
                        child: const AuthenticationScreen(),
                      ),
                    ),
                  );
                }
              }
            },
            child: child ?? const SizedBox(),
          );
        },
        home: BlocProvider(
          create: (context) => AuthenticationCubit(),
          child: const AuthenticationScreen(),
        ),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
