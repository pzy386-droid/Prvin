import 'package:flutter/material.dart';
import 'package:prvin/core/theme/theme_exports.dart';
import 'package:prvin/features/ai/domain/entities/analytics_data.dart';

/// 专注建议列表组件
/// 显示AI生成的个性化专注建议
class FocusRecommendationsList extends StatelessWidget {
  /// 创建专注建议列表组件
  const FocusRecommendationsList({required this.recommendations, super.key});

  /// 专注建议数据列表
  final List<FocusRecommendation> recommendations;

  @override
  Widget build(BuildContext context) {
    if (recommendations.isEmpty) {
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
                'AI智能建议',
                style: ResponsiveTheme.createResponsiveTextStyle(
                  context,
                  baseFontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingXS),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusS),
                ),
                child: const Icon(
                  Icons.psychology,
                  color: AppTheme.primaryColor,
                  size: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingM),
          ...recommendations.map(
            (recommendation) =>
                _buildRecommendationCard(context, recommendation),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(
    BuildContext context,
    FocusRecommendation recommendation,
  ) {
    final confidencePercentage = (recommendation.confidence * 100).toInt();
    final typeColor = _getTypeColor(recommendation.type);
    final typeIcon = _getTypeIcon(recommendation.type);

    return MicroInteractions.createInteractiveContainer(
      onTap: () {
        _showRecommendationDetails(context, recommendation);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
        padding: const EdgeInsets.all(AppTheme.spacingM),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              typeColor.withValues(alpha: 0.05),
              typeColor.withValues(alpha: 0.02),
            ],
          ),
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
          border: Border.all(color: typeColor.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacingS),
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusS),
                  ),
                  child: Icon(typeIcon, color: typeColor, size: 20),
                ),
                const SizedBox(width: AppTheme.spacingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recommendation.type,
                        style: ResponsiveTheme.createResponsiveTextStyle(
                          context,
                          baseFontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: typeColor,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingXS),
                      Text(
                        _formatGeneratedTime(recommendation.generatedAt),
                        style: ResponsiveTheme.createResponsiveTextStyle(
                          context,
                          baseFontSize: 11,
                          color: Colors.grey[500],
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
                      recommendation.confidence,
                    ).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusS),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.verified,
                        size: 12,
                        color: _getConfidenceColor(recommendation.confidence),
                      ),
                      const SizedBox(width: AppTheme.spacingXS),
                      Text(
                        '$confidencePercentage%',
                        style: ResponsiveTheme.createResponsiveTextStyle(
                          context,
                          baseFontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: _getConfidenceColor(recommendation.confidence),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingM),
            Text(
              recommendation.message,
              style: ResponsiveTheme.createResponsiveTextStyle(
                context,
                baseFontSize: 13,
                color: Colors.grey[700],
              ).copyWith(height: 1.4),
            ),
            const SizedBox(height: AppTheme.spacingM),

            // 建议详情
            Row(
              children: [
                if (recommendation.recommendedMinutes > 0) ...[
                  _buildDetailChip(
                    context,
                    Icons.timer,
                    '${recommendation.recommendedMinutes}分钟',
                    Colors.blue,
                  ),
                  const SizedBox(width: AppTheme.spacingS),
                ],
                if (recommendation.bestHours.isNotEmpty) ...[
                  _buildDetailChip(
                    context,
                    Icons.schedule,
                    _formatBestHours(recommendation.bestHours),
                    Colors.green,
                  ),
                ],
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 12,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailChip(
    BuildContext context,
    IconData icon,
    String text,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingS,
        vertical: AppTheme.spacingXS,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusS),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: AppTheme.spacingXS),
          Text(
            text,
            style: ResponsiveTheme.createResponsiveTextStyle(
              context,
              baseFontSize: 11,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
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
            Icon(Icons.psychology_outlined, size: 48, color: Colors.grey[400]),
            const SizedBox(height: AppTheme.spacingM),
            Text(
              '暂无AI建议',
              style: ResponsiveTheme.createResponsiveTextStyle(
                context,
                baseFontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: AppTheme.spacingS),
            Text(
              '使用应用一段时间后，AI将为您生成个性化建议',
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

  void _showRecommendationDetails(
    BuildContext context,
    FocusRecommendation recommendation,
  ) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              _getTypeIcon(recommendation.type),
              color: _getTypeColor(recommendation.type),
              size: 24,
            ),
            const SizedBox(width: AppTheme.spacingS),
            Expanded(
              child: Text(
                recommendation.type,
                style: TextStyle(
                  color: _getTypeColor(recommendation.type),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              recommendation.message,
              style: ResponsiveTheme.createResponsiveTextStyle(
                context,
                baseFontSize: 14,
              ).copyWith(height: 1.4),
            ),
            const SizedBox(height: AppTheme.spacingM),
            if (recommendation.recommendedMinutes > 0) ...[
              Row(
                children: [
                  const Icon(Icons.timer, size: 16),
                  const SizedBox(width: AppTheme.spacingS),
                  Text('建议时长: ${recommendation.recommendedMinutes}分钟'),
                ],
              ),
              const SizedBox(height: AppTheme.spacingS),
            ],
            if (recommendation.bestHours.isNotEmpty) ...[
              Row(
                children: [
                  const Icon(Icons.schedule, size: 16),
                  const SizedBox(width: AppTheme.spacingS),
                  Text('最佳时间: ${_formatBestHours(recommendation.bestHours)}'),
                ],
              ),
              const SizedBox(height: AppTheme.spacingS),
            ],
            Row(
              children: [
                const Icon(Icons.verified, size: 16),
                const SizedBox(width: AppTheme.spacingS),
                Text('置信度: ${(recommendation.confidence * 100).toInt()}%'),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: 实现应用建议功能
            },
            child: const Text('应用建议'),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case '最佳时间段':
        return Colors.blue;
      case '休息建议':
        return Colors.green;
      case '效率提升':
        return Colors.orange;
      case '专注技巧':
        return Colors.purple;
      default:
        return AppTheme.primaryColor;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case '最佳时间段':
        return Icons.schedule;
      case '休息建议':
        return Icons.self_improvement;
      case '效率提升':
        return Icons.trending_up;
      case '专注技巧':
        return Icons.psychology;
      default:
        return Icons.lightbulb;
    }
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return Colors.green;
    if (confidence >= 0.6) return Colors.orange;
    return Colors.red;
  }

  String _formatBestHours(List<int> hours) {
    if (hours.isEmpty) return '无';
    if (hours.length == 1) return '${hours.first}:00';

    final sortedHours = List<int>.from(hours)..sort();
    return '${sortedHours.first}:00-${sortedHours.last}:00';
  }

  String _formatGeneratedTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分钟前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}小时前';
    } else {
      return '${difference.inDays}天前';
    }
  }
}
