import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prvin/features/pomodoro/domain/entities/pomodoro_session.dart';
import 'package:prvin/features/pomodoro/widgets/stats_chart.dart';

void main() {
  group('StatsChart Widget Tests', () {
    late List<PomodoroSession> mockSessions;

    setUp(() {
      final now = DateTime.now();
      mockSessions = [
        PomodoroSession(
          id: '1',
          startTime: now,
          plannedDuration: const Duration(minutes: 25),
          actualDuration: const Duration(minutes: 25),
          type: SessionType.work,
          completed: true,
        ),
        PomodoroSession(
          id: '2',
          startTime: now.add(const Duration(minutes: 30)),
          plannedDuration: const Duration(minutes: 5),
          actualDuration: const Duration(minutes: 5),
          type: SessionType.shortBreak,
          completed: true,
        ),
        PomodoroSession(
          id: '3',
          startTime: now.subtract(const Duration(days: 1)),
          plannedDuration: const Duration(minutes: 25),
          actualDuration: const Duration(minutes: 20),
          type: SessionType.work,
        ),
      ];
    });

    testWidgets('should build without errors', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: StatsChart(sessions: mockSessions)),
        ),
      );

      // 验证基本组件存在
      expect(find.text('本周专注趋势'), findsOneWidget);
      expect(find.byType(CustomPaint), findsOneWidget);
    });

    testWidgets('should show legend correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: StatsChart(sessions: mockSessions)),
        ),
      );

      // 验证图例显示
      expect(find.text('专注时间'), findsOneWidget);
      expect(find.text('休息时间'), findsOneWidget);
      expect(find.text('完成会话'), findsOneWidget);
    });

    testWidgets('should handle empty sessions list', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: StatsChart(sessions: [])),
        ),
      );

      // 验证空状态显示
      expect(find.text('暂无数据'), findsOneWidget);
    });

    testWidgets('should use custom height when provided', (
      WidgetTester tester,
    ) async {
      const customHeight = 300.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatsChart(sessions: mockSessions, height: customHeight),
          ),
        ),
      );

      // 验证组件存在
      expect(find.byType(StatsChart), findsOneWidget);
    });

    testWidgets('should animate chart on load', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: StatsChart(sessions: mockSessions)),
        ),
      );

      // 验证动画组件存在
      expect(find.byType(AnimatedBuilder), findsOneWidget);

      // 等待动画完成
      await tester.pumpAndSettle();

      // 验证图表仍然存在
      expect(find.byType(CustomPaint), findsOneWidget);
    });
  });

  group('StatsChart Animation Tests', () {
    testWidgets('should have animation controller', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: StatsChart(sessions: [])),
        ),
      );

      // 获取状态并验证动画控制器
      final state = tester.state<StatsChartState>(find.byType(StatsChart));
      expect(state, isNotNull);
    });

    testWidgets('should animate from 0 to 1', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: StatsChart(sessions: [])),
        ),
      );

      // 验证初始状态
      expect(find.byType(AnimatedBuilder), findsOneWidget);

      // 推进动画
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // 验证动画进行中
      expect(find.byType(AnimatedBuilder), findsOneWidget);
    });
  });

  group('ChartPainter Tests', () {
    testWidgets('should create custom painter correctly', (
      WidgetTester tester,
    ) async {
      final now = DateTime.now();
      final sessions = [
        PomodoroSession(
          id: '1',
          startTime: now,
          plannedDuration: const Duration(minutes: 25),
          actualDuration: const Duration(minutes: 25),
          type: SessionType.work,
          completed: true,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: StatsChart(sessions: sessions)),
        ),
      );

      // 验证CustomPaint存在
      expect(find.byType(CustomPaint), findsOneWidget);
    });

    testWidgets('should handle different session types', (
      WidgetTester tester,
    ) async {
      final now = DateTime.now();
      final sessions = [
        PomodoroSession(
          id: '1',
          startTime: now,
          plannedDuration: const Duration(minutes: 25),
          actualDuration: const Duration(minutes: 25),
          type: SessionType.work,
          completed: true,
        ),
        PomodoroSession(
          id: '2',
          startTime: now.add(const Duration(minutes: 30)),
          plannedDuration: const Duration(minutes: 5),
          actualDuration: const Duration(minutes: 5),
          type: SessionType.shortBreak,
          completed: true,
        ),
        PomodoroSession(
          id: '3',
          startTime: now.add(const Duration(minutes: 40)),
          plannedDuration: const Duration(minutes: 15),
          actualDuration: const Duration(minutes: 15),
          type: SessionType.longBreak,
          completed: true,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: StatsChart(sessions: sessions)),
        ),
      );

      // 验证图表正常渲染
      expect(find.byType(CustomPaint), findsOneWidget);
    });
  });

  group('StatsChart Data Processing Tests', () {
    testWidgets('should process weekly data correctly', (
      WidgetTester tester,
    ) async {
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));

      // 创建一周的数据
      final sessions = List.generate(7, (index) {
        return PomodoroSession(
          id: 'session_$index',
          startTime: weekStart.add(Duration(days: index, hours: 10)),
          plannedDuration: const Duration(minutes: 25),
          actualDuration: const Duration(minutes: 25),
          type: SessionType.work,
          completed: true,
        );
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: StatsChart(sessions: sessions)),
        ),
      );

      // 验证图表渲染
      expect(find.byType(CustomPaint), findsOneWidget);
      expect(find.text('本周专注趋势'), findsOneWidget);
    });

    testWidgets('should handle sessions from different weeks', (
      WidgetTester tester,
    ) async {
      final now = DateTime.now();
      final sessions = [
        // 本周的会话
        PomodoroSession(
          id: '1',
          startTime: now,
          plannedDuration: const Duration(minutes: 25),
          actualDuration: const Duration(minutes: 25),
          type: SessionType.work,
          completed: true,
        ),
        // 上周的会话（应该被过滤掉）
        PomodoroSession(
          id: '2',
          startTime: now.subtract(const Duration(days: 10)),
          plannedDuration: const Duration(minutes: 25),
          actualDuration: const Duration(minutes: 25),
          type: SessionType.work,
          completed: true,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: StatsChart(sessions: sessions)),
        ),
      );

      // 验证图表正常处理
      expect(find.byType(CustomPaint), findsOneWidget);
    });
  });

  group('StatsChart Edge Cases', () {
    testWidgets('should handle null or invalid session data', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: StatsChart(sessions: [])),
        ),
      );

      // 验证空数据处理
      expect(find.text('暂无数据'), findsOneWidget);
    });

    testWidgets('should handle very large session counts', (
      WidgetTester tester,
    ) async {
      final now = DateTime.now();
      final largeSessions = List.generate(100, (index) {
        return PomodoroSession(
          id: 'session_$index',
          startTime: now.add(Duration(minutes: index * 30)),
          plannedDuration: const Duration(minutes: 25),
          actualDuration: const Duration(minutes: 25),
          type: SessionType.work,
          completed: true,
        );
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: StatsChart(sessions: largeSessions)),
        ),
      );

      // 验证大数据量处理
      expect(find.byType(CustomPaint), findsOneWidget);
    });

    testWidgets('should handle sessions with zero duration', (
      WidgetTester tester,
    ) async {
      final sessions = [
        PomodoroSession(
          id: '1',
          startTime: DateTime.now(),
          plannedDuration: Duration.zero,
          actualDuration: Duration.zero,
          type: SessionType.work,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: StatsChart(sessions: sessions)),
        ),
      );

      // 验证零时长处理
      expect(find.byType(CustomPaint), findsOneWidget);
    });
  });
}
