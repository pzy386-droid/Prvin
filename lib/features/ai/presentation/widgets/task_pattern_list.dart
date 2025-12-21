import 'package:flutter/material.dart';
import 'package:prvin/core/theme/theme_exports.dart';
import 'package:prvin/features/ai/domain/entities/analytics_data.dart';

/// 任务模式列表组件
/// 显示AI识别的任务模式和建议
class TaskPatternList extends StatelessWidget {
  /// 创建任务模式列表组件
  const TaskPatternList({required this.taskPatterns, super.key});

  /// 任务模式数据列表
  final List<TaskPattern> taskPatterns;

  @override
  Widget build(BuildContext context) {
    if (taskPatterns.isEmpty) {
      return _buildEmptyState(context);
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
                '任务模式分析',
                style: ResponsiveTheme.createResponsiveTextStyle(
                  context,
                  baseFontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingS,
                  vertical: AppTheme.spacingXS,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusS),
                ),
                child: Text(
                  '${taskPatterns.length}个模式',
                  style: ResponsiveTheme.createResponsiveTextStyle(
                    context,
                    baseFontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingM),
          ...taskPatterns.map((pattern) => _buildPatternCard(context, pattern)),
        ],
      ),
    );
  }

  Widget _buildPatternCard(BuildContext context, TaskPattern pattern) {
    final confidencePercentage = (pattern.confidence * 100).toInt();
    final categoryColor = _getCategoryColor(pattern.suggestedCategory);

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        border: Border.all(
          color: categoryColor.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingS),
                decoration: BoxDecoration(
                  color: categoryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusS),
                ),
                child: Icon(
                  _getCategoryIcon(pattern.suggestedCategory),
                  color: categoryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pattern.patternName,
                      style: ResponsiveTheme.createResponsiveTextStyle(
                        context,
                        baseFontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingXS),
                    Text(
                      '${_getCategoryName(pattern.suggestedCategory)} • 平均${pattern.averageCompletionMinutes.toInt()}分钟',
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
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingS,
                  vertical: AppTheme.spacingXS,
                ),
                decoration: BoxDecoration(
                  color: _getConfidenceColor(
                    pattern.confidence,
                  ).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusS),
                ),
                child: Text(
                  '$confidencePercentage%',
                  style: ResponsiveTheme.createResponsiveTextStyle(
                    context,
                    baseFontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: _getConfidenceColor(pattern.confidence),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingM),

          // 相似任务
          if (pattern.similarTasks.isNotEmpty) ...[
            Text(
              '相似任务',
              style: ResponsiveTheme.createResponsiveTextStyle(
                context,
                baseFontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: AppTheme.spacingS),
            Wrap(
              spacing: AppTheme.spacingS,
              runSpacing: AppTheme.spacingXS,
              children: pattern.similarTasks.take(3).map((task) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingS,
                    vertical: AppTheme.spacingXS,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppTheme.radiusS),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Text(
                    task,
                    style: ResponsiveTheme.createResponsiveTextStyle(
                      context,
                      baseFontSize: 11,
                      color: Colors.grey[700],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppTheme.spacingM),
          ],

          // 建议标签
          if (pattern.suggestedTags.isNotEmpty) ...[
            Text(
              '建议标签',
              style: ResponsiveTheme.createResponsiveTextStyle(
                context,
                baseFontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: AppTheme.spacingS),
            Wrap(
              spacing: AppTheme.spacingS,
              runSpacing: AppTheme.spacingXS,
              children: pattern.suggestedTags.map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingS,
                    vertical: AppTheme.spacingXS,
                  ),
                  decoration: BoxDecoration(
                    color: categoryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusS),
                  ),
                  child: Text(
                    '#$tag',
                    style: ResponsiveTheme.createResponsiveTextStyle(
                      context,
                      baseFontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: categoryColor,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
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
            Icon(Icons.pattern, size: 48, color: Colors.grey[400]),
            const SizedBox(height: AppTheme.spacingM),
            Text(
              '暂无任务模式数据',
              style: ResponsiveTheme.createResponsiveTextStyle(
                context,
                baseFontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: AppTheme.spacingS),
            Text(
              '完成更多任务后，AI将为您识别任务模式',
              style: ResponsiveTheme.createResponsiveTextStyle(
                context,
                baseFontSize: 12,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(TaskCategory category) {
    switch (category) {
      case TaskCategory.work:
        return Colors.blue;
      case TaskCategory.study:
        return Colors.green;
      case TaskCategory.personal:
        return Colors.orange;
      case TaskCategory.health:
        return Colors.red;
      case TaskCategory.other:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(TaskCategory category) {
    switch (category) {
      case TaskCategory.work:
        return Icons.work;
      case TaskCategory.study:
        return Icons.school;
      case TaskCategory.personal:
        return Icons.person;
      case TaskCategory.health:
        return Icons.favorite;
      case TaskCategory.other:
        return Icons.category;
    }
  }

  String _getCategoryName(TaskCategory category) {
    switch (category) {
      case TaskCategory.work:
        return '工作';
      case TaskCategory.study:
        return '学习';
      case TaskCategory.personal:
        return '个人';
      case TaskCategory.health:
        return '健康';
      case TaskCategory.other:
        return '其他';
    }
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return Colors.green;
    if (confidence >= 0.6) return Colors.orange;
    return Colors.red;
  }
}
