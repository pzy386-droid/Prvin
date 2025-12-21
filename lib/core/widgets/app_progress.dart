import 'package:flutter/material.dart';
import 'package:prvin/core/theme/theme_exports.dart';

/// 进度指示器类型枚举
enum AppProgressType {
  /// 线性进度条
  linear,

  /// 圆形进度条
  circular,

  /// 步骤进度条
  stepper,

  /// 番茄钟进度环
  pomodoro,
}

/// 应用进度指示器组件
class AppProgress extends StatefulWidget {
  /// 创建进度指示器
  const AppProgress({
    required this.value,
    super.key,
    this.type = AppProgressType.linear,
    this.color,
    this.backgroundColor,
    this.strokeWidth = 4.0,
    this.size = 60.0,
    this.showPercentage = false,
    this.animated = true,
    this.duration,
    this.steps,
    this.currentStep = 0,
    this.stepLabels,
    this.breathingEffect = false,
  });

  /// 进度值 (0.0 - 1.0)
  final double value;

  /// 进度指示器类型
  final AppProgressType type;

  /// 进度颜色
  final Color? color;

  /// 背景颜色
  final Color? backgroundColor;

  /// 线条宽度
  final double strokeWidth;

  /// 尺寸（用于圆形进度条）
  final double size;

  /// 是否显示百分比
  final bool showPercentage;

  /// 是否启用动画
  final bool animated;

  /// 动画时长
  final Duration? duration;

  /// 步骤总数（用于步骤进度条）
  final int? steps;

  /// 当前步骤（用于步骤进度条）
  final int currentStep;

  /// 步骤标签
  final List<String>? stepLabels;

  /// 是否启用呼吸效果（用于番茄钟）
  final bool breathingEffect;

  @override
  State<AppProgress> createState() => _AppProgressState();
}

class _AppProgressState extends State<AppProgress>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _breathingController;
  late Animation<double> _progressAnimation;
  late Animation<double> _breathingAnimation;

  @override
  void initState() {
    super.initState();

    _progressController = AnimationController(
      duration: widget.duration ?? AnimationTheme.mediumAnimationDuration,
      vsync: this,
    );

    _breathingController = AnimationController(
      duration: AnimationTheme.breathingAnimationDuration,
      vsync: this,
    );

    _progressAnimation = Tween<double>(begin: 0, end: widget.value).animate(
      CurvedAnimation(
        parent: _progressController,
        curve: AnimationTheme.defaultCurve,
      ),
    );

    _breathingAnimation = AnimationTheme.createBreathingScaleAnimation(
      _breathingController,
    );

    if (widget.animated) {
      _progressController.forward();
    }

    if (widget.breathingEffect) {
      _breathingController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(AppProgress oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.value != widget.value) {
      _progressAnimation =
          Tween<double>(begin: oldWidget.value, end: widget.value).animate(
            CurvedAnimation(
              parent: _progressController,
              curve: AnimationTheme.defaultCurve,
            ),
          );

      if (widget.animated) {
        _progressController.reset();
        _progressController.forward();
      }
    }

    if (oldWidget.breathingEffect != widget.breathingEffect) {
      if (widget.breathingEffect) {
        _breathingController.repeat(reverse: true);
      } else {
        _breathingController.stop();
        _breathingController.reset();
      }
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    _breathingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.type) {
      case AppProgressType.linear:
        return _buildLinearProgress();
      case AppProgressType.circular:
        return _buildCircularProgress();
      case AppProgressType.stepper:
        return _buildStepperProgress();
      case AppProgressType.pomodoro:
        return _buildPomodoroProgress();
    }
  }

  Widget _buildLinearProgress() {
    final progressColor = widget.color ?? AppTheme.primaryColor;
    final bgColor =
        widget.backgroundColor ?? progressColor.withValues(alpha: 0.2);

    return AnimatedBuilder(
      animation: widget.animated
          ? _progressAnimation
          : AlwaysStoppedAnimation(widget.value),
      builder: (context, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: widget.strokeWidth,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(widget.strokeWidth / 2),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: widget.animated
                    ? _progressAnimation.value
                    : widget.value,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        progressColor,
                        progressColor.withValues(alpha: 0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(widget.strokeWidth / 2),
                    boxShadow: [
                      BoxShadow(
                        color: progressColor.withValues(alpha: 0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (widget.showPercentage) ...[
              const SizedBox(height: 8),
              Text(
                '${((widget.animated ? _progressAnimation.value : widget.value) * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: progressColor,
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildCircularProgress() {
    final progressColor = widget.color ?? AppTheme.primaryColor;
    final bgColor =
        widget.backgroundColor ?? progressColor.withValues(alpha: 0.2);

    Widget progressWidget = AnimatedBuilder(
      animation: widget.animated
          ? _progressAnimation
          : AlwaysStoppedAnimation(widget.value),
      builder: (context, child) {
        final currentValue = widget.animated
            ? _progressAnimation.value
            : widget.value;

        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 背景圆环
              SizedBox(
                width: widget.size,
                height: widget.size,
                child: CircularProgressIndicator(
                  value: 1,
                  strokeWidth: widget.strokeWidth,
                  valueColor: AlwaysStoppedAnimation<Color>(bgColor),
                ),
              ),
              // 进度圆环
              SizedBox(
                width: widget.size,
                height: widget.size,
                child: CircularProgressIndicator(
                  value: currentValue,
                  strokeWidth: widget.strokeWidth,
                  valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                  strokeCap: StrokeCap.round,
                ),
              ),
              // 中心文本
              if (widget.showPercentage)
                Text(
                  '${(currentValue * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: widget.size * 0.15,
                    fontWeight: FontWeight.bold,
                    color: progressColor,
                  ),
                ),
            ],
          ),
        );
      },
    );

    if (widget.breathingEffect) {
      progressWidget = AnimatedBuilder(
        animation: _breathingAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _breathingAnimation.value,
            child: progressWidget,
          );
        },
      );
    }

    return progressWidget;
  }

  Widget _buildStepperProgress() {
    final steps = widget.steps ?? 3;
    final progressColor = widget.color ?? AppTheme.primaryColor;
    final bgColor = widget.backgroundColor ?? Colors.grey.shade300;

    return Column(
      children: [
        Row(
          children: List.generate(steps, (index) {
            final isCompleted = index < widget.currentStep;
            final isCurrent = index == widget.currentStep;

            return Expanded(
              child: Row(
                children: [
                  // 步骤圆点
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted || isCurrent ? progressColor : bgColor,
                      border: isCurrent
                          ? Border.all(color: progressColor, width: 2)
                          : null,
                    ),
                    child: isCompleted
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : Center(
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isCurrent
                                    ? Colors.white
                                    : Colors.grey.shade600,
                              ),
                            ),
                          ),
                  ),
                  // 连接线
                  if (index < steps - 1)
                    Expanded(
                      child: Container(
                        height: 2,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        color: isCompleted ? progressColor : bgColor,
                      ),
                    ),
                ],
              ),
            );
          }),
        ),
        if (widget.stepLabels != null) ...[
          const SizedBox(height: 8),
          Row(
            children: List.generate(steps, (index) {
              if (index < widget.stepLabels!.length) {
                final isActive = index <= widget.currentStep;
                return Expanded(
                  child: Text(
                    widget.stepLabels![index],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isActive
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: isActive ? progressColor : Colors.grey.shade600,
                    ),
                  ),
                );
              }
              return const Expanded(child: SizedBox());
            }),
          ),
        ],
      ],
    );
  }

  Widget _buildPomodoroProgress() {
    final progressColor = widget.color ?? AppTheme.pomodoroWorkColor;
    final bgColor =
        widget.backgroundColor ?? progressColor.withValues(alpha: 0.2);

    Widget progressWidget = AnimatedBuilder(
      animation: widget.animated
          ? _progressAnimation
          : AlwaysStoppedAnimation(widget.value),
      builder: (context, child) {
        final currentValue = widget.animated
            ? _progressAnimation.value
            : widget.value;

        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                progressColor.withValues(alpha: 0.1),
                progressColor.withValues(alpha: 0.05),
              ],
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 背景圆环
              SizedBox(
                width: widget.size - 20,
                height: widget.size - 20,
                child: CircularProgressIndicator(
                  value: 1,
                  strokeWidth: widget.strokeWidth,
                  valueColor: AlwaysStoppedAnimation<Color>(bgColor),
                ),
              ),
              // 进度圆环
              SizedBox(
                width: widget.size - 20,
                height: widget.size - 20,
                child: CircularProgressIndicator(
                  value: currentValue,
                  strokeWidth: widget.strokeWidth,
                  valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                  strokeCap: StrokeCap.round,
                ),
              ),
              // 中心图标
              Icon(Icons.timer, size: widget.size * 0.3, color: progressColor),
            ],
          ),
        );
      },
    );

    if (widget.breathingEffect) {
      progressWidget = AnimatedBuilder(
        animation: _breathingAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _breathingAnimation.value,
            child: progressWidget,
          );
        },
      );
    }

    return GlowEffects.createPomodoroGlow(
      glowColor: progressColor,
      isActive: widget.breathingEffect,
      child: progressWidget,
    );
  }
}

/// 简化的进度指示器组件
class SimpleProgress {
  /// 创建线性进度条
  static Widget linear({
    required double value,
    Color? color,
    bool showPercentage = false,
    bool animated = true,
  }) {
    return AppProgress(
      value: value,
      color: color,
      showPercentage: showPercentage,
      animated: animated,
    );
  }

  /// 创建圆形进度条
  static Widget circular({
    required double value,
    Color? color,
    double size = 60,
    bool showPercentage = false,
    bool animated = true,
  }) {
    return AppProgress(
      value: value,
      type: AppProgressType.circular,
      color: color,
      size: size,
      showPercentage: showPercentage,
      animated: animated,
    );
  }

  /// 创建步骤进度条
  static Widget stepper({
    required int steps,
    required int currentStep,
    List<String>? stepLabels,
    Color? color,
  }) {
    return AppProgress(
      value: currentStep / steps,
      type: AppProgressType.stepper,
      steps: steps,
      currentStep: currentStep,
      stepLabels: stepLabels,
      color: color,
    );
  }

  /// 创建番茄钟进度环
  static Widget pomodoro({
    required double value,
    double size = 120,
    bool breathingEffect = false,
    Color? color,
  }) {
    return AppProgress(
      value: value,
      type: AppProgressType.pomodoro,
      size: size,
      breathingEffect: breathingEffect,
      color: color,
    );
  }
}
