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

        // 运行100次迭代以确保属性在各种输入下都成立
        for (var iteration = 0; iteration < 100; iteration++) {
          // 生成随机的初始语言状态
          final initialLanguage = _generateRandomLanguageState(faker);
          final targetLanguage = initialLanguage == 'zh' ? 'en' : 'zh';

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
          final expectedFinalDisplayText = _getExpectedDisplayText(
            targetLanguage,
          );

          // 属性验证：动画完成后按钮应该显示正确的语言标识
          expect(
            find.text(expectedFinalDisplayText),
            findsOneWidget,
            reason:
                'Animation completion should result in correct language display. '
                'Expected: $expectedFinalDisplayText for language: $targetLanguage '
                'in iteration $iteration',
          );

          // 验证按钮处于稳定状态（没有动画进行中的指示器）
          final buttonWidget = tester.widget<OneClickLanguageToggleButton>(
            buttonFinder,
          );
          expect(buttonWidget, isNotNull);

          // 验证没有多个语言标识同时显示（状态不一致的表现）
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

          // 清理状态以准备下一次迭代
          await tester.pumpWidget(Container());
          await tester.pumpAndSettle();
        }
      },
    );

    testWidgets(
      'Property 6: 动画状态一致性 - rapid consecutive toggles should maintain state consistency',
      (WidgetTester tester) async {
        // **Feature: one-click-language-toggle, Property 6: 动画状态一致性**

        // 测试快速连续切换的动画状态一致性
        for (var iteration = 0; iteration < 50; iteration++) {
          final initialLanguage = _generateRandomLanguageState(faker);

          // 生成随机的快速切换次数 (2-6次)
          final rapidToggleCount = faker.randomGenerator.integer(5) + 2;

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
          var currentLang = initialLanguage;
          for (var i = 0; i < rapidToggleCount; i++) {
            await tester.tap(buttonFinder);
            await tester.pump(const Duration(milliseconds: 10)); // 很短的间隔

            // 更新语言状态
            currentLang = currentLang == 'zh' ? 'en' : 'zh';
            appBloc.emit(AppReadyState(languageCode: currentLang));
          }

          // 等待所有动画完成
          await tester.pumpAndSettle();

          // 验证最终状态一致性
          final finalExpectedLanguage = rapidToggleCount % 2 == 0
              ? initialLanguage
              : (initialLanguage == 'zh' ? 'en' : 'zh');

          final expectedDisplayText = _getExpectedDisplayText(
            finalExpectedLanguage,
          );

          // 属性验证：快速切换后应该显示正确的最终状态
          expect(
            find.text(expectedDisplayText),
            findsOneWidget,
            reason:
                'Rapid toggles should result in consistent final state. '
                'Expected: $expectedDisplayText after $rapidToggleCount toggles '
                'starting from $initialLanguage in iteration $iteration',
          );

          // 验证状态稳定性（没有重复的显示文本）
          final allTextWidgets = tester.widgetList(find.byType(Text));
          final displayTexts = allTextWidgets
              .map((widget) => (widget as Text).data)
              .where((text) => text == '中' || text == 'EN')
              .toList();

          expect(
            displayTexts.length,
            equals(1),
            reason:
                'Should have exactly one language display after rapid toggles. '
                'Found displays: $displayTexts in iteration $iteration',
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
        for (var iteration = 0; iteration < 30; iteration++) {
          final initialLanguage = _generateRandomLanguageState(faker);
          final targetLanguage = initialLanguage == 'zh' ? 'en' : 'zh';

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
            milliseconds: faker.randomGenerator.integer(200) + 50,
          );
          await tester.pump(interruptionDelay);

          // 模拟状态更新
          appBloc.emit(AppReadyState(languageCode: targetLanguage));

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
          final expectedDisplayText = _getExpectedDisplayText(targetLanguage);

          // 属性验证：动画中断后应该恢复到正确的稳定状态
          expect(
            find.text(expectedDisplayText),
            findsOneWidget,
            reason:
                'Animation interruption should recover to stable state. '
                'Expected: $expectedDisplayText for language: $targetLanguage '
                'after interruption at ${interruptionDelay.inMilliseconds}ms '
                'in iteration $iteration',
          );

          // 验证没有状态不一致的表现
          final chineseCount = tester.widgetList(find.text('中')).length;
          final englishCount = tester.widgetList(find.text('EN')).length;

          expect(
            chineseCount + englishCount,
            equals(1),
            reason:
                'Should have exactly one language display after recovery. '
                'Found Chinese: $chineseCount, English: $englishCount '
                'in iteration $iteration',
          );

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
