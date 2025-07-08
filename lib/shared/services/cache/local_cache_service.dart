// // shared/services/cache/persistent_cache_service.dart

// import 'package:hive_flutter/hive_flutter.dart';

// import 'package:bandspace_mobile/shared/services/cache/cache_service.dart';

// class PersistentCacheService implements CacheService {
//   final Box _box = Hive.box('app_cache');

//   @override
//   Future<T?> read<T>(String key) async {
//     // Hive zwraca `dynamic`, więc rzutowanie jest konieczne,
//     // ale dzięki generycznemu interfejsowi jest ono jawne i bezpieczne.
//     final value = _box.get(key);
//     if (value is T) {
//       return value;
//     }
//     return null;
//   }

//   @override
//   Future<void> write<T>(String key, T value) async {
//     await _box.put(key, value);
//   }

//   @override
//   Future<void> delete(String key) async {
//     await _box.delete(key);
//   }

//   @override
//   Future<void> clear() async {
//     await _box.clear();
//   }
// }
