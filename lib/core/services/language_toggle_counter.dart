import 'package:prvin/core/services/language_toggle_logger.dart';

/// 语言切换计数器服务
///
/// 负责跟踪语言切换操作的次数和状态，确保切换操作的幂等性
/// 提供切换计数、状态验证和一致性检查功能
class LanguageToggleCounter {
  LanguageToggleCounter._();

  static final LanguageToggleCounter _instance = LanguageToggleCounter._();

  /// 获取单例实例
  static LanguageToggleCounter get instance => _instance;

  /// 切换计数器
  int _toggleCount = 0;

  /// 初始语言状态
  String? _initialLanguage;

  /// 当前语言状态
  String? _currentLanguage;

  /// 切换会话ID（用于跟踪连续切换操作）
  String? _sessionId;

  /// 会话开始时间
  DateTime? _sessionStartTime;

  /// 获取当前切换计数
  int get toggleCount => _toggleCount;

  /// 获取初始语言
  String? get initialLanguage => _initialLanguage;

  /// 获取当前语言
  String? get currentLanguage => _currentLanguage;

  /// 获取当前会话ID
  String? get sessionId => _sessionId;

  /// 获取会话持续时间
  Duration? get sessionDuration {
    if (_sessionStartTime == null) return null;
    return DateTime.now().difference(_sessionStartTime!);
  }

  /// 是否为奇数次切换
  bool get isOddToggle => _toggleCount.isOdd;

  /// 是否为偶数次切换
  bool get isEvenToggle => _toggleCount.isEven;

  /// 开始新的切换会话
  ///
  /// [initialLanguage] 会话开始时的语言状态
  /// 返回会话ID
  String startSession(String initialLanguage) {
    _sessionId = _generateSessionId();
    _sessionStartTime = DateTime.now();
    _initialLanguage = initialLanguage;
    _currentLanguage = initialLanguage;
    _toggleCount = 0;

    LanguageToggleLogger.logDebug(
      'Started new toggle session',
      additionalData: {
        'session_id': _sessionId,
        'initial_language': initialLanguage,
        'start_time': _sessionStartTime?.toIso8601String(),
      },
    );

    return _sessionId!;
  }

  /// 记录语言切换操作
  ///
  /// [fromLanguage] 切换前的语言
  /// [toLanguage] 切换后的语言
  /// 返回切换后的计数
  int recordToggle(String fromLanguage, String toLanguage) {
    if (_sessionId == null) {
      // 如果没有活动会话，自动开始新会话
      startSession(fromLanguage);
    }

    _toggleCount++;
    _currentLanguage = toLanguage;

    LanguageToggleLogger.logDebug(
      'Recorded language toggle',
      additionalData: {
        'session_id': _sessionId,
        'toggle_count': _toggleCount,
        'from_language': fromLanguage,
        'to_language': toLanguage,
        'is_odd_toggle': isOddToggle,
        'is_even_toggle': isEvenToggle,
      },
    );

    return _toggleCount;
  }

  /// 验证切换操作的幂等性
  ///
  /// 检查奇偶次切换是否符合预期：
  /// - 偶数次切换应该回到初始语言
  /// - 奇数次切换应该切换到另一种语言
  ToggleIdempotenceResult verifyIdempotence() {
    if (_sessionId == null || _initialLanguage == null) {
      return ToggleIdempotenceResult(
        isValid: false,
        expectedLanguage: null,
        actualLanguage: _currentLanguage,
        toggleCount: _toggleCount,
        errorMessage: 'No active session or initial language not set',
      );
    }

    String expectedLanguage;
    if (isEvenToggle) {
      // 偶数次切换应该回到初始语言
      expectedLanguage = _initialLanguage!;
    } else {
      // 奇数次切换应该切换到另一种语言
      expectedLanguage = _getAlternateLanguage(_initialLanguage!);
    }

    final isValid = _currentLanguage == expectedLanguage;

    final result = ToggleIdempotenceResult(
      isValid: isValid,
      expectedLanguage: expectedLanguage,
      actualLanguage: _currentLanguage,
      toggleCount: _toggleCount,
      errorMessage: isValid
          ? null
          : 'Expected $_currentLanguage to be $expectedLanguage '
                'after $_toggleCount toggles',
    );

    LanguageToggleLogger.logDebug(
      'Verified toggle idempotence',
      additionalData: {
        'session_id': _sessionId,
        'is_valid': isValid,
        'expected_language': expectedLanguage,
        'actual_language': _currentLanguage,
        'toggle_count': _toggleCount,
        'is_odd_toggle': isOddToggle,
        'error_message': result.errorMessage,
      },
    );

    return result;
  }

  /// 获取切换统计信息
  ToggleStatistics getStatistics() {
    return ToggleStatistics(
      sessionId: _sessionId,
      initialLanguage: _initialLanguage,
      currentLanguage: _currentLanguage,
      toggleCount: _toggleCount,
      sessionDuration: sessionDuration,
      isOddToggle: isOddToggle,
      isEvenToggle: isEvenToggle,
      sessionStartTime: _sessionStartTime,
    );
  }

  /// 结束当前会话
  ToggleSessionSummary endSession() {
    final summary = ToggleSessionSummary(
      sessionId: _sessionId,
      initialLanguage: _initialLanguage,
      finalLanguage: _currentLanguage,
      totalToggles: _toggleCount,
      sessionDuration: sessionDuration,
      idempotenceResult: verifyIdempotence(),
      sessionStartTime: _sessionStartTime,
      sessionEndTime: DateTime.now(),
    );

    LanguageToggleLogger.logDebug(
      'Ended toggle session',
      additionalData: {
        'session_id': _sessionId,
        'total_toggles': _toggleCount,
        'duration_ms': sessionDuration?.inMilliseconds,
        'idempotence_valid': summary.idempotenceResult.isValid,
      },
    );

    // 重置状态
    _reset();

    return summary;
  }

  /// 强制重置计数器状态
  void reset() {
    LanguageToggleLogger.logDebug(
      'Force reset toggle counter',
      additionalData: {
        'previous_session_id': _sessionId,
        'previous_toggle_count': _toggleCount,
      },
    );

    _reset();
  }

  /// 内部重置方法
  void _reset() {
    _toggleCount = 0;
    _initialLanguage = null;
    _currentLanguage = null;
    _sessionId = null;
    _sessionStartTime = null;
  }

  /// 生成会话ID
  String _generateSessionId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = timestamp.hashCode.abs() % 10000;
    return 'toggle_session_${timestamp}_$random';
  }

  /// 获取备用语言
  String _getAlternateLanguage(String currentLanguage) {
    // 简化版本：只支持中英文切换
    switch (currentLanguage) {
      case 'zh':
        return 'en';
      case 'en':
        return 'zh';
      default:
        return 'en'; // 默认切换到英文
    }
  }
}

/// 切换幂等性验证结果
class ToggleIdempotenceResult {
  /// 创建切换幂等性验证结果实例
  const ToggleIdempotenceResult({
    required this.isValid,
    required this.expectedLanguage,
    required this.actualLanguage,
    required this.toggleCount,
    this.errorMessage,
  });

  /// 是否通过幂等性验证
  final bool isValid;

  /// 期望的语言状态
  final String? expectedLanguage;

  /// 实际的语言状态
  final String? actualLanguage;

  /// 切换次数
  final int toggleCount;

  /// 错误消息（如果验证失败）
  final String? errorMessage;

  @override
  String toString() {
    return 'ToggleIdempotenceResult('
        'isValid: $isValid, '
        'expected: $expectedLanguage, '
        'actual: $actualLanguage, '
        'count: $toggleCount'
        '${errorMessage != null ? ', error: $errorMessage' : ''}'
        ')';
  }
}

/// 切换统计信息
class ToggleStatistics {
  /// 创建切换统计信息实例
  const ToggleStatistics({
    required this.sessionId,
    required this.initialLanguage,
    required this.currentLanguage,
    required this.toggleCount,
    required this.sessionDuration,
    required this.isOddToggle,
    required this.isEvenToggle,
    required this.sessionStartTime,
  });

  /// 会话ID
  final String? sessionId;

  /// 初始语言
  final String? initialLanguage;

  /// 当前语言
  final String? currentLanguage;

  /// 切换次数
  final int toggleCount;

  /// 会话持续时间
  final Duration? sessionDuration;

  /// 是否为奇数次切换
  final bool isOddToggle;

  /// 是否为偶数次切换
  final bool isEvenToggle;

  /// 会话开始时间
  final DateTime? sessionStartTime;

  /// 转换为Map用于日志记录
  Map<String, dynamic> toMap() {
    return {
      'session_id': sessionId,
      'initial_language': initialLanguage,
      'current_language': currentLanguage,
      'toggle_count': toggleCount,
      'session_duration_ms': sessionDuration?.inMilliseconds,
      'is_odd_toggle': isOddToggle,
      'is_even_toggle': isEvenToggle,
      'session_start_time': sessionStartTime?.toIso8601String(),
    };
  }
}

/// 切换会话摘要
class ToggleSessionSummary {
  /// 创建切换会话摘要实例
  const ToggleSessionSummary({
    required this.sessionId,
    required this.initialLanguage,
    required this.finalLanguage,
    required this.totalToggles,
    required this.sessionDuration,
    required this.idempotenceResult,
    required this.sessionStartTime,
    required this.sessionEndTime,
  });

  /// 会话ID
  final String? sessionId;

  /// 初始语言
  final String? initialLanguage;

  /// 最终语言
  final String? finalLanguage;

  /// 总切换次数
  final int totalToggles;

  /// 会话持续时间
  final Duration? sessionDuration;

  /// 幂等性验证结果
  final ToggleIdempotenceResult idempotenceResult;

  /// 会话开始时间
  final DateTime? sessionStartTime;

  /// 会话结束时间
  final DateTime? sessionEndTime;

  /// 转换为Map用于日志记录
  Map<String, dynamic> toMap() {
    return {
      'session_id': sessionId,
      'initial_language': initialLanguage,
      'final_language': finalLanguage,
      'total_toggles': totalToggles,
      'session_duration_ms': sessionDuration?.inMilliseconds,
      'idempotence_valid': idempotenceResult.isValid,
      'idempotence_error': idempotenceResult.errorMessage,
      'session_start_time': sessionStartTime?.toIso8601String(),
      'session_end_time': sessionEndTime?.toIso8601String(),
    };
  }
}
