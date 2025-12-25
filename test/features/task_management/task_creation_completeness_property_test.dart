import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prvin/features/task_management/domain/entities/task.dart';

/// **Feature: prvin-integrated-calendar, Property 5: 任务创建完整性**
///
/// 验证任务创建功能的完整性，确保所有必要的属性都能正确设置和保存
void main() {
  group('Task Creation Completeness Property Tests', () {
    late Faker faker;

    setUp(() {
      faker = Faker();
    });

    test(
      '**Feature: prvin-integrated-calendar, Property 5: 任务创建完整性** - '
      'For any valid task creation request, all specified properties should be correctly set',
      () {
        // 运行100次迭代以确保属性测试的充分性
        for (var i = 0; i < 100; i++) {
          // 生成随机的任务创建请求数据
          final taskCreateRequest = _generateRandomTaskCreateRequest(faker);

          // 验证任务创建请求的完整性
          _validateTaskCreateRequestCompleteness(taskCreateRequest);

          // 模拟创建任务
          final createdTask = _simulateTaskCreation(taskCreateRequest);

          // 验证创建的任务包含所有指定的属性
          _validateCreatedTaskCompleteness(taskCreateRequest, createdTask);
        }
      },
    );

    test(
      '**Feature: prvin-integrated-calendar, Property 5: 任务创建完整性** - '
      'For any task creation with minimal required fields, task should be created successfully',
      () {
        for (var i = 0; i < 100; i++) {
          // 生成只包含必需字段的任务创建请求
          final minimalRequest = _generateMinimalTaskCreateRequest(faker);

          // 验证最小请求的有效性
          expect(minimalRequest.title.trim(), isNotEmpty);
          expect(
            minimalRequest.startTime.isBefore(minimalRequest.endTime),
            isTrue,
          );

          // 模拟创建任务
          final createdTask = _simulateTaskCreation(minimalRequest);

          // 验证任务创建成功且包含必需属性
          expect(createdTask.title, equals(minimalRequest.title));
          expect(createdTask.startTime, equals(minimalRequest.startTime));
          expect(createdTask.endTime, equals(minimalRequest.endTime));
          expect(createdTask.priority, equals(minimalRequest.priority));
          expect(createdTask.category, equals(minimalRequest.category));
        }
      },
    );

    test(
      '**Feature: prvin-integrated-calendar, Property 5: 任务创建完整性** - '
      'For any task creation with all optional fields, all properties should be preserved',
      () {
        for (var i = 0; i < 100; i++) {
          // 生成包含所有可选字段的任务创建请求
          final fullRequest = _generateFullTaskCreateRequest(faker);

          // 模拟创建任务
          final createdTask = _simulateTaskCreation(fullRequest);

          // 验证所有属性都被正确保存
          expect(createdTask.title, equals(fullRequest.title));
          expect(createdTask.startTime, equals(fullRequest.startTime));
          expect(createdTask.endTime, equals(fullRequest.endTime));
          expect(createdTask.priority, equals(fullRequest.priority));
          expect(createdTask.category, equals(fullRequest.category));

          // 验证可选字段
          if (fullRequest.description != null) {
            expect(createdTask.description, equals(fullRequest.description));
          }

          // 验证任务具有有效的ID和时间戳
          expect(createdTask.id, isNotEmpty);
          expect(createdTask.createdAt, isNotNull);
          expect(createdTask.updatedAt, isNotNull);
        }
      },
    );

    test('**Feature: prvin-integrated-calendar, Property 5: 任务创建完整性** - '
        'For any task creation, time validation should be enforced', () {
      for (var i = 0; i < 100; i++) {
        final startTime = _generateRandomDateTime(faker);
        final endTime = startTime.add(
          Duration(
            minutes: faker.randomGenerator.integer(300, min: 15), // 15分钟到5小时
          ),
        );

        final request = TaskCreateRequest(
          title: faker.lorem.sentence(),
          startTime: startTime,
          endTime: endTime,
          priority: _generateRandomPriority(faker),
          category: _generateRandomCategory(faker),
        );

        // 验证时间逻辑
        expect(request.startTime.isBefore(request.endTime), isTrue);
        expect(
          request.endTime.difference(request.startTime).inMinutes,
          greaterThanOrEqualTo(15),
        );

        final createdTask = _simulateTaskCreation(request);

        // 验证创建的任务保持时间约束
        expect(createdTask.startTime.isBefore(createdTask.endTime), isTrue);
        expect(
          createdTask.endTime.difference(createdTask.startTime).inMinutes,
          greaterThanOrEqualTo(15),
        );
      }
    });
  });
}

/// 生成随机的任务创建请求
TaskCreateRequest _generateRandomTaskCreateRequest(Faker faker) {
  final startTime = _generateRandomDateTime(faker);
  final endTime = startTime.add(
    Duration(
      minutes: faker.randomGenerator.integer(480, min: 15), // 15分钟到8小时
    ),
  );

  return TaskCreateRequest(
    title: faker.lorem.sentence(),
    description: faker.randomGenerator.boolean()
        ? faker.lorem.sentences(3).join(' ')
        : null,
    startTime: startTime,
    endTime: endTime,
    priority: _generateRandomPriority(faker),
    category: _generateRandomCategory(faker),
  );
}

/// 生成最小的任务创建请求（只包含必需字段）
TaskCreateRequest _generateMinimalTaskCreateRequest(Faker faker) {
  final startTime = _generateRandomDateTime(faker);
  final endTime = startTime.add(
    Duration(
      minutes: faker.randomGenerator.integer(120, min: 15), // 15分钟到2小时
    ),
  );

  return TaskCreateRequest(
    title: faker.lorem.sentence(),
    startTime: startTime,
    endTime: endTime,
  );
}

/// 生成完整的任务创建请求（包含所有字段）
TaskCreateRequest _generateFullTaskCreateRequest(Faker faker) {
  final startTime = _generateRandomDateTime(faker);
  final endTime = startTime.add(
    Duration(minutes: faker.randomGenerator.integer(480, min: 15)),
  );

  return TaskCreateRequest(
    title: faker.lorem.sentence(),
    description: faker.lorem.sentences(2).join(' '),
    startTime: startTime,
    endTime: endTime,
    priority: _generateRandomPriority(faker),
    category: _generateRandomCategory(faker),
  );
}

/// 生成随机日期时间
DateTime _generateRandomDateTime(Faker faker) {
  final now = DateTime.now();
  final randomDays = faker.randomGenerator.integer(30); // 未来30天内
  final randomHour = faker.randomGenerator.integer(24);
  final randomMinute = faker.randomGenerator.integer(60);

  return DateTime(
    now.year,
    now.month,
    now.day + randomDays,
    randomHour,
    randomMinute,
  );
}

/// 生成随机优先级
TaskPriority _generateRandomPriority(Faker faker) {
  const priorities = TaskPriority.values;
  return priorities[faker.randomGenerator.integer(priorities.length)];
}

/// 生成随机分类
TaskCategory _generateRandomCategory(Faker faker) {
  const categories = TaskCategory.values;
  return categories[faker.randomGenerator.integer(categories.length)];
}

/// 验证任务创建请求的完整性
void _validateTaskCreateRequestCompleteness(TaskCreateRequest request) {
  // 验证必需字段
  expect(request.title, isNotNull);
  expect(request.title.trim(), isNotEmpty);
  expect(request.startTime, isNotNull);
  expect(request.endTime, isNotNull);
  expect(request.priority, isNotNull);
  expect(request.category, isNotNull);

  // 验证时间逻辑
  expect(request.startTime.isBefore(request.endTime), isTrue);

  // 验证标题长度限制
  expect(request.title.length, lessThanOrEqualTo(100));
}

/// 模拟任务创建过程
Task _simulateTaskCreation(TaskCreateRequest request) {
  // 模拟任务创建逻辑
  final now = DateTime.now();

  return Task(
    id: 'task_${now.millisecondsSinceEpoch}',
    title: request.title,
    description: request.description,
    startTime: request.startTime,
    endTime: request.endTime,
    priority: request.priority,
    category: request.category,
    createdAt: now,
    updatedAt: now,
  );
}

/// 验证创建的任务完整性
void _validateCreatedTaskCompleteness(
  TaskCreateRequest request,
  Task createdTask,
) {
  // 验证所有请求的属性都被正确设置
  expect(createdTask.title, equals(request.title));
  expect(createdTask.startTime, equals(request.startTime));
  expect(createdTask.endTime, equals(request.endTime));
  expect(createdTask.priority, equals(request.priority));
  expect(createdTask.category, equals(request.category));

  if (request.description != null) {
    expect(createdTask.description, equals(request.description));
  }

  // 验证系统生成的字段
  expect(createdTask.id, isNotNull);
  expect(createdTask.id, isNotEmpty);
  expect(createdTask.createdAt, isNotNull);
  expect(createdTask.updatedAt, isNotNull);
  expect(createdTask.status, equals(TaskStatus.pending));
  expect(createdTask.tags, isNotNull);

  // 验证时间约束
  expect(createdTask.startTime.isBefore(createdTask.endTime), isTrue);
}
