import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const CompactRefinedCalendarApp());
}

/// 紧凑精美日历应用
class CompactRefinedCalendarApp extends StatelessWidget {
  const CompactRefinedCalendarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Prvin AI日历',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: '.SF Pro Display',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4FC3F7), // 天蓝色主题
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const CompactRefinedCalendarPage(),
    );
  }
}

/// 紧凑精美日历页面
class CompactRefinedCalendarPage extends StatefulWidget {
  const CompactRefinedCalendarPage({super.key});

  @override
  State<CompactRefinedCalendarPage> createState() =>
      _CompactRefinedCalendarPageState();
}

class _CompactRefinedCalendarPageState extends State<CompactRefinedCalendarPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  // 移除不必要的动画控制器以提升性能
  // late AnimationController _slideController;
  // late AnimationController _scaleController;
  late PageController _pageController;

  DateTime _selectedDate = DateTime.now();
  DateTime _focusedDate = DateTime.now();
  List<CompactEvent> _events = [];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600), // 减少动画时长
      vsync: this,
    );
    _pageController = PageController();

    _loadEvents();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _loadEvents() {
    setState(() {
      _events = [
        CompactEvent(
          title: '团队会议',
          description: '讨论Q4项目规划',
          time: DateTime.now().add(const Duration(hours: 2)),
          color: const Color(0xFF4FC3F7),
          icon: CupertinoIcons.person_3_fill,
        ),
        CompactEvent(
          title: '午餐约会',
          description: '与朋友在新餐厅聚餐',
          time: DateTime.now().add(const Duration(hours: 5)),
          color: const Color(0xFF81C784),
          icon: CupertinoIcons.heart_fill,
        ),
        CompactEvent(
          title: '健身训练',
          description: '力量训练 + 有氧运动',
          time: DateTime.now().add(const Duration(days: 1)),
          color: const Color(0xFFFFB74D),
          icon: CupertinoIcons.sportscourt_fill,
        ),
        CompactEvent(
          title: '设计评审',
          description: 'UI/UX设计方案讨论',
          time: DateTime.now().add(const Duration(days: 2)),
          color: const Color(0xFFAB47BC),
          icon: CupertinoIcons.paintbrush_fill,
        ),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE3F2FD), // 天蓝色背景
              Color(0xFFBBDEFB),
              Color(0xFFE1F5FE),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeController,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildSliverAppBar(),
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      _buildCompactCalendarCard(),
                      const SizedBox(height: 20),
                      _buildEventsSection(),
                      const SizedBox(height: 100),
                    ],
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

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 100,
      floating: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getFormattedMonth(_focusedDate),
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0277BD),
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          '${_focusedDate.year}年',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF0288D1),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildHeaderButton(
                    icon: CupertinoIcons.search,
                    onTap: () => _showMessage('搜索功能开发中...'),
                  ),
                  const SizedBox(width: 12),
                  _buildHeaderButton(
                    icon: CupertinoIcons.calendar_today,
                    onTap: _goToToday,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7), // 简化为单色背景
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4FC3F7).withValues(alpha: 0.1), // 减少阴影
            blurRadius: 8, // 减少模糊
            offset: const Offset(0, 2), // 减少偏移
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Icon(icon, color: const Color(0xFF0277BD), size: 18),
        ),
      ),
    );
  }

  Widget _buildCompactCalendarCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 520, // 进一步增加高度确保6行完整显示 (6行 * 48px + 间距 + 头部 + 缓冲)
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withValues(alpha: 0.85), // 简化为单色背景，提升性能
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4FC3F7).withValues(alpha: 0.15), // 减少阴影强度
            blurRadius: 20, // 减少模糊半径
            offset: const Offset(0, 10), // 减少偏移
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
        child: Column(
          children: [
            _buildCalendarHeader(),
            const SizedBox(height: 14),
            _buildWeekDays(),
            const SizedBox(height: 12),
            _buildCalendarGrid(), // 移除Expanded，使用固定高度
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildNavButton(
          icon: CupertinoIcons.chevron_left,
          onTap: _previousMonth,
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) {
            return SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0, 0.3),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
              child: FadeTransition(opacity: animation, child: child),
            );
          },
          child: Text(
            '${_focusedDate.year}年${_focusedDate.month}月',
            key: ValueKey('${_focusedDate.year}-${_focusedDate.month}'),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0277BD),
            ),
          ),
        ),
        _buildNavButton(icon: CupertinoIcons.chevron_right, onTap: _nextMonth),
      ],
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF4FC3F7).withValues(alpha: 0.2),
            const Color(0xFF4FC3F7).withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF4FC3F7).withValues(alpha: 0.3),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Icon(icon, color: const Color(0xFF0277BD), size: 16),
        ),
      ),
    );
  }

  Widget _buildWeekDays() {
    const weekDays = ['日', '一', '二', '三', '四', '五', '六'];
    return Row(
      children: weekDays.asMap().entries.map((entry) {
        final isWeekend = entry.key == 0 || entry.key == 6;
        return Expanded(
          child: Center(
            child: Text(
              entry.value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isWeekend
                    ? const Color(0xFFFF7043).withValues(alpha: 0.8)
                    : const Color(0xFF0288D1).withValues(alpha: 0.7),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(_focusedDate.year, _focusedDate.month);
    final lastDayOfMonth = DateTime(
      _focusedDate.year,
      _focusedDate.month + 1,
      0,
    );
    final daysInMonth = lastDayOfMonth.day;

    // 计算第一天是星期几 (0=周日, 1=周一, ..., 6=周六)
    final firstDayWeekday = firstDayOfMonth.weekday == 7
        ? 0
        : firstDayOfMonth.weekday;

    // 构建完整的6行7列日历网格 (42个格子)
    final weeks = <Widget>[];

    for (var week = 0; week < 6; week++) {
      final days = <Widget>[];

      for (var day = 0; day < 7; day++) {
        final index = week * 7 + day;

        if (index < firstDayWeekday) {
          // 上个月的日期 (灰色显示)
          final prevMonth = DateTime(
            _focusedDate.year,
            _focusedDate.month - 1,
            0,
          );
          final prevDayNumber = prevMonth.day - (firstDayWeekday - index - 1);
          final prevDate = DateTime(
            _focusedDate.year,
            _focusedDate.month - 1,
            prevDayNumber,
          );
          days.add(
            SizedBox(
              height: 48,
              child: _buildDateCell(prevDate, index, isOtherMonth: true),
            ),
          );
        } else if (index >= firstDayWeekday + daysInMonth) {
          // 下个月的日期 (灰色显示)
          final nextDayNumber = index - firstDayWeekday - daysInMonth + 1;
          final nextDate = DateTime(
            _focusedDate.year,
            _focusedDate.month + 1,
            nextDayNumber,
          );
          days.add(
            SizedBox(
              height: 48,
              child: _buildDateCell(nextDate, index, isOtherMonth: true),
            ),
          );
        } else {
          // 当前月的日期
          final dayNumber = index - firstDayWeekday + 1;
          final date = DateTime(
            _focusedDate.year,
            _focusedDate.month,
            dayNumber,
          );
          days.add(SizedBox(height: 48, child: _buildDateCell(date, index)));
        }
      }

      weeks.add(
        Row(children: days.map((day) => Expanded(child: day)).toList()),
      );
    }

    return Column(
      children: weeks
          .map(
            (week) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: week,
            ),
          )
          .toList(),
    );
  }

  Widget _buildDateCell(DateTime date, int index, {bool isOtherMonth = false}) {
    final isSelected = _isSameDay(date, _selectedDate);
    final isToday = _isSameDay(date, DateTime.now());
    final hasEvents = _hasEventsOnDate(date);
    final isWeekend = date.weekday == 6 || date.weekday == 7;
    final isCurrentMonth =
        date.month == _focusedDate.month && date.year == _focusedDate.year;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDate = date;
          // 如果点击的是其他月份的日期，切换到对应月份
          if (!isCurrentMonth) {
            _focusedDate = DateTime(date.year, date.month);
          }
        });
        // 移除动画控制器，提升性能
      },
      child: Container(
        // 改为普通Container，移除AnimatedContainer提升性能
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF4FC3F7) // 简化为单色背景，提升性能
              : isToday
              ? const Color(0xFF4FC3F7).withValues(alpha: 0.2)
              : null,
          borderRadius: BorderRadius.circular(10),
          border: isSelected || isToday
              ? Border.all(
                  color: const Color(0xFF4FC3F7).withValues(alpha: 0.5),
                )
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(
                      0xFF4FC3F7,
                    ).withValues(alpha: 0.3), // 减少阴影强度
                    blurRadius: 6, // 减少模糊半径
                    offset: const Offset(0, 2), // 减少偏移
                  ),
                ]
              : null,
        ),
        child: Stack(
          children: [
            Center(
              child: Text(
                // 移除AnimatedDefaultTextStyle，提升性能
                '${date.day}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isToday || isSelected
                      ? FontWeight.w600
                      : FontWeight.w500,
                  color: isSelected
                      ? Colors.white
                      : isToday
                      ? const Color(0xFF0277BD)
                      : isOtherMonth
                      ? const Color(0xFF0288D1).withValues(
                          alpha: 0.3,
                        ) // 其他月份的日期显示为浅色
                      : isWeekend
                      ? const Color(0xFFFF7043).withValues(alpha: 0.8)
                      : const Color(0xFF0288D1).withValues(alpha: 0.8),
                ),
              ),
            ),
            if (hasEvents && !isSelected && isCurrentMonth)
              Positioned(
                bottom: 4,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _buildEventDots(date),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildEventDots(DateTime date) {
    final eventsOnDate = _events
        .where((event) => _isSameDay(event.time, date))
        .take(3)
        .toList();

    return eventsOnDate.asMap().entries.map((entry) {
      return Container(
        width: 4,
        height: 4,
        margin: const EdgeInsets.symmetric(horizontal: 1),
        decoration: BoxDecoration(
          color: entry.value.color, // 简化为单色，移除渐变和阴影提升性能
          shape: BoxShape.circle,
        ),
      );
    }).toList();
  }

  Widget _buildEventsSection() {
    final todayEvents = _events.where((event) {
      return _isSameDay(event.time, _selectedDate);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              Text(
                _isToday(_selectedDate)
                    ? '今天的日程'
                    : _getFormattedDate(_selectedDate),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0277BD),
                ),
              ),
              const Spacer(),
              if (todayEvents.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF4FC3F7).withValues(alpha: 0.2),
                        const Color(0xFF4FC3F7).withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFF4FC3F7).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    '${todayEvents.length}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0277BD),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (todayEvents.isEmpty)
          _buildEmptyState()
        else
          ...todayEvents.asMap().entries.map((entry) {
            return AnimatedContainer(
              duration: Duration(milliseconds: 300 + (entry.key * 100)),
              curve: Curves.easeOutCubic,
              child: _buildEventCard(entry.value),
            );
          }),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.3),
            Colors.white.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4FC3F7).withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Column(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF4FC3F7).withValues(alpha: 0.3),
                      const Color(0xFF4FC3F7).withValues(alpha: 0.1),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  CupertinoIcons.calendar_badge_plus,
                  size: 28,
                  color: Color(0xFF0277BD),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '这一天还没有安排',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0277BD),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '点击右下角的 + 按钮添加新的时间安排',
                style: TextStyle(
                  fontSize: 14,
                  color: const Color(0xFF0288D1).withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventCard(CompactEvent event) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withValues(alpha: 0.85), // 简化为单色背景
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: event.color.withValues(alpha: 0.1), // 减少阴影强度
            blurRadius: 8, // 减少模糊半径
            offset: const Offset(0, 2), // 减少偏移
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
              onTap: () => _showEventDetails(event),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            event.color.withValues(alpha: 0.3),
                            event.color.withValues(alpha: 0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: event.color.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Icon(event.icon, color: event.color, size: 22),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0277BD),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            event.description,
                            style: TextStyle(
                              fontSize: 13,
                              color: const Color(
                                0xFF0288D1,
                              ).withValues(alpha: 0.7),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  event.color.withValues(alpha: 0.2),
                                  event.color.withValues(alpha: 0.1),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: event.color.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              _getEventTimeString(event),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: event.color,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0.3),
                            Colors.white.withValues(alpha: 0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Icon(
                        CupertinoIcons.chevron_right,
                        color: const Color(0xFF0288D1).withValues(alpha: 0.7),
                        size: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    )
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: _showAddEventDialog,
      backgroundColor: const Color(0xFF4FC3F7), // 简化为单色背景
      foregroundColor: Colors.white,
      elevation: 8, // 使用标准阴影
      child: const Icon(CupertinoIcons.add, size: 26),
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

  String _getFormattedDate(DateTime date) {
    return '${date.month}月${date.day}日的日程';
  }

  String _getEventTimeString(CompactEvent event) {
    return '${event.time.hour.toString().padLeft(2, '0')}:${event.time.minute.toString().padLeft(2, '0')}';
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isToday(DateTime date) {
    return _isSameDay(date, DateTime.now());
  }

  bool _hasEventsOnDate(DateTime date) {
    return _events.any((event) => _isSameDay(event.time, date));
  }

  void _goToToday() {
    setState(() {
      _selectedDate = DateTime.now();
      _focusedDate = DateTime.now();
    });
  }

  void _previousMonth() {
    setState(() {
      _focusedDate = DateTime(_focusedDate.year, _focusedDate.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _focusedDate = DateTime(_focusedDate.year, _focusedDate.month + 1);
    });
  }

  void _showAddEventDialog() {
    showCupertinoDialog<void>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('添加新事件'),
        content: const Text(
          '事件添加功能正在开发中...\n\n目前您可以：\n• 点击日历上的任意日期\n• 查看已有的精美事件卡片\n• 体验流畅的天蓝色主题动画',
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('知道了'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showEventDetails(CompactEvent event) {
    showCupertinoDialog<void>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Row(
          children: [
            Icon(event.icon, color: event.color, size: 24),
            const SizedBox(width: 8),
            Expanded(child: Text(event.title)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(event.description),
            const SizedBox(height: 8),
            Text('时间: ${_getEventTimeString(event)}'),
          ],
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('关闭'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

/// 紧凑事件数据类
class CompactEvent {

  CompactEvent({
    required this.title,
    required this.description,
    required this.time,
    required this.color,
    required this.icon,
  });
  final String title;
  final String description;
  final DateTime time;
  final Color color;
  final IconData icon;
}
