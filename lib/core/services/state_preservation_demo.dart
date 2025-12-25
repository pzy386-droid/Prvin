import 'package:prvin/core/services/language_toggle_logger.dart';
import 'package:prvin/core/services/state_isolation_manager.dart';
import 'package:prvin/core/services/state_preservation_service.dart';

/// 状态保持功能演示
///
/// 展示状态隔离和保持功能如何在语言切换过程中工作
class StatePreservationDemo {
  static final StatePreservationService _preservationService =
      StatePreservationService.instance;
  static final StateIsolationManager _isolationManager =
      StateIsolationManager.instance;

  /// 演示完整的状态保持流程
  static Future<void> demonstrateStatePreservation() async {
    LanguageToggleLogger.logDebug('=== State Preservation Demo Started ===');

    try {
      // 1. 模拟应用初始状态
      _simulateInitialAppState();

      // 2. 开始状态隔离会话
      final sessionId = _isolationManager.startIsolationSession();
      LanguageToggleLogger.logDebug('Started isolation session: $sessionId');

      // 3. 模拟状态快照捕获
      await _simulateStateCapture();

      // 4. 模拟语言切换过程中的状态更新
      _simulateLanguageSwitchUpdates();

      // 5. 结束隔离会话并获取报告
      final isolationReport = _isolationManager.endIsolationSession();

      // 6. 模拟状态完整性验证
      await _simulateStateVerification();

      // 7. 输出演示结果
      _outputDemoResults(isolationReport);
    } catch (e, stackTrace) {
      LanguageToggleLogger.logToggleError(
        'State preservation demo failed: $e',
        stackTrace,
      );
    } finally {
      // 清理
      _preservationService.clearSnapshot();
      if (_isolationManager.currentStatus == IsolationStatus.active) {
        _isolationManager.forceEndIsolation();
      }

      LanguageToggleLogger.logDebug(
        '=== State Preservation Demo Completed ===',
      );
    }
  }

  /// 模拟应用初始状态
  static void _simulateInitialAppState() {
    LanguageToggleLogger.logDebug('Simulating initial app state');

    // 模拟一些初始状态数据
    final initialState = {
      'selected_date': DateTime.now().toIso8601String(),
      'search_query': 'important tasks',
      'filter_category': 'work',
      'tasks_count': 5,
      'current_language': 'zh',
    };

    LanguageToggleLogger.logDebug(
      'Initial state established',
      additionalData: initialState,
    );
  }

  /// 模拟状态快照捕获
  static Future<void> _simulateStateCapture() async {
    LanguageToggleLogger.logDebug('Simulating state snapshot capture');

    // 在实际应用中，这里会调用 captureStateSnapshot(context)
    // 这里我们模拟这个过程
    await Future.delayed(const Duration(milliseconds: 10));

    final report = _preservationService.getIsolationReport();
    LanguageToggleLogger.logDebug(
      'State snapshot captured',
      additionalData: report.toMap(),
    );
  }

  /// 模拟语言切换过程中的状态更新
  static void _simulateLanguageSwitchUpdates() {
    LanguageToggleLogger.logDebug('Simulating language switch updates');

    // 1. 允许的语言相关更新
    final languageUpdate = _isolationManager.validateStateUpdate(
      stateKey: 'language_code',
      oldValue: 'zh',
      newValue: 'en',
      component: 'app_bloc',
    );

    LanguageToggleLogger.logDebug(
      'Language update validation',
      additionalData: {
        'allowed': languageUpdate.isAllowed,
        'reason': languageUpdate.reason,
      },
    );

    // 2. 尝试更新受保护的状态（应该被阻止）
    final protectedUpdate1 = _isolationManager.validateStateUpdate(
      stateKey: 'selected_date',
      oldValue: DateTime.now(),
      newValue: DateTime.now().add(const Duration(days: 1)),
      component: 'task_bloc',
    );

    LanguageToggleLogger.logDebug(
      'Protected state update validation (selected_date)',
      additionalData: {
        'allowed': protectedUpdate1.isAllowed,
        'reason': protectedUpdate1.reason,
        'severity': protectedUpdate1.severity?.name,
      },
    );

    // 3. 尝试更新另一个受保护的状态
    final protectedUpdate2 = _isolationManager.validateStateUpdate(
      stateKey: 'search_query',
      oldValue: 'important tasks',
      newValue: 'modified query',
      component: 'task_bloc',
    );

    LanguageToggleLogger.logDebug(
      'Protected state update validation (search_query)',
      additionalData: {
        'allowed': protectedUpdate2.isAllowed,
        'reason': protectedUpdate2.reason,
        'severity': protectedUpdate2.severity?.name,
      },
    );

    // 4. 允许的其他更新
    final otherUpdate = _isolationManager.validateStateUpdate(
      stateKey: 'ui_animation_state',
      oldValue: 'idle',
      newValue: 'animating',
      component: 'ui_controller',
    );

    LanguageToggleLogger.logDebug(
      'Other state update validation',
      additionalData: {
        'allowed': otherUpdate.isAllowed,
        'warning': otherUpdate.warning,
      },
    );
  }

  /// 模拟状态完整性验证
  static Future<void> _simulateStateVerification() async {
    LanguageToggleLogger.logDebug('Simulating state integrity verification');

    // 在实际应用中，这里会调用 verifyStateIntegrity(context)
    // 这里我们模拟验证过程
    await Future.delayed(const Duration(milliseconds: 10));

    // 模拟验证结果
    final mockViolations = <StateViolation>[];

    // 如果有状态变化，会添加到违规列表中
    // 这里我们假设状态保持完好

    LanguageToggleLogger.logDebug(
      'State integrity verification completed',
      additionalData: {
        'violations_count': mockViolations.length,
        'verification_passed': mockViolations.isEmpty,
      },
    );
  }

  /// 输出演示结果
  static void _outputDemoResults(StateIsolationReport isolationReport) {
    LanguageToggleLogger.logDebug('=== Demo Results ===');

    LanguageToggleLogger.logDebug(
      'Isolation Report Summary',
      additionalData: {
        'session_id': isolationReport.sessionId,
        'duration_ms': isolationReport.duration.inMilliseconds,
        'total_updates': isolationReport.totalUpdates,
        'language_updates': isolationReport.languageUpdates,
        'protected_violations': isolationReport.protectedViolations,
        'other_updates': isolationReport.otherUpdates,
        'isolation_successful': isolationReport.isIsolationSuccessful,
      },
    );

    if (isolationReport.hasViolations) {
      LanguageToggleLogger.logWarning(
        'State isolation violations detected',
        additionalData: {
          'violations': isolationReport.violations
              .map((v) => v.toMap())
              .toList(),
        },
      );
    } else {
      LanguageToggleLogger.logDebug(
        'State isolation successful - no violations detected',
      );
    }

    // 演示结论
    final conclusion = isolationReport.isIsolationSuccessful
        ? 'State preservation working correctly! ✅'
        : 'State preservation detected violations! ⚠️';

    LanguageToggleLogger.logDebug(conclusion);
  }

  /// 运行快速演示
  static Future<void> runQuickDemo() async {
    print('\n🔄 Running State Preservation Quick Demo...\n');

    await demonstrateStatePreservation();

    print('\n✅ State Preservation Demo completed successfully!\n');
    print('Key features demonstrated:');
    print('• State isolation during language switching');
    print('• Protection of task management state');
    print('• Validation of state update attempts');
    print('• Comprehensive violation reporting');
    print('• Automatic cleanup and recovery\n');
  }
}
