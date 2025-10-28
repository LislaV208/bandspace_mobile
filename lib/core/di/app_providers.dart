import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import 'package:bandspace_mobile/core/api/api_client.dart';
import 'package:bandspace_mobile/core/auth/auth_event_service.dart';
import 'package:bandspace_mobile/core/storage/database_storage.dart';
import 'package:bandspace_mobile/core/storage/sembast_database_storage.dart';
import 'package:bandspace_mobile/features/auth/cubit/auth_cubit.dart';
import 'package:bandspace_mobile/features/auth/repository/auth_repository.dart';
import 'package:bandspace_mobile/features/project_detail/repository/project_members_repository.dart';
import 'package:bandspace_mobile/shared/cubits/user_invitations/user_invitations_cubit.dart';
import 'package:bandspace_mobile/shared/cubits/user_profile/user_profile_cubit.dart';
import 'package:bandspace_mobile/shared/repositories/account_repository.dart';
import 'package:bandspace_mobile/shared/repositories/invitations_repository.dart';
import 'package:bandspace_mobile/shared/repositories/projects_repository.dart';
import 'package:bandspace_mobile/shared/services/google_sign_in_service.dart';
import 'package:bandspace_mobile/shared/services/session_storage_service.dart';
import 'package:bandspace_mobile/shared/services/shared_preferences_storage.dart';
import 'package:bandspace_mobile/shared/services/wakelock_service.dart';

final appProviders = [
  // Core
  Provider(create: (context) => AuthEventService()),
  Provider(
    create: (context) => ApiClient(
      authEventService: context.read<AuthEventService>(),
    ),
  ),
  Provider(create: (context) => SharedPreferencesStorage()),
  Provider(create: (context) => WakelockService()),

  // Database Storage dla cache'owania
  Provider<DatabaseStorage>(
    create: (context) {
      final storage = SembastDatabaseStorage(name: 'cache');
      // Asynchroniczna inicjalizacja - może być wywołana lazy
      storage.initialize();
      return storage;
    },
    dispose: (context, storage) => storage.dispose(),
  ),

  // Repozytoria
  // Shared
  RepositoryProvider(
    create: (context) => AccountRepository(
      apiClient: context.read(),
      databaseStorage: context.read(),
    ),
  ),
  RepositoryProvider(
    create: (context) => ProjectsRepository(
      apiClient: context.read<ApiClient>(),
      databaseStorage: context.read<DatabaseStorage>(),
    ),
  ),
  RepositoryProvider(
    create: (context) => InvitationsRepository(
      apiClient: context.read<ApiClient>(),
    ),
  ),
  // Features
  RepositoryProvider(
    create: (context) => AuthRepository(
      apiClient: context.read<ApiClient>(),
      storageService: SessionStorageService(),
      googleSignInService: GoogleSignInService(),
    ),
  ),

  RepositoryProvider(
    create: (context) => ProjectMembersRepository(
      apiClient: context.read<ApiClient>(),
      databaseStorage: context.read<DatabaseStorage>(),
    ),
  ),

  // Cubity
  BlocProvider(
    create: (context) => AuthCubit(
      authRepository: context.read<AuthRepository>(),
      authEventService: context.read<AuthEventService>(),
      databaseStorage: context.read<DatabaseStorage>(),
    ),
  ),
  BlocProvider(
    create: (context) => UserProfileCubit(
      userRepository: context.read(),
    ),
  ),
  BlocProvider(
    create: (context) => UserInvitationsCubit(
      invitationsRepository: context.read<InvitationsRepository>(),
    ),
  ),
];
