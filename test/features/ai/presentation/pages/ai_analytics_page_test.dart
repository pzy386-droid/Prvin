import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prvin/features/ai/presentation/pages/ai_analytics_page.dart';

void main() {
  group('AIAnalyticsPage', () {
    testWidgets('should display loading indicator initially', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: AIAnalyticsPage()));

      // 验证加载指示器存在
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('正在分析您的数据...'), findsOneWidget);
    });

    testWidgets('should display analytics content after loading', (
      tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: AIAnalyticsPage()));

      // 等待加载完成
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // 验证标题存在
      expect(find.text('AI智能分析'), findsOneWidget);

      // 验证Tab存在
      expect(find.text('概览'), findsOneWidget);
      expect(find.text('趋势'), findsOneWidget);
      expect(find.text('建议'), findsOneWidget);
    });

    testWidgets('should navigate between tabs', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: AIAnalyticsPage()));

      // 等待加载完成
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // 点击趋势Tab
      await tester.tap(find.text('趋势'));
      await tester.pumpAndSettle();

      // 验证趋势内容显示
      expect(find.text('生产力趋势'), findsOneWidget);

      // 点击建议Tab
      await tester.tap(find.text('建议'));
      await tester.pumpAndSettle();

      // 验证建议内容显示
      expect(find.text('AI智能建议'), findsOneWidget);
    });

    testWidgets('should show settings dialog when settings button is tapped', (
      tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: AIAnalyticsPage()));

      // 等待加载完成
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // 点击设置按钮
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // 验证设置对话框显示
      expect(find.text('分析设置'), findsOneWidget);
      expect(find.text('分析周期'), findsOneWidget);
      expect(find.text('数据导出'), findsOneWidget);
      expect(find.text('刷新数据'), findsOneWidget);
    });

    testWidgets('should refresh data when refresh button is tapped', (
      tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: AIAnalyticsPage()));

      // 等待加载完成
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // 打开设置对话框
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // 点击刷新数据
      await tester.tap(find.text('刷新数据'));
      await tester.pumpAndSettle();

      // 验证加载指示器再次出现
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
