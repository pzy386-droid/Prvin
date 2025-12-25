import 'package:flutter/material.dart';
import 'package:prvin/features/pomodoro/domain/entities/pomodoro_session.dart';

/// 统计图表组件
class StatsChart extends StatefulWidget {
  /// 创建统计图表
  const StatsChart({required this.sessions, super.key, this.height = 200.0});

  /// 会话数据
  final List<PomodoroSession> sessions;

  /// 图表高度
  final double height;

  @override
  State<StatsChart> createState() => StatsChartState();
}

/// 统计图表状态
class StatsChartState extends State<StatsChart> {
  @override
  Widget build(BuildContext context) {
    if (widget.sessions.isEmpty) {
      return SizedBox(
        height: widget.height,
        child: const Center(child: Text('No data available')),
      );
    }

    return SizedBox(
      height: widget.height,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Session Statistics',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(child: _buildChart()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChart() {
    final completedSessions = widget.sessions.where((s) => s.completed).length;
    final totalSessions = widget.sessions.length;
    final completionRate = totalSessions > 0
        ? completedSessions / totalSessions
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Total Sessions: $totalSessions'),
        Text('Completed: $completedSessions'),
        Text('Completion Rate: ${(completionRate * 100).toStringAsFixed(1)}%'),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: completionRate,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(
            Theme.of(context).primaryColor,
          ),
        ),
      ],
    );
  }
}
