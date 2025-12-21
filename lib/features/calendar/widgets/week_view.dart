import 'package:flutter/material.dart';
import 'package:prvin/core/theme/theme_exports.dart';
import 'package:prvin/features/calendar/widgets/calendar_view.dart';

/// 周视图组件
/// 显示一周的日历视图，包含时间轴和任务显示
class WeekView extends StatelessWidget {
  /// 创建周视图组件
  const WeekView({
    required this.date,
    super.key,
    this.tasks = const [],
    this.onDateTap,
    this.showTaskColors = true,
  });

  /// 当前显示的周的某一天
  final DateTime date;

  /// 任务列表
  final List<CalendarTask> tasks;

  /// 日期点击回调
  final void Function(DateTime date)? onDateTap;

  /// 是否显示任务颜色
  final bool showTaskColors;

  @override
  Widget build(BuildContext context) {
    final weekStart = _getWeekStart(date);

    return MicroInteractions.createSlideInWidget(
      beginOffset: const Offset(0.5, 0),
      child: Column(
        children: [
          _buildWeekHeader(context, weekStart),
          Expanded(child: _buildWeekContent(context, weekStart)),
        ],
      ),
    );
  }

  Widget _buildWeekHeader(BuildContext context, DateTime weekStart) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      child: Row(
        children: List.generate(7, (index) {
          final dayDate = weekStart.add(Duration(days: index));
          final isToday = _isToday(dayDate);
          final dayTasks = _getTasksForDate(dayDate);

          return Expanded(
            child: _buildDayHeader(context, dayDate, isToday, dayTasks),
          );
        }),
      ),
    );
  }

  Widget _buildDayHeader(
    BuildContext context,
    DateTime dayDate,
    bool isToday,
    List<CalendarTask> dayTasks,
  ) {
    final theme = Theme.of(context);
    const weekdays = ['日', '一', '二', '三', '四', '五', '六'];
    final weekdayName = weekdays[dayDate.weekday % 7];

    Widget header = Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingS,
        vertical: AppTheme.spacingM,
      ),
      decoration: BoxDecoration(
        color: isToday ? AppTheme.primaryColor : Colors.transparent,
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
      ),
      child: Column(
        children: [
          Text(
            weekdayName,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isToday ? Colors.white : Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            dayDate.day.toString(),
            style: theme.textTheme.titleLarge?.copyWith(
              color: isToday ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (dayTasks.isNotEmpty) ...[
            const SizedBox(height: 4),
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: isToday ? Colors.white : AppTheme.primaryColor,
                shape: BoxShape.circle,
              ),
            ),
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

    // 添加交互效果
    if (onDateTap != null) {
      header = MicroInteractions.createInteractiveContainer(
        onTap: () => onDateTap!(dayDate),
        child: header,
      );
    }

    return header;
  }

  Widget _buildWeekContent(BuildContext context, DateTime weekStart) {
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
          // 日期列
          Expanded(child: _buildDaysGrid(context, weekStart)),
        ],
      ),
    );
  }

  Widget _buildTimeAxis(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 60,
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingS),
      child: Column(
        children: List.generate(24, (hour) {
          return Expanded(
            child: Container(
              alignment: Alignment.topCenter,
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '${hour.toString().padLeft(2, '0')}:00',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                  fontSize: 10,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildDaysGrid(BuildContext context, DateTime weekStart) {
    return Row(
      children: List.generate(7, (dayIndex) {
        final dayDate = weekStart.add(Duration(days: dayIndex));
        return Expanded(child: _buildDayColumn(context, dayDate));
      }),
    );
  }

  Widget _buildDayColumn(BuildContext context, DateTime dayDate) {
    final dayTasks = _getTasksForDate(dayDate);

    return Container(
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: Colors.grey.shade200, width: 0.5),
        ),
      ),
      child: Column(
        children: List.generate(24, (hour) {
          final hourTasks = dayTasks.where((task) {
            if (task.startTime != null) {
              return task.startTime!.hour == hour;
            }
            return hour == 9; // 默认显示在9点
          }).toList();

          return Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade100, width: 0.5),
                ),
              ),
              child: _buildHourCell(context, dayDate, hour, hourTasks),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildHourCell(
    BuildContext context,
    DateTime dayDate,
    int hour,
    List<CalendarTask> hourTasks,
  ) {
    if (hourTasks.isEmpty) {
      return const SizedBox.expand();
    }

    return Stack(
      children: hourTasks.asMap().entries.map((entry) {
        final index = entry.key;
        final task = entry.value;

        return Positioned(
          left: index * 2.0, // 重叠任务的偏移
          right: 4,
          top: 2,
          child: _buildTaskBlock(context, task),
        );
      }).toList(),
    );
  }

  Widget _buildTaskBlock(BuildContext context, CalendarTask task) {
    final theme = Theme.of(context);
    final taskColor = showTaskColors ? task.getColor() : AppTheme.primaryColor;

    return MicroInteractions.createInteractiveContainer(
      onTap: onDateTap != null ? () => onDateTap!(task.date) : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        decoration: BoxDecoration(
          color: taskColor.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          task.title,
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  DateTime _getWeekStart(DateTime date) {
    final weekday = date.weekday % 7; // 0 = 周日, 1 = 周一, ...
    return DateTime(date.year, date.month, date.day - weekday);
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
