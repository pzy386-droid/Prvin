import 'dart:async';
import 'dart:collection';

/// 缓存管理器，提供内存缓存功能以优化数据访问性能
class CacheManager<K, V> {

  CacheManager({int maxSize = 100, Duration ttl = const Duration(minutes: 30)})
    : _maxSize = maxSize,
      _ttl = ttl {
    // 启动定期清理过期缓存的定时器
    _cleanupTimer = Timer.periodic(
      Duration(minutes: ttl.inMinutes ~/ 2),
      (_) => _cleanupExpired(),
    );
  }
  final int _maxSize;
  final Duration _ttl;
  final LinkedHashMap<K, _CacheEntry<V>> _cache = LinkedHashMap();
  Timer? _cleanupTimer;

  /// 获取缓存值
  V? get(K key) {
    final entry = _cache[key];
    if (entry == null) return null;

    // 检查是否过期
    if (_isExpired(entry)) {
      _cache.remove(key);
      return null;
    }

    // 更新访问时间（LRU策略）
    entry.lastAccessed = DateTime.now();

    // 移动到末尾（最近使用）
    _cache.remove(key);
    _cache[key] = entry;

    return entry.value;
  }

  /// 设置缓存值
  void put(K key, V value) {
    // 如果已存在，先删除
    _cache.remove(key);

    // 检查缓存大小限制
    if (_cache.length >= _maxSize) {
      // 删除最久未使用的条目
      final oldestKey = _cache.keys.first;
      _cache.remove(oldestKey);
    }

    // 添加新条目
    _cache[key] = _CacheEntry(
      value: value,
      createdAt: DateTime.now(),
      lastAccessed: DateTime.now(),
    );
  }

  /// 删除缓存值
  V? remove(K key) {
    final entry = _cache.remove(key);
    return entry?.value;
  }

  /// 清空所有缓存
  void clear() {
    _cache.clear();
  }

  /// 检查是否包含指定键
  bool containsKey(K key) {
    final entry = _cache[key];
    if (entry == null) return false;

    if (_isExpired(entry)) {
      _cache.remove(key);
      return false;
    }

    return true;
  }

  /// 获取缓存大小
  int get size => _cache.length;

  /// 获取缓存统计信息
  CacheStats get stats {
    var expiredCount = 0;
    var validCount = 0;

    for (final entry in _cache.values) {
      if (_isExpired(entry)) {
        expiredCount++;
      } else {
        validCount++;
      }
    }

    return CacheStats(
      totalEntries: _cache.length,
      validEntries: validCount,
      expiredEntries: expiredCount,
      maxSize: _maxSize,
      ttl: _ttl,
    );
  }

  /// 检查条目是否过期
  bool _isExpired(_CacheEntry<V> entry) {
    return DateTime.now().difference(entry.createdAt) > _ttl;
  }

  /// 清理过期的缓存条目
  void _cleanupExpired() {
    final expiredKeys = <K>[];

    _cache.forEach((key, entry) {
      if (_isExpired(entry)) {
        expiredKeys.add(key);
      }
    });

    for (final key in expiredKeys) {
      _cache.remove(key);
    }
  }

  /// 销毁缓存管理器
  void dispose() {
    _cleanupTimer?.cancel();
    _cache.clear();
  }
}

/// 缓存条目
class _CacheEntry<V> {

  _CacheEntry({
    required this.value,
    required this.createdAt,
    required this.lastAccessed,
  });
  final V value;
  final DateTime createdAt;
  DateTime lastAccessed;
}

/// 缓存统计信息
class CacheStats {

  const CacheStats({
    required this.totalEntries,
    required this.validEntries,
    required this.expiredEntries,
    required this.maxSize,
    required this.ttl,
  });
  final int totalEntries;
  final int validEntries;
  final int expiredEntries;
  final int maxSize;
  final Duration ttl;

  /// 缓存命中率
  double get hitRate {
    if (totalEntries == 0) return 0;
    return validEntries / totalEntries;
  }

  /// 缓存使用率
  double get usageRate {
    return totalEntries / maxSize;
  }

  @override
  String toString() {
    return 'CacheStats{'
        'total: $totalEntries, '
        'valid: $validEntries, '
        'expired: $expiredEntries, '
        'hitRate: ${(hitRate * 100).toStringAsFixed(1)}%, '
        'usageRate: ${(usageRate * 100).toStringAsFixed(1)}%'
        '}';
  }
}
