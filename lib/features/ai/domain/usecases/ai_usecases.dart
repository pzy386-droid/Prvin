import 'package:prvin/features/ai/domain/entities/analytics_data.dart';
import 'package:prvin/features/ai/domain/repositories/ai_analytics_repository.dart';
import 'package:prvin/features/task_management/domain/entities/task.dart';

/// AI用例类
class AIUseCases {
  /// 构造函数
  const AIUseCases(this._repository);

  final AIAnalyticsRepository _repository;

  /// 获取任务标签建议
  Future<List<String>> getTagSuggestions(String taskTitle) async {
    return _repository.getTagSuggestions(taskTitle);
  }

  /// 获取任务分类建议
  Future<TaskCategory> getCategorySuggestion(String taskTitle) async {
    return _repository.getCategorySuggestion(taskTitle);
  }

  /// 获取专注建议
  Future<List<FocusRecommendation>> getFocusRecommendations(
    String userId,
  ) async {
    return _repository.getFocusRecommendations(userId);
  }

  /// 分析任务模式
  Future<List<TaskPattern>> analyzeTaskPatterns(String userId) async {
    return _repository.analyzeTaskPatterns(userId);
  }

  /// 生成分析报告
  Future<AnalyticsData> generateAnalytics({
    required String userId,
    required DateRange period,
  }) async {
    return _repository.generateAnalytics(userId: userId, period: period);
  }

  /// 获取生产力趋势
  Future<List<ProductivityTrend>> getProductivityTrends({
    required String userId,
    required DateRange period,
  }) async {
    return _repository.getProductivityTrends(userId: userId, period: period);
  }

  /// 获取专注模式分析
  Future<List<FocusPattern>> getFocusPatterns({
    required String userId,
    required DateRange period,
  }) async {
    return _repository.getFocusPatterns(userId: userId, period: period);
  }

  /// 保存分析数据
  Future<void> saveAnalyticsData(AnalyticsData data) async {
    return _repository.saveAnalyticsData(data);
  }

  /// 获取历史分析数据
  Future<List<AnalyticsData>> getHistoricalAnalytics({
    required String userId,
    required DateRange period,
  }) async {
    return _repository.getHistoricalAnalytics(userId: userId, period: period);
  }

  /// 清理过期分析数据
  Future<void> clearExpiredAnalytics({Duration? olderThan}) async {
    return _repository.clearExpiredAnalytics(olderThan: olderThan);
  }
}
