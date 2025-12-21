import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:prvin/core/theme/theme_exports.dart';
import 'package:prvin/features/ai/domain/entities/analytics_data.dart';

/// 生产力趋势图表组件
/// 显示一段时间内的生产力变化趋势
class ProductivityTrendChart extends StatefulWidget {
  /// 创建生产力趋势图表组件
  const ProductivityTrendChart({required this.trends, super.key});

  /// 趋势数据列表
  final List<ProductivityTrend> trends;

  @override
  State<ProductivityTrendChart> createState() => _ProductivityTrendChartState();
}

class _ProductivityTrendChartState extends State<ProductivityTrendChart>
    with SingleTickerProviderStateMixin {
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
    if (widget.trends.isEmpty) {
      return _buildEmptyState();
    }

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
          Row(
            children: [
              Text(
                '生产力趋势',
                style: ResponsiveTheme.createResponsiveTextStyle(
                  context,
                  baseFontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              const Spacer(),
              _buildLegend(),
            ],
          ),
          const SizedBox(height: AppTheme.spacingL),
          SizedBox(
            height: 200,
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return CustomPaint(
                  size: Size(MediaQuery.of(context).size.width - 64, 200),
                  painter: TrendChartPainter(
                    trends: widget.trends,
                    animationValue: _animation.value,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppTheme.spacingM),
          _buildSummaryStats(),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      children: [
        _buildLegendItem('完成任务', Colors.blue),
        const SizedBox(width: AppTheme.spacingM),
        _buildLegendItem('效率评分', Colors.green),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: AppTheme.spacingXS),
        Text(
          label,
          style: ResponsiveTheme.createResponsiveTextStyle(
            context,
            baseFontSize: 10,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryStats() {
    final avgTasks =
        widget.trends.fold(0, (sum, trend) => sum + trend.completedTasks) /
        widget.trends.length;

    final avgEfficiency =
        widget.trends.fold(0, (sum, trend) => sum + trend.efficiencyScore) /
        widget.trends.length;

    final totalFocusHours =
        widget.trends.fold(0, (sum, trend) => sum + trend.focusMinutes) / 60;

    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            '平均任务',
            avgTasks.toStringAsFixed(1),
            '个/天',
            Icons.task_alt,
            Colors.blue,
          ),
        ),
        Expanded(
          child: _buildStatItem(
            '平均效率',
            avgEfficiency.toStringAsFixed(0),
            '分',
            Icons.trending_up,
            Colors.green,
          ),
        ),
        Expanded(
          child: _buildStatItem(
            '专注时间',
            totalFocusHours.toStringAsFixed(1),
            '小时',
            Icons.access_time,
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(
    String title,
    String value,
    String unit,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingS),
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingXS),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusS),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(height: AppTheme.spacingXS),
          Text(
            title,
            style: ResponsiveTheme.createResponsiveTextStyle(
              context,
              baseFontSize: 10,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: AppTheme.spacingXS),
          RichText(
            text: TextSpan(
              text: value,
              style: ResponsiveTheme.createResponsiveTextStyle(
                context,
                baseFontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              children: [
                TextSpan(
                  text: unit,
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
            Icon(Icons.trending_up, size: 48, color: Colors.grey[400]),
            const SizedBox(height: AppTheme.spacingM),
            Text(
              '暂无趋势数据',
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
}

/// 趋势图表绘制器
class TrendChartPainter extends CustomPainter {
  /// 创建趋势图表绘制器
  TrendChartPainter({required this.trends, required this.animationValue});

  /// 趋势数据
  final List<ProductivityTrend> trends;

  /// 动画值
  final double animationValue;

  @override
  void paint(Canvas canvas, Size size) {
    if (trends.isEmpty) return;

    const padding = 20.0;
    final chartWidth = size.width - padding * 2;
    final chartHeight = size.height - padding * 2;

    // 绘制网格线
    _drawGrid(canvas, size, padding, chartWidth);

    // 绘制任务完成数量线
    _drawTasksLine(canvas, size, padding, chartWidth, chartHeight);

    // 绘制效率评分线
    _drawEfficiencyLine(canvas, size, padding, chartWidth, chartHeight);

    // 绘制数据点
    _drawDataPoints(canvas, size, padding, chartWidth, chartHeight);
  }

  void _drawGrid(Canvas canvas, Size size, double padding, double chartWidth) {
    final gridPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.2)
      ..strokeWidth = 1;

    // 绘制水平网格线
    for (var i = 0; i <= 4; i++) {
      final y = padding + (size.height - padding * 2) * i / 4;
      canvas.drawLine(
        Offset(padding, y),
        Offset(size.width - padding, y),
        gridPaint,
      );
    }

    // 绘制垂直网格线
    for (var i = 0; i < trends.length; i++) {
      final x = padding + chartWidth * i / (trends.length - 1);
      canvas.drawLine(
        Offset(x, padding),
        Offset(x, size.height - padding),
        gridPaint,
      );
    }
  }

  void _drawTasksLine(
    Canvas canvas,
    Size size,
    double padding,
    double chartWidth,
    double chartHeight,
  ) {
    final maxTasks = trends.map((t) => t.completedTasks).reduce(math.max);
    final minTasks = trends.map((t) => t.completedTasks).reduce(math.min);
    final taskRange = maxTasks - minTasks;

    if (taskRange == 0) return;

    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();

    for (var i = 0; i < trends.length; i++) {
      final x = padding + chartWidth * i / (trends.length - 1);
      final normalizedValue = (trends[i].completedTasks - minTasks) / taskRange;
      final y = padding + chartHeight * (1 - normalizedValue);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    // 应用动画
    final animatedPath = _createAnimatedPath(path, animationValue);
    canvas.drawPath(animatedPath, paint);
  }

  void _drawEfficiencyLine(
    Canvas canvas,
    Size size,
    double padding,
    double chartWidth,
    double chartHeight,
  ) {
    final maxEfficiency = trends.map((t) => t.efficiencyScore).reduce(math.max);
    final minEfficiency = trends.map((t) => t.efficiencyScore).reduce(math.min);
    final efficiencyRange = maxEfficiency - minEfficiency;

    if (efficiencyRange == 0) return;

    final paint = Paint()
      ..color = Colors.green
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();

    for (var i = 0; i < trends.length; i++) {
      final x = padding + chartWidth * i / (trends.length - 1);
      final normalizedValue =
          (trends[i].efficiencyScore - minEfficiency) / efficiencyRange;
      final y = padding + chartHeight * (1 - normalizedValue);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    // 应用动画
    final animatedPath = _createAnimatedPath(path, animationValue);
    canvas.drawPath(animatedPath, paint);
  }

  void _drawDataPoints(
    Canvas canvas,
    Size size,
    double padding,
    double chartWidth,
    double chartHeight,
  ) {
    final maxTasks = trends.map((t) => t.completedTasks).reduce(math.max);
    final minTasks = trends.map((t) => t.completedTasks).reduce(math.min);
    final taskRange = maxTasks - minTasks;

    final maxEfficiency = trends.map((t) => t.efficiencyScore).reduce(math.max);
    final minEfficiency = trends.map((t) => t.efficiencyScore).reduce(math.min);
    final efficiencyRange = maxEfficiency - minEfficiency;

    for (var i = 0; i < trends.length; i++) {
      if (i / trends.length > animationValue) break;

      final x = padding + chartWidth * i / (trends.length - 1);

      // 绘制任务数据点
      if (taskRange > 0) {
        final normalizedTasks =
            (trends[i].completedTasks - minTasks) / taskRange;
        final taskY = padding + chartHeight * (1 - normalizedTasks);

        canvas.drawCircle(Offset(x, taskY), 4, Paint()..color = Colors.blue);
        canvas.drawCircle(Offset(x, taskY), 2, Paint()..color = Colors.white);
      }

      // 绘制效率数据点
      if (efficiencyRange > 0) {
        final normalizedEfficiency =
            (trends[i].efficiencyScore - minEfficiency) / efficiencyRange;
        final efficiencyY = padding + chartHeight * (1 - normalizedEfficiency);

        canvas.drawCircle(
          Offset(x, efficiencyY),
          4,
          Paint()..color = Colors.green,
        );
        canvas.drawCircle(
          Offset(x, efficiencyY),
          2,
          Paint()..color = Colors.white,
        );
      }
    }
  }

  Path _createAnimatedPath(Path originalPath, double animationValue) {
    final pathMetrics = originalPath.computeMetrics();
    final animatedPath = Path();

    for (final pathMetric in pathMetrics) {
      final extractPath = pathMetric.extractPath(
        0,
        pathMetric.length * animationValue,
      );
      animatedPath.addPath(extractPath, Offset.zero);
    }

    return animatedPath;
  }

  @override
  bool shouldRepaint(TrendChartPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.trends != trends;
  }
}
