import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

/// 性能监控服务
///
/// 提供应用性能监控功能，包括FPS监控、内存使用监控、
/// 操作响应时间监控等功能
class PerformanceMonitor {
  PerformanceMonitor._();

  static final PerformanceMonitor _instance = PerformanceMonitor._();
  static PerformanceMonitor get instance => _instance;

  // FPS监控相关
  final List<double> _fpsHistory = [];
  Timer? _fpsTimer;
  int _frameCount = 0;
  DateTime? _lastFpsCheck;

  // 内存监控相关
  final List<MemoryUsage> _memoryHistory = [];
  Timer? _memoryTimer;

  // 操作性能监控
  final Map<String, List<Duration>> _operationMetrics = {};
  final Map<String, DateTime> _ongoingOperations = {};

  // 性能阈值
  static const double _targetFps = 60;
  static const double _minAcceptableFps = 45;
  static const int _maxMemoryMB = 100;
  static const Duration _maxOperationDuration = Duration(milliseconds: 200);

  // 历史数据保留时间
  static const int _maxHistoryEntries = 600; // 10分钟 * 60秒

  /// 启动性能监控
  void startMonitoring() {
    if (kDebugMode) {
      _startFpsMonitoring();
      _startMemoryMonitoring();
      developer.log(
        'Performance monitoring started',
        name: 'PerformanceMonitor',
      );
    }
  }

  /// 停止性能监控
  void stopMonitoring() {
    _fpsTimer?.cancel();
    _memoryTimer?.cancel();
    _fpsHistory.clear();
    _memoryHistory.clear();
    _operationMetrics.clear();
    _ongoingOperations.clear();

    if (kDebugMode) {
      developer.log(
        'Performance monitoring stopped',
        name: 'PerformanceMonitor',
      );
    }
  }

  /// 开始FPS监控
  void _startFpsMonitoring() {
    _lastFpsCheck = DateTime.now();
    _frameCount = 0;

    // 注册帧回调
    SchedulerBinding.instance.addPersistentFrameCallback(_onFrame);

    // 每秒计算一次FPS
    _fpsTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _calculateFps();
    });
  }

  /// 帧回调处理
  void _onFrame(Duration timestamp) {
    _frameCount++;
  }

  /// 计算FPS
  void _calculateFps() {
    final now = DateTime.now();
    if (_lastFpsCheck != null) {
      final elapsed = now.difference(_lastFpsCheck!);
      final fps = _frameCount / elapsed.inSeconds;

      _fpsHistory.add(fps);
      _trimHistory(_fpsHistory);

      // 检查FPS是否低于阈值
      if (fps < _minAcceptableFps) {
        _reportLowFps(fps);
      }
    }

    _lastFpsCheck = now;
    _frameCount = 0;
  }

  /// 开始内存监控
  void _startMemoryMonitoring() {
    _memoryTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _checkMemoryUsage();
    });
  }

  /// 检查内存使用情况
  void _checkMemoryUsage() {
    // 获取当前内存使用情况
    final memoryUsage = MemoryUsage(
      timestamp: DateTime.now(),
      usedMemoryMB: _getCurrentMemoryUsage(),
    );

    _memoryHistory.add(memoryUsage);
    _trimHistory(_memoryHistory);

    // 检查内存使用是否过高
    if (memoryUsage.usedMemoryMB > _maxMemoryMB) {
      _reportHighMemoryUsage(memoryUsage.usedMemoryMB);
    }
  }

  /// 获取当前内存使用量（MB）
  double _getCurrentMemoryUsage() {
    // 在Flutter中，我们可以通过dart:developer获取内存信息
    // 这里使用一个简化的实现
    try {
      // 这是一个模拟值，实际实现可能需要平台特定的代码
      return 50; // 返回模拟的内存使用量
    } catch (e) {
      return 0;
    }
  }

  /// 开始操作性能监控
  void startOperation(String operationName) {
    _ongoingOperations[operationName] = DateTime.now();
  }

  /// 结束操作性能监控
  void endOperation(String operationName) {
    final startTime = _ongoingOperations.remove(operationName);
    if (startTime != null) {
      final duration = DateTime.now().difference(startTime);

      _operationMetrics.putIfAbsent(operationName, () => []);
      _operationMetrics[operationName]!.add(duration);

      // 限制历史记录数量
      final metrics = _operationMetrics[operationName]!;
      if (metrics.length > _maxHistoryEntries) {
        metrics.removeRange(0, metrics.length - _maxHistoryEntries);
      }

      // 检查操作是否超时
      if (duration > _maxOperationDuration) {
        _reportSlowOperation(operationName, duration);
      }

      if (kDebugMode) {
        developer.log(
          'Operation completed: $operationName (${duration.inMilliseconds}ms)',
          name: 'PerformanceMonitor',
        );
      }
    }
  }

  /// 记录自定义性能指标
  void recordMetric(String metricName, double value) {
    if (kDebugMode) {
      developer.log(
        'Custom metric: $metricName = $value',
        name: 'PerformanceMonitor',
      );
    }
  }

  /// 获取FPS统计信息
  FpsStats getFpsStats() {
    if (_fpsHistory.isEmpty) {
      return const FpsStats(
        currentFps: 0,
        averageFps: 0,
        minFps: 0,
        maxFps: 0,
        isHealthy: true,
      );
    }

    final current = _fpsHistory.last;
    final average = _fpsHistory.reduce((a, b) => a + b) / _fpsHistory.length;
    final min = _fpsHistory.reduce((a, b) => a < b ? a : b);
    final max = _fpsHistory.reduce((a, b) => a > b ? a : b);

    return FpsStats(
      currentFps: current,
      averageFps: average,
      minFps: min,
      maxFps: max,
      isHealthy: average >= _minAcceptableFps,
    );
  }

  /// 获取内存统计信息
  MemoryStats getMemoryStats() {
    if (_memoryHistory.isEmpty) {
      return const MemoryStats(
        currentMemoryMB: 0,
        averageMemoryMB: 0,
        peakMemoryMB: 0,
        isHealthy: true,
      );
    }

    final current = _memoryHistory.last.usedMemoryMB;
    final average =
        _memoryHistory.map((m) => m.usedMemoryMB).reduce((a, b) => a + b) /
        _memoryHistory.length;
    final peak = _memoryHistory
        .map((m) => m.usedMemoryMB)
        .reduce((a, b) => a > b ? a : b);

    return MemoryStats(
      currentMemoryMB: current,
      averageMemoryMB: average,
      peakMemoryMB: peak,
      isHealthy: current <= _maxMemoryMB,
    );
  }

  /// 获取操作性能统计信息
  OperationStats getOperationStats(String operationName) {
    final metrics = _operationMetrics[operationName];
    if (metrics == null || metrics.isEmpty) {
      return OperationStats(
        operationName: operationName,
        totalCalls: 0,
        averageDuration: Duration.zero,
        minDuration: Duration.zero,
        maxDuration: Duration.zero,
        isHealthy: true,
      );
    }

    final totalMs = metrics
        .map((d) => d.inMilliseconds)
        .reduce((a, b) => a + b);
    final averageMs = totalMs / metrics.length;
    final minMs = metrics
        .map((d) => d.inMilliseconds)
        .reduce((a, b) => a < b ? a : b);
    final maxMs = metrics
        .map((d) => d.inMilliseconds)
        .reduce((a, b) => a > b ? a : b);

    return OperationStats(
      operationName: operationName,
      totalCalls: metrics.length,
      averageDuration: Duration(milliseconds: averageMs.round()),
      minDuration: Duration(milliseconds: minMs),
      maxDuration: Duration(milliseconds: maxMs),
      isHealthy:
          Duration(milliseconds: averageMs.round()) <= _maxOperationDuration,
    );
  }

  /// 获取所有性能统计信息
  PerformanceReport getPerformanceReport() {
    return PerformanceReport(
      timestamp: DateTime.now(),
      fpsStats: getFpsStats(),
      memoryStats: getMemoryStats(),
      operationStats: _operationMetrics.keys
          .map(getOperationStats)
          .toList(),
    );
  }

  /// 修剪历史数据
  void _trimHistory<T>(List<T> history) {
    if (history.length > _maxHistoryEntries) {
      history.removeRange(0, history.length - _maxHistoryEntries);
    }
  }

  /// 报告低FPS
  void _reportLowFps(double fps) {
    if (kDebugMode) {
      developer.log(
        'Low FPS detected: ${fps.toStringAsFixed(1)} (target: $_targetFps)',
        name: 'PerformanceMonitor',
        level: 900, // WARNING
      );
    }
  }

  /// 报告高内存使用
  void _reportHighMemoryUsage(double memoryMB) {
    if (kDebugMode) {
      developer.log(
        'High memory usage detected: ${memoryMB.toStringAsFixed(1)}MB (max: ${_maxMemoryMB}MB)',
        name: 'PerformanceMonitor',
        level: 900, // WARNING
      );
    }
  }

  /// 报告慢操作
  void _reportSlowOperation(String operationName, Duration duration) {
    if (kDebugMode) {
      developer.log(
        'Slow operation detected: $operationName (${duration.inMilliseconds}ms, max: ${_maxOperationDuration.inMilliseconds}ms)',
        name: 'PerformanceMonitor',
        level: 900, // WARNING
      );
    }
  }

  /// 销毁监控器
  void dispose() {
    stopMonitoring();
  }
}

/// 内存使用记录
class MemoryUsage {
  const MemoryUsage({required this.timestamp, required this.usedMemoryMB});

  final DateTime timestamp;
  final double usedMemoryMB;
}

/// FPS统计信息
class FpsStats {
  const FpsStats({
    required this.currentFps,
    required this.averageFps,
    required this.minFps,
    required this.maxFps,
    required this.isHealthy,
  });

  final double currentFps;
  final double averageFps;
  final double minFps;
  final double maxFps;
  final bool isHealthy;

  @override
  String toString() {
    return 'FpsStats(current: ${currentFps.toStringAsFixed(1)}, '
        'avg: ${averageFps.toStringAsFixed(1)}, '
        'min: ${minFps.toStringAsFixed(1)}, '
        'max: ${maxFps.toStringAsFixed(1)}, '
        'healthy: $isHealthy)';
  }
}

/// 内存统计信息
class MemoryStats {
  const MemoryStats({
    required this.currentMemoryMB,
    required this.averageMemoryMB,
    required this.peakMemoryMB,
    required this.isHealthy,
  });

  final double currentMemoryMB;
  final double averageMemoryMB;
  final double peakMemoryMB;
  final bool isHealthy;

  @override
  String toString() {
    return 'MemoryStats(current: ${currentMemoryMB.toStringAsFixed(1)}MB, '
        'avg: ${averageMemoryMB.toStringAsFixed(1)}MB, '
        'peak: ${peakMemoryMB.toStringAsFixed(1)}MB, '
        'healthy: $isHealthy)';
  }
}

/// 操作统计信息
class OperationStats {
  const OperationStats({
    required this.operationName,
    required this.totalCalls,
    required this.averageDuration,
    required this.minDuration,
    required this.maxDuration,
    required this.isHealthy,
  });

  final String operationName;
  final int totalCalls;
  final Duration averageDuration;
  final Duration minDuration;
  final Duration maxDuration;
  final bool isHealthy;

  @override
  String toString() {
    return 'OperationStats($operationName: '
        'calls: $totalCalls, '
        'avg: ${averageDuration.inMilliseconds}ms, '
        'min: ${minDuration.inMilliseconds}ms, '
        'max: ${maxDuration.inMilliseconds}ms, '
        'healthy: $isHealthy)';
  }
}

/// 性能报告
class PerformanceReport {
  const PerformanceReport({
    required this.timestamp,
    required this.fpsStats,
    required this.memoryStats,
    required this.operationStats,
  });

  final DateTime timestamp;
  final FpsStats fpsStats;
  final MemoryStats memoryStats;
  final List<OperationStats> operationStats;

  /// 整体健康状态
  bool get isHealthy {
    return fpsStats.isHealthy &&
        memoryStats.isHealthy &&
        operationStats.every((op) => op.isHealthy);
  }

  @override
  String toString() {
    return 'PerformanceReport(${timestamp.toIso8601String()}: '
        'healthy: $isHealthy, '
        'fps: $fpsStats, '
        'memory: $memoryStats, '
        'operations: ${operationStats.length})';
  }
}
