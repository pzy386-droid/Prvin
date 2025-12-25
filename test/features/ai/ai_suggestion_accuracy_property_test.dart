import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prvin/features/ai/data/datasources/ai_local_datasource.dart';
import 'package:prvin/features/ai/data/repositories/ai_analytics_repository_impl.dart';
import 'package:prvin/features/ai/domain/entities/analytics_data.dart';
import 'package:prvin/features/ai/domain/services/ai_suggestion_service.dart';
import 'package:prvin/features/task_management/domain/entities/task.dart';

/// **Feature: prvin-integrated-calendar, Property 6: AI建议准确性**
/// **验证需求: 需求 2.2**
///
/// 对于任何任务内容输入，AI应该提供相关的标签、分类和时间安排建议
void main() {
  group('AI建议准确性属性测试', () {
    late AISuggestionService aiSuggestionService;
    late MockAILocalDataSource mockDataSource;

    setUp(() {
      mockDataSource = MockAILocalDataSource();
      final repository = AIAnalyticsRepositoryImpl(mockDataSource);
      aiSuggestionService = AISuggestionService(repository);
    });

    test(
      '**Feature: prvin-integrated-calendar, Property 6: AI建议准确性** - 对于任何任务标题，AI应该提供相关的标签和分类建议',
      () async {
        final faker = Faker();

        // 运行100次属性测试
        for (var i = 0; i < 100; i++) {
          // 生成随机任务标题
          final taskTitle = _generateRandomTaskTitle(faker);

          // 获取AI建议
          final suggestion = await aiSuggestionService
              .getTaskCreationSuggestions(taskTitle);

          // 验证建议的基本属性
          expect(
            suggestion.suggestedTags,
            isNotEmpty,
            reason: '任务标题"$taskTitle"应该有标签建议',
          );
          expect(
            suggestion.suggestedCategory,
            isNotNull,
            reason: '任务标题"$taskTitle"应该有分类建议',
          );
          expect(
            suggestion.confidence,
            inInclusiveRange(0.0, 1.0),
            reason: '置信度应该在0-1之间',
          );
          expect(suggestion.reasoning, isNotEmpty, reason: '应该提供推理说明');

          // 验证建议的相关性
          _validateSuggestionRelevance(taskTitle, suggestion);
        }
      },
    );

    test(
      '**Feature: prvin-integrated-calendar, Property 6: AI建议准确性** - 工作相关任务应该被正确分类',
      () async {
        final workKeywords = [
          '会议',
          '项目',
          '报告',
          '开发',
          '设计',
          'meeting',
          'project',
          'development',
        ];

        for (var i = 0; i < 50; i++) {
          final keyword = workKeywords[i % workKeywords.length];
          final taskTitle = '$keyword相关任务$i';

          final suggestion = await aiSuggestionService
              .getTaskCreationSuggestions(taskTitle);

          // 工作相关任务应该被分类为工作类别
          expect(
            suggestion.suggestedCategory,
            equals(TaskCategory.work),
            reason: '包含"$keyword"的任务应该被分类为工作',
          );

          // 应该包含工作相关的标签
          final hasWorkRelatedTag = suggestion.suggestedTags.any(
            (tag) => ['important', 'planning', 'communication'].contains(tag),
          );
          expect(hasWorkRelatedTag, isTrue, reason: '工作任务应该包含相关标签');
        }
      },
    );

    test(
      '**Feature: prvin-integrated-calendar, Property 6: AI建议准确性** - 学习相关任务应该被正确分类',
      () async {
        final studyKeywords = [
          '学习',
          '课程',
          '考试',
          '研究',
          'study',
          'course',
          'research',
        ];

        for (var i = 0; i < 50; i++) {
          final keyword = studyKeywords[i % studyKeywords.length];
          final taskTitle = '$keyword任务$i';

          final suggestion = await aiSuggestionService
              .getTaskCreationSuggestions(taskTitle);

          expect(
            suggestion.suggestedCategory,
            equals(TaskCategory.study),
            reason: '包含"$keyword"的任务应该被分类为学习',
          );
        }
      },
    );

    test(
      '**Feature: prvin-integrated-calendar, Property 6: AI建议准确性** - 空标题应该提供默认建议',
      () async {
        for (var i = 0; i < 20; i++) {
          const emptyTitle = '';

          final suggestion = await aiSuggestionService
              .getTaskCreationSuggestions(emptyTitle);

          // 空标题应该有默认建议
          expect(suggestion.suggestedTags, isNotEmpty, reason: '空标题应该提供默认标签建议');
          expect(
            suggestion.suggestedCategory,
            equals(TaskCategory.other),
            reason: '空标题应该默认分类为其他',
          );
          expect(suggestion.confidence, lessThan(0.5), reason: '空标题的置信度应该较低');
        }
      },
    );

    test(
      '**Feature: prvin-integrated-calendar, Property 6: AI建议准确性** - 建议数量应该合理',
      () async {
        final faker = Faker();

        for (var i = 0; i < 100; i++) {
          final taskTitle = faker.lorem.sentence();

          final suggestion = await aiSuggestionService
              .getTaskCreationSuggestions(taskTitle);

          // 标签建议数量应该合理（1-5个）
          expect(
            suggestion.suggestedTags.length,
            inInclusiveRange(1, 5),
            reason: '标签建议数量应该在1-5个之间',
          );

          // 不应该有重复标签
          final uniqueTags = suggestion.suggestedTags.toSet();
          expect(
            uniqueTags.length,
            equals(suggestion.suggestedTags.length),
            reason: '不应该有重复的标签建议',
          );
        }
      },
    );
  });
}

/// 生成随机任务标题
String _generateRandomTaskTitle(Faker faker) {
  final templates = [
    '${faker.lorem.word()}会议',
    '完成${faker.lorem.word()}项目',
    '学习${faker.lorem.word()}',
    '${faker.lorem.word()}运动',
    '和${faker.person.name()}聚会',
    '购买${faker.lorem.word()}',
    '${faker.lorem.word()}检查',
    faker.lorem.sentence(),
  ];

  return templates[faker.randomGenerator.integer(templates.length)];
}

/// 验证建议的相关性
void _validateSuggestionRelevance(String taskTitle, TaskSuggestion suggestion) {
  final titleLower = taskTitle.toLowerCase();

  // 如果标题包含工作关键词，分类应该相关
  final workKeywords = ['会议', '项目', '报告', '工作', 'meeting', 'project', 'work'];
  final hasWorkKeyword = workKeywords.any(
    (keyword) => titleLower.contains(keyword.toLowerCase()),
  );

  if (hasWorkKeyword) {
    expect(
      suggestion.suggestedCategory,
      equals(TaskCategory.work),
      reason: '包含工作关键词的任务应该被分类为工作',
    );
  }

  // 如果标题包含学习关键词，分类应该相关
  final studyKeywords = ['学习', '课程', '考试', 'study', 'course', 'exam'];
  final hasStudyKeyword = studyKeywords.any(
    (keyword) => titleLower.contains(keyword.toLowerCase()),
  );

  if (hasStudyKeyword) {
    expect(
      suggestion.suggestedCategory,
      equals(TaskCategory.study),
      reason: '包含学习关键词的任务应该被分类为学习',
    );
  }

  // 如果标题包含健康关键词，分类应该相关
  final healthKeywords = ['运动', '健身', '医院', 'exercise', 'fitness', 'hospital'];
  final hasHealthKeyword = healthKeywords.any(
    (keyword) => titleLower.contains(keyword.toLowerCase()),
  );

  if (hasHealthKeyword) {
    expect(
      suggestion.suggestedCategory,
      equals(TaskCategory.health),
      reason: '包含健康关键词的任务应该被分类为健康',
    );
  }
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
