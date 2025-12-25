import 'dart:async';

import 'package:flutter/material.dart';
import 'package:prvin/core/services/language_toggle_logger.dart';

/// 动画状态管理器
///
/// 负责管理动画的状态一致性，包括动画中断和恢复机制
class AnimationStateManager {
  AnimationStateManager._();

  static final AnimationStateManager _instance = AnimationStateManager._();

  /// 获取单例实例
  static AnimationStateManager get instance => _instance;

  // 动画状态跟踪
  final Map<String, AnimationState> _animationStates = {};
  final Map<String, AnimationController> _controllers = {};
  final Map<String, Completer<void>> _animationCompleters = {};
  final Map<String, Timer> _timeoutTimers = {};

  // 动画配置
  static const Duration _animationTimeout = Duration(seconds: 2);
  static const Duration _recoveryDelay = Duration(milliseconds: 100);

  /// 注册动画控制器
  void registerController(
    String animationId,
    AnimationController controller, {
    Duration? timeout,
  }) {
    _controllers[animationId] = controller;
    _animationStates[animationId] = AnimationState.idle;

    // 监听动画状态变化
    controller.addStatusListener((status) {
      _handleAnimationStatusChange(animationId, status);
    });

    LanguageToggleLogger.logDebug(
      'Animation controller registered',
      additionalData: {
        'animation_id': animationId,
        'timeout_ms': (timeout ?? _animationTimeout).inMilliseconds,
      },
    );
  }

  /// 注销动画控制器
  void unregisterController(String animationId) {
    _controllers.remove(animationId);
    _animationStates.remove(animationId);
    _animationCompleters.remove(animationId);
    _timeoutTimers[animationId]?.cancel();
    _timeoutTimers.remove(animationId);

    LanguageToggleLogger.logDebug(
      'Animation controller unregistered',
      additionalData: {'animation_id': animationId},
    );
  }

  /// 开始动画并返回完成Future
  Future<AnimationResult> startAnimation(
    String animationId, {
    Duration? timeout,
    bool allowInterruption = true,
  }) async {
    final controller = _controllers[animationId];
    if (controller == null) {
      throw AnimationException('Animation controller not found: $animationId');
    }

    // 检查当前状态
    final currentState = _animationStates[animationId];
    if (currentState == AnimationState.running && !allowInterruption) {
      throw AnimationException(
        'Animation $animationId is already running and interruption is not allowed',
      );
    }

    // 如果动画正在运行，先中断它
    if (currentState == AnimationState.running) {
      await _interruptAnimation(animationId);
    }

    try {
      // 设置状态为运行中
      _animationStates[animationId] = AnimationState.running;

      // 创建完成器
      final completer = Completer<void>();
      _animationCompleters[animationId] = completer;

      // 设置超时定时器
      final timeoutDuration = timeout ?? _animationTimeout;
      _timeoutTimers[animationId] = Timer(timeoutDuration, () {
        _handleAnimationTimeout(animationId);
      });

      LanguageToggleLogger.logDebug(
        'Starting animation',
        additionalData: {
          'animation_id': animationId,
          'current_value': controller.value,
          'status': controller.status.toString(),
          'timeout_ms': timeoutDuration.inMilliseconds,
        },
      );

      // 启动动画
      await controller.forward();

      // 等待动画完成或超时
      await completer.future;

      // 验证最终状态
      final finalState = await _verifyAnimationCompletion(animationId);

      LanguageToggleLogger.logDebug(
        'Animation completed successfully',
        additionalData: {
          'animation_id': animationId,
          'final_value': controller.value,
          'final_status': controller.status.toString(),
          'state_consistent': finalState.isConsistent,
        },
      );

      return AnimationResult.success(
        animationId: animationId,
        finalValue: controller.value,
        isConsistent: finalState.isConsistent,
      );
    } catch (e) {
      LanguageToggleLogger.logAnimationError(
        'Animation failed: $e',
        StackTrace.current,
        animationType: animationId,
        animationState: controller.status.toString(),
      );

      // 尝试恢复到稳定状态
      await _recoverAnimation(animationId);

      return AnimationResult.failure(
        animationId: animationId,
        error: e.toString(),
        finalValue: controller.value,
      );
    } finally {
      // 清理资源
      _cleanupAnimation(animationId);
    }
  }

  /// 中断动画
  Future<void> _interruptAnimation(String animationId) async {
    final controller = _controllers[animationId];
    if (controller == null) return;

    LanguageToggleLogger.logDebug(
      'Interrupting animation',
      additionalData: {
        'animation_id': animationId,
        'current_value': controller.value,
        'status': controller.status.toString(),
      },
    );

    try {
      // 设置状态为中断
      _animationStates[animationId] = AnimationState.interrupted;

      // 停止动画
      controller.stop();

      // 等待一小段时间确保动画完全停止
      await Future<void>.delayed(_recoveryDelay);

      // 完成之前的completer
      final completer = _animationCompleters[animationId];
      if (completer != null && !completer.isCompleted) {
        completer.complete();
      }
    } catch (e) {
      LanguageToggleLogger.logWarning(
        'Failed to interrupt animation: $e',
        additionalData: {'animation_id': animationId},
      );
    }
  }

  /// 处理动画超时
  void _handleAnimationTimeout(String animationId) {
    LanguageToggleLogger.logWarning(
      'Animation timeout',
      additionalData: {
        'animation_id': animationId,
        'timeout_ms': _animationTimeout.inMilliseconds,
      },
    );

    _animationStates[animationId] = AnimationState.timeout;

    // 完成completer以避免无限等待
    final completer = _animationCompleters[animationId];
    if (completer != null && !completer.isCompleted) {
      completer.completeError(
        AnimationTimeoutException('Animation $animationId timed out'),
      );
    }
  }

  /// 处理动画状态变化
  void _handleAnimationStatusChange(
    String animationId,
    AnimationStatus status,
  ) {
    LanguageToggleLogger.logDebug(
      'Animation status changed',
      additionalData: {
        'animation_id': animationId,
        'status': status.toString(),
      },
    );

    switch (status) {
      case AnimationStatus.completed:
        _animationStates[animationId] = AnimationState.completed;
        _completeAnimation(animationId);
      case AnimationStatus.dismissed:
        _animationStates[animationId] = AnimationState.dismissed;
        _completeAnimation(animationId);
      case AnimationStatus.forward:
        _animationStates[animationId] = AnimationState.running;
      case AnimationStatus.reverse:
        _animationStates[animationId] = AnimationState.running;
    }
  }

  /// 完成动画
  void _completeAnimation(String animationId) {
    final completer = _animationCompleters[animationId];
    if (completer != null && !completer.isCompleted) {
      completer.complete();
    }

    // 取消超时定时器
    _timeoutTimers[animationId]?.cancel();
  }

  /// 验证动画完成状态
  Future<AnimationConsistencyResult> _verifyAnimationCompletion(
    String animationId,
  ) async {
    final controller = _controllers[animationId];
    if (controller == null) {
      return const AnimationConsistencyResult(
        isConsistent: false,
        issues: ['Controller not found'],
      );
    }

    final issues = <String>[];

    // 检查动画值是否在预期范围内
    if (controller.value < 0.0 || controller.value > 1.0) {
      issues.add('Animation value out of range: ${controller.value}');
    }

    // 检查动画状态是否稳定
    final currentState = _animationStates[animationId];
    if (currentState != AnimationState.completed &&
        currentState != AnimationState.dismissed) {
      issues.add('Animation not in stable state: $currentState');
    }

    // 检查控制器状态
    if (controller.status != AnimationStatus.completed &&
        controller.status != AnimationStatus.dismissed) {
      issues.add('Controller not in stable status: ${controller.status}');
    }

    return AnimationConsistencyResult(
      isConsistent: issues.isEmpty,
      issues: issues,
    );
  }

  /// 恢复动画到稳定状态
  Future<void> _recoverAnimation(String animationId) async {
    final controller = _controllers[animationId];
    if (controller == null) return;

    try {
      LanguageToggleLogger.logDebug(
        'Recovering animation to stable state',
        additionalData: {
          'animation_id': animationId,
          'current_value': controller.value,
          'status': controller.status.toString(),
        },
      );

      // 设置状态为恢复中
      _animationStates[animationId] = AnimationState.recovering;

      // 根据当前值决定恢复方向
      if (controller.value > 0.5) {
        // 接近完成，恢复到完成状态
        controller.value = 1.0;
        _animationStates[animationId] = AnimationState.completed;
      } else {
        // 接近开始，恢复到初始状态
        controller.value = 0.0;
        _animationStates[animationId] = AnimationState.dismissed;
      }

      // 等待状态稳定
      await Future<void>.delayed(_recoveryDelay);

      LanguageToggleLogger.logDebug(
        'Animation recovery completed',
        additionalData: {
          'animation_id': animationId,
          'recovered_value': controller.value,
          'recovered_state': _animationStates[animationId].toString(),
        },
      );
    } catch (e) {
      LanguageToggleLogger.logAnimationError(
        'Animation recovery failed: $e',
        StackTrace.current,
        animationType: animationId,
        animationState: controller.status.toString(),
      );

      // 强制重置到初始状态
      try {
        controller.reset();
        _animationStates[animationId] = AnimationState.idle;
      } catch (resetError) {
        LanguageToggleLogger.logWarning(
          'Failed to reset animation controller: $resetError',
          additionalData: {'animation_id': animationId},
        );
      }
    }
  }

  /// 清理动画资源
  void _cleanupAnimation(String animationId) {
    _animationCompleters.remove(animationId);
    _timeoutTimers[animationId]?.cancel();
    _timeoutTimers.remove(animationId);

    // 如果动画不在稳定状态，设置为空闲
    final currentState = _animationStates[animationId];
    if (currentState != AnimationState.completed &&
        currentState != AnimationState.dismissed) {
      _animationStates[animationId] = AnimationState.idle;
    }
  }

  /// 获取动画状态
  AnimationState? getAnimationState(String animationId) {
    return _animationStates[animationId];
  }

  /// 检查动画是否正在运行
  bool isAnimationRunning(String animationId) {
    return _animationStates[animationId] == AnimationState.running;
  }

  /// 检查所有动画是否都处于稳定状态
  bool areAllAnimationsStable() {
    return _animationStates.values.every(
      (state) =>
          state == AnimationState.idle ||
          state == AnimationState.completed ||
          state == AnimationState.dismissed,
    );
  }

  /// 获取动画状态报告
  AnimationStateReport getStateReport() {
    final runningAnimations = <String>[];
    final stableAnimations = <String>[];
    final problematicAnimations = <String>[];

    for (final entry in _animationStates.entries) {
      final animationId = entry.key;
      final state = entry.value;

      switch (state) {
        case AnimationState.running:
          runningAnimations.add(animationId);
        case AnimationState.idle:
        case AnimationState.completed:
        case AnimationState.dismissed:
          stableAnimations.add(animationId);
        case AnimationState.interrupted:
        case AnimationState.timeout:
        case AnimationState.error:
          problematicAnimations.add(animationId);
        case AnimationState.recovering:
          // 恢复中的动画单独处理
          break;
      }
    }

    return AnimationStateReport(
      totalAnimations: _animationStates.length,
      runningAnimations: runningAnimations,
      stableAnimations: stableAnimations,
      problematicAnimations: problematicAnimations,
      allStable: areAllAnimationsStable(),
    );
  }

  /// 强制停止所有动画
  Future<void> stopAllAnimations() async {
    final runningAnimations = _animationStates.entries
        .where((entry) => entry.value == AnimationState.running)
        .map((entry) => entry.key)
        .toList();

    for (final animationId in runningAnimations) {
      await _interruptAnimation(animationId);
    }

    LanguageToggleLogger.logDebug(
      'All animations stopped',
      additionalData: {
        'stopped_count': runningAnimations.length,
        'animation_ids': runningAnimations,
      },
    );
  }

  /// 销毁管理器
  void dispose() {
    // 停止所有动画
    for (final controller in _controllers.values) {
      try {
        controller.stop();
      } catch (e) {
        // 忽略停止错误
      }
    }

    // 取消所有定时器
    for (final timer in _timeoutTimers.values) {
      timer.cancel();
    }

    // 完成所有未完成的completer
    for (final completer in _animationCompleters.values) {
      if (!completer.isCompleted) {
        completer.completeError(
          const AnimationException('Animation manager disposed'),
        );
      }
    }

    // 清理所有数据
    _animationStates.clear();
    _controllers.clear();
    _animationCompleters.clear();
    _timeoutTimers.clear();

    LanguageToggleLogger.logDebug('Animation state manager disposed');
  }
}

/// 动画状态枚举
enum AnimationState {
  /// 空闲状态
  idle,

  /// 运行中
  running,

  /// 已完成
  completed,

  /// 已取消
  dismissed,

  /// 被中断
  interrupted,

  /// 超时
  timeout,

  /// 错误状态
  error,

  /// 恢复中
  recovering,
}

/// 动画结果
class AnimationResult {
  const AnimationResult._({
    required this.animationId,
    required this.isSuccess,
    required this.finalValue,
    required this.isConsistent,
    this.error,
  });

  /// 成功结果
  factory AnimationResult.success({
    required String animationId,
    required double finalValue,
    required bool isConsistent,
  }) {
    return AnimationResult._(
      animationId: animationId,
      isSuccess: true,
      finalValue: finalValue,
      isConsistent: isConsistent,
    );
  }

  /// 失败结果
  factory AnimationResult.failure({
    required String animationId,
    required String error,
    required double finalValue,
  }) {
    return AnimationResult._(
      animationId: animationId,
      isSuccess: false,
      finalValue: finalValue,
      isConsistent: false,
      error: error,
    );
  }

  /// 动画ID
  final String animationId;

  /// 是否成功
  final bool isSuccess;

  /// 最终值
  final double finalValue;

  /// 状态是否一致
  final bool isConsistent;

  /// 错误信息
  final String? error;
}

/// 动画一致性检查结果
class AnimationConsistencyResult {
  const AnimationConsistencyResult({
    required this.isConsistent,
    required this.issues,
  });

  /// 是否一致
  final bool isConsistent;

  /// 问题列表
  final List<String> issues;
}

/// 动画状态报告
class AnimationStateReport {
  const AnimationStateReport({
    required this.totalAnimations,
    required this.runningAnimations,
    required this.stableAnimations,
    required this.problematicAnimations,
    required this.allStable,
  });

  /// 总动画数
  final int totalAnimations;

  /// 运行中的动画
  final List<String> runningAnimations;

  /// 稳定的动画
  final List<String> stableAnimations;

  /// 有问题的动画
  final List<String> problematicAnimations;

  /// 是否全部稳定
  final bool allStable;

  /// 转换为Map
  Map<String, dynamic> toMap() {
    return {
      'total_animations': totalAnimations,
      'running_animations': runningAnimations,
      'stable_animations': stableAnimations,
      'problematic_animations': problematicAnimations,
      'all_stable': allStable,
    };
  }
}

/// 动画异常
class AnimationException implements Exception {
  const AnimationException(this.message, [this.cause]);

  /// 错误消息
  final String message;

  /// 原因
  final Object? cause;

  @override
  String toString() {
    if (cause != null) {
      return 'AnimationException: $message (caused by: $cause)';
    }
    return 'AnimationException: $message';
  }
}

/// 动画超时异常
class AnimationTimeoutException extends AnimationException {
  const AnimationTimeoutException(super.message);
}
