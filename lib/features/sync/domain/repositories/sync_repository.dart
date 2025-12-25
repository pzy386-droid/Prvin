import 'package:dartz/dartz.dart';
import 'package:prvin/core/error/failures.dart';
import 'package:prvin/features/sync/data/models/calendar_event_model.dart';
import 'package:prvin/features/task_management/domain/entities/task.dart'
    as task_entity;

/// 同步冲突类型
enum ConflictType {
  /// 时间冲突
  timeConflict,

  /// 内容冲突
  contentConflict,

  /// 删除冲突
  deleteConflict,
}

/// 同步冲突解决方案
enum ConflictResolution {
  /// 使用本地版本
  useLocal,

  /// 使用远程版本
  useRemote,

  /// 合并版本
  merge,

  /// 跳过此次同步
  skip,
}

/// 同步冲突数据
class SyncConflict {
  const SyncConflict({
    required this.id,
    required this.localEvent,
    required this.remoteEvent,
    required this.type,
    required this.detectedAt,
  });

  final String id;
  final CalendarEventModel? localEvent;
  final CalendarEventModel? remoteEvent;
  final ConflictType type;
  final DateTime detectedAt;
}

/// 同步状态
enum SyncStatus {
  /// 空闲
  idle,

  /// 同步中
  syncing,

  /// 同步成功
  success,

  /// 同步失败
  failed,

  /// 有冲突
  conflict,
}

/// 同步统计信息
class SyncStatistics {
  const SyncStatistics({
    required this.totalEvents,
    required this.syncedEvents,
    required this.failedEvents,
    required this.conflictEvents,
    required this.lastSyncTime,
  });

  final int totalEvents;
  final int syncedEvents;
  final int failedEvents;
  final int conflictEvents;
  final DateTime? lastSyncTime;
}

/// 日历提供商
enum CalendarProvider {
  /// Google Calendar
  google,

  /// Microsoft Outlook
  outlook,

  /// Apple Calendar
  apple,
}

/// 同步仓库接口
abstract class SyncRepository {
  /// 连接外部日历服务
  Future<Either<Failure, bool>> connectExternalCalendar(
    CalendarProvider provider,
  );

  /// 断开外部日历服务
  Future<Either<Failure, void>> disconnectExternalCalendar(
    CalendarProvider provider,
  );

  /// 检查外部日历连接状态
  Future<Either<Failure, bool>> isCalendarConnected(CalendarProvider provider);

  /// 同步数据
  Future<Either<Failure, void>> syncData();

  /// 获取同步状态
  Stream<SyncStatus> getSyncStatus();

  /// 获取同步冲突
  Stream<List<SyncConflict>> getSyncConflicts();

  /// 解决同步冲突
  Future<Either<Failure, void>> resolveConflict(
    String conflictId,
    ConflictResolution resolution,
  );

  /// 获取同步统计信息
  Future<Either<Failure, SyncStatistics>> getSyncStatistics();

  /// 启用实时同步
  Future<Either<Failure, void>> enableRealTimeSync();

  /// 禁用实时同步
  Future<Either<Failure, void>> disableRealTimeSync();

  /// 手动推送本地事件到外部日历
  Future<Either<Failure, void>> pushLocalEvent(CalendarEventModel event);

  /// 手动拉取外部日历事件
  Future<Either<Failure, List<CalendarEventModel>>> pullExternalEvents({
    DateTime? startDate,
    DateTime? endDate,
  });

  /// 将任务同步到外部日历
  Future<Either<Failure, CalendarEventModel>> syncTaskToCalendar(
    task_entity.Task task,
  );

  /// 从外部日历删除任务对应的事件
  Future<Either<Failure, void>> removeTaskFromCalendar(String taskId);
}
