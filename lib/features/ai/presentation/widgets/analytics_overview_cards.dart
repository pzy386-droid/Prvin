import 'package:flutter/material.dart';
import 'package:prvin/core/theme/theme_exports.dart';
import 'package:prvin/features/ai/domain/entities/analytics_data.dart';

/// 分析概览卡片组件
/// 显示关键统计数据的卡片网格
class AnalyticsOverviewCards extends StatelessWidget {
  /// 创建分析概览卡片组件
  const AnalyticsOverviewCards({required this.analyticsData, super.key});

  /// 分析数据
  final AnalyticsData analyticsData;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '数据概览',
          style: ResponsiveTheme.createResponsiveTextStyle(
            context,
            baseFontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: AppTheme.spacingM),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: AppTheme.spacingM,
          mainAxisSpacing: AppTheme.spacingM,
          childAspectRatio: 1.2,
          children: [
            _buildOverviewCard(
              context,
              title: '总工作时间',
              value:
                  '${(analyticsData.totalWorkMinutes / 60).toStringAsFixed(1)}h',
              subtitle: '本周累计',
              icon: Icons.access_time,
              color: Colors.blue,
            ),
            _buildOverviewCard(
              context,
              title: '任务完成率',
              value: '${(analyticsData.completionRate * 100).toInt()}%',
              subtitle: '平均完成率',
              icon: Icons.check_circle,
              color: Colors.green,
            ),
            _buildOverviewCard(
              context,
              title: '日均任务',
              value: analyticsData.averageDailyCompletedTasks.toStringAsFixed(
                1,
              ),
              subtitle: '每日完成',
              icon: Icons.task_alt,
              color: Colors.orange,
            ),
            _buildOverviewCard(
              context,
              title: '最佳时段',
              value: _formatBestHours(analyticsData.bestFocusHours),
              subtitle: '专注黄金时间',
              icon: Icons.schedule,
              color: Colors.purple,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOverviewCard(
    BuildContext context, {
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return MicroInteractions.createInteractiveContainer(
      onTap: () {
        // TODO: 添加卡片点击交互
      },
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingM),
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
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacingXS),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusS),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const Spacer(),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingS),
            Text(
              title,
              style: ResponsiveTheme.createResponsiveTextStyle(
                context,
                baseFontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: AppTheme.spacingXS),
            Text(
              value,
              style: ResponsiveTheme.createResponsiveTextStyle(
                context,
                baseFontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: AppTheme.spacingXS),
            Text(
              subtitle,
              style: ResponsiveTheme.createResponsiveTextStyle(
                context,
                baseFontSize: 10,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatBestHours(List<int> hours) {
    if (hours.isEmpty) return '暂无数据';
    if (hours.length == 1) return '${hours.first}:00';

    final sortedHours = List<int>.from(hours)..sort();
    return '${sortedHours.first}:00-${sortedHours.last}:00';
  }
}
