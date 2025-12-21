import 'package:flutter/material.dart';
import 'package:prvin/core/theme/animation_theme.dart';

/// 微光效果组件
/// 提供各种微光和发光效果的实现
class GlowEffects {
  /// 创建当天日期的高亮glow效果
  static Widget createTodayGlow({
    required Widget child,
    Color glowColor = const Color(0xFF6366F1),
    double glowRadius = 20.0,
    bool isAnimated = true,
  }) {
    if (!isAnimated) {
      return Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: glowColor.withValues(alpha: 0.6),
              blurRadius: glowRadius,
              spreadRadius: 2,
            ),
          ],
        ),
        child: child,
      );
    }

    return _AnimatedGlow(
      glowColor: glowColor,
      glowRadius: glowRadius,
      child: child,
    );
  }

  /// 创建任务卡片的微光效果
  static Widget createCardGlow({
    required Widget child,
    Color glowColor = const Color(0xFF6366F1),
    double glowRadius = 8.0,
    bool isHovered = false,
  }) {
    return AnimatedContainer(
      duration: AnimationTheme.shortAnimationDuration,
      curve: AnimationTheme.defaultCurve,
      decoration: BoxDecoration(
        boxShadow: isHovered
            ? [
                BoxShadow(
                  color: glowColor.withValues(alpha: 0.3),
                  blurRadius: glowRadius * 1.5,
                  spreadRadius: 1,
                  offset: const Offset(0, 4),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: child,
    );
  }

  /// 创建番茄钟的呼吸微光效果
  static Widget createPomodoroGlow({
    required Widget child,
    required Color glowColor,
    double baseRadius = 30.0,
    bool isActive = true,
  }) {
    if (!isActive) {
      return child;
    }

    return _BreathingGlow(
      glowColor: glowColor,
      baseRadius: baseRadius,
      child: child,
    );
  }

  /// 创建按钮的交互微光效果
  static Widget createButtonGlow({
    required Widget child,
    Color glowColor = const Color(0xFF6366F1),
    bool isPressed = false,
    bool isHovered = false,
  }) {
    var glowIntensity = 0.0;
    var glowRadius = 0.0;

    if (isPressed) {
      glowIntensity = 0.4;
      glowRadius = 12.0;
    } else if (isHovered) {
      glowIntensity = 0.2;
      glowRadius = 8.0;
    }

    return AnimatedContainer(
      duration: AnimationTheme.microAnimationDuration,
      curve: AnimationTheme.fastInCurve,
      decoration: BoxDecoration(
        boxShadow: glowIntensity > 0
            ? [
                BoxShadow(
                  color: glowColor.withValues(alpha: glowIntensity),
                  blurRadius: glowRadius,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: child,
    );
  }

  /// 创建拖拽时的可放置区域高亮效果
  static Widget createDropZoneGlow({
    required Widget child,
    bool isActive = false,
    Color glowColor = const Color(0xFF10B981),
  }) {
    return AnimatedContainer(
      duration: AnimationTheme.shortAnimationDuration,
      curve: AnimationTheme.elasticCurve,
      decoration: BoxDecoration(
        border: isActive
            ? Border.all(color: glowColor.withValues(alpha: 0.6), width: 2)
            : null,
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: glowColor.withValues(alpha: 0.3),
                  blurRadius: 15,
                  spreadRadius: 3,
                ),
              ]
            : null,
      ),
      child: child,
    );
  }

  /// 创建成功状态的微光效果
  static Widget createSuccessGlow({
    required Widget child,
    bool isVisible = true,
  }) {
    return AnimatedContainer(
      duration: AnimationTheme.mediumAnimationDuration,
      curve: AnimationTheme.bounceCurve,
      decoration: BoxDecoration(
        boxShadow: isVisible
            ? [
                BoxShadow(
                  color: const Color(0xFF10B981).withValues(alpha: 0.4),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ]
            : null,
      ),
      child: child,
    );
  }
}

/// 动画微光组件
class _AnimatedGlow extends StatefulWidget {
  const _AnimatedGlow({
    required this.child,
    required this.glowColor,
    required this.glowRadius,
  });

  final Widget child;
  final Color glowColor;
  final double glowRadius;

  @override
  State<_AnimatedGlow> createState() => _AnimatedGlowState();
}

class _AnimatedGlowState extends State<_AnimatedGlow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationTheme.createGlowAnimationController(this);
    _opacityAnimation = AnimationTheme.createGlowOpacityAnimation(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _opacityAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: widget.glowColor.withValues(
                  alpha: _opacityAnimation.value,
                ),
                blurRadius: widget.glowRadius,
                spreadRadius: 2,
              ),
            ],
          ),
          child: widget.child,
        );
      },
    );
  }
}

/// 呼吸微光组件
class _BreathingGlow extends StatefulWidget {
  const _BreathingGlow({
    required this.child,
    required this.glowColor,
    required this.baseRadius,
  });

  final Widget child;
  final Color glowColor;
  final double baseRadius;

  @override
  State<_BreathingGlow> createState() => _BreathingGlowState();
}

class _BreathingGlowState extends State<_BreathingGlow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _radiusAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationTheme.createBreathingAnimationController(this);

    _radiusAnimation =
        Tween<double>(
          begin: widget.baseRadius * 0.8,
          end: widget.baseRadius * 1.2,
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: AnimationTheme.breathingCurve,
          ),
        );

    _opacityAnimation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(
        parent: _controller,
        curve: AnimationTheme.breathingCurve,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: widget.glowColor.withValues(
                  alpha: _opacityAnimation.value,
                ),
                blurRadius: _radiusAnimation.value,
                spreadRadius: 3,
              ),
            ],
          ),
          child: widget.child,
        );
      },
    );
  }
}
