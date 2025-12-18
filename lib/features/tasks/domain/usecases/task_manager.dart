import 'package:dartz/dartz.dart';
import 'package:my_first_app/core/error/failures.dart';
import '../entities/task.dart';
import '../repositories/task_repository.dart';

/// 任务管理器用例
///
/// 封装任务相关的业务逻辑，提供高级的任务操作功能
class TaskManager {
  final TaskRepository _repository;

  const TaskManager(this._repository);

  /// 创建新任务
  ///
  /// 在创建前会检查时间冲突和数据有效性
  Future<Either<Failure, String>> createTask({
    required String title,
    String? description,
    required DateTime startTime,
    required DateTime endTime,
    List<String> tags = const [],
    TaskPriority priority = TaskPriority.medium,
    TaskCategory category = TaskCategory.personal,
  }) async {
    // 验证输入数据
    final validationResult = _validateTaskData(
      title: title,
      startTime: startTime,
      endTime: endTime,
    );

    if (validationResult != null) {
      return Left(ValidationFailure(validationResult));
    }

    // 检查时间冲突
    final conflictsResult = await _repository.checkTimeConflicts(
      startTime,
      endTime,
    );

    return conflictsResult.fold((failure) => Left(failure), (conflicts) {
      if (conflicts.isNotEmpty) {
        return Left(ValidationFailure('时间冲突：与 ${conflicts.length} 个任务时间重叠'));
      }

      // 创建任务实体
      final task = Task(
        id: _generateTaskId(),
        title: title.trim(),
        description: description?.trim(),
        startTime: startTime,
        endTime: endTime,
        tags: tags
            .map((tag) => tag.trim())
            .where((tag) => tag.isNotEmpty)
            .toList(),
        priority: priority,
        status: TaskStatus.pending,
        category: category,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      return _repository.createTask(task);
    });
  }

  /// 更新任务
  ///
  /// 支持部分更新，只更新提供的字段
  Future<Either<Failure, void>> updateTask({
    required String taskId,
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    List<String>? tags,
    TaskPriority? priority,
    TaskStatus? status,
    TaskCategory? category,
  }) async {
    // 获取现有任务
    final taskResult = await _repository.getTaskById(taskId);

    return taskResult.fold((failure) => Left(failure), (existingTask) {
      if (existingTask == null) {
        return Left(NotFoundFailure('任务不存在'));
      }

      // 创建更新后的任务
      final updatedTask = existingTask.copyWith(
        title: title,
        description: description,
        startTime: startTime,
        endTime: endTime,
        tags: tags,
        priority: priority,
        status: status,
        category: category,
        updatedAt: DateTime.now(),
      );

      // 验证更新后的数据
      final validationResult = _validateTaskData(
        title: updatedTask.title,
        startTime: updatedTask.startTime,
        endTime: updatedTask.endTime,
      );

      if (validationResult != null) {
        return Left(ValidationFailure(validationResult));
      }

      // 如果时间发生变化，检查冲突
      if (startTime != null || endTime != null) {
        return _checkConflictsAndUpdate(updatedTask);
      }

      return _repository.updateTask(updatedTask);
    });
  }

  /// 标记任务为完成
  Future<Either<Failure, void>> completeTask(String taskId) async {
    return updateTask(taskId: taskId, status: TaskStatus.completed);
  }

  /// 开始任务
  Future<Either<Failure, void>> startTask(String taskId) async {
    return updateTask(taskId: taskId, status: TaskStatus.inProgress);
  }

  /// 取消任务
  Future<Either<Failure, void>> cancelTask(String taskId) async {
    return updateTask(taskId: taskId, status: TaskStatus.cancelled);
  }

  /// 删除任务
  Future<Either<Failure, void>> deleteTask(String taskId) async {
    return _repository.deleteTask(taskId);
  }

  /// 获取今日任务
  Future<Either<Failure, List<Task>>> getTodayTasks() async {
    final today = DateTime.now();
    return _repository.getTasksForDate(today);
  }

  /// 获取即将到来的任务（未来7天）
  Future<Either<Failure, List<Task>>> getUpcomingTasks() async {
    final allTasksResult = await _repository.getAllTasks();

    return allTasksResult.fold((failure) => Left(failure), (allTasks) {
      final now = DateTime.now();
      final nextWeek = now.add(const Duration(days: 7));

      final upcomingTasks = allTasks.where((task) {
        return task.status == TaskStatus.pending &&
            task.startTime.isAfter(now) &&
            task.startTime.isBefore(nextWeek);
      }).toList();

      // 按开始时间排序
      upcomingTasks.sort((a, b) => a.startTime.compareTo(b.startTime));

      return Right(upcomingTasks);
    });
  }

  /// 获取过期任务
  Future<Either<Failure, List<Task>>> getOverdueTasks() async {
    final allTasksResult = await _repository.getAllTasks();

    return allTasksResult.fold((failure) => Left(failure), (allTasks) {
      final overdueTasks = allTasks.where((task) => task.isOverdue).toList();

      // 按结束时间排序（最早过期的在前）
      overdueTasks.sort((a, b) => a.endTime.compareTo(b.endTime));

      return Right(overdueTasks);
    });
  }

  /// 搜索任务
  Future<Either<Failure, List<Task>>> searchTasks(String query) async {
    if (query.trim().isEmpty) {
      return const Right([]);
    }

    return _repository.searchTasks(query.trim());
  }

  /// 获取任务统计信息
  Future<Either<Failure, TaskStatistics>> getTaskStatistics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return _repository.getTaskStatistics(
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// 批量更新任务状态
  Future<Either<Failure, void>> updateMultipleTasksStatus(
    List<String> taskIds,
    TaskStatus status,
  ) async {
    if (taskIds.isEmpty) {
      return const Right(null);
    }

    return _repository.updateTasksStatus(taskIds, status);
  }

  /// 检查时间冲突并更新任务
  Future<Either<Failure, void>> _checkConflictsAndUpdate(Task task) async {
    final conflictsResult = await _repository.checkTimeConflicts(
      task.startTime,
      task.endTime,
      excludeTaskId: task.id,
    );

    return conflictsResult.fold((failure) => Left(failure), (conflicts) {
      if (conflicts.isNotEmpty) {
        return Left(ValidationFailure('时间冲突：与 ${conflicts.length} 个任务时间重叠'));
      }

      return _repository.updateTask(task);
    });
  }

  /// 验证任务数据
  String? _validateTaskData({
    required String title,
    required DateTime startTime,
    required DateTime endTime,
  }) {
    if (title.trim().isEmpty) {
      return '任务标题不能为空';
    }

    if (title.trim().length > 200) {
      return '任务标题不能超过200个字符';
    }

    if (endTime.isBefore(startTime)) {
      return '结束时间不能早于开始时间';
    }

    if (endTime.isAtSameMomentAs(startTime)) {
      return '结束时间不能等于开始时间';
    }

    final duration = endTime.difference(startTime);
    if (duration.inDays > 30) {
      return '任务持续时间不能超过30天';
    }

    return null;
  }

  /// 生成任务ID
  String _generateTaskId() {
    return 'task_${DateTime.now().millisecondsSinceEpoch}_${_generateRandomString(6)}';
  }

  /// 生成随机字符串
  String _generateRandomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    var result = '';

    for (int i = 0; i < length; i++) {
      result += chars[(random + i) % chars.length];
    }

    return result;
  }
}
