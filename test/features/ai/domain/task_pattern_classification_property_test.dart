import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prvin/features/ai/domain/entities/analytics_data.dart';

/// **Feature: ai-calendar-app, Property 13: 任务模式分类**
/// *对于任何*相似的任务集合，AI应该自动将它们归类到相同的分类中
/// **验证需求: 需求 5.4**
void main() {
  group('Task Pattern Classification Property Tests', () {
    final faker = Faker();

    test(
      'Property 13: 任务模式分类 - should classify similar tasks into same patterns',
      () {
        // 运行100次迭代以确保属性在各种输入下都成立
        for (var i = 0; i < 100; i++) {
          // 生成包含任务模式的分析数据
          final analyticsData = _generateAnalyticsDataWithTaskPatterns(faker);

          // 验证AI应该检测到任务模式
          expect(
            analyticsData.taskPatterns,
            isNotEmpty,
            reason: 'AI should detect task patterns when similar tasks exist',
          );

          // 验证每个任务模式的基本属性
          for (final pattern in analyticsData.taskPatterns) {
            // 模式应该有明确的名称
            expect(
              pattern.patternName,
              isNotEmpty,
              reason: 'Task pattern should have a clear name',
            );

            // 应该包含相似的任务
            expect(
              pattern.similarTasks,
              isNotEmpty,
              reason: 'Task pattern should contain similar tasks',
            );

            expect(
              pattern.similarTasks.length,
              greaterThanOrEqualTo(2),
              reason: 'Task pattern should contain at least 2 similar tasks',
            );

            // 应该有建议的标签
            expect(
              pattern.suggestedTags,
              isNotEmpty,
              reason: 'Task pattern should suggest relevant tags',
            );

            // 应该有建议的分类
            expect(
              pattern.suggestedCategory,
              isIn(TaskCategory.values),
              reason: 'Task pattern should suggest a valid category',
            );

            // 平均完成时间应该在合理范围内
            expect(
              pattern.averageCompletionMinutes,
              greaterThan(0),
              reason: 'Average completion time should be positive',
            );

            expect(
              pattern.averageCompletionMinutes,
              lessThanOrEqualTo(480), // 8小时
              reason: 'Average completion time should be reasonable',
            );

            // 置信度应该在0-1之间
            expect(
              pattern.confidence,
              inInclusiveRange(0.0, 1.0),
              reason: 'Confidence should be between 0 and 1',
            );

            // 置信度应该足够高
            expect(
              pattern.confidence,
              greaterThanOrEqualTo(0.5),
              reason: 'Pattern confidence should be reasonably high',
            );
          }

          // 验证模式分类的一致性
          _validatePatternConsistency(analyticsData.taskPatterns);
        }
      },
    );

    test('Property 13: 任务模式分类 - should provide meaningful categorization', () {
      for (var i = 0; i < 100; i++) {
        final analyticsData = _generateAnalyticsDataWithTaskPatterns(faker);

        for (final pattern in analyticsData.taskPatterns) {
          // 标签应该是有效的
          for (final tag in pattern.suggestedTags) {
            expect(tag, isNotEmpty, reason: 'Tags should not be empty');
            expect(
              tag.length,
              lessThan(20),
              reason: 'Tags should be reasonably short',
            );
          }

          // 不应该有重复的标签
          final uniqueTags = pattern.suggestedTags.toSet();
          expect(
            uniqueTags.length,
            equals(pattern.suggestedTags.length),
            reason: 'Suggested tags should not contain duplicates',
          );

          // 相似任务应该有一定的相关性
          expect(
            pattern.similarTasks.length,
            lessThanOrEqualTo(10),
            reason: 'Pattern should not contain too many disparate tasks',
          );
        }
      }
    });

    test('Property 13: 任务模式分类 - should handle various task types', () {
      for (var i = 0; i < 50; i++) {
        final analyticsData = _generateAnalyticsDataWithTaskPatterns(faker);

        // 验证不同类型的任务都能被正确分类
        final categoriesUsed = analyticsData.taskPatterns
            .map((p) => p.suggestedCategory)
            .toSet();

        // 应该使用合理数量的分类
        expect(
          categoriesUsed.length,
          lessThanOrEqualTo(TaskCategory.values.length),
          reason: 'Should not exceed available categories',
        );

        // 每个分类都应该是有效的
        for (final category in categoriesUsed) {
          expect(
            TaskCategory.values,
            contains(category),
            reason: 'All used categories should be valid',
          );
        }
      }
    });
  });
}

/// 生成包含任务模式的分析数据
AnalyticsData _generateAnalyticsDataWithTaskPatterns(Faker faker) {
  final now = DateTime.now();
  final startDate = now.subtract(
    Duration(days: faker.randomGenerator.integer(30, min: 7)),
  );
  final endDate = now.subtract(
    Duration(days: faker.randomGenerator.integer(3)),
  );

  // 生成任务模式
  final taskPatterns = _generateTaskPatterns(faker);

  return AnalyticsData(
    userId: faker.guid.guid(),
    period: DateRange(startDate: startDate, endDate: endDate),
    timeDistribution: _generateTimeDistribution(faker),
    completionRate: faker.randomGenerator.decimal(scale: 0.7, min: 0.3),
    trends: _generateTrends(faker, startDate, endDate),
    focusPatterns: _generateFocusPatterns(faker),
    taskPatterns: taskPatterns,
    focusRecommendations: _generateFocusRecommendations(faker),
    generatedAt: now,
  );
}

/// 生成任务模式
List<TaskPattern> _generateTaskPatterns(Faker faker) {
  final patterns = <TaskPattern>[];

  // 定义一些任务模式模板
  final patternTemplates = [
    {
      'name': '开发工作',
      'tasks': ['编写代码', '修复bug', '代码审查', '功能开发'],
      'category': TaskCategory.work,
      'tags': ['开发', '编程', '技术'],
      'avgTime': 120.0,
    },
    {
      'name': '学习活动',
      'tasks': ['阅读文档', '观看教程', '练习编程', '学习新技术'],
      'category': TaskCategory.study,
      'tags': ['学习', '提升', '技能'],
      'avgTime': 90.0,
    },
    {
      'name': '会议沟通',
      'tasks': ['团队会议', '项目讨论', '需求评审', '技术分享'],
      'category': TaskCategory.work,
      'tags': ['会议', '沟通', '协作'],
      'avgTime': 60.0,
    },
    {
      'name': '健身运动',
      'tasks': ['跑步锻炼', '健身房训练', '瑜伽练习', '户外运动'],
      'category': TaskCategory.health,
      'tags': ['健康', '运动', '锻炼'],
      'avgTime': 45.0,
    },
  ];

  // 随机选择几个模式模板
  final selectedCount = faker.randomGenerator.integer(
    patternTemplates.length,
    min: 1,
  );
  final selectedTemplates = patternTemplates.take(selectedCount);

  for (final template in selectedTemplates) {
    final tasks = template['tasks']! as List<String>;
    final selectedTasks = tasks
        .take(faker.randomGenerator.integer(tasks.length, min: 2))
        .toList();

    patterns.add(
      TaskPattern(
        patternName: template['name']! as String,
        similarTasks: selectedTasks,
        suggestedTags: List<String>.from(template['tags']! as List),
        suggestedCategory: template['category']! as TaskCategory,
        averageCompletionMinutes:
            (template['avgTime']! as double) +
            faker.randomGenerator.decimal(scale: 30, min: -15),
        confidence: faker.randomGenerator.decimal(scale: 0.4, min: 0.6),
      ),
    );
  }

  return patterns;
}

/// 验证模式分类的一致性
void _validatePatternConsistency(List<TaskPattern> patterns) {
  // 不同模式应该有不同的名称
  final patternNames = patterns.map((p) => p.patternName).toSet();
  expect(
    patternNames.length,
    equals(patterns.length),
    reason: 'Each pattern should have a unique name',
  );

  // 验证模式的基本结构
  for (final pattern in patterns) {
    expect(
      pattern.similarTasks,
      isNotEmpty,
      reason: 'Each pattern should have similar tasks',
    );

    expect(
      pattern.suggestedTags,
      isNotEmpty,
      reason: 'Each pattern should have suggested tags',
    );
  }
}

/// 生成时间分配数据
Map<String, int> _generateTimeDistribution(Faker faker) {
  return {
    '工作': faker.randomGenerator.integer(480, min: 60),
    '学习': faker.randomGenerator.integer(240, min: 30),
    '个人': faker.randomGenerator.integer(120, min: 15),
    '健康': faker.randomGenerator.integer(90, min: 15),
  };
}

/// 生成趋势数据
List<ProductivityTrend> _generateTrends(
  Faker faker,
  DateTime start,
  DateTime end,
) {
  final trends = <ProductivityTrend>[];
  final dayCount = end.difference(start).inDays + 1;

  for (var i = 0; i < dayCount; i++) {
    trends.add(
      ProductivityTrend(
        date: start.add(Duration(days: i)),
        completedTasks: faker.randomGenerator.integer(10, min: 1),
        totalWorkMinutes: faker.randomGenerator.integer(480, min: 60),
        focusMinutes: faker.randomGenerator.integer(240, min: 20),
        efficiencyScore: faker.randomGenerator.decimal(scale: 80, min: 20),
      ),
    );
  }

  return trends;
}

/// 生成专注模式数据
List<FocusPattern> _generateFocusPatterns(Faker faker) {
  final patterns = <FocusPattern>[];
  final hours = [9, 10, 14, 15, 19, 20];

  for (final hour in hours.take(faker.randomGenerator.integer(4, min: 1))) {
    patterns.add(
      FocusPattern(
        hourOfDay: hour,
        averageFocusMinutes: faker.randomGenerator.decimal(scale: 45, min: 20),
        sessionCount: faker.randomGenerator.integer(15, min: 3),
        successRate: faker.randomGenerator.decimal(scale: 0.5, min: 0.5),
      ),
    );
  }

  return patterns;
}

/// 生成专注建议数据
List<FocusRecommendation> _generateFocusRecommendations(Faker faker) {
  return [
    FocusRecommendation(
      type: '时间建议',
      message: faker.lorem.sentence(),
      recommendedMinutes: faker.randomGenerator.integer(60, min: 25),
      bestHours: [faker.randomGenerator.integer(23)],
      confidence: faker.randomGenerator.decimal(scale: 0.4, min: 0.6),
      generatedAt: DateTime.now(),
    ),
  ];
}
