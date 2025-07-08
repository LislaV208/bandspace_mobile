import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'package:bandspace_mobile/shared/models/cached_audio_file.dart';

/// Serwis bazy danych dla cache audio
class AudioCacheDatabase {
  static const String _databaseName = 'audio_cache.db';
  static const int _databaseVersion = 1;
  static const String _tableName = 'cached_audio_files';

  /// Singleton instance
  static final AudioCacheDatabase _instance = AudioCacheDatabase._internal();

  /// Factory zwracająca singleton
  factory AudioCacheDatabase() => _instance;

  /// Konstruktor prywatny
  AudioCacheDatabase._internal();

  /// Instancja bazy danych
  Database? _database;

  /// Getter dla bazy danych z lazy initialization
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  /// Inicjalizuje bazę danych
  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _databaseName);

    return await openDatabase(path, version: _databaseVersion, onCreate: _onCreate, onUpgrade: _onUpgrade);
  }

  /// Tworzy tabele w bazie danych
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        file_id INTEGER PRIMARY KEY,
        song_id INTEGER NOT NULL,
        filename TEXT NOT NULL,
        file_key TEXT NOT NULL,
        mime_type TEXT NOT NULL,
        size INTEGER NOT NULL,
        local_path TEXT,
        status TEXT NOT NULL DEFAULT 'notCached',
        downloaded_at TEXT,
        last_accessed_at TEXT,
        play_count INTEGER NOT NULL DEFAULT 0,
        checksum TEXT,
        created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Indeksy dla optymalizacji zapytań
    await db.execute('CREATE INDEX idx_song_id ON $_tableName (song_id)');
    await db.execute('CREATE INDEX idx_status ON $_tableName (status)');
    await db.execute('CREATE INDEX idx_last_accessed ON $_tableName (last_accessed_at)');
    await db.execute('CREATE INDEX idx_play_count ON $_tableName (play_count DESC)');
  }

  /// Obsługuje upgrade bazy danych
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // W przyszłości tutaj będą migracje
    if (oldVersion < newVersion) {
      // Przykład migracji dla przyszłych wersji
      // if (oldVersion < 2) {
      //   await db.execute('ALTER TABLE $_tableName ADD COLUMN new_column TEXT');
      // }
    }
  }

  /// Wstawia lub aktualizuje plik w cache
  Future<void> insertOrUpdate(CachedAudioFile file) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();

    final data = file.toJson();
    data['updated_at'] = now;

    await db.insert(_tableName, data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Pobiera plik z cache po ID
  Future<CachedAudioFile?> getFile(int fileId) async {
    final db = await database;
    final results = await db.query(_tableName, where: 'file_id = ?', whereArgs: [fileId], limit: 1);

    if (results.isEmpty) return null;
    return CachedAudioFile.fromJson(results.first);
  }

  /// Pobiera wszystkie pliki dla danego utworu
  Future<List<CachedAudioFile>> getFilesBySong(int songId) async {
    final db = await database;
    final results = await db.query(_tableName, where: 'song_id = ?', whereArgs: [songId], orderBy: 'filename ASC');

    return results.map((row) => CachedAudioFile.fromJson(row)).toList();
  }

  /// Pobiera wszystkie cache'owane pliki
  Future<List<CachedAudioFile>> getAllCachedFiles() async {
    final db = await database;
    final results = await db.query(
      _tableName,
      where: 'status = ?',
      whereArgs: [CacheStatus.cached.name],
      orderBy: 'last_accessed_at DESC',
    );

    return results.map((row) => CachedAudioFile.fromJson(row)).toList();
  }

  /// Pobiera pliki według statusu
  Future<List<CachedAudioFile>> getFilesByStatus(CacheStatus status) async {
    final db = await database;
    final results = await db.query(
      _tableName,
      where: 'status = ?',
      whereArgs: [status.name],
      orderBy: 'updated_at DESC',
    );

    return results.map((row) => CachedAudioFile.fromJson(row)).toList();
  }

  /// Aktualizuje status pliku
  Future<void> updateFileStatus(int fileId, CacheStatus status) async {
    final db = await database;
    await db.update(
      _tableName,
      {'status': status.name, 'updated_at': DateTime.now().toIso8601String()},
      where: 'file_id = ?',
      whereArgs: [fileId],
    );
  }

  /// Aktualizuje lokalną ścieżkę pliku
  Future<void> updateLocalPath(int fileId, String localPath) async {
    final db = await database;
    await db.update(
      _tableName,
      {
        'local_path': localPath,
        'status': CacheStatus.cached.name,
        'downloaded_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'file_id = ?',
      whereArgs: [fileId],
    );
  }

  /// Aktualizuje czas ostatniego dostępu i zwiększa licznik odtworzeń
  Future<void> updateLastAccessed(int fileId) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();

    await db.rawUpdate(
      'UPDATE $_tableName SET last_accessed_at = ?, play_count = play_count + 1, updated_at = ? WHERE file_id = ?',
      [now, now, fileId],
    );
  }

  /// Usuwa plik z cache (tylko z bazy danych)
  Future<void> deleteFile(int fileId) async {
    final db = await database;
    await db.delete(_tableName, where: 'file_id = ?', whereArgs: [fileId]);
  }

  /// Usuwa wszystkie pliki dla danego utworu
  Future<void> deleteFilesBySong(int songId) async {
    final db = await database;
    await db.delete(_tableName, where: 'song_id = ?', whereArgs: [songId]);
  }

  /// Pobiera całkowity rozmiar cache w bajtach
  Future<int> getTotalCacheSize() async {
    final db = await database;
    final result = await db.rawQuery('SELECT SUM(size) as total_size FROM $_tableName WHERE status = ?', [
      CacheStatus.cached.name,
    ]);

    final totalSize = result.first['total_size'];
    return totalSize is int ? totalSize : 0;
  }

  /// Pobiera liczbę cache'owanych plików
  Future<int> getCachedFileCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM $_tableName WHERE status = ?', [
      CacheStatus.cached.name,
    ]);

    final count = result.first['count'];
    return count is int ? count : 0;
  }

  /// Pobiera najstarsze pliki według ostatniego dostępu (dla LRU cleanup)
  Future<List<CachedAudioFile>> getOldestFiles({int limit = 10}) async {
    final db = await database;
    final results = await db.query(
      _tableName,
      where: 'status = ?',
      whereArgs: [CacheStatus.cached.name],
      orderBy: 'last_accessed_at ASC, play_count ASC',
      limit: limit,
    );

    return results.map((row) => CachedAudioFile.fromJson(row)).toList();
  }

  /// Pobiera najmniej odtwarzane pliki (dla cleanup)
  Future<List<CachedAudioFile>> getLeastPlayedFiles({int limit = 10}) async {
    final db = await database;
    final results = await db.query(
      _tableName,
      where: 'status = ?',
      whereArgs: [CacheStatus.cached.name],
      orderBy: 'play_count ASC, last_accessed_at ASC',
      limit: limit,
    );

    return results.map((row) => CachedAudioFile.fromJson(row)).toList();
  }

  /// Sprawdza czy plik istnieje w bazie
  Future<bool> fileExists(int fileId) async {
    final db = await database;
    final result = await db.query(_tableName, where: 'file_id = ?', whereArgs: [fileId], limit: 1);

    return result.isNotEmpty;
  }

  /// Czyści wszystkie dane z bazy
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete(_tableName);
  }

  /// Zamyka bazę danych
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  /// Pobiera statystyki cache
  Future<Map<String, dynamic>> getCacheStats() async {
    final db = await database;

    // Całkowity rozmiar cache
    final sizeResult = await db.rawQuery('SELECT SUM(size) as total_size FROM $_tableName WHERE status = ?', [
      CacheStatus.cached.name,
    ]);

    // Liczba plików
    final countResult = await db.rawQuery('SELECT COUNT(*) as count FROM $_tableName WHERE status = ?', [
      CacheStatus.cached.name,
    ]);

    // Łączna liczba odtworzeń
    final playsResult = await db.rawQuery('SELECT SUM(play_count) as total_plays FROM $_tableName WHERE status = ?', [
      CacheStatus.cached.name,
    ]);

    return {
      'totalSize': sizeResult.first['total_size'] ?? 0,
      'fileCount': countResult.first['count'] ?? 0,
      'totalPlays': playsResult.first['total_plays'] ?? 0,
    };
  }
}
