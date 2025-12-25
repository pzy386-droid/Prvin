import 'package:prvin/core/services/language_toggle_logger.dart';

/// 状态隔离管理器
///
/// 负责确保语言切换过程中只更新语言相关的状态，
/// 其他应用状态保持完全隔离和不变
class StateIsolationManager {
  StateIsolationManager._();

  static final StateIsolationManager _instance = StateIsolationManager._();

  /// 获取单例实例
  static StateIsolationManager get instance => _instance;

  /// 语言相关的状态键
  static const Set<String> _languageRelatedKeys = {
    'language_code',
    'locale',
    'localization',
    'app_language',
    'current_language',
  };

  /// 受保护的状态键（不应在语言切换时改变）
  static const Set<String> _protectedStateKeys = {
    // 任务管理相关
    'tasks',
    'selected_date',
    'search_query',
    'filter_category',
    'filter_status',
    'task_conflicts',

    // 番茄钟相关
    'pomodoro_session',
    'timer_state',
    'session_count',
    'break_time',
    'work_time',

    // UI状态相关
    'current_page_index',
    'focused_date',
    'calendar_view',
    'selected_task',

    // 用户偏好（除语言外）
    'theme_mode',
    'notification_settings',
    'user_preferences',
  };

  /// 当前隔离会话ID
  String? _currentIsolationSessionId;

  /// 隔离会话开始时间
  DateTime? _isolationStartTime;

  /// 被隔离的状态更新记录
  final List<StateUpdateRecord> _isolatedUpdates = [];

  /// 开始状态隔离会话
  ///
  /// 在语言切换开始时调用，创建一个隔离环境
  String startIsolationSession() {
    final sessionId = 'isolation_${DateTime.now().millisecondsSinceEpoch}';
    _currentIsolationSessionId = sessionId;
    _isolationStartTime = DateTime.now();
    _isolatedUpdates.clear();

    LanguageToggleLogger.logDebug(
      'Started state isolation session',
      additionalData: {
        'session_id': sessionId,
        'start_time': _isolationStartTime!.toIso8601String(),
      },
    );

    return sessionId;
  }

  /// 验证状态更新是否被允许
  ///
  /// 在状态更新前调用，检查更新是否违反隔离规则
  StateUpdateValidation validateStateUpdate({
    required String stateKey,
    required dynamic oldValue,
    required dynamic newValue,
    required String component,
    String? sessionId,
  }) {
    // 如果没有活动的隔离会话，允许所有更新
    if (_currentIsolationSessionId == null) {
      return StateUpdateValidation.allowed();
    }

    // 验证会话ID
    if (sessionId != null && sessionId != _currentIsolationSessionId) {
      return StateUpdateValidation.denied(
        reason: 'Invalid isolation session ID',
        severity: ViolationSeverity.high,
      );
    }

    // 语言相关的状态更新总是被允许
    if (_isLanguageRelatedState(stateKey)) {
      _recordStateUpdate(
        StateUpdateRecord(
          sessionId: _currentIsolationSessionId!,
          stateKey: stateKey,
          component: component,
          oldValue: oldValue,
          newValue: newValue,
          timestamp: DateTime.now(),
          updateType: StateUpdateType.languageRelated,
          allowed: true,
        ),
      );

      return StateUpdateValidation.allowed();
    }

    // 受保护的状态更新被拒绝
    if (_isProtectedState(stateKey)) {
      final violation = StateUpdateRecord(
        sessionId: _currentIsolationSessionId!,
        stateKey: stateKey,
        component: component,
        oldValue: oldValue,
        newValue: newValue,
        timestamp: DateTime.now(),
        updateType: StateUpdateType.protected,
        allowed: false,
      );

      _recordStateUpdate(violation);

      LanguageToggleLogger.logWarning(
        'Protected state update blocked during language switch',
        additionalData: {
          'state_key': stateKey,
          'component': component,
          'session_id': _currentIsolationSessionId,
        },
      );

      return StateUpdateValidation.denied(
        reason: 'Protected state cannot be modified during language switch',
        severity: ViolationSeverity.high,
      );
    }

    // 其他状态更新需要谨慎处理
    _recordStateUpdate(
      StateUpdateRecord(
        sessionId: _currentIsolationSessionId!,
        stateKey: stateKey,
        component: component,
        oldValue: oldValue,
        newValue: newValue,
        timestamp: DateTime.now(),
        updateType: StateUpdateType.other,
        allowed: true,
      ),
    );

    return StateUpdateValidation.allowed(
      warning: 'Non-language state updated during language switch',
    );
  }

  /// 结束状态隔离会话
  ///
  /// 在语言切换完成时调用，生成隔离报告
  StateIsolationReport endIsolationSession() {
    if (_currentIsolationSessionId == null) {
      return StateIsolationReport.noSession();
    }

    final sessionId = _currentIsolationSessionId!;
    final startTime = _isolationStartTime!;
    final endTime = DateTime.now();
    final duration = endTime.difference(startTime);

    final report = StateIsolationReport(
      sessionId: sessionId,
      startTime: startTime,
      endTime: endTime,
      duration: duration,
      totalUpdates: _isolatedUpdates.length,
      languageUpdates: _isolatedUpdates
          .where((u) => u.updateType == StateUpdateType.languageRelated)
          .length,
      protectedViolations: _isolatedUpdates
          .where((u) => u.updateType == StateUpdateType.protected && !u.allowed)
          .length,
      otherUpdates: _isolatedUpdates
          .where((u) => u.updateType == StateUpdateType.other)
          .length,
      updates: List.from(_isolatedUpdates),
    );

    LanguageToggleLogger.logDebug(
      'Ended state isolation session',
      additionalData: {
        'session_id': sessionId,
        'duration_ms': duration.inMilliseconds,
        'total_updates': report.totalUpdates,
        'language_updates': report.languageUpdates,
        'protected_violations': report.protectedViolations,
        'other_updates': report.otherUpdates,
      },
    );

    // 清理会话状态
    _currentIsolationSessionId = null;
    _isolationStartTime = null;
    _isolatedUpdates.clear();

    return report;
  }

  /// 检查是否为语言相关状态
  bool _isLanguageRelatedState(String stateKey) {
    final lowerKey = stateKey.toLowerCase();
    return _languageRelatedKeys.any(lowerKey.contains);
  }

  /// 检查是否为受保护状态
  bool _isProtectedState(String stateKey) {
    final lowerKey = stateKey.toLowerCase();
    return _protectedStateKeys.any(lowerKey.contains);
  }

  /// 记录状态更新
  void _recordStateUpdate(StateUpdateRecord record) {
    _isolatedUpdates.add(record);

    // 限制记录数量，避免内存泄漏
    if (_isolatedUpdates.length > 1000) {
      _isolatedUpdates.removeRange(0, 500);
    }
  }

  /// 获取当前隔离状态
  IsolationStatus get currentStatus {
    if (_currentIsolationSessionId == null) {
      return IsolationStatus.inactive;
    }

    return IsolationStatus.active;
  }

  /// 强制结束隔离会话（用于错误恢复）
  void forceEndIsolation() {
    if (_currentIsolationSessionId != null) {
      LanguageToggleLogger.logWarning(
        'Force ending isolation session',
        additionalData: {
          'session_id': _currentIsolationSessionId,
          'updates_count': _isolatedUpdates.length,
        },
      );

      _currentIsolationSessionId = null;
      _isolationStartTime = null;
      _isolatedUpdates.clear();
    }
  }
}

/// 状态更新验证结果
class StateUpdateValidation {
  const StateUpdateValidation({
    required this.isAllowed,
    this.reason,
    this.warning,
    this.severity,
  });

  /// 创建允许的验证结果
  factory StateUpdateValidation.allowed({String? warning}) {
    return StateUpdateValidation(isAllowed: true, warning: warning);
  }

  /// 创建拒绝的验证结果
  factory StateUpdateValidation.denied({
    required String reason,
    required ViolationSeverity severity,
  }) {
    return StateUpdateValidation(
      isAllowed: false,
      reason: reason,
      severity: severity,
    );
  }

  /// 是否允许更新
  final bool isAllowed;

  /// 拒绝原因
  final String? reason;

  /// 警告信息
  final String? warning;

  /// 违规严重性
  final ViolationSeverity? severity;
}

/// 状态更新记录
class StateUpdateRecord {
  const StateUpdateRecord({
    required this.sessionId,
    required this.stateKey,
    required this.component,
    required this.oldValue,
    required this.newValue,
    required this.timestamp,
    required this.updateType,
    required this.allowed,
  });

  /// 会话ID
  final String sessionId;

  /// 状态键
  final String stateKey;

  /// 组件名称
  final String component;

  /// 旧值
  final dynamic oldValue;

  /// 新值
  final dynamic newValue;

  /// 时间戳
  final DateTime timestamp;

  /// 更新类型
  final StateUpdateType updateType;

  /// 是否被允许
  final bool allowed;

  /// 转换为映射
  Map<String, dynamic> toMap() {
    return {
      'session_id': sessionId,
      'state_key': stateKey,
      'component': component,
      'old_value': oldValue?.toString(),
      'new_value': newValue?.toString(),
      'timestamp': timestamp.toIso8601String(),
      'update_type': updateType.name,
      'allowed': allowed,
    };
  }
}

/// 状态更新类型
enum StateUpdateType {
  /// 语言相关更新
  languageRelated,

  /// 受保护状态更新
  protected,

  /// 其他更新
  other,
}

/// 状态隔离报告
class StateIsolationReport {
  const StateIsolationReport({
    required this.sessionId,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.totalUpdates,
    required this.languageUpdates,
    required this.protectedViolations,
    required this.otherUpdates,
    required this.updates,
  });

  /// 创建无会话报告
  factory StateIsolationReport.noSession() {
    final now = DateTime.now();
    return StateIsolationReport(
      sessionId: 'no_session',
      startTime: now,
      endTime: now,
      duration: Duration.zero,
      totalUpdates: 0,
      languageUpdates: 0,
      protectedViolations: 0,
      otherUpdates: 0,
      updates: [],
    );
  }

  /// 会话ID
  final String sessionId;

  /// 开始时间
  final DateTime startTime;

  /// 结束时间
  final DateTime endTime;

  /// 持续时间
  final Duration duration;

  /// 总更新数
  final int totalUpdates;

  /// 语言相关更新数
  final int languageUpdates;

  /// 受保护状态违规数
  final int protectedViolations;

  /// 其他更新数
  final int otherUpdates;

  /// 更新记录列表
  final List<StateUpdateRecord> updates;

  /// 是否有违规
  bool get hasViolations => protectedViolations > 0;

  /// 是否隔离成功
  bool get isIsolationSuccessful => protectedViolations == 0;

  /// 获取违规记录
  List<StateUpdateRecord> get violations {
    return updates
        .where((u) => u.updateType == StateUpdateType.protected && !u.allowed)
        .toList();
  }

  /// 转换为映射
  Map<String, dynamic> toMap() {
    return {
      'session_id': sessionId,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'duration_ms': duration.inMilliseconds,
      'total_updates': totalUpdates,
      'language_updates': languageUpdates,
      'protected_violations': protectedViolations,
      'other_updates': otherUpdates,
      'has_violations': hasViolations,
      'isolation_successful': isIsolationSuccessful,
    };
  }
}

/// 隔离状态
enum IsolationStatus {
  /// 未激活
  inactive,

  /// 激活中
  active,
}

/// 违规严重性（重用之前定义的枚举）
enum ViolationSeverity {
  /// 低严重性
  low,

  /// 中等严重性
  medium,

  /// 高严重性
  high,

  /// 关键严重性
  critical,
}
