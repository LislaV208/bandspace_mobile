import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bandspace_mobile/core/theme/theme.dart';
import 'package:bandspace_mobile/features/auth/cubit/auth_cubit.dart';
import 'package:bandspace_mobile/features/auth/cubit/auth_state.dart';
import 'package:bandspace_mobile/shared/models/user.dart';

/// Uniwersalny komponent avatara użytkownika.
///
/// Wyświetla:
/// 1. Zdjęcie avatara użytkownika, jeśli jest dostępne
/// 2. Inicjały użytkownika na podstawie nazwy lub emaila
/// 3. Fallback do aktualnie zalogowanego użytkownika jeśli nie podano konkretnego
class UserAvatar extends StatelessWidget {
  /// Dane użytkownika - jeśli nie podano, używa aktualnie zalogowanego
  final User? user;

  /// URL avatara użytkownika
  final String? avatarUrl;

  /// Nazwa użytkownika (nadpisuje user.name jeśli podano)
  final String? name;

  /// Email użytkownika (nadpisuje user.email jeśli podano)
  final String? email;

  /// Rozmiar awatara w pikselach
  final double size;

  /// Szerokość obramowania
  final double borderWidth;

  /// Kolor obramowania
  final Color? borderColor;

  /// Kolor tła awatara (opcjonalny - będzie wygenerowany automatycznie)
  final Color? backgroundColor;

  /// Styl tekstu dla inicjału
  final TextStyle? textStyle;

  /// Funkcja wywoływana po kliknięciu na avatar
  final VoidCallback? onTap;

  const UserAvatar({
    super.key,
    this.user,
    this.avatarUrl,
    this.name,
    this.email,
    this.size = 40,
    this.borderWidth = 0,
    this.borderColor,
    this.backgroundColor,
    this.textStyle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BlocSelector<AuthCubit, AuthState, User?>(
      selector: (state) => state.user,
      builder: (context, stateUser) {
        final effectiveUser = user ?? stateUser;
        final effectiveName = name ?? effectiveUser?.name;
        final effectiveEmail = email ?? effectiveUser?.email ?? '';
        
        final Widget avatarWidget = Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: borderWidth > 0
                ? Border.all(
                    color: borderColor ?? AppColors.primary,
                    width: borderWidth,
                  )
                : null,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(size / 2),
            child: _buildAvatarContent(effectiveUser, effectiveName, effectiveEmail),
          ),
        );

        if (onTap != null) {
          return GestureDetector(onTap: onTap, child: avatarWidget);
        }

        return avatarWidget;
      },
    );
  }

  /// Buduje zawartość avatara (zdjęcie lub placeholder)
  Widget _buildAvatarContent(User? user, String? name, String email) {
    // Jeśli podano URL avatara, wyświetl go
    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      return Image.network(
        avatarUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildAvatarPlaceholder(user, name, email),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
      );
    }

    // W przeciwnym razie wyświetl placeholder z inicjałami
    return _buildAvatarPlaceholder(user, name, email);
  }

  /// Buduje placeholder dla avatara z inicjałami
  Widget _buildAvatarPlaceholder(User? user, String? name, String email) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? (user != null ? _generateBackgroundColor(user) : AppColors.accent),
        borderRadius: BorderRadius.circular(size / 2),
      ),
      child: Center(
        child: Text(
          _getInitials(user, name, email),
          style: textStyle ??
              TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: size * 0.4,
              ),
        ),
      ),
    );
  }

  /// Generuje inicjały użytkownika
  String _getInitials(User? user, String? name, String email) {
    // Użyj podaną nazwę lub nazwę z obiektu User
    final effectiveName = name ?? user?.name;
    
    // Najpierw sprawdź czy name jest dostępne i nie jest puste
    if (effectiveName != null && effectiveName.trim().isNotEmpty) {
      final names = effectiveName.trim().split(' ');
      if (names.length >= 2) {
        // Jeśli mamy imię i nazwisko, weź pierwszą literę każdego
        return '${names[0][0]}${names[1][0]}'.toUpperCase();
      } else {
        // Jeśli mamy tylko jedno słowo, weź pierwsze dwie litery
        final name = names[0];
        return name.length >= 2
            ? '${name[0]}${name[1]}'.toUpperCase()
            : name[0].toUpperCase();
      }
    }

    // Jeśli name nie jest dostępne, użyj pierwszej litery emaila
    if (email.isNotEmpty) {
      return email[0].toUpperCase();
    }

    // Fallback
    return '?';
  }

  /// Generuje kolor tła na podstawie danych użytkownika
  Color _generateBackgroundColor(User user) {
    // Kolory dopasowane do ciemnej kolorystyki aplikacji - bardziej stonowane odcienie
    final colors = [
      const Color(0xFF1E3A8A), // blue-900 (ciemny niebieski jak w gradiencie)
      const Color(0xFF065F46), // emerald-800 (ciemny zielony)
      const Color(0xFF92400E), // amber-800 (ciemny żółty)
      const Color(0xFF991B1B), // red-800 (ciemny czerwony)
      const Color(0xFF5B21B6), // violet-800 (ciemny fioletowy)
      const Color(0xFF155E75), // cyan-800 (ciemny cyjan)
      const Color(0xFFEA580C), // orange-600 (stonowany pomarańczowy)
      const Color(0xFF365314), // lime-800 (ciemny limonkowy)
      const Color(0xFFBE185D), // pink-700 (stonowany różowy)
      const Color(0xFF312E81), // indigo-900 (ciemny indygo jak w gradiencie)
    ];

    return colors[user.id % colors.length];
  }
}