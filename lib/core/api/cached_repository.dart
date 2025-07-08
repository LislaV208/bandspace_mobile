import 'package:remote_caching/remote_caching.dart';

import 'package:bandspace_mobile/core/api/api_repository.dart';

/// Abstrakcyjna klasa bazowa dla repozytoriów z obsługą cache'owania i offline-first.
///
/// Wszystkie repozytoria dziedziczące po tej klasie będą automatycznie
/// cache'ować wyniki swoich metod i wspierać tryb offline-first.
abstract class CachedRepository extends ApiRepository {
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

  /// Wykonuje cache'owaną operację z strategią stale-while-revalidate.
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
    return cachedStream<T>(
      methodName: methodName,
      parameters: parameters,
      remoteCall: remoteCall,
      fromJson: fromJson,
      cacheDuration: cacheDuration,
    ).first;
  }

  /// Wykonuje cache'owaną operację jako Stream z strategią stale-while-revalidate.
  ///
  /// Zwraca Stream który najpierw emituje dane z cache (jeśli istnieją),
  /// następnie świeże dane z API po ich pobraniu.
  Stream<T> cachedStream<T>({
    required String methodName,
    required Map<String, dynamic> parameters,
    required Future<T> Function() remoteCall,
    required T Function(Object?) fromJson,
    Duration? cacheDuration,
  }) async* {
    final cacheKey = _generateCacheKey(methodName, parameters);
    final duration =
        cacheDuration ??
        methodCacheStrategies[methodName] ??
        defaultCacheDuration;

    try {
      // Najpierw próbuj pobrać z cache (bez force refresh)
      T? cachedResult;
      try {
        cachedResult = await RemoteCaching.instance.call<T>(
          cacheKey,
          remote: () async => throw Exception('Cache miss'),
          fromJson: fromJson,
          cacheDuration: duration,
        );
      } catch (error) {
        // Jeśli cache miss - cachedResult pozostaje null
        cachedResult = null;
      }

      if (cachedResult != null) {
        // Najpierw emit dane z cache
        yield cachedResult;
      }

      // Zawsze pobierz świeże dane z API
      final freshResult = await RemoteCaching.instance.call<T>(
        cacheKey,
        remote: remoteCall,
        fromJson: fromJson,
        cacheDuration: duration,
        forceRefresh: true,
      );

      // Emit świeże dane (jeśli różnią się od cache)
      if (cachedResult == null || cachedResult != freshResult) {
        yield freshResult;
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Wykonuje cache'owaną operację dla list z strategią stale-while-revalidate.
  ///
  /// Specjalna wersja dla operacji zwracających listy obiektów.
  Future<List<T>> cachedListCall<T>({
    required String methodName,
    required Map<String, dynamic> parameters,
    required Future<List<T>> Function() remoteCall,
    required T Function(Map<String, dynamic>) fromJson,
    Duration? cacheDuration,
  }) async {
    return cachedListStream<T>(
      methodName: methodName,
      parameters: parameters,
      remoteCall: remoteCall,
      fromJson: fromJson,
      cacheDuration: cacheDuration,
    ).first;
  }

  /// Wykonuje cache'owaną operację dla list jako Stream z strategią stale-while-revalidate.
  ///
  /// Zwraca Stream który najpierw emituje dane z cache (jeśli istnieją),
  /// następnie świeże dane z API po ich pobraniu.
  Stream<List<T>> cachedListStream<T>({
    required String methodName,
    required Map<String, dynamic> parameters,
    required Future<List<T>> Function() remoteCall,
    required T Function(Map<String, dynamic>) fromJson,
    Duration? cacheDuration,
  }) async* {
    final cacheKey = _generateCacheKey(methodName, parameters);
    final duration =
        cacheDuration ??
        methodCacheStrategies[methodName] ??
        defaultCacheDuration;

    try {
      // Najpierw próbuj pobrać z cache (bez force refresh)
      List<T>? cachedResult;
      try {
        cachedResult = await RemoteCaching.instance.call<List<T>>(
          cacheKey,
          remote: () async => throw Exception('Cache miss'),
          fromJson: (json) {
            if (json is List) {
              return json
                  .map((item) => fromJson(item as Map<String, dynamic>))
                  .toList();
            }
            return <T>[];
          },
          cacheDuration: duration,
        );
      } catch (error) {
        // Jeśli cache miss - cachedResult pozostaje null
        cachedResult = null;
      }

      if (cachedResult != null) {
        // Najpierw emit dane z cache
        yield cachedResult;
      }

      // Zawsze pobierz świeże dane z API
      final freshResult = await RemoteCaching.instance.call<List<T>>(
        cacheKey,
        remote: remoteCall,
        fromJson: (json) {
          if (json is List) {
            return json
                .map((item) => fromJson(item as Map<String, dynamic>))
                .toList();
          }
          return <T>[];
        },
        cacheDuration: duration,
        forceRefresh: true,
      );

      // Emit świeże dane (jeśli różnią się od cache)
      if (cachedResult == null || !_listsEqual(cachedResult, freshResult)) {
        yield freshResult;
      }
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


  /// Sprawdza czy dwie listy są równe.
  bool _listsEqual<T>(List<T> list1, List<T> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }
    return true;
  }
}
