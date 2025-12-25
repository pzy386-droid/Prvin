import 'dart:developer' as developer;

/// 语言切换日志记录器
///
/// 提供专门针对语言切换功能的日志记录服务
/// 支持不同级别的日志记录和结构化日志输出
class LanguageToggleLogger {
  // 私有构造函数，确保单例模式
  LanguageToggleLogger._();

  /// 单例实例
  static final LanguageToggleLogger _instance = LanguageToggleLogger._();

  /// 获取单例实例
  static LanguageToggleLogger get instance => _instance;

  /// 日志标签
  static const String _tag = 'LanguageToggle';

  /// 是否启用调试日志
  static bool _debugEnabled = true;

  /// 设置调试日志开关
  static void setDebugEnabled(bool enabled) {
    _debugEnabled = enabled;
  }

  /// 记录语言切换尝试
  static void logToggleAttempt(String fromLanguage, String toLanguage) {
    final message = 'Language toggle attempt: $fromLanguage -> $toLanguage';
    _log('INFO', message);

    if (_debugEnabled) {
      developer.log(
        message,
        name: _tag,
        level: 800, // INFO level
      );
    }
  }

  /// 记录语言切换成功
  static void logToggleSuccess(
    String language,
    Duration duration, {
    Map<String, dynamic>? additionalData,
  }) {
    final message =
        'Language toggle successful: $language '
        '(${duration.inMilliseconds}ms)';
    _log('INFO', message, additionalData);

    if (_debugEnabled) {
      developer.log(
        message,
        name: _tag,
        level: 800, // INFO level
        time: DateTime.now(),
      );
    }
  }

  /// 记录语言切换错误
  static void logToggleError(
    String error,
    StackTrace? stackTrace, {
    String? fromLanguage,
    String? toLanguage,
    Map<String, dynamic>? additionalData,
  }) {
    final context = <String, dynamic>{
      if (fromLanguage != null) 'fromLanguage': fromLanguage,
      if (toLanguage != null) 'toLanguage': toLanguage,
      if (additionalData != null) ...additionalData,
    };

    final message = 'Language toggle failed: $error';
    _log('ERROR', message, context);

    if (_debugEnabled) {
      developer.log(
        message,
        name: _tag,
        level: 1000, // SEVERE level
        error: error,
        stackTrace: stackTrace,
        time: DateTime.now(),
      );
    }
  }

  /// 记录警告信息
  static void logWarning(
    String message, {
    Map<String, dynamic>? additionalData,
  }) {
    _log('WARNING', message, additionalData);

    if (_debugEnabled) {
      developer.log(
        message,
        name: _tag,
        level: 900, // WARNING level
        time: DateTime.now(),
      );
    }
  }

  /// 记录调试信息
  static void logDebug(String message, {Map<String, dynamic>? additionalData}) {
    if (!_debugEnabled) return;

    _log('DEBUG', message, additionalData);

    developer.log(
      message,
      name: _tag,
      level: 500, // FINE level
      time: DateTime.now(),
    );
  }

  /// 记录状态访问错误
  static void logStateAccessError(
    String error,
    StackTrace? stackTrace, {
    String? attemptedAction,
  }) {
    final context = <String, dynamic>{
      'errorType': 'StateAccessError',
      if (attemptedAction != null) 'attemptedAction': attemptedAction,
    };

    logToggleError(error, stackTrace, additionalData: context);
  }

  /// 记录SharedPreferences保存错误
  static void logPreferencesSaveError(
    String error,
    StackTrace? stackTrace, {
    String? key,
    dynamic value,
  }) {
    final context = <String, dynamic>{
      'errorType': 'PreferencesSaveError',
      if (key != null) 'key': key,
      if (value != null) 'value': value.toString(),
    };

    logToggleError(error, stackTrace, additionalData: context);
  }

  /// 记录动画错误
  static void logAnimationError(
    String error,
    StackTrace? stackTrace, {
    String? animationType,
    String? animationState,
  }) {
    final context = <String, dynamic>{
      'errorType': 'AnimationError',
      if (animationType != null) 'animationType': animationType,
      if (animationState != null) 'animationState': animationState,
    };

    logToggleError(error, stackTrace, additionalData: context);
  }

  /// 记录用户交互
  static void logUserInteraction(
    String action, {
    String? currentLanguage,
    Map<String, dynamic>? additionalData,
  }) {
    final context = <String, dynamic>{
      'interactionType': 'UserAction',
      'action': action,
      if (currentLanguage != null) 'currentLanguage': currentLanguage,
      if (additionalData != null) ...additionalData,
    };

    final message = 'User interaction: $action';
    _log('INFO', message, context);

    if (_debugEnabled) {
      developer.log(
        message,
        name: _tag,
        level: 800, // INFO level
        time: DateTime.now(),
      );
    }
  }

  /// 记录性能指标
  static void logPerformanceMetric(
    String metric,
    Duration duration, {
    Map<String, dynamic>? additionalData,
  }) {
    final context = <String, dynamic>{
      'metricType': 'Performance',
      'metric': metric,
      'durationMs': duration.inMilliseconds,
      if (additionalData != null) ...additionalData,
    };

    final message =
        'Performance metric: $metric (${duration.inMilliseconds}ms)';
    _log('INFO', message, context);

    if (_debugEnabled) {
      developer.log(
        message,
        name: _tag,
        level: 800, // INFO level
        time: DateTime.now(),
      );
    }
  }

  /// 记录状态变化
  static void logStateChange(
    String fromState,
    String toState, {
    String? trigger,
    Map<String, dynamic>? additionalData,
  }) {
    final context = <String, dynamic>{
      'changeType': 'StateChange',
      'fromState': fromState,
      'toState': toState,
      if (trigger != null) 'trigger': trigger,
      if (additionalData != null) ...additionalData,
    };

    final message = 'State change: $fromState -> $toState';
    _log('INFO', message, context);

    if (_debugEnabled) {
      developer.log(
        message,
        name: _tag,
        level: 800, // INFO level
        time: DateTime.now(),
      );
    }
  }

  /// 内部日志记录方法
  static void _log(
    String level,
    String message, [
    Map<String, dynamic>? context,
  ]) {
    final timestamp = DateTime.now().toIso8601String();
    final logEntry = <String, dynamic>{
      'timestamp': timestamp,
      'level': level,
      'tag': _tag,
      'message': message,
      if (context != null) 'context': context,
    };

    // 在调试模式下打印到控制台
    if (_debugEnabled) {
      final contextStr = context != null ? ' | Context: $context' : '';
      print('[$timestamp] [$_tag] [$level] $message$contextStr');
    }

    // 这里可以添加其他日志输出目标，如文件、远程服务等
    // _writeToFile(logEntry);
    // _sendToRemoteService(logEntry);
  }

  /// 获取日志统计信息
  static Map<String, dynamic> getLogStatistics() {
    // 这里可以实现日志统计功能
    // 例如：错误次数、成功次数、平均响应时间等
    return {
      'feature': 'LanguageToggle',
      'debugEnabled': _debugEnabled,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// 清理日志（如果需要）
  static void clearLogs() {
    // 这里可以实现日志清理功能
    logDebug('Log cleanup requested');
  }
}
