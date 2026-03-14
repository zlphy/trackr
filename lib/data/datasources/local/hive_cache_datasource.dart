import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/constants/app_constants.dart';

abstract class HiveCacheDataSource {
  Future<String?> getCachedCategory(String cacheKey);
  Future<void> cacheCategory(String cacheKey, String category);
  Future<void> clearExpiredCache();
}

class HiveCacheDataSourceImpl implements HiveCacheDataSource {
  final Box<Map> _box;

  HiveCacheDataSourceImpl(this._box);

  static Future<HiveCacheDataSourceImpl> create() async {
    await Hive.initFlutter();
    final box = await Hive.openBox<Map>(AppConstants.hiveCacheBox);
    return HiveCacheDataSourceImpl(box);
  }

  String _buildKey(String raw) =>
      raw.toLowerCase().replaceAll(RegExp(r'\s+'), '_');

  @override
  Future<String?> getCachedCategory(String cacheKey) async {
    final key = _buildKey(cacheKey);
    final entry = _box.get(key);
    if (entry == null) return null;

    final timestamp = entry['timestamp'] as int?;
    if (timestamp == null) return null;

    final cached = DateTime.fromMillisecondsSinceEpoch(timestamp);
    if (DateTime.now().difference(cached) > AppConstants.hiveCacheTtl) {
      await _box.delete(key);
      return null;
    }
    return entry['category'] as String?;
  }

  @override
  Future<void> cacheCategory(String cacheKey, String category) async {
    final key = _buildKey(cacheKey);
    await _box.put(key, {
      'category': category,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  @override
  Future<void> clearExpiredCache() async {
    final now = DateTime.now();
    final keysToDelete = <dynamic>[];
    for (final key in _box.keys) {
      final entry = _box.get(key);
      if (entry != null) {
        final timestamp = entry['timestamp'] as int?;
        if (timestamp != null) {
          final cached = DateTime.fromMillisecondsSinceEpoch(timestamp);
          if (now.difference(cached) > AppConstants.hiveCacheTtl) {
            keysToDelete.add(key);
          }
        }
      }
    }
    await _box.deleteAll(keysToDelete);
  }
}
