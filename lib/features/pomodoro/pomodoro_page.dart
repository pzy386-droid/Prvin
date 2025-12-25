import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:prvin/core/services/help_system_service.dart';
import 'package:prvin/core/theme/theme_exports.dart';
import 'package:prvin/core/widgets/help_system_widgets.dart';

/// 番茄钟主页面
/// 提供沉浸式计时器界面，包含圆形进度动画和呼吸效果
class PomodoroPage extends StatefulWidget {
  /// 创建番茄钟页面
  const PomodoroPage({super.key});

  @override
  State<PomodoroPage> createState() => _PomodoroPageState();
}

class _PomodoroPageState extends State<PomodoroPage>
    with TickerProviderStateMixin {
  // 计时器状态
  PomodoroState _currentState = PomodoroState.idle;
  final Duration _totalDuration = const Duration(minutes: 25); // 默认25分钟
  Duration _remainingTime = const Duration(minutes: 25);

  // 动画控制器
  late AnimationController _progressController;
  late AnimationController _breathingController;
  late AnimationController _backgroundController;
  late AnimationController _pulseController;

  // 动画
  late Animation<double> _progressAnimation;
  late Animation<double> _breathingAnimation;
  late Animation<Color?> _backgroundAnimation;
  late Animation<double> _pulseAnimation;

  // 计时器
  // DateTime? _startTime; // 暂时注释，后续实现时使用

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    // 进度动画控制器
    _progressController = AnimationController(
      duration: _totalDuration,
      vsync: this,
    );

    // 呼吸动画控制器
    _breathingController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    // 背景动画控制器
    _backgroundController = AnimationController(
      duration: AnimationTheme.longAnimationDuration,
      vsync: this,
    );

    // 脉冲动画控制器
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // 进度动画
    _progressAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.linear),
    );

    // 呼吸动画
    _breathingAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
    );

    // 背景颜色动画
    _backgroundAnimation =
        ColorTween(
          begin: AppTheme.primaryColor,
          end: AppTheme.primaryColor.withValues(alpha: 0.8),
        ).animate(
          CurvedAnimation(
            parent: _backgroundController,
            curve: AnimationTheme.smoothCurve,
          ),
        );

    // 脉冲动画
    _pulseAnimation = Tween<double>(begin: 1, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.elasticOut),
    );

    // 启动呼吸动画
    _breathingController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _progressController.dispose();
    _breathingController.dispose();
    _backgroundController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _backgroundAnimation,
          _breathingAnimation,
          _progressAnimation,
          _pulseAnimation,
        ]),
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _backgroundAnimation.value ?? AppTheme.primaryColor,
                  (_backgroundAnimation.value ?? AppTheme.primaryColor)
                      .withValues(alpha: 0.6),
                  AppTheme.primaryColor.withValues(alpha: 0.3),
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  _buildAppBar(),
                  Expanded(child: _buildTimerInterface()),
                  _buildControlButtons(),
                  const SizedBox(height: AppTheme.spacingXL),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      child: Row(
        children: [
          MicroInteractions.createInteractiveContainer(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.all(AppTheme.spacingS),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppTheme.radiusS),
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          const Spacer(),
          Text(
            '专注时间',
            style: ResponsiveTheme.createResponsiveTextStyle(
              context,
              baseFontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          Row(
            children: [
              HelpButton(helpContext: HelpContext.pomodoroTimer, size: 16),
              const SizedBox(width: 12),
              MicroInteractions.createInteractiveContainer(
                onTap: _showStatsPage,
                child: Container(
                  padding: const EdgeInsets.all(AppTheme.spacingS),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppTheme.radiusS),
                  ),
                  child: const Icon(
                    Icons.bar_chart,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.spacingS),
              MicroInteractions.createInteractiveContainer(
                onTap: _showSettingsDialog,
                child: Container(
                  padding: const EdgeInsets.all(AppTheme.spacingS),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppTheme.radiusS),
                  ),
                  child: const Icon(
                    Icons.settings,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimerInterface() {
    return Center(
      child: Transform.scale(
        scale: _breathingAnimation.value,
        child: Transform.scale(
          scale: _pulseAnimation.value,
          child: SizedBox(
            width: 280,
            height: 280,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 背景圆环
                _buildBackgroundCircle(),

                // 进度圆环
                _buildProgressCircle(),

                // 中心内容
                _buildCenterContent(),

                // 微光效果
                _buildGlowEffect(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundCircle() {
    return Container(
      width: 280,
      height: 280,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCircle() {
    return SizedBox(
      width: 280,
      height: 280,
      child: CustomPaint(
        painter: ProgressCirclePainter(
          progress: _progressAnimation.value,
          strokeWidth: 8,
          backgroundColor: Colors.white.withValues(alpha: 0.3),
          progressColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildCenterContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 剩余时间显示
        Text(
          _formatTime(_remainingTime),
          style: ResponsiveTheme.createResponsiveTextStyle(
            context,
            baseFontSize: 48,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),

        const SizedBox(height: AppTheme.spacingS),

        // 状态文本
        Text(
          _getStateText(),
          style: ResponsiveTheme.createResponsiveTextStyle(
            context,
            baseFontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),

        const SizedBox(height: AppTheme.spacingM),

        // 进度百分比
        Text(
          '${(_progressAnimation.value * 100).toInt()}%',
          style: ResponsiveTheme.createResponsiveTextStyle(
            context,
            baseFontSize: 14,
            fontWeight: FontWeight.w400,
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildGlowEffect() {
    return Container(
      width: 300,
      height: 300,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.3),
            blurRadius: 30,
            spreadRadius: 10,
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.1),
            blurRadius: 60,
            spreadRadius: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildControlButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingXL),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // 重置按钮
          _buildControlButton(
            icon: Icons.refresh,
            label: '重置',
            onTap: _resetTimer,
            isSecondary: true,
          ),

          // 主要控制按钮
          _buildMainControlButton(),

          // 暂停/继续按钮
          _buildControlButton(
            icon: _currentState == PomodoroState.running
                ? Icons.pause
                : Icons.play_arrow,
            label: _currentState == PomodoroState.running ? '暂停' : '开始',
            onTap: _toggleTimer,
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isSecondary = false,
  }) {
    return MicroInteractions.createInteractiveContainer(
      onTap: onTap,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSecondary
              ? Colors.white.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.9),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 28,
              color: isSecondary ? Colors.white : AppTheme.primaryColor,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: isSecondary ? Colors.white : AppTheme.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainControlButton() {
    return MicroInteractions.createInteractiveContainer(
      onTap: _toggleTimer,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 15,
              spreadRadius: 3,
            ),
          ],
        ),
        child: Icon(
          _currentState == PomodoroState.running
              ? Icons.pause
              : Icons.play_arrow,
          size: 40,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }

  void _toggleTimer() {
    setState(() {
      if (_currentState == PomodoroState.idle ||
          _currentState == PomodoroState.paused) {
        _startTimer();
      } else if (_currentState == PomodoroState.running) {
        _pauseTimer();
      }
    });
  }

  void _startTimer() {
    setState(() {
      _currentState = PomodoroState.running;
      // _startTime = DateTime.now(); // 暂时注释，后续实现时使用
    });

    _backgroundController.forward();
    _progressController.forward();
    _pulseController.forward();

    // 启动计时器逻辑
    _startCountdown();
  }

  void _pauseTimer() {
    setState(() {
      _currentState = PomodoroState.paused;
    });

    _progressController.stop();
    _backgroundController.reverse();
  }

  void _resetTimer() {
    setState(() {
      _currentState = PomodoroState.idle;
      _remainingTime = _totalDuration;
    });

    _progressController.reset();
    _backgroundController.reset();
    _pulseController.reset();
  }

  void _startCountdown() {
    // 这里应该实现实际的倒计时逻辑
    // 为了演示，我们使用动画控制器来模拟
    _progressController.addListener(() {
      if (mounted) {
        setState(() {
          final elapsed = _totalDuration * _progressController.value;
          _remainingTime = _totalDuration - elapsed;

          if (_remainingTime.inSeconds <= 0) {
            _completeSession();
          }
        });
      }
    });
  }

  void _completeSession() {
    setState(() {
      _currentState = PomodoroState.completed;
      _remainingTime = Duration.zero;
    });

    // 播放完成动画
    _pulseController.repeat(reverse: true);

    // 显示完成对话框
    _showCompletionDialog();
  }

  void _showStatsPage() {
    // 显示简单的统计信息对话框，而不是导航到不存在的页面
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('📊 专注统计'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('今日专注时间: 0 分钟'),
            SizedBox(height: 8),
            Text('本周专注时间: 0 分钟'),
            SizedBox(height: 8),
            Text('完成的番茄钟: 0 个'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('番茄钟设置'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('专注时间'),
              subtitle: Text('${_totalDuration.inMinutes} 分钟'),
              trailing: const Icon(Icons.edit),
              onTap: () {
                // TODO: 实现时间设置
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: const Text('短休息'),
              subtitle: const Text('5 分钟'),
              trailing: const Icon(Icons.edit),
              onTap: () {
                // TODO: 实现短休息设置
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: const Text('长休息'),
              subtitle: const Text('15 分钟'),
              trailing: const Icon(Icons.edit),
              onTap: () {
                // TODO: 实现长休息设置
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  void _showCompletionDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('🎉 专注时间完成！'),
        content: const Text('恭喜你完成了一个番茄钟！现在可以休息一下。'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resetTimer();
            },
            child: const Text('开始休息'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resetTimer();
            },
            child: const Text('继续专注'),
          ),
        ],
      ),
    );
  }

  String _formatTime(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String _getStateText() {
    switch (_currentState) {
      case PomodoroState.idle:
        return '准备开始专注';
      case PomodoroState.running:
        return '专注进行中...';
      case PomodoroState.paused:
        return '已暂停';
      case PomodoroState.completed:
        return '专注完成！';
    }
  }
}

/// 番茄钟状态枚举
enum PomodoroState {
  idle, // 空闲状态
  running, // 运行中
  paused, // 暂停
  completed, // 完成
}

/// 自定义进度圆环绘制器
class ProgressCirclePainter extends CustomPainter {
  ProgressCirclePainter({
    required this.progress,
    required this.strokeWidth,
    required this.backgroundColor,
    required this.progressColor,
  });
  final double progress;
  final double strokeWidth;
  final Color backgroundColor;
  final Color progressColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // 绘制背景圆环
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // 绘制进度圆环
    final progressPaint = Paint()
      ..color = progressColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // 从顶部开始
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(ProgressCirclePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.progressColor != progressColor;
  }
}
