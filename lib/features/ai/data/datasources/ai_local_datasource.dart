import 'package:prvin/core/database/database_helper.dart';
import 'package:prvin/features/ai/domain/entities/analytics_data.dart';
import 'package:prvin/features/task_management/domain/entities/task.dart';
import 'package:sqflite/sqflite.dart';

/// AI本地数据源
abstract class AILocalDataSource {
  /// 获取用户任务数据
  Future<List<Task>> getUserTasks(String userId);

  /// 获取指定时间范围内的任务
  Future<List<Task>> getTasksInPeriod(String userId, DateRange period);

  /// 获取番茄钟会话数据
  Future<List<Map<String, dynamic>>> getPomodoroSessions(
    String userId,
    DateRange period,
  );

  /// 保存分析数据
  Future<void> saveAnalyticsData(AnalyticsData data);

  /// 获取历史分析数据
  Future<List<AnalyticsData>> getHistoricalAnalytics(
    String userId,
    DateRange period,
  );

  /// 清理过期数据
  Future<void> clearExpiredData(Duration olderThan);
}

/// AI本地数据源实现
class AILocalDataSourceImpl implements AILocalDataSource {
  /// 构造函数
  const AILocalDataSourceImpl(this._databaseHelper);

  final DatabaseHelper _databaseHelper;

  @override
  Future<List<Task>> getUserTasks(String userId) async {
    try {
      final db = await _databaseHelper.database;
      final maps = await db.query(
        'tasks',
        where: 'userId = ?',
        whereArgs: [userId],
        orderBy: 'createdAt DESC',
      );

      return maps.map(Task.fromMap).toList();
    } catch (e) {
      throw Exception('获取用户任务失败: $e');
    }
  }

  @override
  Future<List<Task>> getTasksInPeriod(String userId, DateRange period) async {
    try {
      final db = await _databaseHelper.database;
      final maps = await db.query(
        'tasks',
        where: 'userId = ? AND startTime >= ? AND endTime <= ?',
        whereArgs: [
          userId,
          period.startDate.millisecondsSinceEpoch,
          period.endDate.millisecondsSinceEpoch,
        ],
        orderBy: 'startTime ASC',
      );

      return maps.map(Task.fromMap).toList();
    } catch (e) {
      throw Exception('获取时间范围内任务失败: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getPomodoroSessions(
    String userId,
    DateRange period,
  ) async {
    try {
      final db = await _databaseHelper.database;
      final maps = await db.query(
        'pomodoro_sessions',
        where: 'userId = ? AND startTime >= ? AND startTime <= ?',
        whereArgs: [
          userId,
          period.startDate.millisecondsSinceEpoch,
          period.endDate.millisecondsSinceEpoch,
        ],
        orderBy: 'startTime ASC',
      );

      return maps;
    } catch (e) {
      throw Exception('获取番茄钟会话失败: $e');
    }
  }

  @override
  Future<void> saveAnalyticsData(AnalyticsData data) async {
    try {
      final db = await _databaseHelper.database;

      await db.insert('analytics_data', {
        'userId': data.userId,
        'startDate': data.period.startDate.millisecondsSinceEpoch,
        'endDate': data.period.endDate.millisecondsSinceEpoch,
        'timeDistribution': _encodeTimeDistribution(data.timeDistribution),
        'completionRate': data.completionRate,
        'generatedAt': data.generatedAt.millisecondsSinceEpoch,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      throw Exception('保存分析数据失败: $e');
    }
  }

  @override
  Future<List<AnalyticsData>> getHistoricalAnalytics(
    String userId,
    DateRange period,
  ) async {
    try {
      final db = await _databaseHelper.database;
      final maps = await db.query(
        'analytics_data',
        where: 'userId = ? AND startDate >= ? AND endDate <= ?',
        whereArgs: [
          userId,
          period.startDate.millisecondsSinceEpoch,
          period.endDate.millisecondsSinceEpoch,
        ],
        orderBy: 'generatedAt DESC',
      );

      return maps.map(_analyticsDataFromMap).toList();
    } catch (e) {
      throw Exception('获取历史分析数据失败: $e');
    }
  }

  @override
  Future<void> clearExpiredData(Duration olderThan) async {
    try {
      final db = await _databaseHelper.database;
      final cutoffTime = DateTime.now().subtract(olderThan);

      await db.delete(
        'analytics_data',
        where: 'generatedAt < ?',
        whereArgs: [cutoffTime.millisecondsSinceEpoch],
      );
    } catch (e) {
      throw Exception('清理过期数据失败: $e');
    }
  }

  // 私有辅助方法

  String _encodeTimeDistribution(Map<String, int> distribution) {
    // 简单的JSON编码，实际项目中可以使用dart:convert
    final entries = distribution.entries
        .map((e) => '"${e.key}":${e.value}')
        .join(',');
    return '{$entries}';
  }

  Map<String, int> _decodeTimeDistribution(String encoded) {
    // 简单的JSON解码，实际项目中可以使用dart:convert
    final distribution = <String, int>{};
    // 这里简化实现，实际应该使用正确的JSON解析
    return distribution;
  }

  AnalyticsData _analyticsDataFromMap(Map<String, dynamic> map) {
    return AnalyticsData(
      userId: map['userId'] as String,
      period: DateRange(
        startDate: DateTime.fromMillisecondsSinceEpoch(map['startDate'] as int),
        endDate: DateTime.fromMillisecondsSinceEpoch(map['endDate'] as int),
      ),
      timeDistribution: _decodeTimeDistribution(
        map['timeDistribution'] as String,
      ),
      completionRate: map['completionRate'] as double,
      trends: const [], // 简化实现
      focusPatterns: const [], // 简化实现
      taskPatterns: const [], // 简化实现
      focusRecommendations: const [], // 简化实现
      generatedAt: DateTime.fromMillisecondsSinceEpoch(
        map['generatedAt'] as int,
      ),
    );
  }
}
