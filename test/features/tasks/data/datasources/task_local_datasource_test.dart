import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:uuid/uuid.dart';
import 'package:prvin/core/database/database_helper.dart';
import 'package:prvin/features/tasks/data/datasources/task_local_datasource.dart';
import 'package:prvin/features/tasks/data/models/task_model.dart';

void main() {
  group('TaskLocalDataSource', () {
    late DatabaseHelper databaseHelper;
    late TaskLocalDataSource dataSource;
    late TaskModel testTask;

    setUpAll(() {
      // 初始化FFI
      sqfliteFfiInit();
      // 设置数据库工厂为FFI
      databaseFactory = databaseFactoryFfi;
    });

    setUp(() async {
      databaseHelper = DatabaseHelper();
      dataSource = TaskLocalDataSourceImpl(databaseHelper);

      // 创建测试任务
      testTask = TaskModel(
        id: const Uuid().v4(),
        title: 'Test Task',
        description: 'Test Description',
        startTime: DateTime(2024, 1, 1, 9, 0),
        endTime: DateTime(2024, 1, 1, 10, 0),
        tags: ['test', 'work'],
        priority: TaskPriority.high,
        status: TaskStatus.pending,
        category: TaskCategory.work,
        createdAt: DateTime(2024, 1, 1, 8, 0),
        updatedAt: DateTime(2024, 1, 1, 8, 0),
      );
    });

    tearDown(() async {
      await databaseHelper.clearAllData();
      await databaseHelper.close();
    });

    test('should create and retrieve task successfully', () async {
      // 创建任务
      final taskId = await dataSource.createTask(testTask);
      expect(taskId, equals(testTask.id));

      // 检索任务
      final retrievedTask = await dataSource.getTaskById(testTask.id);
      expect(retrievedTask, isNotNull);
      expect(retrievedTask!.id, equals(testTask.id));
      expect(retrievedTask.title, equals(testTask.title));
      expect(retrievedTask.priority, equals(testTask.priority));
      expect(retrievedTask.tags, equals(testTask.tags));
    });

    test('should update task successfully', () async {
      // 创建任务
      await dataSource.createTask(testTask);

      // 更新任务
      final updatedTask = testTask.copyWith(
        title: 'Updated Task',
        status: TaskStatus.completed,
      );
      await dataSource.updateTask(updatedTask);

      // 验证更新
      final retrievedTask = await dataSource.getTaskById(testTask.id);
      expect(retrievedTask!.title, equals('Updated Task'));
      expect(retrievedTask.status, equals(TaskStatus.completed));
    });

    test('should delete task successfully', () async {
      // 创建任务
      await dataSource.createTask(testTask);

      // 验证任务存在
      var retrievedTask = await dataSource.getTaskById(testTask.id);
      expect(retrievedTask, isNotNull);

      // 删除任务
      await dataSource.deleteTask(testTask.id);

      // 验证任务已删除
      retrievedTask = await dataSource.getTaskById(testTask.id);
      expect(retrievedTask, isNull);
    });

    test('should get tasks for specific date', () async {
      // 创建多个任务
      final task1 = testTask;
      final task2 = testTask.copyWith(
        id: const Uuid().v4(),
        startTime: DateTime(2024, 1, 2, 9, 0),
        endTime: DateTime(2024, 1, 2, 10, 0),
      );

      await dataSource.createTask(task1);
      await dataSource.createTask(task2);

      // 获取特定日期的任务
      final tasksForDate1 = await dataSource.getTasksForDate(
        DateTime(2024, 1, 1),
      );
      final tasksForDate2 = await dataSource.getTasksForDate(
        DateTime(2024, 1, 2),
      );

      expect(tasksForDate1.length, equals(1));
      expect(tasksForDate1.first.id, equals(task1.id));

      expect(tasksForDate2.length, equals(1));
      expect(tasksForDate2.first.id, equals(task2.id));
    });

    test('should get tasks by status', () async {
      // 创建不同状态的任务
      final pendingTask = testTask;
      final completedTask = testTask.copyWith(
        id: const Uuid().v4(),
        status: TaskStatus.completed,
      );

      await dataSource.createTask(pendingTask);
      await dataSource.createTask(completedTask);

      // 按状态获取任务
      final pendingTasks = await dataSource.getTasksByStatus(
        TaskStatus.pending,
      );
      final completedTasks = await dataSource.getTasksByStatus(
        TaskStatus.completed,
      );

      expect(pendingTasks.length, equals(1));
      expect(pendingTasks.first.status, equals(TaskStatus.pending));

      expect(completedTasks.length, equals(1));
      expect(completedTasks.first.status, equals(TaskStatus.completed));
    });

    test('should search tasks by title and description', () async {
      // 创建测试任务
      final task1 = testTask.copyWith(title: 'Important Meeting');
      final task2 = testTask.copyWith(
        id: const Uuid().v4(),
        title: 'Code Review',
        description: 'Review important changes',
      );
      final task3 = testTask.copyWith(
        id: const Uuid().v4(),
        title: 'Shopping',
        description: 'Buy groceries',
      );

      await dataSource.createTask(task1);
      await dataSource.createTask(task2);
      await dataSource.createTask(task3);

      // 搜索包含"important"的任务
      final searchResults = await dataSource.searchTasks('important');

      expect(searchResults.length, equals(2));
      expect(
        searchResults.any((task) => task.title.contains('Important')),
        isTrue,
      );
      expect(
        searchResults.any(
          (task) => task.description?.contains('important') == true,
        ),
        isTrue,
      );
    });

    test('should get all tasks ordered by creation date', () async {
      // 创建多个任务
      final task1 = testTask.copyWith(createdAt: DateTime(2024, 1, 1, 8, 0));
      final task2 = testTask.copyWith(
        id: const Uuid().v4(),
        createdAt: DateTime(2024, 1, 1, 9, 0),
      );
      final task3 = testTask.copyWith(
        id: const Uuid().v4(),
        createdAt: DateTime(2024, 1, 1, 10, 0),
      );

      await dataSource.createTask(task1);
      await dataSource.createTask(task2);
      await dataSource.createTask(task3);

      // 获取所有任务（应该按创建时间倒序排列）
      final allTasks = await dataSource.getAllTasks();

      expect(allTasks.length, equals(3));
      expect(allTasks[0].createdAt.isAfter(allTasks[1].createdAt), isTrue);
      expect(allTasks[1].createdAt.isAfter(allTasks[2].createdAt), isTrue);
    });
  });
}
