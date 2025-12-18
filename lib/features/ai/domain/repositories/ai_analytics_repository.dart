import '../entities/analytics_data.dart';

/// AI分析仓库接口
abstract class AIAnalyticsRepository {
  /// 生成指定日期范围的分析数据
  Future<AnalyticsData> generateAnalytics({
    required String userId,
    required DateRange period,
  });

  /// 获取任务标签建议
  Future<List<String>> getTagSuggestions(String taskTitle);

  /// 获取任务分类建议
  Future<TaskCategory> getCategorySuggestion(String taskTitle);

  /// 获取专注时间建议
  Future<List<FocusRecommendation>> getFocusRecommendations(String userId);

  /// 分析任务模式
  Future<List<TaskPattern>> analyzeTaskPatterns(String userId);

  /// 获取生产力趋势
  Future<List<ProductivityTrend>> getProductivityTrends({
    required String userId,
    required DateRange period,
  });

  /// 获取专注模式分析
  Future<List<FocusPattern>> getFocusPatterns({
    required String userId,
    required DateRange period,
  });

  /// 保存分析数据
  Future<void> saveAnalyticsData(AnalyticsData data);

  /// 获取历史分析数据
  Future<List<AnalyticsData>> getHistoricalAnalytics({
    required String userId,
    required DateRange period,
  });

  /// 清除过期的分析数据
  Future<void> clearExpiredAnalytics({Duration? olderThan});
}
