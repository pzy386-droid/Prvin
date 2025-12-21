import 'package:flutter/material.dart';
import 'package:prvin/core/theme/theme_exports.dart';

/// Lottie动画类型枚举
enum AppLottieType {
  /// 加载动画
  loading,

  /// 成功动画
  success,

  /// 错误动画
  error,

  /// 完成动画
  complete,

  /// 空状态动画
  empty,

  /// 番茄钟完成动画
  pomodoroComplete,

  /// 任务完成动画
  taskComplete,
}

/// 应用Lottie动画组件
/// 提供统一的Lottie动画管理和播放功能
class AppLottie extends StatefulWidget {
  /// 创建Lottie动画组件
  const AppLottie({
    required this.type,
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.repeat = true,
    this.reverse = false,
    this.animate = true,
    this.onComplete,
    this.controller,
  });

  /// 动画类型
  final AppLottieType type;

  /// 宽度
  final double? width;

  /// 高度
  final double? height;

  /// 适应方式
  final BoxFit fit;

  /// 是否重复播放
  final bool repeat;

  /// 是否反向播放
  final bool reverse;

  /// 是否自动播放
  final bool animate;

  /// 完成回调
  final VoidCallback? onComplete;

  /// 动画控制器
  final AnimationController? controller;

  @override
  State<AppLottie> createState() => _AppLottieState();
}

class _AppLottieState extends State<AppLottie>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller =
        widget.controller ??
        AnimationController(duration: _getAnimationDuration(), vsync: this);

    _animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
        if (widget.repeat) {
          if (widget.reverse) {
            _controller.reverse();
          } else {
            _controller.reset();
            _controller.forward();
          }
        }
      } else if (status == AnimationStatus.dismissed &&
          widget.repeat &&
          widget.reverse) {
        _controller.forward();
      }
    });

    if (widget.animate) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  Duration _getAnimationDuration() {
    switch (widget.type) {
      case AppLottieType.loading:
        return AnimationTheme.extraLongAnimationDuration;
      case AppLottieType.success:
      case AppLottieType.complete:
      case AppLottieType.taskComplete:
        return AnimationTheme.longAnimationDuration;
      case AppLottieType.error:
        return AnimationTheme.mediumAnimationDuration;
      case AppLottieType.empty:
        return AnimationTheme.longAnimationDuration;
      case AppLottieType.pomodoroComplete:
        return const Duration(milliseconds: 2000);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 由于这是一个演示项目，我们使用简单的图标动画来模拟Lottie效果
    // 在实际项目中，这里会使用lottie包来加载真实的Lottie动画文件
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform.scale(
            scale: 0.5 + (_animation.value * 0.5),
            child: Opacity(
              opacity: _animation.value,
              child: _buildAnimationContent(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnimationContent() {
    final theme = Theme.of(context);

    switch (widget.type) {
      case AppLottieType.loading:
        return _buildLoadingAnimation();
      case AppLottieType.success:
        return _buildSuccessAnimation(theme);
      case AppLottieType.error:
        return _buildErrorAnimation(theme);
      case AppLottieType.complete:
        return _buildCompleteAnimation(theme);
      case AppLottieType.empty:
        return _buildEmptyAnimation(theme);
      case AppLottieType.pomodoroComplete:
        return _buildPomodoroCompleteAnimation(theme);
      case AppLottieType.taskComplete:
        return _buildTaskCompleteAnimation(theme);
    }
  }

  Widget _buildLoadingAnimation() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _controller.value * 2 * 3.14159,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryColor,
                  AppTheme.primaryColor.withValues(alpha: 0.3),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Icon(Icons.refresh, color: Colors.white, size: 30),
          ),
        );
      },
    );
  }

  Widget _buildSuccessAnimation(ThemeData theme) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppTheme.successColor,
        boxShadow: [
          BoxShadow(
            color: AppTheme.successColor.withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform.scale(
            scale: 0.8 + (_animation.value * 0.2),
            child: const Icon(Icons.check, color: Colors.white, size: 40),
          );
        },
      ),
    );
  }

  Widget _buildErrorAnimation(ThemeData theme) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppTheme.errorColor,
        boxShadow: [
          BoxShadow(
            color: AppTheme.errorColor.withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform.rotate(
            angle: _animation.value * 0.1,
            child: const Icon(Icons.close, color: Colors.white, size: 40),
          );
        },
      ),
    );
  }

  Widget _buildCompleteAnimation(ThemeData theme) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const RadialGradient(
              colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
              stops: [0.3, 1.0],
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withValues(alpha: 0.4),
                blurRadius: 30 * _animation.value,
                spreadRadius: 10 * _animation.value,
              ),
            ],
          ),
          child: Transform.scale(
            scale: 0.6 + (_animation.value * 0.4),
            child: const Icon(Icons.star, color: Colors.white, size: 50),
          ),
        );
      },
    );
  }

  Widget _buildEmptyAnimation(ThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, -10 * _animation.value),
              child: Icon(
                Icons.inbox_outlined,
                size: 80,
                color: Colors.grey.shade400,
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        Text(
          '暂无数据',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildPomodoroCompleteAnimation(ThemeData theme) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                AppTheme.pomodoroWorkColor,
                AppTheme.pomodoroWorkColor.withValues(alpha: 0.7),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.pomodoroWorkColor.withValues(alpha: 0.5),
                blurRadius: 40 * _animation.value,
                spreadRadius: 15 * _animation.value,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Transform.scale(
                scale: 0.5 + (_animation.value * 0.5),
                child: const Icon(Icons.timer, color: Colors.white, size: 60),
              ),
              Positioned.fill(
                child: Transform.rotate(
                  angle: _animation.value * 2 * 3.14159,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTaskCompleteAnimation(ThemeData theme) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // 外圈动画
            Transform.scale(
              scale: _animation.value * 2,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.successColor.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
              ),
            ),
            // 内圈动画
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.successColor,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.successColor.withValues(alpha: 0.4),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Transform.scale(
                scale: 0.7 + (_animation.value * 0.3),
                child: const Icon(
                  Icons.task_alt,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// 简化的Lottie动画组件
/// 用于快速创建常用的动画效果
class SimpleLottie {
  /// 创建加载动画
  static Widget loading({double? size, Color? color}) {
    return AppLottie(
      type: AppLottieType.loading,
      width: size ?? 60,
      height: size ?? 60,
    );
  }

  /// 创建成功动画
  static Widget success({double? size, VoidCallback? onComplete}) {
    return AppLottie(
      type: AppLottieType.success,
      width: size ?? 80,
      height: size ?? 80,
      repeat: false,
      onComplete: onComplete,
    );
  }

  /// 创建错误动画
  static Widget error({double? size, VoidCallback? onComplete}) {
    return AppLottie(
      type: AppLottieType.error,
      width: size ?? 80,
      height: size ?? 80,
      repeat: false,
      onComplete: onComplete,
    );
  }

  /// 创建完成动画
  static Widget complete({double? size, VoidCallback? onComplete}) {
    return AppLottie(
      type: AppLottieType.complete,
      width: size ?? 100,
      height: size ?? 100,
      repeat: false,
      onComplete: onComplete,
    );
  }

  /// 创建空状态动画
  static Widget empty({double? size, String? message}) {
    return AppLottie(
      type: AppLottieType.empty,
      width: size ?? 120,
      height: size ?? 120,
      repeat: false,
    );
  }

  /// 创建番茄钟完成动画
  static Widget pomodoroComplete({double? size, VoidCallback? onComplete}) {
    return AppLottie(
      type: AppLottieType.pomodoroComplete,
      width: size ?? 120,
      height: size ?? 120,
      repeat: false,
      onComplete: onComplete,
    );
  }

  /// 创建任务完成动画
  static Widget taskComplete({double? size, VoidCallback? onComplete}) {
    return AppLottie(
      type: AppLottieType.taskComplete,
      width: size ?? 60,
      height: size ?? 60,
      repeat: false,
      onComplete: onComplete,
    );
  }
}
