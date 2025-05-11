import 'package:flutter/material.dart';

import 'package:bandspace_mobile/core/theme/theme.dart';

/// Uniwersalny komponent avatara użytkownika.
///
/// Wyświetla:
/// 1. Zdjęcie avatara użytkownika, jeśli jest dostępne
/// 2. Pierwszą literę nazwy użytkownika, jeśli nie ma zdjęcia
/// 3. Pierwszą literę adresu email, jeśli nie ma ani zdjęcia, ani nazwy
class UserAvatar extends StatelessWidget {
  /// Konstruktor dla dowolnych danych
  const UserAvatar({
    super.key,
    this.avatarUrl,
    this.name,
    required this.email,
    this.size = 40,
    this.borderWidth = 2,
    this.borderColor,
    this.backgroundColor,
    this.textStyle,
    this.onTap,
  });

  /// URL avatara użytkownika
  final String? avatarUrl;

  /// Nazwa użytkownika
  final String? name;

  /// Adres email użytkownika
  final String email;

  /// Rozmiar avatara (szerokość i wysokość)
  final double size;

  /// Szerokość obramowania
  final double borderWidth;

  /// Kolor obramowania (domyślnie AppColors.primary)
  final Color? borderColor;

  /// Kolor tła dla placeholdera (domyślnie AppColors.surfaceMedium)
  final Color? backgroundColor;

  /// Styl tekstu dla inicjału (domyślnie biały, pogrubiony)
  final TextStyle? textStyle;

  /// Funkcja wywoływana po kliknięciu na avatar
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Widget avatarWidget = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: borderColor ?? AppColors.primary, width: borderWidth),
      ),
      child: ClipRRect(borderRadius: BorderRadius.circular(size / 2), child: _buildAvatarContent()),
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: avatarWidget);
    }

    return avatarWidget;
  }

  /// Buduje zawartość avatara (zdjęcie lub placeholder)
  Widget _buildAvatarContent() {
    // Jeśli użytkownik ma URL avatara, wyświetl go
    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      return Image.network(
        avatarUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildAvatarPlaceholder(),
        loadingBuilder: (context, child, loadingProgress) {
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
      );
    }

    // W przeciwnym razie wyświetl placeholder z inicjałem
    return _buildAvatarPlaceholder();
  }

  /// Buduje placeholder dla avatara z inicjałem
  Widget _buildAvatarPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.accent,
        borderRadius: BorderRadius.circular(size / 2),
      ),
      child: Center(
        child: Text(
          _getInitial(),
          style:
              textStyle ??
              TextStyle(
                color: AppColors.onPrimary.withAlpha(204),
                fontWeight: FontWeight.bold,
                fontSize: size * 0.4, // Dostosowanie rozmiaru czcionki do rozmiaru avatara
              ),
        ),
      ),
    );
  }

  /// Zwraca inicjał użytkownika (pierwszą literę imienia lub adresu email)
  String _getInitial() {
    if (name != null && name!.isNotEmpty) {
      return name![0].toUpperCase();
    }
    if (email.isNotEmpty) {
      return email[0].toUpperCase();
    }
    return '?';
  }
}
