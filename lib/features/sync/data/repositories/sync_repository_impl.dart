import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:prvin/core/error/failures.dart';
import 'package:prvin/features/sync/data/datasources/calendar_event_local_datasource.dart';
import 'package:prvin/features/sync/data/datasources/firebase_cloud_datasource.dart';
import 'package:prvin/features/sync/data/datasources/google_calendar_remote_datasource.dart';
import 'package:prvin/features/sync/data/models/calendar_event_model.dart';
import 'package:prvin/features/sync/domain/repositories/sync_repository.dart';
import 'package:prvin/features/sync/domain/services/conflict_resolution_service.dart';
import 'package:prvin/features/task_management/domain/entities/task.dart'
    as task_entity;
import 'package:uuid/uuid.dart';

/// 同步仓库实现
class SyncRepositoryImpl implements SyncRepository {
  SyncRepositoryImpl({
    required this.localDataSource,
    required this.googleCalendarDataSource,
    required this.firebaseCloudDataSource,
    required this.conflictResolutionService,
  });

  final CalendarEventLocalDataSource localDataSource;
  final GoogleCalendarRemoteDataSource googleCalendarDataSource;
  final FirebaseCloudDataSource firebaseCloudDataSource;
  final ConflictResolutionService conflictResolutionService;

  // 同步状态流控制器
  final _syncStatusController = StreamController<SyncStatus>.broadcast();
  final _syncConflictsController =
      StreamController<List<SyncConflict>>.broadcast();

  // 当前同步状态
  SyncStatus _currentStatus = SyncStatus.idle;
  final List<SyncConflict> _currentConflicts = [];

  // UUID生成器
  final _uuid = const Uuid();

  @override
  Future<Either<Failure, bool>> connectExternalCalendar(
    CalendarProvider provider,
  ) async {
    try {
      switch (provider) {
        case CalendarProvider.google:
          final success = await googleCalendarDataSource.authenticate();
          return Right(success);
        case CalendarProvider.outlook:
          // TODO: 实现Outlook集成
          return const Left(NetworkFailure('Outlook集成尚未实现'));
        case CalendarProvider.apple:
          // TODO: 实现Apple Calendar集成
          return const Left(NetworkFailure('Apple Calendar集成尚未实现'));
      }
    } catch (e) {
      return Left(NetworkFailure('连接外部日历失败: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> disconnectExternalCalendar(
    CalendarProvider provider,
  ) async {
    try {
      switch (provider) {
        case CalendarProvider.google:
          await googleCalendarDataSource.signOut();
        case CalendarProvider.outlook:
          // TODO: 实现Outlook断开连接
          break;
        case CalendarProvider.apple:
          // TODO: 实现Apple Calendar断开连接
          break;
      }
      return const Right(null);
    } catch (e) {
      return Left(NetworkFailure('断开外部日历连接失败: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> isCalendarConnected(
    CalendarProvider provider,
  ) async {
    try {
      switch (provider) {
        case CalendarProvider.google:
          final isConnected = await googleCalendarDataSource.isAuthenticated();
          return Right(isConnected);
        case CalendarProvider.outlook:
          // TODO: 检查Outlook连接状态
          return const Right(false);
        case CalendarProvider.apple:
          // TODO: 检查Apple Calendar连接状态
          return const Right(false);
      }
    } catch (e) {
      return Left(NetworkFailure('检查日历连接状态失败: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> syncData() async {
    try {
      _updateSyncStatus(SyncStatus.syncing);

      // 1. 确保Firebase认证
      final isAuthenticated = await firebaseCloudDataSource.isAuthenticated();
      if (!isAuthenticated) {
        await firebaseCloudDataSource.signInAnonymously();
      }

      // 2. 获取本地数据
      final localEvents = await localDataSource.getAllEvents();

      // 3. 获取云端数据
      final cloudEvents = await firebaseCloudDataSource.getEventsFromCloud();

      // 4. 获取Google Calendar数据（如果已连接）
      var remoteEvents = <CalendarEventModel>[];
      final isGoogleConnected = await googleCalendarDataSource
          .isAuthenticated();
      if (isGoogleConnected) {
        remoteEvents = await googleCalendarDataSource.getEvents(
          timeMin: DateTime.now().subtract(const Duration(days: 30)),
          timeMax: DateTime.now().add(const Duration(days: 90)),
        );
      }

      // 5. 检测冲突
      final conflicts = _detectConflicts(localEvents, [
        ...cloudEvents,
        ...remoteEvents,
      ]);

      if (conflicts.isNotEmpty) {
        _currentConflicts.clear();
        _currentConflicts.addAll(conflicts);
        _syncConflictsController.add(List.from(_currentConflicts));
        _updateSyncStatus(SyncStatus.conflict);
        return const Right(null);
      }

      // 6. 三向同步：本地 ↔ 云端 ↔ Google Calendar
      await _performThreeWaySync(localEvents, cloudEvents, remoteEvents);

      _updateSyncStatus(SyncStatus.success);
      return const Right(null);
    } catch (e) {
      _updateSyncStatus(SyncStatus.failed);
      return Left(NetworkFailure('数据同步失败: $e'));
    }
  }

  @override
  Stream<SyncStatus> getSyncStatus() {
    return _syncStatusController.stream;
  }

  @override
  Stream<List<SyncConflict>> getSyncConflicts() {
    return _syncConflictsController.stream;
  }

  @override
  Future<Either<Failure, void>> resolveConflict(
    String conflictId,
    ConflictResolution resolution,
  ) async {
    try {
      final conflict = _currentConflicts.firstWhere(
        (c) => c.id == conflictId,
        orElse: () => throw Exception('冲突不存在'),
      );

      switch (resolution) {
        case ConflictResolution.useLocal:
          if (conflict.localEvent != null) {
            await _pushEventToRemote(conflict.localEvent!);
          }
        case ConflictResolution.useRemote:
          if (conflict.remoteEvent != null) {
            await _pullEventToLocal(conflict.remoteEvent!);
          }
        case ConflictResolution.merge:
          // TODO: 实现智能合并逻辑
          break;
        case ConflictResolution.skip:
          // 跳过，不做任何操作
          break;
      }

      // 移除已解决的冲突
      _currentConflicts.removeWhere((c) => c.id == conflictId);
      _syncConflictsController.add(List.from(_currentConflicts));

      // 如果所有冲突都已解决，更新状态
      if (_currentConflicts.isEmpty) {
        _updateSyncStatus(SyncStatus.success);
      }

      return const Right(null);
    } catch (e) {
      return Left(NetworkFailure('解决同步冲突失败: $e'));
    }
  }

  @override
  Future<Either<Failure, SyncStatistics>> getSyncStatistics() async {
    try {
      final localEvents = await localDataSource.getAllEvents();
      final syncedEvents = localEvents
          .where((e) => e.lastSyncAt != null)
          .length;
      final failedEvents = localEvents.where((e) => e.needsSync).length;

      final lastSyncTime = localEvents
          .where((e) => e.lastSyncAt != null)
          .map((e) => e.lastSyncAt!)
          .fold<DateTime?>(
            null,
            (prev, curr) => prev == null || curr.isAfter(prev) ? curr : prev,
          );

      final statistics = SyncStatistics(
        totalEvents: localEvents.length,
        syncedEvents: syncedEvents,
        failedEvents: failedEvents,
        conflictEvents: _currentConflicts.length,
        lastSyncTime: lastSyncTime,
      );

      return Right(statistics);
    } catch (e) {
      return Left(DatabaseFailure('获取同步统计信息失败: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> enableRealTimeSync() async {
    // TODO: 实现实时同步功能
    return const Left(NetworkFailure('实时同步功能尚未实现'));
  }

  @override
  Future<Either<Failure, void>> disableRealTimeSync() async {
    // TODO: 实现禁用实时同步功能
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> pushLocalEvent(CalendarEventModel event) async {
    try {
      await _pushEventToRemote(event);
      return const Right(null);
    } catch (e) {
      return Left(NetworkFailure('推送本地事件失败: $e'));
    }
  }

  @override
  Future<Either<Failure, List<CalendarEventModel>>> pullExternalEvents({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final events = await googleCalendarDataSource.getEvents(
        timeMin: startDate,
        timeMax: endDate,
      );
      return Right(events);
    } catch (e) {
      return Left(NetworkFailure('拉取外部日历事件失败: $e'));
    }
  }

  @override
  Future<Either<Failure, CalendarEventModel>> syncTaskToCalendar(
    task_entity.Task task,
  ) async {
    try {
      // 将任务转换为日历事件
      final event = _convertTaskToCalendarEvent(task);

      // 推送到Google Calendar
      final remoteEvent = await googleCalendarDataSource.createEvent(event);

      // 保存到本地数据库
      await localDataSource.createEvent(remoteEvent);

      return Right(remoteEvent);
    } catch (e) {
      return Left(NetworkFailure('同步任务到日历失败: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> removeTaskFromCalendar(String taskId) async {
    try {
      // 查找对应的日历事件
      final localEvents = await localDataSource.getAllEvents();
      final taskEvent = localEvents.firstWhere(
        (e) => e.metadata['taskId'] == taskId,
        orElse: () => throw Exception('未找到对应的日历事件'),
      );

      // 从Google Calendar删除
      if (taskEvent.externalId != null) {
        await googleCalendarDataSource.deleteEvent(taskEvent.externalId!);
      }

      // 从本地数据库删除
      await localDataSource.deleteEvent(taskEvent.id);

      return const Right(null);
    } catch (e) {
      return Left(NetworkFailure('从日历删除任务失败: $e'));
    }
  }

  /// 更新同步状态
  void _updateSyncStatus(SyncStatus status) {
    _currentStatus = status;
    _syncStatusController.add(status);
  }

  /// 检测同步冲突
  List<SyncConflict> _detectConflicts(
    List<CalendarEventModel> localEvents,
    List<CalendarEventModel> remoteEvents,
  ) {
    final conflicts = <SyncConflict>[];

    for (final localEvent in localEvents) {
      if (localEvent.externalId == null) continue;

      final remoteEvent = remoteEvents.firstWhere(
        (e) => e.externalId == localEvent.externalId,
        orElse: () => throw StateError('未找到对应的远程事件'),
      );

      // 检查时间冲突
      if (localEvent.startTime != remoteEvent.startTime ||
          localEvent.endTime != remoteEvent.endTime) {
        conflicts.add(
          SyncConflict(
            id: _uuid.v4(),
            localEvent: localEvent,
            remoteEvent: remoteEvent,
            type: ConflictType.timeConflict,
            detectedAt: DateTime.now(),
          ),
        );
      }

      // 检查内容冲突
      if (localEvent.title != remoteEvent.title ||
          localEvent.description != remoteEvent.description) {
        conflicts.add(
          SyncConflict(
            id: _uuid.v4(),
            localEvent: localEvent,
            remoteEvent: remoteEvent,
            type: ConflictType.contentConflict,
            detectedAt: DateTime.now(),
          ),
        );
      }
    }

    return conflicts;
  }

  /// 同步本地事件到远程
  Future<void> _syncLocalToRemote(
    List<CalendarEventModel> localEvents,
    List<CalendarEventModel> remoteEvents,
  ) async {
    for (final localEvent in localEvents) {
      if (localEvent.source != EventSource.local) continue;
      if (!localEvent.needsSync) continue;

      try {
        await _pushEventToRemote(localEvent);
      } catch (e) {
        // 记录错误但继续同步其他事件
        print('同步本地事件失败: ${localEvent.id}, 错误: $e');
      }
    }
  }

  /// 同步远程事件到本地
  Future<void> _syncRemoteToLocal(
    List<CalendarEventModel> remoteEvents,
    List<CalendarEventModel> localEvents,
  ) async {
    for (final remoteEvent in remoteEvents) {
      try {
        await _pullEventToLocal(remoteEvent);
      } catch (e) {
        // 记录错误但继续同步其他事件
        print('同步远程事件失败: ${remoteEvent.id}, 错误: $e');
      }
    }
  }

  /// 推送事件到远程
  Future<void> _pushEventToRemote(CalendarEventModel event) async {
    if (event.externalId == null) {
      // 创建新事件
      final remoteEvent = await googleCalendarDataSource.createEvent(event);
      final updatedEvent = event.copyWith(
        externalId: remoteEvent.externalId,
        lastSyncAt: DateTime.now(),
      );
      await localDataSource.updateEvent(updatedEvent);
    } else {
      // 更新现有事件
      await googleCalendarDataSource.updateEvent(event);
      await localDataSource.markEventSynced(event.id);
    }
  }

  /// 拉取事件到本地
  Future<void> _pullEventToLocal(CalendarEventModel remoteEvent) async {
    final existingEvent = await localDataSource.getEventByExternalId(
      remoteEvent.externalId!,
      remoteEvent.source,
    );

    if (existingEvent == null) {
      // 创建新的本地事件
      await localDataSource.createEvent(remoteEvent);
    } else {
      // 更新现有本地事件
      final updatedEvent = remoteEvent.copyWith(
        id: existingEvent.id,
        lastSyncAt: DateTime.now(),
      );
      await localDataSource.updateEvent(updatedEvent);
    }
  }

  /// 将任务转换为日历事件
  CalendarEventModel _convertTaskToCalendarEvent(task_entity.Task task) {
    return CalendarEventModel(
      id: _uuid.v4(),
      title: task.title,
      description: task.description,
      startTime: task.startTime,
      endTime: task.endTime,
      source: EventSource.local,
      isAllDay: false,
      attendees: const [],
      reminders: const [10], // 默认10分钟提醒
      metadata: {
        'taskId': task.id,
        'taskCategory': task.category.name,
        'taskPriority': task.priority.name,
        'taskStatus': task.status.name,
        'tags': task.tags.join(','),
      },
      createdAt: task.createdAt,
      updatedAt: task.updatedAt,
    );
  }

  /// 三向同步：本地 ↔ 云端 ↔ Google Calendar
  Future<void> _performThreeWaySync(
    List<CalendarEventModel> localEvents,
    List<CalendarEventModel> cloudEvents,
    List<CalendarEventModel> remoteEvents,
  ) async {
    // 1. 同步本地到云端
    await _syncLocalToCloud(localEvents, cloudEvents);

    // 2. 同步云端到本地
    await _syncCloudToLocal(cloudEvents, localEvents);

    // 3. 如果Google Calendar已连接，进行双向同步
    if (remoteEvents.isNotEmpty) {
      await _syncLocalToRemote(localEvents, remoteEvents);
      await _syncRemoteToLocal(remoteEvents, localEvents);

      // 同步Google Calendar事件到云端
      await _syncRemoteToCloud(remoteEvents);
    }
  }

  /// 同步本地到云端
  Future<void> _syncLocalToCloud(
    List<CalendarEventModel> localEvents,
    List<CalendarEventModel> cloudEvents,
  ) async {
    final eventsToSync = localEvents.where((local) {
      final cloudEvent = cloudEvents.firstWhere(
        (cloud) => cloud.id == local.id,
        orElse: () => throw StateError('未找到对应的云端事件'),
      );
      return local.updatedAt.isAfter(cloudEvent.updatedAt);
    }).toList();

    if (eventsToSync.isNotEmpty) {
      await firebaseCloudDataSource.syncEventsToCloud(eventsToSync);
    }
  }

  /// 同步云端到本地
  Future<void> _syncCloudToLocal(
    List<CalendarEventModel> cloudEvents,
    List<CalendarEventModel> localEvents,
  ) async {
    for (final cloudEvent in cloudEvents) {
      final localEvent = localEvents.firstWhere(
        (local) => local.id == cloudEvent.id,
        orElse: () => throw StateError('未找到对应的本地事件'),
      );

      if (cloudEvent.updatedAt.isAfter(localEvent.updatedAt)) {
        await localDataSource.updateEvent(cloudEvent);
      }
    }
  }

  /// 同步Google Calendar事件到云端
  Future<void> _syncRemoteToCloud(List<CalendarEventModel> remoteEvents) async {
    final cloudEvents = remoteEvents
        .map(
          (event) => event.copyWith(
            source: EventSource.googleCalendar,
            lastSyncAt: DateTime.now(),
          ),
        )
        .toList();

    await firebaseCloudDataSource.syncEventsToCloud(cloudEvents);
  }

  /// 释放资源
  void dispose() {
    _syncStatusController.close();
    _syncConflictsController.close();
  }
}
