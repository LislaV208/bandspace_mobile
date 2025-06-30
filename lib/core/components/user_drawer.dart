import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:bandspace_mobile/auth/auth_screen.dart';
import 'package:bandspace_mobile/core/components/member_avatar.dart';
import 'package:bandspace_mobile/core/cubit/auth_cubit.dart';
import 'package:bandspace_mobile/core/models/user.dart';
import 'package:bandspace_mobile/core/theme/theme.dart';
import 'package:bandspace_mobile/profile/profile_screen.dart';

///
/// Zawiera informacje o użytkowniku oraz opcje nawigacji.
class UserDrawer extends StatelessWidget {
  const UserDrawer({super.key, required this.user});

  /// Obiekt użytkownika zawierający dane do wyświetlenia.
  final User user;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.background,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            const Divider(color: AppColors.divider, height: 1, thickness: 1, indent: 16, endIndent: 16),
            Expanded(child: _buildMenuItems(context)),
            const Divider(color: AppColors.divider, height: 1, thickness: 1, indent: 16, endIndent: 16),
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
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0), // Zwiększony padding
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildAvatar(),
          const SizedBox(width: 16), // Zwiększony odstęp
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  user.name ?? user.email,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.textPrimary,
                  ), // Lekko mniejszy niż titleLarge
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Buduje avatar użytkownika.
  Widget _buildAvatar() {
    return MemberAvatar(user: user, size: 64, borderWidth: 1.5);
  }

  /// Buduje listę opcji menu.
  Widget _buildMenuItems(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8.0), // Odstęp od Dividerów
      children: [
        _buildMenuItem(
          icon: LucideIcons.user,
          title: 'Profil',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const ProfileScreen(),
              ),
            );
          },
        ),
        _buildMenuItem(
          icon: LucideIcons.settings,
          title: 'Ustawienia',
          onTap: () {
            // Implementacja nawigacji do ustawień
          },
        ),
        _buildMenuItem(
          icon: LucideIcons.circleHelp,
          title: 'Pomoc',
          onTap: () {
            // Implementacja nawigacji do pomocy
          },
        ),
        _buildMenuItem(
          icon: LucideIcons.info,
          title: 'O aplikacji',
          onTap: () {
            // Implementacja nawigacji do informacji o aplikacji
          },
        ),
      ],
    );
  }

  /// Buduje pojedynczy element menu.
  Widget _buildMenuItem({required IconData icon, required String title, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0), // Odstęp między elementami
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0), // Wewnętrzny padding
        leading: Icon(icon, color: AppColors.iconPrimary, size: 22), // Ujednolicony rozmiar ikony
        title: Text(title, style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimary)),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)), // Zaokrąglone krawędzie dla efektów
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
      child: Builder(
        builder: (context) {
          return ElevatedButton.icon(
            icon: const Icon(LucideIcons.logOut, size: 20),
            label: const Text('Wyloguj się'),
            onPressed: () => _handleLogout(context),
          );
        },
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
      builder:
          (context) => AlertDialog(
            title: const Text('Wylogowanie'),
            content: const Text('Czy na pewno chcesz się wylogować?'),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Anuluj')),
              ElevatedButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Wyloguj')),
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

      // Zamknij drawer
      Navigator.of(context).pop();

      // Nawiguj do ekranu logowania
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const AuthScreen()),
        (route) => false, // Usuń wszystkie poprzednie ekrany ze stosu
      );
    }
  }
}
