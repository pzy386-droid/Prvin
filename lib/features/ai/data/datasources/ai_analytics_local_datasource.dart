import 'package:sqflite/sqflite.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/error/failures.dart';
import '../models/analytics_data_model.dart';

/// AI分析本地数据源接口
abstract class AIAnalyticsLocalDataSource {
  /// 保存分析数据
  Future<void> saveAnalyticsData(AnalyticsDataModel data);

  /// 获取分析数据
  Future<List<AnalyticsDataModel>> getAnalyticsData({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  });

  /// 根据ID获取分析数据
  Future<AnalyticsDataModel?> getAnalyticsById(String id);

  /// 删除分析数据
  Future<void> deleteAnalyticsData(String id);

  /// 清除过期数据
  Future<void> clearExpiredData({Duration? olderThan});

  /// 清空所有分析数据
  Future<void> clearAllAnalytics();
}

/// AI分析本地数据源实现
class AIAnalyticsLocalDataSourceImpl implements AIAnalyticsLocalDataSource {
  /// 创建AI分析本地数据源实现
  const AIAnalyticsLocalDataSourceImpl(this._databaseHelper);

  final DatabaseHelper _databaseHelper;

  @override
  Future<void> saveAnalyticsData(AnalyticsDataModel data) async {
    try {
      final db = await _databaseHelper.database;
      await db.insert(
        'analytics_data',
        _analyticsDataToMap(data),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw DatabaseFailure('保存分析数据失败: $e');
    }
  }

  @override
  Future<List<AnalyticsDataModel>> getAnalyticsData({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final db = await _databaseHelper.database;
      final maps = await db.query(
        'analytics_data',
        where: 'user_id = ? AND generated_at >= ? AND generated_at <= ?',
        whereArgs: [
          userId,
          startDate.millisecondsSinceEpoch,
          endDate.millisecondsSinceEpoch,
        ],
        orderBy: 'generated_at DESC',
      );

      return maps.map(_mapToAnalyticsData).toList();
    } catch (e) {
      throw DatabaseFailure('获取分析数据失败: $e');
    }
  }

  @override
  Future<AnalyticsDataModel?> getAnalyticsById(String id) async {
    try {
      final db = await _databaseHelper.database;
      final maps = await db.query(
        'analytics_data',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (maps.isEmpty) return null;
      return _mapToAnalyticsData(maps.first);
    } catch (e) {
      throw DatabaseFailure('根据ID获取分析数据失败: $e');
    }
  }

  @override
  Future<void> deleteAnalyticsData(String id) async {
    try {
      final db = await _databaseHelper.database;
      final count = await db.delete(
        'analytics_data',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (count == 0) {
        throw const DatabaseFailure('分析数据不存在，无法删除');
      }
    } catch (e) {
      throw DatabaseFailure('删除分析数据失败: $e');
    }
  }

  @override
  Future<void> clearExpiredData({Duration? olderThan}) async {
    try {
      final db = await _databaseHelper.database;
      final cutoffTime = DateTime.now().subtract(
        olderThan ?? const Duration(days: 90),
      );

      await db.delete(
        'analytics_data',
        where: 'generated_at < ?',
        whereArgs: [cutoffTime.millisecondsSinceEpoch],
      );
    } catch (e) {
      throw DatabaseFailure('清除过期分析数据失败: $e');
    }
  }

  @override
  Future<void> clearAllAnalytics() async {
    try {
      final db = await _databaseHelper.database;
      await db.delete('analytics_data');
    } catch (e) {
      throw DatabaseFailure('清空所有分析数据失败: $e');
    }
  }

  /// 将AnalyticsDataModel转换为数据库映射
  Map<String, dynamic> _analyticsDataToMap(AnalyticsDataModel data) {
    return {
      'id':
          data.userId +
          '_' +
          data.generatedAt.millisecondsSinceEpoch.toString(),
      'user_id': data.userId,
      'period_start': data.period.startDate.millisecondsSinceEpoch,
      'period_end': data.period.endDate.millisecondsSinceEpoch,
      'time_distribution': data.timeDistribution.toString(),
      'completion_rate': data.completionRate,
      'trends_data': data.trends.map((t) => t.toJson()).toList().toString(),
      'focus_patterns_data': data.focusPatterns
          .map((f) => f.toJson())
          .toList()
          .toString(),
      'task_patterns_data': data.taskPatterns
          .map((t) => t.toJson())
          .toList()
          .toString(),
      'focus_recommendations_data': data.focusRecommendations
          .map((f) => f.toJson())
          .toList()
          .toString(),
      'generated_at': data.generatedAt.millisecondsSinceEpoch,
    };
  }

  /// 将数据库映射转换为AnalyticsDataModel
  AnalyticsDataModel _mapToAnalyticsData(Map<String, dynamic> map) {
    // 这里简化处理，实际应该正确解析JSON数据
    return AnalyticsDataModel(
      userId: map['user_id'] as String,
      period: DateRange(
        startDate: DateTime.fromMillisecondsSinceEpoch(
          map['period_start'] as int,
        ),
        endDate: DateTime.fromMillisecondsSinceEpoch(map['period_end'] as int),
      ),
      timeDistribution: <String, int>{}, // 简化处理
      completionRate: map['completion_rate'] as double,
      trends: <ProductivityTrend>[], // 简化处理
      focusPatterns: <FocusPattern>[], // 简化处理
      taskPatterns: <TaskPattern>[], // 简化处理
      focusRecommendations: <FocusRecommendation>[], // 简化处理
      generatedAt: DateTime.fromMillisecondsSinceEpoch(
        map['generated_at'] as int,
      ),
    );
  }
}
