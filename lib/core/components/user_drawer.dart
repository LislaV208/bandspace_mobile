import 'package:flutter/material.dart';

import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:bandspace_mobile/core/theme/theme.dart';

///
/// Zawiera informacje o użytkowniku oraz opcje nawigacji.
class UserDrawer extends StatelessWidget {
  const UserDrawer({
    super.key,
    this.userName = 'Użytkownik',
    this.userEmail = 'uzytkownik@example.com',
    this.avatarUrl,
  });

  /// Nazwa użytkownika do wyświetlenia w nagłówku drawera.
  final String userName;

  /// Email użytkownika do wyświetlenia w nagłówku drawera.
  final String userEmail;

  /// URL do avatara użytkownika. Jeśli null, wyświetlany jest placeholder.
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.background,
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            const Divider(color: AppColors.divider),
            Expanded(child: _buildMenuItems()),
            const Divider(color: AppColors.divider),
            _buildLogoutButton(),
          ],
        ),
      ),
    );
  }

  /// Buduje nagłówek drawera z informacjami o użytkowniku.
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildAvatar(),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(userName, style: AppTextStyles.titleLarge, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(userEmail, style: AppTextStyles.bodySmall, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Buduje avatar użytkownika.
  Widget _buildAvatar() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.primary, width: 2)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child:
            avatarUrl != null
                ? Image.network(
                  avatarUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => _buildAvatarPlaceholder(),
                )
                : _buildAvatarPlaceholder(),
      ),
    );
  }

  /// Buduje placeholder dla avatara, gdy URL jest null lub wystąpił błąd ładowania.
  Widget _buildAvatarPlaceholder() {
    return Container(
      color: AppColors.surfaceMedium,
      child: Center(
        child: Text(
          userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  /// Buduje listę opcji menu.
  Widget _buildMenuItems() {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _buildMenuItem(
          icon: LucideIcons.user,
          title: 'Profil',
          onTap: () {
            // Implementacja nawigacji do profilu
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
    return ListTile(
      leading: Icon(icon, color: AppColors.iconPrimary),
      title: Text(title, style: AppTextStyles.bodyLarge),
      onTap: onTap,
      hoverColor: AppColors.surfaceLight,
      tileColor: Colors.transparent,
    );
  }

  /// Buduje przycisk wylogowania.
  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          icon: const Icon(LucideIcons.logOut),
          label: const Text('Wyloguj się'),
          onPressed: () {
            // Implementacja wylogowania
          },
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
            foregroundColor: AppColors.error,
            side: const BorderSide(color: AppColors.error),
          ),
        ),
      ),
    );
  }
}
