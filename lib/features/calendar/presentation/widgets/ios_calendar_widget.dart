import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:prvin/core/theme/ios_theme.dart';
import 'package:prvin/features/calendar/domain/entities/calendar_event.dart';

/// iOS风格日历组件
class IOSCalendarWidget extends StatefulWidget {
  const IOSCalendarWidget({
    required this.selectedDate, required this.focusedDate, required this.events, required this.onDateSelected, required this.onMonthChanged, super.key,
  });

  final DateTime selectedDate;
  final DateTime focusedDate;
  final List<CalendarEvent> events;
  final Function(DateTime) onDateSelected;
  final Function(DateTime) onMonthChanged;

  @override
  State<IOSCalendarWidget> createState() => _IOSCalendarWidgetState();
}

class _IOSCalendarWidgetState extends State<IOSCalendarWidget>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: IOSTheme.fastAnimation,
      vsync: this,
    );
    _pageController = PageController();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [_buildHeader(), _buildWeekDays(), _buildCalendarGrid()],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: IOSTheme.spacing8,
        vertical: IOSTheme.spacing12,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildNavigationButton(
            icon: CupertinoIcons.chevron_left,
            onTap: _previousMonth,
          ),
          Text(
            '${widget.focusedDate.year}年${widget.focusedDate.month}月',
            style: IOSTheme.title3,
          ),
          _buildNavigationButton(
            icon: CupertinoIcons.chevron_right,
            onTap: _nextMonth,
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: IOSTheme.systemGray6,
        borderRadius: BorderRadius.circular(IOSTheme.buttonCornerRadius),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(IOSTheme.buttonCornerRadius),
          child: Padding(
            padding: const EdgeInsets.all(IOSTheme.spacing8),
            child: Icon(icon, color: IOSTheme.primaryBlue, size: 18),
          ),
        ),
      ),
    );
  }

  Widget _buildWeekDays() {
    const weekDays = ['日', '一', '二', '三', '四', '五', '六'];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: IOSTheme.spacing8),
      child: Row(
        children: weekDays.map((day) {
          return Expanded(
            child: Center(
              child: Text(
                day,
                style: IOSTheme.footnote.copyWith(
                  color: IOSTheme.tertiaryLabel,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(
      widget.focusedDate.year,
      widget.focusedDate.month,
    );
    final lastDayOfMonth = DateTime(
      widget.focusedDate.year,
      widget.focusedDate.month + 1,
      0,
    );
    final firstDayWeekday = firstDayOfMonth.weekday % 7;
    final daysInMonth = lastDayOfMonth.day;

    // 计算需要显示的前一个月的日期
    final previousMonth = DateTime(
      widget.focusedDate.year,
      widget.focusedDate.month - 1,
      0,
    );
    final daysFromPreviousMonth = firstDayWeekday;

    // 计算总共需要的格子数
    final totalCells = ((daysInMonth + daysFromPreviousMonth) / 7).ceil() * 7;
    final daysFromNextMonth = totalCells - daysInMonth - daysFromPreviousMonth;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
      ),
      itemCount: totalCells,
      itemBuilder: (context, index) {
        DateTime date;
        var isCurrentMonth = true;

        if (index < daysFromPreviousMonth) {
          // 前一个月的日期
          date = DateTime(
            previousMonth.year,
            previousMonth.month,
            previousMonth.day - (daysFromPreviousMonth - index - 1),
          );
          isCurrentMonth = false;
        } else if (index < daysFromPreviousMonth + daysInMonth) {
          // 当前月的日期
          date = DateTime(
            widget.focusedDate.year,
            widget.focusedDate.month,
            index - daysFromPreviousMonth + 1,
          );
        } else {
          // 下一个月的日期
          date = DateTime(
            widget.focusedDate.year,
            widget.focusedDate.month + 1,
            index - daysFromPreviousMonth - daysInMonth + 1,
          );
          isCurrentMonth = false;
        }

        return _buildDateCell(date, isCurrentMonth);
      },
    );
  }

  Widget _buildDateCell(DateTime date, bool isCurrentMonth) {
    final isSelected = _isSameDay(date, widget.selectedDate);
    final isToday = _isSameDay(date, DateTime.now());
    final hasEvents = _hasEventsOnDate(date);

    return GestureDetector(
      onTap: () {
        widget.onDateSelected(date);
        _scaleController.forward().then((_) {
          _scaleController.reverse();
        });
      },
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: isSelected
              ? IOSTheme.primaryBlue
              : isToday
              ? IOSTheme.primaryBlue.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(IOSTheme.cornerRadius),
        ),
        child: Stack(
          children: [
            Center(
              child: AnimatedScale(
                scale: isSelected ? 1.1 : 1.0,
                duration: IOSTheme.fastAnimation,
                curve: IOSTheme.easeOut,
                child: Text(
                  '${date.day}',
                  style: IOSTheme.body.copyWith(
                    color: isSelected
                        ? Colors.white
                        : isCurrentMonth
                        ? isToday
                              ? IOSTheme.primaryBlue
                              : IOSTheme.label
                        : IOSTheme.systemGray2,
                    fontWeight: isToday || isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ),
            ),
            if (hasEvents && !isSelected)
              Positioned(
                bottom: 4,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _getEventDots(date),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _getEventDots(DateTime date) {
    final eventsOnDate = widget.events
        .where((event) => _isSameDay(event.startTime, date))
        .take(3)
        .toList();

    return eventsOnDate.map((event) {
      return Container(
        width: 4,
        height: 4,
        margin: const EdgeInsets.symmetric(horizontal: 1),
        decoration: BoxDecoration(color: event.color, shape: BoxShape.circle),
      );
    }).toList();
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _hasEventsOnDate(DateTime date) {
    return widget.events.any((event) => _isSameDay(event.startTime, date));
  }

  void _previousMonth() {
    final newDate = DateTime(
      widget.focusedDate.year,
      widget.focusedDate.month - 1,
    );
    widget.onMonthChanged(newDate);
  }

  void _nextMonth() {
    final newDate = DateTime(
      widget.focusedDate.year,
      widget.focusedDate.month + 1,
    );
    widget.onMonthChanged(newDate);
  }
}
