import '../entities/analytics_data.dart';
import '../repositories/ai_analytics_repository.dart';

/// AI分析用例
class AIAnalytics {
  /// 创建AI分析用例
  const AIAnalytics(this._repository);

  final AIAnalyticsRepository _repository;

  /// 生成完整的分析报告
  Future<AnalyticsData> generateFullReport({
    required String userId,
    required DateRange period,
  }) async {
    return await _repository.generateAnalytics(userId: userId, period: period);
  }

  /// 生成今日分析报告
  Future<AnalyticsData> generateTodayReport(String userId) async {
    final today = DateTime.now();
    final period = DateRange(
      startDate: DateTime(today.year, today.month, today.day),
      endDate: today,
    );

    return await _repository.generateAnalytics(userId: userId, period: period);
  }

  /// 生成本周分析报告
  Future<AnalyticsData> generateWeeklyReport(String userId) async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final period = DateRange(
      startDate: DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day),
      endDate: now,
    );

    return await _repository.generateAnalytics(userId: userId, period: period);
  }

  /// 生成本月分析报告
  Future<AnalyticsData> generateMonthlyReport(String userId) async {
    final now = DateTime.now();
    final period = DateRange(
      startDate: DateTime(now.year, now.month, 1),
      endDate: now,
    );

    return await _repository.generateAnalytics(userId: userId, period: period);
  }

  /// 获取智能任务标签建议
  Future<List<String>> getSmartTagSuggestions(String taskTitle) async {
    return await _repository.getTagSuggestions(taskTitle);
  }

  /// 获取智能任务分类建议
  Future<TaskCategory> getSmartCategorySuggestion(String taskTitle) async {
    return await _repository.getCategorySuggestion(taskTitle);
  }

  /// 获取个性化专注建议
  Future<List<FocusRecommendation>> getPersonalizedFocusAdvice(
    String userId,
  ) async {
    return await _repository.getFocusRecommendations(userId);
  }

  /// 分析用户任务模式
  Future<List<TaskPattern>> analyzeUserTaskPatterns(String userId) async {
    return await _repository.analyzeTaskPatterns(userId);
  }

  /// 获取生产力趋势分析
  Future<ProductivityInsights> getProductivityInsights({
    required String userId,
    required DateRange period,
  }) async {
    final trends = await _repository.getProductivityTrends(
      userId: userId,
      period: period,
    );

    return _analyzeProductivityTrends(trends);
  }

  /// 获取专注模式分析
  Future<FocusInsights> getFocusInsights({
    required String userId,
    required DateRange period,
  }) async {
    final patterns = await _repository.getFocusPatterns(
      userId: userId,
      period: period,
    );

    return _analyzeFocusPatterns(patterns);
  }

  /// 获取历史分析数据对比
  Future<AnalyticsComparison> compareAnalytics({
    required String userId,
    required DateRange currentPeriod,
    required DateRange previousPeriod,
  }) async {
    final currentData = await _repository.generateAnalytics(
      userId: userId,
      period: currentPeriod,
    );

    final previousData = await _repository.generateAnalytics(
      userId: userId,
      period: previousPeriod,
    );

    return _compareAnalyticsData(currentData, previousData);
  }

  /// 清理过期的分析数据
  Future<void> cleanupExpiredData({Duration? olderThan}) async {
    await _repository.clearExpiredAnalytics(olderThan: olderThan);
  }

  /// 分析生产力趋势
  ProductivityInsights _analyzeProductivityTrends(
    List<ProductivityTrend> trends,
  ) {
    if (trends.isEmpty) {
      return const ProductivityInsights(
        averageEfficiency: 0,
        trendDirection: TrendDirection.stable,
        bestDay: null,
        worstDay: null,
        recommendations: [],
      );
    }

    final avgEfficiency =
        trends.map((t) => t.efficiencyScore).reduce((a, b) => a + b) /
        trends.length;

    final sortedByEfficiency = List<ProductivityTrend>.from(trends)
      ..sort((a, b) => b.efficiencyScore.compareTo(a.efficiencyScore));

    final bestDay = sortedByEfficiency.first;
    final worstDay = sortedByEfficiency.last;

    // 简化的趋势分析
    final trendDirection = _calculateTrendDirection(trends);

    final recommendations = _generateProductivityRecommendations(
      avgEfficiency,
      trendDirection,
    );

    return ProductivityInsights(
      averageEfficiency: avgEfficiency,
      trendDirection: trendDirection,
      bestDay: bestDay,
      worstDay: worstDay,
      recommendations: recommendations,
    );
  }

  /// 分析专注模式
  FocusInsights _analyzeFocusPatterns(List<FocusPattern> patterns) {
    if (patterns.isEmpty) {
      return const FocusInsights(
        bestFocusHours: [],
        worstFocusHours: [],
        averageSessionLength: 0,
        overallSuccessRate: 0,
        recommendations: [],
      );
    }

    final sortedBySuccess = List<FocusPattern>.from(patterns)
      ..sort((a, b) => b.successRate.compareTo(a.successRate));

    final bestHours = sortedBySuccess.take(3).map((p) => p.hourOfDay).toList();
    final worstHours = sortedBySuccess
        .skip(patterns.length - 3)
        .map((p) => p.hourOfDay)
        .toList();

    final avgSessionLength =
        patterns.map((p) => p.averageFocusMinutes).reduce((a, b) => a + b) /
        patterns.length;

    final overallSuccessRate =
        patterns.map((p) => p.successRate).reduce((a, b) => a + b) /
        patterns.length;

    final recommendations = _generateFocusRecommendations(
      bestHours,
      avgSessionLength,
      overallSuccessRate,
    );

    return FocusInsights(
      bestFocusHours: bestHours,
      worstFocusHours: worstHours,
      averageSessionLength: avgSessionLength,
      overallSuccessRate: overallSuccessRate,
      recommendations: recommendations,
    );
  }

  /// 对比分析数据
  AnalyticsComparison _compareAnalyticsData(
    AnalyticsData current,
    AnalyticsData previous,
  ) {
    final completionRateChange =
        current.completionRate - previous.completionRate;
    final workTimeChange = current.totalWorkMinutes - previous.totalWorkMinutes;

    return AnalyticsComparison(
      completionRateChange: completionRateChange,
      workTimeChange: workTimeChange,
      efficiencyChange: _calculateEfficiencyChange(current, previous),
      improvements: _identifyImprovements(current, previous),
      regressions: _identifyRegressions(current, previous),
    );
  }

  /// 计算趋势方向
  TrendDirection _calculateTrendDirection(List<ProductivityTrend> trends) {
    if (trends.length < 2) return TrendDirection.stable;

    final firstHalf = trends.take(trends.length ~/ 2);
    final secondHalf = trends.skip(trends.length ~/ 2);

    final firstAvg =
        firstHalf.map((t) => t.efficiencyScore).reduce((a, b) => a + b) /
        firstHalf.length;
    final secondAvg =
        secondHalf.map((t) => t.efficiencyScore).reduce((a, b) => a + b) /
        secondHalf.length;

    const threshold = 5.0;
    if (secondAvg - firstAvg > threshold) return TrendDirection.improving;
    if (firstAvg - secondAvg > threshold) return TrendDirection.declining;
    return TrendDirection.stable;
  }

  /// 生成生产力建议
  List<String> _generateProductivityRecommendations(
    double avgEfficiency,
    TrendDirection trend,
  ) {
    final recommendations = <String>[];

    if (avgEfficiency < 60) {
      recommendations.add('您的整体效率偏低，建议优化任务规划和时间管理');
    }

    switch (trend) {
      case TrendDirection.declining:
        recommendations.add('最近效率有所下降，建议分析原因并调整工作方式');
        break;
      case TrendDirection.improving:
        recommendations.add('效率持续提升，继续保持当前的工作节奏');
        break;
      case TrendDirection.stable:
        recommendations.add('效率保持稳定，可以尝试新的提升方法');
        break;
    }

    return recommendations;
  }

  /// 生成专注建议
  List<String> _generateFocusRecommendations(
    List<int> bestHours,
    double avgSessionLength,
    double successRate,
  ) {
    final recommendations = <String>[];

    if (bestHours.isNotEmpty) {
      recommendations.add('您的最佳专注时间是${bestHours.join('、')}点，建议在这些时段安排重要任务');
    }

    if (avgSessionLength < 20) {
      recommendations.add('平均专注时长较短，建议逐步延长专注时间');
    } else if (avgSessionLength > 45) {
      recommendations.add('专注时长较长，注意适当休息避免疲劳');
    }

    if (successRate < 0.7) {
      recommendations.add('专注成功率偏低，建议减少干扰因素或调整专注时长');
    }

    return recommendations;
  }

  /// 计算效率变化
  double _calculateEfficiencyChange(
    AnalyticsData current,
    AnalyticsData previous,
  ) {
    if (current.trends.isEmpty || previous.trends.isEmpty) return 0;

    final currentAvg =
        current.trends.map((t) => t.efficiencyScore).reduce((a, b) => a + b) /
        current.trends.length;
    final previousAvg =
        previous.trends.map((t) => t.efficiencyScore).reduce((a, b) => a + b) /
        previous.trends.length;

    return currentAvg - previousAvg;
  }

  /// 识别改进点
  List<String> _identifyImprovements(
    AnalyticsData current,
    AnalyticsData previous,
  ) {
    final improvements = <String>[];

    if (current.completionRate > previous.completionRate) {
      improvements.add('任务完成率有所提升');
    }

    if (current.totalWorkMinutes > previous.totalWorkMinutes) {
      improvements.add('工作时间增加');
    }

    return improvements;
  }

  /// 识别退步点
  List<String> _identifyRegressions(
    AnalyticsData current,
    AnalyticsData previous,
  ) {
    final regressions = <String>[];

    if (current.completionRate < previous.completionRate) {
      regressions.add('任务完成率有所下降');
    }

    if (current.totalWorkMinutes < previous.totalWorkMinutes) {
      regressions.add('工作时间减少');
    }

    return regressions;
  }
}

/// 趋势方向枚举
enum TrendDirection {
  /// 改善中
  improving,

  /// 下降中
  declining,

  /// 稳定
  stable,
}

/// 生产力洞察
class ProductivityInsights {
  /// 创建生产力洞察
  const ProductivityInsights({
    required this.averageEfficiency,
    required this.trendDirection,
    required this.bestDay,
    required this.worstDay,
    required this.recommendations,
  });

  /// 平均效率
  final double averageEfficiency;

  /// 趋势方向
  final TrendDirection trendDirection;

  /// 最佳日期
  final ProductivityTrend? bestDay;

  /// 最差日期
  final ProductivityTrend? worstDay;

  /// 建议列表
  final List<String> recommendations;
}

/// 专注洞察
class FocusInsights {
  /// 创建专注洞察
  const FocusInsights({
    required this.bestFocusHours,
    required this.worstFocusHours,
    required this.averageSessionLength,
    required this.overallSuccessRate,
    required this.recommendations,
  });

  /// 最佳专注时间
  final List<int> bestFocusHours;

  /// 最差专注时间
  final List<int> worstFocusHours;

  /// 平均会话长度
  final double averageSessionLength;

  /// 整体成功率
  final double overallSuccessRate;

  /// 建议列表
  final List<String> recommendations;
}

/// 分析对比结果
class AnalyticsComparison {
  /// 创建分析对比结果
  const AnalyticsComparison({
    required this.completionRateChange,
    required this.workTimeChange,
    required this.efficiencyChange,
    required this.improvements,
    required this.regressions,
  });

  /// 完成率变化
  final double completionRateChange;

  /// 工作时间变化
  final int workTimeChange;

  /// 效率变化
  final double efficiencyChange;

  /// 改进点
  final List<String> improvements;

  /// 退步点
  final List<String> regressions;
}
