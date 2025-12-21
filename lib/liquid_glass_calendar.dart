import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const LiquidGlassCalendarApp());
}

/// Liquid Glass风格日历应用
class LiquidGlassCalendarApp extends StatelessWidget {
  const LiquidGlassCalendarApp({super.key});

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
      home: const LiquidGlassCalendarPage(),
    );
  }
}

/// Liquid Glass风格日历页面
class LiquidGlassCalendarPage extends StatefulWidget {
  const LiquidGlassCalendarPage({super.key});

  @override
  State<LiquidGlassCalendarPage> createState() =>
      _LiquidGlassCalendarPageState();
}

class _LiquidGlassCalendarPageState extends State<LiquidGlassCalendarPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late AnimationController _breathingController;
  late AnimationController _liquidController;

  DateTime _selectedDate = DateTime.now();
  DateTime _focusedDate = DateTime.now();
  List<LiquidEvent> _events = [];

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _breathingController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    );

    _liquidController = AnimationController(
      duration: const Duration(milliseconds: 8000),
      vsync: this,
    );

    _loadEvents();
    _fadeController.forward();
    _breathingController.repeat(reverse: true);
    _liquidController.repeat();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    _breathingController.dispose();
    _liquidController.dispose();
    super.dispose();
  }

  void _loadEvents() {
    setState(() {
      _events = [
        LiquidEvent(
          title: '团队会议',
          description: '讨论Q4项目规划',
          time: DateTime.now().add(const Duration(hours: 2)),
          color: const Color(0xFF4FC3F7),
          icon: CupertinoIcons.person_3_fill,
        ),
        LiquidEvent(
          title: '午餐约会',
          description: '与朋友在新餐厅聚餐',
          time: DateTime.now().add(const Duration(hours: 5)),
          color: const Color(0xFF81C784),
          icon: CupertinoIcons.heart_fill,
        ),
        LiquidEvent(
          title: '健身训练',
          description: '力量训练 + 有氧运动',
          time: DateTime.now().add(const Duration(days: 1)),
          color: const Color(0xFFFFB74D),
          icon: CupertinoIcons.sportscourt_fill,
        ),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: _buildLiquidBackground(),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeController,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildLiquidAppBar(),
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      _buildCompactCalendarCard(),
                      const SizedBox(height: 32),
                      _buildEventsSection(),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: _buildLiquidFAB(),
    );
  }

  /// 构建液体玻璃背景
  BoxDecoration _buildLiquidBackground() {
    return BoxDecoration(
      gradient: RadialGradient(
        center: Alignment.topLeft,
        radius: 1.5,
        colors: [
          const Color(0xFFE3F2FD).withValues(alpha: 0.8),
          const Color(0xFFBBDEFB).withValues(alpha: 0.6),
          const Color(0xFF90CAF9).withValues(alpha: 0.4),
          const Color(0xFFE1F5FE).withValues(alpha: 0.9),
        ],
        stops: const [0.0, 0.3, 0.7, 1.0],
      ),
    );
  }

  /// 构建液体玻璃风格AppBar
  Widget _buildLiquidAppBar() {
    return SliverAppBar(
      expandedHeight: 100,
      floating: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedBuilder(
                      animation: _breathingController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: 1.0 + (_breathingController.value * 0.02),
                          child: Text(
                            _getFormattedMonth(_focusedDate),
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0277BD).withValues(
                                alpha: 0.9 + (_breathingController.value * 0.1),
                              ),
                              letterSpacing: -0.5,
                            ),
                          ),
                        );
                      },
                    ),
                    Text(
                      '${_focusedDate.year}年',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0288D1).withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              _buildGlassButton(
                icon: CupertinoIcons.search,
                onTap: () => _showMessage('搜索功能开发中...'),
              ),
              const SizedBox(width: 12),
              _buildGlassButton(
                icon: CupertinoIcons.calendar_today,
                onTap: _goToToday,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建玻璃质感按钮
  Widget _buildGlassButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.25),
            Colors.white.withValues(alpha: 0.1),
          ],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4FC3F7).withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.8),
            blurRadius: 1,
            offset: const Offset(-1, -1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(12),
              child: Icon(icon, color: const Color(0xFF0277BD), size: 18),
            ),
          ),
        ),
      ),
    );
  }

  /// 构建紧凑型日历卡片
  Widget _buildCompactCalendarCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      height: 320, // 固定高度，不占据整个屏幕
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.4),
            Colors.white.withValues(alpha: 0.1),
            Colors.white.withValues(alpha: 0.2),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4FC3F7).withValues(alpha: 0.15),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.9),
            blurRadius: 1,
            offset: const Offset(-2, -2),
          ),
          BoxShadow(
            color: const Color(0xFF4FC3F7).withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.3),
                  Colors.white.withValues(alpha: 0.1),
                ],
              ),
            ),
            child: Column(
              children: [
                _buildCalendarHeader(),
                const SizedBox(height: 16),
                _buildWeekDays(),
                const SizedBox(height: 12),
                Expanded(child: _buildCalendarGrid()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 构建日历头部
  Widget _buildCalendarHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildNavButton(
          icon: CupertinoIcons.chevron_left,
          onTap: _previousMonth,
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          transitionBuilder: (child, animation) {
            return SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0, 0.5),
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
              fontWeight: FontWeight.w700,
              color: Color(0xFF0277BD),
            ),
          ),
        ),
        _buildNavButton(icon: CupertinoIcons.chevron_right, onTap: _nextMonth),
      ],
    );
  }

  /// 构建导航按钮
  Widget _buildNavButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF4FC3F7).withValues(alpha: 0.2),
            const Color(0xFF4FC3F7).withValues(alpha: 0.1),
          ],
        ),
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

  /// 构建星期标题
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

  /// 构建日历网格
  Widget _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(_focusedDate.year, _focusedDate.month);
    final lastDayOfMonth = DateTime(
      _focusedDate.year,
      _focusedDate.month + 1,
      0,
    );
    final firstDayWeekday = firstDayOfMonth.weekday % 7;
    final daysInMonth = lastDayOfMonth.day;

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
      ),
      itemCount: 42,
      itemBuilder: (context, index) {
        if (index < firstDayWeekday || index >= firstDayWeekday + daysInMonth) {
          return const SizedBox();
        }

        final day = index - firstDayWeekday + 1;
        final date = DateTime(_focusedDate.year, _focusedDate.month, day);
        return _buildLiquidDateCell(date);
      },
    );
  }

  /// 构建液体玻璃风格日期单元格
  Widget _buildLiquidDateCell(DateTime date) {
    final isSelected = _isSameDay(date, _selectedDate);
    final isToday = _isSameDay(date, DateTime.now());
    final hasEvents = _hasEventsOnDate(date);
    final isWeekend = date.weekday == 6 || date.weekday == 7;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDate = date;
        });
        _scaleController.forward().then((_) {
          _scaleController.reverse();
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF4FC3F7).withValues(alpha: 0.8),
                    const Color(0xFF29B6F6).withValues(alpha: 0.9),
                  ],
                )
              : isToday
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF4FC3F7).withValues(alpha: 0.3),
                    const Color(0xFF4FC3F7).withValues(alpha: 0.1),
                  ],
                )
              : null,
          border: isSelected || isToday
              ? Border.all(
                  color: const Color(0xFF4FC3F7).withValues(alpha: 0.5),
                )
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF4FC3F7).withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.8),
                    blurRadius: 1,
                    offset: const Offset(-1, -1),
                  ),
                ]
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: isSelected ? 5 : 0,
              sigmaY: isSelected ? 5 : 0,
            ),
            child: Stack(
              children: [
                Center(
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isToday || isSelected
                          ? FontWeight.w700
                          : FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : isToday
                          ? const Color(0xFF0277BD)
                          : isWeekend
                          ? const Color(0xFFFF7043).withValues(alpha: 0.8)
                          : const Color(0xFF0288D1).withValues(alpha: 0.8),
                    ),
                    child: Text('${date.day}'),
                  ),
                ),
                if (hasEvents && !isSelected)
                  Positioned(
                    bottom: 4,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _buildLiquidEventDots(date),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 构建液体风格事件点
  List<Widget> _buildLiquidEventDots(DateTime date) {
    final eventsOnDate = _events
        .where((event) => _isSameDay(event.time, date))
        .take(3)
        .toList();

    return eventsOnDate.asMap().entries.map((entry) {
      return AnimatedBuilder(
        animation: _liquidController,
        builder: (context, child) {
          final offset = (entry.key * 0.3) + _liquidController.value;
          final scale = 1.0 + (math.sin(offset * 2 * math.pi) * 0.2);

          return Transform.scale(
            scale: scale,
            child: Container(
              width: 4,
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 1),
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    entry.value.color,
                    entry.value.color.withValues(alpha: 0.6),
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: entry.value.color.withValues(alpha: 0.6),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }).toList();
  }

  /// 构建事件区域
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
                    borderRadius: BorderRadius.circular(12),
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
          _buildLiquidEmptyState()
        else
          ...todayEvents.asMap().entries.map((entry) {
            return AnimatedContainer(
              duration: Duration(milliseconds: 400 + (entry.key * 100)),
              curve: Curves.easeOutCubic,
              child: _buildLiquidEventCard(entry.value),
            );
          }),
      ],
    );
  }

  /// 构建液体风格空状态
  Widget _buildLiquidEmptyState() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.3),
            Colors.white.withValues(alpha: 0.1),
          ],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4FC3F7).withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Column(
            children: [
              AnimatedBuilder(
                animation: _breathingController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1.0 + (_breathingController.value * 0.05),
                    child: Container(
                      width: 60,
                      height: 60,
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
                  );
                },
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

  /// 构建液体风格事件卡片
  Widget _buildLiquidEventCard(LiquidEvent event) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.4),
            Colors.white.withValues(alpha: 0.1),
            Colors.white.withValues(alpha: 0.2),
          ],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: event.color.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.8),
            blurRadius: 1,
            offset: const Offset(-1, -1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _showEventDetails(event),
              borderRadius: BorderRadius.circular(18),
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
                              borderRadius: BorderRadius.circular(8),
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
    );
  }

  /// 构建液体风格FAB
  Widget _buildLiquidFAB() {
    return AnimatedBuilder(
      animation: _breathingController,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_breathingController.value * 0.03),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF4FC3F7).withValues(alpha: 0.9),
                  const Color(0xFF29B6F6).withValues(alpha: 0.8),
                  const Color(0xFF03A9F4).withValues(alpha: 0.9),
                ],
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4FC3F7).withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.8),
                  blurRadius: 1,
                  offset: const Offset(-2, -2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: FloatingActionButton(
                  onPressed: _showAddEventDialog,
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  child: const Icon(CupertinoIcons.add, size: 26),
                ),
              ),
            ),
          ),
        );
      },
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

  String _getEventTimeString(LiquidEvent event) {
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
          '事件添加功能正在开发中...\n\n目前您可以：\n• 点击日历上的任意日期\n• 查看已有的精美事件卡片\n• 体验流畅的Liquid Glass风格动画',
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

  void _showEventDetails(LiquidEvent event) {
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

/// 液体风格事件数据类
class LiquidEvent {

  LiquidEvent({
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
