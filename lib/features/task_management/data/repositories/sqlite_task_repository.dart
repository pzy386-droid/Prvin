import 'dart:async';

import 'package:prvin/core/database/database_helper.dart';
import 'package:prvin/features/task_management/domain/entities/task.dart';
import 'package:prvin/features/task_management/domain/repositories/task_repository.dart';
import 'package:prvin/features/task_management/domain/usecases/task_usecases.dart';

/// SQLite任务仓库实现
class SQLiteTaskRepository implements TaskRepository {

  SQLiteTaskRepository({DatabaseHelper? databaseHelper})
    : _databaseHelper = databaseHelper ?? DatabaseHelper();
  final DatabaseHelper _databaseHelper;
  final StreamController<List<Task>> _tasksController =
      StreamController<List<Task>>.broadcast();

  @override
  Stream<List<Task>> get tasks => _tasksController.stream;

  /// 刷新任务流
  Future<void> _refreshTasks() async {
    final allTasks = await _databaseHelper.getAllTasks();
    _tasksController.add(allTasks);
  }

  @override
  Future<Task> createTask(TaskCreateRequest request) async {
    // 检查时间冲突
    final conflictingTasks = await _databaseHelper.getConflictingTasks(
      request.startTime,
      request.endTime,
    );

    if (conflictingTasks.isNotEmpty) {
      final conflicts = conflictingTasks.map((task) {
        final overlapStart = request.startTime.isAfter(task.startTime)
            ? request.startTime
            : task.startTime;
        final overlapEnd = request.endTime.isBefore(task.endTime)
            ? request.endTime
            : task.endTime;
        final overlapDuration = overlapEnd.difference(overlapStart);

        return ConflictWarning(
          conflictingTask: task,
          newTask: Task(
            id: '',
            title: request.title,
            description: request.description,
            startTime: request.startTime,
            endTime: request.endTime,
            tags: request.tags,
            priority: request.priority,
            category: request.category,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          overlapDuration: overlapDuration,
        );
      }).toList();

      throw TaskConflictException(conflicts);
    }

    // 创建新任务
    final now = DateTime.now();
    final task = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
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

    await _databaseHelper.insertTask(task);
    await _refreshTasks();

    return task;
  }

  @override
  Future<Task> updateTask(String taskId, TaskUpdateRequest request) async {
    // 获取现有任务
    final allTasks = await _databaseHelper.getAllTasks();
    final existingTask = allTasks.firstWhere(
      (task) => task.id == taskId,
      orElse: () => throw TaskNotFoundException('任务不存在: $taskId'),
    );

    // 检查时间冲突（如果更新了时间）
    if (request.startTime != null || request.endTime != null) {
      final newStartTime = request.startTime ?? existingTask.startTime;
      final newEndTime = request.endTime ?? existingTask.endTime;

      final conflictingTasks = await _databaseHelper.getConflictingTasks(
        newStartTime,
        newEndTime,
        excludeTaskId: taskId,
      );

      if (conflictingTasks.isNotEmpty) {
        final conflicts = conflictingTasks.map((task) {
          final overlapStart = newStartTime.isAfter(task.startTime)
              ? newStartTime
              : task.startTime;
          final overlapEnd = newEndTime.isBefore(task.endTime)
              ? newEndTime
              : task.endTime;
          final overlapDuration = overlapEnd.difference(overlapStart);

          return ConflictWarning(
            conflictingTask: task,
            newTask: existingTask.copyWith(
              startTime: newStartTime,
              endTime: newEndTime,
            ),
            overlapDuration: overlapDuration,
          );
        }).toList();

        throw TaskConflictException(conflicts);
      }
    }

    // 更新任务
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

    await _databaseHelper.updateTask(updatedTask);
    await _refreshTasks();

    return updatedTask;
  }

  @override
  Future<void> deleteTask(String taskId) async {
    final result = await _databaseHelper.deleteTask(taskId);
    if (result == 0) {
      throw TaskNotFoundException('任务不存在: $taskId');
    }
    await _refreshTasks();
  }

  @override
  Future<Task?> getTaskById(String taskId) async {
    final allTasks = await _databaseHelper.getAllTasks();
    try {
      return allTasks.firstWhere((task) => task.id == taskId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<Task>> getTasksForDate(DateTime date) async {
    return _databaseHelper.getTasksForDate(date);
  }

  @override
  Future<List<Task>> getTasksInRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    return _databaseHelper.getTasksInRange(startDate, endDate);
  }

  @override
  Future<List<Task>> searchTasks(String query) async {
    return _databaseHelper.searchTasks(query);
  }

  @override
  Future<List<Task>> getTasksByCategory(TaskCategory category) async {
    return _databaseHelper.getTasksByCategory(category);
  }

  @override
  Future<List<Task>> getTasksByStatus(TaskStatus status) async {
    return _databaseHelper.getTasksByStatus(status);
  }

  @override
  Future<List<Task>> getTasksByPriority(TaskPriority priority) async {
    final allTasks = await _databaseHelper.getAllTasks();
    return allTasks.where((task) => task.priority == priority).toList();
  }

  @override
  Future<List<Task>> getTasksByTags(List<String> tags) async {
    final allTasks = await _databaseHelper.getAllTasks();
    return allTasks.where((task) {
      return tags.any((tag) => task.tags.contains(tag));
    }).toList();
  }

  @override
  Future<List<Task>> getTasksByTag(String tag) async {
    final allTasks = await _databaseHelper.getAllTasks();
    return allTasks.where((task) => task.tags.contains(tag)).toList();
  }

  @override
  Future<List<ConflictWarning>> checkTimeConflicts(Task task) async {
    final conflictingTasks = await _databaseHelper.getConflictingTasks(
      task.startTime,
      task.endTime,
      excludeTaskId: task.id.isNotEmpty ? task.id : null,
    );

    return conflictingTasks.map((conflictingTask) {
      final overlapStart = task.startTime.isAfter(conflictingTask.startTime)
          ? task.startTime
          : conflictingTask.startTime;
      final overlapEnd = task.endTime.isBefore(conflictingTask.endTime)
          ? task.endTime
          : conflictingTask.endTime;
      final overlapDuration = overlapEnd.difference(overlapStart);

      return ConflictWarning(
        conflictingTask: conflictingTask,
        newTask: task,
        overlapDuration: overlapDuration,
      );
    }).toList();
  }

  @override
  Future<Map<String, dynamic>> getStatistics() async {
    return _databaseHelper.getTaskStatistics();
  }

  /// 初始化仓库（加载初始数据）
  Future<void> initialize() async {
    await _refreshTasks();
  }

  /// 清理所有数据
  Future<void> clearAllData() async {
    await _databaseHelper.clearAllData();
    await _refreshTasks();
  }

  /// 关闭仓库
  Future<void> close() async {
    await _tasksController.close();
  }
}
