import 'package:flutter/material.dart';
import 'package:prvin/core/theme/theme_exports.dart';
import 'package:prvin/core/widgets/widgets_exports.dart';
import 'package:prvin/features/pomodoro/models/pomodoro_session.dart';
import 'package:prvin/features/pomodoro/models/pomodoro_stats.dart';

/// 统计图表组件
class StatsChart extends StatefulWidget {
  /// 创建统计图表
  const StatsChart({required this.sessions, super.key, this.height = 200});

  /// 会话数据
  final List<PomodoroSession> sessions;

  /// 图表高度
  final double height;

  @override
  State<StatsChart> createState() => _StatsChartState();
}

class _StatsChartState extends State<StatsChart> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: AnimationTheme.longAnimationDuration,
      vsync: this,
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: AnimationTheme.smoothCurve,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '本周专注趋势',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: AppTheme.spacingL),

          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return SizedBox(height: widget.height, child: _buildChart());
            },
          ),

          const SizedBox(height: AppTheme.spacingM),
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildChart() {
    final dailyStats = _calculateDailyStats();

    if (dailyStats.isEmpty) {
      return const Center(
        child: Text('暂无数据', style: TextStyle(color: Colors.grey)),
      );
    }

    return CustomPaint(
      size: Size.infinite,
      painter: ChartPainter(
        dailyStats: dailyStats,
        animation: _animation.value,
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildLegendItem('专注时间', AppTheme.primaryColor),
        _buildLegendItem('休息时间', AppTheme.successColor),
        _buildLegendItem('完成会话', AppTheme.warningColor),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: AppTheme.spacingXS),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  List<DailyStats> _calculateDailyStats() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final dailyStats = <DailyStats>[];

    for (var i = 0; i < 7; i++) {
      final date = weekStart.add(Duration(days: i));
      final dayStart = DateTime(date.year, date.month, date.day);
      final dayEnd = dayStart.add(const Duration(days: 1));

      final daySessions = widget.sessions.where((session) {
        return session.startTime.isAfter(dayStart) &&
            session.startTime.isBefore(dayEnd);
      }).toList();

      var focusTime = Duration.zero;
      var breakTime = Duration.zero;
      var completedSessions = 0;

      for (final session in daySessions) {
        if (session.isWorkSession) {
          focusTime += session.actualDuration;
        } else {
          breakTime += session.actualDuration;
        }

        if (session.completed) {
          completedSessions++;
        }
      }

      dailyStats.add(
        DailyStats(
          date: dayStart,
          sessions: daySessions.length,
          focusTime: focusTime,
          breakTime: breakTime,
          completedSessions: completedSessions,
        ),
      );
    }

    return dailyStats;
  }
}

/// 图表绘制器
class ChartPainter extends CustomPainter {
  /// 创建图表绘制器
  ChartPainter({required this.dailyStats, required this.animation});

  /// 每日统计数据
  final List<DailyStats> dailyStats;

  /// 动画进度
  final double animation;

  @override
  void paint(Canvas canvas, Size size) {
    if (dailyStats.isEmpty) return;

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 2;

    final barWidth = size.width / (dailyStats.length * 2);
    final maxValue = dailyStats
        .map((stats) => stats.focusTime.inMinutes + stats.breakTime.inMinutes)
        .reduce((a, b) => a > b ? a : b)
        .toDouble();

    if (maxValue == 0) return;

    for (var i = 0; i < dailyStats.length; i++) {
      final stats = dailyStats[i];
      final x = (i * 2 + 1) * barWidth;

      // 绘制专注时间柱状图
      final focusHeight =
          (stats.focusTime.inMinutes / maxValue) *
          size.height *
          0.8 *
          animation;
      paint.color = AppTheme.primaryColor;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            x - barWidth * 0.3,
            size.height - focusHeight,
            barWidth * 0.6,
            focusHeight,
          ),
          const Radius.circular(4),
        ),
        paint,
      );

      // 绘制休息时间柱状图
      final breakHeight =
          (stats.breakTime.inMinutes / maxValue) *
          size.height *
          0.8 *
          animation;
      paint.color = AppTheme.successColor;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            x + barWidth * 0.1,
            size.height - breakHeight,
            barWidth * 0.6,
            breakHeight,
          ),
          const Radius.circular(4),
        ),
        paint,
      );

      // 绘制日期标签
      final textPainter = TextPainter(
        text: TextSpan(
          text: _getWeekdayName(stats.date.weekday),
          style: const TextStyle(color: Colors.grey, fontSize: 10),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, size.height - 15),
      );
    }
  }

  String _getWeekdayName(int weekday) {
    const weekdays = ['一', '二', '三', '四', '五', '六', '日'];
    return weekdays[weekday - 1];
  }

  @override
  bool shouldRepaint(ChartPainter oldDelegate) {
    return oldDelegate.animation != animation ||
        oldDelegate.dailyStats != dailyStats;
  }
}
