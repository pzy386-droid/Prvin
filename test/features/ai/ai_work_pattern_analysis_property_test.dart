import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prvin/features/ai/data/datasources/ai_local_datasource.dart';
import 'package:prvin/features/ai/data/repositories/ai_analytics_repository_impl.dart';
import 'package:prvin/features/ai/domain/entities/analytics_data.dart';
import 'package:prvin/features/task_management/domain/entities/task.dart';

/// **Feature: prvin-integrated-calendar, Property 21: AI工作模式分析**
/// **验证需求: 需求 7.1**
///
/// 对于任何用户数据集，AI应该分析工作模式并生成个性化报告
void main() {
  group('AI工作模式分析属性测试', () {
    late AIAnalyticsRepositoryImpl repository;
    late MockAILocalDataSource mockDataSource;

    setUp(() {
      mockDataSource = MockAILocalDataSource();
      repository = AIAnalyticsRepositoryImpl(mockDataSource);
    });

    test(
      '**Feature: prvin-integrated-calendar, Property 21: AI工作模式分析** - 对于任何用户数据，应该生成包含完整分析的报告',
      () async {
        final faker = Faker();

        // 运行100次属性测试
        for (var i = 0; i < 100; i++) {
          final userId = faker.guid.guid();
          final period = _generateRandomDateRange(faker);

          // 模拟用户任务数据
          final tasks = _generateRandomTasks(
            faker,
            period,
            5 + faker.randomGenerator.integer(20),
          );
          mockDataSource.setMockTasks(tasks);

          // 生成分析报告
          final analytics = await repository.generateAnalytics(
            userId: userId,
            period: period,
          );

          // 验证报告的完整性
          expect(analytics.userId, equals(userId), reason: '报告应该包含正确的用户ID');
          expect(analytics.period, equals(period), reason: '报告应该包含正确的时间范围');
          expect(analytics.generatedAt, isNotNull, reason: '报告应该有生成时间');

          // 验证时间分配分析
          expect(analytics.timeDistribution, isNotEmpty, reason: '应该包含时间分配分析');
          expect(
            analytics.completionRate,
            inInclusiveRange(0.0, 1.0),
            reason: '完成率应该在0-1之间',
          );

          // 验证趋势分析
          expect(analytics.trends, isNotEmpty, reason: '应该包含生产力趋势分析');
          expect(
            analytics.trends.length,
            equals(period.dayCount),
            reason: '趋势数据应该覆盖整个分析周期',
          );

          // 验证专注模式分析
          expect(analytics.focusPatterns, isNotEmpty, reason: '应该包含专注模式分析');
          expect(
            analytics.focusPatterns.length,
            equals(24),
            reason: '专注模式应该覆盖24小时',
          );

          // 验证任务模式分析
          expect(
            analytics.taskPatterns,
            isA<List<TaskPattern>>(),
            reason: '应该包含任务模式分析',
          );

          // 验证专注建议
          expect(
            analytics.focusRecommendations,
            isNotEmpty,
            reason: '应该包含专注建议',
          );
        }
      },
    );

    test(
      '**Feature: prvin-integrated-calendar, Property 21: AI工作模式分析** - 时间分配分析应该准确反映任务分布',
      () async {
        final faker = Faker();

        for (var i = 0; i < 50; i++) {
          final userId = faker.guid.guid();
          final period = DateRange(
            startDate: DateTime.now().subtract(const Duration(days: 7)),
            endDate: DateTime.now(),
          );

          // 创建特定分类的任务
          final workTasks = _generateTasksForCategory(
            faker,
            TaskCategory.work,
            5,
          );
          final studyTasks = _generateTasksForCategory(
            faker,
            TaskCategory.study,
            3,
          );
          final personalTasks = _generateTasksForCategory(
            faker,
            TaskCategory.personal,
            2,
          );

          final allTasks = [...workTasks, ...studyTasks, ...personalTasks];
          mockDataSource.setMockTasks(allTasks);

          final analytics = await repository.generateAnalytics(
            userId: userId,
            period: period,
          );

          // 验证时间分配反映了任务分布
          final workMinutes = analytics.timeDistribution['工作'] ?? 0;
          final studyMinutes = analytics.timeDistribution['学习'] ?? 0;
          final personalMinutes = analytics.timeDistribution['个人'] ?? 0;

          // 工作任务最多，应该占用最多时间
          expect(
            workMinutes,
            greaterThanOrEqualTo(studyMinutes),
            reason: '工作任务更多，应该占用更多时间',
          );
          expect(
            workMinutes,
            greaterThanOrEqualTo(personalMinutes),
            reason: '工作任务更多，应该占用更多时间',
          );

          // 总时间应该等于所有分类时间之和
          final totalCalculated = workMinutes + studyMinutes + personalMinutes;
          expect(
            analytics.totalWorkMinutes,
            equals(totalCalculated),
            reason: '总工作时间应该等于各分类时间之和',
          );
        }
      },
    );

    test(
      '**Feature: prvin-integrated-calendar, Property 21: AI工作模式分析** - 完成率计算应该准确',
      () async {
        final faker = Faker();

        for (var i = 0; i < 50; i++) {
          final userId = faker.guid.guid();
          final period = _generateRandomDateRange(faker);

          // 创建已知完成状态的任务
          final completedCount =
              3 + faker.randomGenerator.integer(7); // 3-9个已完成
          final pendingCount = 2 + faker.randomGenerator.integer(5); // 2-6个待办

          final completedTasks = List.generate(
            completedCount,
            (index) => _generateTaskWithStatus(faker, TaskStatus.completed),
          );
          final pendingTasks = List.generate(
            pendingCount,
            (index) => _generateTaskWithStatus(faker, TaskStatus.pending),
          );

          final allTasks = [...completedTasks, ...pendingTasks];
          mockDataSource.setMockTasks(allTasks);

          final analytics = await repository.generateAnalytics(
            userId: userId,
            period: period,
          );

          // 验证完成率计算
          final expectedCompletionRate =
              completedCount / (completedCount + pendingCount);
          expect(
            analytics.completionRate,
            closeTo(expectedCompletionRate, 0.01),
            reason:
                '完成率计算应该准确: 期望${expectedCompletionRate.toStringAsFixed(2)}, 实际${analytics.completionRate.toStringAsFixed(2)}',
          );
        }
      },
    );

    test(
      '**Feature: prvin-integrated-calendar, Property 21: AI工作模式分析** - 专注模式分析应该覆盖所有时间段',
      () async {
        final faker = Faker();

        for (var i = 0; i < 30; i++) {
          final userId = faker.guid.guid();
          final period = _generateRandomDateRange(faker);

          final tasks = _generateRandomTasks(faker, period, 10);
          mockDataSource.setMockTasks(tasks);

          final analytics = await repository.generateAnalytics(
            userId: userId,
            period: period,
          );

          // 验证专注模式覆盖24小时
          expect(
            analytics.focusPatterns.length,
            equals(24),
            reason: '专注模式应该覆盖24小时',
          );

          // 验证每个时间段的数据完整性
          for (var hour = 0; hour < 24; hour++) {
            final pattern = analytics.focusPatterns.firstWhere(
              (p) => p.hourOfDay == hour,
              orElse: () => throw Exception('缺少$hour点的专注模式数据'),
            );

            expect(pattern.hourOfDay, equals(hour), reason: '专注模式时间应该正确');
            expect(
              pattern.averageFocusMinutes,
              greaterThanOrEqualTo(0),
              reason: '平均专注时间应该非负',
            );
            expect(
              pattern.successRate,
              inInclusiveRange(0.0, 1.0),
              reason: '成功率应该在0-1之间',
            );
            expect(
              pattern.sessionCount,
              greaterThanOrEqualTo(0),
              reason: '会话数应该非负',
            );
          }
        }
      },
    );

    test(
      '**Feature: prvin-integrated-calendar, Property 21: AI工作模式分析** - 生产力趋势应该与时间周期匹配',
      () async {
        final faker = Faker();

        for (var i = 0; i < 50; i++) {
          final userId = faker.guid.guid();
          final period = _generateRandomDateRange(faker);

          final tasks = _generateRandomTasks(faker, period, 15);
          mockDataSource.setMockTasks(tasks);

          final analytics = await repository.generateAnalytics(
            userId: userId,
            period: period,
          );

          // 验证趋势数据与时间周期匹配
          expect(
            analytics.trends.length,
            equals(period.dayCount),
            reason: '趋势数据天数应该与分析周期匹配',
          );

          // 验证趋势数据的时间顺序
          for (
            var dayIndex = 0;
            dayIndex < analytics.trends.length;
            dayIndex++
          ) {
            final trend = analytics.trends[dayIndex];
            final expectedDate = period.startDate.add(Duration(days: dayIndex));

            expect(
              trend.date.year,
              equals(expectedDate.year),
              reason: '趋势数据日期应该正确',
            );
            expect(
              trend.date.month,
              equals(expectedDate.month),
              reason: '趋势数据日期应该正确',
            );
            expect(
              trend.date.day,
              equals(expectedDate.day),
              reason: '趋势数据日期应该正确',
            );

            // 验证趋势数据的合理性
            expect(
              trend.completedTasks,
              greaterThanOrEqualTo(0),
              reason: '完成任务数应该非负',
            );
            expect(
              trend.totalWorkMinutes,
              greaterThanOrEqualTo(0),
              reason: '总工作时间应该非负',
            );
            expect(
              trend.focusMinutes,
              greaterThanOrEqualTo(0),
              reason: '专注时间应该非负',
            );
            expect(
              trend.efficiencyScore,
              inInclusiveRange(0.0, 100.0),
              reason: '效率评分应该在0-100之间',
            );
          }
        }
      },
    );

    test(
      '**Feature: prvin-integrated-calendar, Property 21: AI工作模式分析** - 空数据集应该生成默认分析',
      () async {
        final faker = Faker();

        for (var i = 0; i < 20; i++) {
          final userId = faker.guid.guid();
          final period = _generateRandomDateRange(faker);

          // 设置空任务列表
          mockDataSource.setMockTasks([]);

          final analytics = await repository.generateAnalytics(
            userId: userId,
            period: period,
          );

          // 验证空数据集的默认行为
          expect(analytics.timeDistribution, isEmpty, reason: '空数据集的时间分配应该为空');
          expect(analytics.completionRate, equals(0.0), reason: '空数据集的完成率应该为0');
          expect(
            analytics.trends.length,
            equals(period.dayCount),
            reason: '即使没有数据，也应该生成趋势框架',
          );
          expect(
            analytics.focusPatterns.length,
            equals(24),
            reason: '即使没有数据，也应该生成专注模式框架',
          );
        }
      },
    );
  });
}

/// 生成随机日期范围
DateRange _generateRandomDateRange(Faker faker) {
  final endDate = DateTime.now();
  final dayCount = 7 + faker.randomGenerator.integer(23); // 7-30天
  final startDate = endDate.subtract(Duration(days: dayCount));

  return DateRange(startDate: startDate, endDate: endDate);
}

/// 生成随机任务列表
List<Task> _generateRandomTasks(Faker faker, DateRange period, int count) {
  final tasks = <Task>[];
  const categories = TaskCategory.values;
  const statuses = TaskStatus.values;

  for (var i = 0; i < count; i++) {
    final startTime = _generateRandomTimeInPeriod(faker, period);
    final duration = Duration(
      minutes: 30 + faker.randomGenerator.integer(120),
    ); // 30-150分钟

    tasks.add(
      Task(
        id: faker.guid.guid(),
        title: faker.lorem.sentence(),
        description: faker.lorem.sentences(2).join(' '),
        startTime: startTime,
        endTime: startTime.add(duration),
        tags: List.generate(
          faker.randomGenerator.integer(4),
          (index) => faker.lorem.word(),
        ),
        priority: TaskPriority
            .values[faker.randomGenerator.integer(TaskPriority.values.length)],
        status: statuses[faker.randomGenerator.integer(statuses.length)],
        category: categories[faker.randomGenerator.integer(categories.length)],
        createdAt: startTime.subtract(
          Duration(hours: faker.randomGenerator.integer(24)),
        ),
        updatedAt: startTime,
      ),
    );
  }

  return tasks;
}

/// 生成特定分类的任务
List<Task> _generateTasksForCategory(
  Faker faker,
  TaskCategory category,
  int count,
) {
  final tasks = <Task>[];

  for (var i = 0; i < count; i++) {
    final startTime = DateTime.now().subtract(
      Duration(hours: faker.randomGenerator.integer(168)),
    ); // 过去一周
    final duration = Duration(
      minutes: 60 + faker.randomGenerator.integer(60),
    ); // 60-120分钟

    tasks.add(
      Task(
        id: faker.guid.guid(),
        title: '${category.label}任务$i',
        startTime: startTime,
        endTime: startTime.add(duration),
        category: category,
        status: TaskStatus.completed,
        createdAt: startTime,
        updatedAt: startTime,
      ),
    );
  }

  return tasks;
}

/// 生成特定状态的任务
Task _generateTaskWithStatus(Faker faker, TaskStatus status) {
  final startTime = DateTime.now().subtract(
    Duration(hours: faker.randomGenerator.integer(168)),
  );
  final duration = Duration(minutes: 30 + faker.randomGenerator.integer(90));

  return Task(
    id: faker.guid.guid(),
    title: faker.lorem.sentence(),
    startTime: startTime,
    endTime: startTime.add(duration),
    status: status,
    category: TaskCategory
        .values[faker.randomGenerator.integer(TaskCategory.values.length)],
    createdAt: startTime,
    updatedAt: startTime,
  );
}

/// 在指定时间范围内生成随机时间
DateTime _generateRandomTimeInPeriod(Faker faker, DateRange period) {
  final totalMinutes = period.endDate.difference(period.startDate).inMinutes;
  final randomMinutes = faker.randomGenerator.integer(totalMinutes);

  return period.startDate.add(Duration(minutes: randomMinutes));
}

/// 模拟AI本地数据源
class MockAILocalDataSource implements AILocalDataSource {
  List<Task> _mockTasks = [];

  void setMockTasks(List<Task> tasks) {
    _mockTasks = tasks;
  }

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
    return _mockTasks
        .where(
          (task) =>
              task.startTime.isAfter(
                period.startDate.subtract(const Duration(days: 1)),
              ) &&
              task.endTime.isBefore(
                period.endDate.add(const Duration(days: 1)),
              ),
        )
        .toList();
  }

  @override
  Future<List<Task>> getUserTasks(String userId) async {
    return _mockTasks;
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
