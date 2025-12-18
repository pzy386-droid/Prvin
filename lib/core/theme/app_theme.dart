import 'package:flutter/material.dart';

/// 应用主题配置
class AppTheme {
  // 柔和色系配色方案
  static const Color primaryColor = Color(0xFF6366F1); // 柔和紫色
  static const Color secondaryColor = Color(0xFF8B5CF6); // 淡紫色
  static const Color accentColor = Color(0xFF06B6D4); // 青色
  static const Color backgroundColor = Color(0xFFF8FAFC); // 浅灰白
  static const Color surfaceColor = Color(0xFFFFFFFF); // 纯白
  static const Color errorColor = Color(0xFFEF4444); // 柔和红色

  // 任务类型颜色分区
  static const Map<String, Color> taskCategoryColors = {
    'work': Color(0xFF3B82F6), // 蓝色
    'personal': Color(0xFF10B981), // 绿色
    'health': Color(0xFFF59E0B), // 橙色
    'learning': Color(0xFF8B5CF6), // 紫色
    'social': Color(0xFFEC4899), // 粉色
  };

  // 动画配置
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);

  // 缓动曲线
  static const Curve defaultCurve = Curves.easeInOutCubic;
  static const Curve elasticCurve = Curves.elasticOut;
  static const Curve bounceCurve = Curves.bounceOut;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        background: backgroundColor,
        surface: surfaceColor,
      ),

      // 卡片主题
      cardTheme: const CardThemeData(
        elevation: 4,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),

      // 按钮主题
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // 输入框主题
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
      ),

      // 卡片主题
      cardTheme: const CardThemeData(
        elevation: 4,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),

      // 按钮主题
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // 输入框主题
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade600),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
      ),
    );
  }
}
