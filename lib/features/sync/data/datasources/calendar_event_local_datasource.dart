import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/error/failures.dart';
import '../models/calendar_event_model.dart';

/// 日历事件本地数据源接口
abstract class CalendarEventLocalDataSource {
  Future<List<CalendarEventModel>> getAllEvents();
  Future<List<CalendarEventModel>> getEventsForDate(DateTime date);
  Future<List<CalendarEventModel>> getEventsBySource(EventSource source);
  Future<List<CalendarEventModel>> getEventsNeedingSync();
  Future<CalendarEventModel?> getEventById(String id);
  Future<CalendarEventModel?> getEventByExternalId(
    String externalId,
    EventSource source,
  );
  Future<String> createEvent(CalendarEventModel event);
  Future<void> updateEvent(CalendarEventModel event);
  Future<void> deleteEvent(String id);
  Future<void> markEventSynced(String id);
  Future<void> clearAllEvents();
}

/// 日历事件本地数据源实现
class CalendarEventLocalDataSourceImpl implements CalendarEventLocalDataSource {
  final DatabaseHelper _databaseHelper;

  CalendarEventLocalDataSourceImpl(this._databaseHelper);

  @override
  Future<List<CalendarEventModel>> getAllEvents() async {
    try {
      final db = await _databaseHelper.database;
      final maps = await db.query('calendar_events', orderBy: 'start_time ASC');
      return maps.map((map) => _mapToEventModel(map)).toList();
    } catch (e) {
      throw DatabaseFailure('获取所有日历事件失败: $e');
    }
  }

  @override
  Future<List<CalendarEventModel>> getEventsForDate(DateTime date) async {
    try {
      final db = await _databaseHelper.database;
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final maps = await db.query(
        'calendar_events',
        where: 'start_time < ? AND end_time > ?',
        whereArgs: [
          endOfDay.millisecondsSinceEpoch,
          startOfDay.millisecondsSinceEpoch,
        ],
        orderBy: 'start_time ASC',
      );

      return maps.map((map) => _mapToEventModel(map)).toList();
    } catch (e) {
      throw DatabaseFailure('获取指定日期日历事件失败: $e');
    }
  }

  @override
  Future<List<CalendarEventModel>> getEventsBySource(EventSource source) async {
    try {
      final db = await _databaseHelper.database;
      final maps = await db.query(
        'calendar_events',
        where: 'source = ?',
        whereArgs: [source.name],
        orderBy: 'start_time ASC',
      );
      return maps.map((map) => _mapToEventModel(map)).toList();
    } catch (e) {
      throw DatabaseFailure('按来源获取日历事件失败: $e');
    }
  }

  @override
  Future<List<CalendarEventModel>> getEventsNeedingSync() async {
    try {
      final db = await _databaseHelper.database;
      final maps = await db.query(
        'calendar_events',
        where:
            'source != ? AND (last_sync_at IS NULL OR updated_at > last_sync_at)',
        whereArgs: [EventSource.local.name],
        orderBy: 'updated_at DESC',
      );
      return maps.map((map) => _mapToEventModel(map)).toList();
    } catch (e) {
      throw DatabaseFailure('获取需要同步的日历事件失败: $e');
    }
  }

  @override
  Future<CalendarEventModel?> getEventById(String id) async {
    try {
      final db = await _databaseHelper.database;
      final maps = await db.query(
        'calendar_events',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (maps.isEmpty) return null;
      return _mapToEventModel(maps.first);
    } catch (e) {
      throw DatabaseFailure('根据ID获取日历事件失败: $e');
    }
  }

  @override
  Future<CalendarEventModel?> getEventByExternalId(
    String externalId,
    EventSource source,
  ) async {
    try {
      final db = await _databaseHelper.database;
      final maps = await db.query(
        'calendar_events',
        where: 'external_id = ? AND source = ?',
        whereArgs: [externalId, source.name],
        limit: 1,
      );

      if (maps.isEmpty) return null;
      return _mapToEventModel(maps.first);
    } catch (e) {
      throw DatabaseFailure('根据外部ID获取日历事件失败: $e');
    }
  }

  @override
  Future<String> createEvent(CalendarEventModel event) async {
    try {
      final db = await _databaseHelper.database;
      await db.insert(
        'calendar_events',
        _eventModelToMap(event),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return event.id;
    } catch (e) {
      throw DatabaseFailure('创建日历事件失败: $e');
    }
  }

  @override
  Future<void> updateEvent(CalendarEventModel event) async {
    try {
      final db = await _databaseHelper.database;
      final updatedEvent = event.copyWith(updatedAt: DateTime.now());

      final count = await db.update(
        'calendar_events',
        _eventModelToMap(updatedEvent),
        where: 'id = ?',
        whereArgs: [event.id],
      );

      if (count == 0) {
        throw DatabaseFailure('日历事件不存在，无法更新');
      }
    } catch (e) {
      throw DatabaseFailure('更新日历事件失败: $e');
    }
  }

  @override
  Future<void> deleteEvent(String id) async {
    try {
      final db = await _databaseHelper.database;
      final count = await db.delete(
        'calendar_events',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (count == 0) {
        throw DatabaseFailure('日历事件不存在，无法删除');
      }
    } catch (e) {
      throw DatabaseFailure('删除日历事件失败: $e');
    }
  }

  @override
  Future<void> markEventSynced(String id) async {
    try {
      final db = await _databaseHelper.database;
      final count = await db.update(
        'calendar_events',
        {'last_sync_at': DateTime.now().millisecondsSinceEpoch},
        where: 'id = ?',
        whereArgs: [id],
      );

      if (count == 0) {
        throw DatabaseFailure('日历事件不存在，无法标记为已同步');
      }
    } catch (e) {
      throw DatabaseFailure('标记日历事件已同步失败: $e');
    }
  }

  @override
  Future<void> clearAllEvents() async {
    try {
      final db = await _databaseHelper.database;
      await db.delete('calendar_events');
    } catch (e) {
      throw DatabaseFailure('清空所有日历事件失败: $e');
    }
  }

  /// 将数据库映射转换为CalendarEventModel
  CalendarEventModel _mapToEventModel(Map<String, dynamic> map) {
    return CalendarEventModel(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      startTime: DateTime.fromMillisecondsSinceEpoch(map['start_time'] as int),
      endTime: DateTime.fromMillisecondsSinceEpoch(map['end_time'] as int),
      source: _parseEventSource(map['source'] as String),
      externalId: map['external_id'] as String?,
      isAllDay: (map['is_all_day'] as int) == 1,
      location: map['location'] as String?,
      attendees: List<String>.from(
        (jsonDecode(map['attendees'] as String) as List<dynamic>),
      ),
      reminders: List<int>.from(
        (jsonDecode(map['reminders'] as String) as List<dynamic>),
      ),
      recurrenceRule: map['recurrence_rule'] as String?,
      metadata: Map<String, dynamic>.from(
        jsonDecode(map['metadata'] as String) as Map<String, dynamic>,
      ),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
      lastSyncAt: map['last_sync_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['last_sync_at'] as int)
          : null,
    );
  }

  /// 将CalendarEventModel转换为数据库映射
  Map<String, dynamic> _eventModelToMap(CalendarEventModel event) {
    return {
      'id': event.id,
      'title': event.title,
      'description': event.description,
      'start_time': event.startTime.millisecondsSinceEpoch,
      'end_time': event.endTime.millisecondsSinceEpoch,
      'source': _eventSourceToString(event.source),
      'external_id': event.externalId,
      'is_all_day': event.isAllDay ? 1 : 0,
      'location': event.location,
      'attendees': jsonEncode(event.attendees),
      'reminders': jsonEncode(event.reminders),
      'recurrence_rule': event.recurrenceRule,
      'metadata': jsonEncode(event.metadata),
      'created_at': event.createdAt.millisecondsSinceEpoch,
      'updated_at': event.updatedAt.millisecondsSinceEpoch,
      'last_sync_at': event.lastSyncAt?.millisecondsSinceEpoch,
    };
  }

  /// 解析事件来源字符串
  EventSource _parseEventSource(String source) {
    switch (source) {
      case 'local':
        return EventSource.local;
      case 'googleCalendar':
        return EventSource.googleCalendar;
      case 'outlook':
        return EventSource.outlook;
      case 'apple':
        return EventSource.apple;
      default:
        return EventSource.local;
    }
  }

  /// 将事件来源转换为字符串
  String _eventSourceToString(EventSource source) {
    switch (source) {
      case EventSource.local:
        return 'local';
      case EventSource.googleCalendar:
        return 'googleCalendar';
      case EventSource.outlook:
        return 'outlook';
      case EventSource.apple:
        return 'apple';
    }
  }
}
