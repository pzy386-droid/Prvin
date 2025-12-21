import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:prvin/core/theme/theme_exports.dart';

/// 时间分配图表组件
/// 使用饼图展示不同类别的时间分配
class TimeDistributionChart extends StatefulWidget {
  /// 创建时间分配图表组件
  const TimeDistributionChart({required this.timeDistribution, super.key});

  /// 时间分配数据（类别 -> 分钟数）
  final Map<String, int> timeDistribution;

  @override
  State<TimeDistributionChart> createState() => _TimeDistributionChartState();
}

class _TimeDistributionChartState extends State<TimeDistributionChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AnimationTheme.mediumAnimationDuration,
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
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
    if (widget.timeDistribution.isEmpty) {
      return _buildEmptyState();
    }

    final totalMinutes = widget.timeDistribution.values.fold(
      0,
      (sum, minutes) => sum + minutes,
    );

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '时间分配',
            style: ResponsiveTheme.createResponsiveTextStyle(
              context,
              baseFontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: AppTheme.spacingM),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return CustomPaint(
                      size: const Size(200, 200),
                      painter: PieChartPainter(
                        data: widget.timeDistribution,
                        animationValue: _animation.value,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: AppTheme.spacingL),
              Expanded(child: _buildLegend(totalMinutes)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(int totalMinutes) {
    final colors = _getColors();
    final entries = widget.timeDistribution.entries.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: entries.asMap().entries.map((entry) {
        final index = entry.key;
        final category = entry.value.key;
        final minutes = entry.value.value;
        final percentage = (minutes / totalMinutes * 100).toInt();
        final color = colors[index % colors.length];

        return Padding(
          padding: const EdgeInsets.only(bottom: AppTheme.spacingS),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: AppTheme.spacingXS),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category,
                      style: ResponsiveTheme.createResponsiveTextStyle(
                        context,
                        baseFontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '$percentage% (${(minutes / 60).toStringAsFixed(1)}h)',
                      style: ResponsiveTheme.createResponsiveTextStyle(
                        context,
                        baseFontSize: 10,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.pie_chart_outline, size: 48, color: Colors.grey[400]),
            const SizedBox(height: AppTheme.spacingM),
            Text(
              '暂无时间分配数据',
              style: ResponsiveTheme.createResponsiveTextStyle(
                context,
                baseFontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Color> _getColors() {
    return [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
    ];
  }
}

/// 饼图绘制器
class PieChartPainter extends CustomPainter {
  /// 创建饼图绘制器
  PieChartPainter({required this.data, required this.animationValue});

  /// 数据
  final Map<String, int> data;

  /// 动画值
  final double animationValue;

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final totalValue = data.values.fold(0, (sum, value) => sum + value);

    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
    ];

    var startAngle = -math.pi / 2; // 从顶部开始

    data.entries.toList().asMap().forEach((index, entry) {
      final value = entry.value;
      final sweepAngle = (value / totalValue) * 2 * math.pi * animationValue;
      final color = colors[index % colors.length];

      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      // 绘制边框
      final borderPaint = Paint()
        ..color = Colors.white
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        borderPaint,
      );

      startAngle += sweepAngle;
    });

    // 绘制中心白色圆圈
    final centerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius * 0.5, centerPaint);
  }

  @override
  bool shouldRepaint(PieChartPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.data != data;
  }
}
