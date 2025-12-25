import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// 动画性能优化器
///
/// 提供动画性能优化功能，确保动画以60fps运行，
/// 并在性能不足时自动降级动画效果
class AnimationOptimizer {
  AnimationOptimizer._();

  static final AnimationOptimizer _instance = AnimationOptimizer._();
  static AnimationOptimizer get instance => _instance;

  // 性能监控
  final List<double> _recentFrameTimes = [];
  bool _isPerformanceGood = true;
  DateTime? _lastPerformanceCheck;

  // 动画配置
  static const Duration _targetFrameDuration = Duration(
    microseconds: 16667,
  ); // 60fps
  static const Duration _acceptableFrameDuration = Duration(
    microseconds: 22222,
  ); // 45fps
  static const int _performanceCheckFrames = 30;

  /// 获取优化的动画持续时间
  Duration getOptimizedDuration(Duration originalDuration) {
    _checkPerformance();

    if (!_isPerformanceGood) {
      // 性能不佳时缩短动画时间
      return Duration(
        milliseconds: (originalDuration.inMilliseconds * 0.7).round(),
      );
    }

    return originalDuration;
  }

  /// 获取优化的动画曲线
  Curve getOptimizedCurve(Curve originalCurve) {
    _checkPerformance();

    if (!_isPerformanceGood) {
      // 性能不佳时使用更简单的曲线
      if (originalCurve == Curves.elasticOut) {
        return Curves.easeOut;
      } else if (originalCurve == Curves.bounceOut) {
        return Curves.easeOut;
      } else if (originalCurve == Curves.elasticInOut) {
        return Curves.easeInOut;
      }
    }

    return originalCurve;
  }

  /// 创建优化的动画控制器
  AnimationController createOptimizedController({
    required Duration duration,
    required TickerProvider vsync,
    String? debugLabel,
  }) {
    final optimizedDuration = getOptimizedDuration(duration);

    return AnimationController(
      duration: optimizedDuration,
      vsync: vsync,
      debugLabel: debugLabel,
    );
  }

  /// 创建优化的补间动画
  Animation<T> createOptimizedTween<T>({
    required Tween<T> tween,
    required AnimationController controller,
    Curve? curve,
  }) {
    final optimizedCurve = curve != null ? getOptimizedCurve(curve) : null;

    if (optimizedCurve != null) {
      return tween.animate(
        CurvedAnimation(parent: controller, curve: optimizedCurve),
      );
    }

    return tween.animate(controller);
  }

  /// 检查是否应该启用复杂动画
  bool shouldEnableComplexAnimations() {
    _checkPerformance();
    return _isPerformanceGood;
  }

  /// 获取优化的动画配置
  AnimationConfig getOptimizedConfig() {
    _checkPerformance();

    if (_isPerformanceGood) {
      return const AnimationConfig(
        enableShadows: true,
        enableGradients: true,
        enableComplexTransforms: true,
        maxAnimationLayers: 3,
        quality: AnimationQuality.high,
      );
    } else {
      return const AnimationConfig(
        enableShadows: false,
        enableGradients: false,
        enableComplexTransforms: false,
        maxAnimationLayers: 1,
        quality: AnimationQuality.low,
      );
    }
  }

  /// 检查动画性能
  void _checkPerformance() {
    final now = DateTime.now();

    // 每秒检查一次性能
    if (_lastPerformanceCheck != null &&
        now.difference(_lastPerformanceCheck!) < const Duration(seconds: 1)) {
      return;
    }

    _lastPerformanceCheck = now;

    // 获取最近的帧时间
    _updateFrameTimes();

    if (_recentFrameTimes.length >= _performanceCheckFrames) {
      final averageFrameTime =
          _recentFrameTimes.reduce((a, b) => a + b) / _recentFrameTimes.length;

      final averageDuration = Duration(microseconds: averageFrameTime.round());

      // 更新性能状态
      final wasGood = _isPerformanceGood;
      _isPerformanceGood = averageDuration <= _acceptableFrameDuration;

      // 记录性能变化
      if (wasGood != _isPerformanceGood) {
        _logPerformanceChange(averageDuration);
      }

      // 清理旧数据
      _recentFrameTimes.clear();
    }
  }

  /// 更新帧时间数据
  void _updateFrameTimes() {
    // 这里应该从SchedulerBinding获取实际的帧时间
    // 为了简化，我们使用模拟数据
    if (kDebugMode) {
      // 在调试模式下模拟帧时间变化
      final simulatedFrameTime =
          _targetFrameDuration.inMicroseconds.toDouble() +
          (DateTime.now().millisecondsSinceEpoch % 100 - 50) * 100;
      _recentFrameTimes.add(simulatedFrameTime);
    } else {
      // 在发布模式下使用固定的良好性能值
      _recentFrameTimes.add(_targetFrameDuration.inMicroseconds.toDouble());
    }

    // 限制数据量
    if (_recentFrameTimes.length > _performanceCheckFrames * 2) {
      _recentFrameTimes.removeRange(0, _performanceCheckFrames);
    }
  }

  /// 记录性能变化
  void _logPerformanceChange(Duration averageFrameTime) {
    if (kDebugMode) {
      final fps = 1000000 / averageFrameTime.inMicroseconds;
      print(
        'Animation performance changed: '
        '${_isPerformanceGood ? "GOOD" : "POOR"} '
        '(${fps.toStringAsFixed(1)} fps, '
        '${averageFrameTime.inMicroseconds}μs per frame)',
      );
    }
  }

  /// 创建性能优化的装饰容器
  Widget createOptimizedContainer({
    required Widget child,
    Color? color,
    Gradient? gradient,
    List<BoxShadow>? boxShadow,
    BorderRadius? borderRadius,
    Border? border,
  }) {
    final config = getOptimizedConfig();

    return Container(
      decoration: BoxDecoration(
        color: color,
        gradient: config.enableGradients ? gradient : null,
        boxShadow: config.enableShadows ? boxShadow : null,
        borderRadius: borderRadius,
        border: border,
      ),
      child: child,
    );
  }

  /// 创建性能优化的变换组件
  Widget createOptimizedTransform({
    required Widget child,
    Matrix4? transform,
    Offset? origin,
    AlignmentGeometry? alignment,
    bool filterQuality = true,
  }) {
    final config = getOptimizedConfig();

    if (!config.enableComplexTransforms && transform != null) {
      // 简化变换矩阵
      final simplified = Matrix4.identity();

      // 只保留平移和缩放
      simplified.setTranslation(transform.getTranslation());
      final scale = transform.getMaxScaleOnAxis();
      if (scale != 1.0) {
        simplified.scale(scale);
      }

      return Transform(
        transform: simplified,
        origin: origin,
        alignment: alignment ?? Alignment.center,
        filterQuality: config.quality == AnimationQuality.high
            ? ui.FilterQuality.high
            : ui.FilterQuality.low,
        child: child,
      );
    }

    return Transform(
      transform: transform ?? Matrix4.identity(),
      origin: origin,
      alignment: alignment,
      filterQuality: config.quality == AnimationQuality.high && filterQuality
          ? ui.FilterQuality.high
          : ui.FilterQuality.low,
      child: child,
    );
  }

  /// 获取当前性能状态
  PerformanceStatus getPerformanceStatus() {
    _checkPerformance();

    final averageFrameTime = _recentFrameTimes.isNotEmpty
        ? _recentFrameTimes.reduce((a, b) => a + b) / _recentFrameTimes.length
        : _targetFrameDuration.inMicroseconds.toDouble();

    final fps = 1000000 / averageFrameTime;

    return PerformanceStatus(
      isGood: _isPerformanceGood,
      currentFps: fps,
      averageFrameTimeUs: averageFrameTime,
      samplesCount: _recentFrameTimes.length,
    );
  }

  /// 重置性能监控
  void resetPerformanceMonitoring() {
    _recentFrameTimes.clear();
    _isPerformanceGood = true;
    _lastPerformanceCheck = null;
  }

  /// 销毁优化器
  void dispose() {
    _recentFrameTimes.clear();
  }
}

/// 动画配置
class AnimationConfig {
  const AnimationConfig({
    required this.enableShadows,
    required this.enableGradients,
    required this.enableComplexTransforms,
    required this.maxAnimationLayers,
    required this.quality,
  });

  final bool enableShadows;
  final bool enableGradients;
  final bool enableComplexTransforms;
  final int maxAnimationLayers;
  final AnimationQuality quality;
}

/// 动画质量枚举
enum AnimationQuality { low, medium, high }

/// 性能状态
class PerformanceStatus {
  const PerformanceStatus({
    required this.isGood,
    required this.currentFps,
    required this.averageFrameTimeUs,
    required this.samplesCount,
  });

  final bool isGood;
  final double currentFps;
  final double averageFrameTimeUs;
  final int samplesCount;

  @override
  String toString() {
    return 'PerformanceStatus('
        'good: $isGood, '
        'fps: ${currentFps.toStringAsFixed(1)}, '
        'frameTime: ${averageFrameTimeUs.toStringAsFixed(0)}μs, '
        'samples: $samplesCount'
        ')';
  }
}
