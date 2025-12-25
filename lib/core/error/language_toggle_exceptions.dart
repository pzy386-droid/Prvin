import 'package:prvin/core/error/failures.dart';

/// 语言切换相关异常基类
abstract class LanguageToggleException implements Exception {
  const LanguageToggleException(this.message, [this.cause]);

  /// 错误消息
  final String message;

  /// 原始异常（如果有）
  final dynamic cause;

  @override
  String toString() {
    if (cause != null) {
      return 'LanguageToggleException: $message (caused by: $cause)';
    }
    return 'LanguageToggleException: $message';
  }
}

/// BLoC状态访问失败异常
class StateAccessException extends LanguageToggleException {
  const StateAccessException([String? message, dynamic cause])
    : super(message ?? 'Failed to access app state', cause);
}

/// SharedPreferences保存失败异常
class PreferencesSaveException extends LanguageToggleException {
  const PreferencesSaveException([String? message, dynamic cause])
    : super(message ?? 'Failed to save language preference', cause);
}

/// 不支持的语言异常
class UnsupportedLanguageException extends LanguageToggleException {
  const UnsupportedLanguageException(String language, [dynamic cause])
    : super('Unsupported language: $language', cause);

  /// 不支持的语言代码
  String get language => message.split(': ')[1];
}

/// 动画执行异常
class AnimationException extends LanguageToggleException {
  const AnimationException([String? message, dynamic cause])
    : super(message ?? 'Animation execution failed', cause);
}

/// 语言切换超时异常
class LanguageToggleTimeoutException extends LanguageToggleException {
  const LanguageToggleTimeoutException([String? message, dynamic cause])
    : super(message ?? 'Language toggle operation timed out', cause);
}

/// 语言切换失败类（用于Result模式）
class LanguageToggleFailure extends Failure {
  const LanguageToggleFailure([super.message]);
}

/// BLoC状态访问失败类
class StateAccessFailure extends LanguageToggleFailure {
  const StateAccessFailure([super.message]);
}

/// SharedPreferences保存失败类
class PreferencesSaveFailure extends LanguageToggleFailure {
  const PreferencesSaveFailure([super.message]);
}

/// 不支持的语言失败类
class UnsupportedLanguageFailure extends LanguageToggleFailure {
  const UnsupportedLanguageFailure([super.message]);
}

/// 动画执行失败类
class AnimationFailure extends LanguageToggleFailure {
  const AnimationFailure([super.message]);
}
