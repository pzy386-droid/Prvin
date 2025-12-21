import 'package:flutter/material.dart';

/// 应用主题配置
class AppTheme {
  // 柔和色系配色方案
  /// 主色调 - 柔和紫色
  static const Color primaryColor = Color(0xFF6366F1);

  /// 次要色调 - 淡紫色
  static const Color secondaryColor = Color(0xFF8B5CF6);

  /// 强调色 - 青色
  static const Color accentColor = Color(0xFF06B6D4);

  /// 背景色 - 浅灰白
  static const Color backgroundColor = Color(0xFFF8FAFC);

  /// 表面色 - 纯白
  static const Color surfaceColor = Color(0xFFFFFFFF);

  /// 错误色 - 柔和红色
  static const Color errorColor = Color(0xFFEF4444);

  /// 成功色 - 柔和绿色
  static const Color successColor = Color(0xFF10B981);

  /// 警告色 - 柔和橙色
  static const Color warningColor = Color(0xFFF59E0B);

  /// 信息色 - 柔和蓝色
  static const Color infoColor = Color(0xFF3B82F6);

  // 任务类型颜色分区
  /// 任务分类颜色映射
  static const Map<String, Color> taskCategoryColors = {
    'work': Color(0xFF3B82F6), // 蓝色
    'personal': Color(0xFF10B981), // 绿色
    'health': Color(0xFFF59E0B), // 橙色
    'learning': Color(0xFF8B5CF6), // 紫色
    'social': Color(0xFFEC4899), // 粉色
  };

  // 番茄钟状态颜色
  /// 番茄钟工作状态颜色
  static const Color pomodoroWorkColor = Color(0xFFEF4444);

  /// 番茄钟短休息颜色
  static const Color pomodoroShortBreakColor = Color(0xFF10B981);

  /// 番茄钟长休息颜色
  static const Color pomodoroLongBreakColor = Color(0xFF3B82F6);

  // 动画配置
  /// 短动画时长 (200ms)
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);

  /// 中等动画时长 (300ms)
  static const Duration mediumAnimationDuration = Duration(milliseconds: 300);

  /// 长动画时长 (500ms)
  static const Duration longAnimationDuration = Duration(milliseconds: 500);

  /// 超长动画时长 (800ms)
  static const Duration extraLongAnimationDuration = Duration(
    milliseconds: 800,
  );

  // 缓动曲线
  /// 默认缓动曲线
  static const Curve defaultCurve = Curves.easeInOutCubic;

  /// 弹性缓动曲线
  static const Curve elasticCurve = Curves.elasticOut;

  /// 弹跳缓动曲线
  static const Curve bounceCurve = Curves.bounceOut;

  /// 快速进入缓动曲线
  static const Curve fastInCurve = Curves.fastOutSlowIn;

  /// 平滑缓动曲线
  static const Curve smoothCurve = Curves.easeInOut;

  // 间距配置
  /// 超小间距 (4px)
  static const double spacingXS = 4;

  /// 小间距 (8px)
  static const double spacingS = 8;

  /// 中等间距 (16px)
  static const double spacingM = 16;

  /// 大间距 (24px)
  static const double spacingL = 24;

  /// 超大间距 (32px)
  static const double spacingXL = 32;

  // 圆角配置
  /// 小圆角 (8px)
  static const double radiusS = 8;

  /// 中等圆角 (12px)
  static const double radiusM = 12;

  /// 大圆角 (16px)
  static const double radiusL = 16;

  /// 超大圆角 (24px)
  static const double radiusXL = 24;

  // 阴影配置
  /// 小阴影
  static List<BoxShadow> get smallShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];

  /// 中等阴影
  static List<BoxShadow> get mediumShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.1),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  /// 大阴影
  static List<BoxShadow> get largeShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.15),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];

  // 响应式断点
  /// 移动设备断点
  static const double mobileBreakpoint = 600;

  /// 平板设备断点
  static const double tabletBreakpoint = 900;

  /// 桌面设备断点
  static const double desktopBreakpoint = 1200;

  /// 判断是否为移动设备
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  /// 判断是否为平板设备
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < desktopBreakpoint;
  }

  /// 判断是否为桌面设备
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktopBreakpoint;
  }

  /// 获取响应式间距
  static double getResponsiveSpacing(BuildContext context) {
    if (isMobile(context)) return spacingM;
    if (isTablet(context)) return spacingL;
    return spacingXL;
  }

  /// 浅色主题
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        surface: surfaceColor,
      ),

      // 应用栏主题
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: surfaceColor,
        foregroundColor: Colors.black87,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        iconTheme: IconThemeData(color: Colors.black87),
      ),

      // 卡片主题
      cardTheme: CardThemeData(
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusL),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        color: surfaceColor,
      ),

      // 按钮主题
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shadowColor: Colors.transparent,
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: spacingL,
            vertical: spacingM,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusM),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      // 文本按钮主题
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(
            horizontal: spacingL,
            vertical: spacingM,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusM),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      // 输入框主题
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.all(spacingM),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusM),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusM),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusM),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusM),
          borderSide: const BorderSide(color: errorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusM),
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
      ),

      // 浮动操作按钮主题
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
      ),

      // 底部导航栏主题
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: surfaceColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        elevation: 8,
      ),

      // 分割线主题
      dividerTheme: DividerThemeData(color: Colors.grey.shade200),
    );
  }

  /// 深色主题
  static ThemeData get darkTheme {
    const darkSurface = Color(0xFF1F2937);

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
        surface: darkSurface,
      ),

      // 应用栏主题
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: darkSurface,
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),

      // 卡片主题
      cardTheme: CardThemeData(
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusL),
          side: BorderSide(color: Colors.grey.shade700),
        ),
        color: darkSurface,
      ),

      // 按钮主题
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shadowColor: Colors.transparent,
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: spacingL,
            vertical: spacingM,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusM),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      // 文本按钮主题
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(
            horizontal: spacingL,
            vertical: spacingM,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusM),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      // 输入框主题
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey.shade800,
        contentPadding: const EdgeInsets.all(spacingM),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusM),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusM),
          borderSide: BorderSide(color: Colors.grey.shade600),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusM),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusM),
          borderSide: const BorderSide(color: errorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusM),
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
      ),

      // 浮动操作按钮主题
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
      ),

      // 底部导航栏主题
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: darkSurface,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        elevation: 8,
      ),

      // 分割线主题
      dividerTheme: DividerThemeData(color: Colors.grey.shade700),
    );
  }
}
