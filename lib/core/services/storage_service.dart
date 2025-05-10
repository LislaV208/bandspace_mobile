import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:bandspace_mobile/core/models/session.dart';
import 'package:bandspace_mobile/core/models/user.dart';

/// Klucze używane do przechowywania danych w lokalnym magazynie
class StorageKeys {
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String user = 'user';
  static const String session = 'session';
}

/// Serwis odpowiedzialny za zarządzanie lokalnym przechowywaniem danych.
///
/// Używa flutter_secure_storage do bezpiecznego przechowywania wrażliwych danych,
/// takich jak tokeny dostępu i dane użytkownika.
class StorageService {
  final FlutterSecureStorage _storage;

  /// Singleton instance
  static final StorageService _instance = StorageService._internal();

  /// Fabryka zwracająca singleton
  factory StorageService() {
    return _instance;
  }

  /// Konstruktor prywatny inicjalizujący FlutterSecureStorage
  StorageService._internal() : _storage = const FlutterSecureStorage();

  /// Zapisuje token dostępu
  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: StorageKeys.accessToken, value: token);
  }

  /// Odczytuje token dostępu
  Future<String?> getAccessToken() async {
    return await _storage.read(key: StorageKeys.accessToken);
  }

  /// Zapisuje token odświeżania
  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: StorageKeys.refreshToken, value: token);
  }

  /// Odczytuje token odświeżania
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: StorageKeys.refreshToken);
  }

  /// Zapisuje dane użytkownika
  Future<void> saveUser(User user) async {
    final userJson = jsonEncode(user.toJson());
    await _storage.write(key: StorageKeys.user, value: userJson);
  }

  /// Odczytuje dane użytkownika
  Future<User?> getUser() async {
    final userJson = await _storage.read(key: StorageKeys.user);
    if (userJson == null) return null;
    
    try {
      return User.fromJson(jsonDecode(userJson));
    } catch (e) {
      return null;
    }
  }

  /// Zapisuje dane sesji
  Future<void> saveSession(Session session) async {
    final sessionJson = jsonEncode(session.toJson());
    await _storage.write(key: StorageKeys.session, value: sessionJson);
    
    // Zapisz również tokeny i dane użytkownika osobno dla łatwiejszego dostępu
    await saveAccessToken(session.accessToken);
    await saveRefreshToken(session.refreshToken);
    await saveUser(session.user);
  }

  /// Odczytuje dane sesji
  Future<Session?> getSession() async {
    final sessionJson = await _storage.read(key: StorageKeys.session);
    if (sessionJson == null) return null;
    
    try {
      return Session.fromJson(jsonDecode(sessionJson));
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
    await _storage.delete(key: StorageKeys.accessToken);
    await _storage.delete(key: StorageKeys.refreshToken);
    await _storage.delete(key: StorageKeys.user);
    await _storage.delete(key: StorageKeys.session);
  }

  /// Usuwa wszystkie dane z magazynu
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
