import 'package:flutter/material.dart';
import 'package:prvin/core/theme/theme_exports.dart';
import 'package:prvin/core/widgets/widgets_exports.dart';
import 'package:prvin/features/calendar/widgets/calendar_view.dart';

/// 日视图组件
/// 显示单日的详细时间轴和任务安排
class DayView extends StatelessWidget {
  /// 创建日视图组件
  const DayView({
    required this.date,
    super.key,
    this.tasks = const [],
    this.onDateTap,
    this.showTaskColors = true,
  });

  /// 当前显示的日期
  final DateTime date;

  /// 任务列表
  final List<CalendarTask> tasks;

  /// 日期点击回调
  final void Function(DateTime date)? onDateTap;

  /// 是否显示任务颜色
  final bool showTaskColors;

  @override
  Widget build(BuildContext context) {
    final dayTasks = _getTasksForDate(date);

    return MicroInteractions.createSlideInWidget(
      beginOffset: const Offset(1, 0),
      child: Column(
        children: [
          _buildDayHeader(context, dayTasks),
          Expanded(child: _buildDayContent(context, dayTasks)),
        ],
      ),
    );
  }

  Widget _buildDayHeader(BuildContext context, List<CalendarTask> dayTasks) {
    final theme = Theme.of(context);
    final isToday = _isToday(date);
    const weekdays = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];
    final weekdayName = weekdays[date.weekday % 7];

    Widget header = AppCard(
      margin: const EdgeInsets.all(AppTheme.spacingM),
      child: Column(
        children: [
          Row(
            children: [
              // 日期信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      weekdayName,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: isToday
                            ? AppTheme.primaryColor
                            : Colors.grey[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${date.month}月${date.day}日',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: isToday ? AppTheme.primaryColor : Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // 任务统计
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingM,
                  vertical: AppTheme.spacingS,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusL),
                ),
                child: Column(
                  children: [
                    Text(
                      dayTasks.length.toString(),
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '个任务',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (dayTasks.isNotEmpty) ...[
            const SizedBox(height: AppTheme.spacingM),
            _buildTaskSummary(context, dayTasks),
          ],
        ],
      ),
    );

    // 添加今天的微光效果
    if (isToday) {
      header = GlowEffects.createTodayGlow(
        child: header,
      );
    }

    return header;
  }

  Widget _buildTaskSummary(BuildContext context, List<CalendarTask> dayTasks) {
    final completedTasks = dayTasks.where((task) => task.isCompleted).length;
    final progress = dayTasks.isNotEmpty
        ? completedTasks / dayTasks.length
        : 0.0;

    return Column(
      children: [
        Row(
          children: [
            Text(
              '今日进度',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            Text(
              '$completedTasks/${dayTasks.length}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingS),
        SimpleProgress.linear(value: progress),
      ],
    );
  }

  Widget _buildDayContent(BuildContext context, List<CalendarTask> dayTasks) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          // 时间轴
          _buildTimeAxis(context),
          // 任务区域
          Expanded(child: _buildTaskArea(context, dayTasks)),
        ],
      ),
    );
  }

  Widget _buildTimeAxis(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final isToday = _isToday(date);

    return Container(
      width: 80,
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingS),
      child: Column(
        children: List.generate(24, (hour) {
          final isCurrentHour = isToday && now.hour == hour;

          return Expanded(
            child: Container(
              alignment: Alignment.topCenter,
              padding: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                color: isCurrentHour
                    ? AppTheme.primaryColor.withValues(alpha: 0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(AppTheme.radiusS),
              ),
              child: Text(
                '${hour.toString().padLeft(2, '0')}:00',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isCurrentHour
                      ? AppTheme.primaryColor
                      : Colors.grey[600],
                  fontWeight: isCurrentHour
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTaskArea(BuildContext context, List<CalendarTask> dayTasks) {
    return Container(
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        children: List.generate(24, (hour) {
          final hourTasks = dayTasks.where((task) {
            if (task.startTime != null) {
              return task.startTime!.hour == hour;
            }
            // 没有指定时间的任务显示在9点
            return hour == 9;
          }).toList();

          return Expanded(child: _buildHourSlot(context, hour, hourTasks));
        }),
      ),
    );
  }

  Widget _buildHourSlot(
    BuildContext context,
    int hour,
    List<CalendarTask> hourTasks,
  ) {
    final now = DateTime.now();
    final isToday = _isToday(date);
    final isCurrentHour = isToday && now.hour == hour;

    return Container(
      decoration: BoxDecoration(
        color: isCurrentHour
            ? AppTheme.primaryColor.withValues(alpha: 0.05)
            : Colors.transparent,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade100, width: 0.5),
        ),
      ),
      child: Stack(
        children: [
          // 当前时间指示线
          if (isCurrentHour && isToday) _buildCurrentTimeLine(context, now),

          // 任务列表
          if (hourTasks.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacingS),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: hourTasks.map((task) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: _buildTaskItem(context, task),
                  );
                }).toList(),
              ),
            ),

          // 空时间段的添加按钮
          if (hourTasks.isEmpty && onDateTap != null)
            _buildAddTaskButton(context, hour),
        ],
      ),
    );
  }

  Widget _buildCurrentTimeLine(BuildContext context, DateTime now) {
    final minuteProgress = now.minute / 60.0;

    return Positioned(
      left: 0,
      right: 0,
      top: minuteProgress * 60, // 假设每小时60像素高度
      child: Container(
        height: 2,
        decoration: BoxDecoration(
          color: AppTheme.errorColor,
          borderRadius: BorderRadius.circular(1),
          boxShadow: [
            BoxShadow(
              color: AppTheme.errorColor.withValues(alpha: 0.3),
              blurRadius: 4,
              spreadRadius: 1,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskItem(BuildContext context, CalendarTask task) {
    final theme = Theme.of(context);
    final taskColor = showTaskColors ? task.getColor() : AppTheme.primaryColor;

    return MicroInteractions.createInteractiveContainer(
      onTap: onDateTap != null ? () => onDateTap!(task.date) : null,
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingS),
        decoration: BoxDecoration(
          color: taskColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppTheme.radiusS),
          border: Border.all(color: taskColor.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            // 任务状态指示器
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: task.isCompleted ? taskColor : Colors.transparent,
                border: Border.all(color: taskColor, width: 2),
                shape: BoxShape.circle,
              ),
              child: task.isCompleted
                  ? const Icon(Icons.check, size: 8, color: Colors.white)
                  : null,
            ),

            const SizedBox(width: AppTheme.spacingS),

            // 任务信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (task.description != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      task.description!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            // 优先级指示器
            if (task.priority != null)
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: task.getPriorityColor(),
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddTaskButton(BuildContext context, int hour) {
    return Positioned.fill(
      child: MicroInteractions.createInteractiveContainer(
        onTap: () => onDateTap?.call(date),
        child: Container(
          alignment: Alignment.center,
          child: Icon(Icons.add, color: Colors.grey.shade400, size: 20),
        ),
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  List<CalendarTask> _getTasksForDate(DateTime date) {
    return tasks.where((task) => task.isOnDate(date)).toList();
  }
}
