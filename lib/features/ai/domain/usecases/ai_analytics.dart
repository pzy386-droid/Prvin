import 'package:prvin/features/ai/domain/entities/analytics_data.dart';
import 'package:prvin/features/ai/domain/repositories/ai_analytics_repository.dart';

/// AI分析用例
class AIAnalytics {
  /// 创建AI分析用例
  const AIAnalytics(this._repository);

  final AIAnalyticsRepository _repository;

  /// 生成今日报告
  Future<AnalyticsData> generateTodayReport(String userId) async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final period = DateRange(startDate: startOfDay, endDate: endOfDay);

    return _repository.generateAnalytics(userId: userId, period: period);
  }

  /// 生成周报告
  Future<AnalyticsData> generateWeeklyReport(String userId) async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 7));

    final period = DateRange(startDate: startOfWeek, endDate: endOfWeek);

    return _repository.generateAnalytics(userId: userId, period: period);
  }

  /// 获取智能标签建议
  Future<List<String>> getSmartTagSuggestions(String taskTitle) async {
    return _repository.getTagSuggestions(taskTitle);
  }

  /// 获取智能分类建议
  Future<TaskCategory> getSmartCategorySuggestion(String taskTitle) async {
    return _repository.getCategorySuggestion(taskTitle);
  }

  /// 获取个性化专注建议
  Future<List<FocusRecommendation>> getPersonalizedFocusAdvice(
    String userId,
  ) async {
    return _repository.getFocusRecommendations(userId);
  }

  /// 获取生产力洞察
  Future<List<ProductivityTrend>> getProductivityInsights({
    required String userId,
    required DateRange period,
  }) async {
    return _repository.getProductivityTrends(
      userId: userId,
      period: period,
    );
  }

  /// 分析任务模式
  Future<List<TaskPattern>> analyzeTaskPatterns(String userId) async {
    return _repository.analyzeTaskPatterns(userId);
  }

  /// 获取专注模式分析
  Future<List<FocusPattern>> getFocusPatterns({
    required String userId,
    required DateRange period,
  }) async {
    return _repository.getFocusPatterns(userId: userId, period: period);
  }

  /// 保存分析结果
  Future<void> saveAnalyticsData(AnalyticsData data) async {
    await _repository.saveAnalyticsData(data);
  }

  /// 获取历史分析数据
  Future<List<AnalyticsData>> getHistoricalAnalytics({
    required String userId,
    required DateRange period,
  }) async {
    return _repository.getHistoricalAnalytics(
      userId: userId,
      period: period,
    );
  }

  /// 清理过期数据
  Future<void> cleanupExpiredData({Duration? olderThan}) async {
    await _repository.clearExpiredAnalytics(
      olderThan: olderThan ?? const Duration(days: 90),
    );
  }
}
