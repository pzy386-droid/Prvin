import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:prvin/core/theme/ios_theme.dart';
import 'package:prvin/features/calendar/domain/entities/calendar_event.dart';
import 'package:prvin/features/calendar/presentation/widgets/event_bottom_sheet.dart';
import 'package:prvin/features/calendar/presentation/widgets/ios_calendar_widget.dart';

/// 主日历页面 - iOS风格
class MainCalendarPage extends StatefulWidget {
  const MainCalendarPage({super.key});

  @override
  State<MainCalendarPage> createState() => _MainCalendarPageState();
}

class _MainCalendarPageState extends State<MainCalendarPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;

  DateTime _selectedDate = DateTime.now();
  DateTime _focusedDate = DateTime.now();
  List<CalendarEvent> _events = [];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: IOSTheme.normalAnimation,
      vsync: this,
    );
    _slideController = AnimationController(
      duration: IOSTheme.normalAnimation,
      vsync: this,
    );

    _loadEvents();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _loadEvents() {
    // 模拟加载事件数据
    setState(() {
      _events = [
        CalendarEvent(
          id: '1',
          title: '团队会议',
          description: '讨论项目进度和下周计划',
          startTime: DateTime.now().add(const Duration(hours: 2)),
          endTime: DateTime.now().add(const Duration(hours: 3)),
          color: IOSTheme.primaryBlue,
        ),
        CalendarEvent(
          id: '2',
          title: '午餐约会',
          description: '与朋友在新开的餐厅聚餐',
          startTime: DateTime.now().add(const Duration(hours: 5)),
          endTime: DateTime.now().add(const Duration(hours: 6)),
          color: IOSTheme.systemOrange,
        ),
        CalendarEvent(
          id: '3',
          title: '健身训练',
          description: '力量训练和有氧运动',
          startTime: DateTime.now().add(const Duration(days: 1, hours: -2)),
          endTime: DateTime.now().add(const Duration(days: 1, hours: -1)),
          color: IOSTheme.systemGreen,
        ),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: IOSTheme.secondarySystemBackground,
      body: Container(
        decoration: BoxDecoration(gradient: IOSTheme.backgroundGradient),
        child: SafeArea(
          child: IOSAnimations.fadeIn(
            controller: _fadeController,
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [_buildCalendar(), _buildTodayEvents()],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(IOSTheme.spacing16),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getFormattedMonth(_focusedDate),
                style: IOSTheme.largeTitle,
              ),
              Text(
                _getFormattedYear(_focusedDate),
                style: IOSTheme.callout.copyWith(
                  color: IOSTheme.secondaryLabel,
                ),
              ),
            ],
          ),
          const Spacer(),
          _buildHeaderButton(
            icon: CupertinoIcons.search,
            onTap: _showSearchSheet,
          ),
          const SizedBox(width: IOSTheme.spacing8),
          _buildHeaderButton(
            icon: CupertinoIcons.calendar_today,
            onTap: _goToToday,
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: IOSTheme.systemBackground,
        borderRadius: BorderRadius.circular(IOSTheme.buttonCornerRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(IOSTheme.buttonCornerRadius),
          child: Padding(
            padding: const EdgeInsets.all(IOSTheme.spacing8),
            child: Icon(icon, color: IOSTheme.primaryBlue, size: 20),
          ),
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    return IOSComponents.card(
      child: IOSCalendarWidget(
        selectedDate: _selectedDate,
        focusedDate: _focusedDate,
        events: _events,
        onDateSelected: (date) {
          setState(() {
            _selectedDate = date;
          });
          _slideController.forward().then((_) {
            _slideController.reset();
          });
        },
        onMonthChanged: (date) {
          setState(() {
            _focusedDate = date;
          });
        },
      ),
    );
  }

  Widget _buildTodayEvents() {
    final todayEvents = _events.where((event) {
      return _isSameDay(event.startTime, _selectedDate);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(IOSTheme.spacing16),
          child: Row(
            children: [
              Text(
                _isToday(_selectedDate)
                    ? '今天的日程'
                    : _getFormattedDate(_selectedDate),
                style: IOSTheme.title2,
              ),
              const Spacer(),
              if (todayEvents.isNotEmpty)
                Text('${todayEvents.length} 个事件', style: IOSTheme.footnote),
            ],
          ),
        ),
        if (todayEvents.isEmpty)
          _buildEmptyState()
        else
          ...todayEvents.map(_buildEventCard),
        const SizedBox(height: 100), // 为FAB留出空间
      ],
    );
  }

  Widget _buildEmptyState() {
    return IOSComponents.card(
      child: Column(
        children: [
          const Icon(
            CupertinoIcons.calendar_badge_plus,
            size: 48,
            color: IOSTheme.systemGray2,
          ),
          const SizedBox(height: IOSTheme.spacing12),
          Text(
            '这一天还没有安排',
            style: IOSTheme.headline.copyWith(color: IOSTheme.secondaryLabel),
          ),
          const SizedBox(height: IOSTheme.spacing8),
          const Text(
            '点击右下角的 + 按钮添加新的时间安排',
            style: IOSTheme.footnote,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(CalendarEvent event) {
    return IOSComponents.card(
      onTap: () => _showEventDetails(event),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 60,
            decoration: BoxDecoration(
              color: event.color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: IOSTheme.spacing12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: IOSTheme.headline,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: IOSTheme.spacing4),
                if (event.description?.isNotEmpty ?? false)
                  Text(
                    event.description!,
                    style: IOSTheme.footnote,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: IOSTheme.spacing4),
                Text(
                  _getEventTimeString(event),
                  style: IOSTheme.caption1.copyWith(color: event.color),
                ),
              ],
            ),
          ),
          const Icon(
            CupertinoIcons.chevron_right,
            color: IOSTheme.systemGray2,
            size: 16,
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: IOSTheme.primaryBlue.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: _showAddEventSheet,
        backgroundColor: IOSTheme.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        child: const Icon(CupertinoIcons.add, size: 28),
      ),
    );
  }

  // 辅助方法
  String _getFormattedMonth(DateTime date) {
    const months = [
      '一月',
      '二月',
      '三月',
      '四月',
      '五月',
      '六月',
      '七月',
      '八月',
      '九月',
      '十月',
      '十一月',
      '十二月',
    ];
    return months[date.month - 1];
  }

  String _getFormattedYear(DateTime date) {
    return '${date.year}年';
  }

  String _getFormattedDate(DateTime date) {
    return '${date.month}月${date.day}日的日程';
  }

  String _getEventTimeString(CalendarEvent event) {
    if (event.isAllDay) {
      return '全天';
    }
    final start =
        '${event.startTime.hour.toString().padLeft(2, '0')}:${event.startTime.minute.toString().padLeft(2, '0')}';
    final end =
        '${event.endTime.hour.toString().padLeft(2, '0')}:${event.endTime.minute.toString().padLeft(2, '0')}';
    return '$start - $end';
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isToday(DateTime date) {
    return _isSameDay(date, DateTime.now());
  }

  void _goToToday() {
    setState(() {
      _selectedDate = DateTime.now();
      _focusedDate = DateTime.now();
    });
  }

  void _showSearchSheet() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 300,
        decoration: const BoxDecoration(
          color: IOSTheme.systemBackground,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(IOSTheme.cardCornerRadius),
          ),
        ),
        child: const Center(
          child: Text('搜索功能开发中...', style: IOSTheme.headline),
        ),
      ),
    );
  }

  void _showAddEventSheet() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => EventBottomSheet(
        selectedDate: _selectedDate,
        onEventAdded: (event) {
          setState(() {
            _events.add(event);
          });
        },
      ),
    );
  }

  void _showEventDetails(CalendarEvent event) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => EventBottomSheet(
        selectedDate: _selectedDate,
        existingEvent: event,
        onEventUpdated: (updatedEvent) {
          setState(() {
            final index = _events.indexWhere((e) => e.id == event.id);
            if (index != -1) {
              _events[index] = updatedEvent;
            }
          });
        },
        onEventDeleted: (eventId) {
          setState(() {
            _events.removeWhere((e) => e.id == eventId);
          });
        },
      ),
    );
  }
}
