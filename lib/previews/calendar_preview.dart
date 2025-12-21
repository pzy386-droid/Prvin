import 'package:flutter/widget_previews.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:ui';

/// 日历组件预览
@Preview(name: '日历头部', group: '日历组件', size: Size(400, 100))
Widget calendarHeaderPreview() {
  return MaterialApp(
    home: Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: _buildCalendarHeader(),
      ),
    ),
  );
}

@Preview(name: '星期标题', group: '日历组件', size: Size(400, 60))
Widget weekDaysPreview() {
  return MaterialApp(
    home: Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      body: Padding(padding: const EdgeInsets.all(20), child: _buildWeekDays()),
    ),
  );
}

@Preview(name: '日期格子 - 今天', group: '日历组件', size: Size(80, 80))
Widget todayDateCellPreview() {
  return MaterialApp(
    home: Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      body: Center(
        child: SizedBox(
          width: 60,
          height: 60,
          child: _buildDateCell(
            DateTime.now(),
            isToday: true,
            isSelected: false,
          ),
        ),
      ),
    ),
  );
}

@Preview(name: '日期格子 - 选中', group: '日历组件', size: Size(80, 80))
Widget selectedDateCellPreview() {
  return MaterialApp(
    home: Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      body: Center(
        child: SizedBox(
          width: 60,
          height: 60,
          child: _buildDateCell(
            DateTime.now().add(const Duration(days: 1)),
            isToday: false,
            isSelected: true,
          ),
        ),
      ),
    ),
  );
}

@Preview(name: '日期格子 - 有任务', group: '日历组件', size: Size(80, 80))
Widget dateWithTasksPreview() {
  return MaterialApp(
    home: Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      body: Center(
        child: SizedBox(
          width: 60,
          height: 60,
          child: _buildDateCellWithTasks(
            DateTime.now().add(const Duration(days: 2)),
          ),
        ),
      ),
    ),
  );
}

Widget _buildCalendarHeader() {
  final focusedDate = DateTime.now();

  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      _buildNavButton(icon: CupertinoIcons.chevron_left, onTap: () {}),
      Text(
        '${focusedDate.year}年${focusedDate.month}月',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF0277BD),
        ),
      ),
      _buildNavButton(icon: CupertinoIcons.chevron_right, onTap: () {}),
    ],
  );
}

Widget _buildNavButton({required IconData icon, required VoidCallback onTap}) {
  return Container(
    width: 32,
    height: 32,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          const Color(0xFF4FC3F7).withOpacity(0.25),
          const Color(0xFF4FC3F7).withOpacity(0.1),
        ],
      ),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: const Color(0xFF4FC3F7).withOpacity(0.3)),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF4FC3F7).withOpacity(0.2),
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
                  ? const Color(0xFFFF7043).withOpacity(0.8)
                  : const Color(0xFF0288D1).withOpacity(0.7),
            ),
          ),
        ),
      );
    }).toList(),
  );
}

Widget _buildDateCell(
  DateTime date, {
  required bool isToday,
  required bool isSelected,
}) {
  return Container(
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
                const Color(0xFF4FC3F7).withOpacity(0.3),
                const Color(0xFF4FC3F7).withOpacity(0.1),
              ],
            )
          : null,
      borderRadius: BorderRadius.circular(10),
      border: isSelected || isToday
          ? Border.all(color: const Color(0xFF4FC3F7).withOpacity(0.5))
          : null,
      boxShadow: isSelected
          ? [
              BoxShadow(
                color: const Color(0xFF4FC3F7).withOpacity(0.4),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ]
          : null,
    ),
    child: Center(
      child: Text(
        '${date.day}',
        style: TextStyle(
          fontSize: 14,
          fontWeight: isToday || isSelected ? FontWeight.w600 : FontWeight.w500,
          color: isSelected
              ? Colors.white
              : isToday
              ? const Color(0xFF0277BD)
              : const Color(0xFF0288D1).withOpacity(0.8),
        ),
      ),
    ),
  );
}

Widget _buildDateCellWithTasks(DateTime date) {
  return Container(
    margin: const EdgeInsets.all(1),
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
    child: Padding(
      padding: const EdgeInsets.all(4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 日期数字
          Align(
            alignment: Alignment.topCenter,
            child: Text(
              '${date.day}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF0288D1),
              ),
            ),
          ),
          const SizedBox(height: 4),
          // 任务条
          Expanded(
            child: Column(
              children: [
                _buildTaskBar(const Color(0xFF4FC3F7)), // 工作任务
                const SizedBox(height: 2),
                _buildTaskBar(const Color(0xFFE57373)), // 健康任务
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildTaskBar(Color color) {
  return Container(
    width: double.infinity,
    height: 12,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        end: Alignment.centerRight,
        colors: [color.withOpacity(0.9), color.withOpacity(0.7)],
      ),
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: color.withOpacity(0.4), width: 0.5),
      boxShadow: [
        BoxShadow(
          color: color.withOpacity(0.3),
          blurRadius: 2,
          offset: const Offset(0, 1),
        ),
      ],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    ),
  );
}
