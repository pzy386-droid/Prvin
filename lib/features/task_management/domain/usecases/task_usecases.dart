import 'package:prvin/features/task_management/domain/entities/task.dart';
import 'package:prvin/features/task_management/domain/repositories/task_repository.dart';

/// 任务用例类
class TaskUseCases {
  const TaskUseCases(this._repository);

  final TaskRepository _repository;

  /// 获取仓库实例（用于特殊操作）
  TaskRepository get repository => _repository;

  /// 获取所有任务流
  Stream<List<Task>> get tasks => _repository.tasks;

  /// 创建任务
  Future<Task> createTask(TaskCreateRequest request) async {
    print('=== TaskUseCases: 开始创建任务 ===');
    print('请求数据: ${request.title}');

    // 验证任务数据
    print('开始验证任务数据...');
    try {
      _validateTaskRequest(request);
      print('任务数据验证通过');
    } catch (e) {
      print('任务数据验证失败: $e');
      rethrow;
    }

    // 检查时间冲突
    print('创建临时任务对象进行冲突检测...');
    final tempTask = Task(
      id: 'temp',
      title: request.title,
      description: request.description,
      startTime: request.startTime,
      endTime: request.endTime,
      tags: request.tags,
      priority: request.priority,
      category: request.category,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    print('检查时间冲突...');
    try {
      final conflicts = await _repository.checkTimeConflicts(tempTask);
      if (conflicts.isNotEmpty) {
        print('发现时间冲突: ${conflicts.length}个');
        throw TaskConflictException(conflicts);
      }
      print('无时间冲突');
    } catch (e) {
      print('冲突检测出错: $e');
      rethrow;
    }

    print('调用Repository创建任务...');
    try {
      final task = await _repository.createTask(request);
      print('Repository创建任务成功: ${task.id}');
      return task;
    } catch (e) {
      print('Repository创建任务失败: $e');
      rethrow;
    }
  }

  /// 更新任务
  Future<Task> updateTask(String taskId, TaskUpdateRequest request) async {
    final existingTask = await _repository.getTaskById(taskId);
    if (existingTask == null) {
      throw TaskNotFoundException(taskId);
    }

    // 如果更新了时间，检查冲突
    if (request.startTime != null || request.endTime != null) {
      final updatedTask = existingTask.copyWith(
        startTime: request.startTime,
        endTime: request.endTime,
      );
      final conflicts = await _repository.checkTimeConflicts(updatedTask);
      if (conflicts.isNotEmpty) {
        throw TaskConflictException(conflicts);
      }
    }

    return _repository.updateTask(taskId, request);
  }

  /// 删除任务
  Future<void> deleteTask(String taskId) async {
    return _repository.deleteTask(taskId);
  }

  /// 获取指定日期的任务
  Future<List<Task>> getTasksForDate(DateTime date) async {
    return _repository.getTasksForDate(date);
  }

  /// 获取今天的任务
  Future<List<Task>> getTodayTasks() async {
    return getTasksForDate(DateTime.now());
  }

  /// 获取本周的任务
  Future<List<Task>> getWeekTasks() async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return _repository.getTasksInRange(startOfWeek, endOfWeek);
  }

  /// 获取过期任务
  Future<List<Task>> getOverdueTasks() async {
    final allTasks = await _repository.tasks.first;
    return allTasks.where((task) => task.isOverdue).toList();
  }

  /// 完成任务
  Future<Task> completeTask(String taskId) async {
    return updateTask(
      taskId,
      const TaskUpdateRequest(status: TaskStatus.completed),
    );
  }

  /// 搜索任务
  Future<List<Task>> searchTasks(String query) async {
    return _repository.searchTasks(query);
  }

  /// 根据标签获取任务
  Future<List<Task>> getTasksByTag(String tag) async {
    return _repository.getTasksByTag(tag);
  }

  /// 根据分类获取任务
  Future<List<Task>> getTasksByCategory(TaskCategory category) async {
    return _repository.getTasksByCategory(category);
  }

  /// 验证任务请求
  void _validateTaskRequest(TaskCreateRequest request) {
    if (request.title.trim().isEmpty) {
      throw const TaskValidationException('任务标题不能为空');
    }

    if (request.startTime.isAfter(request.endTime)) {
      throw const TaskValidationException('开始时间不能晚于结束时间');
    }

    // 移除了结束时间不能早于当前时间的限制，允许创建过去的任务
  }
}

/// 任务相关异常类
class TaskException implements Exception {
  const TaskException(this.message);
  final String message;

  @override
  String toString() => 'TaskException: $message';
}

class TaskNotFoundException extends TaskException {
  const TaskNotFoundException(String taskId) : super('任务未找到: $taskId');
}

class TaskValidationException extends TaskException {
  const TaskValidationException(super.message);
}

class TaskConflictException extends TaskException {
  const TaskConflictException(this.conflicts) : super('任务时间冲突');
  final List<ConflictWarning> conflicts;
}
