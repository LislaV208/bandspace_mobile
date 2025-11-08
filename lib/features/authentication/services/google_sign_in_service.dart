import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:google_sign_in/google_sign_in.dart';

import 'package:bandspace_mobile/core/config/env_config.dart';

class GoogleSignInService {
  bool _isInitialized = false;
  final _envConfig = EnvConfig();

  final _googleSignIn = GoogleSignIn.instance;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _googleSignIn.initialize(
        clientId: Platform.isIOS ? _envConfig.googleIosClientId : null, // Android używa domyślnej konfiguracji
        serverClientId: _envConfig.googleWebClientId,
      );

      _isInitialized = true;
      log('Google Sign-In: Zainicjalizowano pomyślnie');
    } catch (error) {
      log('Google Sign-In: Błąd podczas inicjalizacji: $error');
      _isInitialized = false;
    }
  }

  Future<GoogleSignInAccount?> signIn() async {
    await _ensureInitialized();

    try {
      final account = await _googleSignIn.authenticate();

      return account;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        log('Google Sign-In: Użytkownik anulował logowanie');
        return null;
      }

      rethrow;
    }
  }

  Future<void> signOut() async {
    await _ensureInitialized();
    await _googleSignIn.signOut();
  }

  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }
}
