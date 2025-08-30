import 'dart:async';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast_io.dart';

/// Menedżer cache'u oparty na bazie danych sembast.
/// Zapewnia trwałe przechowywanie danych w formacie JSON.
class SembastCacheManager {
  static SembastCacheManager? _instance;
  static Database? _database;
  
  static const String _databaseName = 'cached_repository.db';
  static final _store = stringMapStoreFactory.store('cache');

  SembastCacheManager._();

  /// Singleton instance menedżera cache'u.
  static SembastCacheManager get instance {
    _instance ??= SembastCacheManager._();
    return _instance!;
  }

  /// Inicjalizuje bazę danych sembast.
  Future<Database> get database async {
    if (_database != null) return _database!;
    
    final appDocDir = await getApplicationDocumentsDirectory();
    final dbPath = join(appDocDir.path, _databaseName);
    
    _database = await databaseFactoryIo.openDatabase(dbPath);
    return _database!;
  }

  /// Pobiera dane z cache dla danego klucza.
  /// Zwraca null jeśli dane nie istnieją w cache.
  Future<Map<String, dynamic>?> get(String key) async {
    final db = await database;
    final record = await _store.record(key).get(db);
    return record;
  }

  /// Zapisuje dane w cache pod danym kluczem.
  Future<void> set(String key, Map<String, dynamic> data) async {
    final db = await database;
    await _store.record(key).put(db, data);
  }

  /// Usuwa dane z cache dla danego klucza.
  Future<void> delete(String key) async {
    final db = await database;
    await _store.record(key).delete(db);
  }

  /// Czyści wszystkie dane z cache.
  Future<void> clear() async {
    final db = await database;
    await _store.delete(db);
  }

  /// Sprawdza czy dane dla danego klucza istnieją w cache.
  Future<bool> exists(String key) async {
    final db = await database;
    final record = await _store.record(key).get(db);
    return record != null;
  }

  /// Zamyka bazę danych.
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}