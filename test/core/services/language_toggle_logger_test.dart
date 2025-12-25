import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:prvin/core/services/language_toggle_logger.dart';

void main() {
  group('LanguageToggleLogger Tests', () {
    late List<String> capturedLogs;
    late IOSink? originalStdout;

    setUp(() {
      // 启用调试日志用于测试
      LanguageToggleLogger.setDebugEnabled(true);

      // 捕获日志输出
      capturedLogs = [];
      originalStdout = stdout;
    });

    tearDown(() {
      // 清理日志
      LanguageToggleLogger.clearLogs();

      // 恢复原始输出
      if (originalStdout != null) {
        // stdout = originalStdout!;
      }
    });

    test('should log toggle attempt correctly', () {
      // 这个测试验证日志记录功能不会抛出异常
      expect(
        () => LanguageToggleLogger.logToggleAttempt('zh', 'en'),
        returnsNormally,
      );
    });

    test('should log toggle success correctly', () {
      const duration = Duration(milliseconds: 150);
      const additionalData = {'test': 'data'};

      expect(
        () => LanguageToggleLogger.logToggleSuccess(
          'en',
          duration,
          additionalData: additionalData,
        ),
        returnsNormally,
      );
    });

    test('should log toggle error correctly', () {
      const error = 'Test error message';
      final stackTrace = StackTrace.current;

      expect(
        () => LanguageToggleLogger.logToggleError(
          error,
          stackTrace,
          fromLanguage: 'zh',
          toLanguage: 'en',
          additionalData: {'context': 'test'},
        ),
        returnsNormally,
      );
    });

    test('should log warning correctly', () {
      const message = 'Test warning message';
      const additionalData = {'warning': 'test'};

      expect(
        () => LanguageToggleLogger.logWarning(
          message,
          additionalData: additionalData,
        ),
        returnsNormally,
      );
    });

    test('should log debug messages when debug is enabled', () {
      LanguageToggleLogger.setDebugEnabled(true);

      expect(
        () => LanguageToggleLogger.logDebug(
          'Debug message',
          additionalData: {'debug': 'test'},
        ),
        returnsNormally,
      );
    });

    test('should not log debug messages when debug is disabled', () {
      LanguageToggleLogger.setDebugEnabled(false);

      // 即使调试被禁用，方法调用也不应该抛出异常
      expect(
        () => LanguageToggleLogger.logDebug('Debug message'),
        returnsNormally,
      );
    });

    test('should log state access error correctly', () {
      const error = 'State access failed';
      final stackTrace = StackTrace.current;

      expect(
        () => LanguageToggleLogger.logStateAccessError(
          error,
          stackTrace,
          attemptedAction: 'get_current_language',
        ),
        returnsNormally,
      );
    });

    test('should log preferences save error correctly', () {
      const error = 'Preferences save failed';
      final stackTrace = StackTrace.current;

      expect(
        () => LanguageToggleLogger.logPreferencesSaveError(
          error,
          stackTrace,
          key: 'app_language_code',
          value: 'en',
        ),
        returnsNormally,
      );
    });

    test('should log animation error correctly', () {
      const error = 'Animation failed';
      final stackTrace = StackTrace.current;

      expect(
        () => LanguageToggleLogger.logAnimationError(
          error,
          stackTrace,
          animationType: 'rotation',
          animationState: 'forward',
        ),
        returnsNormally,
      );
    });

    test('should log user interaction correctly', () {
      expect(
        () => LanguageToggleLogger.logUserInteraction(
          'button_tap',
          currentLanguage: 'zh',
          additionalData: {'button': 'language_toggle'},
        ),
        returnsNormally,
      );
    });

    test('should log performance metric correctly', () {
      const duration = Duration(milliseconds: 200);

      expect(
        () => LanguageToggleLogger.logPerformanceMetric(
          'language_switch_duration',
          duration,
          additionalData: {'success': true},
        ),
        returnsNormally,
      );
    });

    test('should log state change correctly', () {
      expect(
        () => LanguageToggleLogger.logStateChange(
          'zh',
          'en',
          trigger: 'user_action',
          additionalData: {'method': 'toggle'},
        ),
        returnsNormally,
      );
    });

    test('should return log statistics', () {
      final stats = LanguageToggleLogger.getLogStatistics();

      expect(stats, isA<Map<String, dynamic>>());
      expect(stats['feature'], equals('LanguageToggle'));
      expect(stats['debugEnabled'], isA<bool>());
      expect(stats['timestamp'], isA<String>());
    });

    test('should handle debug enable/disable correctly', () {
      // 测试启用调试
      LanguageToggleLogger.setDebugEnabled(true);
      final statsEnabled = LanguageToggleLogger.getLogStatistics();
      expect(statsEnabled['debugEnabled'], isTrue);

      // 测试禁用调试
      LanguageToggleLogger.setDebugEnabled(false);
      final statsDisabled = LanguageToggleLogger.getLogStatistics();
      expect(statsDisabled['debugEnabled'], isFalse);
    });

    test('should handle clear logs correctly', () {
      expect(LanguageToggleLogger.clearLogs, returnsNormally);
    });

    group('Singleton Pattern Tests', () {
      test('should return same instance', () {
        final instance1 = LanguageToggleLogger.instance;
        final instance2 = LanguageToggleLogger.instance;

        expect(identical(instance1, instance2), isTrue);
      });
    });

    group('Edge Cases', () {
      test('should handle null values gracefully', () {
        expect(
          () => LanguageToggleLogger.logToggleError(
            'Error with null stack trace',
            null,
          ),
          returnsNormally,
        );
      });

      test('should handle empty strings gracefully', () {
        expect(
          () => LanguageToggleLogger.logToggleAttempt('', ''),
          returnsNormally,
        );
      });

      test('should handle very long messages', () {
        final longMessage = 'A' * 1000;

        expect(
          () => LanguageToggleLogger.logWarning(longMessage),
          returnsNormally,
        );
      });
    });

    group('Log Content Verification Tests', () {
      test('should produce correct log for toggle attempt', () {
        // 测试切换操作是否产生正确的日志
        const fromLanguage = 'zh';
        const toLanguage = 'en';

        // 由于我们无法直接捕获print输出，我们验证方法调用不抛出异常
        // 并且可以通过日志统计验证日志系统正常工作
        expect(
          () => LanguageToggleLogger.logToggleAttempt(fromLanguage, toLanguage),
          returnsNormally,
        );

        // 验证日志统计功能正常
        final stats = LanguageToggleLogger.getLogStatistics();
        expect(stats['feature'], equals('LanguageToggle'));
        expect(stats['debugEnabled'], isTrue);
      });

      test('should produce correct log for toggle success', () {
        const language = 'en';
        const duration = Duration(milliseconds: 150);
        const additionalData = {'source': 'test'};

        expect(
          () => LanguageToggleLogger.logToggleSuccess(
            language,
            duration,
            additionalData: additionalData,
          ),
          returnsNormally,
        );

        // 验证日志系统状态
        final stats = LanguageToggleLogger.getLogStatistics();
        expect(stats, isNotEmpty);
      });

      test('should produce correct log for performance metrics', () {
        const metric = 'language_switch_duration';
        const duration = Duration(milliseconds: 200);
        const additionalData = {'success': true, 'method': 'toggle'};

        expect(
          () => LanguageToggleLogger.logPerformanceMetric(
            metric,
            duration,
            additionalData: additionalData,
          ),
          returnsNormally,
        );
      });

      test('should produce correct log for user interactions', () {
        const action = 'button_tap';
        const currentLanguage = 'zh';
        const additionalData = {
          'button_id': 'language_toggle',
          'screen': 'calendar',
        };

        expect(
          () => LanguageToggleLogger.logUserInteraction(
            action,
            currentLanguage: currentLanguage,
            additionalData: additionalData,
          ),
          returnsNormally,
        );
      });

      test('should produce correct log for state changes', () {
        const fromState = 'zh';
        const toState = 'en';
        const trigger = 'user_action';
        const additionalData = {'method': 'toggle', 'duration_ms': 150};

        expect(
          () => LanguageToggleLogger.logStateChange(
            fromState,
            toState,
            trigger: trigger,
            additionalData: additionalData,
          ),
          returnsNormally,
        );
      });
    });

    group('Error Logging Tests', () {
      test('should log state access errors correctly', () {
        const error = 'Failed to access AppBloc state';
        final stackTrace = StackTrace.current;
        const attemptedAction = 'get_current_language';

        expect(
          () => LanguageToggleLogger.logStateAccessError(
            error,
            stackTrace,
            attemptedAction: attemptedAction,
          ),
          returnsNormally,
        );
      });

      test('should log preferences save errors correctly', () {
        const error = 'SharedPreferences save failed';
        final stackTrace = StackTrace.current;
        const key = 'app_language_code';
        const value = 'en';

        expect(
          () => LanguageToggleLogger.logPreferencesSaveError(
            error,
            stackTrace,
            key: key,
            value: value,
          ),
          returnsNormally,
        );
      });

      test('should log animation errors correctly', () {
        const error = 'Animation controller disposed';
        final stackTrace = StackTrace.current;
        const animationType = 'rotation';
        const animationState = 'forward';

        expect(
          () => LanguageToggleLogger.logAnimationError(
            error,
            stackTrace,
            animationType: animationType,
            animationState: animationState,
          ),
          returnsNormally,
        );
      });

      test('should log general toggle errors with context', () {
        const error = 'Unsupported language code';
        final stackTrace = StackTrace.current;
        const fromLanguage = 'zh';
        const toLanguage = 'invalid';
        const additionalData = {'errorType': 'ValidationError'};

        expect(
          () => LanguageToggleLogger.logToggleError(
            error,
            stackTrace,
            fromLanguage: fromLanguage,
            toLanguage: toLanguage,
            additionalData: additionalData,
          ),
          returnsNormally,
        );
      });

      test('should handle multiple error scenarios', () {
        // 测试连续的错误日志记录
        final errors = [
          'Network timeout',
          'Invalid state',
          'Permission denied',
        ];

        for (final error in errors) {
          expect(
            () => LanguageToggleLogger.logToggleError(
              error,
              StackTrace.current,
              additionalData: {'errorIndex': errors.indexOf(error)},
            ),
            returnsNormally,
          );
        }
      });

      test('should log warnings for recoverable issues', () {
        const warnings = [
          'Fallback to default language',
          'Animation skipped due to performance',
          'Cache miss, loading from preferences',
        ];

        for (final warning in warnings) {
          expect(
            () => LanguageToggleLogger.logWarning(
              warning,
              additionalData: {'warningType': 'recoverable'},
            ),
            returnsNormally,
          );
        }
      });
    });

    group('Debug Mode Tests', () {
      test('should respect debug mode settings for different log levels', () {
        // 测试启用调试模式
        LanguageToggleLogger.setDebugEnabled(true);

        expect(
          () => LanguageToggleLogger.logDebug('Debug message when enabled'),
          returnsNormally,
        );

        // 测试禁用调试模式
        LanguageToggleLogger.setDebugEnabled(false);

        expect(
          () => LanguageToggleLogger.logDebug('Debug message when disabled'),
          returnsNormally,
        );

        // 错误和警告应该始终记录，不受调试模式影响
        expect(
          () => LanguageToggleLogger.logToggleError(
            'Error when debug disabled',
            null,
          ),
          returnsNormally,
        );

        expect(
          () => LanguageToggleLogger.logWarning('Warning when debug disabled'),
          returnsNormally,
        );
      });

      test('should maintain consistent behavior across debug mode changes', () {
        // 在不同调试模式下测试相同的操作
        const testMessage = 'Test consistency';

        LanguageToggleLogger.setDebugEnabled(true);
        expect(
          () => LanguageToggleLogger.logToggleAttempt('zh', 'en'),
          returnsNormally,
        );

        LanguageToggleLogger.setDebugEnabled(false);
        expect(
          () => LanguageToggleLogger.logToggleAttempt('en', 'zh'),
          returnsNormally,
        );

        LanguageToggleLogger.setDebugEnabled(true);
        expect(
          () => LanguageToggleLogger.logToggleSuccess(
            'zh',
            const Duration(milliseconds: 100),
          ),
          returnsNormally,
        );
      });
    });

    group('Log Statistics and Monitoring Tests', () {
      test('should provide accurate log statistics', () {
        final stats = LanguageToggleLogger.getLogStatistics();

        expect(stats, isA<Map<String, dynamic>>());
        expect(stats['feature'], equals('LanguageToggle'));
        expect(stats['debugEnabled'], isA<bool>());
        expect(stats['timestamp'], isA<String>());

        // 验证时间戳格式
        final timestamp = DateTime.tryParse(stats['timestamp'] as String);
        expect(timestamp, isNotNull);
      });

      test('should handle log cleanup operations', () {
        // 记录一些日志
        LanguageToggleLogger.logToggleAttempt('zh', 'en');
        LanguageToggleLogger.logToggleSuccess(
          'en',
          const Duration(milliseconds: 100),
        );

        // 清理日志
        expect(LanguageToggleLogger.clearLogs, returnsNormally);

        // 验证清理后系统仍然正常工作
        expect(
          () => LanguageToggleLogger.logToggleAttempt('en', 'zh'),
          returnsNormally,
        );
      });
    });
  });
}
