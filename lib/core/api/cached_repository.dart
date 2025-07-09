import 'package:remote_caching/remote_caching.dart';
import 'package:rxdart/rxdart.dart';

import 'package:bandspace_mobile/core/api/api_repository.dart';

/// Abstrakcyjna klasa bazowa dla repozytoriów z obsługą cache'owania i offline-first.
///
/// Wszystkie repozytoria dziedziczące po tej klasie będą automatycznie
/// cache'ować wyniki swoich metod i wspierać tryb offline-first.
abstract class CachedRepository extends ApiRepository {
  const CachedRepository({
    required super.apiClient,
  });

  /// Mapa przechowująca BehaviorSubject streams dla reaktywnych list.
  /// Klucz: cache key, wartość: BehaviorSubject z danymi.
  static final Map<String, BehaviorSubject<List<dynamic>>> _reactiveStreams =
      {};

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
    // Zamknij wszystkie reaktywne streamy
    for (final subject in _reactiveStreams.values) {
      subject.close();
    }
    _reactiveStreams.clear();
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
    required T Function(Map<String, dynamic>) fromJson,
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
      T? cachedResult;
      try {
        cachedResult = await RemoteCaching.instance.call<T>(
          cacheKey,
          remote: () async => throw Exception('Cache miss'),
          fromJson: (json) => fromJson(json as Map<String, dynamic>),
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
        fromJson: (json) => fromJson(json as Map<String, dynamic>),
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
    bool forceRefresh = false,
  }) async {
    return cachedListStream<T>(
      methodName: methodName,
      parameters: parameters,
      remoteCall: remoteCall,
      fromJson: fromJson,
      cacheDuration: cacheDuration,
      forceRefresh: forceRefresh,
    ).first;
  }

  /// Wykonuje cache'owaną operację dla list jako Stream z strategią stale-while-revalidate.
  ///
  /// Zwraca Stream który najpierw emituje dane z cache (jeśli istnieją),
  /// następnie świeże dane z API po ich pobraniu.
  /// [forceRefresh] - jeśli true, pomija cache i pobiera tylko z API.
  Stream<List<T>> cachedListStream<T>({
    required String methodName,
    required Map<String, dynamic> parameters,
    required Future<List<T>> Function() remoteCall,
    required T Function(Map<String, dynamic>) fromJson,
    Duration? cacheDuration,
    bool forceRefresh = false,
  }) async* {
    final cacheKey = _generateCacheKey(methodName, parameters);
    final duration =
        cacheDuration ??
        methodCacheStrategies[methodName] ??
        defaultCacheDuration;

    try {
      List<T>? cachedResult;

      if (!forceRefresh) {
        // Najpierw próbuj pobrać z cache (tylko jeśli nie forceRefresh)
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

      // Emit świeże dane (jeśli różnią się od cache lub jeśli forceRefresh)
      if (forceRefresh ||
          cachedResult == null ||
          !_listsEqual(cachedResult, freshResult)) {
        yield freshResult;
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Reaktywny stream dla listy z BehaviorSubject.
  ///
  /// Zwraca Stream który będzie emitować nowe dane za każdym razem,
  /// gdy lista zostanie zaktualizowana przez inne metody.
  /// [customCacheKeyPrefix] pozwala nadpisać domyślny prefiks cache key.
  Stream<List<T>> reactiveListStream<T>({
    required String methodName,
    required Map<String, dynamic> parameters,
    required Future<List<T>> Function() remoteCall,
    required T Function(Map<String, dynamic>) fromJson,
    Duration? cacheDuration,
    String? customCacheKeyPrefix,
  }) {
    final cacheKey = _generateCacheKeyWithPrefix(
      methodName,
      parameters,
      customCacheKeyPrefix,
    );

    // Sprawdź czy już istnieje subject dla tego klucza
    if (!_reactiveStreams.containsKey(cacheKey)) {
      _reactiveStreams[cacheKey] = BehaviorSubject<List<T>>();

      // Rozpocznij ładowanie danych
      _loadAndEmitData<T>(
        cacheKey: cacheKey,
        methodName: methodName,
        parameters: parameters,
        remoteCall: remoteCall,
        fromJson: fromJson,
        cacheDuration: cacheDuration,
        customCacheKeyPrefix: customCacheKeyPrefix,
      );
    }

    return _reactiveStreams[cacheKey]!.stream.cast<List<T>>();
  }

  /// Ładuje dane i emituje je do BehaviorSubject.
  Future<void> _loadAndEmitData<T>({
    required String cacheKey,
    required String methodName,
    required Map<String, dynamic> parameters,
    required Future<List<T>> Function() remoteCall,
    required T Function(Map<String, dynamic>) fromJson,
    Duration? cacheDuration,
    String? customCacheKeyPrefix,
  }) async {
    final duration =
        cacheDuration ??
        methodCacheStrategies[methodName] ??
        defaultCacheDuration;

    try {
      // Najpierw próbuj pobrać z cache
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
        cachedResult = null;
      }

      if (cachedResult != null) {
        // Emit dane z cache
        _reactiveStreams[cacheKey]?.add(cachedResult);
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
        _reactiveStreams[cacheKey]?.add(freshResult);
      }
    } catch (e) {
      _reactiveStreams[cacheKey]?.addError(e);
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
    return _generateCacheKeyWithPrefix(methodName, parameters, null);
  }

  /// Generuje unikalny klucz cache z możliwością nadpisania prefiksu.
  String _generateCacheKeyWithPrefix(
    String methodName,
    Map<String, dynamic> parameters,
    String? customPrefix,
  ) {
    final sortedParams = Map.fromEntries(
      parameters.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );

    final paramString = sortedParams.entries
        .map((entry) => '${entry.key}_${entry.value}')
        .join('_');

    final prefix = customPrefix ?? cacheKeyPrefix;

    return paramString.isEmpty
        ? '${prefix}_$methodName'
        : '${prefix}_${methodName}_$paramString';
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

  /// Dodaje nowy element do cache'owanej listy po wykonaniu API call.
  ///
  /// Najpierw wykonuje API call, następnie dodaje nowy element do cache.
  /// [addFirst] określa czy element ma być dodany na początku (true) czy na końcu (false) listy.
  /// [customCacheKeyPrefix] pozwala nadpisać domyślny prefiks cache key.
  Future<T> addToList<T>({
    required String listMethodName,
    required Map<String, dynamic> listParameters,
    required Future<T> Function() createCall,
    required T Function(Map<String, dynamic>) fromJson,
    Duration? cacheDuration,
    bool addFirst = true,
    String? customCacheKeyPrefix,
  }) async {
    final listCacheKey = _generateCacheKeyWithPrefix(
      listMethodName,
      listParameters,
      customCacheKeyPrefix,
    );

    // Wykonaj API call
    final createdItem = await createCall();

    // Pobierz aktualną listę z cache
    List<T>? currentList;
    try {
      currentList = await RemoteCaching.instance.call<List<T>>(
        listCacheKey,
        remote: () async => throw Exception('Cache miss'),
        fromJson: (json) {
          if (json is List) {
            return json
                .map((item) => fromJson(item as Map<String, dynamic>))
                .toList();
          }
          return <T>[];
        },
        cacheDuration: cacheDuration,
      );
    } catch (e) {
      currentList = null;
    }

    // Dodaj nowy element do cache
    if (currentList != null) {
      final updatedList = addFirst
          ? [createdItem, ...currentList]
          : [...currentList, createdItem];
      await RemoteCaching.instance.call<List<T>>(
        listCacheKey,
        remote: () async => updatedList,
        fromJson: (json) {
          if (json is List) {
            return json
                .map((item) => fromJson(item as Map<String, dynamic>))
                .toList();
          }
          return updatedList;
        },
        cacheDuration: cacheDuration,
        forceRefresh: true,
      );

      // Jeśli istnieje reaktywny stream, zaktualizuj go
      if (_reactiveStreams.containsKey(listCacheKey)) {
        _reactiveStreams[listCacheKey]!.add(updatedList);
      }
    }

    return createdItem;
  }

  /// Usuwa element z cache'owanej listy po wykonaniu API call.
  ///
  /// Najpierw wykonuje API call, następnie usuwa element z cache.
  /// [predicate] funkcja określająca który element usunąć z listy.
  /// [customCacheKeyPrefix] pozwala nadpisać domyślny prefiks cache key.
  Future<void> removeFromList<T>({
    required String listMethodName,
    required Map<String, dynamic> listParameters,
    required Future<void> Function() deleteCall,
    required T Function(Map<String, dynamic>) fromJson,
    required bool Function(T) predicate,
    Duration? cacheDuration,
    String? customCacheKeyPrefix,
  }) async {
    final listCacheKey = _generateCacheKeyWithPrefix(
      listMethodName,
      listParameters,
      customCacheKeyPrefix,
    );

    // Wykonaj API call
    await deleteCall();

    // Pobierz aktualną listę z cache
    List<T>? currentList;
    try {
      currentList = await RemoteCaching.instance.call<List<T>>(
        listCacheKey,
        remote: () async => throw Exception('Cache miss'),
        fromJson: (json) {
          if (json is List) {
            return json
                .map((item) => fromJson(item as Map<String, dynamic>))
                .toList();
          }
          return <T>[];
        },
        cacheDuration: cacheDuration,
      );
    } catch (e) {
      currentList = null;
    }

    // Usuń element z cache
    if (currentList != null) {
      final updatedList = currentList
          .where((item) => !predicate(item))
          .toList();
      await RemoteCaching.instance.call<List<T>>(
        listCacheKey,
        remote: () async => updatedList,
        fromJson: (json) {
          if (json is List) {
            return json
                .map((item) => fromJson(item as Map<String, dynamic>))
                .toList();
          }
          return updatedList;
        },
        cacheDuration: cacheDuration,
        forceRefresh: true,
      );

      // Jeśli istnieje reaktywny stream, zaktualizuj go
      if (_reactiveStreams.containsKey(listCacheKey)) {
        _reactiveStreams[listCacheKey]!.add(updatedList);
      }
    }
  }

  /// Aktualizuje element w cache'owanej liście po wykonaniu API call.
  ///
  /// Najpierw wykonuje API call, następnie aktualizuje element w cache.
  /// [predicate] funkcja określająca który element zaktualizować w liście.
  /// [customCacheKeyPrefix] pozwala nadpisać domyślny prefiks cache key.
  Future<T> updateInList<T>({
    required String listMethodName,
    required Map<String, dynamic> listParameters,
    required Future<T> Function() updateCall,
    required T Function(Map<String, dynamic>) fromJson,
    required bool Function(T) predicate,
    Duration? cacheDuration,
    String? customCacheKeyPrefix,
  }) async {
    final listCacheKey = _generateCacheKeyWithPrefix(
      listMethodName,
      listParameters,
      customCacheKeyPrefix,
    );

    // Wykonaj API call
    final updatedItem = await updateCall();

    // Pobierz aktualną listę z cache
    List<T>? currentList;
    try {
      currentList = await RemoteCaching.instance.call<List<T>>(
        listCacheKey,
        remote: () async => throw Exception('Cache miss'),
        fromJson: (json) {
          if (json is List) {
            return json
                .map((item) => fromJson(item as Map<String, dynamic>))
                .toList();
          }
          return <T>[];
        },
        cacheDuration: cacheDuration,
      );
    } catch (e) {
      currentList = null;
    }

    // Aktualizuj element w cache
    if (currentList != null) {
      final updatedList = currentList
          .map((item) => predicate(item) ? updatedItem : item)
          .toList();
      await RemoteCaching.instance.call<List<T>>(
        listCacheKey,
        remote: () async => updatedList,
        fromJson: (json) {
          if (json is List) {
            return json
                .map((item) => fromJson(item as Map<String, dynamic>))
                .toList();
          }
          return updatedList;
        },
        cacheDuration: cacheDuration,
        forceRefresh: true,
      );

      // Jeśli istnieje reaktywny stream, zaktualizuj go
      if (_reactiveStreams.containsKey(listCacheKey)) {
        _reactiveStreams[listCacheKey]!.add(updatedList);
      }
    }

    return updatedItem;
  }

  /// Odświeża cache dla listy i powiadamia subskrybentów streamu.
  ///
  /// Wykonuje API call z forceRefresh=true, co powoduje emission nowych danych
  /// do wszystkich aktywnych subskrybentów streamu.
  Future<void> refreshList<T>({
    required String listMethodName,
    required Map<String, dynamic> listParameters,
    required Future<List<T>> Function() remoteCall,
    required T Function(Map<String, dynamic>) fromJson,
    Duration? cacheDuration,
    String? customCacheKeyPrefix,
  }) async {
    final cacheKey = _generateCacheKeyWithPrefix(
      listMethodName,
      listParameters,
      customCacheKeyPrefix,
    );

    final duration =
        cacheDuration ??
        methodCacheStrategies[listMethodName] ??
        defaultCacheDuration;

    // Wykonaj API call z forceRefresh - to zaktualizuje cache
    final freshData = await RemoteCaching.instance.call<List<T>>(
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

    // Jeśli istnieje reaktywny stream, zaktualizuj go
    if (_reactiveStreams.containsKey(cacheKey)) {
      _reactiveStreams[cacheKey]!.add(freshData);
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
