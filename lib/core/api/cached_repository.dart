import 'package:remote_caching/remote_caching.dart';

import 'package:bandspace_mobile/core/api/base_repository.dart';

/// Abstrakcyjna klasa bazowa dla repozytoriów z obsługą cache'owania i offline-first.
///
/// Wszystkie repozytoria dziedziczące po tej klasie będą automatycznie
/// cache'ować wyniki swoich metod i wspierać tryb offline-first.
abstract class CachedRepository extends BaseRepository {
  const CachedRepository({
    required super.apiClient,
  });

  /// Domyślny czas cache'owania dla tego repozytorium.
  /// Może być nadpisany w konkretnych implementacjach.
  Duration? get defaultCacheDuration => null;

  /// Strategia cache'owania dla poszczególnych metod.
  /// Klucz: nazwa metody, wartość: czas cache'owania.
  /// Jeśli metoda nie jest zdefiniowana, używany jest defaultCacheDuration.
  Map<String, Duration> get methodCacheStrategies => {};

  /// Metody, które powinny invalidować cache innych metod po wykonaniu.
  /// Klucz: nazwa metody wywołującej, wartość: lista metod do invalidacji.
  Map<String, List<String>> get invalidationTriggers => {};

  /// Prefiksy kluczy cache dla tego repozytorium.
  /// Domyślnie używa nazwy klasy bez 'Repository'.
  String get cacheKeyPrefix =>
      runtimeType.toString().replaceAll('Repository', '').toLowerCase();

  /// Invaliduje wszystkie cache.
  static Future<void> invalidateAll() async {
    await RemoteCaching.instance.clearCache();
  }

  /// Wykonuje cache'owaną operację.
  ///
  /// [methodName] - nazwa metody do cache'owania
  /// [parameters] - parametry metody (używane do generowania unikalnego klucza)
  /// [remoteCall] - funkcja wykonująca rzeczywiste wywołanie API
  /// [fromJson] - funkcja deserializująca JSON do obiektu typu T
  /// [cacheDuration] - opcjonalny czas cache'owania (nadpisuje domyślny)
  Future<T> cachedCall<T>({
    required String methodName,
    required Map<String, dynamic> parameters,
    required Future<T> Function() remoteCall,
    required T Function(Object?) fromJson,
    Duration? cacheDuration,
  }) async {
    final cacheKey = _generateCacheKey(methodName, parameters);
    final duration =
        cacheDuration ??
        methodCacheStrategies[methodName] ??
        defaultCacheDuration;

    try {
      final result = await RemoteCaching.instance.call<T>(
        cacheKey,
        remote: remoteCall,
        fromJson: fromJson,
        cacheDuration: duration,
      );

      return result;
    } catch (e) {
      // W przypadku błędu cache'a, próbuj wykonać wywołanie bezpośrednio
      rethrow;
    }
  }

  /// Wykonuje cache'owaną operację dla list.
  ///
  /// Specjalna wersja dla operacji zwracających listy obiektów.
  Future<List<T>> cachedListCall<T>({
    required String methodName,
    required Map<String, dynamic> parameters,
    required Future<List<T>> Function() remoteCall,
    required T Function(Map<String, dynamic>) fromJson,
    Duration? cacheDuration,
  }) async {
    final cacheKey = _generateCacheKey(methodName, parameters);
    final duration =
        cacheDuration ??
        methodCacheStrategies[methodName] ??
        defaultCacheDuration;

    try {
      final result = await RemoteCaching.instance.call<List<T>>(
        cacheKey,
        remote: remoteCall,
        fromJson: (json) {
          // RemoteCaching przekazuje dane bezpośrednio z remote()
          if (json is List) {
            return json.map((item) => fromJson(item)).toList();
          }

          return [];
        },
        cacheDuration: duration,
      );

      return result;
    } catch (e) {
      rethrow;
    }
  }

  /// Wykonuje operację mutującą (POST, PUT, DELETE) i invaliduje odpowiednie cache.
  ///
  /// [methodName] - nazwa metody
  /// [parameters] - parametry metody
  /// [remoteCall] - funkcja wykonująca rzeczywiste wywołanie API
  /// [fromJson] - opcjonalna funkcja deserializująca (dla operacji zwracających dane)
  Future<T?> mutatingCall<T>({
    required String methodName,
    required Map<String, dynamic> parameters,
    required Future<T?> Function() remoteCall,
    T? Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final result = await remoteCall();

      // Invaliduj cache zgodnie z konfiguracją
      await _invalidateCache(methodName);

      return result;
    } catch (e) {
      rethrow;
    }
  }

  /// Invaliduje cache dla konkretnej metody.
  Future<void> invalidateMethod(
    String methodName, [
    Map<String, dynamic>? parameters,
  ]) async {
    final cacheKey = _generateCacheKey(methodName, parameters ?? {});
    await RemoteCaching.instance.clearCacheForKey(cacheKey);
  }

  /// Generuje unikalny klucz cache na podstawie nazwy metody i parametrów.
  String _generateCacheKey(String methodName, Map<String, dynamic> parameters) {
    final sortedParams = Map.fromEntries(
      parameters.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );

    final paramString = sortedParams.entries
        .map((entry) => '${entry.key}_${entry.value}')
        .join('_');

    return paramString.isEmpty
        ? '${cacheKeyPrefix}_$methodName'
        : '${cacheKeyPrefix}_${methodName}_$paramString';
  }

  /// Invaliduje cache na podstawie konfiguracji invalidationTriggers.
  Future<void> _invalidateCache(String methodName) async {
    final methodsToInvalidate = invalidationTriggers[methodName];
    if (methodsToInvalidate != null) {
      for (final method in methodsToInvalidate) {
        await invalidateMethod(method);
      }
    }
  }
}
