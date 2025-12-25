import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prvin/features/sync/data/models/calendar_event_model.dart';
import 'package:prvin/features/sync/domain/repositories/sync_repository.dart';
import 'package:prvin/features/sync/domain/usecases/sync_usecases.dart';
import 'package:prvin/features/task_management/domain/entities/task.dart'
    as task_entity;

/// 同步事件
abstract class SyncEvent extends Equatable {
  const SyncEvent();

  @override
  List<Object?> get props => [];
}

/// 连接外部日历事件
class ConnectExternalCalendarEvent extends SyncEvent {
  const ConnectExternalCalendarEvent(this.provider);

  final CalendarProvider provider;

  @override
  List<Object> get props => [provider];
}

/// 断开外部日历事件
class DisconnectExternalCalendarEvent extends SyncEvent {
  const DisconnectExternalCalendarEvent(this.provider);

  final CalendarProvider provider;

  @override
  List<Object> get props => [provider];
}

/// 检查日历连接状态事件
class CheckCalendarConnectionEvent extends SyncEvent {
  const CheckCalendarConnectionEvent(this.provider);

  final CalendarProvider provider;

  @override
  List<Object> get props => [provider];
}

/// 开始同步事件
class StartSyncEvent extends SyncEvent {
  const StartSyncEvent();
}

/// 解决冲突事件
class ResolveConflictEvent extends SyncEvent {
  const ResolveConflictEvent(this.conflictId, this.resolution);

  final String conflictId;
  final ConflictResolution resolution;

  @override
  List<Object> get props => [conflictId, resolution];
}

/// 获取同步统计信息事件
class GetSyncStatisticsEvent extends SyncEvent {
  const GetSyncStatisticsEvent();
}

/// 启用实时同步事件
class EnableRealTimeSyncEvent extends SyncEvent {
  const EnableRealTimeSyncEvent();
}

/// 禁用实时同步事件
class DisableRealTimeSyncEvent extends SyncEvent {
  const DisableRealTimeSyncEvent();
}

/// 同步任务到日历事件
class SyncTaskToCalendarEvent extends SyncEvent {
  const SyncTaskToCalendarEvent(this.task);

  final task_entity.Task task;

  @override
  List<Object> get props => [task];
}

/// 从日历删除任务事件
class RemoveTaskFromCalendarEvent extends SyncEvent {
  const RemoveTaskFromCalendarEvent(this.taskId);

  final String taskId;

  @override
  List<Object> get props => [taskId];
}

/// 拉取外部事件事件
class PullExternalEventsEvent extends SyncEvent {
  const PullExternalEventsEvent({this.startDate, this.endDate});

  final DateTime? startDate;
  final DateTime? endDate;

  @override
  List<Object?> get props => [startDate, endDate];
}

/// 同步状态
abstract class SyncState extends Equatable {
  const SyncState();

  @override
  List<Object?> get props => [];
}

/// 初始状态
class SyncInitial extends SyncState {
  const SyncInitial();
}

/// 加载中状态
class SyncLoading extends SyncState {
  const SyncLoading();
}

/// 连接成功状态
class CalendarConnected extends SyncState {
  const CalendarConnected(this.provider);

  final CalendarProvider provider;

  @override
  List<Object> get props => [provider];
}

/// 连接失败状态
class CalendarConnectionFailed extends SyncState {
  const CalendarConnectionFailed(this.message);

  final String message;

  @override
  List<Object> get props => [message];
}

/// 同步进行中状态
class SyncInProgress extends SyncState {
  const SyncInProgress();
}

/// 同步成功状态
class SyncSuccess extends SyncState {
  const SyncSuccess();
}

/// 同步失败状态
class SyncFailed extends SyncState {
  const SyncFailed(this.message);

  final String message;

  @override
  List<Object> get props => [message];
}

/// 同步冲突状态
class SyncConflicts extends SyncState {
  const SyncConflicts(this.conflicts);

  final List<SyncConflict> conflicts;

  @override
  List<Object> get props => [conflicts];
}

/// 同步统计信息状态
class SyncStatisticsLoaded extends SyncState {
  const SyncStatisticsLoaded(this.statistics);

  final SyncStatistics statistics;

  @override
  List<Object> get props => [statistics];
}

/// 任务同步成功状态
class TaskSyncedToCalendar extends SyncState {
  const TaskSyncedToCalendar(this.event);

  final CalendarEventModel event;

  @override
  List<Object> get props => [event];
}

/// 任务从日历删除成功状态
class TaskRemovedFromCalendar extends SyncState {
  const TaskRemovedFromCalendar(this.taskId);

  final String taskId;

  @override
  List<Object> get props => [taskId];
}

/// 外部事件拉取成功状态
class ExternalEventsLoaded extends SyncState {
  const ExternalEventsLoaded(this.events);

  final List<CalendarEventModel> events;

  @override
  List<Object> get props => [events];
}

/// 同步BLoC
class SyncBloc extends Bloc<SyncEvent, SyncState> {
  SyncBloc({
    required this.connectExternalCalendarUseCase,
    required this.disconnectExternalCalendarUseCase,
    required this.checkCalendarConnectionUseCase,
    required this.syncDataUseCase,
    required this.getSyncStatusUseCase,
    required this.getSyncConflictsUseCase,
    required this.resolveSyncConflictUseCase,
    required this.getSyncStatisticsUseCase,
    required this.enableRealTimeSyncUseCase,
    required this.disableRealTimeSyncUseCase,
    required this.syncTaskToCalendarUseCase,
    required this.removeTaskFromCalendarUseCase,
    required this.pullExternalEventsUseCase,
  }) : super(const SyncInitial()) {
    on<ConnectExternalCalendarEvent>(_onConnectExternalCalendar);
    on<DisconnectExternalCalendarEvent>(_onDisconnectExternalCalendar);
    on<CheckCalendarConnectionEvent>(_onCheckCalendarConnection);
    on<StartSyncEvent>(_onStartSync);
    on<ResolveConflictEvent>(_onResolveConflict);
    on<GetSyncStatisticsEvent>(_onGetSyncStatistics);
    on<EnableRealTimeSyncEvent>(_onEnableRealTimeSync);
    on<DisableRealTimeSyncEvent>(_onDisableRealTimeSync);
    on<SyncTaskToCalendarEvent>(_onSyncTaskToCalendar);
    on<RemoveTaskFromCalendarEvent>(_onRemoveTaskFromCalendar);
    on<PullExternalEventsEvent>(_onPullExternalEvents);

    // 监听同步状态和冲突
    _syncStatusSubscription = getSyncStatusUseCase().listen(
      _onSyncStatusChanged,
    );
    _syncConflictsSubscription = getSyncConflictsUseCase().listen(
      _onSyncConflictsChanged,
    );
  }

  final ConnectExternalCalendarUseCase connectExternalCalendarUseCase;
  final DisconnectExternalCalendarUseCase disconnectExternalCalendarUseCase;
  final CheckCalendarConnectionUseCase checkCalendarConnectionUseCase;
  final SyncDataUseCase syncDataUseCase;
  final GetSyncStatusUseCase getSyncStatusUseCase;
  final GetSyncConflictsUseCase getSyncConflictsUseCase;
  final ResolveSyncConflictUseCase resolveSyncConflictUseCase;
  final GetSyncStatisticsUseCase getSyncStatisticsUseCase;
  final EnableRealTimeSyncUseCase enableRealTimeSyncUseCase;
  final DisableRealTimeSyncUseCase disableRealTimeSyncUseCase;
  final SyncTaskToCalendarUseCase syncTaskToCalendarUseCase;
  final RemoveTaskFromCalendarUseCase removeTaskFromCalendarUseCase;
  final PullExternalEventsUseCase pullExternalEventsUseCase;

  StreamSubscription<SyncStatus>? _syncStatusSubscription;
  StreamSubscription<List<SyncConflict>>? _syncConflictsSubscription;

  /// 连接外部日历
  Future<void> _onConnectExternalCalendar(
    ConnectExternalCalendarEvent event,
    Emitter<SyncState> emit,
  ) async {
    emit(const SyncLoading());

    final result = await connectExternalCalendarUseCase(event.provider);

    result.fold(
      (failure) => emit(CalendarConnectionFailed(failure.message)),
      (success) => success
          ? emit(CalendarConnected(event.provider))
          : emit(const CalendarConnectionFailed('连接失败')),
    );
  }

  /// 断开外部日历
  Future<void> _onDisconnectExternalCalendar(
    DisconnectExternalCalendarEvent event,
    Emitter<SyncState> emit,
  ) async {
    emit(const SyncLoading());

    final result = await disconnectExternalCalendarUseCase(event.provider);

    result.fold(
      (failure) => emit(SyncFailed(failure.message)),
      (_) => emit(const SyncSuccess()),
    );
  }

  /// 检查日历连接状态
  Future<void> _onCheckCalendarConnection(
    CheckCalendarConnectionEvent event,
    Emitter<SyncState> emit,
  ) async {
    final result = await checkCalendarConnectionUseCase(event.provider);

    result.fold(
      (failure) => emit(CalendarConnectionFailed(failure.message)),
      (isConnected) => isConnected
          ? emit(CalendarConnected(event.provider))
          : emit(const SyncInitial()),
    );
  }

  /// 开始同步
  Future<void> _onStartSync(
    StartSyncEvent event,
    Emitter<SyncState> emit,
  ) async {
    emit(const SyncInProgress());

    final result = await syncDataUseCase();

    result.fold(
      (failure) => emit(SyncFailed(failure.message)),
      (_) => emit(const SyncSuccess()),
    );
  }

  /// 解决冲突
  Future<void> _onResolveConflict(
    ResolveConflictEvent event,
    Emitter<SyncState> emit,
  ) async {
    final result = await resolveSyncConflictUseCase(
      event.conflictId,
      event.resolution,
    );

    result.fold(
      (failure) => emit(SyncFailed(failure.message)),
      (_) => {}, // 状态会通过流更新
    );
  }

  /// 获取同步统计信息
  Future<void> _onGetSyncStatistics(
    GetSyncStatisticsEvent event,
    Emitter<SyncState> emit,
  ) async {
    final result = await getSyncStatisticsUseCase();

    result.fold(
      (failure) => emit(SyncFailed(failure.message)),
      (statistics) => emit(SyncStatisticsLoaded(statistics)),
    );
  }

  /// 启用实时同步
  Future<void> _onEnableRealTimeSync(
    EnableRealTimeSyncEvent event,
    Emitter<SyncState> emit,
  ) async {
    final result = await enableRealTimeSyncUseCase();

    result.fold(
      (failure) => emit(SyncFailed(failure.message)),
      (_) => emit(const SyncSuccess()),
    );
  }

  /// 禁用实时同步
  Future<void> _onDisableRealTimeSync(
    DisableRealTimeSyncEvent event,
    Emitter<SyncState> emit,
  ) async {
    final result = await disableRealTimeSyncUseCase();

    result.fold(
      (failure) => emit(SyncFailed(failure.message)),
      (_) => emit(const SyncSuccess()),
    );
  }

  /// 同步任务到日历
  Future<void> _onSyncTaskToCalendar(
    SyncTaskToCalendarEvent event,
    Emitter<SyncState> emit,
  ) async {
    emit(const SyncLoading());

    final result = await syncTaskToCalendarUseCase(event.task);

    result.fold(
      (failure) => emit(SyncFailed(failure.message)),
      (calendarEvent) => emit(TaskSyncedToCalendar(calendarEvent)),
    );
  }

  /// 从日历删除任务
  Future<void> _onRemoveTaskFromCalendar(
    RemoveTaskFromCalendarEvent event,
    Emitter<SyncState> emit,
  ) async {
    emit(const SyncLoading());

    final result = await removeTaskFromCalendarUseCase(event.taskId);

    result.fold(
      (failure) => emit(SyncFailed(failure.message)),
      (_) => emit(TaskRemovedFromCalendar(event.taskId)),
    );
  }

  /// 拉取外部事件
  Future<void> _onPullExternalEvents(
    PullExternalEventsEvent event,
    Emitter<SyncState> emit,
  ) async {
    emit(const SyncLoading());

    final result = await pullExternalEventsUseCase(
      startDate: event.startDate,
      endDate: event.endDate,
    );

    result.fold(
      (failure) => emit(SyncFailed(failure.message)),
      (events) => emit(ExternalEventsLoaded(events)),
    );
  }

  /// 同步状态变化处理
  void _onSyncStatusChanged(SyncStatus status) {
    switch (status) {
      case SyncStatus.idle:
        emit(const SyncInitial());
      case SyncStatus.syncing:
        emit(const SyncInProgress());
      case SyncStatus.success:
        emit(const SyncSuccess());
      case SyncStatus.failed:
        emit(const SyncFailed('同步失败'));
      case SyncStatus.conflict:
        // 冲突状态会通过冲突流处理
        break;
    }
  }

  /// 同步冲突变化处理
  void _onSyncConflictsChanged(List<SyncConflict> conflicts) {
    if (conflicts.isNotEmpty) {
      emit(SyncConflicts(conflicts));
    }
  }

  @override
  Future<void> close() {
    _syncStatusSubscription?.cancel();
    _syncConflictsSubscription?.cancel();
    return super.close();
  }
}
