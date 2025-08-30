/// Interfejs do operacji na lokalnej bazie danych dla cache'owania.
///
/// Zapewnia ujednolicone API do przechowywania danych w formacie JSON
/// niezależnie od konkretnej implementacji bazy danych.
abstract interface class DatabaseStorage {
  /// Inicjalizuje połączenie z bazą danych.
  /// Musi być wywołana przed użyciem innych metod.
  Future<void> initialize();

  /// Pobiera dane z bazy danych dla danego klucza.
  /// Zwraca null jeśli dane nie istnieją.
  Future<Map<String, dynamic>?> get(String key);

  /// Zapisuje dane w bazie danych pod danym kluczem.
  /// Nadpisuje istniejące dane jeśli klucz już istnieje.
  Future<void> set(String key, Map<String, dynamic> data);

  /// Usuwa dane z bazy danych dla danego klucza.
  /// Nie rzuca błędu jeśli klucz nie istnieje.
  Future<void> delete(String key);

  /// Czyści wszystkie dane z bazy danych.
  Future<void> clear();

  /// Sprawdza czy dane dla danego klucza istnieją w bazie danych.
  Future<bool> exists(String key);

  /// Zamyka połączenie z bazą danych i zwalnia zasoby.
  /// Po wywołaniu tej metody, obiekt nie może być ponownie używany.
  Future<void> dispose();
}
