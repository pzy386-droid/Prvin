import 'package:prvin/features/sync/data/models/calendar_event_model.dart';
import 'package:prvin/features/sync/domain/repositories/sync_repository.dart';
import 'package:prvin/features/task_management/domain/entities/task.dart'
    as task_entity;

/// 冲突检测结果
class ConflictDetectionResult {
  const ConflictDetectionResult({
    required this.hasConflicts,
    required this.taskConflicts,
    required this.eventConflicts,
  });

  final bool hasConflicts;
  final List<TaskConflict> taskConflicts;
  final List<EventConflict> eventConflicts;
}

/// 任务冲突
class TaskConflict {
  const TaskConflict({
    required this.localTask,
    required this.remoteTask,
    required this.conflictType,
    required this.conflictFields,
  });

  final task_entity.Task localTask;
  final task_entity.Task remoteTask;
  final ConflictType conflictType;
  final List<String> conflictFields;
}

/// 事件冲突
class EventConflict {
  const EventConflict({
    required this.localEvent,
    required this.remoteEvent,
    required this.conflictType,
    required this.conflictFields,
  });

  final CalendarEventModel localEvent;
  final CalendarEventModel remoteEvent;
  final ConflictType conflictType;
  final List<String> conflictFields;
}

/// 冲突解决策略
enum ConflictResolutionStrategy {
  /// 总是使用本地版本
  alwaysLocal,

  /// 总是使用远程版本
  alwaysRemote,

  /// 使用最新修改的版本
  useLatest,

  /// 智能合并
  smartMerge,

  /// 手动解决
  manual,
}

/// 冲突检测和解决服务
class ConflictResolutionService {
  ConflictResolutionService();

  /// 检测任务冲突
  ConflictDetectionResult detectConflicts(
    List<task_entity.Task> localTasks,
    List<task_entity.Task> remoteTasks,
    List<CalendarEventModel> localEvents,
    List<CalendarEventModel> remoteEvents,
  ) {
    final taskConflicts = _detectTaskConflicts(localTasks, remoteTasks);
    final eventConflicts = _detectEventConflicts(localEvents, remoteEvents);

    return ConflictDetectionResult(
      hasConflicts: taskConflicts.isNotEmpty || eventConflicts.isNotEmpty,
      taskConflicts: taskConflicts,
      eventConflicts: eventConflicts,
    );
  }

  /// 自动解决冲突
  Map<String, dynamic> autoResolveConflict(
    dynamic localItem,
    dynamic remoteItem,
    ConflictResolutionStrategy strategy,
  ) {
    switch (strategy) {
      case ConflictResolutionStrategy.alwaysLocal:
        return _itemToMap(localItem);
      case ConflictResolutionStrategy.alwaysRemote:
        return _itemToMap(remoteItem);
      case ConflictResolutionStrategy.useLatest:
        return _resolveByLatestUpdate(localItem, remoteItem);
      case ConflictResolutionStrategy.smartMerge:
        return _smartMerge(localItem, remoteItem);
      case ConflictResolutionStrategy.manual:
        // 返回冲突信息，需要手动解决
        return {
          'requiresManualResolution': true,
          'localItem': _itemToMap(localItem),
          'remoteItem': _itemToMap(remoteItem),
        };
    }
  }

  /// 检测任务冲突
  List<TaskConflict> _detectTaskConflicts(
    List<task_entity.Task> localTasks,
    List<task_entity.Task> remoteTasks,
  ) {
    final conflicts = <TaskConflict>[];

    for (final localTask in localTasks) {
      final remoteTask = remoteTasks.firstWhere(
        (t) => t.id == localTask.id,
        orElse: () => throw StateError('未找到对应的远程任务'),
      );

      final conflictFields = <String>[];
      var conflictType = ConflictType.contentConflict;

      // 检查时间冲突
      if (localTask.startTime != remoteTask.startTime ||
          localTask.endTime != remoteTask.endTime) {
        conflictFields.addAll(['startTime', 'endTime']);
        conflictType = ConflictType.timeConflict;
      }

      // 检查内容冲突
      if (localTask.title != remoteTask.title) {
        conflictFields.add('title');
      }
      if (localTask.description != remoteTask.description) {
        conflictFields.add('description');
      }
      if (localTask.priority != remoteTask.priority) {
        conflictFields.add('priority');
      }
      if (localTask.status != remoteTask.status) {
        conflictFields.add('status');
      }
      if (localTask.category != remoteTask.category) {
        conflictFields.add('category');
      }
      if (!_listsEqual(localTask.tags, remoteTask.tags)) {
        conflictFields.add('tags');
      }

      if (conflictFields.isNotEmpty) {
        conflicts.add(
          TaskConflict(
            localTask: localTask,
            remoteTask: remoteTask,
            conflictType: conflictType,
            conflictFields: conflictFields,
          ),
        );
      }
    }

    return conflicts;
  }

  /// 检测事件冲突
  List<EventConflict> _detectEventConflicts(
    List<CalendarEventModel> localEvents,
    List<CalendarEventModel> remoteEvents,
  ) {
    final conflicts = <EventConflict>[];

    for (final localEvent in localEvents) {
      final remoteEvent = remoteEvents.firstWhere(
        (e) => e.id == localEvent.id,
        orElse: () => throw StateError('未找到对应的远程事件'),
      );

      final conflictFields = <String>[];
      var conflictType = ConflictType.contentConflict;

      // 检查时间冲突
      if (localEvent.startTime != remoteEvent.startTime ||
          localEvent.endTime != remoteEvent.endTime) {
        conflictFields.addAll(['startTime', 'endTime']);
        conflictType = ConflictType.timeConflict;
      }

      // 检查内容冲突
      if (localEvent.title != remoteEvent.title) {
        conflictFields.add('title');
      }
      if (localEvent.description != remoteEvent.description) {
        conflictFields.add('description');
      }
      if (localEvent.location != remoteEvent.location) {
        conflictFields.add('location');
      }
      if (localEvent.isAllDay != remoteEvent.isAllDay) {
        conflictFields.add('isAllDay');
      }
      if (!_listsEqual(localEvent.attendees, remoteEvent.attendees)) {
        conflictFields.add('attendees');
      }
      if (!_listsEqual(localEvent.reminders, remoteEvent.reminders)) {
        conflictFields.add('reminders');
      }

      if (conflictFields.isNotEmpty) {
        conflicts.add(
          EventConflict(
            localEvent: localEvent,
            remoteEvent: remoteEvent,
            conflictType: conflictType,
            conflictFields: conflictFields,
          ),
        );
      }
    }

    return conflicts;
  }

  /// 根据最新更新时间解决冲突
  Map<String, dynamic> _resolveByLatestUpdate(
    dynamic localItem,
    dynamic remoteItem,
  ) {
    DateTime localUpdatedAt;
    DateTime remoteUpdatedAt;

    if (localItem is task_entity.Task) {
      localUpdatedAt = localItem.updatedAt;
      remoteUpdatedAt = (remoteItem as task_entity.Task).updatedAt;
    } else if (localItem is CalendarEventModel) {
      localUpdatedAt = localItem.updatedAt;
      remoteUpdatedAt = (remoteItem as CalendarEventModel).updatedAt;
    } else {
      return _itemToMap(localItem);
    }

    return localUpdatedAt.isAfter(remoteUpdatedAt)
        ? _itemToMap(localItem)
        : _itemToMap(remoteItem);
  }

  /// 智能合并
  Map<String, dynamic> _smartMerge(dynamic localItem, dynamic remoteItem) {
    if (localItem is task_entity.Task && remoteItem is task_entity.Task) {
      return _smartMergeTasks(localItem, remoteItem);
    } else if (localItem is CalendarEventModel &&
        remoteItem is CalendarEventModel) {
      return _smartMergeEvents(localItem, remoteItem);
    }

    // 默认使用最新版本
    return _resolveByLatestUpdate(localItem, remoteItem);
  }

  /// 智能合并任务
  Map<String, dynamic> _smartMergeTasks(
    task_entity.Task localTask,
    task_entity.Task remoteTask,
  ) {
    // 使用最新的更新时间作为基准
    final baseTask = localTask.updatedAt.isAfter(remoteTask.updatedAt)
        ? localTask
        : remoteTask;

    // 合并标签（取并集）
    final mergedTags = <String>{...localTask.tags, ...remoteTask.tags}.toList();

    // 如果状态不同，优先使用更高级的状态
    TaskStatus mergedStatus = baseTask.status;
    if (localTask.status != remoteTask.status) {
      final statusPriority = {
        TaskStatus.pending: 0,
        TaskStatus.inProgress: 1,
        TaskStatus.completed: 2,
        TaskStatus.cancelled: 1,
      };

      final localPriority = statusPriority[localTask.status] ?? 0;
      final remotePriority = statusPriority[remoteTask.status] ?? 0;

      mergedStatus = localPriority >= remotePriority
          ? localTask.status
          : remoteTask.status;
    }

    return baseTask
        .copyWith(
          tags: mergedTags,
          status: mergedStatus,
          updatedAt: DateTime.now(),
        )
        .toMap();
  }

  /// 智能合并事件
  Map<String, dynamic> _smartMergeEvents(
    CalendarEventModel localEvent,
    CalendarEventModel remoteEvent,
  ) {
    // 使用最新的更新时间作为基准
    final baseEvent = localEvent.updatedAt.isAfter(remoteEvent.updatedAt)
        ? localEvent
        : remoteEvent;

    // 合并参与者（取并集）
    final mergedAttendees = <String>{
      ...localEvent.attendees,
      ...remoteEvent.attendees,
    }.toList();

    // 合并提醒（取并集并排序）
    final mergedReminders = <int>{
      ...localEvent.reminders,
      ...remoteEvent.reminders,
    }.toList()..sort();

    return baseEvent
        .copyWith(
          attendees: mergedAttendees,
          reminders: mergedReminders,
          updatedAt: DateTime.now(),
        )
        .toJson();
  }

  /// 将项目转换为Map
  Map<String, dynamic> _itemToMap(dynamic item) {
    if (item is task_entity.Task) {
      return item.toMap();
    } else if (item is CalendarEventModel) {
      return item.toJson();
    }
    return {};
  }

  /// 比较两个列表是否相等
  bool _listsEqual<T>(List<T> list1, List<T> list2) {
    if (list1.length != list2.length) return false;
    for (var i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }
    return true;
  }
}
