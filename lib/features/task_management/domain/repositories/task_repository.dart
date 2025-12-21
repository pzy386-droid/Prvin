import 'package:prvin/features/task_management/domain/entities/task.dart';

/// 任务仓库接口
abstract class TaskRepository {
  /// 获取所有任务流
  Stream<List<Task>> get tasks;

  /// 创建新任务
  Future<Task> createTask(TaskCreateRequest request);

  /// 更新任务
  Future<Task> updateTask(String taskId, TaskUpdateRequest request);

  /// 删除任务
  Future<void> deleteTask(String taskId);

  /// 根据ID获取任务
  Future<Task?> getTaskById(String taskId);

  /// 获取指定日期的任务
  Future<List<Task>> getTasksForDate(DateTime date);

  /// 获取日期范围内的任务
  Future<List<Task>> getTasksInRange(DateTime startDate, DateTime endDate);

  /// 检查时间冲突
  Future<List<ConflictWarning>> checkTimeConflicts(Task task);

  /// 搜索任务
  Future<List<Task>> searchTasks(String query);

  /// 根据标签获取任务
  Future<List<Task>> getTasksByTag(String tag);

  /// 根据分类获取任务
  Future<List<Task>> getTasksByCategory(TaskCategory category);

  /// 根据状态获取任务
  Future<List<Task>> getTasksByStatus(TaskStatus status);
}
