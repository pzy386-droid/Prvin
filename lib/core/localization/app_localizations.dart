import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prvin/core/bloc/app_bloc.dart';
import 'package:prvin/core/error/language_toggle_exceptions.dart';
import 'package:prvin/core/localization/app_strings.dart';
import 'package:prvin/core/services/language_toggle_error_handler.dart';
import 'package:prvin/core/services/language_toggle_logger.dart';

/// 应用本地化服务
///
/// 提供简单、高效的字符串本地化功能
/// 支持运行时语言切换，具有完善的fallback机制
class AppLocalizations {
  // 私有构造函数
  AppLocalizations._();

  /// 当前语言代码缓存
  static String? _currentLocale;

  /// 获取本地化字符串
  ///
  /// [key] 字符串键值
  /// [fallback] 可选的fallback文本，如果未找到对应翻译则使用此文本
  /// [context] 可选的BuildContext，用于获取当前语言设置
  ///
  /// 返回本地化后的字符串，如果未找到则返回fallback或key本身
  static String get(String key, {String? fallback, BuildContext? context}) {
    final locale = _getCurrentLocale(context);
    final localizedMap = AppStrings.localizedValues[locale];

    // 尝试获取本地化字符串
    final localizedString = localizedMap?[key];
    if (localizedString != null && localizedString.isNotEmpty) {
      return localizedString;
    }

    // 如果当前语言没有找到，尝试使用中文作为fallback
    if (locale != 'zh') {
      final chineseMap = AppStrings.localizedValues['zh'];
      final chineseString = chineseMap?[key];
      if (chineseString != null && chineseString.isNotEmpty) {
        return chineseString;
      }
    }

    // 最后使用提供的fallback或key本身
    return fallback ?? key;
  }

  /// 获取当前语言代码
  ///
  /// 优先级：
  /// 1. 从BuildContext中的AppBloc获取
  /// 2. 使用缓存的语言代码
  /// 3. 默认使用中文
  static String _getCurrentLocale([BuildContext? context]) {
    // 尝试从BLoC获取当前语言
    if (context != null) {
      try {
        final appState = context.read<AppBloc>().state;
        if (appState is AppReadyState) {
          final locale = appState.languageCode;
          if (AppStrings.isLocaleSupported(locale)) {
            _currentLocale = locale;
            return locale;
          }
        }
      } catch (e) {
        // 如果获取失败，继续使用其他方式
      }
    }

    // 使用缓存的语言代码
    if (_currentLocale != null &&
        AppStrings.isLocaleSupported(_currentLocale!)) {
      return _currentLocale!;
    }

    // 默认使用中文
    _currentLocale = 'zh';
    return 'zh';
  }

  /// 设置当前语言代码（用于缓存）
  static void setCurrentLocale(String locale) {
    if (AppStrings.isLocaleSupported(locale)) {
      _currentLocale = locale;
    }
  }

  /// 获取支持的语言列表
  static List<String> get supportedLocales => AppStrings.supportedLocales;

  /// 检查是否支持指定语言
  static bool isLocaleSupported(String locale) =>
      AppStrings.isLocaleSupported(locale);

  /// 获取语言显示名称
  static String getLanguageDisplayName(String locale) {
    switch (locale) {
      case 'zh':
        return '中文';
      case 'en':
        return 'English';
      default:
        return locale.toUpperCase();
    }
  }

  /// 切换语言（通过BLoC）
  static void changeLanguage(BuildContext context, String locale) {
    if (AppStrings.isLocaleSupported(locale)) {
      context.read<AppBloc>().add(AppLanguageChangedEvent(locale));
      setCurrentLocale(locale);
    }
  }

  /// 带错误处理的语言切换
  static Future<void> changeLanguageWithErrorHandling(
    BuildContext context,
    String locale,
  ) async {
    try {
      if (!AppStrings.isLocaleSupported(locale)) {
        throw UnsupportedLanguageException(locale);
      }

      // 使用重试机制执行语言切换
      await LanguageToggleErrorHandler.withRetry(
        () async {
          context.read<AppBloc>().add(AppLanguageChangedEvent(locale));

          // 等待状态更新
          await Future.delayed(const Duration(milliseconds: 50));

          // 验证切换是否成功
          final newState = context.read<AppBloc>().state;
          if (newState is AppReadyState && newState.languageCode == locale) {
            LanguageToggleLogger.logDebug(
              'Language change verified successfully',
            );
          } else {
            throw StateAccessException(
              'Language change verification failed: expected $locale, got ${newState is AppReadyState ? newState.languageCode : 'unknown'}',
            );
          }
        },
        maxAttempts: 2,
        shouldRetry: (error) => error is StateAccessException,
      );
    } catch (e, stackTrace) {
      LanguageToggleLogger.logToggleError(
        'Language change failed: $e',
        stackTrace,
        toLanguage: locale,
      );
      rethrow;
    }
  }

  /// 一键切换语言（在支持的语言之间循环切换）
  static void toggleLanguage(BuildContext context) {
    final currentLocale = _getCurrentLocale(context);
    final supportedLocales = AppStrings.supportedLocales;

    // 找到当前语言在支持列表中的索引
    final currentIndex = supportedLocales.indexOf(currentLocale);

    // 计算下一个语言的索引（循环）
    final nextIndex = (currentIndex + 1) % supportedLocales.length;
    final nextLocale = supportedLocales[nextIndex];

    // 切换到下一个语言
    changeLanguage(context, nextLocale);
  }
}

/// BuildContext扩展，提供便捷的本地化方法
extension LocalizationExtension on BuildContext {
  /// 获取本地化字符串的便捷方法
  ///
  /// 使用方式：context.l10n('key', fallback: 'fallback text')
  String l10n(String key, {String? fallback}) {
    return AppLocalizations.get(key, fallback: fallback, context: this);
  }

  /// 获取当前语言代码
  String get currentLocale {
    try {
      final appState = read<AppBloc>().state;
      if (appState is AppReadyState) {
        return appState.languageCode;
      }
    } catch (e) {
      // 如果获取失败，返回默认语言
    }
    return 'zh';
  }

  /// 切换语言的便捷方法
  void changeLanguage(String locale) {
    AppLocalizations.changeLanguage(this, locale);
  }

  /// 一键切换语言的便捷方法
  void toggleLanguage() {
    AppLocalizations.toggleLanguage(this);
  }

  /// 获取下一个语言的显示名称
  String get nextLanguageDisplay {
    final currentLocale = this.currentLocale;
    final supportedLocales = AppLocalizations.supportedLocales;

    // 找到当前语言在支持列表中的索引
    final currentIndex = supportedLocales.indexOf(currentLocale);

    // 计算下一个语言的索引（循环）
    final nextIndex = (currentIndex + 1) % supportedLocales.length;
    final nextLocale = supportedLocales[nextIndex];

    // 返回下一个语言的简短显示标识
    switch (nextLocale) {
      case 'zh':
        return '中';
      case 'en':
        return 'EN';
      default:
        return nextLocale.toUpperCase();
    }
  }
}
