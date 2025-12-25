import 'package:flutter_test/flutter_test.dart';
import 'package:prvin/core/localization/app_strings.dart';

/// 语言切换功能验证测试
///
/// 验证一键语言切换功能的基本功能和新增的翻译文本
void main() {
  group('Language Toggle Verification Tests', () {
    test('should support both Chinese and English locales', () {
      expect(AppStrings.isLocaleSupported('zh'), isTrue);
      expect(AppStrings.isLocaleSupported('en'), isTrue);
      expect(AppStrings.isLocaleSupported('fr'), isFalse);
    });

    test('should return correct supported locales', () {
      final supportedLocales = AppStrings.supportedLocales;
      expect(supportedLocales, contains('zh'));
      expect(supportedLocales, contains('en'));
      expect(supportedLocales.length, equals(2));
    });

    group('AI Feature Translations', () {
      test('should have AI analytics translations in both languages', () {
        final zhStrings = AppStrings.localizedValues['zh']!;
        final enStrings = AppStrings.localizedValues['en']!;

        // AI分析相关
        expect(zhStrings['ai_analytics'], equals('AI 数据分析'));
        expect(enStrings['ai_analytics'], equals('AI Data Analysis'));

        expect(zhStrings['ai_analytics_subtitle'], equals('智能分析您的工作模式'));
        expect(
          enStrings['ai_analytics_subtitle'],
          equals('Intelligent analysis of your work patterns'),
        );

        expect(zhStrings['ai_suggestions'], equals('AI智能建议'));
        expect(enStrings['ai_suggestions'], equals('AI Smart Suggestions'));
      });

      test('should have task pattern translations in both languages', () {
        final zhStrings = AppStrings.localizedValues['zh']!;
        final enStrings = AppStrings.localizedValues['en']!;

        expect(zhStrings['task_patterns'], equals('任务模式分析'));
        expect(enStrings['task_patterns'], equals('Task Pattern Analysis'));

        expect(zhStrings['time_distribution'], equals('时间分配'));
        expect(enStrings['time_distribution'], equals('Time Distribution'));

        expect(zhStrings['productivity_trends'], equals('生产力趋势'));
        expect(enStrings['productivity_trends'], equals('Productivity Trends'));
      });

      test('should have AI suggestion states in both languages', () {
        final zhStrings = AppStrings.localizedValues['zh']!;
        final enStrings = AppStrings.localizedValues['en']!;

        expect(zhStrings['no_ai_suggestions'], equals('暂无AI建议'));
        expect(enStrings['no_ai_suggestions'], equals('No AI Suggestions'));

        expect(zhStrings['analyzing_data'], equals('正在分析您的数据...'));
        expect(enStrings['analyzing_data'], equals('Analyzing your data...'));

        expect(zhStrings['start_analysis'], equals('开始分析'));
        expect(enStrings['start_analysis'], equals('Start Analysis'));
      });
    });

    group('Sync Feature Translations', () {
      test('should have sync settings translations in both languages', () {
        final zhStrings = AppStrings.localizedValues['zh']!;
        final enStrings = AppStrings.localizedValues['en']!;

        expect(zhStrings['sync_settings'], equals('同步设置'));
        expect(enStrings['sync_settings'], equals('Sync Settings'));

        expect(zhStrings['external_calendar'], equals('外部日历'));
        expect(enStrings['external_calendar'], equals('External Calendar'));

        expect(zhStrings['google_calendar'], equals('Google 日历'));
        expect(enStrings['google_calendar'], equals('Google Calendar'));
      });

      test('should have sync status translations in both languages', () {
        final zhStrings = AppStrings.localizedValues['zh']!;
        final enStrings = AppStrings.localizedValues['en']!;

        expect(zhStrings['sync_enabled'], equals('同步已启用'));
        expect(enStrings['sync_enabled'], equals('Sync Enabled'));

        expect(zhStrings['sync_disabled'], equals('同步已禁用'));
        expect(enStrings['sync_disabled'], equals('Sync Disabled'));

        expect(zhStrings['sync_conflict'], equals('同步冲突'));
        expect(enStrings['sync_conflict'], equals('Sync Conflict'));
      });

      test('should have connection status translations in both languages', () {
        final zhStrings = AppStrings.localizedValues['zh']!;
        final enStrings = AppStrings.localizedValues['en']!;

        expect(zhStrings['offline_mode'], equals('离线模式'));
        expect(enStrings['offline_mode'], equals('Offline Mode'));

        expect(zhStrings['online_mode'], equals('在线模式'));
        expect(enStrings['online_mode'], equals('Online Mode'));

        expect(zhStrings['connection_lost'], equals('连接丢失'));
        expect(enStrings['connection_lost'], equals('Connection Lost'));

        expect(zhStrings['connection_restored'], equals('连接已恢复'));
        expect(enStrings['connection_restored'], equals('Connection Restored'));
      });
    });

    group('Web Platform Feature Translations', () {
      test('should have PWA translations in both languages', () {
        final zhStrings = AppStrings.localizedValues['zh']!;
        final enStrings = AppStrings.localizedValues['en']!;

        expect(zhStrings['install_pwa'], equals('安装应用'));
        expect(enStrings['install_pwa'], equals('Install App'));

        expect(zhStrings['pwa_install_prompt'], equals('将此应用安装到您的设备'));
        expect(
          enStrings['pwa_install_prompt'],
          equals('Install this app to your device'),
        );

        expect(zhStrings['pwa_installed'], equals('应用已安装'));
        expect(enStrings['pwa_installed'], equals('App Installed'));
      });

      test('should have web feature translations in both languages', () {
        final zhStrings = AppStrings.localizedValues['zh']!;
        final enStrings = AppStrings.localizedValues['en']!;

        expect(zhStrings['keyboard_shortcuts'], equals('键盘快捷键'));
        expect(enStrings['keyboard_shortcuts'], equals('Keyboard Shortcuts'));

        expect(zhStrings['copy_to_clipboard'], equals('复制到剪贴板'));
        expect(enStrings['copy_to_clipboard'], equals('Copy to Clipboard'));

        expect(zhStrings['copied_to_clipboard'], equals('已复制到剪贴板'));
        expect(enStrings['copied_to_clipboard'], equals('Copied to Clipboard'));
      });

      test('should have notification translations in both languages', () {
        final zhStrings = AppStrings.localizedValues['zh']!;
        final enStrings = AppStrings.localizedValues['en']!;

        expect(zhStrings['browser_notification'], equals('浏览器通知'));
        expect(
          enStrings['browser_notification'],
          equals('Browser Notification'),
        );

        expect(zhStrings['notification_permission'], equals('通知权限'));
        expect(
          enStrings['notification_permission'],
          equals('Notification Permission'),
        );

        expect(zhStrings['enable_notifications'], equals('启用通知'));
        expect(
          enStrings['enable_notifications'],
          equals('Enable Notifications'),
        );
      });
    });

    group('Accessibility Feature Translations', () {
      test('should have accessibility translations in both languages', () {
        final zhStrings = AppStrings.localizedValues['zh']!;
        final enStrings = AppStrings.localizedValues['en']!;

        expect(zhStrings['accessibility_mode'], equals('无障碍模式'));
        expect(enStrings['accessibility_mode'], equals('Accessibility Mode'));

        expect(zhStrings['high_contrast'], equals('高对比度'));
        expect(enStrings['high_contrast'], equals('High Contrast'));

        expect(zhStrings['large_text'], equals('大字体'));
        expect(enStrings['large_text'], equals('Large Text'));
      });

      test(
        'should have assistive technology translations in both languages',
        () {
          final zhStrings = AppStrings.localizedValues['zh']!;
          final enStrings = AppStrings.localizedValues['en']!;

          expect(zhStrings['screen_reader'], equals('屏幕阅读器'));
          expect(enStrings['screen_reader'], equals('Screen Reader'));

          expect(zhStrings['keyboard_navigation'], equals('键盘导航'));
          expect(
            enStrings['keyboard_navigation'],
            equals('Keyboard Navigation'),
          );

          expect(zhStrings['voice_control'], equals('语音控制'));
          expect(enStrings['voice_control'], equals('Voice Control'));

          expect(zhStrings['accessibility_settings'], equals('无障碍设置'));
          expect(
            enStrings['accessibility_settings'],
            equals('Accessibility Settings'),
          );
        },
      );
    });

    group('Translation Completeness', () {
      test('should have all AI feature keys in both languages', () {
        final zhStrings = AppStrings.localizedValues['zh']!;
        final enStrings = AppStrings.localizedValues['en']!;

        final aiKeys = [
          'ai_analytics',
          'ai_analytics_subtitle',
          'ai_suggestions',
          'ai_recommendations',
          'task_patterns',
          'time_distribution',
          'productivity_trends',
          'focus_recommendations',
          'no_ai_suggestions',
          'no_ai_suggestions_hint',
          'analyzing_data',
          'start_analysis',
          'refresh_analysis',
          'similar_tasks',
          'suggested_tags',
          'confidence',
          'apply_suggestion',
          'best_time',
          'recommended_duration',
          'data_overview',
        ];

        for (final key in aiKeys) {
          expect(
            zhStrings.containsKey(key),
            isTrue,
            reason: 'Chinese missing key: $key',
          );
          expect(
            enStrings.containsKey(key),
            isTrue,
            reason: 'English missing key: $key',
          );
          expect(
            zhStrings[key],
            isNotEmpty,
            reason: 'Chinese empty value for key: $key',
          );
          expect(
            enStrings[key],
            isNotEmpty,
            reason: 'English empty value for key: $key',
          );
        }
      });

      test('should have all sync feature keys in both languages', () {
        final zhStrings = AppStrings.localizedValues['zh']!;
        final enStrings = AppStrings.localizedValues['en']!;

        final syncKeys = [
          'sync_settings',
          'external_calendar',
          'google_calendar',
          'outlook_calendar',
          'sync_status',
          'sync_enabled',
          'sync_disabled',
          'last_sync',
          'sync_now',
          'sync_conflict',
          'resolve_conflict',
          'sync_error',
          'offline_mode',
          'online_mode',
          'connection_lost',
          'connection_restored',
        ];

        for (final key in syncKeys) {
          expect(
            zhStrings.containsKey(key),
            isTrue,
            reason: 'Chinese missing key: $key',
          );
          expect(
            enStrings.containsKey(key),
            isTrue,
            reason: 'English missing key: $key',
          );
          expect(
            zhStrings[key],
            isNotEmpty,
            reason: 'Chinese empty value for key: $key',
          );
          expect(
            enStrings[key],
            isNotEmpty,
            reason: 'English empty value for key: $key',
          );
        }
      });

      test('should have all web platform keys in both languages', () {
        final zhStrings = AppStrings.localizedValues['zh']!;
        final enStrings = AppStrings.localizedValues['en']!;

        final webKeys = [
          'install_pwa',
          'pwa_install_prompt',
          'pwa_installed',
          'offline_available',
          'update_available',
          'keyboard_shortcuts',
          'copy_to_clipboard',
          'copied_to_clipboard',
          'paste_from_clipboard',
          'browser_notification',
          'notification_permission',
          'enable_notifications',
        ];

        for (final key in webKeys) {
          expect(
            zhStrings.containsKey(key),
            isTrue,
            reason: 'Chinese missing key: $key',
          );
          expect(
            enStrings.containsKey(key),
            isTrue,
            reason: 'English missing key: $key',
          );
          expect(
            zhStrings[key],
            isNotEmpty,
            reason: 'Chinese empty value for key: $key',
          );
          expect(
            enStrings[key],
            isNotEmpty,
            reason: 'English empty value for key: $key',
          );
        }
      });

      test('should have all accessibility keys in both languages', () {
        final zhStrings = AppStrings.localizedValues['zh']!;
        final enStrings = AppStrings.localizedValues['en']!;

        final accessibilityKeys = [
          'accessibility_mode',
          'high_contrast',
          'large_text',
          'screen_reader',
          'keyboard_navigation',
          'voice_control',
          'accessibility_settings',
        ];

        for (final key in accessibilityKeys) {
          expect(
            zhStrings.containsKey(key),
            isTrue,
            reason: 'Chinese missing key: $key',
          );
          expect(
            enStrings.containsKey(key),
            isTrue,
            reason: 'English missing key: $key',
          );
          expect(
            zhStrings[key],
            isNotEmpty,
            reason: 'Chinese empty value for key: $key',
          );
          expect(
            enStrings[key],
            isNotEmpty,
            reason: 'English empty value for key: $key',
          );
        }
      });
    });

    group('Translation Quality', () {
      test('should have meaningful translations (not just key names)', () {
        final zhStrings = AppStrings.localizedValues['zh']!;
        final enStrings = AppStrings.localizedValues['en']!;

        // Check that translations are not just the key names
        expect(zhStrings['ai_analytics'], isNot(equals('ai_analytics')));
        expect(enStrings['ai_analytics'], isNot(equals('ai_analytics')));

        expect(zhStrings['sync_settings'], isNot(equals('sync_settings')));
        expect(enStrings['sync_settings'], isNot(equals('sync_settings')));

        expect(zhStrings['install_pwa'], isNot(equals('install_pwa')));
        expect(enStrings['install_pwa'], isNot(equals('install_pwa')));
      });

      test('should have appropriate length translations', () {
        final zhStrings = AppStrings.localizedValues['zh']!;
        final enStrings = AppStrings.localizedValues['en']!;

        // Check that translations are not too short (likely incomplete)
        expect(zhStrings['ai_analytics']!.length, greaterThan(2));
        expect(enStrings['ai_analytics']!.length, greaterThan(2));

        expect(zhStrings['pwa_install_prompt']!.length, greaterThan(5));
        expect(enStrings['pwa_install_prompt']!.length, greaterThan(5));

        // Check that translations are not excessively long
        expect(zhStrings['ai_analytics']!.length, lessThan(50));
        expect(enStrings['ai_analytics']!.length, lessThan(50));
      });
    });

    group('Basic AppStrings Functionality', () {
      test('should validate locale support correctly', () {
        expect(AppStrings.isLocaleSupported('zh'), isTrue);
        expect(AppStrings.isLocaleSupported('en'), isTrue);
        expect(AppStrings.isLocaleSupported('fr'), isFalse);
        expect(AppStrings.isLocaleSupported(''), isFalse);
      });

      test('should return correct supported locales list', () {
        final supportedLocales = AppStrings.supportedLocales;
        expect(supportedLocales, isA<List<String>>());
        expect(supportedLocales, contains('zh'));
        expect(supportedLocales, contains('en'));
        expect(supportedLocales.length, equals(2));
      });

      test('should have consistent key sets between languages', () {
        final zhStrings = AppStrings.localizedValues['zh']!;
        final enStrings = AppStrings.localizedValues['en']!;

        // Check that both languages have the same keys
        final zhKeys = zhStrings.keys.toSet();
        final enKeys = enStrings.keys.toSet();

        expect(
          zhKeys,
          equals(enKeys),
          reason: 'Chinese and English should have the same keys',
        );
      });
    });
  });
}
