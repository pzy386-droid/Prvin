import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prvin/core/bloc/app_bloc.dart';
import 'package:prvin/core/widgets/one_click_language_toggle_button.dart';

/// **Feature: one-click-language-toggle, Property 6: 动画状态一致性**
/// *对于任何*语言切换动画，动画完成后按钮应该处于稳定状态，显示正确的语言标识
/// **Validates: Requirements 1.5, 2.4**

void main() {
  group('Animation State Consistency Property Tests', () {
    late AppBloc appBloc;
    late Faker faker;

    setUp(() {
      appBloc = AppBloc();
      faker = Faker();
    });

    tearDown(() {
      appBloc.close();
    });

    testWidgets(
      'Property 6: 动画状态一致性 - animation completion should result in stable button state',
      (WidgetTester tester) async {
        // **Feature: one-click-language-toggle, Property 6: 动画状态一致性**

        // 运行50次迭代以确保属性在各种输入下都成立
        for (var iteration = 0; iteration < 50; iteration++) {
          // 生成随机的初始语言状态
          final initialLanguage = _generateRandomLanguageState(faker);

          // 设置初始状态
          appBloc.emit(AppReadyState(languageCode: initialLanguage));

          // 创建测试应用
          await tester.pumpWidget(
            MaterialApp(
              home: BlocProvider<AppBloc>.value(
                value: appBloc,
                child: const Scaffold(
                  body: Center(child: OneClickLanguageToggleButton()),
                ),
              ),
            ),
          );

          // 查找语言切换按钮
          final buttonFinder = find.byType(OneClickLanguageToggleButton);
          expect(buttonFinder, findsOneWidget);

          // 验证初始状态显示正确
          final initialDisplayText = _getExpectedDisplayText(initialLanguage);
          expect(find.text(initialDisplayText), findsOneWidget);

          // 模拟点击按钮触发动画
          await tester.tap(buttonFinder);
          await tester.pump(); // 开始动画

          // 等待动画进行中的状态
          await tester.pump(const Duration(milliseconds: 50));
          await tester.pump(const Duration(milliseconds: 100));
          await tester.pump(const Duration(milliseconds: 150));

          // 等待动画完全完成
          await tester.pumpAndSettle();

          // 验证动画完成后的状态一致性
          // 属性验证：动画完成后按钮应该处于稳定状态
          final buttonWidget = tester.widget<OneClickLanguageToggleButton>(
            buttonFinder,
          );
          expect(buttonWidget, isNotNull);

          // 验证只有一个语言标识显示（状态一致性的关键指标）
          final chineseDisplayCount = tester.widgetList(find.text('中')).length;
          final englishDisplayCount = tester.widgetList(find.text('EN')).length;

          expect(
            chineseDisplayCount + englishDisplayCount,
            equals(1),
            reason:
                'Only one language display should be visible after animation completion. '
                'Found Chinese: $chineseDisplayCount, English: $englishDisplayCount '
                'in iteration $iteration',
          );

          // 验证按钮可以继续响应交互（稳定状态的表现）
          final buttonElement = tester.element(buttonFinder);
          expect(
            buttonElement.mounted,
            isTrue,
            reason:
                'Button should remain mounted and interactive after animation',
          );

          // 清理状态以准备下一次迭代
          await tester.pumpWidget(Container());
          await tester.pumpAndSettle();
        }
      },
    );

    testWidgets(
      'Property 6: 动画状态一致性 - rapid consecutive animations should maintain consistency',
      (WidgetTester tester) async {
        // **Feature: one-click-language-toggle, Property 6: 动画状态一致性**

        // 测试快速连续动画的状态一致性
        for (var iteration = 0; iteration < 25; iteration++) {
          final initialLanguage = _generateRandomLanguageState(faker);

          // 生成随机的快速点击次数 (2-5次)
          final rapidClickCount = faker.randomGenerator.integer(4) + 2;

          appBloc.emit(AppReadyState(languageCode: initialLanguage));

          // 创建测试应用
          await tester.pumpWidget(
            MaterialApp(
              home: BlocProvider<AppBloc>.value(
                value: appBloc,
                child: const Scaffold(
                  body: Center(child: OneClickLanguageToggleButton()),
                ),
              ),
            ),
          );

          final buttonFinder = find.byType(OneClickLanguageToggleButton);
          expect(buttonFinder, findsOneWidget);

          // 执行快速连续点击
          for (var i = 0; i < rapidClickCount; i++) {
            await tester.tap(buttonFinder);
            await tester.pump(const Duration(milliseconds: 20)); // 很短的间隔
          }

          // 等待所有动画完成
          await tester.pumpAndSettle();

          // 验证最终状态一致性
          // 属性验证：快速连续动画后应该只有一个语言显示
          final allTextWidgets = tester.widgetList(find.byType(Text));
          final displayTexts = allTextWidgets
              .map((widget) => (widget as Text).data)
              .where((text) => text == '中' || text == 'EN')
              .toList();

          expect(
            displayTexts.length,
            equals(1),
            reason:
                'Should have exactly one language display after rapid animations. '
                'Found displays: $displayTexts in iteration $iteration',
          );

          // 验证按钮仍然可交互
          final buttonElement = tester.element(buttonFinder);
          expect(
            buttonElement.mounted,
            isTrue,
            reason: 'Button should remain interactive after rapid animations',
          );

          // 清理状态
          await tester.pumpWidget(Container());
          await tester.pumpAndSettle();
        }
      },
    );

    testWidgets(
      'Property 6: 动画状态一致性 - animation interruption should recover to stable state',
      (WidgetTester tester) async {
        // **Feature: one-click-language-toggle, Property 6: 动画状态一致性**

        // 测试动画中断后的状态恢复
        for (var iteration = 0; iteration < 20; iteration++) {
          final initialLanguage = _generateRandomLanguageState(faker);

          appBloc.emit(AppReadyState(languageCode: initialLanguage));

          // 创建测试应用
          await tester.pumpWidget(
            MaterialApp(
              home: BlocProvider<AppBloc>.value(
                value: appBloc,
                child: const Scaffold(
                  body: Center(child: OneClickLanguageToggleButton()),
                ),
              ),
            ),
          );

          final buttonFinder = find.byType(OneClickLanguageToggleButton);
          expect(buttonFinder, findsOneWidget);

          // 开始动画
          await tester.tap(buttonFinder);
          await tester.pump();

          // 在动画进行中模拟中断（例如快速重新构建）
          final interruptionDelay = Duration(
            milliseconds: faker.randomGenerator.integer(150) + 25,
          );
          await tester.pump(interruptionDelay);

          // 强制重新构建来模拟中断
          await tester.pumpWidget(
            MaterialApp(
              home: BlocProvider<AppBloc>.value(
                value: appBloc,
                child: const Scaffold(
                  body: Center(child: OneClickLanguageToggleButton()),
                ),
              ),
            ),
          );

          // 等待恢复到稳定状态
          await tester.pumpAndSettle();

          // 验证恢复后的状态一致性
          // 属性验证：动画中断后应该恢复到稳定状态
          final chineseCount = tester.widgetList(find.text('中')).length;
          final englishCount = tester.widgetList(find.text('EN')).length;

          expect(
            chineseCount + englishCount,
            equals(1),
            reason:
                'Should have exactly one language display after recovery. '
                'Found Chinese: $chineseCount, English: $englishCount '
                'after interruption at ${interruptionDelay.inMilliseconds}ms '
                'in iteration $iteration',
          );

          // 验证按钮恢复到可交互状态
          final buttonElement = tester.element(buttonFinder);
          expect(
            buttonElement.mounted,
            isTrue,
            reason: 'Button should be mounted and interactive after recovery',
          );

          // 清理状态
          await tester.pumpWidget(Container());
          await tester.pumpAndSettle();
        }
      },
    );

    testWidgets(
      'Property 6: 动画状态一致性 - animation state should be consistent across different durations',
      (WidgetTester tester) async {
        // **Feature: one-click-language-toggle, Property 6: 动画状态一致性**

        // 测试不同动画时长下的状态一致性
        for (var iteration = 0; iteration < 15; iteration++) {
          final initialLanguage = _generateRandomLanguageState(faker);

          appBloc.emit(AppReadyState(languageCode: initialLanguage));

          // 生成随机的动画时长
          final animationDuration = Duration(
            milliseconds: faker.randomGenerator.integer(400) + 100,
          );

          // 创建带有自定义动画时长的测试应用
          await tester.pumpWidget(
            MaterialApp(
              home: BlocProvider<AppBloc>.value(
                value: appBloc,
                child: Scaffold(
                  body: Center(
                    child: OneClickLanguageToggleButton(
                      animationDuration: animationDuration,
                    ),
                  ),
                ),
              ),
            ),
          );

          final buttonFinder = find.byType(OneClickLanguageToggleButton);
          expect(buttonFinder, findsOneWidget);

          // 触发动画
          await tester.tap(buttonFinder);
          await tester.pump();

          // 等待动画完成
          await tester.pumpAndSettle();

          // 验证动画完成后的状态一致性
          // 属性验证：无论动画时长如何，完成后都应该有稳定的状态
          final chineseCount = tester.widgetList(find.text('中')).length;
          final englishCount = tester.widgetList(find.text('EN')).length;

          expect(
            chineseCount + englishCount,
            equals(1),
            reason:
                'Should have exactly one language display regardless of animation duration. '
                'Found Chinese: $chineseCount, English: $englishCount '
                'with duration ${animationDuration.inMilliseconds}ms '
                'in iteration $iteration',
          );

          // 验证按钮状态稳定
          final buttonWidget = tester.widget<OneClickLanguageToggleButton>(
            buttonFinder,
          );
          expect(buttonWidget.animationDuration, equals(animationDuration));

          // 清理状态
          await tester.pumpWidget(Container());
          await tester.pumpAndSettle();
        }
      },
    );
  });
}

/// 生成随机的语言状态
String _generateRandomLanguageState(Faker faker) {
  return faker.randomGenerator.boolean() ? 'zh' : 'en';
}

/// 获取预期的显示文本
String _getExpectedDisplayText(String languageCode) {
  return languageCode == 'zh' ? '中' : 'EN';
}
