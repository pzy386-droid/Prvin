import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prvin/core/bloc/app_bloc.dart';
import 'package:prvin/core/services/language_toggle_counter.dart';
import 'package:prvin/core/widgets/one_click_language_toggle_button.dart';

/// 集成测试：验证一键语言切换按钮与切换计数器的集成
void main() {
  group('Toggle Idempotence Integration Tests', () {
    late AppBloc appBloc;
    late LanguageToggleCounter counter;

    setUp(() {
      appBloc = AppBloc();
      counter = LanguageToggleCounter.instance;
      counter.reset(); // 确保每个测试开始时状态干净
    });

    tearDown(() {
      counter.reset(); // 清理测试后的状态
      appBloc.close();
    });

    testWidgets(
      'should integrate toggle counter with button widget correctly',
      (WidgetTester tester) async {
        // 设置初始状态
        appBloc.emit(const AppReadyState());

        // 创建测试widget
        Widget createTestWidget() {
          return MaterialApp(
            home: BlocProvider<AppBloc>.value(
              value: appBloc,
              child: const Scaffold(body: OneClickLanguageToggleButton()),
            ),
          );
        }

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // 验证初始状态
        expect(counter.toggleCount, equals(0));
        expect(counter.sessionId, isNull);

        // 验证静态方法可以访问计数器状态
        expect(OneClickLanguageToggleButton.getToggleCount(), equals(0));

        final initialStats = OneClickLanguageToggleButton.getToggleStatistics();
        expect(initialStats.toggleCount, equals(0));
        expect(initialStats.sessionId, isNull);
      },
    );

    testWidgets('should verify idempotence through static methods', (
      WidgetTester tester,
    ) async {
      // 手动设置切换会话来测试静态方法
      counter.startSession('zh');
      counter.recordToggle('zh', 'en');

      // 验证静态方法返回正确的幂等性结果
      final idempotenceResult =
          OneClickLanguageToggleButton.verifyToggleIdempotence();
      expect(idempotenceResult.isValid, isTrue);
      expect(idempotenceResult.toggleCount, equals(1));
      expect(idempotenceResult.expectedLanguage, equals('en'));
      expect(idempotenceResult.actualLanguage, equals('en'));

      // 测试偶数次切换
      counter.recordToggle('en', 'zh');
      final evenToggleResult =
          OneClickLanguageToggleButton.verifyToggleIdempotence();
      expect(evenToggleResult.isValid, isTrue);
      expect(evenToggleResult.toggleCount, equals(2));
      expect(evenToggleResult.expectedLanguage, equals('zh'));
      expect(evenToggleResult.actualLanguage, equals('zh'));
    });

    testWidgets('should end session through static method correctly', (
      WidgetTester tester,
    ) async {
      // 设置切换会话
      counter.startSession('zh');
      counter.recordToggle('zh', 'en');
      counter.recordToggle('en', 'zh');

      // 通过静态方法结束会话
      final summary = OneClickLanguageToggleButton.endToggleSession();

      expect(summary.sessionId, isNotNull);
      expect(summary.initialLanguage, equals('zh'));
      expect(summary.finalLanguage, equals('zh'));
      expect(summary.totalToggles, equals(2));
      expect(summary.idempotenceResult.isValid, isTrue);

      // 验证会话已结束
      expect(OneClickLanguageToggleButton.getToggleCount(), equals(0));
      final stats = OneClickLanguageToggleButton.getToggleStatistics();
      expect(stats.sessionId, isNull);
    });

    group('Idempotence Property Verification', () {
      test('should verify odd/even toggle consistency', () {
        // 测试奇数次切换的幂等性
        counter.startSession('zh');

        for (var i = 1; i <= 10; i++) {
          final fromLang = i.isOdd ? 'zh' : 'en';
          final toLang = i.isOdd ? 'en' : 'zh';

          counter.recordToggle(fromLang, toLang);

          final result = counter.verifyIdempotence();
          expect(result.isValid, isTrue, reason: 'Toggle $i should be valid');

          if (i.isOdd) {
            expect(
              result.expectedLanguage,
              equals('en'),
              reason: 'Odd toggle $i should expect English',
            );
          } else {
            expect(
              result.expectedLanguage,
              equals('zh'),
              reason: 'Even toggle $i should expect Chinese',
            );
          }
        }
      });

      test('should detect idempotence violations correctly', () {
        counter.startSession('zh');

        // 正确的第一次切换
        counter.recordToggle('zh', 'en');
        expect(counter.verifyIdempotence().isValid, isTrue);

        // 错误的第二次切换（应该回到'zh'但实际是'en'）
        counter.recordToggle('en', 'en'); // 模拟错误：没有切换

        final violationResult = counter.verifyIdempotence();
        expect(violationResult.isValid, isFalse);
        expect(violationResult.expectedLanguage, equals('zh'));
        expect(violationResult.actualLanguage, equals('en'));
        expect(violationResult.errorMessage, isNotNull);
      });

      test('should handle multiple complete cycles', () {
        counter.startSession('zh');

        // 执行5个完整的切换循环（每个循环2次切换）
        for (var cycle = 0; cycle < 5; cycle++) {
          counter.recordToggle('zh', 'en');
          counter.recordToggle('en', 'zh');

          // 每个完整循环后都应该回到初始状态
          final result = counter.verifyIdempotence();
          expect(
            result.isValid,
            isTrue,
            reason: 'Cycle $cycle should be valid',
          );
          expect(
            result.actualLanguage,
            equals('zh'),
            reason: 'Should return to Chinese after even toggles',
          );
        }

        expect(counter.toggleCount, equals(10));
        expect(counter.isEvenToggle, isTrue);
      });
    });

    group('Session Management', () {
      test('should handle session lifecycle correctly', () {
        // 验证初始状态
        expect(counter.sessionId, isNull);
        expect(counter.toggleCount, equals(0));

        // 开始会话
        final sessionId = counter.startSession('zh');
        expect(sessionId, isNotNull);
        expect(counter.sessionId, equals(sessionId));
        expect(counter.initialLanguage, equals('zh'));

        // 执行一些切换
        counter.recordToggle('zh', 'en');
        counter.recordToggle('en', 'zh');

        // 获取统计信息
        final stats = counter.getStatistics();
        expect(stats.sessionId, equals(sessionId));
        expect(stats.toggleCount, equals(2));
        expect(stats.sessionDuration, isNotNull);

        // 结束会话
        final summary = counter.endSession();
        expect(summary.sessionId, equals(sessionId));
        expect(summary.totalToggles, equals(2));

        // 验证会话已清理
        expect(counter.sessionId, isNull);
        expect(counter.toggleCount, equals(0));
      });

      test('should auto-start session when needed', () {
        // 直接记录切换而不先开始会话
        expect(counter.sessionId, isNull);

        final count = counter.recordToggle('zh', 'en');

        // 应该自动开始会话
        expect(count, equals(1));
        expect(counter.sessionId, isNotNull);
        expect(counter.initialLanguage, equals('zh'));
        expect(counter.currentLanguage, equals('en'));
      });
    });
  });
}
