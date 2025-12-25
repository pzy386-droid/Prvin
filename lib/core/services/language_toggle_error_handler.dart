import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prvin/core/bloc/app_bloc.dart';
import 'package:prvin/core/error/language_toggle_exceptions.dart';
import 'package:prvin/core/services/language_toggle_logger.dart';
import 'package:prvin/core/theme/app_theme.dart';
import 'package:prvin/core/widgets/app_dialog.dart';

/// 语言切换错误处理器
///
/// 提供统一的错误处理、用户反馈和错误恢复机制
class LanguageToggleErrorHandler {
  // 私有构造函数
  LanguageToggleErrorHandler._();

  /// 单例实例
  static final LanguageToggleErrorHandler _instance =
      LanguageToggleErrorHandler._();

  /// 获取单例实例
  static LanguageToggleErrorHandler get instance => _instance;

  /// 错误重试次数限制
  static const int _maxRetryAttempts = 3;

  /// 错误重试间隔
  static const Duration _retryDelay = Duration(milliseconds: 500);

  /// 处理语言切换错误
  ///
  /// [context] - BuildContext用于显示用户反馈
  /// [error] - 发生的错误
  /// [stackTrace] - 错误堆栈跟踪
  /// [fromLanguage] - 切换前的语言
  /// [toLanguage] - 目标语言
  /// [onRetry] - 重试回调函数
  static Future<void> handleError(
    BuildContext context,
    dynamic error, {
    StackTrace? stackTrace,
    String? fromLanguage,
    String? toLanguage,
    VoidCallback? onRetry,
  }) async {
    // 记录错误日志
    LanguageToggleLogger.logToggleError(
      error.toString(),
      stackTrace,
      fromLanguage: fromLanguage,
      toLanguage: toLanguage,
    );

    // 根据错误类型提供不同的处理策略
    if (error is LanguageToggleException) {
      await _handleLanguageToggleException(
        context,
        error,
        stackTrace: stackTrace,
        fromLanguage: fromLanguage,
        toLanguage: toLanguage,
        onRetry: onRetry,
      );
    } else {
      await _handleGenericError(
        context,
        error,
        stackTrace: stackTrace,
        onRetry: onRetry,
      );
    }
  }

  /// 处理语言切换特定异常
  static Future<void> _handleLanguageToggleException(
    BuildContext context,
    LanguageToggleException exception, {
    StackTrace? stackTrace,
    String? fromLanguage,
    String? toLanguage,
    VoidCallback? onRetry,
  }) async {
    if (exception is StateAccessException) {
      await _handleStateAccessError(context, exception, onRetry: onRetry);
    } else if (exception is PreferencesSaveException) {
      await _handlePreferencesSaveError(context, exception, onRetry: onRetry);
    } else if (exception is UnsupportedLanguageException) {
      await _handleUnsupportedLanguageError(context, exception);
    } else if (exception is AnimationException) {
      await _handleAnimationError(context, exception, onRetry: onRetry);
    } else if (exception is LanguageToggleTimeoutException) {
      await _handleTimeoutError(context, exception, onRetry: onRetry);
    } else {
      await _handleGenericError(context, exception, onRetry: onRetry);
    }
  }

  /// 处理BLoC状态访问错误
  static Future<void> _handleStateAccessError(
    BuildContext context,
    StateAccessException exception, {
    VoidCallback? onRetry,
  }) async {
    LanguageToggleLogger.logStateAccessError(
      exception.message,
      null,
      attemptedAction: 'language_toggle',
    );

    // 尝试恢复应用状态
    await _attemptStateRecovery(context);

    // 显示用户友好的错误提示
    if (context.mounted) {
      _showErrorSnackBar(
        context,
        '应用状态异常，正在尝试恢复...',
        severity: ErrorSeverity.warning,
        onRetry: onRetry,
      );
    }
  }

  /// 处理SharedPreferences保存错误
  static Future<void> _handlePreferencesSaveError(
    BuildContext context,
    PreferencesSaveException exception, {
    VoidCallback? onRetry,
  }) async {
    LanguageToggleLogger.logPreferencesSaveError(
      exception.message,
      null,
      key: 'app_language_code',
    );

    // 这种错误通常不影响当前会话，只是设置不会持久化
    if (context.mounted) {
      _showErrorSnackBar(
        context,
        '语言设置保存失败，重启应用后可能恢复到之前的语言',
        severity: ErrorSeverity.info,
        duration: const Duration(seconds: 4),
      );
    }
  }

  /// 处理不支持的语言错误
  static Future<void> _handleUnsupportedLanguageError(
    BuildContext context,
    UnsupportedLanguageException exception,
  ) async {
    LanguageToggleLogger.logWarning(
      'Attempted to switch to unsupported language: ${exception.language}',
    );

    if (context.mounted) {
      _showErrorSnackBar(
        context,
        '不支持的语言: ${exception.language}',
      );
    }
  }

  /// 处理动画错误
  static Future<void> _handleAnimationError(
    BuildContext context,
    AnimationException exception, {
    VoidCallback? onRetry,
  }) async {
    LanguageToggleLogger.logAnimationError(
      exception.message,
      null,
      animationType: 'language_toggle_animation',
    );

    // 动画错误通常不影响功能，只是视觉效果
    if (context.mounted) {
      _showErrorSnackBar(
        context,
        '动画效果异常，功能正常',
        severity: ErrorSeverity.info,
        duration: const Duration(seconds: 2),
      );
    }
  }

  /// 处理超时错误
  static Future<void> _handleTimeoutError(
    BuildContext context,
    LanguageToggleTimeoutException exception, {
    VoidCallback? onRetry,
  }) async {
    if (context.mounted) {
      _showErrorSnackBar(
        context,
        '语言切换超时，请重试',
        severity: ErrorSeverity.warning,
        onRetry: onRetry,
      );
    }
  }

  /// 处理通用错误
  static Future<void> _handleGenericError(
    BuildContext context,
    dynamic error, {
    StackTrace? stackTrace,
    VoidCallback? onRetry,
  }) async {
    final errorMessage = error.toString();

    if (context.mounted) {
      _showErrorSnackBar(
        context,
        '语言切换失败: $errorMessage',
        onRetry: onRetry,
      );
    }
  }

  /// 尝试恢复应用状态
  static Future<void> _attemptStateRecovery(BuildContext context) async {
    try {
      if (context.mounted) {
        final appBloc = context.read<AppBloc>();

        // 如果当前状态不是就绪状态，尝试重新初始化
        if (appBloc.state is! AppReadyState) {
          appBloc.add(const AppInitializeEvent());

          LanguageToggleLogger.logDebug(
            'Attempted state recovery by re-initializing app',
          );
        }
      }
    } catch (e) {
      LanguageToggleLogger.logWarning('State recovery attempt failed: $e');
    }
  }

  /// 显示错误提示条
  static void _showErrorSnackBar(
    BuildContext context,
    String message, {
    ErrorSeverity severity = ErrorSeverity.error,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onRetry,
  }) {
    if (!context.mounted) return;

    final colors = _getErrorColors(severity);
    final icon = _getErrorIcon(severity);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: colors.backgroundColor,
        behavior: SnackBarBehavior.floating,
        duration: duration,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
        ),
        action: onRetry != null
            ? SnackBarAction(
                label: '重试',
                textColor: Colors.white,
                onPressed: onRetry,
              )
            : null,
      ),
    );
  }

  /// 显示错误对话框（用于严重错误）
  static Future<void> showErrorDialog(
    BuildContext context,
    String title,
    String message, {
    VoidCallback? onRetry,
    VoidCallback? onCancel,
  }) async {
    if (!context.mounted) return;

    await DialogUtils.showError(
      context,
      title: title,
      message: message,
      buttonText: onRetry != null ? '重试' : '确定',
    );

    // 如果有重试回调，执行它
    if (onRetry != null) {
      onRetry();
    }
  }

  /// 带重试机制的错误处理
  static Future<T?> withRetry<T>(
    Future<T> Function() operation, {
    int maxAttempts = _maxRetryAttempts,
    Duration delay = _retryDelay,
    bool Function(dynamic error)? shouldRetry,
  }) async {
    var attempts = 0;

    while (attempts < maxAttempts) {
      try {
        attempts++;
        final result = await operation();

        if (attempts > 1) {
          LanguageToggleLogger.logDebug(
            'Operation succeeded after $attempts attempts',
          );
        }

        return result;
      } catch (error, stackTrace) {
        final isLastAttempt = attempts >= maxAttempts;
        final shouldRetryError = shouldRetry?.call(error) ?? true;

        if (isLastAttempt || !shouldRetryError) {
          LanguageToggleLogger.logToggleError(
            'Operation failed after $attempts attempts: $error',
            stackTrace,
          );
          rethrow;
        }

        LanguageToggleLogger.logWarning(
          'Operation failed (attempt $attempts/$maxAttempts), retrying in ${delay.inMilliseconds}ms: $error',
        );

        await Future.delayed(delay);
      }
    }

    return null;
  }

  /// 获取错误颜色配置
  static _ErrorColors _getErrorColors(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.info:
        return const _ErrorColors(
          backgroundColor: AppTheme.infoColor,
          textColor: Colors.white,
        );
      case ErrorSeverity.warning:
        return const _ErrorColors(
          backgroundColor: AppTheme.warningColor,
          textColor: Colors.white,
        );
      case ErrorSeverity.error:
        return const _ErrorColors(
          backgroundColor: AppTheme.errorColor,
          textColor: Colors.white,
        );
    }
  }

  /// 获取错误图标
  static IconData _getErrorIcon(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.info:
        return Icons.info_outline;
      case ErrorSeverity.warning:
        return Icons.warning_amber_outlined;
      case ErrorSeverity.error:
        return Icons.error_outline;
    }
  }
}

/// 错误严重程度枚举
enum ErrorSeverity {
  /// 信息提示
  info,

  /// 警告
  warning,

  /// 错误
  error,
}

/// 错误颜色配置
class _ErrorColors {
  const _ErrorColors({required this.backgroundColor, required this.textColor});

  final Color backgroundColor;
  final Color textColor;
}
