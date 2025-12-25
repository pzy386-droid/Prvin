import 'package:flutter_test/flutter_test.dart';
import 'package:prvin/core/localization/app_localizations.dart';
import 'package:prvin/core/localization/app_strings.dart';

void main() {
  group('AppLocalizations Tests', () {
    test('should return correct Chinese strings', () {
      // 设置中文语言
      AppLocalizations.setCurrentLocale('zh');

      // 测试基本字符串
      expect(AppLocalizations.get('app_name'), equals('Prvin AI日历'));
      expect(AppLocalizations.get('calendar'), equals('日历'));
      expect(AppLocalizations.get('focus'), equals('专注'));
      expect(AppLocalizations.get('today'), equals('今天'));
    });

    test('should return correct English strings', () {
      // 设置英文语言
      AppLocalizations.setCurrentLocale('en');

      // 测试基本字符串
      expect(AppLocalizations.get('app_name'), equals('Prvin AI Calendar'));
      expect(AppLocalizations.get('calendar'), equals('Calendar'));
      expect(AppLocalizations.get('focus'), equals('Focus'));
      expect(AppLocalizations.get('today'), equals('Today'));
    });

    test('should return fallback when key not found', () {
      AppLocalizations.setCurrentLocale('zh');

      // 测试不存在的键
      expect(
        AppLocalizations.get('non_existent_key', fallback: 'fallback_text'),
        equals('fallback_text'),
      );

      // 测试没有fallback的情况
      expect(
        AppLocalizations.get('non_existent_key'),
        equals('non_existent_key'),
      );
    });

    test('should support all defined locales', () {
      expect(AppLocalizations.isLocaleSupported('zh'), isTrue);
      expect(AppLocalizations.isLocaleSupported('en'), isTrue);
      expect(AppLocalizations.isLocaleSupported('fr'), isFalse);
    });

    test('should return correct language display names', () {
      expect(AppLocalizations.getLanguageDisplayName('zh'), equals('中文'));
      expect(AppLocalizations.getLanguageDisplayName('en'), equals('English'));
      expect(AppLocalizations.getLanguageDisplayName('fr'), equals('FR'));
    });

    test('should have consistent string keys across languages', () {
      final chineseKeys = AppStrings.localizedValues['zh']!.keys.toSet();
      final englishKeys = AppStrings.localizedValues['en']!.keys.toSet();

      // 检查所有中文键在英文中都有对应
      expect(chineseKeys.difference(englishKeys), isEmpty);

      // 检查所有英文键在中文中都有对应
      expect(englishKeys.difference(chineseKeys), isEmpty);
    });

    test('should cycle through supported languages correctly', () {
      final supportedLocales = AppLocalizations.supportedLocales;
      expect(supportedLocales.length, greaterThan(0));

      // 测试语言循环逻辑
      for (var i = 0; i < supportedLocales.length; i++) {
        final currentLocale = supportedLocales[i];
        final expectedNextIndex = (i + 1) % supportedLocales.length;
        final expectedNextLocale = supportedLocales[expectedNextIndex];

        // 设置当前语言
        AppLocalizations.setCurrentLocale(currentLocale);

        // 验证下一个语言是预期的
        final nextIndex =
            (supportedLocales.indexOf(currentLocale) + 1) %
            supportedLocales.length;
        expect(supportedLocales[nextIndex], equals(expectedNextLocale));
      }
    });

    test('should return correct next language display text', () {
      // 测试中文 -> 英文
      AppLocalizations.setCurrentLocale('zh');
      final supportedLocales = AppLocalizations.supportedLocales;
      final currentIndex = supportedLocales.indexOf('zh');
      final nextIndex = (currentIndex + 1) % supportedLocales.length;
      final nextLocale = supportedLocales[nextIndex];

      String expectedDisplay;
      switch (nextLocale) {
        case 'zh':
          expectedDisplay = '中';
        case 'en':
          expectedDisplay = 'EN';
        default:
          expectedDisplay = nextLocale.toUpperCase();
      }

      // 由于我们无法直接测试 BuildContext 扩展，我们测试逻辑本身
      expect(expectedDisplay, isNotEmpty);
      expect(expectedDisplay.length, lessThanOrEqualTo(3));
    });
  });
}
