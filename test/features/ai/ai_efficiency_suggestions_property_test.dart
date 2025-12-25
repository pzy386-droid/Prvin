import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prvin/features/ai/data/datasources/ai_local_datasource.dart';
import 'package:prvin/features/ai/data/repositories/ai_analytics_repository_impl.dart';
import 'package:prvin/features/ai/domain/entities/analytics_data.dart';
import 'package:prvin/features/task_management/domain/entities/task.dart';

/// **Feature: prvin-integrated-calendar, Property 22: AI效率建议**
/// **验证需求: 需求 7.2**
///
/// 对于任何检测到的效率模式，AI应该提供专注时间建议和任务优化
void main() {
  group('AI效率建议属性测试', () {
    late AIAnalyticsRepositoryImpl repository;
    late MockAILocalDataSource mockDataSource;

    setUp(() {
      mockDataSource = MockAILocalDataSource();
      repository = AIAnalyticsRepositoryImpl(mockDataSource);
    });

    test(
      '**Feature: prvin-integrated-calendar, Property 22: AI效率建议** - 对于任何用户，应该提供专注时间建议',
      () async {
        final faker = Faker();

        // 运行100次属性测试
        for (var i = 0; i < 100; i++) {
          final userId = faker.guid.guid();

          // 获取专注建议
          final recommendations = await repository.getFocusRecommendations(
            userId,
          );

          // 验证建议的基本属性
          expect(recommendations, isNotEmpty, reason: '应该为用户提供专注建议');

          for (final recommendation in recommendations) {
            // 验证建议的完整性
            expect(recommendation.type, isNotEmpty, reason: '建议应该有类型');
            expect(recommendation.message, isNotEmpty, reason: '建议应该有消息内容');
            expect(
              recommendation.recommendedMinutes,
              greaterThan(0),
              reason: '建议的专注时长应该大于0',
            );
            expect(recommendation.bestHours, isNotEmpty, reason: '应该提供最佳时间段');
            expect(
              recommendation.confidence,
              inInclusiveRange(0.0, 1.0),
              reason: '置信度应该在0-1之间',
            );
            expect(recommendation.generatedAt, isNotNull, reason: '建议应该有生成时间');

            // 验证时间段的合理性
            for (final hour in recommendation.bestHours) {
              expect(hour, inInclusiveRange(0, 23), reason: '时间段应该在0-23之间');
            }

            // 验证专注时长的合理性
            expect(
              recommendation.recommendedMinutes,
              inInclusiveRange(5, 120),
              reason: '建议的专注时长应该在5-120分钟之间',
            );
          }
        }
      },
    );

    test(
      '**Feature: prvin-integrated-calendar, Property 22: AI效率建议** - 不同时间段应该有不同的建议特征',
      () async {
        final faker = Faker();

        for (var i = 0; i < 50; i++) {
          final userId = faker.guid.guid();

          final recommendations = await repository.getFocusRecommendations(
            userId,
          );

          // 查找不同类型的建议
          final morningRecommendations = recommendations
              .where(
                (r) =>
                    r.type.contains('morning') ||
                    r.bestHours.any((h) => h >= 9 && h <= 11),
              )
              .toList();

          final afternoonRecommendations = recommendations
              .where(
                (r) =>
                    r.type.contains('afternoon') ||
                    r.bestHours.any((h) => h >= 14 && h <= 16),
              )
              .toList();

          final pomodoroRecommendations = recommendations
              .where((r) => r.type.contains('pomodoro'))
              .toList();

          // 验证建议的多样性
          final uniqueTypes = recommendations.map((r) => r.type).toSet();
          expect(
            uniqueTypes.length,
            greaterThanOrEqualTo(1),
            reason: '应该有不同类型的建议',
          );

          // 验证番茄钟建议的特征
          for (final pomodoro in pomodoroRecommendations) {
            expect(
              pomodoro.recommendedMinutes,
              inInclusiveRange(20, 30),
              reason: '番茄钟建议应该在20-30分钟范围内',
            );
            expect(
              pomodoro.confidence,
              greaterThanOrEqualTo(0.8),
              reason: '番茄钟建议应该有较高置信度',
            );
          }

          // 验证上午建议的特征
          for (final morning in morningRecommendations) {
            expect(
              morning.bestHours.any((h) => h >= 9 && h <= 11),
              isTrue,
              reason: '上午建议应该包含上午时间段',
            );
            expect(
              morning.recommendedMinutes,
              greaterThanOrEqualTo(30),
              reason: '上午建议通常时长较长',
            );
          }
        }
      },
    );

    test(
      '**Feature: prvin-integrated-calendar, Property 22: AI效率建议** - 建议消息应该清晰且可操作',
      () async {
        final faker = Faker();

        for (var i = 0; i < 50; i++) {
          final userId = faker.guid.guid();

          final recommendations = await repository.getFocusRecommendations(
            userId,
          );

          for (final recommendation in recommendations) {
            final message = recommendation.message;

            // 验证消息的基本质量
            expect(message.length, greaterThan(10), reason: '建议消息应该有足够的信息量');
            expect(message.length, lessThan(200), reason: '建议消息应该简洁明了');

            // 验证消息包含关键信息
            final containsTimeInfo =
                message.contains('时间') ||
                message.contains('分钟') ||
                message.contains('点') ||
                message.contains('time') ||
                message.contains('minute');

            final containsActionInfo =
                message.contains('建议') ||
                message.contains('适合') ||
                message.contains('使用') ||
                message.contains('recommend') ||
                message.contains('suggest');

            expect(
              containsTimeInfo || containsActionInfo,
              isTrue,
              reason: '建议消息应该包含时间或行动信息: $message',
            );
          }
        }
      },
    );

    test(
      '**Feature: prvin-integrated-calendar, Property 22: AI效率建议** - 建议的时间段应该合理分布',
      () async {
        final faker = Faker();

        for (var i = 0; i < 30; i++) {
          final userId = faker.guid.guid();

          final recommendations = await repository.getFocusRecommendations(
            userId,
          );

          // 收集所有建议的时间段
          final allHours = <int>[];
          for (final recommendation in recommendations) {
            allHours.addAll(recommendation.bestHours);
          }

          if (allHours.isNotEmpty) {
            // 验证时间段的分布
            final uniqueHours = allHours.toSet();

            // 应该覆盖工作时间段
            final hasWorkingHours = uniqueHours.any((h) => h >= 9 && h <= 17);
            expect(hasWorkingHours, isTrue, reason: '建议应该包含工作时间段');

            // 不应该过度集中在某个时间段
            final hourCounts = <int, int>{};
            for (final hour in allHours) {
              hourCounts[hour] = (hourCounts[hour] ?? 0) + 1;
            }

            final maxCount = hourCounts.values.reduce((a, b) => a > b ? a : b);
            final totalCount = allHours.length;

            // 最频繁的时间段不应该超过总数的70%
            expect(
              maxCount / totalCount,
              lessThanOrEqualTo(0.7),
              reason: '建议的时间段不应该过度集中',
            );
          }
        }
      },
    );

    test(
      '**Feature: prvin-integrated-calendar, Property 22: AI效率建议** - 建议应该具有时间一致性',
      () async {
        final faker = Faker();

        for (var i = 0; i < 20; i++) {
          final userId = faker.guid.guid();

          // 多次获取同一用户的建议
          final recommendations1 = await repository.getFocusRecommendations(
            userId,
          );
          final recommendations2 = await repository.getFocusRecommendations(
            userId,
          );

          // 验证建议的一致性
          expect(
            recommendations1.length,
            equals(recommendations2.length),
            reason: '同一用户的建议数量应该一致',
          );

          // 验证核心建议类型的一致性
          final types1 = recommendations1.map((r) => r.type).toSet();
          final types2 = recommendations2.map((r) => r.type).toSet();

          expect(types1, equals(types2), reason: '同一用户的建议类型应该一致');

          // 验证番茄钟建议的一致性（如果存在）
          final pomodoro1 = recommendations1
              .where((r) => r.type.contains('pomodoro'))
              .toList();
          final pomodoro2 = recommendations2
              .where((r) => r.type.contains('pomodoro'))
              .toList();

          if (pomodoro1.isNotEmpty && pomodoro2.isNotEmpty) {
            expect(
              pomodoro1.first.recommendedMinutes,
              equals(pomodoro2.first.recommendedMinutes),
              reason: '番茄钟建议的时长应该一致',
            );
          }
        }
      },
    );
  });
}

/// 模拟AI本地数据源
class MockAILocalDataSource implements AILocalDataSource {
  @override
  Future<void> clearExpiredData(Duration olderThan) async {}

  @override
  Future<List<Map<String, dynamic>>> getPomodoroSessions(
    String userId,
    DateRange period,
  ) async {
    return [];
  }

  @override
  Future<List<Task>> getTasksInPeriod(String userId, DateRange period) async {
    return [];
  }

  @override
  Future<List<Task>> getUserTasks(String userId) async {
    return [];
  }

  @override
  Future<List<AnalyticsData>> getHistoricalAnalytics(
    String userId,
    DateRange period,
  ) async {
    return [];
  }

  @override
  Future<void> saveAnalyticsData(AnalyticsData data) async {}
}
