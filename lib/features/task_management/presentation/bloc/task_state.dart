part of 'task_bloc.dart';

/// 任务BLoC状态枚举
enum TaskBlocStatus { initial, loading, success, failure, conflict }

/// 任务状态类
class TaskState extends Equatable {
  const TaskState({
    this.status = TaskBlocStatus.initial,
    this.tasks = const [],
    this.selectedDate,
    this.searchQuery = '',
    this.filterCategory,
    this.filterStatus,
    this.conflicts = const [],
    this.errorMessage,
    this.message,
  });

  final TaskBlocStatus status;
  final List<Task> tasks;
  final DateTime? selectedDate;
  final String searchQuery;
  final TaskCategory? filterCategory;
  final TaskStatus? filterStatus;
  final List<ConflictWarning> conflicts;
  final String? errorMessage;
  final String? message;

  /// 是否正在加载
  bool get isLoading => status == TaskBlocStatus.loading;

  /// 是否有错误
  bool get hasError => status == TaskBlocStatus.failure;

  /// 是否有冲突
  bool get hasConflict => status == TaskBlocStatus.conflict;

  /// 是否成功
  bool get isSuccess => status == TaskBlocStatus.success;

  /// 获取今天的任务
  List<Task> get todayTasks {
    final today = DateTime.now();
    return tasks.where((task) {
      return task.startTime.year == today.year &&
          task.startTime.month == today.month &&
          task.startTime.day == today.day;
    }).toList();
  }

  /// 获取过期任务
  List<Task> get overdueTasks {
    return tasks.where((task) => task.isOverdue).toList();
  }

  /// 获取已完成任务
  List<Task> get completedTasks {
    return tasks.where((task) => task.status == TaskStatus.completed).toList();
  }

  /// 获取待办任务
  List<Task> get pendingTasks {
    return tasks.where((task) => task.status == TaskStatus.pending).toList();
  }

  /// 复制状态并修改部分属性
  TaskState copyWith({
    TaskBlocStatus? status,
    List<Task>? tasks,
    DateTime? selectedDate,
    String? searchQuery,
    TaskCategory? filterCategory,
    TaskStatus? filterStatus,
    List<ConflictWarning>? conflicts,
    String? errorMessage,
    String? message,
  }) {
    return TaskState(
      status: status ?? this.status,
      tasks: tasks ?? this.tasks,
      selectedDate: selectedDate ?? this.selectedDate,
      searchQuery: searchQuery ?? this.searchQuery,
      filterCategory: filterCategory ?? this.filterCategory,
      filterStatus: filterStatus ?? this.filterStatus,
      conflicts: conflicts ?? this.conflicts,
      errorMessage: errorMessage,
      message: message,
    );
  }

  @override
  List<Object?> get props => [
    status,
    tasks,
    selectedDate,
    searchQuery,
    filterCategory,
    filterStatus,
    conflicts,
    errorMessage,
    message,
  ];
}
