import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:bandspace_mobile/shared/models/session.dart';
import 'package:bandspace_mobile/shared/models/user.dart';

/// Klucze używane do przechowywania danych sesji
class SessionStorageKeys {
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String user = 'user';
  static const String session = 'session';
}

/// Serwis odpowiedzialny za zarządzanie sesjami użytkownika.
///
/// Używa flutter_secure_storage do bezpiecznego przechowywania
/// danych uwierzytelniania takich jak tokeny i dane użytkownika.
class SessionStorageService {
  final FlutterSecureStorage _storage;

  /// Singleton instance
  static final SessionStorageService _instance = SessionStorageService._internal();

  /// Factory zwracająca singleton
  factory SessionStorageService() {
    return _instance;
  }

  /// Konstruktor prywatny inicjalizujący FlutterSecureStorage
  SessionStorageService._internal() : _storage = const FlutterSecureStorage();

  // =============== TOKEN MANAGEMENT ===============

  /// Zapisuje token dostępu
  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: SessionStorageKeys.accessToken, value: token);
  }

  /// Odczytuje token dostępu
  Future<String?> getAccessToken() async {
    return await _storage.read(key: SessionStorageKeys.accessToken);
  }

  /// Zapisuje token odświeżania
  Future<void> saveRefreshToken(String? token) async {
    await _storage.write(key: SessionStorageKeys.refreshToken, value: token);
  }

  /// Odczytuje token odświeżania
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: SessionStorageKeys.refreshToken);
  }

  // =============== USER DATA MANAGEMENT ===============

  /// Zapisuje dane użytkownika
  Future<void> saveUser(User user) async {
    final userJson = jsonEncode(user.toMap());
    await _storage.write(key: SessionStorageKeys.user, value: userJson);
  }

  /// Odczytuje dane użytkownika
  Future<User?> getUser() async {
    final userJson = await _storage.read(key: SessionStorageKeys.user);
    if (userJson == null) return null;

    try {
      return User.fromMap(jsonDecode(userJson));
    } catch (e) {
      return null;
    }
  }

  // =============== SESSION MANAGEMENT ===============

  /// Zapisuje dane sesji
  Future<void> saveSession(Session session) async {
    final sessionJson = jsonEncode(session.toMap());
    await _storage.write(key: SessionStorageKeys.session, value: sessionJson);

    // Zapisz również tokeny i dane użytkownika osobno dla łatwiejszego dostępu
    await saveAccessToken(session.accessToken);
    await saveRefreshToken(session.refreshToken);
    await saveUser(session.user);
  }

  /// Odczytuje dane sesji
  Future<Session?> getSession() async {
    final sessionJson = await _storage.read(key: SessionStorageKeys.session);
    if (sessionJson == null) return null;

    try {
      return Session.fromMap(jsonDecode(sessionJson));
    } catch (e) {
      return null;
    }
  }

  /// Sprawdza, czy użytkownik jest zalogowany
  Future<bool> isLoggedIn() async {
    final accessToken = await getAccessToken();
    final user = await getUser();

    return accessToken != null && user != null;
  }

  /// Usuwa wszystkie dane sesji
  Future<void> clearSession() async {
    await _storage.deleteAll();
    // await _storage.delete(key: SessionStorageKeys.accessToken);
    // await _storage.delete(key: SessionStorageKeys.refreshToken);
    // await _storage.delete(key: SessionStorageKeys.user);
    // await _storage.delete(key: SessionStorageKeys.session);
  }

  /// Usuwa wszystkie dane sesji (alias dla clearSession)
  Future<void> clearAll() async {
    await clearSession();
  }
}
