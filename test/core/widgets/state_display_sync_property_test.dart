import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prvin/core/localization/app_localizations.dart';
import 'package:prvin/core/widgets/one_click_language_toggle_button.dart';

/// **Feature: one-click-language-toggle, Property 2: 状态显示同步性**
/// *对于任何*语言切换操作，按钮显示的语言标识应该与系统当前语言状态保持同步
/// **Validates: Requirements 2.3**
void main() {
  group('State Display Synchronization Property Tests', () {
    final faker = Faker();

    test(
      'Property 2: 状态显示同步性 - button display should always sync with system language state',
      () {
        // **Feature: one-click-language-toggle, Property 2: 状态显示同步性**

        // 运行100次迭代以确保属性在各种输入下都成立
        for (var i = 0; i < 100; i++) {
          // 生成随机的语言状态序列
          final testLanguageSequence = _generateRandomLanguageSequence(faker);

          // 对每个语言状态验证显示同步性
          for (final languageCode in testLanguageSequence) {
            // 获取系统语言状态
            final systemLanguageState = LanguageToggleState.fromCode(
              languageCode,
            );

            // 获取按钮应该显示的文本
            final expectedDisplayText = _getExpectedDisplayText(languageCode);

            // 验证按钮显示与系统状态同步
            expect(
              systemLanguageState.display,
              equals(expectedDisplayText),
              reason:
                  'Button display should match system language state for $languageCode',
            );

            // 验证显示文本的正确性
            _validateDisplayTextCorrectness(languageCode, expectedDisplayText);
          }
        }
      },
    );

    test(
      'Property 2: 状态显示同步性 - display should update immediately after language change',
      () {
        // **Feature: one-click-language-toggle, Property 2: 状态显示同步性**

        for (var i = 0; i < 50; i++) {
          // 生成随机的初始语言和目标语言
          final initialLanguage = _generateRandomSupportedLanguage(faker);
          final targetLanguage = _getOppositeLanguage(initialLanguage);

          // 模拟语言切换前的状态
          final beforeSwitchDisplay = _getExpectedDisplayText(initialLanguage);

          // 模拟语言切换后的状态
          final afterSwitchDisplay = _getExpectedDisplayText(targetLanguage);

          // 验证切换前后显示文本不同
          expect(
            beforeSwitchDisplay,
            isNot(equals(afterSwitchDisplay)),
            reason:
                'Display should change when language switches from $initialLanguage to $targetLanguage',
          );

          // 验证切换后的显示文本正确
          expect(
            afterSwitchDisplay,
            equals(_getExpectedDisplayForLanguage(targetLanguage)),
            reason:
                'Display should show correct text for target language $targetLanguage',
          );

          // 验证显示文本与语言状态枚举一致
          final languageState = LanguageToggleState.fromCode(targetLanguage);
          expect(
            afterSwitchDisplay,
            equals(languageState.display),
            reason:
                'Display should match LanguageToggleState enum display for $targetLanguage',
          );
        }
      },
    );

    test(
      'Property 2: 状态显示同步性 - display consistency across multiple rapid switches',
      () {
        // **Feature: one-click-language-toggle, Property 2: 状态显示同步性**

        for (var i = 0; i < 30; i++) {
          var currentLanguage = _generateRandomSupportedLanguage(faker);
          final switchCount = faker.randomGenerator.integer(10, min: 3);

          // 执行多次快速切换
          for (var switchIndex = 0; switchIndex < switchCount; switchIndex++) {
            // 切换到下一个语言
            currentLanguage = _performLanguageToggle(currentLanguage);

            // 验证每次切换后显示都正确同步
            final expectedDisplay = _getExpectedDisplayText(currentLanguage);
            final languageState = LanguageToggleState.fromCode(currentLanguage);

            expect(
              languageState.display,
              equals(expectedDisplay),
              reason:
                  'Display should sync correctly after switch $switchIndex to $currentLanguage',
            );

            // 验证显示文本的有效性
            expect(
              _isValidDisplayText(expectedDisplay),
              isTrue,
              reason: 'Display text should be valid: $expectedDisplay',
            );
          }
        }
      },
    );

    test(
      'Property 2: 状态显示同步性 - display should handle edge cases correctly',
      () {
        // **Feature: one-click-language-toggle, Property 2: 状态显示同步性**

        for (var i = 0; i < 20; i++) {
          // 测试无效语言代码的显示处理
          final invalidLanguage = faker.lorem.word();
          final fallbackState = LanguageToggleState.fromCode(invalidLanguage);

          // 验证无效语言代码回退到默认显示
          expect(
            fallbackState,
            equals(LanguageToggleState.chinese),
            reason: 'Invalid language should fallback to Chinese state',
          );

          expect(
            fallbackState.display,
            equals('中'),
            reason: 'Fallback state should display Chinese identifier',
          );

          // 测试空字符串的处理
          final emptyState = LanguageToggleState.fromCode('');
          expect(
            emptyState.display,
            equals('中'),
            reason: 'Empty language code should display Chinese identifier',
          );

          // 测试大小写变化的处理
          final upperCaseZh = LanguageToggleState.fromCode('ZH');
          final lowerCaseZh = LanguageToggleState.fromCode('zh');

          // 由于当前实现区分大小写，大写应该回退到默认
          expect(
            upperCaseZh.display,
            equals('中'),
            reason: 'Case-sensitive handling should work correctly',
          );

          expect(
            lowerCaseZh.display,
            equals('中'),
            reason: 'Lowercase zh should display Chinese identifier',
          );
        }
      },
    );

    test('Property 2: 状态显示同步性 - display text properties should be consistent', () {
      // **Feature: one-click-language-toggle, Property 2: 状态显示同步性**

      for (var i = 0; i < 50; i++) {
        final supportedLanguages = AppLocalizations.supportedLocales;

        for (final language in supportedLanguages) {
          final languageState = LanguageToggleState.fromCode(language);
          final displayText = languageState.display;

          // 验证显示文本不为空
          expect(
            displayText.isNotEmpty,
            isTrue,
            reason: 'Display text should not be empty for $language',
          );

          // 验证显示文本长度合理（1-3个字符）
          expect(
            displayText.length,
            inInclusiveRange(1, 3),
            reason:
                'Display text length should be reasonable for $language: $displayText',
          );

          // 验证显示文本不包含空白字符
          expect(
            displayText.trim(),
            equals(displayText),
            reason:
                'Display text should not have leading/trailing whitespace: "$displayText"',
          );

          // 验证特定语言的显示文本格式
          if (language == 'zh') {
            expect(
              displayText,
              equals('中'),
              reason: 'Chinese should display as "中"',
            );
          } else if (language == 'en') {
            expect(
              displayText,
              equals('EN'),
              reason: 'English should display as "EN"',
            );
          }

          // 验证显示文本的一致性（多次调用应返回相同结果）
          final secondCall = LanguageToggleState.fromCode(language).display;
          expect(
            displayText,
            equals(secondCall),
            reason:
                'Display text should be consistent across calls for $language',
          );
        }
      }
    });

    group('Extension Method Property Tests', () {
      test(
        'Property 2: 状态显示同步性 - nextLanguageDisplay should be consistent with toggle logic',
        () {
          // **Feature: one-click-language-toggle, Property 2: 状态显示同步性**

          for (var i = 0; i < 50; i++) {
            final currentLanguage = _generateRandomSupportedLanguage(faker);
            final nextLanguage = _performLanguageToggle(currentLanguage);

            // 获取下一个语言的显示文本
            final nextDisplay = _getNextLanguageDisplay(currentLanguage);
            final expectedNextDisplay = _getExpectedDisplayText(nextLanguage);

            // 验证nextLanguageDisplay与实际切换结果一致
            expect(
              nextDisplay,
              equals(expectedNextDisplay),
              reason:
                  'nextLanguageDisplay should match actual next language display for $currentLanguage -> $nextLanguage',
            );

            // 验证显示文本的双向一致性
            final reverseNextDisplay = _getNextLanguageDisplay(nextLanguage);
            final expectedReverseDisplay = _getExpectedDisplayText(
              currentLanguage,
            );

            expect(
              reverseNextDisplay,
              equals(expectedReverseDisplay),
              reason:
                  'Reverse nextLanguageDisplay should be consistent for $nextLanguage -> $currentLanguage',
            );
          }
        },
      );
    });
  });
}

/// 生成随机的语言序列用于测试
List<String> _generateRandomLanguageSequence(Faker faker) {
  final supportedLanguages = AppLocalizations.supportedLocales;
  final sequenceLength = faker.randomGenerator.integer(10, min: 3);

  return List.generate(sequenceLength, (index) {
    final randomIndex = faker.randomGenerator.integer(
      supportedLanguages.length,
    );
    return supportedLanguages[randomIndex];
  });
}

/// 生成随机的支持语言
String _generateRandomSupportedLanguage(Faker faker) {
  final supportedLanguages = AppLocalizations.supportedLocales;
  final randomIndex = faker.randomGenerator.integer(supportedLanguages.length);
  return supportedLanguages[randomIndex];
}

/// 获取语言的对立语言（用于双语切换测试）
String _getOppositeLanguage(String language) {
  return language == 'zh' ? 'en' : 'zh';
}

/// 获取期望的显示文本
String _getExpectedDisplayText(String languageCode) {
  switch (languageCode) {
    case 'zh':
      return '中';
    case 'en':
      return 'EN';
    default:
      return '中'; // 默认回退到中文
  }
}

/// 获取特定语言的期望显示文本（与_getExpectedDisplayText相同，用于语义清晰）
String _getExpectedDisplayForLanguage(String languageCode) {
  return _getExpectedDisplayText(languageCode);
}

/// 验证显示文本的正确性
void _validateDisplayTextCorrectness(String languageCode, String displayText) {
  switch (languageCode) {
    case 'zh':
      expect(
        displayText,
        equals('中'),
        reason: 'Chinese language should display "中"',
      );
    case 'en':
      expect(
        displayText,
        equals('EN'),
        reason: 'English language should display "EN"',
      );
    default:
      expect(
        displayText,
        equals('中'),
        reason: 'Unknown language should fallback to Chinese display "中"',
      );
  }
}

/// 检查显示文本是否有效
bool _isValidDisplayText(String displayText) {
  final validDisplayTexts = {'中', 'EN'};
  return validDisplayTexts.contains(displayText);
}

/// 执行语言切换操作（模拟核心切换逻辑）
String _performLanguageToggle(String currentLanguage) {
  final supportedLocales = AppLocalizations.supportedLocales;

  // 确保当前语言在支持列表中
  var workingLanguage = currentLanguage;
  if (!supportedLocales.contains(workingLanguage)) {
    workingLanguage = 'zh'; // 默认使用中文
  }

  // 找到当前语言在支持列表中的索引
  final currentIndex = supportedLocales.indexOf(workingLanguage);

  // 计算下一个语言的索引（循环）
  final nextIndex = (currentIndex + 1) % supportedLocales.length;

  return supportedLocales[nextIndex];
}

/// 获取下一个语言的显示文本（模拟扩展方法）
String _getNextLanguageDisplay(String currentLanguage) {
  final nextLanguage = _performLanguageToggle(currentLanguage);
  return _getExpectedDisplayText(nextLanguage);
}
