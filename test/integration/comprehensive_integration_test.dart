
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prvin/core/bloc/app_bloc.dart';
import 'package:prvin/core/widgets/one_click_language_toggle_button.dart';
import 'package:prvin/features/task_management/data/repositories/task_repository_impl.dart';
import 'package:prvin/features/task_management/domain/usecases/task_usecases.dart';
import 'package:prvin/features/task_management/presentation/bloc/task_bloc.dart';
import 'package:prvin/integrated_calendar_with_pomodoro.dart';

void main() {
  group('Comprehensive Integration Tests', () {
    late AppBloc appBloc;
    late TaskBloc taskBloc;

    setUp(() {
      appBloc = AppBloc();
      final repository = TaskRepositoryImpl();
      final useCases = TaskUseCases(repository);
      taskBloc = TaskBloc(useCases);
    });

    tearDown(() {
      appBloc.close();
      taskBloc.close();
    });

    /// 创建完整的测试应用环境
    Widget createTestApp({
      AppState? initialAppState,
      Size? screenSize,
      Brightness? brightness,
      bool highContrast = false,
    }) {
      if (initialAppState != null) {
        appBloc.emit(initialAppState);
      }

      return MaterialApp(
        theme: ThemeData(
          brightness: brightness ?? Brightness.light,
          useMaterial3: true,
          fontFamily: '.SF Pro Display',
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF4FC3F7),
            brightness: brightness ?? Brightness.light,
          ),
        ),
        home: MediaQuery(
          data: MediaQueryData(
            size: screenSize ?? const Size(400, 800),
            devicePixelRatio: 2,
            highContrast: highContrast,
          ),
          child: MultiBlocProvider(
            providers: [
              BlocProvider<AppBloc>.value(value: appBloc),
              BlocProvider<TaskBloc>.value(value: taskBloc),
            ],
            child: const IntegratedCalendarWithPomodoroPage(),
          ),
        ),
      );
    }

    group('Complete User Scenario Tests', () {
      testWidgets('should handle complete language switching workflow', (
        WidgetTester tester,
      ) async {
        // 设置初始状态
        appBloc.emit(const AppReadyState());

        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        // 验证初始状态
        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);
        expect(find.text('中'), findsOneWidget);

        // 执行语言切换
        await tester.tap(find.byType(OneClickLanguageToggleButton));
        await tester.pump();

        // 验证切换动画开始
        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

        // 等待动画完成
        await tester.pumpAndSettle();

        // 验证应用仍然稳定运行
        expect(find.byType(IntegratedCalendarWithPomodoroPage), findsOneWidget);
        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);
      });

      testWidgets(
        'should maintain functionality during rapid language switching',
        (WidgetTester tester) async {
          appBloc.emit(const AppReadyState());

          await tester.pumpWidget(createTestApp());
          await tester.pumpAndSettle();

          // 执行快速连续切换
          for (var i = 0; i < 5; i++) {
            await tester.tap(find.byType(OneClickLanguageToggleButton));
            await tester.pump(const Duration(milliseconds: 100));
          }

          await tester.pumpAndSettle();

          // 验证应用仍然正常工作
          expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);
          expect(
            find.byType(IntegratedCalendarWithPomodoroPage),
            findsOneWidget,
          );

          // 验证其他功能仍然可用
          expect(find.byType(BottomNavigationBar), findsOneWidget);
          expect(find.byType(FloatingActionButton), findsOneWidget);
        },
      );

      testWidgets(
        'should handle language switching while navigating between pages',
        (WidgetTester tester) async {
          appBloc.emit(const AppReadyState());

          await tester.pumpWidget(createTestApp());
          await tester.pumpAndSettle();

          // 切换到番茄钟页面
          await tester.tap(find.text('专注'));
          await tester.pumpAndSettle();

          // 在番茄钟页面执行语言切换
          await tester.tap(find.byType(OneClickLanguageToggleButton));
          await tester.pump();
          await tester.pumpAndSettle();

          // 切换回日历页面
          await tester.tap(find.text('日历'));
          await tester.pumpAndSettle();

          // 验证语言切换按钮仍然正常工作
          expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

          // 再次执行语言切换
          await tester.tap(find.byType(OneClickLanguageToggleButton));
          await tester.pump();
          await tester.pumpAndSettle();

          // 验证应用状态稳定
          expect(
            find.byType(IntegratedCalendarWithPomodoroPage),
            findsOneWidget,
          );
        },
      );

      testWidgets('should preserve task data during language switching', (
        WidgetTester tester,
      ) async {
        appBloc.emit(const AppReadyState());

        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        // 验证任务相关UI存在
        final taskElements = find.textContaining('任务');
        expect(taskElements, findsWidgets);

        // 执行语言切换
        await tester.tap(find.byType(OneClickLanguageToggleButton));
        await tester.pump();
        await tester.pumpAndSettle();

        // 验证任务数据和UI仍然存在
        expect(taskElements, findsWidgets);

        // 验证日历功能正常
        final calendarElements = find.textContaining('月');
        expect(calendarElements, findsWidgets);
      });

      testWidgets('should handle language switching during task creation', (
        WidgetTester tester,
      ) async {
        appBloc.emit(const AppReadyState());

        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        // 点击FAB开始创建任务
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pump();

        // 在任务创建过程中切换语言
        await tester.tap(find.byType(OneClickLanguageToggleButton));
        await tester.pump();
        await tester.pumpAndSettle();

        // 验证应用没有崩溃
        expect(find.byType(IntegratedCalendarWithPomodoroPage), findsOneWidget);
        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);
      });
    });

    group('Compatibility with Existing Features', () {
      testWidgets('should not interfere with calendar navigation', (
        WidgetTester tester,
      ) async {
        appBloc.emit(const AppReadyState());

        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        // 查找日历导航按钮
        final prevButton = find.byIcon(CupertinoIcons.chevron_left);
        final nextButton = find.byIcon(CupertinoIcons.chevron_right);

        expect(prevButton, findsOneWidget);
        expect(nextButton, findsOneWidget);

        // 执行语言切换
        await tester.tap(find.byType(OneClickLanguageToggleButton));
        await tester.pump();

        // 验证日历导航仍然可用
        expect(prevButton, findsOneWidget);
        expect(nextButton, findsOneWidget);

        // 测试日历导航功能
        await tester.tap(nextButton);
        await tester.pump();
        await tester.pumpAndSettle();

        // 验证导航成功且语言按钮仍然存在
        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);
      });

      testWidgets('should coexist with search and today buttons', (
        WidgetTester tester,
      ) async {
        appBloc.emit(const AppReadyState());

        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        // 验证所有头部按钮存在
        final searchButton = find.byIcon(CupertinoIcons.search);
        final todayButton = find.byIcon(CupertinoIcons.calendar_today);
        final languageButton = find.byType(OneClickLanguageToggleButton);

        expect(searchButton, findsOneWidget);
        expect(todayButton, findsOneWidget);
        expect(languageButton, findsOneWidget);

        // 测试每个按钮的交互
        await tester.tap(searchButton);
        await tester.pump();
        expect(languageButton, findsOneWidget);

        await tester.tap(languageButton);
        await tester.pump();
        expect(searchButton, findsOneWidget);
        expect(todayButton, findsOneWidget);

        await tester.tap(todayButton);
        await tester.pump();
        expect(languageButton, findsOneWidget);
      });

      testWidgets('should work correctly with bottom navigation', (
        WidgetTester tester,
      ) async {
        appBloc.emit(const AppReadyState());

        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        // 验证底部导航存在
        expect(find.byType(BottomNavigationBar), findsOneWidget);

        // 执行语言切换
        await tester.tap(find.byType(OneClickLanguageToggleButton));
        await tester.pump();

        // 验证底部导航仍然正常
        expect(find.byType(BottomNavigationBar), findsOneWidget);

        // 使用底部导航切换页面
        await tester.tap(find.text('专注'));
        await tester.pumpAndSettle();

        // 验证语言按钮在新页面仍然存在
        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

        // 切换回日历页面
        await tester.tap(find.text('日历'));
        await tester.pumpAndSettle();

        // 验证语言按钮仍然正常工作
        await tester.tap(find.byType(OneClickLanguageToggleButton));
        await tester.pump();
        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);
      });

      testWidgets('should maintain floating action button functionality', (
        WidgetTester tester,
      ) async {
        appBloc.emit(const AppReadyState());

        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        // 验证FAB存在
        expect(find.byType(FloatingActionButton), findsOneWidget);

        // 执行语言切换
        await tester.tap(find.byType(OneClickLanguageToggleButton));
        await tester.pump();

        // 验证FAB仍然存在且可用
        expect(find.byType(FloatingActionButton), findsOneWidget);

        // 测试FAB功能
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pump();

        // 验证语言按钮不受影响
        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);
      });
    });

    group('Different Device and Screen Size Adaptation', () {
      testWidgets('should work correctly on small screens (phone)', (
        WidgetTester tester,
      ) async {
        appBloc.emit(const AppReadyState());

        await tester.pumpWidget(
          createTestApp(screenSize: const Size(360, 640)),
        );
        await tester.pumpAndSettle();

        // 验证按钮在小屏幕上正确显示
        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

        final buttonSize = tester.getSize(
          find.byType(OneClickLanguageToggleButton),
        );
        expect(buttonSize.width, equals(40.0));
        expect(buttonSize.height, equals(40.0));

        // 测试功能
        await tester.tap(find.byType(OneClickLanguageToggleButton));
        await tester.pump();
        await tester.pumpAndSettle();

        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);
      });

      testWidgets('should work correctly on large screens (tablet)', (
        WidgetTester tester,
      ) async {
        appBloc.emit(const AppReadyState());

        await tester.pumpWidget(
          createTestApp(screenSize: const Size(1024, 768)),
        );
        await tester.pumpAndSettle();

        // 验证按钮在大屏幕上正确显示
        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

        // 验证布局适配
        final buttonRect = tester.getRect(
          find.byType(OneClickLanguageToggleButton),
        );
        expect(buttonRect.size.width, equals(40.0));
        expect(buttonRect.size.height, equals(40.0));

        // 测试功能
        await tester.tap(find.byType(OneClickLanguageToggleButton));
        await tester.pump();
        await tester.pumpAndSettle();

        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);
      });

      testWidgets('should maintain layout consistency across orientations', (
        WidgetTester tester,
      ) async {
        appBloc.emit(const AppReadyState());

        // 测试竖屏模式
        await tester.binding.setSurfaceSize(const Size(400, 800));
        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);
        final portraitButtonRect = tester.getRect(
          find.byType(OneClickLanguageToggleButton),
        );

        // 测试横屏模式
        await tester.binding.setSurfaceSize(const Size(800, 400));
        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);
        final landscapeButtonRect = tester.getRect(
          find.byType(OneClickLanguageToggleButton),
        );

        // 验证按钮尺寸在不同方向下保持一致
        expect(portraitButtonRect.size, equals(landscapeButtonRect.size));

        // 测试功能在横屏模式下正常工作
        await tester.tap(find.byType(OneClickLanguageToggleButton));
        await tester.pump();
        await tester.pumpAndSettle();

        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

        // 恢复默认尺寸
        await tester.binding.setSurfaceSize(null);
      });

      testWidgets('should adapt to different pixel densities', (
        WidgetTester tester,
      ) async {
        appBloc.emit(const AppReadyState());

        // 测试高密度屏幕
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(
                size: Size(400, 800),
                devicePixelRatio: 3, // 高密度
              ),
              child: MultiBlocProvider(
                providers: [
                  BlocProvider<AppBloc>.value(value: appBloc),
                  BlocProvider<TaskBloc>.value(value: taskBloc),
                ],
                child: const IntegratedCalendarWithPomodoroPage(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

        // 测试功能
        await tester.tap(find.byType(OneClickLanguageToggleButton));
        await tester.pump();
        await tester.pumpAndSettle();

        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);
      });
    });

    group('Theme and Accessibility Adaptation', () {
      testWidgets('should work correctly with light theme', (
        WidgetTester tester,
      ) async {
        appBloc.emit(const AppReadyState());

        await tester.pumpWidget(createTestApp(brightness: Brightness.light));
        await tester.pumpAndSettle();

        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

        // 测试功能
        await tester.tap(find.byType(OneClickLanguageToggleButton));
        await tester.pump();
        await tester.pumpAndSettle();

        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);
      });

      testWidgets('should work correctly with dark theme', (
        WidgetTester tester,
      ) async {
        appBloc.emit(const AppReadyState());

        await tester.pumpWidget(createTestApp(brightness: Brightness.dark));
        await tester.pumpAndSettle();

        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

        // 测试功能
        await tester.tap(find.byType(OneClickLanguageToggleButton));
        await tester.pump();
        await tester.pumpAndSettle();

        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);
      });

      testWidgets('should adapt to high contrast mode', (
        WidgetTester tester,
      ) async {
        appBloc.emit(const AppReadyState());

        await tester.pumpWidget(createTestApp(highContrast: true));
        await tester.pumpAndSettle();

        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

        // 测试功能
        await tester.tap(find.byType(OneClickLanguageToggleButton));
        await tester.pump();
        await tester.pumpAndSettle();

        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);
      });

      testWidgets('should support keyboard navigation', (
        WidgetTester tester,
      ) async {
        appBloc.emit(const AppReadyState());

        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        // 获取按钮的焦点
        final buttonFinder = find.byType(OneClickLanguageToggleButton);
        expect(buttonFinder, findsOneWidget);

        // 模拟Tab键导航到按钮
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();

        // 模拟空格键激活按钮
        await tester.sendKeyEvent(LogicalKeyboardKey.space);
        await tester.pump();
        await tester.pumpAndSettle();

        // 验证按钮仍然存在
        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);
      });

      testWidgets('should provide proper semantic information', (
        WidgetTester tester,
      ) async {
        appBloc.emit(const AppReadyState());

        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        // 验证按钮具有适当的语义信息
        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

        final semantics = tester.getSemantics(
          find.byType(OneClickLanguageToggleButton),
        );
        expect(semantics, isNotNull);
      });
    });

    group('Error Handling and Recovery', () {
      testWidgets('should handle app state errors gracefully', (
        WidgetTester tester,
      ) async {
        // 设置错误状态
        appBloc.emit(const AppErrorState('Test error'));

        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        // 验证应用不会崩溃
        expect(find.byType(IntegratedCalendarWithPomodoroPage), findsOneWidget);
        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

        // 验证按钮在错误状态下仍然可以交互
        await tester.tap(find.byType(OneClickLanguageToggleButton));
        await tester.pump();

        // 验证应用仍然稳定
        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);
      });

      testWidgets('should recover from loading states', (
        WidgetTester tester,
      ) async {
        appBloc.emit(const AppLoadingState());

        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        // 验证加载状态下的表现
        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

        // 恢复到正常状态
        appBloc.emit(const AppReadyState());
        await tester.pumpAndSettle();

        // 验证按钮恢复正常功能
        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

        await tester.tap(find.byType(OneClickLanguageToggleButton));
        await tester.pump();
        await tester.pumpAndSettle();

        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);
      });

      testWidgets('should handle rapid state changes', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        // 快速切换应用状态
        for (var i = 0; i < 5; i++) {
          appBloc.emit(const AppLoadingState());
          await tester.pump(const Duration(milliseconds: 50));

          appBloc.emit(const AppReadyState());
          await tester.pump(const Duration(milliseconds: 50));
        }

        await tester.pumpAndSettle();

        // 验证应用仍然稳定
        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);
        expect(find.byType(IntegratedCalendarWithPomodoroPage), findsOneWidget);
      });
    });

    group('Performance and Memory Tests', () {
      testWidgets('should not cause memory leaks during repeated operations', (
        WidgetTester tester,
      ) async {
        appBloc.emit(const AppReadyState());

        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        // 执行多次语言切换操作
        for (var i = 0; i < 10; i++) {
          await tester.tap(find.byType(OneClickLanguageToggleButton));
          await tester.pump(const Duration(milliseconds: 100));
        }

        await tester.pumpAndSettle();

        // 验证应用仍然响应正常
        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);
        expect(find.byType(IntegratedCalendarWithPomodoroPage), findsOneWidget);

        // 检查内存使用情况
        final memoryStats = OneClickLanguageToggleButton.getMemoryStats();
        expect(memoryStats, isNotNull);

        // 检查是否有内存泄漏
        final memoryLeaks = OneClickLanguageToggleButton.detectMemoryLeaks();
        expect(memoryLeaks, isEmpty);
      });

      testWidgets(
        'should maintain good performance during intensive operations',
        (WidgetTester tester) async {
          appBloc.emit(const AppReadyState());

          await tester.pumpWidget(createTestApp());
          await tester.pumpAndSettle();

          // 执行密集操作
          for (var i = 0; i < 20; i++) {
            await tester.tap(find.byType(OneClickLanguageToggleButton));
            await tester.pump(const Duration(milliseconds: 50));

            // 同时进行其他操作
            await tester.tap(find.byIcon(CupertinoIcons.search));
            await tester.pump(const Duration(milliseconds: 25));
          }

          await tester.pumpAndSettle();

          // 验证性能状态
          final performanceReport =
              OneClickLanguageToggleButton.getPerformanceReport();
          expect(performanceReport, isNotNull);
          expect(
            performanceReport.fpsStats.currentFps,
            greaterThanOrEqualTo(30),
          );

          // 验证应用仍然稳定
          expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);
        },
      );

      testWidgets('should handle animation performance correctly', (
        WidgetTester tester,
      ) async {
        appBloc.emit(const AppReadyState());

        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        // 检查动画性能状态
        final animationStatus =
            OneClickLanguageToggleButton.getAnimationPerformanceStatus();
        expect(animationStatus, isNotNull);

        // 执行动画操作
        await tester.tap(find.byType(OneClickLanguageToggleButton));
        await tester.pump();

        // 检查动画状态一致性
        final animationReport =
            OneClickLanguageToggleButton.getAnimationStateReport();
        expect(animationReport, isNotNull);

        await tester.pumpAndSettle();

        // 验证所有动画都处于稳定状态
        final areAnimationsStable =
            OneClickLanguageToggleButton.areAnimationsStable();
        expect(areAnimationsStable, isTrue);
      });
    });

    group('User Experience Validation', () {
      testWidgets('should provide smooth visual feedback', (
        WidgetTester tester,
      ) async {
        appBloc.emit(const AppReadyState());

        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        // 测试点击反馈
        await tester.tap(find.byType(OneClickLanguageToggleButton));
        await tester.pump(const Duration(milliseconds: 100));

        // 验证按钮仍然存在（动画进行中）
        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

        await tester.pumpAndSettle();

        // 验证最终状态
        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);
      });

      testWidgets('should maintain consistent visual hierarchy', (
        WidgetTester tester,
      ) async {
        appBloc.emit(const AppReadyState());

        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        // 验证按钮在正确的视觉层次中
        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);
        expect(find.byType(SliverAppBar), findsOneWidget);

        // 验证按钮不会遮挡重要内容
        final monthText = find.textContaining('月');
        expect(monthText, findsWidgets);

        final languageButtonRect = tester.getRect(
          find.byType(OneClickLanguageToggleButton),
        );

        // 验证按钮位置合理
        expect(languageButtonRect.center.dx, greaterThan(200));
      });

      testWidgets(
        'should provide appropriate feedback for different interactions',
        (WidgetTester tester) async {
          appBloc.emit(const AppReadyState());

          await tester.pumpWidget(createTestApp());
          await tester.pumpAndSettle();

          final buttonFinder = find.byType(OneClickLanguageToggleButton);

          // 测试点击交互
          await tester.tap(buttonFinder);
          await tester.pump();
          expect(buttonFinder, findsOneWidget);

          await tester.pumpAndSettle();

          // 测试长按交互（如果支持）
          await tester.longPress(buttonFinder);
          await tester.pump();
          expect(buttonFinder, findsOneWidget);

          await tester.pumpAndSettle();
        },
      );

      testWidgets('should integrate seamlessly with app navigation flow', (
        WidgetTester tester,
      ) async {
        appBloc.emit(const AppReadyState());

        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        // 测试完整的导航流程
        // 1. 在日历页面切换语言
        await tester.tap(find.byType(OneClickLanguageToggleButton));
        await tester.pump();
        await tester.pumpAndSettle();

        // 2. 导航到番茄钟页面
        await tester.tap(find.text('专注'));
        await tester.pumpAndSettle();

        // 3. 在番茄钟页面切换语言
        await tester.tap(find.byType(OneClickLanguageToggleButton));
        await tester.pump();
        await tester.pumpAndSettle();

        // 4. 返回日历页面
        await tester.tap(find.text('日历'));
        await tester.pumpAndSettle();

        // 验证整个流程中应用保持稳定
        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);
        expect(find.byType(IntegratedCalendarWithPomodoroPage), findsOneWidget);
      });
    });

    group('Edge Cases and Boundary Conditions', () {
      testWidgets('should handle widget disposal during animation', (
        WidgetTester tester,
      ) async {
        appBloc.emit(const AppReadyState());

        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        // 开始动画
        await tester.tap(find.byType(OneClickLanguageToggleButton));
        await tester.pump(const Duration(milliseconds: 50));

        // 立即销毁widget
        await tester.pumpWidget(Container());
        await tester.pumpAndSettle();

        // 验证没有异常抛出
        expect(tester.takeException(), isNull);
      });

      testWidgets('should handle rapid widget rebuilds', (
        WidgetTester tester,
      ) async {
        appBloc.emit(const AppReadyState());

        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        // 快速重建widget
        for (var i = 0; i < 10; i++) {
          await tester.pumpWidget(createTestApp());
          await tester.pump(const Duration(milliseconds: 10));
        }

        await tester.pumpAndSettle();

        // 验证按钮仍然正常工作
        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

        await tester.tap(find.byType(OneClickLanguageToggleButton));
        await tester.pump();
        await tester.pumpAndSettle();

        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);
      });

      testWidgets('should handle concurrent state changes', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        // 同时触发多个状态变化
        appBloc.emit(const AppReadyState());
        appBloc.emit(const AppReadyState(languageCode: 'en'));
        appBloc.emit(const AppReadyState());

        await tester.pump();
        await tester.pumpAndSettle();

        // 验证应用处理并发状态变化
        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);
        expect(find.byType(IntegratedCalendarWithPomodoroPage), findsOneWidget);
      });
    });
  });
}
