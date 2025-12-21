import 'package:flutter/material.dart';
import 'package:prvin/core/theme/theme_exports.dart';
import 'package:prvin/core/widgets/app_button.dart';
import 'package:prvin/core/widgets/app_lottie.dart';

/// 对话框类型枚举
enum AppDialogType {
  /// 信息对话框
  info,

  /// 成功对话框
  success,

  /// 警告对话框
  warning,

  /// 错误对话框
  error,

  /// 确认对话框
  confirm,

  /// 自定义对话框
  custom,
}

/// 应用对话框组件
class AppDialog extends StatelessWidget {
  /// 创建应用对话框
  const AppDialog({
    required this.title,
    super.key,
    this.content,
    this.type = AppDialogType.info,
    this.icon,
    this.primaryButtonText,
    this.secondaryButtonText,
    this.onPrimaryPressed,
    this.onSecondaryPressed,
    this.showCloseButton = true,
    this.barrierDismissible = true,
    this.width,
    this.height,
    this.padding,
    this.animationType = DialogAnimationType.scale,
  });

  /// 标题
  final String title;

  /// 内容
  final Widget? content;

  /// 对话框类型
  final AppDialogType type;

  /// 自定义图标
  final IconData? icon;

  /// 主按钮文本
  final String? primaryButtonText;

  /// 次按钮文本
  final String? secondaryButtonText;

  /// 主按钮回调
  final VoidCallback? onPrimaryPressed;

  /// 次按钮回调
  final VoidCallback? onSecondaryPressed;

  /// 是否显示关闭按钮
  final bool showCloseButton;

  /// 是否可以点击背景关闭
  final bool barrierDismissible;

  /// 宽度
  final double? width;

  /// 高度
  final double? height;

  /// 内边距
  final EdgeInsets? padding;

  /// 动画类型
  final DialogAnimationType animationType;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: _buildDialogContent(context),
    );
  }

  Widget _buildDialogContent(BuildContext context) {
    final theme = Theme.of(context);

    return MicroInteractions.createFadeInWidget(
      child: MicroInteractions.createSlideInWidget(
        beginOffset: _getSlideOffset(),
        child: Container(
          width: width,
          height: height,
          constraints: BoxConstraints(
            maxWidth:
                ResponsiveTheme.getResponsiveMaxContentWidth(context) * 0.9,
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          padding: padding ?? const EdgeInsets.all(AppTheme.spacingL),
          decoration: BoxDecoration(
            color: theme.dialogBackgroundColor,
            borderRadius: BorderRadius.circular(
              ResponsiveTheme.getResponsiveBorderRadius(context),
            ),
            boxShadow: ResponsiveTheme.getResponsiveShadow(context),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 标题栏
              _buildHeader(context),

              // 内容区域
              if (content != null) ...[
                const SizedBox(height: AppTheme.spacingM),
                Flexible(child: content!),
              ],

              // 按钮区域
              if (_hasButtons()) ...[
                const SizedBox(height: AppTheme.spacingL),
                _buildButtons(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        // 图标
        if (_getDialogIcon() != null) ...[
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getDialogColor().withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(_getDialogIcon(), color: _getDialogColor(), size: 24),
          ),
          const SizedBox(width: AppTheme.spacingM),
        ],

        // 标题
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: _getDialogColor(),
            ),
          ),
        ),

        // 关闭按钮
        if (showCloseButton)
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
            iconSize: 20,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
      ],
    );
  }

  Widget _buildButtons(BuildContext context) {
    final buttons = <Widget>[];

    if (secondaryButtonText != null) {
      buttons.add(
        Expanded(
          child: AppButton(
            text: secondaryButtonText!,
            onPressed: onSecondaryPressed ?? () => Navigator.of(context).pop(),
            type: AppButtonType.outline,
          ),
        ),
      );
    }

    if (primaryButtonText != null) {
      if (buttons.isNotEmpty) {
        buttons.add(const SizedBox(width: AppTheme.spacingM));
      }

      buttons.add(
        Expanded(
          child: AppButton(
            text: primaryButtonText!,
            onPressed: onPrimaryPressed ?? () => Navigator.of(context).pop(),
            type: _getPrimaryButtonType(),
          ),
        ),
      );
    }

    return Row(children: buttons);
  }

  bool _hasButtons() {
    return primaryButtonText != null || secondaryButtonText != null;
  }

  IconData? _getDialogIcon() {
    if (icon != null) return icon;

    switch (type) {
      case AppDialogType.info:
        return Icons.info_outline;
      case AppDialogType.success:
        return Icons.check_circle_outline;
      case AppDialogType.warning:
        return Icons.warning_amber_outlined;
      case AppDialogType.error:
        return Icons.error_outline;
      case AppDialogType.confirm:
        return Icons.help_outline;
      case AppDialogType.custom:
        return null;
    }
  }

  Color _getDialogColor() {
    switch (type) {
      case AppDialogType.info:
        return AppTheme.infoColor;
      case AppDialogType.success:
        return AppTheme.successColor;
      case AppDialogType.warning:
        return AppTheme.warningColor;
      case AppDialogType.error:
        return AppTheme.errorColor;
      case AppDialogType.confirm:
        return AppTheme.primaryColor;
      case AppDialogType.custom:
        return AppTheme.primaryColor;
    }
  }

  AppButtonType _getPrimaryButtonType() {
    switch (type) {
      case AppDialogType.error:
        return AppButtonType.danger;
      case AppDialogType.warning:
        return AppButtonType.outline;
      default:
        return AppButtonType.primary;
    }
  }

  Offset _getSlideOffset() {
    switch (animationType) {
      case DialogAnimationType.slideFromTop:
        return const Offset(0, -1);
      case DialogAnimationType.slideFromBottom:
        return const Offset(0, 1);
      case DialogAnimationType.slideFromLeft:
        return const Offset(-1, 0);
      case DialogAnimationType.slideFromRight:
        return const Offset(1, 0);
      case DialogAnimationType.scale:
      case DialogAnimationType.fade:
        return Offset.zero;
    }
  }
}

/// 对话框动画类型枚举
enum DialogAnimationType {
  /// 缩放动画
  scale,

  /// 淡入动画
  fade,

  /// 从顶部滑入
  slideFromTop,

  /// 从底部滑入
  slideFromBottom,

  /// 从左侧滑入
  slideFromLeft,

  /// 从右侧滑入
  slideFromRight,
}

/// 加载对话框组件
class LoadingDialog extends StatelessWidget {
  /// 创建加载对话框
  const LoadingDialog({
    required this.message,
    super.key,
    this.showProgress = false,
    this.progress = 0.0,
  });

  /// 加载消息
  final String message;

  /// 是否显示进度
  final bool showProgress;

  /// 进度值
  final double progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        decoration: BoxDecoration(
          color: theme.dialogBackgroundColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusL),
          boxShadow: AppTheme.mediumShadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SimpleLottie.loading(),
            const SizedBox(height: AppTheme.spacingM),
            Text(
              message,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            if (showProgress) ...[
              const SizedBox(height: AppTheme.spacingM),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.2),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: AppTheme.spacingS),
              Text(
                '${(progress * 100).toInt()}%',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 对话框工具类
class DialogUtils {
  /// 显示信息对话框
  static Future<bool?> showInfo(
    BuildContext context, {
    required String title,
    required String message,
    String? buttonText,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AppDialog(
        title: title,
        content: Text(message),
        primaryButtonText: buttonText ?? '确定',
      ),
    );
  }

  /// 显示成功对话框
  static Future<bool?> showSuccess(
    BuildContext context, {
    required String title,
    required String message,
    String? buttonText,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AppDialog(
        title: title,
        type: AppDialogType.success,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SimpleLottie.success(),
            const SizedBox(height: AppTheme.spacingM),
            Text(message),
          ],
        ),
        primaryButtonText: buttonText ?? '确定',
      ),
    );
  }

  /// 显示错误对话框
  static Future<bool?> showError(
    BuildContext context, {
    required String title,
    required String message,
    String? buttonText,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AppDialog(
        title: title,
        type: AppDialogType.error,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SimpleLottie.error(),
            const SizedBox(height: AppTheme.spacingM),
            Text(message),
          ],
        ),
        primaryButtonText: buttonText ?? '确定',
      ),
    );
  }

  /// 显示确认对话框
  static Future<bool?> showConfirm(
    BuildContext context, {
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AppDialog(
        title: title,
        type: AppDialogType.confirm,
        content: Text(message),
        primaryButtonText: confirmText ?? '确定',
        secondaryButtonText: cancelText ?? '取消',
        onPrimaryPressed: () => Navigator.of(context).pop(true),
        onSecondaryPressed: () => Navigator.of(context).pop(false),
      ),
    );
  }

  /// 显示加载对话框
  static Future<T?> showLoading<T>(
    BuildContext context, {
    required String message,
    bool showProgress = false,
    double progress = 0.0,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: false,
      builder: (context) => LoadingDialog(
        message: message,
        showProgress: showProgress,
        progress: progress,
      ),
    );
  }

  /// 显示底部弹出对话框
  static Future<T?> showBottomSheet<T>(
    BuildContext context, {
    required Widget child,
    bool isScrollControlled = false,
    bool isDismissible = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppTheme.radiusL),
          ),
        ),
        child: child,
      ),
    );
  }
}
