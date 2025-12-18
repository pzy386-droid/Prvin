// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics_data_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductivityTrend _$ProductivityTrendFromJson(Map<String, dynamic> json) =>
    ProductivityTrend(
      date: DateTime.parse(json['date'] as String),
      completedTasks: (json['completedTasks'] as num).toInt(),
      totalWorkMinutes: (json['totalWorkMinutes'] as num).toInt(),
      focusMinutes: (json['focusMinutes'] as num).toInt(),
      efficiencyScore: (json['efficiencyScore'] as num).toDouble(),
    );

Map<String, dynamic> _$ProductivityTrendToJson(ProductivityTrend instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'completedTasks': instance.completedTasks,
      'totalWorkMinutes': instance.totalWorkMinutes,
      'focusMinutes': instance.focusMinutes,
      'efficiencyScore': instance.efficiencyScore,
    };

FocusPattern _$FocusPatternFromJson(Map<String, dynamic> json) => FocusPattern(
  hourOfDay: (json['hourOfDay'] as num).toInt(),
  averageFocusMinutes: (json['averageFocusMinutes'] as num).toDouble(),
  sessionCount: (json['sessionCount'] as num).toInt(),
  successRate: (json['successRate'] as num).toDouble(),
);

Map<String, dynamic> _$FocusPatternToJson(FocusPattern instance) =>
    <String, dynamic>{
      'hourOfDay': instance.hourOfDay,
      'averageFocusMinutes': instance.averageFocusMinutes,
      'sessionCount': instance.sessionCount,
      'successRate': instance.successRate,
    };

TaskPattern _$TaskPatternFromJson(Map<String, dynamic> json) => TaskPattern(
  patternName: json['patternName'] as String,
  similarTasks: (json['similarTasks'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  suggestedTags: (json['suggestedTags'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  suggestedCategory: $enumDecode(
    _$TaskCategoryEnumMap,
    json['suggestedCategory'],
  ),
  averageCompletionMinutes: (json['averageCompletionMinutes'] as num)
      .toDouble(),
  confidence: (json['confidence'] as num).toDouble(),
);

Map<String, dynamic> _$TaskPatternToJson(TaskPattern instance) =>
    <String, dynamic>{
      'patternName': instance.patternName,
      'similarTasks': instance.similarTasks,
      'suggestedTags': instance.suggestedTags,
      'suggestedCategory': _$TaskCategoryEnumMap[instance.suggestedCategory]!,
      'averageCompletionMinutes': instance.averageCompletionMinutes,
      'confidence': instance.confidence,
    };

const _$TaskCategoryEnumMap = {
  TaskCategory.work: 'work',
  TaskCategory.personal: 'personal',
  TaskCategory.health: 'health',
  TaskCategory.learning: 'learning',
  TaskCategory.social: 'social',
};

FocusRecommendation _$FocusRecommendationFromJson(Map<String, dynamic> json) =>
    FocusRecommendation(
      type: json['type'] as String,
      message: json['message'] as String,
      recommendedMinutes: (json['recommendedMinutes'] as num).toInt(),
      bestHours: (json['bestHours'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      confidence: (json['confidence'] as num).toDouble(),
      generatedAt: DateTime.parse(json['generatedAt'] as String),
    );

Map<String, dynamic> _$FocusRecommendationToJson(
  FocusRecommendation instance,
) => <String, dynamic>{
  'type': instance.type,
  'message': instance.message,
  'recommendedMinutes': instance.recommendedMinutes,
  'bestHours': instance.bestHours,
  'confidence': instance.confidence,
  'generatedAt': instance.generatedAt.toIso8601String(),
};

DateRange _$DateRangeFromJson(Map<String, dynamic> json) => DateRange(
  startDate: DateTime.parse(json['startDate'] as String),
  endDate: DateTime.parse(json['endDate'] as String),
);

Map<String, dynamic> _$DateRangeToJson(DateRange instance) => <String, dynamic>{
  'startDate': instance.startDate.toIso8601String(),
  'endDate': instance.endDate.toIso8601String(),
};

AnalyticsDataModel _$AnalyticsDataModelFromJson(Map<String, dynamic> json) =>
    AnalyticsDataModel(
      userId: json['userId'] as String,
      period: DateRange.fromJson(json['period'] as Map<String, dynamic>),
      timeDistribution: Map<String, int>.from(json['timeDistribution'] as Map),
      completionRate: (json['completionRate'] as num).toDouble(),
      trends: (json['trends'] as List<dynamic>)
          .map((e) => ProductivityTrend.fromJson(e as Map<String, dynamic>))
          .toList(),
      focusPatterns: (json['focusPatterns'] as List<dynamic>)
          .map((e) => FocusPattern.fromJson(e as Map<String, dynamic>))
          .toList(),
      taskPatterns: (json['taskPatterns'] as List<dynamic>)
          .map((e) => TaskPattern.fromJson(e as Map<String, dynamic>))
          .toList(),
      focusRecommendations: (json['focusRecommendations'] as List<dynamic>)
          .map((e) => FocusRecommendation.fromJson(e as Map<String, dynamic>))
          .toList(),
      generatedAt: DateTime.parse(json['generatedAt'] as String),
    );

Map<String, dynamic> _$AnalyticsDataModelToJson(AnalyticsDataModel instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'period': instance.period,
      'timeDistribution': instance.timeDistribution,
      'completionRate': instance.completionRate,
      'trends': instance.trends,
      'focusPatterns': instance.focusPatterns,
      'taskPatterns': instance.taskPatterns,
      'focusRecommendations': instance.focusRecommendations,
      'generatedAt': instance.generatedAt.toIso8601String(),
    };
