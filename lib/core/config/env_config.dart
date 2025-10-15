import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Klasa odpowiedzialna za zarządzanie konfiguracją środowiskową aplikacji.
///
/// Zapewnia dostęp do zmiennych środowiskowych zdefiniowanych w plikach .env.
class EnvConfig {
  // Referencja do instancji dotenv
  final dotenv = DotEnv();

  /// Singleton instance
  static final EnvConfig _instance = EnvConfig._internal();

  /// Fabryka zwracająca singleton
  factory EnvConfig() {
    return _instance;
  }

  /// Konstruktor prywatny
  EnvConfig._internal();

  /// Inicjalizuje konfigurację środowiskową, ładując określony plik .env.
  ///
  /// Parametr [fileName] określa nazwę pliku konfiguracyjnego, który ma zostać załadowany.
  /// Domyślnie używany jest plik '.env'.
  Future<void> init({String fileName = '.env'}) async {
    await dotenv.load(fileName: fileName);
  }

  /// Zwraca bazowy URL API z konfiguracji środowiskowej.
  String get apiBaseUrl => dotenv.get('API_BASE_URL');

  /// Zwraca iOS Client ID dla Google Sign-In.
  String get googleIosClientId => dotenv.get('GOOGLE_IOS_CLIENT_ID');

  /// Zwraca Web Client ID dla Google Sign-In (używany jako serverClientId).
  String get googleWebClientId => dotenv.get('GOOGLE_WEB_CLIENT_ID');

  /// Zwraca DSN Sentry.
  String get sentryDsn => dotenv.get('SENTRY_DSN');

  /// Zwraca wartość zmiennej środowiskowej o podanej nazwie.
  ///
  /// Jeśli zmienna nie istnieje, zwraca wartość domyślną [defaultValue].
  String get(String name, {String defaultValue = ''}) {
    return dotenv.env[name] ?? defaultValue;
  }
}
