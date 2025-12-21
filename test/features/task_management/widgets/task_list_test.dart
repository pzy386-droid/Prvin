import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prvin/features/task_management/widgets/task_list.dart';

void main() {
  group('TaskList Widget Tests', () {
    final sampleTasks = [
      TaskItem(
        id: '1',
        title: '测试任务1',
        description: '测试描述1',
        date: DateTime(2024, 12, 15),
        category: 'work',
        priority: 'high',
        tags: ['标签1', '标签2'],
      ),
      TaskItem(
        id: '2',
        title: '测试任务2',
        description: '测试描述2',
        date: DateTime(2024, 12, 16),
        category: 'personal',
        priority: 'medium',
        tags: ['标签3'],
        isCompleted: true,
      ),
    ];

    testWidgets('should display task list correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskList(tasks: sampleTasks),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 验证任务标题显示
      expect(find.text('测试任务1'), findsOneWidget);
      expect(find.text('测试任务2'), findsOneWidget);

      // 验证任务描述显示
      expect(find.text('测试描述1'), findsOneWidget);
      expect(find.text('测试描述2'), findsOneWidget);
    });

    testWidgets(
      'should hide completed tasks when showCompletedTasks is false',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TaskList(tasks: sampleTasks, showCompletedTasks: false),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // 验证只显示未完成的任务
        expect(find.text('测试任务1'), findsOneWidget);
        expect(find.text('测试任务2'), findsNothing);
      },
    );

    testWidgets('should display empty state when no tasks', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: TaskList(tasks: [])),
        ),
      );

      await tester.pumpAndSettle();

      // 验证空状态显示
      expect(find.text('暂无任务'), findsOneWidget);
      expect(find.text('点击右下角按钮创建第一个任务'), findsOneWidget);
    });

    testWidgets('should call onTaskTap when task is tapped', (
      WidgetTester tester,
    ) async {
      TaskItem? tappedTask;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskList(
              tasks: sampleTasks,
              onTaskTap: (task) {
                tappedTask = task;
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 点击第一个任务
      await tester.tap(find.text('测试任务1'));
      await tester.pumpAndSettle();

      // 验证回调被调用
      expect(tappedTask, isNotNull);
      expect(tappedTask!.id, equals('1'));
    });

    testWidgets('should call onTaskToggle when checkbox is tapped', (
      WidgetTester tester,
    ) async {
      TaskItem? toggledTask;
      bool? newCompletedState;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskList(
              tasks: sampleTasks,
              onTaskToggle: (task, completed) {
                toggledTask = task;
                newCompletedState = completed;
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 查找第一个任务的复选框
      final checkboxFinder = find.byType(Container).first;
      await tester.tap(checkboxFinder);
      await tester.pumpAndSettle();

      // 验证回调被调用
      expect(toggledTask, isNotNull);
      expect(newCompletedState, isNotNull);
    });

    testWidgets('should show task menu when more button is tapped', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: TaskList(tasks: sampleTasks)),
        ),
      );

      await tester.pumpAndSettle();

      // 点击更多按钮
      await tester.tap(find.byIcon(Icons.more_vert).first);
      await tester.pumpAndSettle();

      // 验证菜单显示
      expect(find.text('编辑'), findsOneWidget);
      expect(find.text('删除'), findsOneWidget);
    });

    testWidgets('should call onTaskEdit when edit menu item is selected', (
      WidgetTester tester,
    ) async {
      TaskItem? editedTask;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskList(
              tasks: sampleTasks,
              onTaskEdit: (task) {
                editedTask = task;
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 点击更多按钮
      await tester.tap(find.byIcon(Icons.more_vert).first);
      await tester.pumpAndSettle();

      // 点击编辑
      await tester.tap(find.text('编辑'));
      await tester.pumpAndSettle();

      // 验证回调被调用
      expect(editedTask, isNotNull);
      expect(editedTask!.id, equals('1'));
    });

    testWidgets('should call onTaskDelete when delete menu item is selected', (
      WidgetTester tester,
    ) async {
      TaskItem? deletedTask;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskList(
              tasks: sampleTasks,
              onTaskDelete: (task) {
                deletedTask = task;
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 点击更多按钮
      await tester.tap(find.byIcon(Icons.more_vert).first);
      await tester.pumpAndSettle();

      // 点击删除
      await tester.tap(find.text('删除'));
      await tester.pumpAndSettle();

      // 验证回调被调用
      expect(deletedTask, isNotNull);
      expect(deletedTask!.id, equals('1'));
    });
  });

  group('TaskCard Widget Tests', () {
    final sampleTask = TaskItem(
      id: '1',
      title: '测试任务',
      description: '测试描述',
      date: DateTime(2024, 12, 15),
      startTime: const TimeOfDay(hour: 9, minute: 0),
      endTime: const TimeOfDay(hour: 10, minute: 0),
      category: 'work',
      priority: 'high',
      tags: ['标签1', '标签2', '标签3'],
    );

    testWidgets('should display task information correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: TaskCard(task: sampleTask)),
        ),
      );

      await tester.pumpAndSettle();

      // 验证任务信息显示
      expect(find.text('测试任务'), findsOneWidget);
      expect(find.text('测试描述'), findsOneWidget);
      expect(find.text('工作'), findsOneWidget);
      expect(find.text('09:00 - 10:00'), findsOneWidget);

      // 验证标签显示（最多显示3个）
      expect(find.text('标签1'), findsOneWidget);
      expect(find.text('标签2'), findsOneWidget);
      expect(find.text('标签3'), findsOneWidget);
    });

    testWidgets('should show completed task with different style', (
      WidgetTester tester,
    ) async {
      final completedTask = sampleTask.copyWith(isCompleted: true);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: TaskCard(task: completedTask)),
        ),
      );

      await tester.pumpAndSettle();

      // 验证完成状态的复选框
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('should call onTap when card is tapped', (
      WidgetTester tester,
    ) async {
      var tapWasCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskCard(
              task: sampleTask,
              onTap: () {
                tapWasCalled = true;
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 点击卡片
      await tester.tap(find.byType(TaskCard));
      await tester.pumpAndSettle();

      // 验证回调被调用
      expect(tapWasCalled, isTrue);
    });

    testWidgets('should call onToggle when checkbox is tapped', (
      WidgetTester tester,
    ) async {
      bool? newCompletedState;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskCard(
              task: sampleTask,
              onToggle: (completed) {
                newCompletedState = completed;
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 查找并点击复选框
      final checkboxFinder = find.byType(Container).first;
      await tester.tap(checkboxFinder);
      await tester.pumpAndSettle();

      // 验证回调被调用
      expect(newCompletedState, isNotNull);
      expect(newCompletedState, isTrue); // 从false变为true
    });
  });

  group('TaskItem Model Tests', () {
    test('should create TaskItem with required fields', () {
      final task = TaskItem(
        id: '1',
        title: '测试任务',
        date: DateTime(2024, 12, 15),
      );

      expect(task.id, equals('1'));
      expect(task.title, equals('测试任务'));
      expect(task.date, equals(DateTime(2024, 12, 15)));
      expect(task.isCompleted, isFalse);
      expect(task.tags, isEmpty);
    });

    test('should create TaskItem with all fields', () {
      final task = TaskItem(
        id: '1',
        title: '测试任务',
        description: '测试描述',
        date: DateTime(2024, 12, 15),
        startTime: const TimeOfDay(hour: 9, minute: 0),
        endTime: const TimeOfDay(hour: 10, minute: 0),
        category: 'work',
        priority: 'high',
        tags: ['标签1', '标签2'],
        isCompleted: true,
        createdAt: DateTime(2024, 12, 14),
        updatedAt: DateTime(2024, 12, 15),
      );

      expect(task.id, equals('1'));
      expect(task.title, equals('测试任务'));
      expect(task.description, equals('测试描述'));
      expect(task.date, equals(DateTime(2024, 12, 15)));
      expect(task.startTime, equals(const TimeOfDay(hour: 9, minute: 0)));
      expect(task.endTime, equals(const TimeOfDay(hour: 10, minute: 0)));
      expect(task.category, equals('work'));
      expect(task.priority, equals('high'));
      expect(task.tags, equals(['标签1', '标签2']));
      expect(task.isCompleted, isTrue);
      expect(task.createdAt, equals(DateTime(2024, 12, 14)));
      expect(task.updatedAt, equals(DateTime(2024, 12, 15)));
    });

    test('should copy TaskItem with modifications', () {
      final original = TaskItem(
        id: '1',
        title: '原始任务',
        date: DateTime(2024, 12, 15),
      );

      final copied = original.copyWith(title: '修改后的任务', isCompleted: true);

      expect(copied.id, equals('1')); // 保持不变
      expect(copied.title, equals('修改后的任务')); // 新值
      expect(copied.date, equals(DateTime(2024, 12, 15))); // 保持不变
      expect(copied.isCompleted, isTrue); // 新值
    });

    test('should create TaskItem from TaskFormData', () {
      final formData = TaskFormData(
        id: 'form-id',
        title: '表单任务',
        description: '表单描述',
        date: DateTime(2024, 12, 15),
        startTime: const TimeOfDay(hour: 9, minute: 0),
        endTime: const TimeOfDay(hour: 10, minute: 0),
        category: 'work',
        priority: 'high',
        tags: ['标签1', '标签2'],
      );

      final task = TaskItem.fromFormData(formData);

      expect(task.id, equals('form-id'));
      expect(task.title, equals('表单任务'));
      expect(task.description, equals('表单描述'));
      expect(task.date, equals(DateTime(2024, 12, 15)));
      expect(task.startTime, equals(const TimeOfDay(hour: 9, minute: 0)));
      expect(task.endTime, equals(const TimeOfDay(hour: 10, minute: 0)));
      expect(task.category, equals('work'));
      expect(task.priority, equals('high'));
      expect(task.tags, equals(['标签1', '标签2']));
      expect(task.isCompleted, isFalse); // 默认值
      expect(task.createdAt, isNotNull);
      expect(task.updatedAt, isNotNull);
    });

    test('should convert TaskItem to TaskFormData', () {
      final task = TaskItem(
        id: '1',
        title: '测试任务',
        description: '测试描述',
        date: DateTime(2024, 12, 15),
        startTime: const TimeOfDay(hour: 9, minute: 0),
        endTime: const TimeOfDay(hour: 10, minute: 0),
        category: 'work',
        priority: 'high',
        tags: ['标签1', '标签2'],
        isCompleted: true,
      );

      final formData = task.toFormData();

      expect(formData.id, equals('1'));
      expect(formData.title, equals('测试任务'));
      expect(formData.description, equals('测试描述'));
      expect(formData.date, equals(DateTime(2024, 12, 15)));
      expect(formData.startTime, equals(const TimeOfDay(hour: 9, minute: 0)));
      expect(formData.endTime, equals(const TimeOfDay(hour: 10, minute: 0)));
      expect(formData.category, equals('work'));
      expect(formData.priority, equals('high'));
      expect(formData.tags, equals(['标签1', '标签2']));
    });
  });
}
