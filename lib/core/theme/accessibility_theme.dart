import 'package:flutter/material.dart';
import 'package:prvin/core/theme/app_theme.dart';

/// 可访问性主题配置
/// 提供高对比度模式、字体缩放和其他可访问性功能的主题支持
class AccessibilityTheme {
  /// 高对比度颜色配置
  static const Map<String, Color> highContrastColors = {
    'primary': Color(0xFF000000), // 纯黑色
    'onPrimary': Color(0xFFFFFFFF), // 纯白色
    'secondary': Color(0xFF333333), // 深灰色
    'onSecondary': Color(0xFFFFFFFF), // 纯白色
    'surface': Color(0xFFFFFFFF), // 纯白色背景
    'onSurface': Color(0xFF000000), // 纯黑色文字
    'background': Color(0xFFFFFFFF), // 纯白色背景
    'onBackground': Color(0xFF000000), // 纯黑色文字
    'error': Color(0xFF800000), // 深红色
    'onError': Color(0xFFFFFFFF), // 纯白色
    'success': Color(0xFF006400), // 深绿色
    'warning': Color(0xFF8B4513), // 深棕色
    'info': Color(0xFF000080), // 深蓝色
  };

  /// 获取高对比度主题
  static ThemeData getHighContrastTheme({bool isDark = false}) {
    final baseTheme = isDark ? AppTheme.darkTheme : AppTheme.lightTheme;

    return baseTheme.copyWith(
      // 高对比度颜色方案
      colorScheme: ColorScheme.fromSeed(
        seedColor: highContrastColors['primary']!,
        brightness: isDark ? Brightness.dark : Brightness.light,
        primary: isDark ? Colors.white : Colors.black,
        onPrimary: isDark ? Colors.black : Colors.white,
        secondary: isDark ? Colors.grey.shade300 : Colors.grey.shade800,
        onSecondary: isDark ? Colors.black : Colors.white,
        surface: isDark ? Colors.black : Colors.white,
        onSurface: isDark ? Colors.white : Colors.black,
        background: isDark ? Colors.black : Colors.white,
        onBackground: isDark ? Colors.white : Colors.black,
        error: isDark ? Colors.red.shade300 : Colors.red.shade800,
        onError: isDark ? Colors.black : Colors.white,
      ),

      // 高对比度应用栏主题
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: isDark ? Colors.black : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700, // 更粗的字体
          color: isDark ? Colors.white : Colors.black,
        ),
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : Colors.black,
          size: 28, // 更大的图标
        ),
      ),

      // 高对比度卡片主题
      cardTheme: CardThemeData(
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusL),
          side: BorderSide(
            color: isDark ? Colors.white : Colors.black,
            width: 2, // 更粗的边框
          ),
        ),
        color: isDark ? Colors.black : Colors.white,
      ),

      // 高对比度按钮主题
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shadowColor: Colors.transparent,
          backgroundColor: isDark ? Colors.white : Colors.black,
          foregroundColor: isDark ? Colors.black : Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingL,
            vertical: AppTheme.spacingM,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusM),
            side: BorderSide(
              color: isDark ? Colors.white : Colors.black,
              width: 2,
            ),
          ),
          textStyle: const TextStyle(
            fontSize: 18, // 更大的字体
            fontWeight: FontWeight.w700, // 更粗的字体
          ),
        ),
      ),

      // 高对比度文本按钮主题
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: isDark ? Colors.white : Colors.black,
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingL,
            vertical: AppTheme.spacingM,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusM),
            side: BorderSide(
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),

      // 高对比度输入框主题
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? Colors.black : Colors.white,
        contentPadding: const EdgeInsets.all(AppTheme.spacingM),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
          borderSide: BorderSide(
            color: isDark ? Colors.white : Colors.black,
            width: 2,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
          borderSide: BorderSide(
            color: isDark ? Colors.white : Colors.black,
            width: 2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
          borderSide: BorderSide(
            color: isDark ? Colors.white : Colors.black,
            width: 3, // 更粗的焦点边框
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
          borderSide: BorderSide(
            color: isDark ? Colors.red.shade300 : Colors.red.shade800,
            width: 2,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
          borderSide: BorderSide(
            color: isDark ? Colors.red.shade300 : Colors.red.shade800,
            width: 3,
          ),
        ),
        labelStyle: TextStyle(
          color: isDark ? Colors.white : Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        hintStyle: TextStyle(
          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
          fontSize: 16,
        ),
      ),

      // 高对比度分割线主题
      dividerTheme: DividerThemeData(
        color: isDark ? Colors.white : Colors.black,
        thickness: 2, // 更粗的分割线
      ),

      // 高对比度文本主题
      textTheme: _getHighContrastTextTheme(isDark),
    );
  }

  /// 获取高对比度文本主题
  static TextTheme _getHighContrastTextTheme(bool isDark) {
    final textColor = isDark ? Colors.white : Colors.black;

    return TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: textColor,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: textColor,
      ),
      displaySmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: textColor,
      ),
      headlineLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: textColor,
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: textColor,
      ),
      headlineSmall: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: textColor,
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
    );
  }

  /// 检查是否应该使用高对比度模式
  static bool shouldUseHighContrast(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return mediaQuery.highContrast;
  }

  /// 获取适应性主题（根据系统设置自动选择）
  static ThemeData getAdaptiveTheme(
    BuildContext context, {
    bool isDark = false,
  }) {
    if (shouldUseHighContrast(context)) {
      return getHighContrastTheme(isDark: isDark);
    }
    return isDark ? AppTheme.darkTheme : AppTheme.lightTheme;
  }

  /// 获取可访问性友好的颜色
  static Color getAccessibleColor(
    BuildContext context, {
    required Color normalColor,
    required Color highContrastColor,
  }) {
    return shouldUseHighContrast(context) ? highContrastColor : normalColor;
  }

  /// 获取可访问性友好的文本样式
  static TextStyle getAccessibleTextStyle(
    BuildContext context, {
    required TextStyle normalStyle,
    double? highContrastFontSizeMultiplier = 1.2,
    FontWeight? highContrastFontWeight,
  }) {
    if (!shouldUseHighContrast(context)) {
      return normalStyle;
    }

    return normalStyle.copyWith(
      fontSize:
          (normalStyle.fontSize ?? 14) *
          (highContrastFontSizeMultiplier ?? 1.2),
      fontWeight: highContrastFontWeight ?? FontWeight.w700,
      color: Theme.of(context).colorScheme.onSurface,
    );
  }

  /// 获取可访问性友好的边框
  static Border getAccessibleBorder(
    BuildContext context, {
    required Border normalBorder,
    double? highContrastWidth = 2.0,
  }) {
    if (!shouldUseHighContrast(context)) {
      return normalBorder;
    }

    final color = Theme.of(context).colorScheme.onSurface;
    final width = highContrastWidth ?? 2.0;

    return Border.all(color: color, width: width);
  }

  /// 获取可访问性友好的阴影
  static List<BoxShadow> getAccessibleShadow(
    BuildContext context, {
    required List<BoxShadow> normalShadow,
  }) {
    // 高对比度模式下不使用阴影
    if (shouldUseHighContrast(context)) {
      return [];
    }
    return normalShadow;
  }

  /// 获取焦点指示器样式
  static BoxDecoration getFocusIndicatorDecoration(
    BuildContext context, {
    double borderRadius = 8.0,
  }) {
    final theme = Theme.of(context);
    final isHighContrast = shouldUseHighContrast(context);

    return BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: isHighContrast
            ? theme.colorScheme.onSurface
            : theme.colorScheme.primary,
        width: isHighContrast ? 3.0 : 2.0,
      ),
    );
  }

  /// 获取可访问性友好的图标大小
  static double getAccessibleIconSize(
    BuildContext context, {
    required double normalSize,
    double highContrastMultiplier = 1.3,
  }) {
    if (!shouldUseHighContrast(context)) {
      return normalSize;
    }
    return normalSize * highContrastMultiplier;
  }

  /// 获取可访问性友好的间距
  static double getAccessibleSpacing(
    BuildContext context, {
    required double normalSpacing,
    double highContrastMultiplier = 1.2,
  }) {
    if (!shouldUseHighContrast(context)) {
      return normalSpacing;
    }
    return normalSpacing * highContrastMultiplier;
  }
}
