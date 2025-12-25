import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:prvin/core/services/animation_optimizer.dart';
import 'package:prvin/core/services/memory_optimizer.dart';
import 'package:prvin/core/services/performance_monitor.dart' as pm;

/// 性能优化服务
///
/// 整合动画优化器、内存优化器和性能监控器，提供统一的性能优化接口
/// 确保应用保持60fps帧率和良好的内存管理
class PerformanceOptimizationService {
  PerformanceOptimizationService._();

  static final PerformanceOptimizationService _instance =
      PerformanceOptimizationService._();

  /// 获取性能优化服务实例
  static PerformanceOptimizationService get instance => _instance;

  // 服务实例
  final _performanceMonitor = pm.PerformanceMonitor.instance;
  final _animationOptimizer = AnimationOptimizer.instance;
  final _memoryOptimizer = MemoryOptimizer.instance;

  // 优化状态
  final bool _isOptimizationEnabled = true;
  Timer? _optimizationTimer;

  // 性能阈值
  static const double _targetFps = 60;
  static const double _minAcceptableFps = 45;
  static const int _maxMemoryMB = 100;

  /// 启动性能优化服务
  void start() {
    if (!_isOptimizationEnabled) return;

    // 启动各个子服务
    _performanceMonitor.startMonitoring();
    _memoryOptimizer.start();

    // 启动定期优化检查
    _startOptimizationLoop();

    if (kDebugMode) {
      debugPrint('PerformanceOptimizationService started');
    }
  }

  /// 停止性能优化服务
  void stop() {
    _optimizationTimer?.cancel();
    _performanceMonitor.stopMonitoring();
    _memoryOptimizer.stop();

    if (kDebugMode) {
      debugPrint('PerformanceOptimizationService stopped');
    }
  }

  /// 创建优化的动画控制器
  AnimationController createOptimizedAnimationController({
    required Duration duration,
    required TickerProvider vsync,
    String? debugLabel,
  }) {
    _performanceMonitor.startOperation('animation_controller_creation');

    final controller = _animationOptimizer.createOptimizedController(
      duration: duration,
      vsync: vsync,
      debugLabel: debugLabel,
    );

    _performanceMonitor.endOperation('animation_controller_creation');
    return controller;
  }

  /// 创建优化的补间动画
  Animation<T> createOptimizedTween<T>({
    required Tween<T> tween,
    required AnimationController controller,
    Curve? curve,
  }) {
    return _animationOptimizer.createOptimizedTween<T>(
      tween: tween,
      controller: controller,
      curve: curve,
    );
  }

  /// 创建性能优化的容器
  Widget createOptimizedContainer({
    required Widget child,
    Color? color,
    Gradient? gradient,
    List<BoxShadow>? boxShadow,
    BorderRadius? borderRadius,
    Border? border,
  }) {
    return _animationOptimizer.createOptimizedContainer(
      color: color,
      gradient: gradient,
      boxShadow: boxShadow,
      borderRadius: borderRadius,
      border: border,
      child: child,
    );
  }

  /// 从对象池获取对象
  T? getFromPool<T>() {
    return _memoryOptimizer.getFromPool<T>();
  }

  /// 将对象返回到对象池
  void returnToPool<T>(T object) {
    _memoryOptimizer.returnToPool<T>(object);
  }

  /// 存储弱引用
  void storeWeakReference(String key, Object object) {
    _memoryOptimizer.storeWeakReference(key, object);
  }

  /// 获取弱引用对象
  T? getWeakReference<T>(String key) {
    return _memoryOptimizer.getWeakReference<T>(key);
  }

  /// 开始操作性能监控
  void startOperation(String operationName) {
    _performanceMonitor.startOperation(operationName);
  }

  /// 结束操作性能监控
  void endOperation(String operationName) {
    _performanceMonitor.endOperation(operationName);
  }

  /// 记录自定义性能指标
  void recordMetric(String metricName, double value) {
    _performanceMonitor.recordMetric(metricName, value);
  }

  /// 获取综合性能报告
  OptimizationReport getOptimizationReport() {
    final performanceReport = _performanceMonitor.getPerformanceReport();
    final memoryStats = _memoryOptimizer.getMemoryStats();
    final animationStatus = _animationOptimizer.getPerformanceStatus();
    final memoryLeaks = _memoryOptimizer.detectMemoryLeaks();

    return OptimizationReport(
      timestamp: DateTime.now(),
      performanceReport: performanceReport,
      memoryStats: memoryStats,
      animationStatus: animationStatus,
      memoryLeaks: memoryLeaks,
      isHealthy: _isSystemHealthy(
        performanceReport,
        memoryStats,
        animationStatus,
      ),
      recommendations: _generateRecommendations(
        performanceReport,
        memoryStats,
        animationStatus,
        memoryLeaks,
      ),
    );
  }

  /// 强制执行性能优化
  void forceOptimization() {
    _performOptimization();
  }

  /// 启动优化循环
  void _startOptimizationLoop() {
    _optimizationTimer = Timer.periodic(
      const Duration(seconds: 30), // 每30秒检查一次
      (_) => _performOptimization(),
    );
  }

  /// 执行性能优化
  void _performOptimization() {
    final report = getOptimizationReport();

    if (!report.isHealthy) {
      _applyOptimizations(report);
    }

    // 定期清理内存
    _memoryOptimizer.cleanupWeakReferences();

    if (kDebugMode) {
      debugPrint(
        'Performance optimization cycle completed: ${report.isHealthy ? "HEALTHY" : "NEEDS_ATTENTION"}',
      );
    }
  }

  /// 应用优化措施
  void _applyOptimizations(OptimizationReport report) {
    // 如果FPS过低，重置动画优化器
    if (report.performanceReport.fpsStats.currentFps < _minAcceptableFps) {
      _animationOptimizer.resetPerformanceMonitoring();
    }

    // 如果内存使用过高，强制垃圾回收
    if (report.memoryStats.pooledObjectsCount > 500) {
      _memoryOptimizer.forceGarbageCollection();
    }

    // 处理内存泄漏
    if (report.memoryLeaks.isNotEmpty) {
      for (final leak in report.memoryLeaks) {
        if (kDebugMode) {
          debugPrint('Memory leak detected: ${leak.description}');
        }
      }
    }
  }

  /// 检查系统健康状态
  bool _isSystemHealthy(
    pm.PerformanceReport performanceReport,
    MemoryStats memoryStats,
    PerformanceStatus animationStatus,
  ) {
    return performanceReport.isHealthy &&
        memoryStats.pooledObjectsCount < 1000 &&
        animationStatus.isGood;
  }

  /// 生成优化建议
  List<String> _generateRecommendations(
    pm.PerformanceReport performanceReport,
    MemoryStats memoryStats,
    PerformanceStatus animationStatus,
    List<MemoryLeak> memoryLeaks,
  ) {
    final recommendations = <String>[];

    // FPS相关建议
    if (performanceReport.fpsStats.currentFps < _minAcceptableFps) {
      recommendations.add('当前FPS过低，建议减少复杂动画或降低动画质量');
    }

    // 内存相关建议
    if (memoryStats.pooledObjectsCount > 500) {
      recommendations.add('对象池中对象过多，建议清理未使用的对象');
    }

    if (memoryStats.weakReferencesCount > 100) {
      recommendations.add('弱引用缓存过大，建议清理无效引用');
    }

    // 动画相关建议
    if (!animationStatus.isGood) {
      recommendations.add('动画性能不佳，已自动降级动画效果');
    }

    // 内存泄漏建议
    if (memoryLeaks.isNotEmpty) {
      recommendations.add('检测到${memoryLeaks.length}个潜在内存泄漏，建议检查代码');
    }

    // 操作性能建议
    for (final opStats in performanceReport.operationStats) {
      if (!opStats.isHealthy) {
        recommendations.add('操作"${opStats.operationName}"响应时间过长，建议优化');
      }
    }

    return recommendations;
  }

  /// 销毁服务
  void dispose() {
    stop();
    _animationOptimizer.dispose();
    _memoryOptimizer.dispose();
    _performanceMonitor.dispose();
  }
}

/// 优化报告
class OptimizationReport {
  const OptimizationReport({
    required this.timestamp,
    required this.performanceReport,
    required this.memoryStats,
    required this.animationStatus,
    required this.memoryLeaks,
    required this.isHealthy,
    required this.recommendations,
  });

  final DateTime timestamp;
  final pm.PerformanceReport performanceReport;
  final MemoryStats memoryStats;
  final PerformanceStatus animationStatus;
  final List<MemoryLeak> memoryLeaks;
  final bool isHealthy;
  final List<String> recommendations;

  @override
  String toString() {
    return 'OptimizationReport('
        'timestamp: ${timestamp.toIso8601String()}, '
        'healthy: $isHealthy, '
        'recommendations: ${recommendations.length}'
        ')';
  }
}
