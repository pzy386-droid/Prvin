import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:prvin/features/tasks/data/models/task_model.dart';

part 'analytics_data_model.g.dart';

/// 生产力趋势数据
@JsonSerializable()
class ProductivityTrend extends Equatable {
  const ProductivityTrend({
    required this.date,
    required this.completedTasks,
    required this.totalWorkMinutes,
    required this.focusMinutes,
    required this.efficiencyScore,
  });

  factory ProductivityTrend.fromJson(Map<String, dynamic> json) =>
      _$ProductivityTrendFromJson(json);

  /// 日期
  final DateTime date;

  /// 完成任务数
  final int completedTasks;

  /// 总工作时间（分钟）
  final int totalWorkMinutes;

  /// 专注时间（分钟）
  final int focusMinutes;

  /// 效率评分（0-100）
  final double efficiencyScore;

  Map<String, dynamic> toJson() => _$ProductivityTrendToJson(this);

  @override
  List<Object?> get props => [
    date,
    completedTasks,
    totalWorkMinutes,
    focusMinutes,
    efficiencyScore,
  ];
}

/// 专注模式数据
@JsonSerializable()
class FocusPattern extends Equatable {
  const FocusPattern({
    required this.hourOfDay,
    required this.averageFocusMinutes,
    required this.sessionCount,
    required this.successRate,
  });

  factory FocusPattern.fromJson(Map<String, dynamic> json) =>
      _$FocusPatternFromJson(json);

  /// 时间段（小时）
  final int hourOfDay;

  /// 平均专注时长（分钟）
  final double averageFocusMinutes;

  /// 专注会话数
  final int sessionCount;

  /// 成功率（0-1）
  final double successRate;

  Map<String, dynamic> toJson() => _$FocusPatternToJson(this);

  @override
  List<Object?> get props => [
    hourOfDay,
    averageFocusMinutes,
    sessionCount,
    successRate,
  ];
}

/// 任务模式数据
@JsonSerializable()
class TaskPattern extends Equatable {
  const TaskPattern({
    required this.patternName,
    required this.similarTasks,
    required this.suggestedTags,
    required this.suggestedCategory,
    required this.averageCompletionMinutes,
    required this.confidence,
  });

  factory TaskPattern.fromJson(Map<String, dynamic> json) =>
      _$TaskPatternFromJson(json);

  /// 模式名称
  final String patternName;

  /// 相似任务列表
  final List<String> similarTasks;

  /// 建议标签
  final List<String> suggestedTags;

  /// 建议分类
  final TaskCategory suggestedCategory;

  /// 平均完成时间（分钟）
  final double averageCompletionMinutes;

  /// 置信度（0-1）
  final double confidence;

  Map<String, dynamic> toJson() => _$TaskPatternToJson(this);

  @override
  List<Object?> get props => [
    patternName,
    similarTasks,
    suggestedTags,
    suggestedCategory,
    averageCompletionMinutes,
    confidence,
  ];
}

/// 专注建议数据
@JsonSerializable()
class FocusRecommendation extends Equatable {
  const FocusRecommendation({
    required this.type,
    required this.message,
    required this.recommendedMinutes,
    required this.bestHours,
    required this.confidence,
    required this.generatedAt,
  });

  factory FocusRecommendation.fromJson(Map<String, dynamic> json) =>
      _$FocusRecommendationFromJson(json);

  /// 建议类型
  final String type;

  /// 建议内容
  final String message;

  /// 建议的专注时长（分钟）
  final int recommendedMinutes;

  /// 最佳时间段
  final List<int> bestHours;

  /// 置信度（0-1）
  final double confidence;

  /// 生成时间
  final DateTime generatedAt;

  Map<String, dynamic> toJson() => _$FocusRecommendationToJson(this);

  @override
  List<Object?> get props => [
    type,
    message,
    recommendedMinutes,
    bestHours,
    confidence,
    generatedAt,
  ];
}

/// 日期范围数据
@JsonSerializable()
class DateRange extends Equatable {
  const DateRange({required this.startDate, required this.endDate});

  factory DateRange.fromJson(Map<String, dynamic> json) =>
      _$DateRangeFromJson(json);

  /// 开始日期
  final DateTime startDate;

  /// 结束日期
  final DateTime endDate;

  Map<String, dynamic> toJson() => _$DateRangeToJson(this);

  /// 获取日期范围的天数
  int get dayCount => endDate.difference(startDate).inDays + 1;

  /// 检查日期是否在范围内
  bool contains(DateTime date) {
    return date.isAfter(startDate.subtract(const Duration(days: 1))) &&
        date.isBefore(endDate.add(const Duration(days: 1)));
  }

  @override
  List<Object?> get props => [startDate, endDate];
}

/// 分析数据主模型
@JsonSerializable()
class AnalyticsDataModel extends Equatable {
  const AnalyticsDataModel({
    required this.userId,
    required this.period,
    required this.timeDistribution,
    required this.completionRate,
    required this.trends,
    required this.focusPatterns,
    required this.taskPatterns,
    required this.focusRecommendations,
    required this.generatedAt,
  });

  /// 从JSON创建AnalyticsDataModel
  factory AnalyticsDataModel.fromJson(Map<String, dynamic> json) =>
      _$AnalyticsDataModelFromJson(json);

  /// 用户ID
  final String userId;

  /// 分析周期
  final DateRange period;

  /// 时间分配（分类 -> 分钟数）
  final Map<String, int> timeDistribution;

  /// 任务完成率（0-1）
  final double completionRate;

  /// 生产力趋势列表
  final List<ProductivityTrend> trends;

  /// 专注模式列表
  final List<FocusPattern> focusPatterns;

  /// 任务模式列表
  final List<TaskPattern> taskPatterns;

  /// 专注建议列表
  final List<FocusRecommendation> focusRecommendations;

  /// 生成时间
  final DateTime generatedAt;

  /// 转换为JSON
  Map<String, dynamic> toJson() => _$AnalyticsDataModelToJson(this);

  /// 数据验证
  bool isValid() {
    // 用户ID不能为空
    if (userId.trim().isEmpty) return false;

    // 完成率必须在0-1之间
    if (completionRate < 0 || completionRate > 1) return false;

    // 时间分配不能有负值
    if (timeDistribution.values.any((minutes) => minutes < 0)) return false;

    // 生成时间应该在周期结束时间之后或同一天
    // 允许一定的时间容差
    if (generatedAt.isBefore(period.endDate.subtract(const Duration(hours: 1)))) {
      return false;
    }

    return true;
  }

  /// 获取总工作时间（分钟）
  int get totalWorkMinutes =>
      timeDistribution.values.fold(0, (sum, minutes) => sum + minutes);

  /// 获取最活跃的任务分类
  String? get mostActiveCategory {
    if (timeDistribution.isEmpty) return null;

    String? maxCategory;
    var maxMinutes = 0;

    timeDistribution.forEach((category, minutes) {
      if (minutes > maxMinutes) {
        maxMinutes = minutes;
        maxCategory = category;
      }
    });

    return maxCategory;
  }

  /// 获取平均每日完成任务数
  double get averageDailyCompletedTasks {
    if (trends.isEmpty) return 0;
    final totalTasks = trends.fold(
      0,
      (sum, trend) => sum + trend.completedTasks,
    );
    return totalTasks / trends.length;
  }

  /// 获取最佳专注时间段
  List<int> get bestFocusHours {
    if (focusPatterns.isEmpty) return [];

    // 按成功率排序，取前3个时间段
    final sortedPatterns = List<FocusPattern>.from(focusPatterns)
      ..sort((a, b) => b.successRate.compareTo(a.successRate));

    return sortedPatterns.take(3).map((pattern) => pattern.hourOfDay).toList();
  }

  /// 复制并更新分析数据
  AnalyticsDataModel copyWith({
    String? userId,
    DateRange? period,
    Map<String, int>? timeDistribution,
    double? completionRate,
    List<ProductivityTrend>? trends,
    List<FocusPattern>? focusPatterns,
    List<TaskPattern>? taskPatterns,
    List<FocusRecommendation>? focusRecommendations,
    DateTime? generatedAt,
  }) {
    return AnalyticsDataModel(
      userId: userId ?? this.userId,
      period: period ?? this.period,
      timeDistribution: timeDistribution ?? this.timeDistribution,
      completionRate: completionRate ?? this.completionRate,
      trends: trends ?? this.trends,
      focusPatterns: focusPatterns ?? this.focusPatterns,
      taskPatterns: taskPatterns ?? this.taskPatterns,
      focusRecommendations: focusRecommendations ?? this.focusRecommendations,
      generatedAt: generatedAt ?? this.generatedAt,
    );
  }

  @override
  List<Object?> get props => [
    userId,
    period,
    timeDistribution,
    completionRate,
    trends,
    focusPatterns,
    taskPatterns,
    focusRecommendations,
    generatedAt,
  ];
}
