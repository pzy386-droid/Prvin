import 'package:flutter/material.dart';
import 'package:prvin/core/theme/theme_exports.dart';

/// 应用卡片组件
class AppCard extends StatelessWidget {
  /// 创建应用卡片
  const AppCard({
    required this.child,
    super.key,
    this.padding,
    this.margin,
    this.color,
    this.borderRadius,
    this.elevation,
    this.shadowColor,
    this.border,
    this.onTap,
    this.animateOnTap = true,
    this.width,
    this.height,
  });

  /// 子组件
  final Widget child;

  /// 内边距
  final EdgeInsets? padding;

  /// 外边距
  final EdgeInsets? margin;

  /// 背景色
  final Color? color;

  /// 圆角半径
  final BorderRadius? borderRadius;

  /// 阴影高度
  final double? elevation;

  /// 阴影颜色
  final Color? shadowColor;

  /// 边框
  final Border? border;

  /// 点击回调
  final VoidCallback? onTap;

  /// 点击时是否显示动画
  final bool animateOnTap;

  /// 宽度
  final double? width;

  /// 高度
  final double? height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Widget card = Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding ?? const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: color ?? theme.cardColor,
        borderRadius: borderRadius ?? BorderRadius.circular(AppTheme.radiusL),
        border:
            border ??
            Border.all(
              color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
            ),
        boxShadow: elevation != null && elevation! > 0
            ? [
                BoxShadow(
                  color:
                      shadowColor ??
                      Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
                  blurRadius: elevation! * 2,
                  offset: Offset(0, elevation!),
                ),
              ]
            : null,
      ),
      child: child,
    );

    if (onTap != null) {
      card = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius ?? BorderRadius.circular(AppTheme.radiusL),
          child: card,
        ),
      );

      if (animateOnTap) {
        card = MicroInteractions.createInteractiveContainer(
          onTap: onTap,
          child: card,
        );
      }
    }

    return MicroInteractions.createFadeInWidget(child: card);
  }
}

/// 任务卡片组件
class TaskCard extends StatelessWidget {
  /// 创建任务卡片
  const TaskCard({
    required this.title,
    super.key,
    this.description,
    this.category,
    this.priority,
    this.dueDate,
    this.isCompleted = false,
    this.onTap,
    this.onToggleComplete,
    this.tags = const [],
  });

  /// 任务标题
  final String title;

  /// 任务描述
  final String? description;

  /// 任务分类
  final String? category;

  /// 优先级
  final String? priority;

  /// 截止日期
  final DateTime? dueDate;

  /// 是否完成
  final bool isCompleted;

  /// 点击回调
  final VoidCallback? onTap;

  /// 切换完成状态回调
  final VoidCallback? onToggleComplete;

  /// 标签列表
  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoryColor = category != null
        ? AppTheme.taskCategoryColors[category] ?? AppTheme.primaryColor
        : AppTheme.primaryColor;

    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题和完成状态
          Row(
            children: [
              if (onToggleComplete != null)
                GestureDetector(
                  onTap: onToggleComplete,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isCompleted ? categoryColor : Colors.grey,
                        width: 2,
                      ),
                      color: isCompleted ? categoryColor : Colors.transparent,
                    ),
                    child: isCompleted
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
                  ),
                ),
              if (onToggleComplete != null)
                const SizedBox(width: AppTheme.spacingS),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                    color: isCompleted ? Colors.grey : null,
                  ),
                ),
              ),
              if (priority != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingS,
                    vertical: AppTheme.spacingXS,
                  ),
                  decoration: BoxDecoration(
                    color: _getPriorityColor(priority!).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusS),
                  ),
                  child: Text(
                    priority!,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: _getPriorityColor(priority!),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),

          // 描述
          if (description != null) ...[
            const SizedBox(height: AppTheme.spacingS),
            Text(
              description!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          // 标签
          if (tags.isNotEmpty) ...[
            const SizedBox(height: AppTheme.spacingS),
            Wrap(
              spacing: AppTheme.spacingXS,
              runSpacing: AppTheme.spacingXS,
              children: tags.map((tag) {
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
                    tag,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: categoryColor,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],

          // 截止日期和分类
          if (dueDate != null || category != null) ...[
            const SizedBox(height: AppTheme.spacingS),
            Row(
              children: [
                if (dueDate != null) ...[
                  Icon(Icons.schedule, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: AppTheme.spacingXS),
                  Text(
                    _formatDate(dueDate!),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
                const Spacer(),
                if (category != null)
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: categoryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
      case '高':
        return AppTheme.errorColor;
      case 'medium':
      case '中':
        return AppTheme.warningColor;
      case 'low':
      case '低':
        return AppTheme.successColor;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;

    if (difference == 0) {
      return '今天';
    } else if (difference == 1) {
      return '明天';
    } else if (difference == -1) {
      return '昨天';
    } else if (difference > 0) {
      return '$difference天后';
    } else {
      return '${-difference}天前';
    }
  }
}
