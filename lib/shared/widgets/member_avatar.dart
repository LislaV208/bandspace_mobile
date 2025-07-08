import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bandspace_mobile/features/auth/cubit/auth_cubit.dart';
import 'package:bandspace_mobile/features/auth/cubit/auth_state.dart';
import 'package:bandspace_mobile/shared/models/user.dart';

/// Wyświetla awatar użytkownika z inicjałami na podstawie nazwy lub emaila.
/// Może być używany w różnych miejscach aplikacji.
class UserAvatar extends StatelessWidget {
  final User? user;

  /// Rozmiar awatara w pikselach
  final double size;

  /// Szerokość obramowania
  final double borderWidth;

  /// Kolor obramowania
  final Color borderColor;

  /// Kolor tła awatara (opcjonalny - będzie wygenerowany automatycznie)
  final Color? backgroundColor;

  const UserAvatar({
    super.key,
    this.user,
    this.size = 40,
    this.borderWidth = 0,
    this.borderColor = Colors.transparent,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return BlocSelector<AuthCubit, AuthState, User?>(
      selector: (state) => state.user,
      builder: (context, stateUser) {
        final user = this.user ?? stateUser;
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: borderWidth > 0
                ? Border.all(color: borderColor, width: borderWidth)
                : null,
          ),
          child: user != null
              ? CircleAvatar(
                  radius: size / 2,
                  backgroundColor:
                      backgroundColor ?? _generateBackgroundColor(user),
                  child: Text(
                    _getInitials(user),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: size * 0.4,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              : Icon(
                  Icons.person,
                  color: Colors.white,
                  size: size * 0.6,
                ),
        );
      },
    );
  }

  /// Generuje inicjały użytkownika
  String _getInitials(User user) {
    // Najpierw sprawdź czy name jest dostępne i nie jest puste
    if (user.name != null && user.name!.trim().isNotEmpty) {
      final names = user.name!.trim().split(' ');
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
    if (user.email.isNotEmpty) {
      return user.email[0].toUpperCase();
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
