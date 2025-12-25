import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prvin/core/widgets/one_click_language_toggle_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('OneClickLanguageToggleButton Simple Tests', () {
    setUp(() async {
      // 设置SharedPreferences的mock
      SharedPreferences.setMockInitialValues({'app_language_code': 'zh'});
    });

    /// 创建简单的测试用Widget包装器
    Widget createSimpleTestWidget({Widget? child}) {
      return MaterialApp(
        home: Scaffold(body: child ?? const OneClickLanguageToggleButton()),
      );
    }

    group('Basic Rendering Tests', () {
      testWidgets('should render button widget', (WidgetTester tester) async {
        await tester.pumpWidget(createSimpleTestWidget());
        await tester.pump();

        // 验证按钮存在
        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);
      });

      testWidgets('should render with custom size', (
        WidgetTester tester,
      ) async {
        const customSize = 60.0;
        await tester.pumpWidget(
          createSimpleTestWidget(
            child: const OneClickLanguageToggleButton(size: customSize),
          ),
        );
        await tester.pump();

        // 验证按钮尺寸设置正确
        final buttonWidget = tester.widget<OneClickLanguageToggleButton>(
          find.byType(OneClickLanguageToggleButton),
        );
        expect(buttonWidget.size, equals(customSize));
      });

      testWidgets('should have proper widget structure', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(createSimpleTestWidget());
        await tester.pump();

        // 验证基本组件结构存在
        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);
        expect(find.byType(AnimatedContainer), findsWidgets);
        expect(find.byType(InkWell), findsOneWidget);
      });

      testWidgets('should respond to tap gestures', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(createSimpleTestWidget());
        await tester.pump();

        // 模拟点击
        await tester.tap(find.byType(OneClickLanguageToggleButton));
        await tester.pump();

        // 验证按钮仍然存在（基本响应测试）
        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);
      });
    });
  });
}
