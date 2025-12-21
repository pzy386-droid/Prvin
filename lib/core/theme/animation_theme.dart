import 'package:flutter/material.dart';

/// 动画主题配置
/// 提供应用中所有动画效果的统一配置
class AnimationTheme {
  // 动画时长配置
  /// 微动效时长 (150ms) - 用于悬停、点击等快速反馈
  static const Duration microAnimationDuration = Duration(milliseconds: 150);

  /// 短动画时长 (200ms) - 用于按钮状态变化
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);

  /// 中等动画时长 (300ms) - 用于页面元素进入/退出
  static const Duration mediumAnimationDuration = Duration(milliseconds: 300);

  /// 长动画时长 (500ms) - 用于页面切换
  static const Duration longAnimationDuration = Duration(milliseconds: 500);

  /// 超长动画时长 (800ms) - 用于复杂动画序列
  static const Duration extraLongAnimationDuration = Duration(
    milliseconds: 800,
  );

  /// 番茄钟呼吸动画时长 (2000ms)
  static const Duration breathingAnimationDuration = Duration(
    milliseconds: 2000,
  );

  // 物理惯性缓动曲线配置
  /// 默认缓动 - 自然的进出效果
  static const Curve defaultCurve = Curves.easeInOutCubic;

  /// 快速进入 - 快速开始，缓慢结束
  static const Curve fastInCurve = Curves.fastOutSlowIn;

  /// 快速退出 - 缓慢开始，快速结束
  static const Curve fastOutCurve = Curves.fastOutSlowIn;

  /// 弹性效果 - 带有弹性的动画
  static const Curve elasticCurve = Curves.elasticOut;

  /// 弹跳效果 - 带有弹跳的动画
  static const Curve bounceCurve = Curves.bounceOut;

  /// 物理惯性 - 模拟真实物理效果的cubic-bezier曲线
  static const Curve physicalCurve = Cubic(0.25, 0.46, 0.45, 0.94);

  /// 平滑曲线 - 用于页面切换和翻页
  static const Curve smoothCurve = Cubic(0.4, 0, 0.2, 1);

  /// 呼吸曲线 - 用于番茄钟的呼吸效果
  static const Curve breathingCurve = Curves.easeInOutSine;

  // 微动效配置
  /// 悬停放大比例
  static const double hoverScale = 1.05;

  /// 点击缩放比例
  static const double tapScale = 0.95;

  /// 拖拽时的缩放比例
  static const double dragScale = 1.1;

  /// 阴影提升高度
  static const double shadowElevation = 8;

  // 页面切换动画配置
  /// 页面切换偏移量
  static const Offset pageTransitionOffset = Offset(1, 0);

  /// 淡入淡出透明度
  static const double fadeOpacity = 0;

  // 微光效果配置
  /// 微光动画时长
  static const Duration glowAnimationDuration = Duration(milliseconds: 1500);

  /// 微光透明度范围
  static const double glowOpacityMin = 0.3;
  static const double glowOpacityMax = 0.8;

  /// 微光模糊半径
  static const double glowBlurRadius = 20;

  // 晃动动画配置
  /// 拖拽时周围元素的晃动幅度
  static const double shakeAmplitude = 2;

  /// 晃动动画时长
  static const Duration shakeAnimationDuration = Duration(milliseconds: 100);

  // 预定义动画控制器配置
  /// 创建微动效动画控制器
  static AnimationController createMicroAnimationController(
    TickerProvider vsync,
  ) {
    return AnimationController(duration: microAnimationDuration, vsync: vsync);
  }

  /// 创建短动画控制器
  static AnimationController createShortAnimationController(
    TickerProvider vsync,
  ) {
    return AnimationController(duration: shortAnimationDuration, vsync: vsync);
  }

  /// 创建中等动画控制器
  static AnimationController createMediumAnimationController(
    TickerProvider vsync,
  ) {
    return AnimationController(duration: mediumAnimationDuration, vsync: vsync);
  }

  /// 创建长动画控制器
  static AnimationController createLongAnimationController(
    TickerProvider vsync,
  ) {
    return AnimationController(duration: longAnimationDuration, vsync: vsync);
  }

  /// 创建呼吸动画控制器（循环）
  static AnimationController createBreathingAnimationController(
    TickerProvider vsync,
  ) {
    return AnimationController(
      duration: breathingAnimationDuration,
      vsync: vsync,
    )..repeat(reverse: true);
  }

  /// 创建微光动画控制器（循环）
  static AnimationController createGlowAnimationController(
    TickerProvider vsync,
  ) {
    return AnimationController(duration: glowAnimationDuration, vsync: vsync)
      ..repeat(reverse: true);
  }

  // 预定义动画
  /// 创建缩放动画
  static Animation<double> createScaleAnimation(
    AnimationController controller, {
    double begin = 1.0,
    double end = 1.05,
    Curve curve = defaultCurve,
  }) {
    return Tween<double>(
      begin: begin,
      end: end,
    ).animate(CurvedAnimation(parent: controller, curve: curve));
  }

  /// 创建淡入淡出动画
  static Animation<double> createFadeAnimation(
    AnimationController controller, {
    double begin = 0.0,
    double end = 1.0,
    Curve curve = defaultCurve,
  }) {
    return Tween<double>(
      begin: begin,
      end: end,
    ).animate(CurvedAnimation(parent: controller, curve: curve));
  }

  /// 创建滑动动画
  static Animation<Offset> createSlideAnimation(
    AnimationController controller, {
    Offset begin = const Offset(1, 0),
    Offset end = Offset.zero,
    Curve curve = physicalCurve,
  }) {
    return Tween<Offset>(
      begin: begin,
      end: end,
    ).animate(CurvedAnimation(parent: controller, curve: curve));
  }

  /// 创建旋转动画
  static Animation<double> createRotationAnimation(
    AnimationController controller, {
    double begin = 0.0,
    double end = 1.0,
    Curve curve = defaultCurve,
  }) {
    return Tween<double>(
      begin: begin,
      end: end,
    ).animate(CurvedAnimation(parent: controller, curve: curve));
  }

  /// 创建颜色动画
  static Animation<Color?> createColorAnimation(
    AnimationController controller, {
    required Color begin,
    required Color end,
    Curve curve = defaultCurve,
  }) {
    return ColorTween(
      begin: begin,
      end: end,
    ).animate(CurvedAnimation(parent: controller, curve: curve));
  }

  /// 创建呼吸缩放动画（用于番茄钟）
  static Animation<double> createBreathingScaleAnimation(
    AnimationController controller,
  ) {
    return Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(parent: controller, curve: breathingCurve));
  }

  /// 创建微光透明度动画
  static Animation<double> createGlowOpacityAnimation(
    AnimationController controller,
  ) {
    return Tween<double>(
      begin: glowOpacityMin,
      end: glowOpacityMax,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));
  }

  /// 创建晃动动画
  static Animation<double> createShakeAnimation(
    AnimationController controller,
  ) {
    return Tween<double>(
      begin: -shakeAmplitude,
      end: shakeAmplitude,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.elasticIn));
  }
}
