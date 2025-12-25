import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prvin/core/services/language_toggle_logger.dart';
import 'package:prvin/core/services/state_isolation_manager.dart';
import 'package:prvin/features/task_management/domain/entities/task.dart';
import 'package:prvin/features/task_management/presentation/bloc/task_bloc.dart';

/// 状态保持服务
///
/// 负责在语言切换过程中保护和验证非语言相关的应用状态
/// 确保语言切换不会影响任务数据、日期选择、番茄钟状态等
class StatePreservationService {
  StatePreservationService._();

  static final StatePreservationService _instance =
      StatePreservationService._();

  /// 获取单例实例
  static StatePreservationService get instance => _instance;

  /// 状态快照，用于验证状态完整性
  Map<String, dynamic>? _stateSnapshot;

  /// 捕获当前应用状态快照
  ///
  /// 在语言切换前调用，保存所有需要保持不变的状态
  Future<void> captureStateSnapshot(BuildContext context) async {
    try {
      LanguageToggleLogger.logDebug(
        'Capturing state snapshot before language switch',
      );

      final snapshot = <String, dynamic>{};

      // 捕获任务管理状态
      final taskBloc = context.read<TaskBloc>();
      final taskState = taskBloc.state;

      snapshot['task_management'] = {
        'selected_date': taskState.selectedDate?.toIso8601String(),
        'search_query': taskState.searchQuery,
        'filter_category': taskState.filterCategory?.toString(),
        'filter_status': taskState.filterStatus?.toString(),
        'tasks_count': taskState.tasks.length,
        'task_ids': taskState.tasks.map((Task task) => task.id).toList(),
        'status': taskState.status.toString(),
      };

      // 捕获UI状态（如果有的话）
      snapshot['ui_state'] = {'timestamp': DateTime.now().toIso8601String()};

      _stateSnapshot = snapshot;

      LanguageToggleLogger.logDebug(
        'State snapshot captured successfully',
        additionalData: {
          'snapshot_keys': snapshot.keys.toList(),
          'task_count': taskState.tasks.length,
          'selected_date': taskState.selectedDate?.toIso8601String(),
        },
      );
    } catch (e, stackTrace) {
      LanguageToggleLogger.logToggleError(
        'Failed to capture state snapshot: $e',
        stackTrace,
      );
      // 不重新抛出异常，因为这不应该阻止语言切换
    }
  }

  /// 验证状态完整性
  ///
  /// 在语言切换后调用，确保所有非语言相关的状态保持不变
  Future<StateIntegrityResult> verifyStateIntegrity(
    BuildContext context,
  ) async {
    try {
      if (_stateSnapshot == null) {
        LanguageToggleLogger.logWarning(
          'No state snapshot available for verification',
        );
        return StateIntegrityResult.noSnapshot();
      }

      LanguageToggleLogger.logDebug(
        'Verifying state integrity after language switch',
      );

      final violations = <StateViolation>[];

      // 验证任务管理状态
      await _verifyTaskManagementState(context, violations);

      // 验证其他状态（如果有的话）
      await _verifyUIState(violations);

      final result = StateIntegrityResult(
        isValid: violations.isEmpty,
        violations: violations,
        verificationTime: DateTime.now(),
      );

      if (result.isValid) {
        LanguageToggleLogger.logDebug(
          'State integrity verification passed',
          additionalData: {
            'verification_time': result.verificationTime.toIso8601String(),
          },
        );
      } else {
        LanguageToggleLogger.logWarning(
          'State integrity verification failed',
          additionalData: {
            'violations_count': violations.length,
            'violations': violations.map((v) => v.toString()).toList(),
          },
        );
      }

      return result;
    } catch (e, stackTrace) {
      LanguageToggleLogger.logToggleError(
        'State integrity verification error: $e',
        stackTrace,
      );

      return StateIntegrityResult.error(e.toString());
    }
  }

  /// 验证任务管理状态
  Future<void> _verifyTaskManagementState(
    BuildContext context,
    List<StateViolation> violations,
  ) async {
    try {
      final taskBloc = context.read<TaskBloc>();
      final currentTaskState = taskBloc.state;
      final expectedTaskState =
          _stateSnapshot!['task_management'] as Map<String, dynamic>;

      // 验证选中日期
      final expectedDateStr = expectedTaskState['selected_date'] as String?;
      final currentDateStr = currentTaskState.selectedDate?.toIso8601String();

      if (expectedDateStr != currentDateStr) {
        violations.add(
          StateViolation(
            component: 'task_management',
            field: 'selected_date',
            expected: expectedDateStr,
            actual: currentDateStr,
            severity: ViolationSeverity.medium,
          ),
        );
      }

      // 验证搜索查询
      if (expectedTaskState['search_query'] != currentTaskState.searchQuery) {
        violations.add(
          StateViolation(
            component: 'task_management',
            field: 'search_query',
            expected: expectedTaskState['search_query'],
            actual: currentTaskState.searchQuery,
            severity: ViolationSeverity.low,
          ),
        );
      }

      // 验证过滤器状态
      if (expectedTaskState['filter_category'] !=
          currentTaskState.filterCategory?.toString()) {
        violations.add(
          StateViolation(
            component: 'task_management',
            field: 'filter_category',
            expected: expectedTaskState['filter_category'],
            actual: currentTaskState.filterCategory?.toString(),
            severity: ViolationSeverity.medium,
          ),
        );
      }

      if (expectedTaskState['filter_status'] !=
          currentTaskState.filterStatus?.toString()) {
        violations.add(
          StateViolation(
            component: 'task_management',
            field: 'filter_status',
            expected: expectedTaskState['filter_status'],
            actual: currentTaskState.filterStatus?.toString(),
            severity: ViolationSeverity.medium,
          ),
        );
      }

      // 验证任务数量（应该保持不变，除非有并发操作）
      final expectedTaskCount = expectedTaskState['tasks_count'] as int;
      if (expectedTaskCount != currentTaskState.tasks.length) {
        violations.add(
          StateViolation(
            component: 'task_management',
            field: 'tasks_count',
            expected: expectedTaskCount,
            actual: currentTaskState.tasks.length,
            severity: ViolationSeverity.high,
          ),
        );
      }

      // 验证任务ID列表（任务本身不应该改变）
      final expectedTaskIds = (expectedTaskState['task_ids'] as List<dynamic>)
          .cast<String>();
      final currentTaskIds = currentTaskState.tasks
          .map((task) => task.id)
          .toList();

      if (!listEquals(expectedTaskIds, currentTaskIds)) {
        violations.add(
          StateViolation(
            component: 'task_management',
            field: 'task_ids',
            expected: expectedTaskIds,
            actual: currentTaskIds,
            severity: ViolationSeverity.high,
          ),
        );
      }
    } catch (e) {
      violations.add(
        StateViolation(
          component: 'task_management',
          field: 'verification_error',
          expected: 'successful_verification',
          actual: e.toString(),
          severity: ViolationSeverity.critical,
        ),
      );
    }
  }

  /// 验证UI状态
  Future<void> _verifyUIState(List<StateViolation> violations) async {
    // 目前UI状态验证较为简单，主要确保时间戳存在
    final expectedUIState = _stateSnapshot!['ui_state'] as Map<String, dynamic>;

    if (!expectedUIState.containsKey('timestamp')) {
      violations.add(
        const StateViolation(
          component: 'ui_state',
          field: 'timestamp',
          expected: 'valid_timestamp',
          actual: 'missing',
          severity: ViolationSeverity.low,
        ),
      );
    }
  }

  /// 清除状态快照
  void clearSnapshot() {
    _stateSnapshot = null;
    LanguageToggleLogger.logDebug('State snapshot cleared');
  }

  /// 获取状态隔离报告
  StatePreservationReport getIsolationReport() {
    return StatePreservationReport(
      hasSnapshot: _stateSnapshot != null,
      snapshotTimestamp: _stateSnapshot?['ui_state']?['timestamp'] as String?,
      protectedComponents: ['task_management', 'ui_state'],
    );
  }
}

/// 状态保持报告
class StatePreservationReport {
  const StatePreservationReport({
    required this.hasSnapshot,
    required this.protectedComponents,
    this.snapshotTimestamp,
  });

  /// 是否有状态快照
  final bool hasSnapshot;

  /// 快照时间戳
  final String? snapshotTimestamp;

  /// 受保护的组件列表
  final List<String> protectedComponents;

  /// 转换为映射
  Map<String, dynamic> toMap() {
    return {
      'has_snapshot': hasSnapshot,
      'snapshot_timestamp': snapshotTimestamp,
      'protected_components': protectedComponents,
    };
  }
}

/// 状态完整性验证结果
class StateIntegrityResult {
  const StateIntegrityResult({
    required this.isValid,
    required this.violations,
    required this.verificationTime,
    this.errorMessage,
  });

  /// 创建无快照的结果
  factory StateIntegrityResult.noSnapshot() {
    return StateIntegrityResult(
      isValid: false,
      violations: [
        const StateViolation(
          component: 'system',
          field: 'snapshot',
          expected: 'valid_snapshot',
          actual: 'no_snapshot',
          severity: ViolationSeverity.medium,
        ),
      ],
      verificationTime: DateTime.now(),
    );
  }

  /// 创建错误结果
  factory StateIntegrityResult.error(String errorMessage) {
    return StateIntegrityResult(
      isValid: false,
      violations: [
        const StateViolation(
          component: 'system',
          field: 'verification',
          expected: 'successful_verification',
          actual: 'error',
          severity: ViolationSeverity.critical,
        ),
      ],
      verificationTime: DateTime.now(),
      errorMessage: errorMessage,
    );
  }

  /// 状态是否有效
  final bool isValid;

  /// 违规列表
  final List<StateViolation> violations;

  /// 验证时间
  final DateTime verificationTime;

  /// 错误消息（如果有）
  final String? errorMessage;

  /// 获取高严重性违规
  List<StateViolation> get criticalViolations {
    return violations
        .where(
          (v) =>
              v.severity == ViolationSeverity.critical ||
              v.severity == ViolationSeverity.high,
        )
        .toList();
  }

  /// 获取违规摘要
  String get violationSummary {
    if (violations.isEmpty) return 'No violations';

    final counts = <ViolationSeverity, int>{};
    for (final violation in violations) {
      counts[violation.severity] = (counts[violation.severity] ?? 0) + 1;
    }

    return counts.entries
        .map((entry) => '${entry.key.name}: ${entry.value}')
        .join(', ');
  }
}

/// 状态违规
class StateViolation {
  const StateViolation({
    required this.component,
    required this.field,
    required this.expected,
    required this.actual,
    required this.severity,
  });

  /// 组件名称
  final String component;

  /// 字段名称
  final String field;

  /// 期望值
  final dynamic expected;

  /// 实际值
  final dynamic actual;

  /// 严重性
  final ViolationSeverity severity;

  @override
  String toString() {
    return 'StateViolation(component: $component, field: $field, '
        'expected: $expected, actual: $actual, severity: ${severity.name})';
  }
}
