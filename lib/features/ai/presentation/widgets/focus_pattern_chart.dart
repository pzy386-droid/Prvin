import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:prvin/core/theme/theme_exports.dart';
import 'package:prvin/features/ai/domain/entities/analytics_data.dart';

/// 专注模式图表组件
/// 显示不同时间段的专注效果分析
class FocusPatternChart extends StatefulWidget {
  /// 创建专注模式图表组件
  const FocusPatternChart({required this.focusPatterns, super.key});

  /// 专注模式数据列表
  final List<FocusPattern> focusPatterns;

  @override
  State<FocusPatternChart> createState() => _FocusPatternChartState();
}

class _FocusPatternChartState extends State<FocusPatternChart>
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
    if (widget.focusPatterns.isEmpty) {
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
          Text(
            '专注时间分析',
            style: ResponsiveTheme.createResponsiveTextStyle(
              context,
              baseFontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: AppTheme.spacingM),
          SizedBox(
            height: 180,
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return CustomPaint(
                  size: Size(MediaQuery.of(context).size.width - 64, 180),
                  painter: FocusPatternPainter(
                    patterns: widget.focusPatterns,
                    animationValue: _animation.value,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppTheme.spacingM),
          _buildPatternList(),
        ],
      ),
    );
  }

  Widget _buildPatternList() {
    // 按成功率排序
    final sortedPatterns = List<FocusPattern>.from(widget.focusPatterns)
      ..sort((a, b) => b.successRate.compareTo(a.successRate));

    return Column(
      children: sortedPatterns.map((pattern) {
        final isTop = sortedPatterns.indexOf(pattern) == 0;
        return _buildPatternItem(pattern, isTop);
      }).toList(),
    );
  }

  Widget _buildPatternItem(FocusPattern pattern, bool isTop) {
    final successPercentage = (pattern.successRate * 100).toInt();
    final color = _getColorForSuccessRate(pattern.successRate);

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingS),
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: isTop ? color.withValues(alpha: 0.1) : Colors.grey[50],
        borderRadius: BorderRadius.circular(AppTheme.radiusS),
        border: isTop
            ? Border.all(color: color.withValues(alpha: 0.3))
            : null,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingS),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppTheme.radiusS),
            ),
            child: Icon(
              isTop ? Icons.star : Icons.access_time,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: AppTheme.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '${pattern.hourOfDay}:00',
                      style: ResponsiveTheme.createResponsiveTextStyle(
                        context,
                        baseFontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    if (isTop) ...[
                      const SizedBox(width: AppTheme.spacingXS),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.spacingXS,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '最佳',
                          style: ResponsiveTheme.createResponsiveTextStyle(
                            context,
                            baseFontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: AppTheme.spacingXS),
                Text(
                  '平均${pattern.averageFocusMinutes.toInt()}分钟 • $successPercentage%成功率 • ${pattern.sessionCount}次会话',
                  style: ResponsiveTheme.createResponsiveTextStyle(
                    context,
                    baseFontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 40,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: pattern.successRate,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
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
            Icon(Icons.schedule, size: 48, color: Colors.grey[400]),
            const SizedBox(height: AppTheme.spacingM),
            Text(
              '暂无专注模式数据',
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

  Color _getColorForSuccessRate(double successRate) {
    if (successRate >= 0.8) return Colors.green;
    if (successRate >= 0.6) return Colors.orange;
    return Colors.red;
  }
}

/// 专注模式图表绘制器
class FocusPatternPainter extends CustomPainter {
  /// 创建专注模式图表绘制器
  FocusPatternPainter({required this.patterns, required this.animationValue});

  /// 专注模式数据
  final List<FocusPattern> patterns;

  /// 动画值
  final double animationValue;

  @override
  void paint(Canvas canvas, Size size) {
    if (patterns.isEmpty) return;

    const padding = 20.0;
    final chartWidth = size.width - padding * 2;
    final chartHeight = size.height - padding * 2;

    // 绘制24小时时间轴
    _drawTimeAxis(canvas, size, padding);

    // 绘制专注强度条
    _drawFocusBars(canvas, size, padding, chartWidth, chartHeight);

    // 绘制成功率曲线
    _drawSuccessRateCurve(canvas, size, padding, chartWidth, chartHeight);
  }

  void _drawTimeAxis(Canvas canvas, Size size, double padding) {
    final axisPaint = Paint()
      ..color = Colors.grey[400]!
      ..strokeWidth = 1;

    // 绘制底部轴线
    canvas.drawLine(
      Offset(padding, size.height - padding),
      Offset(size.width - padding, size.height - padding),
      axisPaint,
    );

    // 绘制时间刻度
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (var hour = 0; hour < 24; hour += 6) {
      final x = padding + (size.width - padding * 2) * hour / 24;

      // 绘制刻度线
      canvas.drawLine(
        Offset(x, size.height - padding),
        Offset(x, size.height - padding + 5),
        axisPaint,
      );

      // 绘制时间标签
      textPainter.text = TextSpan(
        text: '$hour:00',
        style: TextStyle(color: Colors.grey[600], fontSize: 10),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, size.height - padding + 8),
      );
    }
  }

  void _drawFocusBars(
    Canvas canvas,
    Size size,
    double padding,
    double chartWidth,
    double chartHeight,
  ) {
    if (patterns.isEmpty) return;

    final maxFocusMinutes = patterns
        .map((p) => p.averageFocusMinutes)
        .reduce(math.max);

    for (final pattern in patterns) {
      final x = padding + chartWidth * pattern.hourOfDay / 24;
      final barWidth = chartWidth / 24 * 0.6;
      final normalizedHeight = pattern.averageFocusMinutes / maxFocusMinutes;
      final barHeight = chartHeight * 0.6 * normalizedHeight * animationValue;

      final color = _getColorForSuccessRate(pattern.successRate);
      final paint = Paint()
        ..color = color.withValues(alpha: 0.7)
        ..style = PaintingStyle.fill;

      final rect = Rect.fromLTWH(
        x - barWidth / 2,
        size.height - padding - barHeight,
        barWidth,
        barHeight,
      );

      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(4)),
        paint,
      );
    }
  }

  void _drawSuccessRateCurve(
    Canvas canvas,
    Size size,
    double padding,
    double chartWidth,
    double chartHeight,
  ) {
    if (patterns.length < 2) return;

    final paint = Paint()
      ..color = AppTheme.primaryColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();

    for (var i = 0; i < patterns.length; i++) {
      final pattern = patterns[i];
      final x = padding + chartWidth * pattern.hourOfDay / 24;
      final y = padding + chartHeight * 0.3 * (1 - pattern.successRate);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    // 应用动画
    final pathMetrics = path.computeMetrics();
    final animatedPath = Path();

    for (final pathMetric in pathMetrics) {
      final extractPath = pathMetric.extractPath(
        0,
        pathMetric.length * animationValue,
      );
      animatedPath.addPath(extractPath, Offset.zero);
    }

    canvas.drawPath(animatedPath, paint);

    // 绘制数据点
    for (var i = 0; i < patterns.length; i++) {
      if (i / patterns.length > animationValue) break;

      final pattern = patterns[i];
      final x = padding + chartWidth * pattern.hourOfDay / 24;
      final y = padding + chartHeight * 0.3 * (1 - pattern.successRate);

      canvas.drawCircle(
        Offset(x, y),
        3,
        Paint()..color = AppTheme.primaryColor,
      );
      canvas.drawCircle(Offset(x, y), 1.5, Paint()..color = Colors.white);
    }
  }

  Color _getColorForSuccessRate(double successRate) {
    if (successRate >= 0.8) return Colors.green;
    if (successRate >= 0.6) return Colors.orange;
    return Colors.red;
  }

  @override
  bool shouldRepaint(FocusPatternPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.patterns != patterns;
  }
}
