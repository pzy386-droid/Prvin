import 'package:flutter/material.dart';
import 'package:prvin/core/theme/app_theme.dart';

/// 响应式布局工具类
class ResponsiveLayout extends StatelessWidget {
  /// 创建响应式布局
  const ResponsiveLayout({
    required this.mobile, super.key,
    this.tablet,
    this.desktop,
  });

  /// 移动端布局
  final Widget mobile;

  /// 平板端布局（可选，默认使用移动端布局）
  final Widget? tablet;

  /// 桌面端布局（可选，默认使用平板端或移动端布局）
  final Widget? desktop;

  @override
  Widget build(BuildContext context) {
    if (AppTheme.isDesktop(context)) {
      return desktop ?? tablet ?? mobile;
    } else if (AppTheme.isTablet(context)) {
      return tablet ?? mobile;
    } else {
      return mobile;
    }
  }
}

/// 响应式值工具类
class ResponsiveValue<T> {
  /// 创建响应式值
  const ResponsiveValue({required this.mobile, this.tablet, this.desktop});

  /// 移动端值
  final T mobile;

  /// 平板端值
  final T? tablet;

  /// 桌面端值
  final T? desktop;

  /// 根据屏幕尺寸获取对应值
  T getValue(BuildContext context) {
    if (AppTheme.isDesktop(context)) {
      return desktop ?? tablet ?? mobile;
    } else if (AppTheme.isTablet(context)) {
      return tablet ?? mobile;
    } else {
      return mobile;
    }
  }
}

/// 响应式网格布局
class ResponsiveGrid extends StatelessWidget {
  /// 创建响应式网格布局
  const ResponsiveGrid({
    required this.children, super.key,
    this.mobileColumns = 1,
    this.tabletColumns = 2,
    this.desktopColumns = 3,
    this.spacing = AppTheme.spacingM,
    this.runSpacing,
    this.padding,
  });

  /// 子组件列表
  final List<Widget> children;

  /// 移动端列数
  final int mobileColumns;

  /// 平板端列数
  final int tabletColumns;

  /// 桌面端列数
  final int desktopColumns;

  /// 水平间距
  final double spacing;

  /// 垂直间距
  final double? runSpacing;

  /// 内边距
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final columns = ResponsiveValue(
      mobile: mobileColumns,
      tablet: tabletColumns,
      desktop: desktopColumns,
    ).getValue(context);

    return Padding(
      padding:
          padding ?? EdgeInsets.all(AppTheme.getResponsiveSpacing(context)),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final itemWidth =
              (constraints.maxWidth - (spacing * (columns - 1))) / columns;

          return Wrap(
            spacing: spacing,
            runSpacing: runSpacing ?? spacing,
            children: children.map((child) {
              return SizedBox(width: itemWidth, child: child);
            }).toList(),
          );
        },
      ),
    );
  }
}

/// 响应式容器
class ResponsiveContainer extends StatelessWidget {
  /// 创建响应式容器
  const ResponsiveContainer({
    required this.child, super.key,
    this.maxWidth,
    this.padding,
    this.margin,
  });

  /// 子组件
  final Widget child;

  /// 最大宽度
  final double? maxWidth;

  /// 内边距
  final EdgeInsets? padding;

  /// 外边距
  final EdgeInsets? margin;

  @override
  Widget build(BuildContext context) {
    final responsivePadding =
        padding ??
        EdgeInsets.symmetric(
          horizontal: AppTheme.getResponsiveSpacing(context),
        );

    return Container(
      width: double.infinity,
      margin: margin,
      padding: responsivePadding,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth:
                maxWidth ??
                (AppTheme.isDesktop(context) ? 1200 : double.infinity),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// 响应式间距
class ResponsiveSpacing extends StatelessWidget {
  /// 创建响应式间距
  const ResponsiveSpacing({
    super.key,
    this.mobile = AppTheme.spacingM,
    this.tablet,
    this.desktop,
  });

  /// 移动端间距
  final double mobile;

  /// 平板端间距
  final double? tablet;

  /// 桌面端间距
  final double? desktop;

  @override
  Widget build(BuildContext context) {
    final spacing = ResponsiveValue(
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    ).getValue(context);

    return SizedBox(width: spacing, height: spacing);
  }
}

/// 响应式文本样式
class ResponsiveText extends StatelessWidget {
  /// 创建响应式文本
  const ResponsiveText(
    this.text, {
    super.key,
    this.mobileStyle,
    this.tabletStyle,
    this.desktopStyle,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  /// 文本内容
  final String text;

  /// 移动端样式
  final TextStyle? mobileStyle;

  /// 平板端样式
  final TextStyle? tabletStyle;

  /// 桌面端样式
  final TextStyle? desktopStyle;

  /// 文本对齐
  final TextAlign? textAlign;

  /// 最大行数
  final int? maxLines;

  /// 溢出处理
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    final style = ResponsiveValue(
      mobile: mobileStyle ?? Theme.of(context).textTheme.bodyMedium,
      tablet: tabletStyle,
      desktop: desktopStyle,
    ).getValue(context);

    return Text(
      text,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

/// 响应式布局构建器
class ResponsiveBuilder extends StatelessWidget {
  /// 创建响应式布局构建器
  const ResponsiveBuilder({required this.builder, super.key});

  /// 构建器函数
  final Widget Function(
    BuildContext context,
    BoxConstraints constraints,
    DeviceType deviceType,
  )
  builder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        DeviceType deviceType;
        if (AppTheme.isDesktop(context)) {
          deviceType = DeviceType.desktop;
        } else if (AppTheme.isTablet(context)) {
          deviceType = DeviceType.tablet;
        } else {
          deviceType = DeviceType.mobile;
        }

        return builder(context, constraints, deviceType);
      },
    );
  }
}

/// 设备类型枚举
enum DeviceType {
  /// 移动设备
  mobile,

  /// 平板设备
  tablet,

  /// 桌面设备
  desktop,
}
