import 'dart:convert';

import 'package:bandspace_mobile/core/storage/shared_preferences_storage.dart';
import 'package:bandspace_mobile/shared/models/song_download_url.dart';

class SongListUrlsCacheStorage {
  final SharedPreferencesStorage _storage;

  SongListUrlsCacheStorage._internal(this._storage);

  factory SongListUrlsCacheStorage(SharedPreferencesStorage storage) =>
      SongListUrlsCacheStorage._internal(storage);

  Future<void> saveSongListUrls(
    int projectId,
    SongListDownloadUrls urls,
  ) async {
    final key = '${projectId}_urls';
    await _storage.setString(key, jsonEncode(urls.toJson()));
  }

  Future<SongListDownloadUrls?> getSongListUrls(int projectId) async {
    final key = '${projectId}_urls';
    final data = await _storage.getString(key);
    if (data == null) return null;

    try {
      return SongListDownloadUrls.fromJson(jsonDecode(data));
    } catch (e) {
      return null;
    }
  }
}
