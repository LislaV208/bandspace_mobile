import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:google_sign_in/google_sign_in.dart';

import 'package:bandspace_mobile/core/config/env_config.dart';

/// Serwis odpowiedzialny za obsługę Google Sign-In
///
/// Korzysta z najnowszej wersji google_sign_in (7.x) z singleton pattern
class GoogleSignInService {
  static final GoogleSignInService _instance = GoogleSignInService._internal();
  GoogleSignInAccount? _currentUser;
  StreamSubscription<GoogleSignInAuthenticationEvent>? _authSubscription;
  bool _isInitialized = false;
  final _envConfig = EnvConfig();

  late final GoogleSignIn _googleSignIn;

  factory GoogleSignInService() {
    return _instance;
  }

  GoogleSignInService._internal() {
    _googleSignIn = GoogleSignIn.instance;

    // Nasłuchuj zmian stanu autentyfikacji z właściwym zarządzaniem subscription
    _authSubscription = _googleSignIn.authenticationEvents.listen((event) {
      if (event is GoogleSignInAuthenticationEventSignIn) {
        _currentUser = event.user;
        debugPrint(
          'Google Sign-In: Użytkownik zalogowany: ${event.user.email}',
        );
      } else if (event is GoogleSignInAuthenticationEventSignOut) {
        _currentUser = null;
        debugPrint('Google Sign-In: Użytkownik wylogowany');
      }
    });
  }

  /// Czyści zasoby - wywołaj gdy serwis nie jest już potrzebny
  void dispose() {
    _authSubscription?.cancel();
    _authSubscription = null;
  }

  /// Inicjalizuje Google Sign-In z właściwą konfiguracją
  Future<void> initialize({
    String? clientId,
    List<String> scopes = const ['email', 'profile'],
  }) async {
    if (_isInitialized) return;

    try {
      await _googleSignIn.initialize(
        clientId: Platform.isIOS
            ? _envConfig.googleIosClientId
            : null, // Android używa domyślnej konfiguracji
        serverClientId: _envConfig.googleWebClientId,
      );

      // Spróbuj lekkiej autentyfikacji przy starcie
      // _currentUser = await _googleSignIn.attemptLightweightAuthentication();
      _isInitialized = true;
      debugPrint('Google Sign-In: Zainicjalizowano pomyślnie');
    } catch (error) {
      debugPrint('Google Sign-In: Błąd podczas inicjalizacji: $error');
      _isInitialized = true; // Ustaw jako zainicjalizowany mimo błędu
      // Nie rethrow - inicjalizacja może się nie powieść, ale serwis dalej może działać
    }
  }

  /// Loguje użytkownika przez Google
  ///
  /// Zwraca GoogleSignInAccount w przypadku powodzenia, null jeśli użytkownik anulował
  Future<GoogleSignInAccount?> signIn() async {
    await _ensureInitialized();

    // W wersji 7.x używamy attemptLightweightAuthentication() + authenticate()
    GoogleSignInAccount? account = await _googleSignIn
        .attemptLightweightAuthentication();

    // Jeśli lightweight nie zadziała, spróbuj pełnej autoryzacji
    account ??= await _googleSignIn.authenticate();

    _currentUser = account;
    log('Google Sign-In: Pomyślnie zalogowano ${account.email}');
    return account;
  }

  /// Wylogowuje użytkownika z Google
  Future<void> signOut() async {
    await _ensureInitialized();

    try {
      await _googleSignIn.signOut();
      _currentUser = null;
      debugPrint('Google Sign-In: Pomyślnie wylogowano');
    } on PlatformException catch (e) {
      debugPrint(
        'Google Sign-In: Platform error podczas wylogowywania [${e.code}]: ${e.message}',
      );
      // Mimo błędu, wyczyść lokalny stan
      _currentUser = null;
      rethrow;
    } catch (error) {
      debugPrint('Google Sign-In: Błąd podczas wylogowywania: $error');
      // Mimo błędu, wyczyść lokalny stan
      _currentUser = null;
      rethrow;
    }
  }

  /// Rozłącza konto Google od aplikacji
  ///
  /// Różni się od signOut tym, że usuwa również uprawnienia aplikacji
  Future<void> disconnect() async {
    await _ensureInitialized();

    try {
      await _googleSignIn.disconnect();
      _currentUser = null;
      debugPrint('Google Sign-In: Pomyślnie rozłączono konto');
    } on PlatformException catch (e) {
      debugPrint(
        'Google Sign-In: Platform error podczas rozłączania [${e.code}]: ${e.message}',
      );
      // Mimo błędu, wyczyść lokalny stan
      _currentUser = null;
      rethrow;
    } catch (error) {
      debugPrint('Google Sign-In: Błąd podczas rozłączania: $error');
      // Mimo błędu, wyczyść lokalny stan
      _currentUser = null;
      rethrow;
    }
  }

  /// Sprawdza, czy użytkownik jest aktualnie zalogowany przez Google
  Future<bool> isSignedIn() async {
    await _ensureInitialized();

    try {
      // Sprawdź aktualny stan
      final user = await currentUser;
      return user != null;
    } catch (error) {
      debugPrint(
        'Google Sign-In: Błąd podczas sprawdzania stanu logowania: $error',
      );
      return false;
    }
  }

  /// Pobiera aktualnie zalogowane konto Google
  Future<GoogleSignInAccount?> get currentUser async {
    await _ensureInitialized();

    if (_currentUser == null) {
      try {
        _currentUser = await _googleSignIn.attemptLightweightAuthentication();
      } catch (error) {
        debugPrint(
          'Google Sign-In: Błąd podczas pobierania aktualnego użytkownika: $error',
        );
        return null;
      }
    }
    return _currentUser;
  }

  /// Zwraca ID token dla aktualnie zalogowanego użytkownika
  ///
  /// Zawiera informacje o użytkowniku, może być wykorzystany do weryfikacji tożsamości w backendzie
  Future<String?> getIdToken() async {
    final GoogleSignInAccount? account = await currentUser;
    if (account != null) {
      try {
        final GoogleSignInAuthentication auth = account.authentication;
        return auth.idToken;
      } on PlatformException catch (e) {
        debugPrint(
          'Google Sign-In: Platform error podczas pobierania ID token [${e.code}]: ${e.message}',
        );
        return null;
      } catch (error) {
        debugPrint('Google Sign-In: Błąd podczas pobierania ID token: $error');
        return null;
      }
    }
    return null;
  }

  /// Stream dla zdarzeń autentyfikacji
  Stream<GoogleSignInAuthenticationEvent> get authenticationEvents =>
      _googleSignIn.authenticationEvents;

  /// Sprawdza czy serwis jest zainicjalizowany, jeśli nie - inicjalizuje
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }
}
