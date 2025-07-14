import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesStorage {
  SharedPreferencesStorage._internal();

  static final SharedPreferencesStorage _instance =
      SharedPreferencesStorage._internal();

  factory SharedPreferencesStorage() => _instance;

  final SharedPreferencesAsync _prefs = SharedPreferencesAsync();

  Future<void> setString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  Future<String?> getString(String key) async {
    return await _prefs.getString(key);
  }

  Future<void> setBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  Future<bool?> getBool(String key) async {
    return await _prefs.getBool(key);
  }

  Future<void> setInt(String key, int value) async {
    await _prefs.setInt(key, value);
  }

  Future<int?> getInt(String key) async {
    return await _prefs.getInt(key);
  }

  Future<void> setDouble(String key, double value) async {
    await _prefs.setDouble(key, value);
  }

  Future<double?> getDouble(String key) async {
    return await _prefs.getDouble(key);
  }

  Future<void> setStringList(String key, List<String> value) async {
    await _prefs.setStringList(key, value);
  }

  Future<List<String>?> getStringList(String key) async {
    return await _prefs.getStringList(key);
  }

  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }

  Future<void> clear({Set<String>? allowList}) async {
    await _prefs.clear(allowList: allowList);
  }

  Future<bool> containsKey(String key) async {
    return await _prefs.containsKey(key);
  }

  Future<Set<String>> getKeys() async {
    return await _prefs.getKeys();
  }
}
