import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prvin/features/ai/presentation/pages/ai_analytics_page.dart';

void main() {
  group('AIAnalyticsPage', () {
    testWidgets('should create without errors', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: AIAnalyticsPage()));

      // 验证页面创建成功
      expect(find.byType(AIAnalyticsPage), findsOneWidget);

      // 等待异步操作完成
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // 验证基本UI元素存在
      expect(find.text('AI智能分析'), findsOneWidget);
    });

    testWidgets('should display tabs after loading', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: AIAnalyticsPage()));

      // 等待加载完成
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // 验证Tab存在
      expect(find.text('概览'), findsOneWidget);
      expect(find.text('趋势'), findsOneWidget);
      expect(find.text('建议'), findsOneWidget);
    });
  });
}
