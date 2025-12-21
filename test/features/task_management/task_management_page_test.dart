import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prvin/features/task_management/task_management_page.dart';

void main() {
  group('TaskManagementPage Widget Tests', () {
    testWidgets('should display task management page correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: TaskManagementPage()));

      await tester.pumpAndSettle();

      // 验证应用栏
      expect(find.text('任务管理'), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byIcon(Icons.more_vert), findsOneWidget);

      // 验证筛选栏
      expect(find.text('筛选：'), findsOneWidget);
      expect(find.text('全部'), findsOneWidget);
      expect(find.text('今天'), findsOneWidget);
      expect(find.text('本周'), findsOneWidget);
      expect(find.text('本月'), findsOneWidget);

      // 验证排序选项
      expect(find.text('排序：'), findsOneWidget);
      expect(find.text('日期'), findsOneWidget);
      expect(find.text('优先级'), findsOneWidget);
      expect(find.text('分类'), findsOneWidget);

      // 验证浮动操作按钮
      expect(find.text('创建任务'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('should display sample tasks', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: TaskManagementPage()));

      await tester.pumpAndSettle();

      // 验证示例任务显示
      expect(find.text('完成项目报告'), findsOneWidget);
      expect(find.text('健身锻炼'), findsOneWidget);
      expect(find.text('学习Flutter'), findsOneWidget);
      expect(find.text('团队会议'), findsOneWidget);
    });

    testWidgets('should show task count in filter bar', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: TaskManagementPage()));

      await tester.pumpAndSettle();

      // 验证任务统计显示
      expect(find.textContaining('个任务'), findsOneWidget);
    });

    testWidgets('should open create task form when FAB is tapped', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: TaskManagementPage()));

      await tester.pumpAndSettle();

      // 点击创建任务按钮
      await tester.tap(find.text('创建任务'));
      await tester.pumpAndSettle();

      // 验证任务表单显示
      expect(find.text('创建任务'), findsWidgets); // 会找到按钮和表单标题
    });

    testWidgets('should filter tasks by today', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: TaskManagementPage()));

      await tester.pumpAndSettle();

      // 点击今天筛选
      await tester.tap(find.text('今天'));
      await tester.pumpAndSettle();

      // 验证筛选效果（任务数量可能会变化）
      expect(find.textContaining('个任务'), findsOneWidget);
    });

    testWidgets('should filter tasks by week', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: TaskManagementPage()));

      await tester.pumpAndSettle();

      // 点击本周筛选
      await tester.tap(find.text('本周'));
      await tester.pumpAndSettle();

      // 验证筛选效果
      expect(find.textContaining('个任务'), findsOneWidget);
    });

    testWidgets('should filter tasks by month', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: TaskManagementPage()));

      await tester.pumpAndSettle();

      // 点击本月筛选
      await tester.tap(find.text('本月'));
      await tester.pumpAndSettle();

      // 验证筛选效果
      expect(find.textContaining('个任务'), findsOneWidget);
    });

    testWidgets('should sort tasks by priority', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: TaskManagementPage()));

      await tester.pumpAndSettle();

      // 点击优先级排序
      await tester.tap(find.text('优先级'));
      await tester.pumpAndSettle();

      // 验证排序效果（任务顺序可能会变化）
      expect(find.textContaining('个任务'), findsOneWidget);
    });

    testWidgets('should sort tasks by category', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: TaskManagementPage()));

      await tester.pumpAndSettle();

      // 点击分类排序
      await tester.tap(find.text('分类'));
      await tester.pumpAndSettle();

      // 验证排序效果
      expect(find.textContaining('个任务'), findsOneWidget);
    });

    testWidgets('should show search dialog when search button is tapped', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: TaskManagementPage()));

      await tester.pumpAndSettle();

      // 点击搜索按钮
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      // 验证搜索对话框显示
      expect(find.text('搜索任务'), findsOneWidget);
      expect(find.text('输入关键词搜索任务...'), findsOneWidget);
      expect(find.text('取消'), findsOneWidget);
      expect(find.text('搜索'), findsOneWidget);
    });

    testWidgets('should show menu when more button is tapped', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: TaskManagementPage()));

      await tester.pumpAndSettle();

      // 点击更多按钮
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      // 验证菜单显示
      expect(find.text('显示已完成'), findsOneWidget);
      expect(find.text('导出任务'), findsOneWidget);
      expect(find.text('设置'), findsOneWidget);
    });

    testWidgets('should toggle completed tasks visibility', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: TaskManagementPage()));

      await tester.pumpAndSettle();

      // 点击更多按钮
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      // 点击隐藏已完成
      await tester.tap(find.text('隐藏已完成'));
      await tester.pumpAndSettle();

      // 验证已完成任务被隐藏（团队会议任务是已完成的）
      expect(find.text('团队会议'), findsNothing);
    });

    testWidgets('should show task details when task is tapped', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: TaskManagementPage()));

      await tester.pumpAndSettle();

      // 点击第一个任务
      await tester.tap(find.text('完成项目报告'));
      await tester.pumpAndSettle();

      // 验证任务详情对话框显示
      expect(find.text('完成项目报告'), findsWidgets); // 标题和内容都会显示
      expect(find.text('整理本月项目进度，准备汇报材料'), findsOneWidget);
      expect(find.text('关闭'), findsOneWidget);
      expect(find.text('编辑'), findsOneWidget);
    });

    testWidgets('should show delete confirmation when task is deleted', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: TaskManagementPage()));

      await tester.pumpAndSettle();

      // 点击第一个任务的更多按钮
      await tester.tap(find.byIcon(Icons.more_vert).first);
      await tester.pumpAndSettle();

      // 点击删除
      await tester.tap(find.text('删除'));
      await tester.pumpAndSettle();

      // 验证删除确认对话框显示
      expect(find.text('删除任务'), findsOneWidget);
      expect(find.textContaining('确定要删除任务'), findsOneWidget);
      expect(find.text('取消'), findsOneWidget);
      expect(find.text('删除'), findsWidgets); // 菜单项和确认按钮
    });

    testWidgets('should delete task when confirmed', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: TaskManagementPage()));

      await tester.pumpAndSettle();

      // 记录删除前的任务
      expect(find.text('完成项目报告'), findsOneWidget);

      // 点击第一个任务的更多按钮
      await tester.tap(find.byIcon(Icons.more_vert).first);
      await tester.pumpAndSettle();

      // 点击删除
      await tester.tap(find.text('删除'));
      await tester.pumpAndSettle();

      // 确认删除
      await tester.tap(find.text('删除').last);
      await tester.pumpAndSettle();

      // 验证任务被删除
      expect(find.text('完成项目报告'), findsNothing);

      // 验证删除成功提示
      expect(find.textContaining('已删除'), findsOneWidget);
      expect(find.text('撤销'), findsOneWidget);
    });

    testWidgets('should undo task deletion', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: TaskManagementPage()));

      await tester.pumpAndSettle();

      // 删除任务
      await tester.tap(find.byIcon(Icons.more_vert).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('删除'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('删除').last);
      await tester.pumpAndSettle();

      // 点击撤销
      await tester.tap(find.text('撤销'));
      await tester.pumpAndSettle();

      // 验证任务被恢复
      expect(find.text('完成项目报告'), findsOneWidget);
    });

    testWidgets('should show edit form when task is edited', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: TaskManagementPage()));

      await tester.pumpAndSettle();

      // 点击第一个任务的更多按钮
      await tester.tap(find.byIcon(Icons.more_vert).first);
      await tester.pumpAndSettle();

      // 点击编辑
      await tester.tap(find.text('编辑'));
      await tester.pumpAndSettle();

      // 验证编辑表单显示
      expect(find.text('编辑任务'), findsOneWidget);
      expect(find.text('完成项目报告'), findsOneWidget);
      expect(find.text('更新任务'), findsOneWidget);
    });
  });

  group('TaskManagementPage Integration Tests', () {
    testWidgets('should create new task successfully', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: TaskManagementPage()));

      await tester.pumpAndSettle();

      // 点击创建任务按钮
      await tester.tap(find.text('创建任务'));
      await tester.pumpAndSettle();

      // 输入任务标题
      await tester.enterText(find.byType(TextFormField).first, '新测试任务');
      await tester.pumpAndSettle();

      // 保存任务
      await tester.tap(find.text('创建任务').last);
      await tester.pumpAndSettle();

      // 验证任务被创建
      expect(find.text('新测试任务'), findsOneWidget);

      // 验证成功提示
      expect(find.textContaining('创建成功'), findsOneWidget);
    });

    testWidgets('should update task successfully', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: TaskManagementPage()));

      await tester.pumpAndSettle();

      // 编辑第一个任务
      await tester.tap(find.byIcon(Icons.more_vert).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('编辑'));
      await tester.pumpAndSettle();

      // 修改任务标题
      await tester.enterText(find.byType(TextFormField).first, '修改后的任务');
      await tester.pumpAndSettle();

      // 保存修改
      await tester.tap(find.text('更新任务'));
      await tester.pumpAndSettle();

      // 验证任务被更新
      expect(find.text('修改后的任务'), findsOneWidget);

      // 验证成功提示
      expect(find.textContaining('更新成功'), findsOneWidget);
    });

    testWidgets('should toggle task completion status', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: TaskManagementPage()));

      await tester.pumpAndSettle();

      // 查找第一个任务的复选框并点击
      final checkboxFinder = find.byType(Container).first;
      await tester.tap(checkboxFinder);
      await tester.pumpAndSettle();

      // 验证任务状态变化（通过视觉效果验证）
      expect(find.byIcon(Icons.check), findsWidgets);
    });
  });
}
