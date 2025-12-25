part of 'task_bloc.dart';

/// 任务事件基类
abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object?> get props => [];
}

/// 请求加载任务
class TaskLoadRequested extends TaskEvent {
  const TaskLoadRequested();
}

/// 请求创建任务
class TaskCreateRequested extends TaskEvent {
  const TaskCreateRequested(this.request);

  final TaskCreateRequest request;

  @override
  List<Object> get props => [request];
}

/// 请求更新任务
class TaskUpdateRequested extends TaskEvent {
  const TaskUpdateRequested(this.taskId, this.request);

  final String taskId;
  final TaskUpdateRequest request;

  @override
  List<Object> get props => [taskId, request];
}

/// 请求删除任务
class TaskDeleteRequested extends TaskEvent {
  const TaskDeleteRequested(this.taskId);

  final String taskId;

  @override
  List<Object> get props => [taskId];
}

/// 请求完成任务
class TaskCompleteRequested extends TaskEvent {
  const TaskCompleteRequested(this.taskId);

  final String taskId;

  @override
  List<Object> get props => [taskId];
}

/// 请求搜索任务
class TaskSearchRequested extends TaskEvent {
  const TaskSearchRequested(this.query);

  final String query;

  @override
  List<Object> get props => [query];
}

/// 任务过滤器更改
class TaskFilterChanged extends TaskEvent {
  const TaskFilterChanged({this.category, this.status});

  final TaskCategory? category;
  final TaskStatus? status;

  @override
  List<Object?> get props => [category, status];
}

/// 选中日期更改
class TaskDateChanged extends TaskEvent {
  const TaskDateChanged(this.date);

  final DateTime? date;

  @override
  List<Object?> get props => [date];
}

/// 请求AI任务建议
class TaskAISuggestionsRequested extends TaskEvent {
  const TaskAISuggestionsRequested(this.taskTitle);

  final String taskTitle;

  @override
  List<Object> get props => [taskTitle];
}

/// 请求AI任务优化建议
class TaskOptimizationSuggestionsRequested extends TaskEvent {
  const TaskOptimizationSuggestionsRequested();
}

/// 清除AI建议
class TaskAISuggestionsCleared extends TaskEvent {
  const TaskAISuggestionsCleared();
}
