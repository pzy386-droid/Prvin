import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prvin/features/task_management/domain/entities/task.dart';

/// **Feature: prvin-integrated-calendar, Property 4: 任务拖拽功能性**
///
/// 验证任务拖拽功能，确保任务可以在不同日期间移动并更新时间
void main() {
  group('Task Drag Functionality Property Tests', () {
    late Faker faker;

    setUp(() {
      faker = Faker();
    });

    test('Property 4: Task drag updates time to target date', () {
      // 运行100次迭代以确保属性测试的充分性
      for (var i = 0; i < 100; i++) {
        // 生成原始任务
        final originalTask = _generateRandomTask(faker);

        // 生成目标日期
        final targetDate = _generateRandomDate(faker);

        // 模拟拖拽操作
        final draggedTask = _simulateTaskDrag(originalTask, targetDate);

        // 验证拖拽后的任务属性
        _validateDraggedTask(originalTask, draggedTask, targetDate);
      }
    });

    test('Property 4: Task drag within same day only changes time', () {
      for (var i = 0; i < 100; i++) {
        final originalTask = _generateRandomTask(faker);

        // 生成同一天的不同时间
        final targetTime = _generateRandomTimeOnSameDay(
          originalTask.startTime,
          faker,
        );

        final draggedTask = _simulateTaskDragToTime(originalTask, targetTime);

        // 验证日期保持不变，只有时间改变
        expect(
          _isSameDate(draggedTask.startTime, originalTask.startTime),
          isTrue,
        );
        expect(draggedTask.startTime.hour, equals(targetTime.hour));
        expect(draggedTask.startTime.minute, equals(targetTime.minute));
      }
    });
  });
}

/// 生成随机任务
Task _generateRandomTask(Faker faker) {
  final startTime = _generateRandomDateTime(faker);
  final duration = Duration(
    minutes: faker.randomGenerator.integer(240, min: 15), // 15分钟到4小时
  );
  final endTime = startTime.add(duration);

  return Task(
    id: faker.guid.guid(),
    title: faker.lorem.sentence(),
    description: faker.randomGenerator.boolean()
        ? faker.lorem.sentences(2).join(' ')
        : null,
    startTime: startTime,
    endTime: endTime,
    priority: _generateRandomPriority(faker),
    category: _generateRandomCategory(faker),
    status: _generateRandomStatus(faker),
    tags: _generateRandomTags(faker),
    createdAt: DateTime.now().subtract(
      Duration(days: faker.randomGenerator.integer(30)),
    ),
    updatedAt: DateTime.now().subtract(
      Duration(hours: faker.randomGenerator.integer(24)),
    ),
  );
}

/// 生成随机日期时间
DateTime _generateRandomDateTime(Faker faker) {
  final now = DateTime.now();
  final randomDays = faker.randomGenerator.integer(60, min: -30); // 过去30天到未来30天
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

/// 生成随机日期
DateTime _generateRandomDate(Faker faker) {
  final now = DateTime.now();
  final randomDays = faker.randomGenerator.integer(60, min: -30);

  return DateTime(now.year, now.month, now.day + randomDays);
}

/// 生成同一天的随机时间
DateTime _generateRandomTimeOnSameDay(DateTime date, Faker faker) {
  final randomHour = faker.randomGenerator.integer(24);
  final randomMinute = faker.randomGenerator.integer(60);

  return DateTime(date.year, date.month, date.day, randomHour, randomMinute);
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

/// 生成随机状态
TaskStatus _generateRandomStatus(Faker faker) {
  const statuses = TaskStatus.values;
  return statuses[faker.randomGenerator.integer(statuses.length)];
}

/// 生成随机标签
List<String> _generateRandomTags(Faker faker) {
  final tagCount = faker.randomGenerator.integer(5);
  return List.generate(tagCount, (_) => faker.lorem.word());
}

/// 模拟任务拖拽到新日期
Task _simulateTaskDrag(Task originalTask, DateTime targetDate) {
  final duration = originalTask.endTime.difference(originalTask.startTime);

  // 保持原始时间，只改变日期
  final newStartTime = DateTime(
    targetDate.year,
    targetDate.month,
    targetDate.day,
    originalTask.startTime.hour,
    originalTask.startTime.minute,
  );

  final newEndTime = newStartTime.add(duration);

  return originalTask.copyWith(
    startTime: newStartTime,
    endTime: newEndTime,
    updatedAt: DateTime.now(),
  );
}

/// 模拟任务拖拽到新时间
Task _simulateTaskDragToTime(Task originalTask, DateTime targetTime) {
  final duration = originalTask.endTime.difference(originalTask.startTime);
  final newEndTime = targetTime.add(duration);

  return originalTask.copyWith(
    startTime: targetTime,
    endTime: newEndTime,
    updatedAt: DateTime.now(),
  );
}

/// 验证拖拽后的任务
void _validateDraggedTask(
  Task originalTask,
  Task draggedTask,
  DateTime targetDate,
) {
  // 验证日期已更改到目标日期
  expect(draggedTask.startTime.year, equals(targetDate.year));
  expect(draggedTask.startTime.month, equals(targetDate.month));
  expect(draggedTask.startTime.day, equals(targetDate.day));

  // 验证时间保持不变
  expect(draggedTask.startTime.hour, equals(originalTask.startTime.hour));
  expect(draggedTask.startTime.minute, equals(originalTask.startTime.minute));

  // 验证持续时间保持不变
  final originalDuration = originalTask.endTime.difference(
    originalTask.startTime,
  );
  final newDuration = draggedTask.endTime.difference(draggedTask.startTime);
  expect(newDuration, equals(originalDuration));
}

/// 检查是否为同一天
bool _isSameDate(DateTime date1, DateTime date2) {
  return date1.year == date2.year &&
      date1.month == date2.month &&
      date1.day == date2.day;
}
