import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prvin/features/pomodoro/data/models/pomodoro_session_model.dart';
import 'package:prvin/features/sync/data/models/calendar_event_model.dart';
import 'package:prvin/features/tasks/data/models/task_model.dart';

void main() {
  group('Data Models Integration Tests', () {
    final faker = Faker();

    test('Core data models should serialize and deserialize correctly', () {
      // 测试TaskModel
      final task = TaskModel(
        id: faker.guid.guid(),
        title: faker.lorem.sentence(),
        startTime: DateTime.now(),
        endTime: DateTime.now().add(const Duration(hours: 1)),
        tags: const ['test'],
        priority: TaskPriority.high,
        status: TaskStatus.pending,
        category: TaskCategory.work,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final taskJson = task.toJson();
      final taskFromJson = TaskModel.fromJson(taskJson);
      expect(taskFromJson, equals(task));

      // 测试PomodoroSessionModel
      final session = PomodoroSessionModel(
        id: faker.guid.guid(),
        startTime: DateTime.now(),
        plannedDuration: const Duration(minutes: 25),
        actualDuration: const Duration(minutes: 20),
        type: SessionType.work,
        completed: true,
        createdAt: DateTime.now(),
      );

      final sessionJson = session.toJson();
      final sessionFromJson = PomodoroSessionModel.fromJson(sessionJson);
      expect(sessionFromJson, equals(session));

      // 测试CalendarEventModel
      final event = CalendarEventModel(
        id: faker.guid.guid(),
        title: faker.lorem.sentence(),
        startTime: DateTime.now(),
        endTime: DateTime.now().add(const Duration(hours: 1)),
        source: EventSource.local,
        isAllDay: false,
        attendees: const [],
        reminders: const [15],
        metadata: const {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final eventJson = event.toJson();
      final eventFromJson = CalendarEventModel.fromJson(eventJson);
      expect(eventFromJson, equals(event));
    });

    test('Core data models should validate correctly', () {
      // 有效的任务
      final validTask = TaskModel(
        id: 'valid-id',
        title: 'Valid Task',
        startTime: DateTime.now(),
        endTime: DateTime.now().add(const Duration(hours: 1)),
        tags: const [],
        priority: TaskPriority.medium,
        status: TaskStatus.pending,
        category: TaskCategory.personal,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      expect(validTask.isValid(), isTrue);

      // 有效的番茄钟会话
      final now = DateTime.now();
      final validSession = PomodoroSessionModel(
        id: 'valid-session',
        startTime: now,
        endTime: now.add(const Duration(minutes: 25)), // 已完成的会话需要结束时间
        plannedDuration: const Duration(minutes: 25),
        actualDuration: const Duration(minutes: 25),
        type: SessionType.work,
        completed: true,
        createdAt: now,
      );
      expect(validSession.isValid(), isTrue);

      // 有效的日历事件
      final validEvent = CalendarEventModel(
        id: 'valid-event',
        title: 'Valid Event',
        startTime: DateTime.now(),
        endTime: DateTime.now().add(const Duration(hours: 1)),
        source: EventSource.local,
        isAllDay: false,
        attendees: const [],
        reminders: const [],
        metadata: const {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      expect(validEvent.isValid(), isTrue);
    });

    test('Data models should handle edge cases correctly', () {
      // 测试空标签列表
      final taskWithEmptyTags = TaskModel(
        id: 'test-id',
        title: 'Test Task',
        startTime: DateTime.now(),
        endTime: DateTime.now().add(const Duration(hours: 1)),
        tags: const [], // 空标签列表
        priority: TaskPriority.medium,
        status: TaskStatus.pending,
        category: TaskCategory.personal,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      expect(taskWithEmptyTags.isValid(), isTrue);
      expect(taskWithEmptyTags.tags, isEmpty);

      // 测试全天事件
      final allDayEvent = CalendarEventModel(
        id: 'all-day-event',
        title: 'All Day Event',
        startTime: DateTime(2024),
        endTime: DateTime(2024, 1, 2),
        source: EventSource.local,
        isAllDay: true, // 全天事件
        attendees: const [],
        reminders: const [],
        metadata: const {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      expect(allDayEvent.isValid(), isTrue);
      expect(allDayEvent.isAllDay, isTrue);

      // 测试未完成的番茄钟会话
      final incompleteSession = PomodoroSessionModel(
        id: 'incomplete-session',
        startTime: DateTime.now(),
        plannedDuration: const Duration(minutes: 25),
        actualDuration: const Duration(minutes: 10),
        type: SessionType.work,
        completed: false, // 未完成
        createdAt: DateTime.now(),
      );
      expect(incompleteSession.isValid(), isTrue);
      expect(incompleteSession.isActive, isTrue);
    });
  });
}
