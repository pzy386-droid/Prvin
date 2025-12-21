import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prvin/features/tasks/data/models/task_model.dart';

void main() {
  group('TaskModel Property Tests', () {
    final faker = Faker();

    /// **Feature: ai-calendar-app, Property 4: 任务属性完整性**
    /// 对于任何新创建的任务，应该支持设置开始时间、结束时间、标签和优先级属性
    test('Property 4: Task attribute completeness', () {
      // 运行100次迭代以确保属性测试的充分性
      for (var i = 0; i < 100; i++) {
        // 生成随机任务数据
        final startTime = faker.date.dateTime(minYear: 2024, maxYear: 2025);
        final endTime = startTime.add(
          Duration(
            hours: faker.randomGenerator.integer(8, min: 1),
            minutes: faker.randomGenerator.integer(60),
          ),
        );

        final task = TaskModel(
          id: faker.guid.guid(),
          title: faker.lorem.sentence(),
          description: faker.lorem.sentences(3).join(' '),
          startTime: startTime,
          endTime: endTime,
          tags: List.generate(
            faker.randomGenerator.integer(5),
            (_) => faker.lorem.word(),
          ),
          priority:
              TaskPriority.values[faker.randomGenerator.integer(
                TaskPriority.values.length,
              )],
          status: TaskStatus
              .values[faker.randomGenerator.integer(TaskStatus.values.length)],
          category:
              TaskCategory.values[faker.randomGenerator.integer(
                TaskCategory.values.length,
              )],
          createdAt: faker.date.dateTime(minYear: 2024, maxYear: 2024),
          updatedAt: faker.date.dateTime(minYear: 2024, maxYear: 2024),
        );

        // 验证任务具有所有必需的属性
        expect(
          task.startTime,
          isNotNull,
          reason: 'Task should have start time',
        );
        expect(task.endTime, isNotNull, reason: 'Task should have end time');
        expect(task.tags, isNotNull, reason: 'Task should have tags list');
        expect(task.priority, isNotNull, reason: 'Task should have priority');

        // 验证时间逻辑正确
        expect(
          task.endTime.isAfter(task.startTime),
          isTrue,
          reason: 'End time should be after start time',
        );

        // 验证枚举值有效
        expect(
          TaskPriority.values.contains(task.priority),
          isTrue,
          reason: 'Priority should be valid enum value',
        );
        expect(
          TaskStatus.values.contains(task.status),
          isTrue,
          reason: 'Status should be valid enum value',
        );
        expect(
          TaskCategory.values.contains(task.category),
          isTrue,
          reason: 'Category should be valid enum value',
        );

        // 验证标签列表不为null（可以为空）
        expect(
          task.tags,
          isA<List<String>>(),
          reason: 'Tags should be a list of strings',
        );
      }
    });

    test('Property: Task serialization round trip', () {
      // 运行100次迭代测试序列化往返
      for (var i = 0; i < 100; i++) {
        final startTime = faker.date.dateTime(minYear: 2024, maxYear: 2025);
        final endTime = startTime.add(
          Duration(hours: faker.randomGenerator.integer(8, min: 1)),
        );

        final originalTask = TaskModel(
          id: faker.guid.guid(),
          title: faker.lorem.sentence(),
          description: faker.lorem.sentences(2).join(' '),
          startTime: startTime,
          endTime: endTime,
          tags: List.generate(
            faker.randomGenerator.integer(3),
            (_) => faker.lorem.word(),
          ),
          priority:
              TaskPriority.values[faker.randomGenerator.integer(
                TaskPriority.values.length,
              )],
          status: TaskStatus
              .values[faker.randomGenerator.integer(TaskStatus.values.length)],
          category:
              TaskCategory.values[faker.randomGenerator.integer(
                TaskCategory.values.length,
              )],
          createdAt: faker.date.dateTime(minYear: 2024, maxYear: 2024),
          updatedAt: faker.date.dateTime(minYear: 2024, maxYear: 2024),
        );

        // 序列化到JSON然后反序列化
        final json = originalTask.toJson();
        final deserializedTask = TaskModel.fromJson(json);

        // 验证往返后数据完全一致
        expect(
          deserializedTask,
          equals(originalTask),
          reason: 'Task should be identical after JSON round trip',
        );
      }
    });

    test('Property: Task validation consistency', () {
      // 运行100次迭代测试验证逻辑一致性
      for (var i = 0; i < 100; i++) {
        final startTime = faker.date.dateTime(minYear: 2024, maxYear: 2025);

        // 随机决定是否创建有效任务
        final isValidTask = faker.randomGenerator.boolean();

        final task = TaskModel(
          id: faker.guid.guid(),
          title: isValidTask ? faker.lorem.sentence() : '', // 无效任务使用空标题
          startTime: startTime,
          endTime: isValidTask
              ? startTime.add(const Duration(hours: 1))
              : startTime.subtract(const Duration(hours: 1)), // 无效任务结束时间早于开始时间
          tags: const [],
          priority: TaskPriority.medium,
          status: TaskStatus.pending,
          category: TaskCategory.personal,
          createdAt: startTime.subtract(const Duration(hours: 2)),
          updatedAt: startTime.subtract(const Duration(hours: 1)),
        );

        // 验证isValid()方法的一致性
        if (isValidTask) {
          expect(
            task.isValid(),
            isTrue,
            reason: 'Valid task should pass validation',
          );
        } else {
          expect(
            task.isValid(),
            isFalse,
            reason: 'Invalid task should fail validation',
          );
        }
      }
    });
  });
}
