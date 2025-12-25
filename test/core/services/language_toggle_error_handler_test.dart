import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prvin/core/error/language_toggle_exceptions.dart';
import 'package:prvin/core/services/language_toggle_error_handler.dart';
import 'package:prvin/core/services/language_toggle_logger.dart';

void main() {
  group('LanguageToggleErrorHandler Tests', () {
    setUp(() {
      // 启用调试日志用于测试
      LanguageToggleLogger.setDebugEnabled(true);
    });

    tearDown(LanguageToggleLogger.clearLogs);

    testWidgets('should handle StateAccessException correctly', (
      WidgetTester tester,
    ) async {
      const exception = StateAccessException('Test state access error');
      var retryCallbackCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () async {
                    await LanguageToggleErrorHandler.handleError(
                      context,
                      exception,
                      fromLanguage: 'zh',
                      toLanguage: 'en',
                      onRetry: () {
                        retryCallbackCalled = true;
                      },
                    );
                  },
                  child: const Text('Test Error'),
                );
              },
            ),
          ),
        ),
      );

      // 触发错误处理
      await tester.tap(find.text('Test Error'));
      await tester.pumpAndSettle();

      // 验证错误提示显示
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('应用状态异常，正在尝试恢复...'), findsOneWidget);
    });

    testWidgets('should handle PreferencesSaveException correctly', (
      WidgetTester tester,
    ) async {
      const exception = PreferencesSaveException('Test preferences save error');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () async {
                    await LanguageToggleErrorHandler.handleError(
                      context,
                      exception,
                      fromLanguage: 'zh',
                      toLanguage: 'en',
                    );
                  },
                  child: const Text('Test Error'),
                );
              },
            ),
          ),
        ),
      );

      // 触发错误处理
      await tester.tap(find.text('Test Error'));
      await tester.pumpAndSettle();

      // 验证错误提示显示
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('语言设置保存失败，重启应用后可能恢复到之前的语言'), findsOneWidget);
    });

    testWidgets('should handle UnsupportedLanguageException correctly', (
      WidgetTester tester,
    ) async {
      const exception = UnsupportedLanguageException('fr');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () async {
                    await LanguageToggleErrorHandler.handleError(
                      context,
                      exception,
                    );
                  },
                  child: const Text('Test Error'),
                );
              },
            ),
          ),
        ),
      );

      // 触发错误处理
      await tester.tap(find.text('Test Error'));
      await tester.pumpAndSettle();

      // 验证错误提示显示
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('不支持的语言: fr'), findsOneWidget);
    });

    testWidgets('should handle AnimationException correctly', (
      WidgetTester tester,
    ) async {
      const exception = AnimationException('Test animation error');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () async {
                    await LanguageToggleErrorHandler.handleError(
                      context,
                      exception,
                    );
                  },
                  child: const Text('Test Error'),
                );
              },
            ),
          ),
        ),
      );

      // 触发错误处理
      await tester.tap(find.text('Test Error'));
      await tester.pumpAndSettle();

      // 验证错误提示显示
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('动画效果异常，功能正常'), findsOneWidget);
    });

    testWidgets('should handle generic errors correctly', (
      WidgetTester tester,
    ) async {
      final exception = Exception('Generic test error');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () async {
                    await LanguageToggleErrorHandler.handleError(
                      context,
                      exception,
                      onRetry: () {},
                    );
                  },
                  child: const Text('Test Error'),
                );
              },
            ),
          ),
        ),
      );

      // 触发错误处理
      await tester.tap(find.text('Test Error'));
      await tester.pumpAndSettle();

      // 验证错误提示显示
      expect(find.byType(SnackBar), findsOneWidget);
      expect(
        find.text('语言切换失败: Exception: Generic test error'),
        findsOneWidget,
      );
      expect(find.text('重试'), findsOneWidget);
    });

    test('should retry operations with exponential backoff', () async {
      var attemptCount = 0;
      const maxAttempts = 3;

      try {
        await LanguageToggleErrorHandler.withRetry(() async {
          attemptCount++;
          if (attemptCount < maxAttempts) {
            throw Exception('Temporary failure');
          }
          return 'Success';
        });
      } catch (e) {
        // 不应该到达这里，因为第3次尝试应该成功
        fail('Operation should have succeeded on the third attempt');
      }

      expect(attemptCount, equals(maxAttempts));
    });

    test('should respect shouldRetry callback', () async {
      var attemptCount = 0;

      try {
        await LanguageToggleErrorHandler.withRetry(
          () async {
            attemptCount++;
            throw const StateAccessException('Persistent error');
          },
          shouldRetry: (error) => false, // 不重试
        );
      } catch (e) {
        expect(e, isA<StateAccessException>());
      }

      expect(attemptCount, equals(1)); // 只尝试一次
    });

    test('should handle timeout errors correctly', () async {
      const exception = LanguageToggleTimeoutException('Operation timed out');

      // 这里我们只测试异常的创建和属性
      expect(exception.message, equals('Operation timed out'));
      expect(exception.toString(), contains('LanguageToggleException'));
    });

    group('Error Severity Tests', () {
      test('should categorize errors by severity correctly', () {
        // 这些测试验证错误严重程度的分类逻辑
        expect(ErrorSeverity.info.index, equals(0));
        expect(ErrorSeverity.warning.index, equals(1));
        expect(ErrorSeverity.error.index, equals(2));
      });
    });

    group('Exception Hierarchy Tests', () {
      test('should create StateAccessException correctly', () {
        const exception = StateAccessException('Test message', 'Test cause');
        expect(exception.message, equals('Test message'));
        expect(exception.cause, equals('Test cause'));
        expect(exception.toString(), contains('Test message'));
        expect(exception.toString(), contains('Test cause'));
      });

      test('should create PreferencesSaveException correctly', () {
        const exception = PreferencesSaveException();
        expect(exception.message, equals('Failed to save language preference'));
        expect(exception.cause, isNull);
      });

      test('should create UnsupportedLanguageException correctly', () {
        const exception = UnsupportedLanguageException('fr');
        expect(exception.language, equals('fr'));
        expect(exception.message, equals('Unsupported language: fr'));
      });

      test('should create AnimationException correctly', () {
        const exception = AnimationException();
        expect(exception.message, equals('Animation execution failed'));
      });

      test('should create LanguageToggleTimeoutException correctly', () {
        const exception = LanguageToggleTimeoutException();
        expect(
          exception.message,
          equals('Language toggle operation timed out'),
        );
      });
    });
  });
}
