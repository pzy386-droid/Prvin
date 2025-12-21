import 'package:flutter/material.dart';
import 'package:prvin/core/theme/animation_theme.dart';

/// 微动效交互组件
/// 提供各种微动效和交互反馈的实现
class MicroInteractions {
  /// 创建可交互的微动效容器
  static Widget createInteractiveContainer({
    required Widget child,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
    bool enableHoverEffect = true,
    bool enableTapEffect = true,
    bool enableScaleEffect = true,
    Color? hoverColor,
    double hoverScale = AnimationTheme.hoverScale,
    double tapScale = AnimationTheme.tapScale,
  }) {
    return _InteractiveContainer(
      onTap: onTap,
      onLongPress: onLongPress,
      enableHoverEffect: enableHoverEffect,
      enableTapEffect: enableTapEffect,
      enableScaleEffect: enableScaleEffect,
      hoverColor: hoverColor,
      hoverScale: hoverScale,
      tapScale: tapScale,
      child: child,
    );
  }

  /// 创建可拖拽的微动效组件
  static Widget createDraggableWithEffects({
    required Widget child,
    required dynamic data,
    Widget? feedback,
    Widget? childWhenDragging,
    VoidCallback? onDragStarted,
    VoidCallback? onDragEnd,
    bool enableShakeEffect = true,
  }) {
    return _DraggableWithEffects(
      data: data,
      feedback: feedback,
      childWhenDragging: childWhenDragging,
      onDragStarted: onDragStarted,
      onDragEnd: onDragEnd,
      enableShakeEffect: enableShakeEffect,
      child: child,
    );
  }

  /// 创建可放置区域的微动效组件
  static Widget createDropTargetWithEffects<T extends Object>({
    required Widget child,
    required void Function(T data) onAccept,
    bool Function(T data)? onWillAccept,
    VoidCallback? onLeave,
    bool enableHighlightEffect = true,
    Color highlightColor = const Color(0xFF10B981),
  }) {
    return _DropTargetWithEffects<T>(
      onAccept: onAccept,
      onWillAccept: onWillAccept,
      onLeave: onLeave,
      enableHighlightEffect: enableHighlightEffect,
      highlightColor: highlightColor,
      child: child,
    );
  }

  /// 创建弹性按钮
  static Widget createElasticButton({
    required Widget child,
    required VoidCallback onPressed,
    bool enableElasticEffect = true,
    double elasticScale = 0.95,
  }) {
    return _ElasticButton(
      onPressed: onPressed,
      enableElasticEffect: enableElasticEffect,
      elasticScale: elasticScale,
      child: child,
    );
  }

  /// 创建呼吸效果组件
  static Widget createBreathingWidget({
    required Widget child,
    bool isActive = true,
    double breathingScale = 0.05,
  }) {
    return _BreathingWidget(
      isActive: isActive,
      breathingScale: breathingScale,
      child: child,
    );
  }

  /// 创建晃动效果组件
  static Widget createShakeWidget({
    required Widget child,
    bool isShaking = false,
    double shakeIntensity = AnimationTheme.shakeAmplitude,
  }) {
    return _ShakeWidget(
      isShaking: isShaking,
      shakeIntensity: shakeIntensity,
      child: child,
    );
  }

  /// 创建渐变出现效果
  static Widget createFadeInWidget({
    required Widget child,
    Duration delay = Duration.zero,
    Duration duration = AnimationTheme.mediumAnimationDuration,
    Curve curve = AnimationTheme.defaultCurve,
  }) {
    return _FadeInWidget(
      delay: delay,
      duration: duration,
      curve: curve,
      child: child,
    );
  }

  /// 创建滑入效果
  static Widget createSlideInWidget({
    required Widget child,
    Offset beginOffset = const Offset(0, 1),
    Duration delay = Duration.zero,
    Duration duration = AnimationTheme.mediumAnimationDuration,
    Curve curve = AnimationTheme.physicalCurve,
  }) {
    return _SlideInWidget(
      beginOffset: beginOffset,
      delay: delay,
      duration: duration,
      curve: curve,
      child: child,
    );
  }
}

/// 可交互容器组件
class _InteractiveContainer extends StatefulWidget {
  const _InteractiveContainer({
    required this.child,
    this.onTap,
    this.onLongPress,
    this.enableHoverEffect = true,
    this.enableTapEffect = true,
    this.enableScaleEffect = true,
    this.hoverColor,
    this.hoverScale = AnimationTheme.hoverScale,
    this.tapScale = AnimationTheme.tapScale,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool enableHoverEffect;
  final bool enableTapEffect;
  final bool enableScaleEffect;
  final Color? hoverColor;
  final double hoverScale;
  final double tapScale;

  @override
  State<_InteractiveContainer> createState() => _InteractiveContainerState();
}

class _InteractiveContainerState extends State<_InteractiveContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  bool _isHovered = false;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationTheme.createMicroAnimationController(this);
    _scaleAnimation = AnimationTheme.createScaleAnimation(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.enableTapEffect) {
      setState(() => _isPressed = true);
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.enableTapEffect) {
      setState(() => _isPressed = false);
      _controller.reverse();
    }
  }

  void _handleTapCancel() {
    if (widget.enableTapEffect) {
      setState(() => _isPressed = false);
      _controller.reverse();
    }
  }

  void _handleHoverEnter(PointerEvent event) {
    if (widget.enableHoverEffect) {
      setState(() => _isHovered = true);
    }
  }

  void _handleHoverExit(PointerEvent event) {
    if (widget.enableHoverEffect) {
      setState(() => _isHovered = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    var child = widget.child;

    if (widget.enableScaleEffect) {
      child = AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          var scale = 1.0;
          if (_isPressed) {
            scale = widget.tapScale;
          } else if (_isHovered) {
            scale = widget.hoverScale;
          }

          return Transform.scale(scale: scale, child: widget.child);
        },
      );
    }

    if (widget.hoverColor != null) {
      child = AnimatedContainer(
        duration: AnimationTheme.microAnimationDuration,
        decoration: BoxDecoration(
          color: _isHovered
              ? widget.hoverColor!.withValues(alpha: 0.1)
              : Colors.transparent,
        ),
        child: child,
      );
    }

    return MouseRegion(
      onEnter: _handleHoverEnter,
      onExit: _handleHoverExit,
      child: GestureDetector(
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        child: child,
      ),
    );
  }
}

/// 可拖拽微动效组件
class _DraggableWithEffects extends StatefulWidget {
  const _DraggableWithEffects({
    required this.child,
    required this.data,
    this.feedback,
    this.childWhenDragging,
    this.onDragStarted,
    this.onDragEnd,
    this.enableShakeEffect = true,
  });

  final Widget child;
  final dynamic data;
  final Widget? feedback;
  final Widget? childWhenDragging;
  final VoidCallback? onDragStarted;
  final VoidCallback? onDragEnd;
  final bool enableShakeEffect;

  @override
  State<_DraggableWithEffects> createState() => _DraggableWithEffectsState();
}

class _DraggableWithEffectsState extends State<_DraggableWithEffects>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationTheme.createShortAnimationController(this);
    _scaleAnimation = AnimationTheme.createScaleAnimation(
      _controller,
      end: AnimationTheme.dragScale,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleDragStarted() {
    setState(() => _isDragging = true);
    _controller.forward();
    widget.onDragStarted?.call();
  }

  void _handleDragEnd(DraggableDetails details) {
    setState(() => _isDragging = false);
    _controller.reverse();
    widget.onDragEnd?.call();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _isDragging ? _scaleAnimation.value : 1.0,
          child: Draggable(
            data: widget.data,
            feedback: widget.feedback ?? widget.child,
            childWhenDragging: widget.childWhenDragging,
            onDragStarted: _handleDragStarted,
            onDragEnd: _handleDragEnd,
            child: widget.child,
          ),
        );
      },
    );
  }
}

/// 可放置区域微动效组件
class _DropTargetWithEffects<T extends Object> extends StatefulWidget {
  const _DropTargetWithEffects({
    required this.child,
    required this.onAccept,
    this.onWillAccept,
    this.onLeave,
    this.enableHighlightEffect = true,
    this.highlightColor = const Color(0xFF10B981),
  });

  final Widget child;
  final void Function(T data) onAccept;
  final bool Function(T data)? onWillAccept;
  final VoidCallback? onLeave;
  final bool enableHighlightEffect;
  final Color highlightColor;

  @override
  State<_DropTargetWithEffects<T>> createState() =>
      _DropTargetWithEffectsState<T>();
}

class _DropTargetWithEffectsState<T extends Object>
    extends State<_DropTargetWithEffects<T>> {
  bool _isHighlighted = false;

  @override
  Widget build(BuildContext context) {
    return DragTarget<T>(
      onWillAcceptWithDetails: (data) {
        setState(() => _isHighlighted = true);
        return widget.onWillAccept?.call(data.data) ?? true;
              return false;
      },
      onAcceptWithDetails: (data) {
        setState(() => _isHighlighted = false);
        widget.onAccept(data.data);
      },
      onLeave: (data) {
        setState(() => _isHighlighted = false);
        widget.onLeave?.call();
      },
      builder: (context, candidateData, rejectedData) {
        return AnimatedContainer(
          duration: AnimationTheme.shortAnimationDuration,
          curve: AnimationTheme.elasticCurve,
          decoration: BoxDecoration(
            border: _isHighlighted && widget.enableHighlightEffect
                ? Border.all(
                    color: widget.highlightColor.withValues(alpha: 0.6),
                    width: 2,
                  )
                : null,
            boxShadow: _isHighlighted && widget.enableHighlightEffect
                ? [
                    BoxShadow(
                      color: widget.highlightColor.withValues(alpha: 0.3),
                      blurRadius: 15,
                      spreadRadius: 3,
                    ),
                  ]
                : null,
          ),
          child: widget.child,
        );
      },
    );
  }
}

/// 弹性按钮组件
class _ElasticButton extends StatefulWidget {
  const _ElasticButton({
    required this.child,
    required this.onPressed,
    this.enableElasticEffect = true,
    this.elasticScale = 0.95,
  });

  final Widget child;
  final VoidCallback onPressed;
  final bool enableElasticEffect;
  final double elasticScale;

  @override
  State<_ElasticButton> createState() => _ElasticButtonState();
}

class _ElasticButtonState extends State<_ElasticButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationTheme.createMicroAnimationController(this);
    _scaleAnimation = AnimationTheme.createScaleAnimation(
      _controller,
      end: widget.elasticScale,
      curve: AnimationTheme.elasticCurve,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.enableElasticEffect) {
      _controller.forward().then((_) {
        _controller.reverse();
      });
    }
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: widget.enableElasticEffect ? _scaleAnimation.value : 1.0,
            child: widget.child,
          );
        },
      ),
    );
  }
}

/// 呼吸效果组件
class _BreathingWidget extends StatefulWidget {
  const _BreathingWidget({
    required this.child,
    this.isActive = true,
    this.breathingScale = 0.05,
  });

  final Widget child;
  final bool isActive;
  final double breathingScale;

  @override
  State<_BreathingWidget> createState() => _BreathingWidgetState();
}

class _BreathingWidgetState extends State<_BreathingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationTheme.createBreathingAnimationController(this);
    _scaleAnimation = AnimationTheme.createBreathingScaleAnimation(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(_BreathingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
        _controller.reset();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isActive) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: widget.child,
        );
      },
    );
  }
}

/// 晃动效果组件
class _ShakeWidget extends StatefulWidget {
  const _ShakeWidget({
    required this.child,
    this.isShaking = false,
    this.shakeIntensity = AnimationTheme.shakeAmplitude,
  });

  final Widget child;
  final bool isShaking;
  final double shakeIntensity;

  @override
  State<_ShakeWidget> createState() => _ShakeWidgetState();
}

class _ShakeWidgetState extends State<_ShakeWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AnimationTheme.shakeAnimationDuration,
      vsync: this,
    );
    _shakeAnimation = AnimationTheme.createShakeAnimation(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(_ShakeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isShaking != oldWidget.isShaking) {
      if (widget.isShaking) {
        _controller.repeat();
      } else {
        _controller.stop();
        _controller.reset();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeAnimation.value * widget.shakeIntensity, 0),
          child: widget.child,
        );
      },
    );
  }
}

/// 渐变出现组件
class _FadeInWidget extends StatefulWidget {
  const _FadeInWidget({
    required this.child,
    this.delay = Duration.zero,
    this.duration = AnimationTheme.mediumAnimationDuration,
    this.curve = AnimationTheme.defaultCurve,
  });

  final Widget child;
  final Duration delay;
  final Duration duration;
  final Curve curve;

  @override
  State<_FadeInWidget> createState() => _FadeInWidgetState();
}

class _FadeInWidgetState extends State<_FadeInWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _fadeAnimation = AnimationTheme.createFadeAnimation(
      _controller,
      curve: widget.curve,
    );

    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(opacity: _fadeAnimation.value, child: widget.child);
      },
    );
  }
}

/// 滑入效果组件
class _SlideInWidget extends StatefulWidget {
  const _SlideInWidget({
    required this.child,
    this.beginOffset = const Offset(0, 1),
    this.delay = Duration.zero,
    this.duration = AnimationTheme.mediumAnimationDuration,
    this.curve = AnimationTheme.physicalCurve,
  });

  final Widget child;
  final Offset beginOffset;
  final Duration delay;
  final Duration duration;
  final Curve curve;

  @override
  State<_SlideInWidget> createState() => _SlideInWidgetState();
}

class _SlideInWidgetState extends State<_SlideInWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _slideAnimation = AnimationTheme.createSlideAnimation(
      _controller,
      begin: widget.beginOffset,
      curve: widget.curve,
    );

    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return SlideTransition(position: _slideAnimation, child: widget.child);
      },
    );
  }
}
