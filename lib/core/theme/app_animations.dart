import 'package:flutter/material.dart';
import 'package:prvin/core/theme/app_theme.dart';

/// 应用动画配置
class AppAnimations {
  /// 淡入动画
  static Widget fadeIn({
    required Widget child,
    Duration duration = AppTheme.mediumAnimationDuration,
    Curve curve = AppTheme.defaultCurve,
    double begin = 0.0,
    double end = 1.0,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: begin, end: end),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Opacity(opacity: value, child: child);
      },
      child: child,
    );
  }

  /// 滑入动画
  static Widget slideIn({
    required Widget child,
    Duration duration = AppTheme.mediumAnimationDuration,
    Curve curve = AppTheme.defaultCurve,
    Offset begin = const Offset(0, 0.3),
    Offset end = Offset.zero,
  }) {
    return TweenAnimationBuilder<Offset>(
      tween: Tween(begin: begin, end: end),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Transform.translate(offset: value, child: child);
      },
      child: child,
    );
  }

  /// 缩放动画
  static Widget scaleIn({
    required Widget child,
    Duration duration = AppTheme.mediumAnimationDuration,
    Curve curve = AppTheme.elasticCurve,
    double begin = 0.8,
    double end = 1.0,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: begin, end: end),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child);
      },
      child: child,
    );
  }

  /// 旋转动画
  static Widget rotateIn({
    required Widget child,
    Duration duration = AppTheme.longAnimationDuration,
    Curve curve = AppTheme.defaultCurve,
    double begin = -0.1,
    double end = 0.0,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: begin, end: end),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Transform.rotate(angle: value, child: child);
      },
      child: child,
    );
  }

  /// 组合动画：淡入 + 滑入
  static Widget fadeSlideIn({
    required Widget child,
    Duration duration = AppTheme.mediumAnimationDuration,
    Curve curve = AppTheme.defaultCurve,
    Offset slideBegin = const Offset(0, 0.3),
    double fadeBegin = 0.0,
  }) {
    return fadeIn(
      duration: duration,
      curve: curve,
      begin: fadeBegin,
      child: slideIn(
        duration: duration,
        curve: curve,
        begin: slideBegin,
        child: child,
      ),
    );
  }

  /// 组合动画：淡入 + 缩放
  static Widget fadeScaleIn({
    required Widget child,
    Duration duration = AppTheme.mediumAnimationDuration,
    Curve curve = AppTheme.elasticCurve,
    double scaleBegin = 0.8,
    double fadeBegin = 0.0,
  }) {
    return fadeIn(
      duration: duration,
      curve: curve,
      begin: fadeBegin,
      child: scaleIn(
        duration: duration,
        curve: curve,
        begin: scaleBegin,
        child: child,
      ),
    );
  }

  /// 列表项动画
  static Widget listItemAnimation({
    required Widget child,
    required int index,
    Duration delay = const Duration(milliseconds: 50),
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: AppTheme.mediumAnimationDuration + (delay * index),
      curve: AppTheme.fastInCurve,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: child,
    );
  }

  /// 页面转场动画
  static PageRouteBuilder<T> createRoute<T>({
    required Widget page,
    RouteTransitionType type = RouteTransitionType.slideFromRight,
    Duration duration = AppTheme.mediumAnimationDuration,
    Curve curve = AppTheme.defaultCurve,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        switch (type) {
          case RouteTransitionType.fade:
            return FadeTransition(opacity: animation, child: child);

          case RouteTransitionType.slideFromRight:
            return SlideTransition(
              position: animation.drive(
                Tween(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).chain(CurveTween(curve: curve)),
              ),
              child: child,
            );

          case RouteTransitionType.slideFromLeft:
            return SlideTransition(
              position: animation.drive(
                Tween(
                  begin: const Offset(-1, 0),
                  end: Offset.zero,
                ).chain(CurveTween(curve: curve)),
              ),
              child: child,
            );

          case RouteTransitionType.slideFromBottom:
            return SlideTransition(
              position: animation.drive(
                Tween(
                  begin: const Offset(0, 1),
                  end: Offset.zero,
                ).chain(CurveTween(curve: curve)),
              ),
              child: child,
            );

          case RouteTransitionType.scale:
            return ScaleTransition(
              scale: animation.drive(
                Tween(begin: 0.8, end: 1).chain(CurveTween(curve: curve)),
              ),
              child: FadeTransition(opacity: animation, child: child),
            );
        }
      },
    );
  }

  /// 微动效 - 轻微弹跳
  static Widget microBounce({
    required Widget child,
    Duration duration = const Duration(milliseconds: 150),
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1, end: 1),
      duration: duration,
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child);
      },
      child: child,
    );
  }

  /// 呼吸效果动画
  static Widget breathingEffect({
    required Widget child,
    Duration duration = const Duration(seconds: 2),
    double minScale = 0.95,
    double maxScale = 1.05,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: minScale, end: maxScale),
      duration: duration,
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child);
      },
      onEnd: () {
        // 反向动画会自动处理
      },
      child: child,
    );
  }

  /// 脉冲效果
  static Widget pulseEffect({
    required Widget child,
    Duration duration = const Duration(milliseconds: 1000),
    double minOpacity = 0.5,
    double maxOpacity = 1.0,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: minOpacity, end: maxOpacity),
      duration: duration,
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Opacity(opacity: value, child: child);
      },
      child: child,
    );
  }
}

/// 路由转场类型
enum RouteTransitionType {
  /// 淡入淡出
  fade,

  /// 从右侧滑入
  slideFromRight,

  /// 从左侧滑入
  slideFromLeft,

  /// 从底部滑入
  slideFromBottom,

  /// 缩放
  scale,
}
