import 'package:flutter/material.dart';

// 设备类型枚举
enum DeviceType { mobile, tablet, desktop }

/// 响应式设计主题配置
/// 提供跨设备的响应式布局和样式支持
class ResponsiveTheme {
  // 设备断点定义
  /// 移动设备断点 (< 600px)
  static const double mobileBreakpoint = 600;

  /// 平板设备断点 (600px - 1200px)
  static const double tabletBreakpoint = 1200;

  /// 桌面设备断点 (> 1200px)
  static const double desktopBreakpoint = 1200;

  /// 获取当前设备类型
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width < mobileBreakpoint) {
      return DeviceType.mobile;
    } else if (width < desktopBreakpoint) {
      return DeviceType.tablet;
    } else {
      return DeviceType.desktop;
    }
  }

  /// 判断是否为移动设备
  static bool isMobile(BuildContext context) {
    return getDeviceType(context) == DeviceType.mobile;
  }

  /// 判断是否为平板设备
  static bool isTablet(BuildContext context) {
    return getDeviceType(context) == DeviceType.tablet;
  }

  /// 判断是否为桌面设备
  static bool isDesktop(BuildContext context) {
    return getDeviceType(context) == DeviceType.desktop;
  }

  // 响应式间距配置
  /// 获取响应式间距
  static double getResponsiveSpacing(BuildContext context) {
    switch (getDeviceType(context)) {
      case DeviceType.mobile:
        return 16;
      case DeviceType.tablet:
        return 24;
      case DeviceType.desktop:
        return 32;
    }
  }

  /// 获取响应式内边距
  static EdgeInsets getResponsivePadding(BuildContext context) {
    final spacing = getResponsiveSpacing(context);
    return EdgeInsets.all(spacing);
  }

  /// 获取响应式水平内边距
  static EdgeInsets getResponsiveHorizontalPadding(BuildContext context) {
    final spacing = getResponsiveSpacing(context);
    return EdgeInsets.symmetric(horizontal: spacing);
  }

  /// 获取响应式垂直内边距
  static EdgeInsets getResponsiveVerticalPadding(BuildContext context) {
    final spacing = getResponsiveSpacing(context);
    return EdgeInsets.symmetric(vertical: spacing);
  }

  // 响应式字体大小配置
  /// 获取响应式标题字体大小
  static double getResponsiveTitleFontSize(BuildContext context) {
    switch (getDeviceType(context)) {
      case DeviceType.mobile:
        return 24;
      case DeviceType.tablet:
        return 28;
      case DeviceType.desktop:
        return 32;
    }
  }

  /// 获取响应式副标题字体大小
  static double getResponsiveSubtitleFontSize(BuildContext context) {
    switch (getDeviceType(context)) {
      case DeviceType.mobile:
        return 18;
      case DeviceType.tablet:
        return 20;
      case DeviceType.desktop:
        return 22;
    }
  }

  /// 获取响应式正文字体大小
  static double getResponsiveBodyFontSize(BuildContext context) {
    switch (getDeviceType(context)) {
      case DeviceType.mobile:
        return 14;
      case DeviceType.tablet:
        return 16;
      case DeviceType.desktop:
        return 16;
    }
  }

  /// 获取响应式小字体大小
  static double getResponsiveCaptionFontSize(BuildContext context) {
    switch (getDeviceType(context)) {
      case DeviceType.mobile:
        return 12;
      case DeviceType.tablet:
        return 13;
      case DeviceType.desktop:
        return 14;
    }
  }

  // 响应式布局配置
  /// 获取日历网格的列数
  static int getCalendarGridColumns(BuildContext context) {
    switch (getDeviceType(context)) {
      case DeviceType.mobile:
        return 7; // 标准周视图
      case DeviceType.tablet:
        return 7; // 标准周视图
      case DeviceType.desktop:
        return 7; // 标准周视图，但可以显示更多信息
    }
  }

  /// 获取任务列表的交叉轴数量
  static int getTaskListCrossAxisCount(BuildContext context) {
    switch (getDeviceType(context)) {
      case DeviceType.mobile:
        return 1; // 单列
      case DeviceType.tablet:
        return 2; // 双列
      case DeviceType.desktop:
        return 3; // 三列
    }
  }

  /// 获取响应式卡片宽度
  static double getResponsiveCardWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    switch (getDeviceType(context)) {
      case DeviceType.mobile:
        return screenWidth - 32; // 留出边距
      case DeviceType.tablet:
        return (screenWidth - 64) / 2; // 双列布局
      case DeviceType.desktop:
        return (screenWidth - 96) / 3; // 三列布局
    }
  }

  /// 获取响应式最大内容宽度
  static double getResponsiveMaxContentWidth(BuildContext context) {
    switch (getDeviceType(context)) {
      case DeviceType.mobile:
        return double.infinity;
      case DeviceType.tablet:
        return 800;
      case DeviceType.desktop:
        return 1200;
    }
  }

  // 响应式圆角配置
  /// 获取响应式圆角半径
  static double getResponsiveBorderRadius(BuildContext context) {
    switch (getDeviceType(context)) {
      case DeviceType.mobile:
        return 12;
      case DeviceType.tablet:
        return 16;
      case DeviceType.desktop:
        return 20;
    }
  }

  // 响应式阴影配置
  /// 获取响应式阴影
  static List<BoxShadow> getResponsiveShadow(BuildContext context) {
    switch (getDeviceType(context)) {
      case DeviceType.mobile:
        return [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ];
      case DeviceType.tablet:
        return [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ];
      case DeviceType.desktop:
        return [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ];
    }
  }

  // 响应式动画配置
  /// 获取响应式动画时长
  static Duration getResponsiveAnimationDuration(BuildContext context) {
    switch (getDeviceType(context)) {
      case DeviceType.mobile:
        return const Duration(milliseconds: 200); // 移动设备使用较快的动画
      case DeviceType.tablet:
        return const Duration(milliseconds: 300); // 平板使用中等速度
      case DeviceType.desktop:
        return const Duration(milliseconds: 400); // 桌面使用较慢的动画
    }
  }

  // 响应式布局辅助方法
  /// 根据设备类型返回不同的值
  static T responsive<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    switch (getDeviceType(context)) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return tablet ?? mobile;
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile;
    }
  }

  /// 创建响应式文本样式
  static TextStyle createResponsiveTextStyle(
    BuildContext context, {
    required double baseFontSize,
    FontWeight? fontWeight,
    Color? color,
  }) {
    final deviceType = getDeviceType(context);
    double scaleFactor;

    switch (deviceType) {
      case DeviceType.mobile:
        scaleFactor = 1.0;
      case DeviceType.tablet:
        scaleFactor = 1.1;
      case DeviceType.desktop:
        scaleFactor = 1.2;
    }

    return TextStyle(
      fontSize: baseFontSize * scaleFactor,
      fontWeight: fontWeight,
      color: color,
    );
  }

  /// 创建响应式容器
  static Widget createResponsiveContainer({
    required BuildContext context,
    required Widget child,
    EdgeInsets? padding,
    EdgeInsets? margin,
    BoxDecoration? decoration,
  }) {
    return Container(
      padding: padding ?? getResponsivePadding(context),
      margin: margin,
      decoration: decoration?.copyWith(
        borderRadius: BorderRadius.circular(getResponsiveBorderRadius(context)),
        boxShadow: decoration.boxShadow ?? getResponsiveShadow(context),
      ),
      constraints: BoxConstraints(
        maxWidth: getResponsiveMaxContentWidth(context),
      ),
      child: child,
    );
  }

  /// 创建响应式网格视图
  static Widget createResponsiveGridView({
    required BuildContext context,
    required List<Widget> children,
    double? childAspectRatio,
    double? mainAxisSpacing,
    double? crossAxisSpacing,
  }) {
    final crossAxisCount = getTaskListCrossAxisCount(context);
    final spacing = getResponsiveSpacing(context) / 2;

    return GridView.count(
      crossAxisCount: crossAxisCount,
      childAspectRatio: childAspectRatio ?? 1.0,
      mainAxisSpacing: mainAxisSpacing ?? spacing,
      crossAxisSpacing: crossAxisSpacing ?? spacing,
      padding: getResponsivePadding(context),
      children: children,
    );
  }
}
