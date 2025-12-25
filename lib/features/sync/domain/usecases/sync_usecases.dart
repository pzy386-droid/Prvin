import 'package:dartz/dartz.dart';
import 'package:prvin/core/error/failures.dart';
import 'package:prvin/features/sync/data/models/calendar_event_model.dart';
import 'package:prvin/features/sync/domain/repositories/sync_repository.dart';
import 'package:prvin/features/task_management/domain/entities/task.dart'
    as task_entity;

/// 连接外部日历用例
class ConnectExternalCalendarUseCase {
  ConnectExternalCalendarUseCase(this.repository);

  final SyncRepository repository;

  Future<Either<Failure, bool>> call(CalendarProvider provider) {
    return repository.connectExternalCalendar(provider);
  }
}

/// 断开外部日历用例
class DisconnectExternalCalendarUseCase {
  DisconnectExternalCalendarUseCase(this.repository);

  final SyncRepository repository;

  Future<Either<Failure, void>> call(CalendarProvider provider) {
    return repository.disconnectExternalCalendar(provider);
  }
}

/// 检查日历连接状态用例
class CheckCalendarConnectionUseCase {
  CheckCalendarConnectionUseCase(this.repository);

  final SyncRepository repository;

  Future<Either<Failure, bool>> call(CalendarProvider provider) {
    return repository.isCalendarConnected(provider);
  }
}

/// 同步数据用例
class SyncDataUseCase {
  SyncDataUseCase(this.repository);

  final SyncRepository repository;

  Future<Either<Failure, void>> call() {
    return repository.syncData();
  }
}

/// 获取同步状态用例
class GetSyncStatusUseCase {
  GetSyncStatusUseCase(this.repository);

  final SyncRepository repository;

  Stream<SyncStatus> call() {
    return repository.getSyncStatus();
  }
}

/// 获取同步冲突用例
class GetSyncConflictsUseCase {
  GetSyncConflictsUseCase(this.repository);

  final SyncRepository repository;

  Stream<List<SyncConflict>> call() {
    return repository.getSyncConflicts();
  }
}

/// 解决同步冲突用例
class ResolveSyncConflictUseCase {
  ResolveSyncConflictUseCase(this.repository);

  final SyncRepository repository;

  Future<Either<Failure, void>> call(
    String conflictId,
    ConflictResolution resolution,
  ) {
    return repository.resolveConflict(conflictId, resolution);
  }
}

/// 获取同步统计信息用例
class GetSyncStatisticsUseCase {
  GetSyncStatisticsUseCase(this.repository);

  final SyncRepository repository;

  Future<Either<Failure, SyncStatistics>> call() {
    return repository.getSyncStatistics();
  }
}

/// 启用实时同步用例
class EnableRealTimeSyncUseCase {
  EnableRealTimeSyncUseCase(this.repository);

  final SyncRepository repository;

  Future<Either<Failure, void>> call() {
    return repository.enableRealTimeSync();
  }
}

/// 禁用实时同步用例
class DisableRealTimeSyncUseCase {
  DisableRealTimeSyncUseCase(this.repository);

  final SyncRepository repository;

  Future<Either<Failure, void>> call() {
    return repository.disableRealTimeSync();
  }
}

/// 推送本地事件用例
class PushLocalEventUseCase {
  PushLocalEventUseCase(this.repository);

  final SyncRepository repository;

  Future<Either<Failure, void>> call(CalendarEventModel event) {
    return repository.pushLocalEvent(event);
  }
}

/// 拉取外部事件用例
class PullExternalEventsUseCase {
  PullExternalEventsUseCase(this.repository);

  final SyncRepository repository;

  Future<Either<Failure, List<CalendarEventModel>>> call({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return repository.pullExternalEvents(
      startDate: startDate,
      endDate: endDate,
    );
  }
}

/// 同步任务到日历用例
class SyncTaskToCalendarUseCase {
  SyncTaskToCalendarUseCase(this.repository);

  final SyncRepository repository;

  Future<Either<Failure, CalendarEventModel>> call(task_entity.Task task) {
    return repository.syncTaskToCalendar(task);
  }
}

/// 从日历删除任务用例
class RemoveTaskFromCalendarUseCase {
  RemoveTaskFromCalendarUseCase(this.repository);

  final SyncRepository repository;

  Future<Either<Failure, void>> call(String taskId) {
    return repository.removeTaskFromCalendar(taskId);
  }
}
