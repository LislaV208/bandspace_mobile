import 'package:rxdart/rxdart.dart';

import 'package:bandspace_mobile/core/api/api_repository.dart';
import 'package:bandspace_mobile/core/storage/database_storage.dart';

class RepositoryResponse<T> {
  final T? cached;
  final Stream<T> stream;

  const RepositoryResponse({
    required this.cached,
    required this.stream,
  });
}

/// Abstrakcyjna klasa bazowa dla repozytoriów z obsługą cache'owania i offline-first.
///
/// Wszystkie repozytoria dziedziczące po tej klasie będą automatycznie
/// cache'ować wyniki swoich metod i wspierać tryb offline-first.
abstract class CachedRepository extends ApiRepository {
  final DatabaseStorage _databaseStorage;

  const CachedRepository({
    required super.apiClient,
    required DatabaseStorage databaseStorage,
  }) : _databaseStorage = databaseStorage;

  /// Mapa przechowująca PublishSubject streams dla reaktywnych list.
  /// Klucz: cache key, wartość: PublishSubject z danymi.
  static final Map<String, PublishSubject<List<dynamic>>> _reactiveStreams = {};

  /// Mapa przechowująca PublishSubject streams dla reaktywnych pojedynczych elementów.
  /// Klucz: cache key, wartość: PublishSubject z danymi.
  static final Map<String, PublishSubject<dynamic>> _reactiveSingleStreams = {};

  /// Metody, które powinny invalidować cache innych metod po wykonaniu.
  /// Klucz: nazwa metody wywołującej, wartość: lista metod do invalidacji.
  Map<String, List<String>> get invalidationTriggers => {};

  /// Prefiksy kluczy cache dla tego repozytorium.
  /// Domyślnie używa nazwy klasy bez 'Repository'.
  String get cacheKeyPrefix =>
      runtimeType.toString().replaceAll('Repository', '').toLowerCase();

  /// Invaliduje wszystkie cache.
  Future<void> invalidateAll() async {
    await _databaseStorage.clear();
    // Zamknij wszystkie reaktywne streamy
    for (final subject in _reactiveStreams.values) {
      subject.close();
    }
    _reactiveStreams.clear();

    // Zamknij wszystkie reaktywne pojedyncze streamy
    for (final subject in _reactiveSingleStreams.values) {
      subject.close();
    }
    _reactiveSingleStreams.clear();
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
    Duration?
    cacheDuration, // Zachowany dla kompatybilności API, ale ignorowany
    bool forceRefresh = false,
  }) async* {
    final cacheKey = _generateCacheKey(methodName, parameters);

    try {
      List<T>? cachedResult;

      if (!forceRefresh) {
        // Najpierw próbuj pobrać z cache (tylko jeśli nie forceRefresh)
        try {
          final cachedData = await _databaseStorage.get(cacheKey);
          if (cachedData != null && cachedData['data'] is List) {
            cachedResult = (cachedData['data'] as List)
                .map((item) => fromJson(item as Map<String, dynamic>))
                .toList();
          }
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
      final freshResult = await remoteCall();

      // Zapisz w cache
      await _databaseStorage.set(cacheKey, {
        'data': freshResult.map((item) => (item as dynamic).toJson()).toList(),
      });

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

  /// Hybrydowy stream dla listy zwracający zarówno cache jak i fresh stream.
  ///
  /// Zwraca Future z RepositoryResponse zawierającym:
  /// - cached: dane z cache (null jeśli brak cache)
  /// - stream: reaktywny stream który automatycznie aktualizuje się podczas refreshList
  /// [customCacheKeyPrefix] pozwala nadpisać domyślny prefiks cache key.
  Future<RepositoryResponse<List<T>>> hybridListStream<T>({
    required String methodName,
    required Map<String, dynamic> parameters,
    required Future<List<T>> Function() remoteCall,
    required T Function(Map<String, dynamic>) fromJson,
    Duration?
    cacheDuration, // Zachowany dla kompatybilności API, ale ignorowany
    String? customCacheKeyPrefix,
  }) async {
    final cacheKey = _generateCacheKeyWithPrefix(
      methodName,
      parameters,
      customCacheKeyPrefix,
    );

    // Pobierz dane z cache (asynchronicznie)
    List<T>? cachedData;
    try {
      final cachedResult = await _databaseStorage.get(cacheKey);
      if (cachedResult != null && cachedResult['data'] is List) {
        cachedData = (cachedResult['data'] as List)
            .map((item) => fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {
      // Cache miss - cachedData pozostaje null
      cachedData = null;
    }

    // Sprawdź czy już istnieje reactive stream dla tego klucza
    if (!_reactiveStreams.containsKey(cacheKey)) {
      _reactiveStreams[cacheKey] = PublishSubject<List<T>>();
    }
    // Rozpocznij ładowanie świeżych danych w tle
    _loadAndEmitData<T>(
      cacheKey: cacheKey,
      methodName: methodName,
      parameters: parameters,
      remoteCall: remoteCall,
      fromJson: fromJson,
      customCacheKeyPrefix: customCacheKeyPrefix,
    );

    // Zwróć cached dane i reaktywny stream
    return RepositoryResponse(
      cached: cachedData,
      stream: _reactiveStreams[cacheKey]!.stream.cast<List<T>>(),
    );
  }

  /// Reaktywny stream dla pojedynczego elementu z PublishSubject.
  ///
  /// Zwraca Stream który będzie emitować nowe dane za każdym razem,
  /// gdy element zostanie zaktualizowany przez inne metody.
  Stream<T> reactiveStream<T>({
    required String methodName,
    required Map<String, dynamic> parameters,
    required Future<T> Function() remoteCall,
    required T Function(Map<String, dynamic>) fromJson,
    Duration?
    cacheDuration, // Zachowany dla kompatybilności API, ale ignorowany
  }) {
    final cacheKey = _generateCacheKey(methodName, parameters);

    // Sprawdź czy już istnieje subject dla tego klucza
    if (!_reactiveSingleStreams.containsKey(cacheKey)) {
      _reactiveSingleStreams[cacheKey] = PublishSubject<T>();

      // Rozpocznij ładowanie danych
      _loadAndEmitSingleData<T>(
        cacheKey: cacheKey,
        methodName: methodName,
        parameters: parameters,
        remoteCall: remoteCall,
        fromJson: fromJson,
      );
    }

    return _reactiveSingleStreams[cacheKey]!.stream.cast<T>();
  }

  /// Ładuje dane i emituje je do PublishSubject dla pojedynczego elementu.
  Future<void> _loadAndEmitSingleData<T>({
    required String cacheKey,
    required String methodName,
    required Map<String, dynamic> parameters,
    required Future<T> Function() remoteCall,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    try {
      // Najpierw próbuj pobrać z cache
      T? cachedResult;
      try {
        final cachedData = await _databaseStorage.get(cacheKey);
        if (cachedData != null && cachedData['data'] is Map) {
          cachedResult = fromJson(cachedData['data'] as Map<String, dynamic>);
        }
      } catch (error) {
        cachedResult = null;
      }

      if (cachedResult != null) {
        // Emit dane z cache
        _reactiveSingleStreams[cacheKey]?.add(cachedResult);
      }

      // Zawsze pobierz świeże dane z API
      final freshResult = await remoteCall();

      // Zapisz w cache
      await _databaseStorage.set(cacheKey, {
        'data': (freshResult as dynamic).toJson(),
      });

      // Emit świeże dane (jeśli różnią się od cache)
      if (cachedResult == null || cachedResult != freshResult) {
        _reactiveSingleStreams[cacheKey]?.add(freshResult);
      }
    } catch (e) {
      _reactiveSingleStreams[cacheKey]?.addError(e);
    }
  }

  /// Ładuje dane i emituje je do PublishSubject.
  Future<void> _loadAndEmitData<T>({
    required String cacheKey,
    required String methodName,
    required Map<String, dynamic> parameters,
    required Future<List<T>> Function() remoteCall,
    required T Function(Map<String, dynamic>) fromJson,
    String? customCacheKeyPrefix,
  }) async {
    try {
      // Zawsze pobierz świeże dane z API
      final freshResult = await remoteCall();

      // Zapisz w cache
      await _databaseStorage.set(cacheKey, {
        'data': freshResult.map((item) => (item as dynamic).toJson()).toList(),
      });

      // Emit świeże dane
      _reactiveStreams[cacheKey]?.add(freshResult);
    } catch (e) {
      _reactiveStreams[cacheKey]?.addError(e);
    }
  }

  /// Invaliduje cache dla konkretnej metody.
  Future<void> invalidateMethod(
    String methodName, [
    Map<String, dynamic>? parameters,
  ]) async {
    final cacheKey = _generateCacheKey(methodName, parameters ?? {});
    await _databaseStorage.delete(cacheKey);
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
    Duration?
    cacheDuration, // Zachowany dla kompatybilności API, ale ignorowany
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
      final cachedData = await _databaseStorage.get(listCacheKey);
      if (cachedData != null && cachedData['data'] is List) {
        currentList = (cachedData['data'] as List)
            .map((item) => fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      currentList = null;
    }

    // Dodaj nowy element do cache
    if (currentList != null) {
      final updatedList = addFirst
          ? [createdItem, ...currentList]
          : [...currentList, createdItem];

      await _databaseStorage.set(listCacheKey, {
        'data': updatedList.map((item) => (item as dynamic).toJson()).toList(),
      });

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
    Duration?
    cacheDuration, // Zachowany dla kompatybilności API, ale ignorowany
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
      final cachedData = await _databaseStorage.get(listCacheKey);
      if (cachedData != null && cachedData['data'] is List) {
        currentList = (cachedData['data'] as List)
            .map((item) => fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      currentList = null;
    }

    // Usuń element z cache
    if (currentList != null) {
      final updatedList = currentList
          .where((item) => !predicate(item))
          .toList();

      await _databaseStorage.set(listCacheKey, {
        'data': updatedList.map((item) => (item as dynamic).toJson()).toList(),
      });

      // Jeśli istnieje reaktywny stream, zaktualizuj go
      if (_reactiveStreams.containsKey(listCacheKey)) {
        _reactiveStreams[listCacheKey]!.add(updatedList);
      }
    }
  }

  /// Aktualizuje pojedynczy element w cache po wykonaniu API call.
  ///
  /// Najpierw wykonuje API call, następnie aktualizuje cache.
  /// Przydatne do aktualizacji pojedynczego obiektu bez pobierania listy.
  Future<T> updateSingle<T>({
    required String methodName,
    required Map<String, dynamic> parameters,
    required Future<T> Function() updateCall,
    required T Function(Map<String, dynamic>) fromJson,
    Duration?
    cacheDuration, // Zachowany dla kompatybilności API, ale ignorowany
  }) async {
    final cacheKey = _generateCacheKey(methodName, parameters);

    // Wykonaj API call
    final updatedItem = await updateCall();

    // Zaktualizuj cache
    await _databaseStorage.set(cacheKey, {
      'data': (updatedItem as dynamic).toJson(),
    });

    // Jeśli istnieje reaktywny stream, zaktualizuj go
    if (_reactiveSingleStreams.containsKey(cacheKey)) {
      _reactiveSingleStreams[cacheKey]!.add(updatedItem);
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
    Duration?
    cacheDuration, // Zachowany dla kompatybilności API, ale ignorowany
    String? customCacheKeyPrefix,
  }) async {
    final cacheKey = _generateCacheKeyWithPrefix(
      listMethodName,
      listParameters,
      customCacheKeyPrefix,
    );

    // Wykonaj API call - to zaktualizuje cache
    final freshData = await remoteCall();

    await _databaseStorage.set(cacheKey, {
      'data': freshData.map((item) => (item as dynamic).toJson()).toList(),
    });

    // Jeśli istnieje reaktywny stream, zaktualizuj go
    if (_reactiveStreams.containsKey(cacheKey)) {
      _reactiveStreams[cacheKey]!.add(freshData);
    }
  }

  /// Odświeża cache dla pojedynczego elementu i powiadamia subskrybentów streamu.
  ///
  /// Wykonuje API call z forceRefresh=true, co powoduje emission nowych danych
  /// do wszystkich aktywnych subskrybentów streamu.
  Future<void> refreshSingle<T>({
    required String methodName,
    required Map<String, dynamic> parameters,
    required Future<T> Function() remoteCall,
    required T Function(Map<String, dynamic>) fromJson,
    Duration?
    cacheDuration, // Zachowany dla kompatybilności API, ale ignorowany
  }) async {
    final cacheKey = _generateCacheKey(methodName, parameters);

    // Wykonaj API call - to zaktualizuje cache
    final freshData = await remoteCall();

    await _databaseStorage.set(cacheKey, {
      'data': (freshData as dynamic).toJson(),
    });

    // Jeśli istnieje reaktywny stream, zaktualizuj go
    if (_reactiveSingleStreams.containsKey(cacheKey)) {
      _reactiveSingleStreams[cacheKey]!.add(freshData);
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
