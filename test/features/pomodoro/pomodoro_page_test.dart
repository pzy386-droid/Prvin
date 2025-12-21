import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prvin/features/pomodoro/pomodoro_page.dart';

void main() {
  group('PomodoroPage Tests', () {
    testWidgets('should build without errors', (WidgetTester tester) async {
      // 构建番茄钟页面
      await tester.pumpWidget(const MaterialApp(home: PomodoroPage()));

      // 验证页面基本元素存在
      expect(find.text('专注时间'), findsOneWidget);
      expect(find.text('准备开始专注'), findsOneWidget);
      expect(find.text('25:00'), findsOneWidget);
      expect(find.text('0%'), findsOneWidget);
    });

    testWidgets('should show timer controls', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: PomodoroPage()));

      // 验证控制按钮存在
      expect(find.byIcon(Icons.refresh), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow), findsWidgets);
      expect(find.text('重置'), findsOneWidget);
      expect(find.text('开始'), findsOneWidget);
    });

    testWidgets('should show settings button', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: PomodoroPage()));

      // 验证设置按钮存在
      expect(find.byIcon(Icons.settings), findsOneWidget);
    });

    testWidgets('should show back button', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: PomodoroPage()));

      // 验证返回按钮存在
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('should start timer when play button is tapped', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: PomodoroPage()));

      // 点击开始按钮
      await tester.tap(find.byIcon(Icons.play_arrow).first);
      await tester.pump();

      // 验证状态变化
      expect(find.text('专注进行中...'), findsOneWidget);
      expect(find.byIcon(Icons.pause), findsWidgets);
    });

    testWidgets('should reset timer when reset button is tapped', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: PomodoroPage()));

      // 先开始计时器
      await tester.tap(find.byIcon(Icons.play_arrow).first);
      await tester.pump();

      // 然后重置
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pump();

      // 验证重置后的状态
      expect(find.text('准备开始专注'), findsOneWidget);
      expect(find.text('25:00'), findsOneWidget);
      expect(find.text('0%'), findsOneWidget);
    });

    testWidgets('should show settings dialog when settings button is tapped', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: PomodoroPage()));

      // 点击设置按钮
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pump();

      // 验证设置对话框显示
      expect(find.text('番茄钟设置'), findsOneWidget);
      expect(find.text('专注时间'), findsWidgets); // 可能有多个，因为页面标题也有
      expect(find.text('短休息'), findsOneWidget);
      expect(find.text('长休息'), findsOneWidget);
    });
  });

  group('PomodoroState Tests', () {
    test('should have correct enum values', () {
      expect(PomodoroState.values.length, 4);
      expect(PomodoroState.values, contains(PomodoroState.idle));
      expect(PomodoroState.values, contains(PomodoroState.running));
      expect(PomodoroState.values, contains(PomodoroState.paused));
      expect(PomodoroState.values, contains(PomodoroState.completed));
    });
  });

  group('PomodoroPage Animation Tests', () {
    testWidgets('should have breathing animation', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: PomodoroPage()));

      // 验证动画构建器存在
      expect(find.byType(AnimatedBuilder), findsWidgets);

      // 推进动画
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(PomodoroPage), findsOneWidget);
    });

    testWidgets('should animate progress circle', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: PomodoroPage()));

      // 开始计时器
      await tester.tap(find.byIcon(Icons.play_arrow).first);
      await tester.pump();

      // 验证进度动画
      expect(find.byType(CustomPaint), findsOneWidget);
    });

    testWidgets('should show pulse animation on start', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: PomodoroPage()));

      // 开始计时器
      await tester.tap(find.byIcon(Icons.play_arrow).first);
      await tester.pump();

      // 验证脉冲动画
      expect(find.byType(Transform), findsWidgets);
    });
  });

  group('PomodoroPage State Management Tests', () {
    testWidgets('should maintain state through widget rebuilds', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: PomodoroPage()));

      // 开始计时器
      await tester.tap(find.byIcon(Icons.play_arrow).first);
      await tester.pump();

      // 重建widget
      await tester.pumpWidget(const MaterialApp(home: PomodoroPage()));

      // 验证状态保持
      expect(find.text('专注进行中...'), findsOneWidget);
    });

    testWidgets('should handle multiple state transitions', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: PomodoroPage()));

      // 开始 -> 暂停 -> 重置
      await tester.tap(find.byIcon(Icons.play_arrow).first);
      await tester.pump();
      expect(find.text('专注进行中...'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.pause).first);
      await tester.pump();
      expect(find.text('已暂停'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pump();
      expect(find.text('准备开始专注'), findsOneWidget);
    });
  });

  group('PomodoroPage Navigation Tests', () {
    testWidgets('should navigate to stats page', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: PomodoroPage()));

      // 点击统计按钮
      await tester.tap(find.byIcon(Icons.bar_chart));
      await tester.pumpAndSettle();

      // 验证导航到统计页面
      expect(find.text('专注统计'), findsOneWidget);
    });

    testWidgets('should navigate back from stats page', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: PomodoroPage()));

      // 导航到统计页面
      await tester.tap(find.byIcon(Icons.bar_chart));
      await tester.pumpAndSettle();

      // 返回
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // 验证返回到番茄钟页面
      expect(find.text('专注时间'), findsOneWidget);
    });
  });

  group('PomodoroPage Visual Tests', () {
    testWidgets('should show gradient background', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: PomodoroPage()));

      // 验证渐变背景容器存在
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('should show glow effect', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: PomodoroPage()));

      // 验证微光效果容器存在
      final containers = find.byType(Container);
      expect(containers, findsWidgets);
    });

    testWidgets('should display time format correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: PomodoroPage()));

      // 验证时间格式
      expect(find.text('25:00'), findsOneWidget);
    });
  });

  group('ProgressCirclePainter Tests', () {
    test('should create painter with correct properties', () {
      final painter = ProgressCirclePainter(
        progress: 0.5,
        strokeWidth: 8,
        backgroundColor: Colors.grey,
        progressColor: Colors.blue,
      );

      expect(painter.progress, 0.5);
      expect(painter.strokeWidth, 8.0);
      expect(painter.backgroundColor, Colors.grey);
      expect(painter.progressColor, Colors.blue);
    });

    test('should repaint when properties change', () {
      final painter1 = ProgressCirclePainter(
        progress: 0.5,
        strokeWidth: 8,
        backgroundColor: Colors.grey,
        progressColor: Colors.blue,
      );

      final painter2 = ProgressCirclePainter(
        progress: 0.7,
        strokeWidth: 8,
        backgroundColor: Colors.grey,
        progressColor: Colors.blue,
      );

      expect(painter1.shouldRepaint(painter2), true);
    });

    test('should not repaint when properties are same', () {
      final painter1 = ProgressCirclePainter(
        progress: 0.5,
        strokeWidth: 8,
        backgroundColor: Colors.grey,
        progressColor: Colors.blue,
      );

      final painter2 = ProgressCirclePainter(
        progress: 0.5,
        strokeWidth: 8,
        backgroundColor: Colors.grey,
        progressColor: Colors.blue,
      );

      expect(painter1.shouldRepaint(painter2), false);
    });

    test('should handle edge cases correctly', () {
      // 测试边界值
      final painter1 = ProgressCirclePainter(
        progress: 0,
        strokeWidth: 1,
        backgroundColor: Colors.transparent,
        progressColor: Colors.black,
      );

      final painter2 = ProgressCirclePainter(
        progress: 1,
        strokeWidth: 20,
        backgroundColor: Colors.white,
        progressColor: Colors.red,
      );

      expect(painter1.progress, 0.0);
      expect(painter2.progress, 1.0);
      expect(painter1.shouldRepaint(painter2), true);
    });
  });
}
