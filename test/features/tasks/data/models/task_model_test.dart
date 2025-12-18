import 'package:flutter_test/flutter_test.dart';
import 'package:prvin/features/tasks/data/models/task_model.dart';

void main() {
  group('TaskModel', () {
    late TaskModel testTask;

    setUp(() {
      testTask = TaskModel(
        id: 'test-id',
        title: 'Test Task',
        description: 'Test Description',
        startTime: DateTime(2024, 1, 1, 9, 0),
        endTime: DateTime(2024, 1, 1, 10, 0),
        tags: ['work', 'important'],
        priority: TaskPriority.high,
        status: TaskStatus.pending,
        category: TaskCategory.work,
        createdAt: DateTime(2024, 1, 1, 8, 0),
        updatedAt: DateTime(2024, 1, 1, 8, 0),
      );
    });

    test('should create a valid task model', () {
      expect(testTask.isValid(), isTrue);
      expect(testTask.title, equals('Test Task'));
      expect(testTask.priority, equals(TaskPriority.high));
      expect(testTask.category, equals(TaskCategory.work));
    });

    test('should calculate duration correctly', () {
      expect(testTask.duration, equals(const Duration(hours: 1)));
    });

    test('should detect time conflicts', () {
      final conflictingTask = TaskModel(
        id: 'conflict-id',
        title: 'Conflicting Task',
        startTime: DateTime(2024, 1, 1, 9, 30),
        endTime: DateTime(2024, 1, 1, 10, 30),
        tags: [],
        priority: TaskPriority.medium,
        status: TaskStatus.pending,
        category: TaskCategory.personal,
        createdAt: DateTime(2024, 1, 1, 8, 0),
        updatedAt: DateTime(2024, 1, 1, 8, 0),
      );

      expect(testTask.hasTimeConflict(conflictingTask), isTrue);
    });

    test('should serialize to and from JSON', () {
      final json = testTask.toJson();
      final fromJson = TaskModel.fromJson(json);

      expect(fromJson, equals(testTask));
    });

    test('should validate invalid tasks', () {
      final invalidTask = TaskModel(
        id: 'invalid-id',
        title: '', // Empty title
        startTime: DateTime(2024, 1, 1, 10, 0),
        endTime: DateTime(2024, 1, 1, 9, 0), // End before start
        tags: [],
        priority: TaskPriority.medium,
        status: TaskStatus.pending,
        category: TaskCategory.personal,
        createdAt: DateTime(2024, 1, 1, 8, 0),
        updatedAt: DateTime(2024, 1, 1, 8, 0),
      );

      expect(invalidTask.isValid(), isFalse);
    });

    test('should copy with new values', () {
      final updatedTask = testTask.copyWith(
        title: 'Updated Task',
        status: TaskStatus.completed,
      );

      expect(updatedTask.title, equals('Updated Task'));
      expect(updatedTask.status, equals(TaskStatus.completed));
      expect(updatedTask.id, equals(testTask.id)); // Unchanged
    });
  });
}
