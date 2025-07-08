import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import 'package:bandspace_mobile/core/api/api_client.dart';
import 'package:bandspace_mobile/features/account/repository/user_repository.dart';
import 'package:bandspace_mobile/features/auth/cubit/auth_cubit.dart';
import 'package:bandspace_mobile/features/auth/repository/auth_repository.dart';
import 'package:bandspace_mobile/features/dashboard/repository/dashboard_repository.dart';
import 'package:bandspace_mobile/features/project_detail/repository/project_detail_repository.dart';
import 'package:bandspace_mobile/features/project_detail/repository/project_members_repository.dart';
import 'package:bandspace_mobile/shared/services/google_sign_in_service.dart';
import 'package:bandspace_mobile/shared/services/session_storage_service.dart';

final appProviders = [
  // Core
  Provider(create: (context) => ApiClient()),

  // Repozytoria
  RepositoryProvider(
    create: (context) => AuthRepository(
      apiClient: context.read<ApiClient>(),
      storageService: SessionStorageService(),
      googleSignInService: GoogleSignInService(),
    ),
  ),
  RepositoryProvider(
    create: (context) => DashboardRepository(
      apiClient: context.read<ApiClient>(),
    ),
  ),
  RepositoryProvider(
    create: (context) => ProjectDetailRepository(
      apiClient: context.read<ApiClient>(),
    ),
  ),
  RepositoryProvider(
    create: (context) => ProjectMembersRepository(
      apiClient: context.read<ApiClient>(),
    ),
  ),
  RepositoryProvider(
    create: (context) => UserRepository(
      apiClient: context.read<ApiClient>(),
    ),
  ),

  // Cubity
  BlocProvider(
    create: (context) => AuthCubit(
      authRepository: context.read<AuthRepository>(),
    ),
  ),
];
