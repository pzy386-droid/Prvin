import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prvin/core/services/language_toggle_counter.dart';

/// **Feature: one-click-language-toggle, Property 5: 切换操作幂等性**
/// *对于任何*连续的语言切换操作，奇数次点击应该切换到一种语言，偶数次点击应该回到原始语言
/// **Validates: Requirements 1.1**
void main() {
  group('Toggle Idempotence Property Tests', () {
    final faker = Faker();
    late LanguageToggleCounter counter;

    setUp(() {
      counter = LanguageToggleCounter.instance;
      counter.reset();
    });

    tearDown(() {
      counter.reset();
    });

    test(
      'Property 5: 切换操作幂等性 - even number of toggles should return to initial language',
      () {
        // **Feature: one-click-language-toggle, Property 5: 切换操作幂等性**

        // 运行100次迭代以确保属性在各种输入下都成立
        for (var i = 0; i < 100; i++) {
          // 生成随机的初始语言状态
          final initialLanguage = _generateRandomLanguageState(faker);

          // 开始新的切换会话
          counter.startSession(initialLanguage);

          // 生成随机的偶数次切换次数 (2, 4, 6, 8, 10)
          final evenToggleCount = (faker.randomGenerator.integer(5) + 1) * 2;

          var currentLanguage = initialLanguage;

          // 执行偶数次切换
          for (
            var toggleIndex = 0;
            toggleIndex < evenToggleCount;
            toggleIndex++
          ) {
            final nextLanguage = _getAlternateLanguage(currentLanguage);
            counter.recordToggle(currentLanguage, nextLanguage);
            currentLanguage = nextLanguage;
          }

          // 验证幂等性：偶数次切换后应该回到初始语言
          final idempotenceResult = counter.verifyIdempotence();

          expect(
            idempotenceResult.isValid,
            isTrue,
            reason:
                'After $evenToggleCount toggles, idempotence should be valid',
          );

          expect(
            idempotenceResult.actualLanguage,
            equals(initialLanguage),
            reason:
                'After $evenToggleCount toggles, should return to initial language $initialLanguage',
          );

          expect(
            idempotenceResult.expectedLanguage,
            equals(initialLanguage),
            reason:
                'Expected language should be initial language for even toggles',
          );

          expect(
            idempotenceResult.toggleCount,
            equals(evenToggleCount),
            reason: 'Toggle count should match performed toggles',
          );

          // 重置计数器为下一次迭代
          counter.reset();
        }
      },
    );

    test(
      'Property 5: 切换操作幂等性 - odd number of toggles should switch to alternate language',
      () {
        // **Feature: one-click-language-toggle, Property 5: 切换操作幂等性**

        // 运行100次迭代以确保属性在各种输入下都成立
        for (var i = 0; i < 100; i++) {
          // 生成随机的初始语言状态
          final initialLanguage = _generateRandomLanguageState(faker);

          // 开始新的切换会话
          counter.startSession(initialLanguage);

          // 生成随机的奇数次切换次数 (1, 3, 5, 7, 9)
          final oddToggleCount = (faker.randomGenerator.integer(5) * 2) + 1;

          var currentLanguage = initialLanguage;

          // 执行奇数次切换
          for (
            var toggleIndex = 0;
            toggleIndex < oddToggleCount;
            toggleIndex++
          ) {
            final nextLanguage = _getAlternateLanguage(currentLanguage);
            counter.recordToggle(currentLanguage, nextLanguage);
            currentLanguage = nextLanguage;
          }

          // 验证幂等性：奇数次切换后应该切换到备用语言
          final idempotenceResult = counter.verifyIdempotence();
          final expectedAlternateLanguage = _getAlternateLanguage(
            initialLanguage,
          );

          expect(
            idempotenceResult.isValid,
            isTrue,
            reason:
                'After $oddToggleCount toggles, idempotence should be valid',
          );

          expect(
            idempotenceResult.actualLanguage,
            equals(expectedAlternateLanguage),
            reason:
                'After $oddToggleCount toggles, should be at alternate language $expectedAlternateLanguage',
          );

          expect(
            idempotenceResult.expectedLanguage,
            equals(expectedAlternateLanguage),
            reason:
                'Expected language should be alternate language for odd toggles',
          );

          expect(
            idempotenceResult.toggleCount,
            equals(oddToggleCount),
            reason: 'Toggle count should match performed toggles',
          );

          // 重置计数器为下一次迭代
          counter.reset();
        }
      },
    );

    test(
      'Property 5: 切换操作幂等性 - consecutive even-odd toggle pairs should maintain consistency',
      () {
        // **Feature: one-click-language-toggle, Property 5: 切换操作幂等性**

        for (var i = 0; i < 50; i++) {
          final initialLanguage = _generateRandomLanguageState(faker);
          counter.startSession(initialLanguage);

          var currentLanguage = initialLanguage;

          // 执行多个偶数-奇数切换对
          final pairCount = faker.randomGenerator.integer(5) + 1; // 1-5对

          for (var pairIndex = 0; pairIndex < pairCount; pairIndex++) {
            // 执行偶数次切换 (2次)
            for (var evenToggle = 0; evenToggle < 2; evenToggle++) {
              final nextLanguage = _getAlternateLanguage(currentLanguage);
              counter.recordToggle(currentLanguage, nextLanguage);
              currentLanguage = nextLanguage;
            }

            // 验证偶数次切换后回到初始语言
            var result = counter.verifyIdempotence();
            expect(
              result.actualLanguage,
              equals(initialLanguage),
              reason:
                  'After even toggles in pair $pairIndex, should return to initial language',
            );

            // 执行奇数次切换 (1次)
            final nextLanguage = _getAlternateLanguage(currentLanguage);
            counter.recordToggle(currentLanguage, nextLanguage);
            currentLanguage = nextLanguage;

            // 验证奇数次切换后切换到备用语言
            result = counter.verifyIdempotence();
            expect(
              result.actualLanguage,
              equals(_getAlternateLanguage(initialLanguage)),
              reason:
                  'After odd toggle in pair $pairIndex, should be at alternate language',
            );
          }

          counter.reset();
        }
      },
    );

    test(
      'Property 5: 切换操作幂等性 - large number of toggles should maintain idempotence',
      () {
        // **Feature: one-click-language-toggle, Property 5: 切换操作幂等性**

        for (var i = 0; i < 20; i++) {
          final initialLanguage = _generateRandomLanguageState(faker);
          counter.startSession(initialLanguage);

          // 执行大量切换操作 (50-200次)
          final largeToggleCount = faker.randomGenerator.integer(151) + 50;

          var currentLanguage = initialLanguage;

          for (
            var toggleIndex = 0;
            toggleIndex < largeToggleCount;
            toggleIndex++
          ) {
            final nextLanguage = _getAlternateLanguage(currentLanguage);
            counter.recordToggle(currentLanguage, nextLanguage);
            currentLanguage = nextLanguage;
          }

          // 验证幂等性
          final idempotenceResult = counter.verifyIdempotence();

          expect(
            idempotenceResult.isValid,
            isTrue,
            reason:
                'After $largeToggleCount toggles, idempotence should still be valid',
          );

          // 验证最终语言状态符合奇偶性规则
          if (largeToggleCount.isEven) {
            expect(
              idempotenceResult.actualLanguage,
              equals(initialLanguage),
              reason:
                  'After $largeToggleCount (even) toggles, should return to initial language',
            );
          } else {
            expect(
              idempotenceResult.actualLanguage,
              equals(_getAlternateLanguage(initialLanguage)),
              reason:
                  'After $largeToggleCount (odd) toggles, should be at alternate language',
            );
          }

          counter.reset();
        }
      },
    );

    test(
      'Property 5: 切换操作幂等性 - rapid toggle sequences should maintain consistency',
      () {
        // **Feature: one-click-language-toggle, Property 5: 切换操作幂等性**

        for (var i = 0; i < 30; i++) {
          final initialLanguage = _generateRandomLanguageState(faker);
          counter.startSession(initialLanguage);

          var currentLanguage = initialLanguage;

          // 模拟快速切换序列
          final rapidToggleCount =
              faker.randomGenerator.integer(20) + 5; // 5-24次

          for (
            var toggleIndex = 0;
            toggleIndex < rapidToggleCount;
            toggleIndex++
          ) {
            final nextLanguage = _getAlternateLanguage(currentLanguage);
            counter.recordToggle(currentLanguage, nextLanguage);
            currentLanguage = nextLanguage;

            // 在每次切换后验证幂等性
            final intermediateResult = counter.verifyIdempotence();
            expect(
              intermediateResult.isValid,
              isTrue,
              reason:
                  'Idempotence should be valid after toggle ${toggleIndex + 1}',
            );

            // 验证中间状态符合奇偶性规则
            final currentToggleCount = toggleIndex + 1;
            if (currentToggleCount.isEven) {
              expect(
                intermediateResult.actualLanguage,
                equals(initialLanguage),
                reason:
                    'After $currentToggleCount (even) toggles, should be at initial language',
              );
            } else {
              expect(
                intermediateResult.actualLanguage,
                equals(_getAlternateLanguage(initialLanguage)),
                reason:
                    'After $currentToggleCount (odd) toggles, should be at alternate language',
              );
            }
          }

          counter.reset();
        }
      },
    );

    group('Edge Cases Property Tests', () {
      test(
        'Property 5: 切换操作幂等性 - single toggle should always switch to alternate',
        () {
          // **Feature: one-click-language-toggle, Property 5: 切换操作幂等性**

          for (var i = 0; i < 50; i++) {
            final initialLanguage = _generateRandomLanguageState(faker);
            counter.startSession(initialLanguage);

            // 执行单次切换
            final alternateLanguage = _getAlternateLanguage(initialLanguage);
            counter.recordToggle(initialLanguage, alternateLanguage);

            // 验证幂等性
            final result = counter.verifyIdempotence();

            expect(result.isValid, isTrue);
            expect(result.toggleCount, equals(1));
            expect(result.actualLanguage, equals(alternateLanguage));
            expect(result.expectedLanguage, equals(alternateLanguage));

            counter.reset();
          }
        },
      );

      test(
        'Property 5: 切换操作幂等性 - zero toggles should maintain initial state',
        () {
          // **Feature: one-click-language-toggle, Property 5: 切换操作幂等性**

          for (var i = 0; i < 30; i++) {
            final initialLanguage = _generateRandomLanguageState(faker);
            counter.startSession(initialLanguage);

            // 不执行任何切换，直接验证
            final result = counter.verifyIdempotence();

            expect(result.isValid, isTrue);
            expect(result.toggleCount, equals(0));
            expect(result.actualLanguage, equals(initialLanguage));
            expect(result.expectedLanguage, equals(initialLanguage));

            counter.reset();
          }
        },
      );
    });

    group('Session Management Property Tests', () {
      test(
        'Property 5: 切换操作幂等性 - multiple sessions should maintain independent idempotence',
        () {
          // **Feature: one-click-language-toggle, Property 5: 切换操作幂等性**

          for (var i = 0; i < 20; i++) {
            // 第一个会话
            final firstInitialLanguage = _generateRandomLanguageState(faker);
            counter.startSession(firstInitialLanguage);

            final firstToggleCount = faker.randomGenerator.integer(10) + 1;
            var currentLanguage = firstInitialLanguage;

            for (var j = 0; j < firstToggleCount; j++) {
              final nextLanguage = _getAlternateLanguage(currentLanguage);
              counter.recordToggle(currentLanguage, nextLanguage);
              currentLanguage = nextLanguage;
            }

            final firstResult = counter.verifyIdempotence();
            expect(firstResult.isValid, isTrue);

            // 验证第一个会话的幂等性
            if (firstToggleCount.isEven) {
              expect(
                firstResult.actualLanguage,
                equals(firstInitialLanguage),
                reason: 'First session: even toggles should return to initial',
              );
            } else {
              expect(
                firstResult.actualLanguage,
                equals(_getAlternateLanguage(firstInitialLanguage)),
                reason: 'First session: odd toggles should switch to alternate',
              );
            }

            // 结束第一个会话并完全重置
            counter.endSession();

            // 第二个会话 - 使用完全独立的状态
            final secondInitialLanguage = _generateRandomLanguageState(faker);
            counter.startSession(secondInitialLanguage);

            final secondToggleCount = faker.randomGenerator.integer(10) + 1;
            currentLanguage = secondInitialLanguage;

            for (var j = 0; j < secondToggleCount; j++) {
              final nextLanguage = _getAlternateLanguage(currentLanguage);
              counter.recordToggle(currentLanguage, nextLanguage);
              currentLanguage = nextLanguage;
            }

            final secondResult = counter.verifyIdempotence();
            expect(secondResult.isValid, isTrue);

            // 验证第二个会话的幂等性独立于第一个会话
            if (secondToggleCount.isEven) {
              expect(
                secondResult.actualLanguage,
                equals(secondInitialLanguage),
                reason: 'Second session: even toggles should return to initial',
              );
            } else {
              expect(
                secondResult.actualLanguage,
                equals(_getAlternateLanguage(secondInitialLanguage)),
                reason:
                    'Second session: odd toggles should switch to alternate',
              );
            }

            // 确保会话计数正确
            expect(
              secondResult.toggleCount,
              equals(secondToggleCount),
              reason: 'Second session should have correct toggle count',
            );

            counter.reset();
          }
        },
      );
    });
  });
}

/// 生成随机的语言状态用于测试
String _generateRandomLanguageState(Faker faker) {
  final supportedLanguages = ['zh', 'en'];
  final randomIndex = faker.randomGenerator.integer(supportedLanguages.length);
  return supportedLanguages[randomIndex];
}

/// 获取备用语言
String _getAlternateLanguage(String currentLanguage) {
  switch (currentLanguage) {
    case 'zh':
      return 'en';
    case 'en':
      return 'zh';
    default:
      return 'en'; // 默认切换到英文
  }
}
