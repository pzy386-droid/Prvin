import 'package:flutter/material.dart';
import 'package:prvin/core/theme/theme_exports.dart';

/// 按钮类型枚举
enum AppButtonType {
  /// 主要按钮
  primary,

  /// 次要按钮
  secondary,

  /// 文本按钮
  text,

  /// 轮廓按钮
  outline,

  /// 危险按钮
  danger,
}

/// 按钮尺寸枚举
enum AppButtonSize {
  /// 小尺寸
  small,

  /// 中等尺寸
  medium,

  /// 大尺寸
  large,
}

/// 应用按钮组件
class AppButton extends StatelessWidget {
  /// 创建应用按钮
  const AppButton({
    required this.text,
    required this.onPressed,
    super.key,
    this.type = AppButtonType.primary,
    this.size = AppButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isDisabled = false,
    this.width,
    this.height,
    this.borderRadius,
    this.backgroundColor,
    this.foregroundColor,
    this.animateOnTap = true,
  });

  /// 按钮文本
  final String text;

  /// 点击回调
  final VoidCallback? onPressed;

  /// 按钮类型
  final AppButtonType type;

  /// 按钮尺寸
  final AppButtonSize size;

  /// 图标
  final IconData? icon;

  /// 是否加载中
  final bool isLoading;

  /// 是否禁用
  final bool isDisabled;

  /// 宽度
  final double? width;

  /// 高度
  final double? height;

  /// 圆角半径
  final BorderRadius? borderRadius;

  /// 背景色
  final Color? backgroundColor;

  /// 前景色
  final Color? foregroundColor;

  /// 点击时是否显示动画
  final bool animateOnTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEnabled = !isDisabled && !isLoading && onPressed != null;

    final buttonStyle = _getButtonStyle(theme);
    final buttonChild = _buildButtonChild(theme);

    Widget button;

    switch (type) {
      case AppButtonType.primary:
        button = ElevatedButton(
          onPressed: isEnabled ? onPressed : null,
          style: buttonStyle,
          child: buttonChild,
        );
      case AppButtonType.secondary:
        button = ElevatedButton(
          onPressed: isEnabled ? onPressed : null,
          style: buttonStyle,
          child: buttonChild,
        );
      case AppButtonType.text:
        button = TextButton(
          onPressed: isEnabled ? onPressed : null,
          style: buttonStyle,
          child: buttonChild,
        );
      case AppButtonType.outline:
        button = OutlinedButton(
          onPressed: isEnabled ? onPressed : null,
          style: buttonStyle,
          child: buttonChild,
        );
      case AppButtonType.danger:
        button = ElevatedButton(
          onPressed: isEnabled ? onPressed : null,
          style: buttonStyle,
          child: buttonChild,
        );
    }

    if (width != null || height != null) {
      button = SizedBox(width: width, height: height, child: button);
    }

    if (animateOnTap && isEnabled) {
      button = MicroInteractions.createElasticButton(
        onPressed: onPressed!,
        child: button,
      );
    }

    return button;
  }

  ButtonStyle _getButtonStyle(ThemeData theme) {
    final padding = _getPadding();
    final borderRadius =
        this.borderRadius ?? BorderRadius.circular(AppTheme.radiusM);

    switch (type) {
      case AppButtonType.primary:
        return ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppTheme.primaryColor,
          foregroundColor: foregroundColor ?? Colors.white,
          padding: padding,
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
          elevation: 0,
          shadowColor: Colors.transparent,
        );

      case AppButtonType.secondary:
        return ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? Colors.grey.shade100,
          foregroundColor: foregroundColor ?? Colors.grey.shade700,
          padding: padding,
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
          elevation: 0,
          shadowColor: Colors.transparent,
        );

      case AppButtonType.text:
        return TextButton.styleFrom(
          foregroundColor: foregroundColor ?? AppTheme.primaryColor,
          padding: padding,
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
        );

      case AppButtonType.outline:
        return OutlinedButton.styleFrom(
          foregroundColor: foregroundColor ?? AppTheme.primaryColor,
          padding: padding,
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
          side: BorderSide(
            color: backgroundColor ?? AppTheme.primaryColor,
            width: 1.5,
          ),
        );

      case AppButtonType.danger:
        return ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppTheme.errorColor,
          foregroundColor: foregroundColor ?? Colors.white,
          padding: padding,
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
          elevation: 0,
          shadowColor: Colors.transparent,
        );
    }
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case AppButtonSize.small:
        return const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingM,
          vertical: AppTheme.spacingS,
        );
      case AppButtonSize.medium:
        return const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingL,
          vertical: AppTheme.spacingM,
        );
      case AppButtonSize.large:
        return const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingXL,
          vertical: AppTheme.spacingL,
        );
    }
  }

  Widget _buildButtonChild(ThemeData theme) {
    if (isLoading) {
      return SizedBox(
        width: _getIconSize(),
        height: _getIconSize(),
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            foregroundColor ?? _getDefaultForegroundColor(theme),
          ),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: _getIconSize()),
          const SizedBox(width: AppTheme.spacingS),
          Text(text, style: _getTextStyle()),
        ],
      );
    }

    return Text(text, style: _getTextStyle());
  }

  double _getIconSize() {
    switch (size) {
      case AppButtonSize.small:
        return 16;
      case AppButtonSize.medium:
        return 20;
      case AppButtonSize.large:
        return 24;
    }
  }

  TextStyle? _getTextStyle() {
    switch (size) {
      case AppButtonSize.small:
        return const TextStyle(fontSize: 14, fontWeight: FontWeight.w600);
      case AppButtonSize.medium:
        return const TextStyle(fontSize: 16, fontWeight: FontWeight.w600);
      case AppButtonSize.large:
        return const TextStyle(fontSize: 18, fontWeight: FontWeight.w600);
    }
  }

  Color _getDefaultForegroundColor(ThemeData theme) {
    switch (type) {
      case AppButtonType.primary:
      case AppButtonType.danger:
        return Colors.white;
      case AppButtonType.secondary:
        return Colors.grey.shade700;
      case AppButtonType.text:
      case AppButtonType.outline:
        return AppTheme.primaryColor;
    }
  }
}

/// 浮动操作按钮组件
class AppFloatingActionButton extends StatelessWidget {
  /// 创建浮动操作按钮
  const AppFloatingActionButton({
    required this.onPressed,
    required this.icon,
    super.key,
    this.backgroundColor,
    this.foregroundColor,
    this.size = AppButtonSize.medium,
    this.heroTag,
  });

  /// 点击回调
  final VoidCallback? onPressed;

  /// 图标
  final IconData icon;

  /// 背景色
  final Color? backgroundColor;

  /// 前景色
  final Color? foregroundColor;

  /// 尺寸
  final AppButtonSize size;

  /// Hero标签
  final Object? heroTag;

  @override
  Widget build(BuildContext context) {
    final fabSize = _getFabSize();

    return SizedBox(
      width: fabSize,
      height: fabSize,
      child: FloatingActionButton(
        onPressed: onPressed,
        backgroundColor: backgroundColor ?? AppTheme.primaryColor,
        foregroundColor: foregroundColor ?? Colors.white,
        elevation: 4,
        heroTag: heroTag,
        child: Icon(icon, size: _getIconSize()),
      ),
    );
  }

  double _getFabSize() {
    switch (size) {
      case AppButtonSize.small:
        return 48;
      case AppButtonSize.medium:
        return 56;
      case AppButtonSize.large:
        return 64;
    }
  }

  double _getIconSize() {
    switch (size) {
      case AppButtonSize.small:
        return 20;
      case AppButtonSize.medium:
        return 24;
      case AppButtonSize.large:
        return 28;
    }
  }
}
