import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

/// Serwis odpowiedzialny za obsługę Google Sign-In
///
/// Korzysta z pakietu google_sign_in do autoryzacji użytkowników przez Google
class GoogleSignInService {
  static final GoogleSignInService _instance = GoogleSignInService._internal();
  late final GoogleSignIn _googleSignIn;

  factory GoogleSignInService() {
    return _instance;
  }

  GoogleSignInService._internal() {
    _googleSignIn = GoogleSignIn(
      scopes: ['email', 'profile'],
      // Konfiguracja dla różnych platform
      clientId: _getClientId(),
    );
  }

  /// Zwraca odpowiedni Client ID w zależności od platformy
  String? _getClientId() {
    // Na iOS i Android, Client ID jest konfigurowane w plikach konfiguracyjnych
    // Na web potrzebujemy podać Client ID bezpośrednio
    if (kIsWeb) {
      return '773891250246-o4b9rrrbrped2joef6dpa4o7mv2blv8m.apps.googleusercontent.com';
    }
    return null; // Dla iOS/Android używamy konfiguracji z plików
  }

  /// Loguje użytkownika przez Google
  ///
  /// Zwraca GoogleSignInAccount w przypadku powodzenia, null jeśli użytkownik anulował
  Future<GoogleSignInAccount?> signIn() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      
      if (account != null) {
        debugPrint('Google Sign-In: Pomyślnie zalogowano ${account.email}');
      } else {
        debugPrint('Google Sign-In: Użytkownik anulował logowanie');
      }
      
      return account;
    } catch (error) {
      debugPrint('Google Sign-In: Błąd podczas logowania: $error');
      rethrow;
    }
  }

  /// Wylogowuje użytkownika z Google
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      debugPrint('Google Sign-In: Pomyślnie wylogowano');
    } catch (error) {
      debugPrint('Google Sign-In: Błąd podczas wylogowywania: $error');
      rethrow;
    }
  }

  /// Rozłącza konto Google od aplikacji
  ///
  /// Różni się od signOut tym, że usuwa również uprawnienia aplikacji
  Future<void> disconnect() async {
    try {
      await _googleSignIn.disconnect();
      debugPrint('Google Sign-In: Pomyślnie rozłączono konto');
    } catch (error) {
      debugPrint('Google Sign-In: Błąd podczas rozłączania: $error');
      rethrow;
    }
  }

  /// Sprawdza, czy użytkownik jest aktualnie zalogowany przez Google
  Future<bool> isSignedIn() async {
    return await _googleSignIn.isSignedIn();
  }

  /// Pobiera aktualnie zalogowane konto Google
  GoogleSignInAccount? get currentUser => _googleSignIn.currentUser;

  /// Zwraca token autoryzacji dla aktualnie zalogowanego użytkownika
  ///
  /// Potrzebny do wysyłania requestów do backendu
  Future<String?> getAuthToken() async {
    final GoogleSignInAccount? account = _googleSignIn.currentUser;
    if (account != null) {
      final GoogleSignInAuthentication auth = await account.authentication;
      return auth.accessToken;
    }
    return null;
  }

  /// Zwraca ID token dla aktualnie zalogowanego użytkownika
  ///
  /// Zawiera informacje o użytkowniku, może być wykorzystany do weryfikacji tożsamości
  Future<String?> getIdToken() async {
    final GoogleSignInAccount? account = _googleSignIn.currentUser;
    if (account != null) {
      final GoogleSignInAuthentication auth = await account.authentication;
      return auth.idToken;
    }
    return null;
  }
}