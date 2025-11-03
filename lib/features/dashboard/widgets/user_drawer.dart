import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:bandspace_mobile/features/account/screens/profile_screen.dart';
import 'package:bandspace_mobile/features/auth/cubit/authentication_cubit.dart';
import 'package:bandspace_mobile/shared/cubits/user_profile/user_profile_cubit.dart';
import 'package:bandspace_mobile/shared/cubits/user_profile/user_profile_state.dart';
import 'package:bandspace_mobile/shared/models/user.dart';
import 'package:bandspace_mobile/shared/theme/theme.dart';
import 'package:bandspace_mobile/shared/widgets/user_avatar.dart';

///
/// Zawiera informacje o użytkowniku oraz opcje nawigacji.
class UserDrawer extends StatelessWidget {
  const UserDrawer({super.key});

  /// Obiekt użytkownika zawierający dane do wyświetlenia.

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.background,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            const Divider(
              color: AppColors.divider,
              height: 1,
              thickness: 1,
              indent: 16,
              endIndent: 16,
            ),
            Expanded(child: _buildMenuItems(context)),
            const Divider(
              color: AppColors.divider,
              height: 1,
              thickness: 1,
              indent: 16,
              endIndent: 16,
            ),
            const SizedBox(height: 8.0), // Dodatkowy odstęp
            _buildLogoutButton(),
            const SizedBox(height: 8.0), // Odstęp od dołu
          ],
        ),
      ),
    );
  }

  /// Buduje nagłówek drawera z informacjami o użytkowniku.
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20.0,
        vertical: 24.0,
      ), // Zwiększony padding
      child: BlocSelector<UserProfileCubit, UserProfileState, User?>(
        selector: (state) => state is UserProfileLoadSuccess ? state.user : null,
        builder: (context, profileUser) {
          final user = profileUser;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              UserAvatar(
                size: 52,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FittedBox(
                      child: Text(
                        user?.name ?? user?.email ?? 'Użytkownik',
                        style: AppTextStyles.titleMedium.copyWith(
                          color: AppColors.textPrimary,
                        ), // Lekko mniejszy niż titleLarge
                      ),
                    ),
                    if (user?.name != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        user?.email ?? 'Brak adresu email',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Buduje listę opcji menu.
  Widget _buildMenuItems(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8.0), // Odstęp od Dividerów
      children: [
        _buildMenuItem(
          icon: LucideIcons.user,
          title: 'Konto',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => ProfileScreen()),
            );
          },
        ),
      ],
    );
  }

  /// Buduje pojedynczy element menu.
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 12.0,
        vertical: 4.0,
      ), // Odstęp między elementami
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 4.0,
        ), // Wewnętrzny padding
        leading: Icon(
          icon,
          color: AppColors.iconPrimary,
          size: 22,
        ), // Ujednolicony rozmiar ikony
        title: Text(
          title,
          style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimary),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ), // Zaokrąglone krawędzie dla efektów
        hoverColor: AppColors.surfaceLight.withAlpha(204), // opacity 0.8
        splashColor: AppColors.primary.withAlpha(38), // opacity 0.15
        focusColor: AppColors.primary.withAlpha(26), // opacity 0.1
        tileColor: Colors.transparent,
      ),
    );
  }

  /// Buduje przycisk wylogowania.
  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        children: [
          Builder(
            builder: (context) {
              return SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(LucideIcons.logOut),
                  label: const Text('Wyloguj się'),
                  onPressed: () => _handleLogout(context),
                ),
              );
            },
          ),
          const SizedBox(height: 16.0),
          FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Text(
                  'v${snapshot.data!.version}+${snapshot.data!.buildNumber}',
                  style: Theme.of(context).textTheme.bodySmall,
                );
              } else {
                return const SizedBox.shrink();
              }
            },
          ),
        ],
      ),
    );
  }

  void _handleLogout(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => BlocConsumer<UserProfileCubit, UserProfileState>(
        listener: (context, state) {
          if (state is UserSignedOut) {
            context.read<AuthenticationCubit>().onSignedOut();
          }
        },
        builder: (context, state) {
          final isSigningOut = state is UserSigningOut || state is UserSignedOut;

          return AlertDialog(
            title: const Text('Wylogowanie'),
            content: const Text('Czy na pewno chcesz się wylogować?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Anuluj'),
              ),
              ElevatedButton(
                onPressed: isSigningOut ? null : () => context.read<UserProfileCubit>().signOut(),
                child: isSigningOut
                    ? SizedBox.square(
                        dimension: 20,
                        child: const CircularProgressIndicator(
                          strokeWidth: 3,
                        ),
                      )
                    : const Text('Wyloguj'),
              ),
            ],
          );
        },
      ),
    );
  }
}
