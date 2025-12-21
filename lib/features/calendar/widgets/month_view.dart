import 'package:flutter/material.dart';
import 'package:prvin/core/theme/theme_exports.dart';
import 'package:prvin/features/calendar/widgets/calendar_view.dart';

/// 月视图组件
/// 显示整个月的日历网格
class MonthView extends StatelessWidget {
  /// 创建月视图组件
  const MonthView({
    required this.date,
    super.key,
    this.tasks = const [],
    this.onDateTap,
    this.showTaskColors = true,
  });

  /// 当前显示的月份日期
  final DateTime date;

  /// 任务列表
  final List<CalendarTask> tasks;

  /// 日期点击回调
  final void Function(DateTime date)? onDateTap;

  /// 是否显示任务颜色
  final bool showTaskColors;

  @override
  Widget build(BuildContext context) {
    return MicroInteractions.createFadeInWidget(
      child: Column(
        children: [
          _buildWeekdayHeader(context),
          Expanded(child: _buildCalendarGrid(context)),
        ],
      ),
    );
  }

  Widget _buildWeekdayHeader(BuildContext context) {
    const weekdays = ['日', '一', '二', '三', '四', '五', '六'];

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingM,
        vertical: AppTheme.spacingS,
      ),
      child: Row(
        children: weekdays.map((weekday) {
          return Expanded(
            child: Center(
              child: Text(
                weekday,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCalendarGrid(BuildContext context) {
    final firstDayOfMonth = DateTime(date.year, date.month);
    final lastDayOfMonth = DateTime(date.year, date.month + 1, 0);
    final firstDayWeekday = firstDayOfMonth.weekday % 7; // 0 = 周日
    final daysInMonth = lastDayOfMonth.day;

    // 计算需要显示的总天数（包括上个月和下个月的部分天数）
    final totalCells = ((daysInMonth + firstDayWeekday - 1) / 7).ceil() * 7;

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: totalCells,
      itemBuilder: (context, index) {
        return _buildDayCell(context, index, firstDayOfMonth, firstDayWeekday);
      },
    );
  }

  Widget _buildDayCell(
    BuildContext context,
    int index,
    DateTime firstDayOfMonth,
    int firstDayWeekday,
  ) {
    final dayNumber = index - firstDayWeekday + 1;
    final cellDate = DateTime(date.year, date.month, dayNumber);

    // 判断是否为当前月份的日期
    final isCurrentMonth =
        dayNumber >= 1 &&
        dayNumber <= DateTime(date.year, date.month + 1, 0).day;
    final isToday = _isToday(cellDate);
    final dayTasks = _getTasksForDate(cellDate);

    if (!isCurrentMonth) {
      // 显示上个月或下个月的日期（灰色显示）
      final actualDate = dayNumber <= 0
          ? DateTime(date.year, date.month, dayNumber)
          : DateTime(
              date.year,
              date.month + 1,
              dayNumber - DateTime(date.year, date.month + 1, 0).day,
            );

      return _buildDayCellContent(
        context,
        actualDate,
        actualDate.day,
        isCurrentMonth: false,
        isToday: false,
        tasks: [],
      );
    }

    return _buildDayCellContent(
      context,
      cellDate,
      dayNumber,
      isCurrentMonth: isCurrentMonth,
      isToday: isToday,
      tasks: dayTasks,
    );
  }

  Widget _buildDayCellContent(
    BuildContext context,
    DateTime cellDate,
    int dayNumber, {
    required bool isCurrentMonth,
    required bool isToday,
    required List<CalendarTask> tasks,
  }) {
    final theme = Theme.of(context);

    Widget dayCell = Container(
      decoration: BoxDecoration(
        color: _getDayCellColor(isCurrentMonth, isToday),
        borderRadius: BorderRadius.circular(AppTheme.radiusS),
        border: isToday
            ? Border.all(color: AppTheme.primaryColor, width: 2)
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 日期数字
          Text(
            dayNumber.toString(),
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
              color: _getDayTextColor(isCurrentMonth, isToday),
            ),
          ),

          // 任务指示器
          if (tasks.isNotEmpty && showTaskColors) ...[
            const SizedBox(height: 2),
            _buildTaskIndicators(tasks),
          ],
        ],
      ),
    );

    // 添加今天的微光效果
    if (isToday) {
      dayCell = GlowEffects.createTodayGlow(
        child: dayCell,
      );
    }

    // 添加交互效果
    if (isCurrentMonth && onDateTap != null) {
      dayCell = MicroInteractions.createInteractiveContainer(
        onTap: () => onDateTap!(cellDate),
        child: dayCell,
      );
    }

    return dayCell;
  }

  Widget _buildTaskIndicators(List<CalendarTask> tasks) {
    if (tasks.isEmpty) return const SizedBox.shrink();

    // 最多显示3个任务指示器
    final displayTasks = tasks.take(3).toList();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: displayTasks.map((task) {
        return Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.symmetric(horizontal: 1),
          decoration: BoxDecoration(
            color: task.getColor(),
            shape: BoxShape.circle,
          ),
        );
      }).toList(),
    );
  }

  Color _getDayCellColor(bool isCurrentMonth, bool isToday) {
    if (isToday) {
      return AppTheme.primaryColor.withValues(alpha: 0.1);
    }
    if (!isCurrentMonth) {
      return Colors.transparent;
    }
    return Colors.transparent;
  }

  Color _getDayTextColor(bool isCurrentMonth, bool isToday) {
    if (isToday) {
      return AppTheme.primaryColor;
    }
    if (!isCurrentMonth) {
      return Colors.grey.shade400;
    }
    return Colors.black87;
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
