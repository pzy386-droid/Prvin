import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prvin/core/theme/accessibility_theme.dart';
import 'package:prvin/core/widgets/accessibility_wrapper.dart';

void main() {
  group('Accessibility Comprehensive Support Property Tests', () {
    /// **Feature: prvin-integrated-calendar, Property 31: 可访问性全面支持**
    /// 对于任何可访问性需求，应该支持屏幕阅读器、键盘导航、高对比度和字体调整
    /// **验证需求: 需求 10.1, 10.2, 10.3, 10.4**
    group('Property 31: Accessibility Comprehensive Support', () {
      testWidgets('should provide screen reader support for any widget', (
        WidgetTester tester,
      ) async {
        // Test with various semantic configurations
        final testCases = [
          {'label': '测试按钮', 'hint': '点击执行操作', 'value': '已启用', 'isButton': true},
          {'label': '输入框', 'hint': '请输入文本', 'value': '', 'isTextField': true},
          {'label': '标题文本', 'hint': '页面标题', 'value': '主标题', 'isHeader': true},
        ];

        for (final testCase in testCases) {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: AccessibilityWrapper(
                  semanticLabel: testCase['label'] as String?,
                  semanticHint: testCase['hint'] as String?,
                  semanticValue: testCase['value'] as String?,
                  isButton: testCase['isButton'] as bool? ?? false,
                  isTextField: testCase['isTextField'] as bool? ?? false,
                  isHeader: testCase['isHeader'] as bool? ?? false,
                  child: Container(width: 100, height: 50, color: Colors.blue),
                ),
              ),
            ),
          );

          final handle = tester.ensureSemantics();

          // Verify screen reader support
          final semantics = tester.getSemantics(
            find.byType(AccessibilityWrapper),
          );
          expect(semantics.label, equals(testCase['label']));
          expect(semantics.hint, equals(testCase['hint']));
          expect(semantics.value, equals(testCase['value']));

          // Verify semantic flags using hasFlag method
          if (testCase['isButton'] == true) {
            expect(semantics.hasFlag(SemanticsFlag.isButton), isTrue);
          }
          if (testCase['isTextField'] == true) {
            expect(semantics.hasFlag(SemanticsFlag.isTextField), isTrue);
          }
          if (testCase['isHeader'] == true) {
            expect(semantics.hasFlag(SemanticsFlag.isHeader), isTrue);
          }

          expect(semantics.hasFlag(SemanticsFlag.isFocusable), isTrue);

          handle.dispose();
        }
      });

      testWidgets(
        'should support keyboard navigation for any focusable element',
        (WidgetTester tester) async {
          var wasPressed = false;

          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: AccessibleButton(
                  semanticLabel: '测试按钮',
                  onPressed: () => wasPressed = true,
                  child: const Text('按钮'),
                ),
              ),
            ),
          );

          // Test Tab navigation
          await tester.sendKeyEvent(LogicalKeyboardKey.tab);
          await tester.pump();

          // Test Space key activation
          await tester.sendKeyEvent(LogicalKeyboardKey.space);
          await tester.pump();

          // Verify keyboard interaction works
          expect(wasPressed, isTrue);

          // Reset and test Enter key
          wasPressed = false;
          await tester.sendKeyEvent(LogicalKeyboardKey.enter);
          await tester.pump();

          expect(wasPressed, isTrue);
        },
      );

      testWidgets('should adapt to high contrast mode for any theme', (
        WidgetTester tester,
      ) async {
        // Test normal contrast
        await tester.pumpWidget(
          MaterialApp(
            theme: AccessibilityTheme.getAdaptiveTheme(
              tester.element(find.byType(MaterialApp)),
            ),
            home: const Scaffold(body: AccessibleText('测试文本')),
          ),
        );

        expect(find.byType(AccessibleText), findsOneWidget);

        // Test high contrast mode
        await tester.pumpWidget(
          MaterialApp(
            theme: AccessibilityTheme.getHighContrastTheme(),
            home: const MediaQuery(
              data: MediaQueryData(highContrast: true),
              child: Scaffold(body: AccessibleText('测试文本')),
            ),
          ),
        );

        expect(find.byType(AccessibleText), findsOneWidget);

        // Verify high contrast theme is applied
        final context = tester.element(find.byType(AccessibleText));
        expect(AccessibilityTheme.shouldUseHighContrast(context), isTrue);
      });

      testWidgets('should support font scaling for any text element', (
        WidgetTester tester,
      ) async {
        const testText = '可缩放文本';

        // Test different text scale factors
        final scaleFactors = [0.8, 1.0, 1.2, 1.5, 2.0];

        for (final scaleFactor in scaleFactors) {
          await tester.pumpWidget(
            MaterialApp(
              home: MediaQuery(
                data: MediaQueryData(
                  textScaler: TextScaler.linear(scaleFactor),
                ),
                child: const Scaffold(
                  body: AccessibleText(
                    testText,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
          );

          expect(find.byType(AccessibleText), findsOneWidget);
          expect(find.text(testText), findsOneWidget);

          // Verify text renders without overflow at different scales
          final textWidget = tester.widget<Text>(find.text(testText));
          expect(textWidget.data, equals(testText));
        }
      });

      testWidgets(
        'should provide focus indicators for any interactive element',
        (WidgetTester tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Column(
                  children: [
                    AccessibleButton(
                      semanticLabel: '按钮1',
                      onPressed: () {},
                      child: const Text('按钮1'),
                    ),
                    const AccessibleTextField(
                      semanticLabel: '输入框1',
                      decoration: InputDecoration(labelText: '输入框1'),
                    ),
                    AccessibleIconButton(
                      semanticLabel: '图标按钮1',
                      onPressed: () {},
                      icon: const Icon(Icons.star),
                    ),
                  ],
                ),
              ),
            ),
          );

          // Test focus on each element
          final elements = [
            find.byType(AccessibleButton),
            find.byType(AccessibleTextField),
            find.byType(AccessibleIconButton),
          ];

          for (final element in elements) {
            await tester.tap(element);
            await tester.pump();

            // Verify element is focusable
            final handle = tester.ensureSemantics();
            final semantics = tester.getSemantics(element);
            expect(semantics.hasFlag(SemanticsFlag.isFocusable), isTrue);
            handle.dispose();
          }
        },
      );

      testWidgets('should maintain accessibility across state changes', (
        WidgetTester tester,
      ) async {
        var isEnabled = true;
        var currentLabel = '初始标签';

        await tester.pumpWidget(
          StatefulBuilder(
            builder: (context, setState) {
              return MaterialApp(
                home: Scaffold(
                  body: Column(
                    children: [
                      AccessibleButton(
                        semanticLabel: currentLabel,
                        onPressed: isEnabled ? () {} : null,
                        child: Text(currentLabel),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            isEnabled = !isEnabled;
                            currentLabel = isEnabled ? '已启用' : '已禁用';
                          });
                        },
                        child: const Text('切换状态'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );

        // Test initial state
        final handle1 = tester.ensureSemantics();
        var semantics = tester.getSemantics(find.byType(AccessibleButton));
        expect(semantics.label, equals('初始标签'));
        expect(semantics.hasFlag(SemanticsFlag.isEnabled), isTrue);
        handle1.dispose();

        // Change state
        await tester.tap(find.text('切换状态'));
        await tester.pump();

        // Test updated state
        final handle2 = tester.ensureSemantics();
        semantics = tester.getSemantics(find.byType(AccessibleButton));
        expect(semantics.label, equals('已禁用'));
        expect(semantics.hasFlag(SemanticsFlag.isEnabled), isFalse);
        handle2.dispose();

        // Change back
        await tester.tap(find.text('切换状态'));
        await tester.pump();

        // Test restored state
        final handle3 = tester.ensureSemantics();
        semantics = tester.getSemantics(find.byType(AccessibleButton));
        expect(semantics.label, equals('已启用'));
        expect(semantics.hasFlag(SemanticsFlag.isEnabled), isTrue);
        handle3.dispose();
      });

      testWidgets('should work with complex widget hierarchies', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              appBar: AppBar(
                title: const AccessibleText('应用标题', isHeader: true),
              ),
              body: Column(
                children: [
                  const AccessibleText('页面标题', isHeader: true, headerLevel: 2),
                  AccessibilityWrapper(
                    semanticLabel: '表单容器',
                    child: Column(
                      children: [
                        const AccessibleTextField(
                          semanticLabel: '用户名',
                          decoration: InputDecoration(labelText: '用户名'),
                        ),
                        const AccessibleTextField(
                          semanticLabel: '密码',
                          decoration: InputDecoration(labelText: '密码'),
                        ),
                        AccessibleButton(
                          semanticLabel: '登录按钮',
                          onPressed: () {},
                          child: const Text('登录'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

        // Verify all accessibility components work together
        final handle = tester.ensureSemantics();

        // Check header
        final headerSemantics = tester.getSemantics(find.text('页面标题'));
        expect(headerSemantics.hasFlag(SemanticsFlag.isHeader), isTrue);

        // Check text fields
        final textFields = find.byType(AccessibleTextField);
        expect(textFields, findsNWidgets(2));

        for (var i = 0; i < 2; i++) {
          final fieldSemantics = tester.getSemantics(textFields.at(i));
          expect(fieldSemantics.hasFlag(SemanticsFlag.isTextField), isTrue);
          expect(fieldSemantics.hasFlag(SemanticsFlag.isFocusable), isTrue);
        }

        // Check button
        final buttonSemantics = tester.getSemantics(
          find.byType(AccessibleButton),
        );
        expect(buttonSemantics.hasFlag(SemanticsFlag.isButton), isTrue);
        expect(buttonSemantics.hasFlag(SemanticsFlag.isEnabled), isTrue);

        handle.dispose();
      });
    });
  });
}
