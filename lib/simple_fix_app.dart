import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const SimpleFix());
}

class SimpleFix extends StatelessWidget {
  const SimpleFix({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Prvin 修复版',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: '.SF Pro Display',
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4FC3F7)),
      ),
      debugShowCheckedModeBanner: false,
      home: const SimpleCalendarPage(),
    );
  }
}

class SimpleCalendarPage extends StatefulWidget {
  const SimpleCalendarPage({super.key});

  @override
  State<SimpleCalendarPage> createState() => _SimpleCalendarPageState();
}

class _SimpleCalendarPageState extends State<SimpleCalendarPage> {
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedDate = DateTime.now();
  final List<SimpleTask> _tasks = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB), Color(0xFFE1F5FE)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(child: _buildCalendar()),
              _buildTaskList(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        backgroundColor: const Color(0xFF4FC3F7),
        child: const Icon(CupertinoIcons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Text(
            '${_focusedDate.year}年${_focusedDate.month}月',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0277BD),
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: _previousMonth,
            icon: const Icon(CupertinoIcons.chevron_left),
          ),
          IconButton(
            onPressed: _nextMonth,
            icon: const Icon(CupertinoIcons.chevron_right),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          _buildWeekDays(),
          const SizedBox(height: 10),
          _buildCalendarGrid(),
        ],
      ),
    );
  }

  Widget _buildWeekDays() {
    const weekDays = ['日', '一', '二', '三', '四', '五', '六'];
    return Row(
      children: weekDays.map((day) {
        return Expanded(
          child: Center(
            child: Text(
              day,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0288D1),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDay = DateTime(_focusedDate.year, _focusedDate.month, 1);
    final lastDay = DateTime(_focusedDate.year, _focusedDate.month + 1, 0);
    final firstWeekday = firstDay.weekday == 7 ? 0 : firstDay.weekday;

    final weeks = <Widget>[];

    for (int week = 0; week < 6; week++) {
      final days = <Widget>[];

      for (int day = 0; day < 7; day++) {
        final index = week * 7 + day;

        if (index < firstWeekday) {
          days.add(const SizedBox(height: 50));
        } else if (index >= firstWeekday + lastDay.day) {
          days.add(const SizedBox(height: 50));
        } else {
          final dayNumber = index - firstWeekday + 1;
          final date = DateTime(
            _focusedDate.year,
            _focusedDate.month,
            dayNumber,
          );
          days.add(_buildDateCell(date));
        }
      }

      weeks.add(
        Row(children: days.map((day) => Expanded(child: day)).toList()),
      );
    }

    return Column(children: weeks);
  }

  Widget _buildDateCell(DateTime date) {
    final isSelected = _isSameDay(date, _selectedDate);
    final isToday = _isSameDay(date, DateTime.now());
    final tasksOnDate = _tasks
        .where((task) => _isSameDay(task.date, date))
        .toList();

    return GestureDetector(
      onTap: () => setState(() => _selectedDate = date),
      child: Container(
        height: 50,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF4FC3F7)
              : isToday
              ? const Color(0xFF4FC3F7).withValues(alpha: 0.3)
              : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${date.day}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF0277BD),
              ),
            ),
            if (tasksOnDate.isNotEmpty)
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : const Color(0xFF4FC3F7),
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskList() {
    final todayTasks = _tasks
        .where((task) => _isSameDay(task.date, _selectedDate))
        .toList();

    return Container(
      height: 200,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_selectedDate.month}月${_selectedDate.day}日的任务',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0277BD),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: todayTasks.isEmpty
                ? const Center(
                    child: Text(
                      '暂无任务',
                      style: TextStyle(color: Color(0xFF0288D1)),
                    ),
                  )
                : ListView.builder(
                    itemCount: todayTasks.length,
                    itemBuilder: (context, index) {
                      final task = todayTasks[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          task.title,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF0277BD),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showAddTaskDialog() {
    final titleController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('添加任务'),
        content: TextField(
          controller: titleController,
          decoration: const InputDecoration(
            hintText: '输入任务内容',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.trim().isNotEmpty) {
                setState(() {
                  _tasks.add(
                    SimpleTask(
                      title: titleController.text.trim(),
                      date: _selectedDate,
                    ),
                  );
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('任务添加成功')));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4FC3F7),
              foregroundColor: Colors.white,
            ),
            child: const Text('保存'),
          ),
        ],
      ),
    );
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

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class SimpleTask {
  final String title;
  final DateTime date;

  SimpleTask({required this.title, required this.date});
}
