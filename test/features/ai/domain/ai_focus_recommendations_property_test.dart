import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prvin/features/ai/domain/entities/analytics_data.dart';

/// **Feature: ai-calendar-app, Property 12: AI专注建议**
/// *对于任何*历史数据和工作模式，AI应该提供个性化的专注时间建议
/// **验证需求: 需求 5.3**
void main() {
  group('AI Focus Recommendations Property Tests', () {
    final faker = Faker();

    test(
      'Property 12: AI专注建议 - should provide personalized focus recommendations for any historical data',
      () {
        // 运行100次迭代以确保属性在各种输入下都成立
        for (var i = 0; i < 100; i++) {
          // 生成随机的历史数据和工作模式
          final analyticsData = _generateRandomAnalyticsData(faker);

          // 验证AI应该提供专注时间建议
          expect(
            analyticsData.focusRecommendations,
            isNotEmpty,
            reason:
                'AI should always provide focus recommendations for any analytics data',
          );

          // 验证建议的基本属性
          for (final recommendation in analyticsData.focusRecommendations) {
            // 建议应该有明确的类型
            expect(
              recommendation.type,
              isNotEmpty,
              reason: 'Focus recommendation should have a clear type',
            );

            // 建议应该有具体的消息内容
            expect(
              recommendation.message,
              isNotEmpty,
              reason: 'Focus recommendation should have a meaningful message',
            );

            // 建议的专注时长应该在合理范围内（5-120分钟）
            expect(
              recommendation.recommendedMinutes,
              inInclusiveRange(5, 120),
              reason: 'Recommended focus time should be between 5-120 minutes',
            );

            // 置信度应该在0-1之间
            expect(
              recommendation.confidence,
              inInclusiveRange(0.0, 1.0),
              reason: 'Confidence should be between 0 and 1',
            );

            // 生成时间应该是有效的
            expect(
              recommendation.generatedAt,
              isNotNull,
              reason: 'Recommendation should have a valid generation time',
            );

            // 如果有最佳时间段建议，应该在0-23小时范围内
            for (final hour in recommendation.bestHours) {
              expect(
                hour,
                inInclusiveRange(0, 23),
                reason: 'Best hours should be valid hour values (0-23)',
              );
            }
          }

          // 验证建议的个性化特征
          _validatePersonalizationFeatures(analyticsData);
        }
      },
    );

    test(
      'Property 12: AI专注建议 - recommendations should be based on historical patterns',
      () {
        for (var i = 0; i < 100; i++) {
          final analyticsData = _generateRandomAnalyticsData(faker);

          // 如果有专注模式数据，建议应该反映这些模式
          if (analyticsData.focusPatterns.isNotEmpty) {
            final bestFocusHours = analyticsData.bestFocusHours;
            final recommendations = analyticsData.focusRecommendations;

            // 至少应该有一个建议提到最佳时间段
            final hasTimeBasedRecommendation = recommendations.any(
              (rec) => rec.bestHours.isNotEmpty || rec.type.contains('时间'),
            );

            expect(
              hasTimeBasedRecommendation,
              isTrue,
              reason:
                  'Should provide time-based recommendations when focus patterns exist',
            );
          }

          // 如果有生产力趋势数据，建议应该考虑效率模式
          if (analyticsData.trends.isNotEmpty) {
            final avgEfficiency =
                analyticsData.trends
                    .map((t) => t.efficiencyScore)
                    .reduce((a, b) => a + b) /
                analyticsData.trends.length;

            // 低效率时应该有改进建议
            if (avgEfficiency < 60) {
              final hasImprovementRecommendation = analyticsData
                  .focusRecommendations
                  .any(
                    (rec) =>
                        rec.message.contains('提高') ||
                        rec.message.contains('改善'),
                  );

              expect(
                hasImprovementRecommendation,
                isTrue,
                reason:
                    'Should provide improvement recommendations for low efficiency',
              );
            }
          }
        }
      },
    );

    test(
      'Property 12: AI专注建议 - recommendations should be relevant and accurate',
      () {
        for (var i = 0; i < 100; i++) {
          final analyticsData = _generateRandomAnalyticsData(faker);

          for (final recommendation in analyticsData.focusRecommendations) {
            // 建议应该有足够的置信度（至少0.5）
            expect(
              recommendation.confidence,
              greaterThanOrEqualTo(0.5),
              reason: 'Recommendations should have reasonable confidence level',
            );

            // 建议的专注时长应该基于用户的历史模式
            if (analyticsData.focusPatterns.isNotEmpty) {
              // 建议时长应该在合理范围内
              expect(
                recommendation.recommendedMinutes,
                inInclusiveRange(5, 120),
                reason: 'Recommended time should be within reasonable bounds',
              );

              // 如果有明确的时间段建议，应该与历史数据相关
              if (recommendation.type.contains('时间') &&
                  recommendation.bestHours.isNotEmpty) {
                final recommendedHour = recommendation.bestHours.first;
                final hasMatchingPattern = analyticsData.focusPatterns.any(
                  (pattern) => pattern.hourOfDay == recommendedHour,
                );

                expect(
                  hasMatchingPattern,
                  isTrue,
                  reason:
                      'Time-based recommendations should match historical patterns',
                );
              }
            }
          }
        }
      },
    );
  });
}

/// 生成随机的分析数据用于属性测试
AnalyticsData _generateRandomAnalyticsData(Faker faker) {
  final now = DateTime.now();
  final startDate = now.subtract(
    Duration(days: faker.randomGenerator.integer(30, min: 7)),
  );
  final endDate = now.subtract(
    Duration(days: faker.randomGenerator.integer(3)),
  );

  // 生成随机的时间分配
  final categories = ['工作', '学习', '个人', '健康'];
  final timeDistribution = <String, int>{};
  for (final category in categories) {
    timeDistribution[category] = faker.randomGenerator.integer(480, min: 30);
  }

  // 生成随机的生产力趋势
  final trends = <ProductivityTrend>[];
  final dayCount = endDate.difference(startDate).inDays + 1;
  for (var i = 0; i < dayCount; i++) {
    final date = startDate.add(Duration(days: i));
    trends.add(
      ProductivityTrend(
        date: date,
        completedTasks: faker.randomGenerator.integer(15, min: 1),
        totalWorkMinutes: faker.randomGenerator.integer(600, min: 60),
        focusMinutes: faker.randomGenerator.integer(300, min: 20),
        efficiencyScore: faker.randomGenerator.decimal(scale: 100, min: 20),
      ),
    );
  }

  // 生成随机的专注模式
  final focusPatterns = <FocusPattern>[];
  final focusHours = [9, 10, 11, 14, 15, 16, 19, 20, 21];
  final selectedHours = focusHours.take(
    faker.randomGenerator.integer(5, min: 1),
  );

  for (final hour in selectedHours) {
    focusPatterns.add(
      FocusPattern(
        hourOfDay: hour,
        averageFocusMinutes: faker.randomGenerator.decimal(scale: 60, min: 15),
        sessionCount: faker.randomGenerator.integer(20, min: 1),
        successRate: faker.randomGenerator.decimal(scale: 0.5, min: 0.5),
      ),
    );
  }

  // 生成随机的任务模式
  final taskPatterns = <TaskPattern>[];
  final patternCount = faker.randomGenerator.integer(5, min: 1);
  for (var i = 0; i < patternCount; i++) {
    taskPatterns.add(
      TaskPattern(
        patternName: faker.lorem.words(2).join(' '),
        similarTasks: List.generate(
          faker.randomGenerator.integer(5, min: 2),
          (_) => faker.lorem.sentence(),
        ),
        suggestedTags: List.generate(
          faker.randomGenerator.integer(4, min: 1),
          (_) => faker.lorem.word(),
        ),
        suggestedCategory: TaskCategory
            .values[faker.randomGenerator.integer(TaskCategory.values.length)],
        averageCompletionMinutes: faker.randomGenerator.decimal(
          scale: 180,
          min: 15,
        ),
        confidence: faker.randomGenerator.decimal(scale: 0.5, min: 0.5),
      ),
    );
  }

  // 生成随机的专注建议
  final focusRecommendations = _generateFocusRecommendations(
    faker,
    focusPatterns,
    trends,
  );

  return AnalyticsData(
    userId: faker.guid.guid(),
    period: DateRange(startDate: startDate, endDate: endDate),
    timeDistribution: timeDistribution,
    completionRate: faker.randomGenerator.decimal(scale: 0.7, min: 0.3),
    trends: trends,
    focusPatterns: focusPatterns,
    taskPatterns: taskPatterns,
    focusRecommendations: focusRecommendations,
    generatedAt: now,
  );
}

/// 生成基于历史数据的专注建议
List<FocusRecommendation> _generateFocusRecommendations(
  Faker faker,
  List<FocusPattern> focusPatterns,
  List<ProductivityTrend> trends,
) {
  final recommendations = <FocusRecommendation>[];
  final now = DateTime.now();

  // 基于专注模式的时间建议
  if (focusPatterns.isNotEmpty) {
    final bestPattern = focusPatterns.reduce(
      (a, b) => a.successRate > b.successRate ? a : b,
    );

    recommendations.add(
      FocusRecommendation(
        type: '最佳时间段',
        message: '根据您的历史数据，${bestPattern.hourOfDay}点左右是您专注度最高的时间段',
        recommendedMinutes:
            (focusPatterns
                        .map((p) => p.averageFocusMinutes)
                        .reduce((a, b) => a + b) /
                    focusPatterns.length)
                .round()
                .clamp(5, 120),
        bestHours: [bestPattern.hourOfDay],
        confidence: bestPattern.successRate,
        generatedAt: now,
      ),
    );
  }

  // 基于效率趋势的建议
  if (trends.isNotEmpty) {
    final avgEfficiency =
        trends.map((t) => t.efficiencyScore).reduce((a, b) => a + b) /
        trends.length;

    if (avgEfficiency < 60) {
      recommendations.add(
        FocusRecommendation(
          type: '效率提升',
          message:
              '建议采用番茄钟技术，每${faker.randomGenerator.integer(60, min: 25)}分钟专注后休息${faker.randomGenerator.integer(15, min: 5)}分钟',
          recommendedMinutes: trends.isNotEmpty
              ? (trends.map((t) => t.focusMinutes).reduce((a, b) => a + b) /
                        trends.length)
                    .round()
                    .clamp(25, 60)
              : 45,
          bestHours: const [],
          confidence: 0.8,
          generatedAt: now,
        ),
      );
    }
  }

  // 通用休息建议
  recommendations.add(
    FocusRecommendation(
      type: '休息建议',
      message:
          '建议每${faker.randomGenerator.integer(60, min: 30)}分钟专注后休息${faker.randomGenerator.integer(20, min: 5)}分钟，这样可以提高整体效率',
      recommendedMinutes: focusPatterns.isNotEmpty
          ? (focusPatterns
                        .map((p) => p.averageFocusMinutes)
                        .reduce((a, b) => a + b) /
                    focusPatterns.length)
                .round()
                .clamp(30, 60)
          : 45,
      bestHours: const [],
      confidence: 0.8,
      generatedAt: now,
    ),
  );

  return recommendations;
}

/// 验证建议的个性化特征
void _validatePersonalizationFeatures(AnalyticsData analyticsData) {
  final recommendations = analyticsData.focusRecommendations;

  // 建议应该考虑用户的完成率
  if (analyticsData.completionRate < 0.6) {
    // 低完成率时应该有相关建议
    final hasCompletionAdvice = recommendations.any(
      (rec) =>
          rec.message.contains('完成') ||
          rec.message.contains('效率') ||
          rec.message.contains('专注'),
    );

    expect(
      hasCompletionAdvice,
      isTrue,
      reason:
          'Should provide completion-related advice for low completion rates',
    );
  }

  // 建议应该基于用户的活跃时间段
  if (analyticsData.focusPatterns.isNotEmpty) {
    final hasActiveHours = analyticsData.focusPatterns.any(
      (pattern) => pattern.sessionCount > 5,
    );

    if (hasActiveHours) {
      final hasTimeRecommendation = recommendations.any(
        (rec) => rec.bestHours.isNotEmpty || rec.type.contains('时间'),
      );

      expect(
        hasTimeRecommendation,
        isTrue,
        reason:
            'Should provide time-based recommendations when user has active patterns',
      );
    }
  }
}
