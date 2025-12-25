import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prvin/features/pomodoro/pomodoro_page.dart';
import 'package:prvin/features/task_management/data/repositories/task_repository_impl.dart';
import 'package:prvin/features/task_management/domain/entities/task.dart';
import 'package:prvin/features/task_management/domain/usecases/task_usecases.dart';
import 'package:prvin/features/task_management/presentation/bloc/task_bloc.dart';
import 'package:prvin/features/task_management/presentation/pages/task_form_page.dart';

void main() {
  runApp(const IntegratedCalendarApp());
}

/// 集成日历应用 - 将任务管理集成到日历中
class IntegratedCalendarApp extends StatelessWidget {
  const IntegratedCalendarApp({super.key});

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
      home: BlocProvider(
        create: (context) {
          final repository = TaskRepositoryImpl();
          final useCases = TaskUseCases(repository);
          return TaskBloc(useCases)..add(const TaskLoadRequested());
        },
        child: const IntegratedCalendarPage(),
      ),
    );
  }
}

/// 集成日历页面
class IntegratedCalendarPage extends StatefulWidget {
  const IntegratedCalendarPage({super.key});

  @override
  State<IntegratedCalendarPage> createState() => _IntegratedCalendarPageState();
}

class _IntegratedCalendarPageState extends State<IntegratedCalendarPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _slideController;

  DateTime _selectedDate = DateTime.now();
  DateTime _focusedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _slideController.dispose();
    super.dispose();
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
                      _buildTasksSection(),
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
                    icon: CupertinoIcons.timer,
                    onTap: _openPomodoro,
                  ),
                  const SizedBox(width: 12),
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
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 200),
      tween: Tween(begin: 0, end: 1),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.9 + (0.1 * value),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.4 * value),
                  Colors.white.withValues(alpha: 0.1 * value),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3 * value),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(
                    0xFF4FC3F7,
                  ).withValues(alpha: 0.15 * value),
                  blurRadius: 8 * value,
                  offset: Offset(0, 3 * value),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5 * value, sigmaY: 5 * value),
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
          ),
        );
      },
    );
  }

  Widget _buildCompactCalendarCard() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      tween: Tween(begin: 0, end: 1),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              height: 520,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.4 * value),
                    Colors.white.withValues(alpha: 0.1 * value),
                    Colors.white.withValues(alpha: 0.3 * value),
                  ],
                ),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3 * value),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(
                      0xFF4FC3F7,
                    ).withValues(alpha: 0.2 * value),
                    blurRadius: 25 * value,
                    offset: Offset(0, 12 * value),
                  ),
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.8 * value),
                    blurRadius: 1 * value,
                    offset: Offset(-1 * value, -1 * value),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: 8 * value,
                    sigmaY: 8 * value,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15 * value),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        _buildCalendarHeader(),
                        const SizedBox(height: 14),
                        _buildWeekDays(),
                        const SizedBox(height: 12),
                        _buildCalendarGrid(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
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
            const Color(0xFF4FC3F7).withValues(alpha: 0.25),
            const Color(0xFF4FC3F7).withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF4FC3F7).withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4FC3F7).withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
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
    return BlocBuilder<TaskBloc, TaskState>(
      builder: (context, state) {
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
              final prevDayNumber =
                  prevMonth.day - (firstDayWeekday - index - 1);
              final prevDate = DateTime(
                _focusedDate.year,
                _focusedDate.month - 1,
                prevDayNumber,
              );
              days.add(
                SizedBox(
                  height: 48,
                  child: _buildDateCell(
                    prevDate,
                    index,
                    state.tasks,
                    isOtherMonth: true,
                  ),
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
                  child: _buildDateCell(
                    nextDate,
                    index,
                    state.tasks,
                    isOtherMonth: true,
                  ),
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
              days.add(
                SizedBox(
                  height: 48,
                  child: _buildDateCell(date, index, state.tasks),
                ),
              );
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
      },
    );
  }

  Widget _buildDateCell(
    DateTime date,
    int index,
    List<Task> tasks, {
    bool isOtherMonth = false,
  }) {
    final isSelected = _isSameDay(date, _selectedDate);
    final isToday = _isSameDay(date, DateTime.now());
    final hasEvents = _hasTasksOnDate(date, tasks);
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
        // 更新任务BLoC的选中日期
        context.read<TaskBloc>().add(TaskDateChanged(date));
        // 添加点击动画效果
        _scaleController.forward().then((_) {
          _scaleController.reverse();
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF4FC3F7), Color(0xFF29B6F6)],
                )
              : isToday
              ? LinearGradient(
                  colors: [
                    const Color(0xFF4FC3F7).withValues(alpha: 0.3),
                    const Color(0xFF4FC3F7).withValues(alpha: 0.1),
                  ],
                )
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
                    color: const Color(0xFF4FC3F7).withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: ScaleTransition(
          scale: Tween<double>(begin: 1, end: 0.95).animate(
            CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
          ),
          child: Stack(
            children: [
              Center(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
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
                        ? const Color(0xFF0288D1).withValues(alpha: 0.3)
                        : isWeekend
                        ? const Color(0xFFFF7043).withValues(alpha: 0.8)
                        : const Color(0xFF0288D1).withValues(alpha: 0.8),
                  ),
                  child: Text('${date.day}'),
                ),
              ),
              if (hasEvents && !isSelected && isCurrentMonth)
                Positioned(
                  bottom: 4,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _buildTaskDots(date, tasks),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildTaskDots(DateTime date, List<Task> tasks) {
    final tasksOnDate = tasks
        .where((task) => _isSameDay(task.startTime, date))
        .take(3)
        .toList();

    return tasksOnDate.asMap().entries.map((entry) {
      return TweenAnimationBuilder<double>(
        duration: Duration(milliseconds: 300 + (entry.key * 100)),
        tween: Tween(begin: 0, end: 1),
        curve: Curves.elasticOut,
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: Container(
              width: 4,
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 1),
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    _getCategoryColor(entry.value.category),
                    _getCategoryColor(
                      entry.value.category,
                    ).withValues(alpha: 0.6),
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _getCategoryColor(
                      entry.value.category,
                    ).withValues(alpha: 0.4),
                    blurRadius: 2,
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

  Widget _buildTasksSection() {
    return BlocConsumer<TaskBloc, TaskState>(
      listener: (context, state) {
        if (state.message != null) {
          _showMessage(state.message!);
        }
        if (state.hasError) {
          _showErrorMessage(state.errorMessage ?? '操作失败');
        }
      },
      builder: (context, state) {
        final todayTasks = state.tasks.where((task) {
          return _isSameDay(task.startTime, _selectedDate);
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
                        ? '今天的任务'
                        : _getFormattedDate(_selectedDate),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0277BD),
                    ),
                  ),
                  const Spacer(),
                  if (todayTasks.isNotEmpty)
                    TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 400),
                      tween: Tween(begin: 0, end: 1),
                      curve: Curves.elasticOut,
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(
                                    0xFF4FC3F7,
                                  ).withValues(alpha: 0.2),
                                  const Color(
                                    0xFF4FC3F7,
                                  ).withValues(alpha: 0.1),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(
                                  0xFF4FC3F7,
                                ).withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              '${todayTasks.length}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF0277BD),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (todayTasks.isEmpty)
              _buildEmptyState()
            else
              ...todayTasks.asMap().entries.map((entry) {
                return TweenAnimationBuilder<double>(
                  duration: Duration(milliseconds: 400 + (entry.key * 100)),
                  tween: Tween(begin: 0, end: 1),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(0, 30 * (1 - value)),
                      child: Opacity(
                        opacity: value,
                        child: _buildTaskCard(entry.value),
                      ),
                    );
                  },
                );
              }),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      tween: Tween(begin: 0, end: 1),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
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
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
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
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Column(
                    children: [
                      TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 800),
                        tween: Tween(begin: 0, end: 1),
                        curve: Curves.elasticOut,
                        builder: (context, scaleValue, child) {
                          return Transform.scale(
                            scale: scaleValue,
                            child: Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                gradient: RadialGradient(
                                  colors: [
                                    const Color(
                                      0xFF4FC3F7,
                                    ).withValues(alpha: 0.3),
                                    const Color(
                                      0xFF4FC3F7,
                                    ).withValues(alpha: 0.1),
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
                        '这一天还没有任务',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0277BD),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '点击右下角的 + 按钮添加新的任务',
                        style: TextStyle(
                          fontSize: 14,
                          color: const Color(0xFF0288D1).withValues(alpha: 0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      // 番茄钟快速启动按钮
                      GestureDetector(
                        onTap: _openPomodoro,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF4FC3F7), Color(0xFF29B6F6)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF4FC3F7,
                                ).withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                CupertinoIcons.timer,
                                color: Colors.white,
                                size: 18,
                              ),
                              SizedBox(width: 8),
                              Text(
                                '开始专注时间',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTaskCard(Task task) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.4),
            Colors.white.withValues(alpha: 0.1),
            Colors.white.withValues(alpha: 0.2),
          ],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: _getCategoryColor(task.category).withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _editTask(task),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              colors: [
                                _getCategoryColor(
                                  task.category,
                                ).withValues(alpha: 0.3),
                                _getCategoryColor(
                                  task.category,
                                ).withValues(alpha: 0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            _getCategoryIcon(task.category),
                            color: _getCategoryColor(task.category),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                task.title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF0277BD),
                                ),
                              ),
                              if (task.description != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  task.description!,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: const Color(
                                      0xFF0288D1,
                                    ).withValues(alpha: 0.7),
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),
                        _buildPriorityBadge(task.priority),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          CupertinoIcons.time,
                          size: 16,
                          color: const Color(0xFF0288D1).withValues(alpha: 0.7),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _formatTaskTime(task),
                          style: TextStyle(
                            fontSize: 12,
                            color: const Color(
                              0xFF0288D1,
                            ).withValues(alpha: 0.7),
                          ),
                        ),
                        const Spacer(),
                        // 番茄钟快速启动按钮
                        GestureDetector(
                          onTap: () => _startPomodoroForTask(task),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF4FC3F7,
                              ).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(
                                  0xFF4FC3F7,
                                ).withValues(alpha: 0.3),
                              ),
                            ),
                            child: const Icon(
                              CupertinoIcons.timer,
                              size: 14,
                              color: Color(0xFF0277BD),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildStatusBadge(task.status),
                      ],
                    ),
                    if (task.tags.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: task.tags.take(3).map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF4FC3F7,
                              ).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(
                                  0xFF4FC3F7,
                                ).withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              tag,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF0277BD),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityBadge(TaskPriority priority) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getPriorityColor(priority).withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getPriorityColor(priority).withValues(alpha: 0.5),
        ),
      ),
      child: Text(
        priority.label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: _getPriorityColor(priority),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(TaskStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getStatusColor(status).withValues(alpha: 0.5),
        ),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: _getStatusColor(status),
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      tween: Tween(begin: 0, end: 1),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF4FC3F7), Color(0xFF29B6F6)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4FC3F7).withValues(alpha: 0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: FloatingActionButton(
              onPressed: _createTask,
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
              elevation: 0,
              child: const Icon(CupertinoIcons.add, size: 26),
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
    return '${date.month}月${date.day}日的任务';
  }

  String _formatTaskTime(Task task) {
    final start = task.startTime;
    final end = task.endTime;

    if (start.day == end.day) {
      return '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')} - '
          '${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}';
    } else {
      return '${start.month}/${start.day} ${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')} - '
          '${end.month}/${end.day} ${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}';
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isToday(DateTime date) {
    return _isSameDay(date, DateTime.now());
  }

  bool _hasTasksOnDate(DateTime date, List<Task> tasks) {
    return tasks.any((task) => _isSameDay(task.startTime, date));
  }

  Color _getCategoryColor(TaskCategory category) {
    switch (category) {
      case TaskCategory.work:
        return const Color(0xFF4FC3F7);
      case TaskCategory.personal:
        return const Color(0xFF81C784);
      case TaskCategory.study:
        return const Color(0xFFAB47BC);
      case TaskCategory.health:
        return const Color(0xFFE57373);
      case TaskCategory.social:
        return const Color(0xFFFFB74D);
      case TaskCategory.other:
        return const Color(0xFF90A4AE);
    }
  }

  IconData _getCategoryIcon(TaskCategory category) {
    switch (category) {
      case TaskCategory.work:
        return CupertinoIcons.briefcase;
      case TaskCategory.personal:
        return CupertinoIcons.person;
      case TaskCategory.study:
        return CupertinoIcons.book;
      case TaskCategory.health:
        return CupertinoIcons.heart;
      case TaskCategory.social:
        return CupertinoIcons.group;
      case TaskCategory.other:
        return CupertinoIcons.tag;
    }
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return const Color(0xFF81C784);
      case TaskPriority.medium:
        return const Color(0xFF4FC3F7);
      case TaskPriority.high:
        return const Color(0xFFFFB74D);
      case TaskPriority.urgent:
        return const Color(0xFFE57373);
    }
  }

  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return const Color(0xFF90A4AE);
      case TaskStatus.inProgress:
        return const Color(0xFF4FC3F7);
      case TaskStatus.completed:
        return const Color(0xFF81C784);
      case TaskStatus.cancelled:
        return const Color(0xFFE57373);
    }
  }

  void _goToToday() {
    setState(() {
      _selectedDate = DateTime.now();
      _focusedDate = DateTime.now();
    });
    context.read<TaskBloc>().add(TaskDateChanged(DateTime.now()));
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

  void _createTask() {
    final taskBloc = context.read<TaskBloc>(); // 在导航前获取BLoC实例
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        pageBuilder: (context, animation, secondaryAnimation) {
          return BlocProvider.value(
            value: taskBloc, // 使用预先获取的实例
            child: TaskFormPage(initialDate: _selectedDate),
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
                .animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
            child: child,
          );
        },
      ),
    );
  }

  void _editTask(Task task) {
    final taskBloc = context.read<TaskBloc>(); // 在导航前获取BLoC实例
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        pageBuilder: (context, animation, secondaryAnimation) {
          return BlocProvider.value(
            value: taskBloc, // 使用预先获取的实例
            child: TaskFormPage(task: task),
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
                .animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
            child: child,
          );
        },
      ),
    );
  }

  void _startPomodoroForTask(Task task) {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        pageBuilder: (context, animation, secondaryAnimation) {
          return const PomodoroPage();
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
                .animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
            child: child,
          );
        },
      ),
    );

    // 显示提示消息
    _showMessage('为任务"${task.title}"启动番茄钟');
  }

  void _openPomodoro() {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        pageBuilder: (context, animation, secondaryAnimation) {
          return const PomodoroPage();
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
                .animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
            child: child,
          );
        },
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

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
