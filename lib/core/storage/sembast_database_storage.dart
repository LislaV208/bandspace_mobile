import 'dart:async';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast_io.dart';

import 'database_storage.dart';

/// Implementacja DatabaseStorage używająca biblioteki sembast.
/// 
/// Zapewnia trwałe przechowywanie danych w lokalnej bazie danych
/// z automatycznym zarządzaniem połączeniem i obsługą błędów.
class SembastDatabaseStorage implements DatabaseStorage {
  final String _name;
  late final StoreRef<String, Map<String, Object?>> _store;
  
  Database? _database;
  bool _isInitialized = false;

  /// Tworzy nową instancję SembastDatabaseStorage.
  /// 
  /// [name] - nazwa używana zarówno jako nazwa pliku bazy danych ({name}.db)
  /// jak i nazwa store'a w bazie danych
  SembastDatabaseStorage({
    required String name,
  }) : _name = name {
    _store = stringMapStoreFactory.store(_name);
  }

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      final appDocDir = await getApplicationDocumentsDirectory();
      final dbPath = join(appDocDir.path, '$_name.db');
      
      _database = await databaseFactoryIo.openDatabase(dbPath);
      _isInitialized = true;
    } catch (e) {
      _database = null;
      _isInitialized = false;
      rethrow;
    }
  }

  /// Zapewnia, że baza danych jest zainicjalizowana przed operacją.
  Future<Database> get _ensureDatabase async {
    if (!_isInitialized || _database == null) {
      await initialize();
    }
    return _database!;
  }

  @override
  Future<Map<String, dynamic>?> get(String key) async {
    try {
      final db = await _ensureDatabase;
      final record = await _store.record(key).get(db);
      return record;
    } catch (e) {
      // Log error and return null instead of crashing
      return null;
    }
  }

  @override
  Future<void> set(String key, Map<String, dynamic> data) async {
    try {
      final db = await _ensureDatabase;
      await _store.record(key).put(db, data);
    } catch (e) {
      // Re-throw to allow caller to handle the error
      rethrow;
    }
  }

  @override
  Future<void> delete(String key) async {
    try {
      final db = await _ensureDatabase;
      await _store.record(key).delete(db);
    } catch (e) {
      // Ignore delete errors - key might not exist
    }
  }

  @override
  Future<void> clear() async {
    try {
      final db = await _ensureDatabase;
      await _store.delete(db);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<bool> exists(String key) async {
    try {
      final db = await _ensureDatabase;
      final record = await _store.record(key).get(db);
      return record != null;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> dispose() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
      _isInitialized = false;
    }
  }
}