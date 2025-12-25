import 'package:flutter_test/flutter_test.dart';
import 'package:prvin/core/services/language_toggle_counter.dart';

void main() {
  group('LanguageToggleCounter Tests', () {
    late LanguageToggleCounter counter;

    setUp(() {
      counter = LanguageToggleCounter.instance;
      counter.reset(); // 确保每个测试开始时状态干净
    });

    tearDown(() {
      counter.reset(); // 清理测试后的状态
    });

    test('should start session correctly', () {
      final sessionId = counter.startSession('zh');

      expect(sessionId, isNotNull);
      expect(counter.sessionId, equals(sessionId));
      expect(counter.initialLanguage, equals('zh'));
      expect(counter.currentLanguage, equals('zh'));
      expect(counter.toggleCount, equals(0));
    });

    test('should record toggle operations correctly', () {
      counter.startSession('zh');

      final count1 = counter.recordToggle('zh', 'en');
      expect(count1, equals(1));
      expect(counter.currentLanguage, equals('en'));
      expect(counter.isOddToggle, isTrue);
      expect(counter.isEvenToggle, isFalse);

      final count2 = counter.recordToggle('en', 'zh');
      expect(count2, equals(2));
      expect(counter.currentLanguage, equals('zh'));
      expect(counter.isOddToggle, isFalse);
      expect(counter.isEvenToggle, isTrue);
    });

    test('should verify idempotence correctly for even toggles', () {
      counter.startSession('zh');

      // 执行偶数次切换（应该回到初始语言）
      counter.recordToggle('zh', 'en');
      counter.recordToggle('en', 'zh');

      final result = counter.verifyIdempotence();
      expect(result.isValid, isTrue);
      expect(result.expectedLanguage, equals('zh'));
      expect(result.actualLanguage, equals('zh'));
      expect(result.toggleCount, equals(2));
      expect(result.errorMessage, isNull);
    });

    test('should verify idempotence correctly for odd toggles', () {
      counter.startSession('zh');

      // 执行奇数次切换（应该切换到另一种语言）
      counter.recordToggle('zh', 'en');

      final result = counter.verifyIdempotence();
      expect(result.isValid, isTrue);
      expect(result.expectedLanguage, equals('en'));
      expect(result.actualLanguage, equals('en'));
      expect(result.toggleCount, equals(1));
      expect(result.errorMessage, isNull);
    });

    test('should detect idempotence violations', () {
      counter.startSession('zh');

      // 模拟错误：奇数次切换但没有改变语言
      counter.recordToggle('zh', 'zh'); // 错误：应该切换到'en'

      final result = counter.verifyIdempotence();
      expect(result.isValid, isFalse);
      expect(result.expectedLanguage, equals('en'));
      expect(result.actualLanguage, equals('zh'));
      expect(result.toggleCount, equals(1));
      expect(result.errorMessage, isNotNull);
    });

    test('should handle multiple toggle cycles correctly', () {
      counter.startSession('zh');

      // 执行多个完整的切换循环
      for (var cycle = 0; cycle < 3; cycle++) {
        counter.recordToggle('zh', 'en');
        counter.recordToggle('en', 'zh');
      }

      expect(counter.toggleCount, equals(6));
      expect(counter.isEvenToggle, isTrue);

      final result = counter.verifyIdempotence();
      expect(result.isValid, isTrue);
      expect(result.actualLanguage, equals('zh')); // 应该回到初始语言
    });

    test('should provide correct statistics', () {
      counter.startSession('zh');
      counter.recordToggle('zh', 'en');
      counter.recordToggle('en', 'zh');

      final stats = counter.getStatistics();
      expect(stats.sessionId, isNotNull);
      expect(stats.initialLanguage, equals('zh'));
      expect(stats.currentLanguage, equals('zh'));
      expect(stats.toggleCount, equals(2));
      expect(stats.isEvenToggle, isTrue);
      expect(stats.sessionDuration, isNotNull);
    });

    test('should end session and provide summary', () {
      counter.startSession('zh');
      counter.recordToggle('zh', 'en');
      counter.recordToggle('en', 'zh');

      final summary = counter.endSession();
      expect(summary.sessionId, isNotNull);
      expect(summary.initialLanguage, equals('zh'));
      expect(summary.finalLanguage, equals('zh'));
      expect(summary.totalToggles, equals(2));
      expect(summary.idempotenceResult.isValid, isTrue);

      // 会话结束后状态应该被重置
      expect(counter.sessionId, isNull);
      expect(counter.toggleCount, equals(0));
    });

    test('should auto-start session when recording toggle without session', () {
      // 不手动开始会话，直接记录切换
      final count = counter.recordToggle('zh', 'en');

      expect(count, equals(1));
      expect(counter.sessionId, isNotNull);
      expect(counter.initialLanguage, equals('zh'));
      expect(counter.currentLanguage, equals('en'));
    });

    test('should handle reset correctly', () {
      counter.startSession('zh');
      counter.recordToggle('zh', 'en');

      expect(counter.toggleCount, equals(1));

      counter.reset();

      expect(counter.sessionId, isNull);
      expect(counter.toggleCount, equals(0));
      expect(counter.initialLanguage, isNull);
      expect(counter.currentLanguage, isNull);
    });

    group('Edge Cases', () {
      test('should handle verification without active session', () {
        final result = counter.verifyIdempotence();
        expect(result.isValid, isFalse);
        expect(result.errorMessage, contains('No active session'));
      });

      test('should handle statistics without active session', () {
        final stats = counter.getStatistics();
        expect(stats.sessionId, isNull);
        expect(stats.toggleCount, equals(0));
      });

      test('should handle alternate language correctly', () {
        counter.startSession('en');
        counter.recordToggle('en', 'zh');

        final result = counter.verifyIdempotence();
        expect(result.isValid, isTrue);
        expect(result.expectedLanguage, equals('zh'));
      });
    });
  });
}
