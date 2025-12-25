import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';

/// 内存优化器
///
/// 提供内存使用优化功能，包括对象池管理、
/// 弱引用缓存、内存泄漏检测等功能
class MemoryOptimizer {
  MemoryOptimizer._();

  static final MemoryOptimizer _instance = MemoryOptimizer._();
  static MemoryOptimizer get instance => _instance;

  // 对象池
  final Map<Type, Queue<dynamic>> _objectPools = {};
  final Map<Type, int> _poolSizes = {};

  // 弱引用缓存
  final Map<String, WeakReference<dynamic>> _weakCache = {};

  // 内存监控
  final List<MemorySnapshot> _memorySnapshots = [];
  Timer? _memoryMonitorTimer;

  // 配置
  static const int _defaultPoolSize = 10;
  static const int _maxPoolSize = 50;
  static const Duration _cleanupInterval = Duration(minutes: 2);
  static const Duration _snapshotInterval = Duration(seconds: 30);

  /// 启动内存优化器
  void start() {
    _startMemoryMonitoring();
    _startPeriodicCleanup();

    if (kDebugMode) {
      print('MemoryOptimizer started');
    }
  }

  /// 停止内存优化器
  void stop() {
    _memoryMonitorTimer?.cancel();
    _clearAllPools();
    _weakCache.clear();
    _memorySnapshots.clear();

    if (kDebugMode) {
      print('MemoryOptimizer stopped');
    }
  }

  /// 从对象池获取对象
  T? getFromPool<T>() {
    final pool = _objectPools[T];
    if (pool != null && pool.isNotEmpty) {
      return pool.removeFirst() as T;
    }
    return null;
  }

  /// 将对象返回到对象池
  void returnToPool<T>(T object) {
    if (object == null) return;

    final type = T;
    final pool = _objectPools.putIfAbsent(type, Queue<dynamic>.new);
    final maxSize = _poolSizes[type] ?? _defaultPoolSize;

    if (pool.length < maxSize) {
      // 重置对象状态（如果需要）
      _resetObjectState(object as Object);
      pool.add(object);
    }
  }

  /// 设置对象池大小
  void setPoolSize<T>(int size) {
    final clampedSize = size.clamp(1, _maxPoolSize);
    _poolSizes[T] = clampedSize;

    // 如果当前池大小超过新限制，移除多余对象
    final pool = _objectPools[T];
    if (pool != null) {
      while (pool.length > clampedSize) {
        pool.removeLast();
      }
    }
  }

  /// 预热对象池
  void warmupPool<T>(T Function() factory, int count) {
    final pool = _objectPools.putIfAbsent(T, Queue<dynamic>.new);
    final maxSize = _poolSizes[T] ?? _defaultPoolSize;
    final targetCount = count.clamp(0, maxSize);

    for (var i = pool.length; i < targetCount; i++) {
      pool.add(factory());
    }
  }

  /// 存储弱引用
  void storeWeakReference(String key, Object object) {
    _weakCache[key] = WeakReference(object);
  }

  /// 获取弱引用对象
  T? getWeakReference<T>(String key) {
    final weakRef = _weakCache[key];
    if (weakRef != null) {
      final target = weakRef.target;
      if (target != null) {
        return target as T;
      } else {
        // 对象已被垃圾回收，移除弱引用
        _weakCache.remove(key);
      }
    }
    return null;
  }

  /// 清理无效的弱引用
  void cleanupWeakReferences() {
    final keysToRemove = <String>[];

    _weakCache.forEach((key, weakRef) {
      if (weakRef.target == null) {
        keysToRemove.add(key);
      }
    });

    for (final key in keysToRemove) {
      _weakCache.remove(key);
    }

    if (kDebugMode && keysToRemove.isNotEmpty) {
      print('Cleaned up ${keysToRemove.length} invalid weak references');
    }
  }

  /// 强制垃圾回收（仅在调试模式下）
  void forceGarbageCollection() {
    if (kDebugMode) {
      // 在Flutter中，我们无法直接触发GC
      // 但可以通过清理缓存来释放内存
      cleanupWeakReferences();
      _cleanupObjectPools();

      print('Forced memory cleanup completed');
    }
  }

  /// 获取内存使用统计
  MemoryStats getMemoryStats() {
    final poolStats = <String, int>{};
    var totalPooledObjects = 0;

    _objectPools.forEach((type, pool) {
      final count = pool.length;
      poolStats[type.toString()] = count;
      totalPooledObjects += count;
    });

    return MemoryStats(
      pooledObjectsCount: totalPooledObjects,
      poolStats: poolStats,
      weakReferencesCount: _weakCache.length,
      memorySnapshotsCount: _memorySnapshots.length,
    );
  }

  /// 检测潜在的内存泄漏
  List<MemoryLeak> detectMemoryLeaks() {
    final leaks = <MemoryLeak>[];

    // 检查对象池是否过大
    _objectPools.forEach((type, pool) {
      final maxSize = _poolSizes[type] ?? _defaultPoolSize;
      if (pool.length > maxSize * 0.8) {
        leaks.add(
          MemoryLeak(
            type: MemoryLeakType.oversizedPool,
            description:
                'Object pool for $type is ${pool.length}/$maxSize (${(pool.length / maxSize * 100).toStringAsFixed(1)}% full)',
            severity: pool.length >= maxSize
                ? MemoryLeakSeverity.high
                : MemoryLeakSeverity.medium,
          ),
        );
      }
    });

    // 检查弱引用缓存是否过大
    if (_weakCache.length > 100) {
      leaks.add(
        MemoryLeak(
          type: MemoryLeakType.excessiveWeakReferences,
          description: 'Weak reference cache has ${_weakCache.length} entries',
          severity: _weakCache.length > 500
              ? MemoryLeakSeverity.high
              : MemoryLeakSeverity.medium,
        ),
      );
    }

    // 检查内存快照增长趋势
    if (_memorySnapshots.length >= 10) {
      final recent = _memorySnapshots
          .skip(_memorySnapshots.length - 5)
          .toList();
      final older = _memorySnapshots
          .skip(_memorySnapshots.length - 10)
          .take(5)
          .toList();

      final recentAvg =
          recent
              .map((MemorySnapshot s) => s.estimatedMemoryMB)
              .reduce((double a, double b) => a + b) /
          recent.length;
      final olderAvg =
          older
              .map((MemorySnapshot s) => s.estimatedMemoryMB)
              .reduce((double a, double b) => a + b) /
          older.length;

      if (recentAvg > olderAvg * 1.5) {
        leaks.add(
          MemoryLeak(
            type: MemoryLeakType.memoryGrowth,
            description:
                'Memory usage increased from ${olderAvg.toStringAsFixed(1)}MB to ${recentAvg.toStringAsFixed(1)}MB',
            severity: recentAvg > olderAvg * 2
                ? MemoryLeakSeverity.high
                : MemoryLeakSeverity.medium,
          ),
        );
      }
    }

    return leaks;
  }

  /// 开始内存监控
  void _startMemoryMonitoring() {
    _memoryMonitorTimer = Timer.periodic(_snapshotInterval, (_) {
      _takeMemorySnapshot();
    });
  }

  /// 开始定期清理
  void _startPeriodicCleanup() {
    Timer.periodic(_cleanupInterval, (_) {
      cleanupWeakReferences();
      _cleanupObjectPools();
      _trimMemorySnapshots();
    });
  }

  /// 拍摄内存快照
  void _takeMemorySnapshot() {
    final snapshot = MemorySnapshot(
      timestamp: DateTime.now(),
      pooledObjectsCount: _objectPools.values.fold(
        0,
        (sum, pool) => sum + pool.length,
      ),
      weakReferencesCount: _weakCache.length,
      estimatedMemoryMB: _estimateMemoryUsage(),
    );

    _memorySnapshots.add(snapshot);

    // 限制快照数量
    if (_memorySnapshots.length > 100) {
      _memorySnapshots.removeRange(0, _memorySnapshots.length - 100);
    }
  }

  /// 估算内存使用量
  double _estimateMemoryUsage() {
    // 这是一个简化的估算，实际实现可能需要更复杂的计算
    var estimated = 0;

    // 对象池内存估算
    _objectPools.forEach((type, pool) {
      estimated += (pool.length * _getEstimatedObjectSize(type)).round();
    });

    // 弱引用缓存内存估算
    estimated += (_weakCache.length * 0.1).round(); // 每个弱引用约0.1KB

    return estimated / 1024; // 转换为MB
  }

  /// 获取对象估算大小（KB）
  double _getEstimatedObjectSize(Type type) {
    // 根据类型返回估算的对象大小
    final typeName = type.toString();

    if (typeName.contains('Animation')) {
      return 2; // 动画对象约2KB
    } else if (typeName.contains('Color')) {
      return 0.1; // 颜色对象约0.1KB
    } else if (typeName.contains('Text')) {
      return 1; // 文本对象约1KB
    } else {
      return 0.5; // 默认0.5KB
    }
  }

  /// 重置对象状态
  void _resetObjectState(dynamic object) {
    // 这里可以根据对象类型进行特定的重置操作
    // 例如：清空列表、重置计数器等

    if (object is List) {
      object.clear();
    } else if (object is Map) {
      object.clear();
    } else if (object is Set) {
      object.clear();
    }

    // 可以添加更多类型的重置逻辑
  }

  /// 清理对象池
  void _cleanupObjectPools() {
    _objectPools.forEach((type, pool) {
      final maxSize = _poolSizes[type] ?? _defaultPoolSize;

      // 如果池太大，移除一些对象
      while (pool.length > maxSize) {
        pool.removeLast();
      }
    });
  }

  /// 清空所有对象池
  void _clearAllPools() {
    _objectPools.clear();
    _poolSizes.clear();
  }

  /// 修剪内存快照
  void _trimMemorySnapshots() {
    // 保留最近1小时的快照
    final cutoff = DateTime.now().subtract(const Duration(hours: 1));
    _memorySnapshots.removeWhere(
      (snapshot) => snapshot.timestamp.isBefore(cutoff),
    );
  }

  /// 销毁内存优化器
  void dispose() {
    stop();
  }
}

/// 内存快照
class MemorySnapshot {
  const MemorySnapshot({
    required this.timestamp,
    required this.pooledObjectsCount,
    required this.weakReferencesCount,
    required this.estimatedMemoryMB,
  });

  final DateTime timestamp;
  final int pooledObjectsCount;
  final int weakReferencesCount;
  final double estimatedMemoryMB;
}

/// 内存统计信息
class MemoryStats {
  const MemoryStats({
    required this.pooledObjectsCount,
    required this.poolStats,
    required this.weakReferencesCount,
    required this.memorySnapshotsCount,
  });

  final int pooledObjectsCount;
  final Map<String, int> poolStats;
  final int weakReferencesCount;
  final int memorySnapshotsCount;

  @override
  String toString() {
    return 'MemoryStats('
        'pooled: $pooledObjectsCount, '
        'weakRefs: $weakReferencesCount, '
        'snapshots: $memorySnapshotsCount, '
        'pools: ${poolStats.length}'
        ')';
  }
}

/// 内存泄漏信息
class MemoryLeak {
  const MemoryLeak({
    required this.type,
    required this.description,
    required this.severity,
  });

  final MemoryLeakType type;
  final String description;
  final MemoryLeakSeverity severity;

  @override
  String toString() {
    return 'MemoryLeak(${severity.name.toUpperCase()}: $description)';
  }
}

/// 内存泄漏类型
enum MemoryLeakType {
  oversizedPool,
  excessiveWeakReferences,
  memoryGrowth,
  unusedObjects,
}

/// 内存泄漏严重程度
enum MemoryLeakSeverity { low, medium, high, critical }
