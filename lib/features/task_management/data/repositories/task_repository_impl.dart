import 'dart:async';
import 'dart:math';

import 'package:prvin/features/task_management/domain/entities/task.dart';
import 'package:prvin/features/task_management/domain/repositories/task_repository.dart';

/// 任务仓库内存实现（用于演示和测试）
class TaskRepositoryImpl implements TaskRepository {
  TaskRepositoryImpl() {
    _initializeSampleTasks();
    // 初始化完成后发送数据
    _notifyListeners();
  }

  final List<Task> _tasks = [];
  final StreamController<List<Task>> _tasksController =
      StreamController<List<Task>>.broadcast();

  /// 获取当前任务列表（用于直接访问）
  List<Task> get currentTasks => List.from(_tasks);

  @override
  Stream<List<Task>> get tasks => _tasksController.stream;

  void _initializeSampleTasks() {
    // 不添加任何示例任务，让用户从空白开始
    // 用户可以自己创建任务
  }

  @override
  Future<Task> createTask(TaskCreateRequest request) async {
    print('=== TaskRepository: 开始创建任务 ===');
    print('请求标题: ${request.title}');

    // 模拟网络延迟
    print('模拟网络延迟...');
    await Future<void>.delayed(const Duration(milliseconds: 500));

    final now = DateTime.now();
    final task = Task(
      id: _generateId(),
      title: request.title,
      description: request.description,
      startTime: request.startTime,
      endTime: request.endTime,
      tags: request.tags,
      priority: request.priority,
      category: request.category,
      createdAt: now,
      updatedAt: now,
    );

    print('创建的任务对象: ${task.id} - ${task.title}');

    _tasks.add(task);
    print('任务已添加到内存列表，当前任务数量: ${_tasks.length}');

    _notifyListeners();
    print('已通知监听器');
    print('=== TaskRepository: 任务创建完成 ===');

    return task;
  }

  @override
  Future<Task> updateTask(String taskId, TaskUpdateRequest request) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _tasks.indexWhere((task) => task.id == taskId);
    if (index == -1) {
      throw Exception('Task not found: $taskId');
    }

    final existingTask = _tasks[index];
    final updatedTask = existingTask.copyWith(
      title: request.title,
      description: request.description,
      startTime: request.startTime,
      endTime: request.endTime,
      tags: request.tags,
      priority: request.priority,
      status: request.status,
      category: request.category,
      updatedAt: DateTime.now(),
    );

    _tasks[index] = updatedTask;
    _notifyListeners();
    return updatedTask;
  }

  @override
  Future<void> deleteTask(String taskId) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 200));

    _tasks.removeWhere((task) => task.id == taskId);
    _notifyListeners();
  }

  @override
  Future<Task?> getTaskById(String taskId) async {
    await Future.delayed(const Duration(milliseconds: 100));

    try {
      return _tasks.firstWhere((task) => task.id == taskId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<Task>> getTasksForDate(DateTime date) async {
    await Future.delayed(const Duration(milliseconds: 200));

    return _tasks.where((task) {
      return task.startTime.year == date.year &&
          task.startTime.month == date.month &&
          task.startTime.day == date.day;
    }).toList();
  }

  @override
  Future<List<Task>> getTasksInRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));

    return _tasks.where((task) {
      return task.startTime.isAfter(
            startDate.subtract(const Duration(days: 1)),
          ) &&
          task.startTime.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  @override
  Future<List<ConflictWarning>> checkTimeConflicts(Task task) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final conflicts = <ConflictWarning>[];

    for (final existingTask in _tasks) {
      // 跳过自己
      if (existingTask.id == task.id) continue;

      // 检查时间重叠
      if (_hasTimeOverlap(task, existingTask)) {
        final overlapDuration = _calculateOverlapDuration(task, existingTask);
        conflicts.add(
          ConflictWarning(
            conflictingTask: existingTask,
            newTask: task,
            overlapDuration: overlapDuration,
          ),
        );
      }
    }

    return conflicts;
  }

  @override
  Future<List<Task>> searchTasks(String query) async {
    await Future.delayed(const Duration(milliseconds: 300));

    if (query.isEmpty) return List.from(_tasks);

    final lowerQuery = query.toLowerCase();
    return _tasks.where((task) {
      return task.title.toLowerCase().contains(lowerQuery) ||
          (task.description?.toLowerCase().contains(lowerQuery) ?? false) ||
          task.tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
    }).toList();
  }

  @override
  Future<List<Task>> getTasksByTag(String tag) async {
    await Future.delayed(const Duration(milliseconds: 200));

    return _tasks.where((task) => task.tags.contains(tag)).toList();
  }

  @override
  Future<List<Task>> getTasksByCategory(TaskCategory category) async {
    await Future.delayed(const Duration(milliseconds: 200));

    return _tasks.where((task) => task.category == category).toList();
  }

  @override
  Future<List<Task>> getTasksByStatus(TaskStatus status) async {
    await Future.delayed(const Duration(milliseconds: 200));

    return _tasks.where((task) => task.status == status).toList();
  }

  // 私有辅助方法

  void _notifyListeners() {
    _tasksController.add(List.from(_tasks));
  }

  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString() +
        Random().nextInt(1000).toString();
  }

  bool _hasTimeOverlap(Task task1, Task task2) {
    return task1.startTime.isBefore(task2.endTime) &&
        task1.endTime.isAfter(task2.startTime);
  }

  Duration _calculateOverlapDuration(Task task1, Task task2) {
    final overlapStart = task1.startTime.isAfter(task2.startTime)
        ? task1.startTime
        : task2.startTime;
    final overlapEnd = task1.endTime.isBefore(task2.endTime)
        ? task1.endTime
        : task2.endTime;

    return overlapEnd.difference(overlapStart);
  }

  void dispose() {
    _tasksController.close();
  }
}
