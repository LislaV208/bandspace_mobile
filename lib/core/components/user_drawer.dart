import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:bandspace_mobile/auth/auth_screen.dart';
import 'package:bandspace_mobile/core/cubit/auth_cubit.dart';
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            const Divider(color: AppColors.divider, height: 1, thickness: 1, indent: 16, endIndent: 16),
            Expanded(child: _buildMenuItems()),
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
                  userName,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.textPrimary,
                  ), // Lekko mniejszy niż titleLarge
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 4),
                Text(
                  userEmail,
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
    return Container(
      width: 64, // Lekko zwiększony rozmiar
      height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primary.withOpacity(0.8), width: 1.5), // Subtelniejsza ramka
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32), // Dopasowanie do rozmiaru
        child:
            avatarUrl != null
                ? Image.network(
                  avatarUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => _buildAvatarPlaceholder(),
                  // Opcjonalnie: Lepsze wrażenia podczas ładowania
                  loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                        value:
                            loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                : null,
                      ),
                    );
                  },
                )
                : _buildAvatarPlaceholder(),
      ),
    );
  }

  /// Buduje placeholder dla avatara, gdy URL jest null lub wystąpił błąd ładowania.
  Widget _buildAvatarPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceMedium,
        borderRadius: BorderRadius.circular(30), // Aby pasowało do ClipRRect
      ),
      child: Center(
        child: Text(
          userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
          style: AppTextStyles.titleLarge.copyWith(color: AppColors.onPrimary.withOpacity(0.8)),
        ),
      ),
    );
  }

  /// Buduje listę opcji menu.
  Widget _buildMenuItems() {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8.0), // Odstęp od Dividerów
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0), // Odstęp między elementami
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0), // Wewnętrzny padding
        leading: Icon(icon, color: AppColors.iconPrimary, size: 22), // Ujednolicony rozmiar ikony
        title: Text(title, style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimary)),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)), // Zaokrąglone krawędzie dla efektów
        hoverColor: AppColors.surfaceLight.withOpacity(0.8),
        splashColor: AppColors.primary.withOpacity(0.15),
        focusColor: AppColors.primary.withOpacity(0.1),
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
