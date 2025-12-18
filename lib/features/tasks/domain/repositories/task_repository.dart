import 'package:dartz/dartz.dart';
import 'package:my_first_app/core/error/failures.dart';
import '../entities/task.dart';

/// 任务仓库接口
///
/// 定义任务相关的业务操作，隔离数据访问细节
abstract class TaskRepository {
  /// 获取所有任务
  Future<Either<Failure, List<Task>>> getAllTasks();

  /// 根据日期获取任务
  Future<Either<Failure, List<Task>>> getTasksForDate(DateTime date);

  /// 根据状态获取任务
  Future<Either<Failure, List<Task>>> getTasksByStatus(TaskStatus status);

  /// 根据分类获取任务
  Future<Either<Failure, List<Task>>> getTasksByCategory(String category);

  /// 根据ID获取任务
  Future<Either<Failure, Task?>> getTaskById(String id);

  /// 搜索任务
  Future<Either<Failure, List<Task>>> searchTasks(String query);

  /// 创建任务
  Future<Either<Failure, String>> createTask(Task task);

  /// 更新任务
  Future<Either<Failure, void>> updateTask(Task task);

  /// 删除任务
  Future<Either<Failure, void>> deleteTask(String id);

  /// 批量更新任务状态
  Future<Either<Failure, void>> updateTasksStatus(
    List<String> taskIds,
    TaskStatus status,
  );

  /// 获取任务统计信息
  Future<Either<Failure, TaskStatistics>> getTaskStatistics({
    DateTime? startDate,
    DateTime? endDate,
  });

  /// 检查时间冲突
  Future<Either<Failure, List<Task>>> checkTimeConflicts(
    DateTime startTime,
    DateTime endTime, {
    String? excludeTaskId,
  });

  /// 清空所有任务
  Future<Either<Failure, void>> clearAllTasks();
}

/// 任务统计信息
class TaskStatistics {
  /// 总任务数
  final int totalTasks;

  /// 已完成任务数
  final int completedTasks;

  /// 进行中任务数
  final int inProgressTasks;

  /// 待办任务数
  final int todoTasks;

  /// 已取消任务数
  final int cancelledTasks;

  /// 按分类统计
  final Map<String, int> tasksByCategory;

  /// 按优先级统计
  final Map<TaskPriority, int> tasksByPriority;

  /// 完成率
  double get completionRate {
    if (totalTasks == 0) return 0.0;
    return completedTasks / totalTasks;
  }

  const TaskStatistics({
    required this.totalTasks,
    required this.completedTasks,
    required this.inProgressTasks,
    required this.todoTasks,
    required this.cancelledTasks,
    required this.tasksByCategory,
    required this.tasksByPriority,
  });
}
