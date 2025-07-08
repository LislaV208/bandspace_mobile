abstract class CacheService {
  /// Odczytuje wartość typu <T> z cache pod podanym kluczem.
  /// Zwraca null, jeśli klucz nie istnieje.
  Future<T?> read<T>(String key);

  /// Zapisuje wartość typu <T> do cache pod podanym kluczem.
  Future<void> write<T>(String key, T value);

  /// Usuwa wpis z cache.
  Future<void> delete(String key);

  /// Czyści cały cache.
  Future<void> clear();
}
