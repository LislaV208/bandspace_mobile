import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import 'package:bandspace_mobile/core/api/api_client.dart';
import 'package:bandspace_mobile/features/auth/cubit/auth_cubit.dart';
import 'package:bandspace_mobile/features/auth/repository/auth_repository.dart';
import 'package:bandspace_mobile/features/project_detail/repository/project_members_repository.dart';
import 'package:bandspace_mobile/shared/cubits/user_profile/user_profile_cubit.dart';
import 'package:bandspace_mobile/shared/repositories/projects_repository.dart';
import 'package:bandspace_mobile/shared/repositories/user_repository.dart';
import 'package:bandspace_mobile/shared/services/google_sign_in_service.dart';
import 'package:bandspace_mobile/shared/services/session_storage_service.dart';

final appProviders = [
  // Core
  Provider(create: (context) => ApiClient()),

  // Repozytoria
  // Shared
  RepositoryProvider(
    create: (context) => UserRepository(
      apiClient: context.read<ApiClient>(),
    ),
  ),
  RepositoryProvider(
    create: (context) => ProjectsRepository(
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
    ),
  ),

  // Cubity
  BlocProvider(
    create: (context) => AuthCubit(
      authRepository: context.read<AuthRepository>(),
    ),
  ),
  BlocProvider(
    create: (context) => UserProfileCubit(
      userRepository: context.read<UserRepository>(),
    ),
  ),
];
