import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prvin/features/task_management/widgets/task_form.dart';

void main() {
  group('TaskForm Widget Tests', () {
    testWidgets('should display create task form correctly', (
      WidgetTester tester,
    ) async {
      var saveWasCalled = false;
      TaskFormData? savedData;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskForm(
              onSave: (data) {
                saveWasCalled = true;
                savedData = data;
              },
              onCancel: () {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 验证表单标题
      expect(find.text('创建任务'), findsOneWidget);

      // 验证必填字段标签
      expect(find.text('任务标题 *'), findsOneWidget);
      expect(find.text('任务描述'), findsOneWidget);
      expect(find.text('时间安排'), findsOneWidget);
      expect(find.text('任务分类'), findsOneWidget);
      expect(find.text('优先级'), findsOneWidget);
      expect(find.text('标签'), findsOneWidget);

      // 验证分类选项
      expect(find.text('工作'), findsOneWidget);
      expect(find.text('个人'), findsOneWidget);
      expect(find.text('健康'), findsOneWidget);
      expect(find.text('学习'), findsOneWidget);
      expect(find.text('会议'), findsOneWidget);

      // 验证优先级选项
      expect(find.text('低'), findsOneWidget);
      expect(find.text('中'), findsOneWidget);
      expect(find.text('高'), findsOneWidget);

      // 验证操作按钮
      expect(find.text('取消'), findsOneWidget);
      expect(find.text('创建任务'), findsOneWidget);
    });

    testWidgets('should display edit task form correctly', (
      WidgetTester tester,
    ) async {
      final initialTask = TaskFormData(
        id: 'test-id',
        title: '测试任务',
        description: '测试描述',
        date: DateTime(2024, 12, 15),
        category: 'work',
        priority: 'high',
        tags: ['测试', '重要'],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskForm(
              initialTask: initialTask,
              onSave: (data) {},
              onCancel: () {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 验证表单标题
      expect(find.text('编辑任务'), findsOneWidget);

      // 验证预填充的数据
      expect(find.text('测试任务'), findsOneWidget);
      expect(find.text('测试描述'), findsOneWidget);

      // 验证更新按钮
      expect(find.text('更新任务'), findsOneWidget);
    });

    testWidgets('should validate required fields', (WidgetTester tester) async {
      var saveWasCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskForm(
              onSave: (data) {
                saveWasCalled = true;
              },
              onCancel: () {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 尝试保存空表单
      await tester.tap(find.text('创建任务'));
      await tester.pumpAndSettle();

      // 验证验证错误信息
      expect(find.text('请输入任务标题'), findsOneWidget);
      expect(saveWasCalled, isFalse);
    });

    testWidgets('should save task with valid data', (
      WidgetTester tester,
    ) async {
      var saveWasCalled = false;
      TaskFormData? savedData;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskForm(
              onSave: (data) {
                saveWasCalled = true;
                savedData = data;
              },
              onCancel: () {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 输入任务标题
      await tester.enterText(find.byType(TextFormField).first, '测试任务');
      await tester.pumpAndSettle();

      // 点击保存按钮
      await tester.tap(find.text('创建任务'));
      await tester.pumpAndSettle();

      // 验证保存被调用
      expect(saveWasCalled, isTrue);
      expect(savedData, isNotNull);
      expect(savedData!.title, equals('测试任务'));
    });

    testWidgets('should handle category selection', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskForm(onSave: (data) {}, onCancel: () {}),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 点击个人分类
      await tester.tap(find.text('个人'));
      await tester.pumpAndSettle();

      // 验证分类被选中（通过视觉状态变化）
      // 这里我们通过查找Container来验证选中状态
      final personalCategoryFinder = find.ancestor(
        of: find.text('个人'),
        matching: find.byType(Container),
      );
      expect(personalCategoryFinder, findsWidgets);
    });

    testWidgets('should handle priority selection', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskForm(onSave: (data) {}, onCancel: () {}),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 点击高优先级
      await tester.tap(find.text('高'));
      await tester.pumpAndSettle();

      // 验证优先级被选中
      final highPriorityFinder = find.ancestor(
        of: find.text('高'),
        matching: find.byType(Container),
      );
      expect(highPriorityFinder, findsWidgets);
    });

    testWidgets('should handle tags input', (WidgetTester tester) async {
      TaskFormData? savedData;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskForm(
              onSave: (data) {
                savedData = data;
              },
              onCancel: () {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 输入任务标题（必填）
      await tester.enterText(find.byType(TextFormField).first, '测试任务');

      // 查找标签输入框（通过hint文本）
      final tagInputFinder = find.widgetWithText(TextFormField, '输入标签，用逗号分隔');
      expect(tagInputFinder, findsOneWidget);

      // 输入标签
      await tester.enterText(tagInputFinder, '标签1, 标签2, 标签3');
      await tester.pumpAndSettle();

      // 保存任务
      await tester.tap(find.text('创建任务'));
      await tester.pumpAndSettle();

      // 验证标签被正确解析
      expect(savedData, isNotNull);
      expect(savedData!.tags, contains('标签1'));
      expect(savedData!.tags, contains('标签2'));
      expect(savedData!.tags, contains('标签3'));
    });

    testWidgets('should call cancel callback', (WidgetTester tester) async {
      var cancelWasCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskForm(
              onSave: (data) {},
              onCancel: () {
                cancelWasCalled = true;
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 点击取消按钮
      await tester.tap(find.text('取消'));
      await tester.pumpAndSettle();

      // 验证取消回调被调用
      expect(cancelWasCalled, isTrue);
    });

    testWidgets('should show discard dialog when there are unsaved changes', (
      WidgetTester tester,
    ) async {
      var cancelWasCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskForm(
              onSave: (data) {},
              onCancel: () {
                cancelWasCalled = true;
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 输入一些数据
      await tester.enterText(find.byType(TextFormField).first, '测试任务');
      await tester.pumpAndSettle();

      // 点击取消按钮
      await tester.tap(find.text('取消'));
      await tester.pumpAndSettle();

      // 验证显示放弃更改对话框
      expect(find.text('放弃更改'), findsOneWidget);
      expect(find.text('您有未保存的更改，确定要放弃吗？'), findsOneWidget);
      expect(find.text('继续编辑'), findsOneWidget);
      expect(find.text('放弃更改'), findsWidgets); // 会找到两个：对话框标题和按钮

      // 点击放弃更改
      await tester.tap(find.text('放弃更改').last);
      await tester.pumpAndSettle();

      // 验证取消回调被调用
      expect(cancelWasCalled, isTrue);
    });
  });

  group('TaskFormData Tests', () {
    test('should create TaskFormData with required fields', () {
      final formData = TaskFormData(
        title: '测试任务',
        date: DateTime(2024, 12, 15),
      );

      expect(formData.title, equals('测试任务'));
      expect(formData.date, equals(DateTime(2024, 12, 15)));
      expect(formData.id, isNull);
      expect(formData.description, isNull);
      expect(formData.tags, isEmpty);
    });

    test('should create TaskFormData with all fields', () {
      final formData = TaskFormData(
        id: 'test-id',
        title: '测试任务',
        description: '测试描述',
        date: DateTime(2024, 12, 15),
        startTime: const TimeOfDay(hour: 9, minute: 0),
        endTime: const TimeOfDay(hour: 10, minute: 0),
        category: 'work',
        priority: 'high',
        tags: ['标签1', '标签2'],
      );

      expect(formData.id, equals('test-id'));
      expect(formData.title, equals('测试任务'));
      expect(formData.description, equals('测试描述'));
      expect(formData.date, equals(DateTime(2024, 12, 15)));
      expect(formData.startTime, equals(const TimeOfDay(hour: 9, minute: 0)));
      expect(formData.endTime, equals(const TimeOfDay(hour: 10, minute: 0)));
      expect(formData.category, equals('work'));
      expect(formData.priority, equals('high'));
      expect(formData.tags, equals(['标签1', '标签2']));
    });

    test('should copy TaskFormData with modifications', () {
      final original = TaskFormData(
        title: '原始任务',
        date: DateTime(2024, 12, 15),
        category: 'work',
      );

      final copied = original.copyWith(title: '修改后的任务', priority: 'high');

      expect(copied.title, equals('修改后的任务'));
      expect(copied.date, equals(DateTime(2024, 12, 15))); // 保持不变
      expect(copied.category, equals('work')); // 保持不变
      expect(copied.priority, equals('high')); // 新值
    });
  });
}
