import 'package:dartz/dartz.dart';
import 'package:my_first_app/core/error/failures.dart';
import 'package:my_first_app/features/tasks/domain/entities/task.dart';
import 'package:my_first_app/features/tasks/domain/repositories/task_repository.dart';
import 'package:prvin/features/tasks/data/datasources/task_local_datasource.dart';
import 'package:prvin/features/tasks/data/models/task_model.dart';

/// 任务仓库实现
///
/// 协调本地数据源和缓存，处理数据转换和错误处理
class TaskRepositoryImpl implements TaskRepository {

  const TaskRepositoryImpl(this._localDataSource);
  final TaskLocalDataSource _localDataSource;

  @override
  Future<Either<Failure, List<Task>>> getAllTasks() async {
    try {
      final taskModels = await _localDataSource.getAllTasks();
      final tasks = taskModels.map(_mapModelToEntity).toList();
      return Right(tasks);
    } catch (e) {
      return Left(DatabaseFailure('获取所有任务失败: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Task>>> getTasksForDate(DateTime date) async {
    try {
      final taskModels = await _localDataSource.getTasksForDate(date);
      final tasks = taskModels.map(_mapModelToEntity).toList();
      return Right(tasks);
    } catch (e) {
      return Left(DatabaseFailure('获取指定日期任务失败: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Task>>> getTasksByStatus(
    TaskStatus status,
  ) async {
    try {
      final modelStatus = _mapEntityStatusToModel(status);
      final taskModels = await _localDataSource.getTasksByStatus(modelStatus);
      final tasks = taskModels.map(_mapModelToEntity).toList();
      return Right(tasks);
    } catch (e) {
      return Left(DatabaseFailure('按状态获取任务失败: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Task>>> getTasksByCategory(
    String category,
  ) async {
    try {
      final taskModels = await _localDataSource.getTasksByCategory(category);
      final tasks = taskModels.map(_mapModelToEntity).toList();
      return Right(tasks);
    } catch (e) {
      return Left(DatabaseFailure('按分类获取任务失败: $e'));
    }
  }

  @override
  Future<Either<Failure, Task?>> getTaskById(String id) async {
    try {
      final taskModel = await _localDataSource.getTaskById(id);
      if (taskModel == null) return const Right(null);

      final task = _mapModelToEntity(taskModel);
      return Right(task);
    } catch (e) {
      return Left(DatabaseFailure('根据ID获取任务失败: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Task>>> searchTasks(String query) async {
    try {
      final taskModels = await _localDataSource.searchTasks(query);
      final tasks = taskModels.map(_mapModelToEntity).toList();
      return Right(tasks);
    } catch (e) {
      return Left(DatabaseFailure('搜索任务失败: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> createTask(Task task) async {
    try {
      final taskModel = _mapEntityToModel(task);
      final id = await _localDataSource.createTask(taskModel);
      return Right(id);
    } catch (e) {
      return Left(DatabaseFailure('创建任务失败: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateTask(Task task) async {
    try {
      final taskModel = _mapEntityToModel(task);
      await _localDataSource.updateTask(taskModel);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('更新任务失败: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTask(String id) async {
    try {
      await _localDataSource.deleteTask(id);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('删除任务失败: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateTasksStatus(
    List<String> taskIds,
    TaskStatus status,
  ) async {
    try {
      final modelStatus = _mapEntityStatusToModel(status);
      await _localDataSource.updateTasksStatus(taskIds, modelStatus);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('批量更新任务状态失败: $e'));
    }
  }

  @override
  Future<Either<Failure, TaskStatistics>> getTaskStatistics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final allTasks = await _localDataSource.getAllTasks();

      // 过滤日期范围
      final filteredTasks = allTasks.where((task) {
        if (startDate != null && task.createdAt.isBefore(startDate)) {
          return false;
        }
        if (endDate != null && task.createdAt.isAfter(endDate)) {
          return false;
        }
        return true;
      }).toList();

      // 计算统计信息
      final statistics = _calculateStatistics(filteredTasks);
      return Right(statistics);
    } catch (e) {
      return Left(DatabaseFailure('获取任务统计信息失败: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Task>>> checkTimeConflicts(
    DateTime startTime,
    DateTime endTime, {
    String? excludeTaskId,
  }) async {
    try {
      final allTasks = await _localDataSource.getAllTasks();

      final conflictingTasks = allTasks
          .where((taskModel) {
            // 排除指定的任务
            if (excludeTaskId != null && taskModel.id == excludeTaskId) {
              return false;
            }

            // 只检查未完成和未取消的任务
            if (taskModel.status == TaskStatus.completed ||
                taskModel.status == TaskStatus.cancelled) {
              return false;
            }

            // 检查时间冲突
            return startTime.isBefore(taskModel.endTime) &&
                endTime.isAfter(taskModel.startTime);
          })
          .map(_mapModelToEntity)
          .toList();

      return Right(conflictingTasks);
    } catch (e) {
      return Left(DatabaseFailure('检查时间冲突失败: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> clearAllTasks() async {
    try {
      await _localDataSource.clearAllTasks();
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('清空所有任务失败: $e'));
    }
  }

  /// 将任务模型转换为任务实体
  Task _mapModelToEntity(TaskModel model) {
    return Task(
      id: model.id,
      title: model.title,
      description: model.description,
      startTime: model.startTime,
      endTime: model.endTime,
      tags: model.tags,
      priority: _mapModelPriorityToEntity(model.priority),
      status: _mapModelStatusToEntity(model.status),
      category: _mapModelCategoryToEntity(model.category),
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }

  /// 将任务实体转换为任务模型
  TaskModel _mapEntityToModel(Task entity) {
    return TaskModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      startTime: entity.startTime,
      endTime: entity.endTime,
      tags: entity.tags,
      priority: _mapEntityPriorityToModel(entity.priority),
      status: _mapEntityStatusToModel(entity.status),
      category: _mapEntityCategoryToModel(entity.category),
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// 映射优先级：模型 -> 实体
  TaskPriority _mapModelPriorityToEntity(TaskPriority modelPriority) {
    switch (modelPriority) {
      case TaskPriority.low:
        return TaskPriority.low;
      case TaskPriority.medium:
        return TaskPriority.medium;
      case TaskPriority.high:
        return TaskPriority.high;
      case TaskPriority.urgent:
        return TaskPriority.urgent;
    }
  }

  /// 映射优先级：实体 -> 模型
  TaskPriority _mapEntityPriorityToModel(TaskPriority entityPriority) {
    switch (entityPriority) {
      case TaskPriority.low:
        return TaskPriority.low;
      case TaskPriority.medium:
        return TaskPriority.medium;
      case TaskPriority.high:
        return TaskPriority.high;
      case TaskPriority.urgent:
        return TaskPriority.urgent;
    }
  }

  /// 映射状态：模型 -> 实体
  TaskStatus _mapModelStatusToEntity(TaskStatus modelStatus) {
    switch (modelStatus) {
      case TaskStatus.pending:
        return TaskStatus.pending;
      case TaskStatus.inProgress:
        return TaskStatus.inProgress;
      case TaskStatus.completed:
        return TaskStatus.completed;
      case TaskStatus.cancelled:
        return TaskStatus.cancelled;
    }
  }

  /// 映射状态：实体 -> 模型
  TaskStatus _mapEntityStatusToModel(TaskStatus entityStatus) {
    switch (entityStatus) {
      case TaskStatus.pending:
        return TaskStatus.pending;
      case TaskStatus.inProgress:
        return TaskStatus.inProgress;
      case TaskStatus.completed:
        return TaskStatus.completed;
      case TaskStatus.cancelled:
        return TaskStatus.cancelled;
    }
  }

  /// 映射分类：模型 -> 实体
  TaskCategory _mapModelCategoryToEntity(TaskCategory modelCategory) {
    switch (modelCategory) {
      case TaskCategory.work:
        return TaskCategory.work;
      case TaskCategory.personal:
        return TaskCategory.personal;
      case TaskCategory.health:
        return TaskCategory.health;
      case TaskCategory.learning:
        return TaskCategory.learning;
      case TaskCategory.social:
        return TaskCategory.social;
    }
  }

  /// 映射分类：实体 -> 模型
  TaskCategory _mapEntityCategoryToModel(TaskCategory entityCategory) {
    switch (entityCategory) {
      case TaskCategory.work:
        return TaskCategory.work;
      case TaskCategory.personal:
        return TaskCategory.personal;
      case TaskCategory.health:
        return TaskCategory.health;
      case TaskCategory.learning:
        return TaskCategory.learning;
      case TaskCategory.social:
        return TaskCategory.social;
    }
  }

  /// 计算任务统计信息
  TaskStatistics _calculateStatistics(List<TaskModel> tasks) {
    final totalTasks = tasks.length;
    var completedTasks = 0;
    var inProgressTasks = 0;
    var todoTasks = 0;
    var cancelledTasks = 0;

    final tasksByCategory = <String, int>{};
    final tasksByPriority = <TaskPriority, int>{};

    for (final task in tasks) {
      // 统计状态
      switch (task.status) {
        case TaskStatus.completed:
          completedTasks++;
        case TaskStatus.inProgress:
          inProgressTasks++;
        case TaskStatus.pending:
          todoTasks++;
        case TaskStatus.cancelled:
          cancelledTasks++;
      }

      // 统计分类
      final categoryName = task.category.name;
      tasksByCategory[categoryName] = (tasksByCategory[categoryName] ?? 0) + 1;

      // 统计优先级
      tasksByPriority[task.priority] =
          (tasksByPriority[task.priority] ?? 0) + 1;
    }

    return TaskStatistics(
      totalTasks: totalTasks,
      completedTasks: completedTasks,
      inProgressTasks: inProgressTasks,
      todoTasks: todoTasks,
      cancelledTasks: cancelledTasks,
      tasksByCategory: tasksByCategory,
      tasksByPriority: tasksByPriority,
    );
  }
}
