import 'package:flutter/widget_previews.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:ui';

import 'package:prvin/features/task_management/domain/entities/task.dart';

/// 任务卡片预览
@Preview(name: '任务卡片 - 工作任务', group: '任务组件', size: Size(400, 200))
Widget workTaskCardPreview() {
  final task = Task(
    id: 'preview-1',
    title: '团队会议',
    description: '讨论Q4项目规划和目标设定',
    startTime: DateTime.now().add(const Duration(hours: 2)),
    endTime: DateTime.now().add(const Duration(hours: 3)),
    tags: const ['工作', '会议'],
    priority: TaskPriority.high,
    category: TaskCategory.work,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  return MaterialApp(
    home: Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: _buildTaskCard(task),
      ),
    ),
  );
}

@Preview(name: '任务卡片 - 个人任务', group: '任务组件', size: Size(400, 200))
Widget personalTaskCardPreview() {
  final task = Task(
    id: 'preview-2',
    title: '健身训练',
    description: '力量训练 + 有氧运动，保持身体健康',
    startTime: DateTime.now().add(const Duration(hours: 1)),
    endTime: DateTime.now().add(const Duration(hours: 2)),
    tags: const ['健康', '运动'],
    priority: TaskPriority.medium,
    category: TaskCategory.health,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  return MaterialApp(
    home: Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: _buildTaskCard(task),
      ),
    ),
  );
}

@Preview(
  name: '任务卡片 - 紧急任务',
  group: '任务组件',
  size: Size(400, 200),
  brightness: Brightness.dark,
)
Widget urgentTaskCardPreview() {
  final task = Task(
    id: 'preview-3',
    title: '紧急修复',
    description: '修复生产环境的关键bug',
    startTime: DateTime.now(),
    endTime: DateTime.now().add(const Duration(hours: 1)),
    tags: const ['紧急', '修复'],
    priority: TaskPriority.urgent,
    category: TaskCategory.work,
    status: TaskStatus.inProgress,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  return MaterialApp(
    theme: ThemeData.dark(),
    home: Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: _buildTaskCard(task),
      ),
    ),
  );
}

Widget _buildTaskCard(Task task) {
  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.4),
          Colors.white.withOpacity(0.1),
          Colors.white.withOpacity(0.2),
        ],
      ),
      border: Border.all(color: Colors.white.withOpacity(0.3)),
      boxShadow: [
        BoxShadow(
          color: _getCategoryColor(task.category).withOpacity(0.15),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
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
                          _getCategoryColor(task.category).withOpacity(0.3),
                          _getCategoryColor(task.category).withOpacity(0.1),
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
                              color: const Color(0xFF0288D1).withOpacity(0.7),
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
                    color: const Color(0xFF0288D1).withOpacity(0.7),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _formatTaskTime(task),
                    style: TextStyle(
                      fontSize: 12,
                      color: const Color(0xFF0288D1).withOpacity(0.7),
                    ),
                  ),
                  const Spacer(),
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
                        color: const Color(0xFF4FC3F7).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF4FC3F7).withOpacity(0.3),
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
  );
}

Widget _buildPriorityBadge(TaskPriority priority) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: _getPriorityColor(priority).withOpacity(0.2),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: _getPriorityColor(priority).withOpacity(0.5)),
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
      color: _getStatusColor(status).withOpacity(0.2),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: _getStatusColor(status).withOpacity(0.5)),
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

String _formatTaskTime(Task task) {
  final start = task.startTime;
  final end = task.endTime;

  if (start.day == end.day) {
    return '${start.hour.toString().padLeft(2, '0')}:'
        '${start.minute.toString().padLeft(2, '0')} - '
        '${end.hour.toString().padLeft(2, '0')}:'
        '${end.minute.toString().padLeft(2, '0')}';
  } else {
    return '${start.month}/${start.day} '
        '${start.hour.toString().padLeft(2, '0')}:'
        '${start.minute.toString().padLeft(2, '0')} - '
        '${end.month}/${end.day} '
        '${end.hour.toString().padLeft(2, '0')}:'
        '${end.minute.toString().padLeft(2, '0')}';
  }
}
