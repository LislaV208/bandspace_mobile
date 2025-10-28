import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:bandspace_mobile/shared/theme/theme.dart';
import 'package:bandspace_mobile/features/account/screens/profile_screen.dart';
import 'package:bandspace_mobile/features/auth/cubit/auth_cubit.dart';
import 'package:bandspace_mobile/features/auth/cubit/auth_state.dart';
import 'package:bandspace_mobile/shared/cubits/user_profile/user_profile_cubit.dart';
import 'package:bandspace_mobile/shared/cubits/user_profile/user_profile_state.dart';
import 'package:bandspace_mobile/shared/models/user.dart';
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
      child: BlocSelector<AuthCubit, AuthState, User?>(
        selector: (state) => state.user,
        builder: (context, authUser) {
          return BlocSelector<UserProfileCubit, UserProfileState, User?>(
            selector: (state) =>
                state is UserProfileLoadSuccess ? state.user : null,
            builder: (context, profileUser) {
              final user = profileUser ?? authUser;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  UserAvatar(
                    size: 64,
                  ),
                  const SizedBox(width: 16), // Zwiększony odstęp
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          user?.name ?? user?.email ?? 'Użytkownik',
                          style: AppTextStyles.titleMedium.copyWith(
                            color: AppColors.textPrimary,
                          ), // Lekko mniejszy niż titleLarge
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
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

  /// Obsługuje proces wylogowania
  void _handleLogout(BuildContext context) async {
    // Pobierz AuthCubit przed operacją asynchroniczną
    final authCubit = context.read<AuthCubit>();

    // Pokaż dialog potwierdzenia
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Wylogowanie'),
        content: const Text('Czy na pewno chcesz się wylogować?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Anuluj'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Wyloguj'),
          ),
        ],
      ),
    );

    // Sprawdź, czy widget jest nadal w drzewie widgetów
    if (!context.mounted) return;

    if (shouldLogout == true) {
      // Wywołaj metodę logout
      await authCubit.logout();

      // Sprawdź ponownie, czy widget jest nadal w drzewie widgetów
      if (!context.mounted) return;

      // Zamknij drawer - nawigacja do AuthScreen będzie obsłużona przez listener w DashboardScreen
      Navigator.of(context).pop();
    }
  }
}
