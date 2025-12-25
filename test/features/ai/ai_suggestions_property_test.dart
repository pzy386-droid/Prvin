import 'package:flutter_test/flutter_test.dart';
import 'package:prvin/features/ai/data/repositories/ai_analytics_repository_impl.dart';
import 'package:prvin/features/task_management/domain/entities/task.dart';

/// **Feature: prvin-integrated-calendar, Property 6: AI建议准确性**
///
/// 验证AI建议功能的准确性和一致性
void main() {
  group('AI建议准确性属性测试', () {
    late AIAnalyticsRepositoryImpl repository;

    setUp(() {
      repository = const AIAnalyticsRepositoryImpl();
    });

    test(
      '**Feature: prvin-integrated-calendar, Property 6: AI建议准确性** - 标签建议应该与任务内容相关',
      () async {
        // 测试用例：工作相关任务
        final workTasks = [
          '团队会议讨论项目进度',
          '代码评审和优化',
          '编写技术文档',
          '项目需求分析',
          '开发新功能模块',
        ];

        for (final taskTitle in workTasks) {
          final suggestions = await repository.getTagSuggestions(taskTitle);

          // 验证建议不为空
          expect(suggestions, isNotEmpty, reason: '工作任务应该有标签建议: $taskTitle');

          // 验证建议数量合理
          expect(
            suggestions.length,
            lessThanOrEqualTo(5),
            reason: '标签建议数量应该不超过5个: $taskTitle',
          );

          // 验证包含工作相关标签
          final hasWorkRelatedTag = suggestions.any(
            (tag) => [
              '工作',
              '会议',
              '项目',
              '开发',
              '文档',
              'work',
              'meeting',
              'project',
              'dev',
              'docs',
            ].contains(tag.toLowerCase()),
          );

          expect(
            hasWorkRelatedTag,
            isTrue,
            reason: '工作任务应该包含工作相关标签: $taskTitle, 建议: $suggestions',
          );
        }
      },
    );

    test(
      '**Feature: prvin-integrated-calendar, Property 6: AI建议准确性** - 分类建议应该准确匹配任务类型',
      () async {
        // 测试用例：不同类型的任务
        final testCases = {
          '健身房锻炼': TaskCategory.health,
          '跑步运动': TaskCategory.health,
          '瑜伽练习': TaskCategory.health,
          '团队会议': TaskCategory.work,
          '项目开发': TaskCategory.work,
          '代码评审': TaskCategory.work,
          '阅读技术书籍': TaskCategory.study,
          '学习新技术': TaskCategory.study,
          '研究论文': TaskCategory.study,
          '朋友聚会': TaskCategory.social,
          '家庭聚餐': TaskCategory.social,
          '约会': TaskCategory.social,
          '整理房间': TaskCategory.personal,
          '购物': TaskCategory.personal,
          '休息': TaskCategory.personal,
        };

        for (final entry in testCases.entries) {
          final taskTitle = entry.key;
          final expectedCategory = entry.value;

          final suggestedCategory = await repository.getCategorySuggestion(
            taskTitle,
          );

          expect(
            suggestedCategory,
            equals(expectedCategory),
            reason:
                '任务 "$taskTitle" 应该被分类为 $expectedCategory，但得到 $suggestedCategory',
          );
        }
      },
    );

    test(
      '**Feature: prvin-integrated-calendar, Property 6: AI建议准确性** - 相似任务应该得到相似建议',
      () async {
        // 测试相似任务的建议一致性
        final similarTaskGroups = [
          ['团队会议', '项目会议', '需求讨论会议'],
          ['跑步', '慢跑', '晨跑'],
          ['阅读', '看书', '学习资料'],
          ['购物', '买东西', '采购'],
        ];

        for (final taskGroup in similarTaskGroups) {
          final allSuggestions = <List<String>>[];
          final allCategories = <TaskCategory>[];

          // 获取所有相似任务的建议
          for (final task in taskGroup) {
            final suggestions = await repository.getTagSuggestions(task);
            final category = await repository.getCategorySuggestion(task);

            allSuggestions.add(suggestions);
            allCategories.add(category);
          }

          // 验证分类一致性
          final firstCategory = allCategories.first;
          for (final category in allCategories) {
            expect(
              category,
              equals(firstCategory),
              reason: '相似任务应该有相同的分类: $taskGroup',
            );
          }

          // 验证标签建议有重叠
          final firstSuggestions = allSuggestions.first.toSet();
          for (final suggestions in allSuggestions.skip(1)) {
            final overlap = firstSuggestions.intersection(suggestions.toSet());
            expect(
              overlap.isNotEmpty,
              isTrue,
              reason: '相似任务应该有重叠的标签建议: $taskGroup',
            );
          }
        }
      },
    );

    test(
      '**Feature: prvin-integrated-calendar, Property 6: AI建议准确性** - 空输入和异常输入处理',
      () async {
        // 测试边界情况
        final edgeCases = [
          '', // 空字符串
          '   ', // 只有空格
          'a', // 单个字符
          '123', // 纯数字
          r'!@#$%', // 特殊字符
          'x' * 100, // 超长字符串
        ];

        for (final input in edgeCases) {
          // 标签建议应该不抛异常
          final suggestions = await repository.getTagSuggestions(input);
          expect(
            suggestions,
            isA<List<String>>(),
            reason: '标签建议应该返回字符串列表，即使输入异常: "$input"',
          );

          // 分类建议应该不抛异常
          final category = await repository.getCategorySuggestion(input);
          expect(
            category,
            isA<TaskCategory>(),
            reason: '分类建议应该返回有效分类，即使输入异常: "$input"',
          );

          // 对于无意义输入，应该返回默认分类
          if (input.trim().isEmpty || input.length < 2) {
            expect(
              category,
              equals(TaskCategory.other),
              reason: '无意义输入应该返回"其他"分类: "$input"',
            );
          }
        }
      },
    );

    test(
      '**Feature: prvin-integrated-calendar, Property 6: AI建议准确性** - 多语言支持',
      () async {
        // 测试中英文混合输入
        final multiLanguageTasks = {
          'meeting with team': TaskCategory.work,
          'exercise at gym': TaskCategory.health,
          'study English': TaskCategory.study,
          '工作会议': TaskCategory.work,
          '健身锻炼': TaskCategory.health,
          '学习编程': TaskCategory.study,
          'work 项目': TaskCategory.work,
          'study 学习': TaskCategory.study,
        };

        for (final entry in multiLanguageTasks.entries) {
          final taskTitle = entry.key;
          final expectedCategory = entry.value;

          final suggestions = await repository.getTagSuggestions(taskTitle);
          final category = await repository.getCategorySuggestion(taskTitle);

          // 验证多语言任务也能得到合理建议
          expect(suggestions, isNotEmpty, reason: '多语言任务应该有标签建议: $taskTitle');

          expect(
            category,
            equals(expectedCategory),
            reason: '多语言任务分类应该准确: $taskTitle',
          );
        }
      },
    );

    test(
      '**Feature: prvin-integrated-calendar, Property 6: AI建议准确性** - 性能要求',
      () async {
        // 测试AI建议的响应时间
        const testTask = '团队会议讨论项目进度';

        // 标签建议性能测试
        final tagStopwatch = Stopwatch()..start();
        final suggestions = await repository.getTagSuggestions(testTask);
        tagStopwatch.stop();

        expect(
          tagStopwatch.elapsedMilliseconds,
          lessThan(1000),
          reason: '标签建议应该在1秒内完成',
        );
        expect(suggestions, isNotEmpty, reason: '标签建议应该返回结果');

        // 分类建议性能测试
        final categoryStopwatch = Stopwatch()..start();
        final category = await repository.getCategorySuggestion(testTask);
        categoryStopwatch.stop();

        expect(
          categoryStopwatch.elapsedMilliseconds,
          lessThan(1000),
          reason: '分类建议应该在1秒内完成',
        );
        expect(category, isNotNull, reason: '分类建议应该返回结果');
      },
    );

    test(
      '**Feature: prvin-integrated-calendar, Property 6: AI建议准确性** - 建议质量评估',
      () async {
        // 测试建议的质量和相关性
        final qualityTestCases = [
          {
            'task': '编写Flutter应用的用户界面',
            'expectedTags': ['开发', '编程', 'Flutter', 'UI', '工作'],
            'category': TaskCategory.work,
          },
          {
            'task': '晨跑30分钟保持健康',
            'expectedTags': ['运动', '跑步', '健康', '锻炼'],
            'category': TaskCategory.health,
          },
          {
            'task': '阅读《深入理解计算机系统》',
            'expectedTags': ['学习', '阅读', '计算机', '书籍'],
            'category': TaskCategory.study,
          },
        ];

        for (final testCase in qualityTestCases) {
          final task = testCase['task']! as String;
          final expectedTags = testCase['expectedTags']! as List<String>;
          final expectedCategory = testCase['category']! as TaskCategory;

          final suggestions = await repository.getTagSuggestions(task);
          final category = await repository.getCategorySuggestion(task);

          // 验证分类准确性
          expect(category, equals(expectedCategory), reason: '任务分类应该准确: $task');

          // 验证标签相关性（至少有一个期望的标签）
          final hasRelevantTag = suggestions.any(
            (suggestion) => expectedTags.any(
              (expected) =>
                  suggestion.toLowerCase().contains(expected.toLowerCase()) ||
                  expected.toLowerCase().contains(suggestion.toLowerCase()),
            ),
          );

          expect(
            hasRelevantTag,
            isTrue,
            reason: '应该包含相关标签。任务: $task, 期望: $expectedTags, 实际: $suggestions',
          );
        }
      },
    );
  });
}
