import 'package:flutter/material.dart';
import 'package:prvin/core/theme/theme_exports.dart';
import 'package:prvin/core/widgets/widgets_exports.dart';
import 'package:prvin/features/calendar/widgets/day_view.dart';
import 'package:prvin/features/calendar/widgets/month_view.dart';
import 'package:prvin/features/calendar/widgets/week_view.dart';

/// 日历视图类型枚举
enum CalendarViewType {
  /// 月视图
  month,

  /// 周视图
  week,

  /// 日视图
  day,
}

/// 日历界面组件
/// 提供月视图、周视图和日视图的统一接口
class CalendarView extends StatefulWidget {
  /// 创建日历界面组件
  const CalendarView({
    super.key,
    this.initialDate,
    this.initialViewType = CalendarViewType.month,
    this.onDateTap,
    this.onViewTypeChanged,
    this.tasks = const [],
    this.showTaskColors = true,
    this.enableSwipeNavigation = true,
  });

  /// 初始日期
  final DateTime? initialDate;

  /// 初始视图类型
  final CalendarViewType initialViewType;

  /// 日期点击回调
  final void Function(DateTime date)? onDateTap;

  /// 视图类型变化回调
  final void Function(CalendarViewType viewType)? onViewTypeChanged;

  /// 任务列表
  final List<CalendarTask> tasks;

  /// 是否显示任务颜色
  final bool showTaskColors;

  /// 是否启用滑动导航
  final bool enableSwipeNavigation;

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView>
    with TickerProviderStateMixin {
  late DateTime _currentDate;
  late CalendarViewType _currentViewType;
  late PageController _pageController;
  late AnimationController _viewSwitchController;
  late Animation<double> _viewSwitchAnimation;

  @override
  void initState() {
    super.initState();
    _currentDate = widget.initialDate ?? DateTime.now();
    _currentViewType = widget.initialViewType;
    _pageController = PageController(initialPage: 1000); // 中间位置开始

    _viewSwitchController = AnimationController(
      duration: AnimationTheme.mediumAnimationDuration,
      vsync: this,
    );

    _viewSwitchAnimation = AnimationTheme.createFadeAnimation(
      _viewSwitchController,
      curve: AnimationTheme.smoothCurve,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _viewSwitchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: AnimatedBuilder(
            animation: _viewSwitchAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: _viewSwitchAnimation.value,
                child: _buildCalendarContent(),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return AppCard(
      margin: const EdgeInsets.all(AppTheme.spacingM),
      child: Column(
        children: [
          // 导航栏
          Row(
            children: [
              // 上一个时期按钮
              MicroInteractions.createInteractiveContainer(
                onTap: _goToPrevious,
                child: Container(
                  padding: const EdgeInsets.all(AppTheme.spacingS),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusS),
                  ),
                  child: const Icon(Icons.chevron_left, color: AppTheme.primaryColor),
                ),
              ),

              const SizedBox(width: AppTheme.spacingM),

              // 当前日期显示
              Expanded(
                child: MicroInteractions.createInteractiveContainer(
                  onTap: _goToToday,
                  child: Column(
                    children: [
                      Text(
                        _getHeaderTitle(),
                        style: ResponsiveTheme.createResponsiveTextStyle(
                          context,
                          baseFontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      if (_currentViewType == CalendarViewType.day)
                        Text(
                          _getWeekdayName(_currentDate),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: AppTheme.spacingM),

              // 下一个时期按钮
              MicroInteractions.createInteractiveContainer(
                onTap: _goToNext,
                child: Container(
                  padding: const EdgeInsets.all(AppTheme.spacingS),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusS),
                  ),
                  child: const Icon(
                    Icons.chevron_right,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppTheme.spacingM),

          // 视图切换按钮
          Row(
            children: [
              Expanded(
                child: _buildViewTypeButton(
                  CalendarViewType.month,
                  '月',
                  Icons.calendar_view_month,
                ),
              ),
              const SizedBox(width: AppTheme.spacingS),
              Expanded(
                child: _buildViewTypeButton(
                  CalendarViewType.week,
                  '周',
                  Icons.calendar_view_week,
                ),
              ),
              const SizedBox(width: AppTheme.spacingS),
              Expanded(
                child: _buildViewTypeButton(
                  CalendarViewType.day,
                  '日',
                  Icons.calendar_view_day,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildViewTypeButton(
    CalendarViewType viewType,
    String label,
    IconData icon,
  ) {
    final isSelected = _currentViewType == viewType;

    return MicroInteractions.createInteractiveContainer(
      onTap: () => _switchViewType(viewType),
      child: AnimatedContainer(
        duration: AnimationTheme.shortAnimationDuration,
        curve: AnimationTheme.defaultCurve,
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingM,
          vertical: AppTheme.spacingS,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor
              : AppTheme.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
          border: isSelected
              ? null
              : Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : AppTheme.primaryColor,
            ),
            const SizedBox(width: AppTheme.spacingXS),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppTheme.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarContent() {
    if (widget.enableSwipeNavigation) {
      return PageView.builder(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        itemBuilder: (context, index) {
          final date = _getDateForPage(index);
          return _buildCalendarForDate(date);
        },
      );
    } else {
      return _buildCalendarForDate(_currentDate);
    }
  }

  Widget _buildCalendarForDate(DateTime date) {
    switch (_currentViewType) {
      case CalendarViewType.month:
        return MonthView(
          date: date,
          tasks: widget.tasks,
          onDateTap: widget.onDateTap,
          showTaskColors: widget.showTaskColors,
        );
      case CalendarViewType.week:
        return WeekView(
          date: date,
          tasks: widget.tasks,
          onDateTap: widget.onDateTap,
          showTaskColors: widget.showTaskColors,
        );
      case CalendarViewType.day:
        return DayView(
          date: date,
          tasks: widget.tasks,
          onDateTap: widget.onDateTap,
          showTaskColors: widget.showTaskColors,
        );
    }
  }

  void _switchViewType(CalendarViewType newViewType) {
    if (_currentViewType != newViewType) {
      _viewSwitchController.reset();
      setState(() {
        _currentViewType = newViewType;
      });
      _viewSwitchController.forward();
      widget.onViewTypeChanged?.call(newViewType);
    }
  }

  void _goToPrevious() {
    setState(() {
      switch (_currentViewType) {
        case CalendarViewType.month:
          _currentDate = DateTime(_currentDate.year, _currentDate.month - 1);
        case CalendarViewType.week:
          _currentDate = _currentDate.subtract(const Duration(days: 7));
        case CalendarViewType.day:
          _currentDate = _currentDate.subtract(const Duration(days: 1));
      }
    });
  }

  void _goToNext() {
    setState(() {
      switch (_currentViewType) {
        case CalendarViewType.month:
          _currentDate = DateTime(_currentDate.year, _currentDate.month + 1);
        case CalendarViewType.week:
          _currentDate = _currentDate.add(const Duration(days: 7));
        case CalendarViewType.day:
          _currentDate = _currentDate.add(const Duration(days: 1));
      }
    });
  }

  void _goToToday() {
    setState(() {
      _currentDate = DateTime.now();
    });
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentDate = _getDateForPage(page);
    });
  }

  DateTime _getDateForPage(int page) {
    final offset = page - 1000; // 1000是初始页面
    switch (_currentViewType) {
      case CalendarViewType.month:
        return DateTime(_currentDate.year, _currentDate.month + offset);
      case CalendarViewType.week:
        return _currentDate.add(Duration(days: offset * 7));
      case CalendarViewType.day:
        return _currentDate.add(Duration(days: offset));
    }
  }

  String _getHeaderTitle() {
    switch (_currentViewType) {
      case CalendarViewType.month:
        return '${_currentDate.year}年${_currentDate.month}月';
      case CalendarViewType.week:
        final weekStart = _getWeekStart(_currentDate);
        final weekEnd = weekStart.add(const Duration(days: 6));
        if (weekStart.month == weekEnd.month) {
          return '${weekStart.year}年${weekStart.month}月${weekStart.day}-${weekEnd.day}日';
        } else {
          return '${weekStart.month}月${weekStart.day}日 - ${weekEnd.month}月${weekEnd.day}日';
        }
      case CalendarViewType.day:
        return '${_currentDate.year}年${_currentDate.month}月${_currentDate.day}日';
    }
  }

  String _getWeekdayName(DateTime date) {
    const weekdays = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];
    return weekdays[date.weekday % 7];
  }

  DateTime _getWeekStart(DateTime date) {
    final weekday = date.weekday % 7; // 0 = 周日, 1 = 周一, ...
    return date.subtract(Duration(days: weekday));
  }
}

/// 日历任务数据模型
class CalendarTask {
  const CalendarTask({
    required this.id,
    required this.title,
    required this.date,
    this.description,
    this.category,
    this.priority,
    this.isCompleted = false,
    this.startTime,
    this.endTime,
  });

  final String id;
  final String title;
  final DateTime date;
  final String? description;
  final String? category;
  final String? priority;
  final bool isCompleted;
  final TimeOfDay? startTime;
  final TimeOfDay? endTime;

  /// 获取任务颜色
  Color getColor() {
    if (category != null && AppTheme.taskCategoryColors.containsKey(category)) {
      return AppTheme.taskCategoryColors[category]!;
    }
    return AppTheme.primaryColor;
  }

  /// 获取优先级颜色
  Color getPriorityColor() {
    switch (priority?.toLowerCase()) {
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

  /// 判断是否为今天的任务
  bool isToday() {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// 判断是否为指定日期的任务
  bool isOnDate(DateTime targetDate) {
    return date.year == targetDate.year &&
        date.month == targetDate.month &&
        date.day == targetDate.day;
  }
}
