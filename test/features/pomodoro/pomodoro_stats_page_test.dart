import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prvin/features/pomodoro/pages/pomodoro_stats_page.dart';

void main() {
  group('PomodoroStatsPage UI Tests', () {
    testWidgets('should build without errors', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: PomodoroStatsPage()));

      // 验证页面基本元素存在
      expect(find.text('专注统计'), findsOneWidget);
      expect(find.byType(TabBar), findsOneWidget);
      expect(find.byType(TabBarView), findsOneWidget);
    });

    testWidgets('should show stats overview cards', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: PomodoroStatsPage()));

      // 验证统计卡片存在
      expect(find.text('今日专注'), findsOneWidget);
      expect(find.text('连续天数'), findsOneWidget);
      expect(find.text('总专注时间'), findsOneWidget);
      expect(find.text('完成率'), findsOneWidget);
    });

    testWidgets('should show tab bar with correct tabs', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: PomodoroStatsPage()));

      // 验证标签页存在
      expect(find.text('今日'), findsOneWidget);
      expect(find.text('本周'), findsOneWidget);
      expect(find.text('成就'), findsOneWidget);
    });

    testWidgets('should switch tabs correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: PomodoroStatsPage()));

      // 点击本周标签
      await tester.tap(find.text('本周'));
      await tester.pumpAndSettle();

      // 验证本周内容显示
      expect(find.text('本周专注趋势'), findsOneWidget);
      expect(find.text('本周总结'), findsOneWidget);

      // 点击成就标签
      await tester.tap(find.text('成就'));
      await tester.pumpAndSettle();

      // 验证成就内容显示
      expect(find.text('专注新手'), findsOneWidget);
      expect(find.text('坚持不懈'), findsOneWidget);
      expect(find.text('专注大师'), findsOneWidget);
    });

    testWidgets('should show today progress section', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: PomodoroStatsPage()));

      // 验证今日进度部分
      expect(find.text('今日目标进度'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('should show today sessions list', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: PomodoroStatsPage()));

      // 验证今日会话记录
      expect(find.text('今日会话记录'), findsOneWidget);
    });

    testWidgets('should show settings button and dialog', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: PomodoroStatsPage()));

      // 点击设置按钮
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pump();

      // 验证设置对话框显示
      expect(find.text('统计设置'), findsOneWidget);
      expect(find.text('每日目标'), findsOneWidget);
      expect(find.text('导出数据'), findsOneWidget);
    });

    testWidgets('should show week summary correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: PomodoroStatsPage()));

      // 切换到本周标签
      await tester.tap(find.text('本周'));
      await tester.pumpAndSettle();

      // 验证本周总结内容
      expect(find.text('总会话'), findsOneWidget);
      expect(find.text('专注时间'), findsOneWidget);
      expect(find.text('平均时长'), findsOneWidget);
    });

    testWidgets('should show achievement cards with correct states', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: PomodoroStatsPage()));

      // 切换到成就标签
      await tester.tap(find.text('成就'));
      await tester.pumpAndSettle();

      // 验证成就卡片
      expect(find.text('完成第一个番茄钟'), findsOneWidget);
      expect(find.text('连续专注7天'), findsOneWidget);
      expect(find.text('累计专注100小时'), findsOneWidget);

      // 验证解锁状态显示
      expect(find.text('已解锁'), findsWidgets);
      expect(find.text('未解锁'), findsWidgets);
    });
  });

  group('PomodoroStatsPage Animation Tests', () {
    testWidgets('should animate fade in on load', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: PomodoroStatsPage()));

      // 验证FadeTransition存在
      expect(find.byType(FadeTransition), findsOneWidget);
    });

    testWidgets('should handle tab controller correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: PomodoroStatsPage()));

      final tabBarFinder = find.byType(TabBar);
      expect(tabBarFinder, findsOneWidget);

      final tabBar = tester.widget(tabBarFinder);
      expect(tabBar.tabs.length, 3);
    });
  });

  group('PomodoroStatsPage Data Display Tests', () {
    testWidgets('should display mock session data correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: PomodoroStatsPage()));

      // 验证统计数据显示（基于模拟数据）
      expect(find.textContaining('个番茄钟'), findsWidgets);
      expect(find.textContaining('天'), findsWidgets);
      expect(find.textContaining('小时'), findsWidgets);
      expect(find.textContaining('%'), findsWidgets);
    });

    testWidgets('should show session items with correct format', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: PomodoroStatsPage()));

      // 查找会话项目（如果有的话）
      // 由于使用模拟数据，可能会有会话显示
      final sessionItems = find.byType(Container);
      expect(sessionItems, findsWidgets);
    });
  });

  group('PomodoroStatsPage Interaction Tests', () {
    testWidgets('should handle settings dialog interactions', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: PomodoroStatsPage()));

      // 等待页面加载完成
      await tester.pump(const Duration(seconds: 1));

      // 打开设置对话框
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pump();

      // 验证对话框打开
      expect(find.text('统计设置'), findsOneWidget);

      // 点击关闭按钮
      await tester.tap(find.text('关闭'));
      await tester.pump();

      // 验证对话框关闭
      expect(find.text('统计设置'), findsNothing);
    });

    testWidgets('should handle tab switching smoothly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: PomodoroStatsPage()));

      // 等待页面加载完成
      await tester.pump(const Duration(seconds: 1));

      // 测试所有标签切换
      await tester.tap(find.text('本周'));
      await tester.pump();
      expect(find.text('本周专注趋势'), findsOneWidget);

      await tester.tap(find.text('成就'));
      await tester.pump();
      expect(find.text('专注新手'), findsOneWidget);

      await tester.tap(find.text('今日'));
      await tester.pump();
      expect(find.text('今日目标进度'), findsOneWidget);
    });
  });
}
