import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Klucze używane do przechowywania danych connectivity
class ConnectivityStorageKeys {
  static const String lastOnlineTime = 'last_online_time';
}

/// Serwis odpowiedzialny za zarządzanie danymi związanymi z połączeniem internetowym.
///
/// Przechowuje informacje o ostatnim czasie kiedy aplikacja
/// była online, używane do wyświetlania baneru offline.
class ConnectivityStorageService {
  final FlutterSecureStorage _storage;

  /// Singleton instance
  static final ConnectivityStorageService _instance = ConnectivityStorageService._internal();

  /// Factory zwracająca singleton
  factory ConnectivityStorageService() {
    return _instance;
  }

  /// Konstruktor prywatny inicjalizujący FlutterSecureStorage
  ConnectivityStorageService._internal() : _storage = const FlutterSecureStorage();

  // =============== CONNECTIVITY METHODS ===============

  /// Zapisuje czas ostatniego połączenia online
  Future<void> saveLastOnlineTime(DateTime timestamp) async {
    await _storage.write(
      key: ConnectivityStorageKeys.lastOnlineTime,
      value: timestamp.toIso8601String(),
    );
  }

  /// Odczytuje czas ostatniego połączenia online
  Future<DateTime?> getLastOnlineTime() async {
    final timestampStr = await _storage.read(key: ConnectivityStorageKeys.lastOnlineTime);
    if (timestampStr == null) return null;

    try {
      return DateTime.parse(timestampStr);
    } catch (e) {
      return null;
    }
  }

  /// Usuwa zapisany czas ostatniego połączenia
  Future<void> clearLastOnlineTime() async {
    await _storage.delete(key: ConnectivityStorageKeys.lastOnlineTime);
  }

  /// Sprawdza czy mamy zapisany czas ostatniego połączenia
  Future<bool> hasLastOnlineTime() async {
    final timestamp = await getLastOnlineTime();
    return timestamp != null;
  }

  /// Zwraca czas od ostatniego połączenia w minutach
  Future<int?> getMinutesSinceLastOnline() async {
    final lastOnline = await getLastOnlineTime();
    if (lastOnline == null) return null;

    final difference = DateTime.now().difference(lastOnline);
    return difference.inMinutes;
  }

  /// Formatuje czas ostatniego połączenia w języku polskim
  Future<String?> getFormattedTimeSinceLastOnline() async {
    final lastOnline = await getLastOnlineTime();
    if (lastOnline == null) return null;

    final difference = DateTime.now().difference(lastOnline);

    if (difference.inMinutes < 1) {
      return 'przed chwilą';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} min temu';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} godz. temu';
    } else {
      return '${difference.inDays} dni temu';
    }
  }
}