import 'package:sqflite/sqflite.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/error/failures.dart';
import '../models/pomodoro_session_model.dart';

/// 番茄钟本地数据源接口
abstract class PomodoroLocalDataSource {
  Future<List<PomodoroSessionModel>> getAllSessions();
  Future<List<PomodoroSessionModel>> getSessionsForDate(DateTime date);
  Future<List<PomodoroSessionModel>> getSessionsByType(SessionType type);
  Future<List<PomodoroSessionModel>> getSessionsForTask(String taskId);
  Future<PomodoroSessionModel?> getSessionById(String id);
  Future<PomodoroSessionModel?> getActiveSession();
  Future<String> createSession(PomodoroSessionModel session);
  Future<void> updateSession(PomodoroSessionModel session);
  Future<void> deleteSession(String id);
  Future<void> clearAllSessions();
}

/// 番茄钟本地数据源实现
class PomodoroLocalDataSourceImpl implements PomodoroLocalDataSource {
  final DatabaseHelper _databaseHelper;

  PomodoroLocalDataSourceImpl(this._databaseHelper);

  @override
  Future<List<PomodoroSessionModel>> getAllSessions() async {
    try {
      final db = await _databaseHelper.database;
      final maps = await db.query(
        'pomodoro_sessions',
        orderBy: 'start_time DESC',
      );
      return maps.map((map) => _mapToSessionModel(map)).toList();
    } catch (e) {
      throw DatabaseFailure('获取所有番茄钟会话失败: $e');
    }
  }

  @override
  Future<List<PomodoroSessionModel>> getSessionsForDate(DateTime date) async {
    try {
      final db = await _databaseHelper.database;
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final maps = await db.query(
        'pomodoro_sessions',
        where: 'start_time >= ? AND start_time < ?',
        whereArgs: [
          startOfDay.millisecondsSinceEpoch,
          endOfDay.millisecondsSinceEpoch,
        ],
        orderBy: 'start_time ASC',
      );

      return maps.map((map) => _mapToSessionModel(map)).toList();
    } catch (e) {
      throw DatabaseFailure('获取指定日期番茄钟会话失败: $e');
    }
  }

  @override
  Future<List<PomodoroSessionModel>> getSessionsByType(SessionType type) async {
    try {
      final db = await _databaseHelper.database;
      final maps = await db.query(
        'pomodoro_sessions',
        where: 'type = ?',
        whereArgs: [type.name],
        orderBy: 'start_time DESC',
      );
      return maps.map((map) => _mapToSessionModel(map)).toList();
    } catch (e) {
      throw DatabaseFailure('按类型获取番茄钟会话失败: $e');
    }
  }

  @override
  Future<List<PomodoroSessionModel>> getSessionsForTask(String taskId) async {
    try {
      final db = await _databaseHelper.database;
      final maps = await db.query(
        'pomodoro_sessions',
        where: 'associated_task_id = ?',
        whereArgs: [taskId],
        orderBy: 'start_time DESC',
      );
      return maps.map((map) => _mapToSessionModel(map)).toList();
    } catch (e) {
      throw DatabaseFailure('获取任务关联的番茄钟会话失败: $e');
    }
  }

  @override
  Future<PomodoroSessionModel?> getSessionById(String id) async {
    try {
      final db = await _databaseHelper.database;
      final maps = await db.query(
        'pomodoro_sessions',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (maps.isEmpty) return null;
      return _mapToSessionModel(maps.first);
    } catch (e) {
      throw DatabaseFailure('根据ID获取番茄钟会话失败: $e');
    }
  }

  @override
  Future<PomodoroSessionModel?> getActiveSession() async {
    try {
      final db = await _databaseHelper.database;
      final maps = await db.query(
        'pomodoro_sessions',
        where: 'completed = ? AND end_time IS NULL',
        whereArgs: [0], // 0 = false
        orderBy: 'start_time DESC',
        limit: 1,
      );

      if (maps.isEmpty) return null;
      return _mapToSessionModel(maps.first);
    } catch (e) {
      throw DatabaseFailure('获取活动番茄钟会话失败: $e');
    }
  }

  @override
  Future<String> createSession(PomodoroSessionModel session) async {
    try {
      final db = await _databaseHelper.database;
      await db.insert(
        'pomodoro_sessions',
        _sessionModelToMap(session),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return session.id;
    } catch (e) {
      throw DatabaseFailure('创建番茄钟会话失败: $e');
    }
  }

  @override
  Future<void> updateSession(PomodoroSessionModel session) async {
    try {
      final db = await _databaseHelper.database;
      final count = await db.update(
        'pomodoro_sessions',
        _sessionModelToMap(session),
        where: 'id = ?',
        whereArgs: [session.id],
      );

      if (count == 0) {
        throw DatabaseFailure('番茄钟会话不存在，无法更新');
      }
    } catch (e) {
      throw DatabaseFailure('更新番茄钟会话失败: $e');
    }
  }

  @override
  Future<void> deleteSession(String id) async {
    try {
      final db = await _databaseHelper.database;
      final count = await db.delete(
        'pomodoro_sessions',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (count == 0) {
        throw DatabaseFailure('番茄钟会话不存在，无法删除');
      }
    } catch (e) {
      throw DatabaseFailure('删除番茄钟会话失败: $e');
    }
  }

  @override
  Future<void> clearAllSessions() async {
    try {
      final db = await _databaseHelper.database;
      await db.delete('pomodoro_sessions');
    } catch (e) {
      throw DatabaseFailure('清空所有番茄钟会话失败: $e');
    }
  }

  /// 将数据库映射转换为PomodoroSessionModel
  PomodoroSessionModel _mapToSessionModel(Map<String, dynamic> map) {
    return PomodoroSessionModel(
      id: map['id'] as String,
      startTime: DateTime.fromMillisecondsSinceEpoch(map['start_time'] as int),
      endTime: map['end_time'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['end_time'] as int)
          : null,
      plannedDuration: Duration(microseconds: map['planned_duration'] as int),
      actualDuration: Duration(microseconds: map['actual_duration'] as int),
      type: SessionType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => SessionType.work,
      ),
      associatedTaskId: map['associated_task_id'] as String?,
      completed: (map['completed'] as int) == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    );
  }

  /// 将PomodoroSessionModel转换为数据库映射
  Map<String, dynamic> _sessionModelToMap(PomodoroSessionModel session) {
    return {
      'id': session.id,
      'start_time': session.startTime.millisecondsSinceEpoch,
      'end_time': session.endTime?.millisecondsSinceEpoch,
      'planned_duration': session.plannedDuration.inMicroseconds,
      'actual_duration': session.actualDuration.inMicroseconds,
      'type': session.type.name,
      'associated_task_id': session.associatedTaskId,
      'completed': session.completed ? 1 : 0,
      'created_at': session.createdAt.millisecondsSinceEpoch,
    };
  }
}
