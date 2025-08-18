import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:bandspace_mobile/features/auth/cubit/auth_cubit.dart';
import 'package:bandspace_mobile/features/auth/cubit/auth_state.dart';
import 'package:bandspace_mobile/features/auth/screens/auth_screen.dart';
import 'package:bandspace_mobile/features/dashboard/cubit/projects/projects_cubit.dart';
import 'package:bandspace_mobile/features/dashboard/views/projects_view.dart';
import 'package:bandspace_mobile/features/dashboard/widgets/create_project_bottom_sheet.dart';
import 'package:bandspace_mobile/features/dashboard/widgets/user_drawer.dart';
import 'package:bandspace_mobile/shared/cubits/user_invitations/user_invitations_cubit.dart';
import 'package:bandspace_mobile/shared/cubits/user_invitations/user_invitations_state.dart';
import 'package:bandspace_mobile/shared/cubits/user_profile/user_profile_cubit.dart';
import 'package:bandspace_mobile/shared/cubits/user_profile/user_profile_state.dart';
import 'package:bandspace_mobile/shared/repositories/projects_repository.dart';
import 'package:bandspace_mobile/shared/widgets/user_avatar.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  static Widget create() {
    return BlocProvider(
      create: (context) => ProjectsCubit(
        projectsRepository: context.read<ProjectsRepository>(),
      ),
      child: const DashboardScreen(),
    );
  }

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserInvitationsCubit>().loadInvitations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // Listener dla automatycznego przekierowania po wylogowaniu
        BlocListener<AuthCubit, AuthState>(
          listenWhen: (previous, current) {
            // Słuchaj tylko gdy wcześniej użytkownik był zalogowany, a teraz nie jest
            return previous.user != null && current.user == null;
          },
          listener: (context, state) {
            // Pokaż SnackBar jeśli wylogowanie było spowodowane błędem tokenu
            if (state.loggedOutDueToTokenFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Wystąpił błąd sesji. Zaloguj się ponownie.'),
                  backgroundColor: Theme.of(context).colorScheme.errorContainer,
                ),
              );
            }

            // Użytkownik został wylogowany - przekieruj do AuthScreen
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const AuthScreen()),
              (route) => false, // Usuń wszystkie poprzednie ekrany ze stosu
            );
          },
        ),
        BlocListener<UserProfileCubit, UserProfileState>(
          listenWhen: (previous, current) =>
              previous is UserProfileEditNameSubmitting &&
              current is UserProfileLoadSuccess,
          listener: (context, state) {
            if (state is UserProfileLoadSuccess) {
              context.read<ProjectsCubit>().refreshProjects();
            }
          },
        ),
        BlocListener<UserInvitationsCubit, UserInvitationsState>(
          listenWhen: (previous, current) =>
              current is UserInvitationsActionSuccess,
          listener: (context, state) {
            // Po przyjęciu zaproszenia odśwież projekty, aby pokazać nowy projekt
            context.read<ProjectsCubit>().refreshProjects();
          },
        ),
      ],
      child: Scaffold(
        endDrawer: UserDrawer(),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'BandSpace',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    Builder(
                      builder: (context) {
                        return GestureDetector(
                          onTap: () => Scaffold.of(context).openEndDrawer(),
                          child: UserAvatar(
                            size: 40,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ProjectsView(),
              ),
            ],
          ),
        ),
        floatingActionButton: Builder(
          builder: (context) {
            return FloatingActionButton.extended(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              onPressed: () async {
                final cubit = context.read<ProjectsCubit>();
                cubit.pauseUpdates();
                final created = await CreateProjectBottomSheet.show(context);

                if (created == true) {
                  cubit.resumeUpdates();
                  cubit.refreshProjects();
                }
              },
              label: const Text('Nowy projekt'),
              icon: const Icon(LucideIcons.plus),
            );
          },
        ),
      ),
    );
  }
}
