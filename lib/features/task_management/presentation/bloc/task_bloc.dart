import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:prvin/features/task_management/domain/entities/task.dart';
import 'package:prvin/features/task_management/domain/repositories/task_repository.dart';
import 'package:prvin/features/task_management/domain/usecases/task_usecases.dart';
import 'package:prvin/features/task_management/data/repositories/task_repository_impl.dart';

part 'task_event.dart';
part 'task_state.dart';

/// 任务管理BLoC
class TaskBloc extends Bloc<TaskEvent, TaskState> {
  TaskBloc(this._taskUseCases) : super(const TaskState()) {
    on<TaskLoadRequested>(_onTaskLoadRequested);
    on<TaskCreateRequested>(_onTaskCreateRequested);
    on<TaskUpdateRequested>(_onTaskUpdateRequested);
    on<TaskDeleteRequested>(_onTaskDeleteRequested);
    on<TaskCompleteRequested>(_onTaskCompleteRequested);
    on<TaskSearchRequested>(_onTaskSearchRequested);
    on<TaskFilterChanged>(_onTaskFilterChanged);
    on<TaskDateChanged>(_onTaskDateChanged);

    // 立即加载初始数据
    add(const TaskLoadRequested());
  }

  final TaskUseCases _taskUseCases;
  StreamSubscription<List<Task>>? _taskSubscription;

  /// 获取仓库实例（用于特殊操作）
  TaskRepository get repository => _taskUseCases.repository;

  @override
  Future<void> close() {
    _taskSubscription?.cancel();
    return super.close();
  }

  /// 加载任务
  Future<void> _onTaskLoadRequested(
    TaskLoadRequested event,
    Emitter<TaskState> emit,
  ) async {
    try {
      // 只在初始状态时显示loading
      if (state.status == TaskBlocStatus.initial) {
        emit(state.copyWith(status: TaskBlocStatus.loading));
      }

      // 直接从repository获取任务
      final repository = _taskUseCases.repository as TaskRepositoryImpl;
      final tasks = repository.currentTasks;
      final filteredTasks = _applyFilters(tasks);

      emit(
        state.copyWith(status: TaskBlocStatus.success, tasks: filteredTasks),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: TaskBlocStatus.failure,
          errorMessage: '加载任务失败: $error',
        ),
      );
    }
  }

  /// 创建任务
  Future<void> _onTaskCreateRequested(
    TaskCreateRequested event,
    Emitter<TaskState> emit,
  ) async {
    emit(state.copyWith(status: TaskBlocStatus.loading));

    try {
      await _taskUseCases.createTask(event.request);

      // 直接从repository获取最新任务
      final repository = _taskUseCases.repository as TaskRepositoryImpl;
      final tasks = repository.currentTasks;
      final filteredTasks = _applyFilters(tasks);

      emit(
        state.copyWith(
          status: TaskBlocStatus.success,
          message: '任务创建成功',
          tasks: filteredTasks,
        ),
      );
    } catch (error) {
      var errorMessage = '创建任务失败';

      if (error is TaskConflictException) {
        errorMessage = '任务时间冲突，请调整时间';
        emit(
          state.copyWith(
            status: TaskBlocStatus.conflict,
            errorMessage: errorMessage,
            conflicts: error.conflicts,
          ),
        );
      } else if (error is TaskValidationException) {
        errorMessage = error.message;
        emit(
          state.copyWith(
            status: TaskBlocStatus.failure,
            errorMessage: errorMessage,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: TaskBlocStatus.failure,
            errorMessage: '$errorMessage: $error',
          ),
        );
      }
    }
  }

  /// 更新任务
  Future<void> _onTaskUpdateRequested(
    TaskUpdateRequested event,
    Emitter<TaskState> emit,
  ) async {
    emit(state.copyWith(status: TaskBlocStatus.loading));

    try {
      await _taskUseCases.updateTask(event.taskId, event.request);
      emit(state.copyWith(status: TaskBlocStatus.success, message: '任务更新成功'));
      add(const TaskLoadRequested());
    } catch (error) {
      var errorMessage = '更新任务失败';
      if (error is TaskConflictException) {
        errorMessage = '任务时间冲突，请调整时间';
        emit(
          state.copyWith(
            status: TaskBlocStatus.conflict,
            errorMessage: errorMessage,
            conflicts: error.conflicts,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: TaskBlocStatus.failure,
            errorMessage: errorMessage,
          ),
        );
      }
    }
  }

  /// 删除任务
  Future<void> _onTaskDeleteRequested(
    TaskDeleteRequested event,
    Emitter<TaskState> emit,
  ) async {
    emit(state.copyWith(status: TaskBlocStatus.loading));

    try {
      await _taskUseCases.deleteTask(event.taskId);
      emit(state.copyWith(status: TaskBlocStatus.success, message: '任务删除成功'));
      add(const TaskLoadRequested());
    } catch (error) {
      emit(
        state.copyWith(status: TaskBlocStatus.failure, errorMessage: '删除任务失败'),
      );
    }
  }

  /// 完成任务
  Future<void> _onTaskCompleteRequested(
    TaskCompleteRequested event,
    Emitter<TaskState> emit,
  ) async {
    try {
      await _taskUseCases.completeTask(event.taskId);
      emit(state.copyWith(message: '任务已完成'));
      add(const TaskLoadRequested());
    } catch (error) {
      emit(
        state.copyWith(status: TaskBlocStatus.failure, errorMessage: '完成任务失败'),
      );
    }
  }

  /// 搜索任务
  Future<void> _onTaskSearchRequested(
    TaskSearchRequested event,
    Emitter<TaskState> emit,
  ) async {
    emit(
      state.copyWith(searchQuery: event.query, status: TaskBlocStatus.loading),
    );

    try {
      List<Task> tasks;
      if (event.query.isEmpty) {
        tasks = await _taskUseCases.tasks.first;
      } else {
        tasks = await _taskUseCases.searchTasks(event.query);
      }

      tasks = _applyFilters(tasks);

      emit(state.copyWith(status: TaskBlocStatus.success, tasks: tasks));
    } catch (error) {
      emit(
        state.copyWith(status: TaskBlocStatus.failure, errorMessage: '搜索失败'),
      );
    }
  }

  /// 更改过滤器
  Future<void> _onTaskFilterChanged(
    TaskFilterChanged event,
    Emitter<TaskState> emit,
  ) async {
    emit(
      state.copyWith(
        filterCategory: event.category,
        filterStatus: event.status,
      ),
    );
    add(const TaskLoadRequested());
  }

  /// 更改选中日期
  Future<void> _onTaskDateChanged(
    TaskDateChanged event,
    Emitter<TaskState> emit,
  ) async {
    emit(state.copyWith(selectedDate: event.date));
    add(const TaskLoadRequested());
  }

  /// 应用过滤器
  List<Task> _applyFilters(List<Task> tasks) {
    var filteredTasks = tasks;

    // 按分类过滤
    if (state.filterCategory != null) {
      filteredTasks = filteredTasks
          .where((task) => task.category == state.filterCategory)
          .toList();
    }

    // 按状态过滤
    if (state.filterStatus != null) {
      filteredTasks = filteredTasks
          .where((task) => task.status == state.filterStatus)
          .toList();
    }

    // 按搜索查询过滤
    if (state.searchQuery.isNotEmpty) {
      filteredTasks = filteredTasks
          .where(
            (task) =>
                task.title.toLowerCase().contains(
                  state.searchQuery.toLowerCase(),
                ) ||
                (task.description?.toLowerCase().contains(
                      state.searchQuery.toLowerCase(),
                    ) ??
                    false),
          )
          .toList();
    }

    return filteredTasks;
  }
}
