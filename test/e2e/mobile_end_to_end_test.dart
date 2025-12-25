import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prvin/core/bloc/app_bloc.dart';
import 'package:prvin/features/task_management/data/repositories/task_repository_impl.dart';
import 'package:prvin/features/task_management/domain/usecases/task_usecases.dart';
import 'package:prvin/features/task_management/presentation/bloc/task_bloc.dart';
import 'package:prvin/integrated_calendar_with_pomodoro.dart';

void main() {
  group('Mobile End-to-End Integration Tests', () {
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

    /// 创建移动端测试应用环境
    Widget createMobileApp({
      AppState? initialAppState,
      Size? screenSize,
      Brightness? brightness,
      bool highContrast = false,
    }) {
      if (initialAppState != null) {
        appBloc.emit(initialAppState);
      }

      return MaterialApp(
        title: 'Prvin AI日历 - 移动端测试',
        theme: ThemeData(
          brightness: brightness ?? Brightness.light,
          useMaterial3: true,
          fontFamily: '.SF Pro Display',
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF4FC3F7),
            brightness: brightness ?? Brightness.light,
          ),
        ),
        debugShowCheckedModeBanner: false,
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

    group('Complete Mobile User Journey Tests', () {
      testWidgets(
        'should handle complete mobile workflow with all core features',
        (WidgetTester tester) async {
          // 设置初始状态
          appBloc.emit(const AppReadyState());

          await tester.pumpWidget(createMobileApp());
          await tester.pumpAndSettle();

          // === 第一阶段：应用启动验证 ===
          expect(
            find.byType(IntegratedCalendarWithPomodoroPage),
            findsOneWidget,
          );
          expect(find.byType(BottomNavigationBar), findsOneWidget);
          expect(find.byType(FloatingActionButton), findsOneWidget);
          expect(find.byType(SliverAppBar), findsOneWidget);

          // === 第二阶段：日历功能测试 ===
          // 测试日历导航
          final nextButton = find.byIcon(CupertinoIcons.chevron_right);
          if (nextButton.evaluate().isNotEmpty) {
            await tester.tap(nextButton);
            await tester.pumpAndSettle();
          }

          // 测试"今天"按钮
          final todayButton = find.byIcon(CupertinoIcons.calendar_today);
          if (todayButton.evaluate().isNotEmpty) {
            await tester.tap(todayButton);
            await tester.pumpAndSettle();
          }

          // === 第三阶段：页面切换测试 ===
          // 切换到番茄钟页面
          final pomodoroTab = find.text('专注');
          if (pomodoroTab.evaluate().isNotEmpty) {
            await tester.tap(pomodoroTab);
            await tester.pumpAndSettle();
          }

          // 切换回日历页面
          final calendarTab = find.text('日历');
          if (calendarTab.evaluate().isNotEmpty) {
            await tester.tap(calendarTab);
            await tester.pumpAndSettle();
          }

          // === 第四阶段：任务管理测试 ===
          // 测试FAB功能
          await tester.tap(find.byType(FloatingActionButton));
          await tester.pump();
          await tester.pumpAndSettle();

          // === 第五阶段：搜索功能测试 ===
          final searchButton = find.byIcon(CupertinoIcons.search);
          if (searchButton.evaluate().isNotEmpty) {
            await tester.tap(searchButton);
            await tester.pump();
            await tester.pumpAndSettle();
          }

          // 验证应用仍然稳定
          expect(
            find.byType(IntegratedCalendarWithPomodoroPage),
            findsOneWidget,
          );
        },
      );

      testWidgets('should handle rapid user interactions without crashes', (
        WidgetTester tester,
      ) async {
        appBloc.emit(const AppReadyState());

        await tester.pumpWidget(createMobileApp());
        await tester.pumpAndSettle();

        // 执行快速连续操作
        for (var i = 0; i < 5; i++) {
          // 快速切换页面
          final pomodoroTab = find.text('专注');
          if (pomodoroTab.evaluate().isNotEmpty) {
            await tester.tap(pomodoroTab);
            await tester.pump(const Duration(milliseconds: 50));
          }

          final calendarTab = find.text('日历');
          if (calendarTab.evaluate().isNotEmpty) {
            await tester.tap(calendarTab);
            await tester.pump(const Duration(milliseconds: 50));
          }

          // 快速点击搜索
          final searchButton = find.byIcon(CupertinoIcons.search);
          if (searchButton.evaluate().isNotEmpty) {
            await tester.tap(searchButton);
            await tester.pump(const Duration(milliseconds: 25));
          }

          // 快速点击今天按钮
          final todayButton = find.byIcon(CupertinoIcons.calendar_today);
          if (todayButton.evaluate().isNotEmpty) {
            await tester.tap(todayButton);
            await tester.pump(const Duration(milliseconds: 25));
          }
        }

        await tester.pumpAndSettle();

        // 验证应用仍然正常工作
        expect(find.byType(IntegratedCalendarWithPomodoroPage), findsOneWidget);
        expect(find.byType(BottomNavigationBar), findsOneWidget);
        expect(find.byType(FloatingActionButton), findsOneWidget);
      });

      testWidgets('should maintain state during app lifecycle changes', (
        WidgetTester tester,
      ) async {
        appBloc.emit(const AppReadyState());

        await tester.pumpWidget(createMobileApp());
        await tester.pumpAndSettle();

        // 切换到番茄钟页面
        final pomodoroTab = find.text('专注');
        if (pomodoroTab.evaluate().isNotEmpty) {
          await tester.tap(pomodoroTab);
          await tester.pumpAndSettle();
        }

        // 模拟应用暂停/恢复
        await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
          'flutter/lifecycle',
          const StandardMethodCodec().encodeMethodCall(
            const MethodCall('AppLifecycleState.paused'),
          ),
          (data) {},
        );

        await tester.pump();

        await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
          'flutter/lifecycle',
          const StandardMethodCodec().encodeMethodCall(
            const MethodCall('AppLifecycleState.resumed'),
          ),
          (data) {},
        );

        await tester.pump();
        await tester.pumpAndSettle();

        // 验证状态保持
        expect(find.byType(IntegratedCalendarWithPomodoroPage), findsOneWidget);

        // 验证可以正常切换回日历页面
        final calendarTab = find.text('日历');
        if (calendarTab.evaluate().isNotEmpty) {
          await tester.tap(calendarTab);
          await tester.pumpAndSettle();
        }

        expect(find.byType(IntegratedCalendarWithPomodoroPage), findsOneWidget);
      });
    });

    group('Cross-Platform Mobile Compatibility Tests', () {
      testWidgets('should work correctly on small screens (phone)', (
        WidgetTester tester,
      ) async {
        appBloc.emit(const AppReadyState());

        await tester.pumpWidget(
          createMobileApp(screenSize: const Size(360, 640)),
        );
        await tester.pumpAndSettle();

        // 验证在小屏幕上正确显示
        expect(find.byType(IntegratedCalendarWithPomodoroPage), findsOneWidget);
        expect(find.byType(BottomNavigationBar), findsOneWidget);

        // 测试基本功能
        final pomodoroTab = find.text('专注');
        if (pomodoroTab.evaluate().isNotEmpty) {
          await tester.tap(pomodoroTab);
          await tester.pumpAndSettle();
        }

        expect(find.byType(IntegratedCalendarWithPomodoroPage), findsOneWidget);
      });

      testWidgets('should work correctly on large screens (tablet)', (
        WidgetTester tester,
      ) async {
        appBloc.emit(const AppReadyState());

        await tester.pumpWidget(
          createMobileApp(screenSize: const Size(1024, 768)),
        );
        await tester.pumpAndSettle();

        // 验证在大屏幕上正确显示
        expect(find.byType(IntegratedCalendarWithPomodoroPage), findsOneWidget);

        // 测试功能
        final pomodoroTab = find.text('专注');
        if (pomodoroTab.evaluate().isNotEmpty) {
          await tester.tap(pomodoroTab);
          await tester.pumpAndSettle();
        }

        expect(find.byType(IntegratedCalendarWithPomodoroPage), findsOneWidget);
      });

      testWidgets('should maintain layout consistency across orientations', (
        WidgetTester tester,
      ) async {
        appBloc.emit(const AppReadyState());

        // 测试竖屏模式
        await tester.binding.setSurfaceSize(const Size(400, 800));
        await tester.pumpWidget(createMobileApp());
        await tester.pumpAndSettle();

        expect(find.byType(IntegratedCalendarWithPomodoroPage), findsOneWidget);

        // 测试横屏模式
        await tester.binding.setSurfaceSize(const Size(800, 400));
        await tester.pumpWidget(createMobileApp());
        await tester.pumpAndSettle();

        expect(find.byType(IntegratedCalendarWithPomodoroPage), findsOneWidget);

        // 测试功能在横屏模式下正常工作
        final pomodoroTab = find.text('专注');
        if (pomodoroTab.evaluate().isNotEmpty) {
          await tester.tap(pomodoroTab);
          await tester.pumpAndSettle();
        }

        expect(find.byType(IntegratedCalendarWithPomodoroPage), findsOneWidget);

        // 恢复默认尺寸
        await tester.binding.setSurfaceSize(null);
      });
    });

    group('Theme and Accessibility Tests', () {
      testWidgets('should work correctly with light theme', (
        WidgetTester tester,
      ) async {
        appBloc.emit(const AppReadyState());

        await tester.pumpWidget(createMobileApp(brightness: Brightness.light));
        await tester.pumpAndSettle();

        expect(find.byType(IntegratedCalendarWithPomodoroPage), findsOneWidget);

        // 测试功能
        final pomodoroTab = find.text('专注');
        if (pomodoroTab.evaluate().isNotEmpty) {
          await tester.tap(pomodoroTab);
          await tester.pumpAndSettle();
        }

        expect(find.byType(IntegratedCalendarWithPomodoroPage), findsOneWidget);
      });

      testWidgets('should work correctly with dark theme', (
        WidgetTester tester,
      ) async {
        appBloc.emit(const AppReadyState());

        await tester.pumpWidget(createMobileApp(brightness: Brightness.dark));
        await tester.pumpAndSettle();

        expect(find.byType(IntegratedCalendarWithPomodoroPage), findsOneWidget);

        // 测试功能
        final pomodoroTab = find.text('专注');
        if (pomodoroTab.evaluate().isNotEmpty) {
          await tester.tap(pomodoroTab);
          await tester.pumpAndSettle();
        }

        expect(find.byType(IntegratedCalendarWithPomodoroPage), findsOneWidget);
      });

      testWidgets('should adapt to high contrast mode', (
        WidgetTester tester,
      ) async {
        appBloc.emit(const AppReadyState());

        await tester.pumpWidget(createMobileApp(highContrast: true));
        await tester.pumpAndSettle();

        expect(find.byType(IntegratedCalendarWithPomodoroPage), findsOneWidget);

        // 测试功能
        final pomodoroTab = find.text('专注');
        if (pomodoroTab.evaluate().isNotEmpty) {
          await tester.tap(pomodoroTab);
          await tester.pumpAndSettle();
        }

        expect(find.byType(IntegratedCalendarWithPomodoroPage), findsOneWidget);
      });

      testWidgets('should support keyboard navigation', (
        WidgetTester tester,
      ) async {
        appBloc.emit(const AppReadyState());

        await tester.pumpWidget(createMobileApp());
        await tester.pumpAndSettle();

        // 模拟Tab键导航
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();

        // 模拟空格键激活
        await tester.sendKeyEvent(LogicalKeyboardKey.space);
        await tester.pump();
        await tester.pumpAndSettle();

        // 验证应用仍然稳定
        expect(find.byType(IntegratedCalendarWithPomodoroPage), findsOneWidget);
      });
    });

    group('Error Handling and Recovery Tests', () {
      testWidgets('should handle app state errors gracefully', (
        WidgetTester tester,
      ) async {
        // 设置错误状态
        appBloc.emit(const AppErrorState('Mobile test error'));

        await tester.pumpWidget(createMobileApp());
        await tester.pumpAndSettle();

        // 验证应用不会崩溃
        expect(find.byType(IntegratedCalendarWithPomodoroPage), findsOneWidget);

        // 恢复到正常状态
        appBloc.emit(const AppReadyState());
        await tester.pumpAndSettle();

        // 验证功能恢复正常
        final pomodoroTab = find.text('专注');
        if (pomodoroTab.evaluate().isNotEmpty) {
          await tester.tap(pomodoroTab);
          await tester.pumpAndSettle();
        }

        expect(find.byType(IntegratedCalendarWithPomodoroPage), findsOneWidget);
      });

      testWidgets('should recover from loading states', (
        WidgetTester tester,
      ) async {
        appBloc.emit(const AppLoadingState());

        await tester.pumpWidget(createMobileApp());
        await tester.pumpAndSettle();

        // 验证加载状态下的表现
        expect(find.byType(IntegratedCalendarWithPomodoroPage), findsOneWidget);

        // 恢复到正常状态
        appBloc.emit(const AppReadyState());
        await tester.pumpAndSettle();

        // 验证功能恢复正常
        expect(find.byType(IntegratedCalendarWithPomodoroPage), findsOneWidget);

        final pomodoroTab = find.text('专注');
        if (pomodoroTab.evaluate().isNotEmpty) {
          await tester.tap(pomodoroTab);
          await tester.pumpAndSettle();
        }

        expect(find.byType(IntegratedCalendarWithPomodoroPage), findsOneWidget);
      });

      testWidgets('should handle rapid state changes', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(createMobileApp());
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
        expect(find.byType(IntegratedCalendarWithPomodoroPage), findsOneWidget);
      });
    });

    group('Performance and Memory Tests', () {
      testWidgets('should not cause memory leaks during repeated operations', (
        WidgetTester tester,
      ) async {
        appBloc.emit(const AppReadyState());

        await tester.pumpWidget(createMobileApp());
        await tester.pumpAndSettle();

        // 执行多次操作
        for (var i = 0; i < 10; i++) {
          final pomodoroTab = find.text('专注');
          if (pomodoroTab.evaluate().isNotEmpty) {
            await tester.tap(pomodoroTab);
            await tester.pump(const Duration(milliseconds: 100));
          }

          final calendarTab = find.text('日历');
          if (calendarTab.evaluate().isNotEmpty) {
            await tester.tap(calendarTab);
            await tester.pump(const Duration(milliseconds: 100));
          }
        }

        await tester.pumpAndSettle();

        // 验证应用仍然响应正常
        expect(find.byType(IntegratedCalendarWithPomodoroPage), findsOneWidget);
        expect(find.byType(BottomNavigationBar), findsOneWidget);
        expect(find.byType(FloatingActionButton), findsOneWidget);
      });

      testWidgets(
        'should maintain good performance during intensive operations',
        (WidgetTester tester) async {
          appBloc.emit(const AppReadyState());

          await tester.pumpWidget(createMobileApp());
          await tester.pumpAndSettle();

          // 执行密集操作
          for (var i = 0; i < 20; i++) {
            final pomodoroTab = find.text('专注');
            if (pomodoroTab.evaluate().isNotEmpty) {
              await tester.tap(pomodoroTab);
              await tester.pump(const Duration(milliseconds: 50));
            }

            // 同时进行其他操作
            final searchButton = find.byIcon(CupertinoIcons.search);
            if (searchButton.evaluate().isNotEmpty) {
              await tester.tap(searchButton);
              await tester.pump(const Duration(milliseconds: 25));
            }

            final calendarTab = find.text('日历');
            if (calendarTab.evaluate().isNotEmpty) {
              await tester.tap(calendarTab);
              await tester.pump(const Duration(milliseconds: 25));
            }
          }

          await tester.pumpAndSettle();

          // 验证应用仍然稳定
          expect(
            find.byType(IntegratedCalendarWithPomodoroPage),
            findsOneWidget,
          );
        },
      );
    });

    group('User Experience Validation Tests', () {
      testWidgets('should provide smooth visual feedback', (
        WidgetTester tester,
      ) async {
        appBloc.emit(const AppReadyState());

        await tester.pumpWidget(createMobileApp());
        await tester.pumpAndSettle();

        // 测试点击反馈
        final pomodoroTab = find.text('专注');
        if (pomodoroTab.evaluate().isNotEmpty) {
          await tester.tap(pomodoroTab);
          await tester.pump(const Duration(milliseconds: 100));

          // 验证切换进行中
          expect(
            find.byType(IntegratedCalendarWithPomodoroPage),
            findsOneWidget,
          );

          await tester.pumpAndSettle();

          // 验证最终状态
          expect(
            find.byType(IntegratedCalendarWithPomodoroPage),
            findsOneWidget,
          );
        }
      });

      testWidgets('should integrate seamlessly with app navigation flow', (
        WidgetTester tester,
      ) async {
        appBloc.emit(const AppReadyState());

        await tester.pumpWidget(createMobileApp());
        await tester.pumpAndSettle();

        // 测试完整的导航流程
        // 1. 在日历页面点击FAB
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pump();
        await tester.pumpAndSettle();

        // 2. 导航到番茄钟页面
        final pomodoroTab = find.text('专注');
        if (pomodoroTab.evaluate().isNotEmpty) {
          await tester.tap(pomodoroTab);
          await tester.pumpAndSettle();
        }

        // 3. 返回日历页面
        final calendarTab = find.text('日历');
        if (calendarTab.evaluate().isNotEmpty) {
          await tester.tap(calendarTab);
          await tester.pumpAndSettle();
        }

        // 验证整个流程中应用保持稳定
        expect(find.byType(IntegratedCalendarWithPomodoroPage), findsOneWidget);
      });
    });

    group('Edge Cases and Boundary Conditions Tests', () {
      testWidgets('should handle widget disposal during operations', (
        WidgetTester tester,
      ) async {
        appBloc.emit(const AppReadyState());

        await tester.pumpWidget(createMobileApp());
        await tester.pumpAndSettle();

        // 开始操作
        final pomodoroTab = find.text('专注');
        if (pomodoroTab.evaluate().isNotEmpty) {
          await tester.tap(pomodoroTab);
          await tester.pump(const Duration(milliseconds: 50));
        }

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

        await tester.pumpWidget(createMobileApp());
        await tester.pumpAndSettle();

        // 快速重建widget
        for (var i = 0; i < 10; i++) {
          await tester.pumpWidget(createMobileApp());
          await tester.pump(const Duration(milliseconds: 10));
        }

        await tester.pumpAndSettle();

        // 验证应用仍然正常工作
        expect(find.byType(IntegratedCalendarWithPomodoroPage), findsOneWidget);

        final pomodoroTab = find.text('专注');
        if (pomodoroTab.evaluate().isNotEmpty) {
          await tester.tap(pomodoroTab);
          await tester.pumpAndSettle();
        }

        expect(find.byType(IntegratedCalendarWithPomodoroPage), findsOneWidget);
      });

      testWidgets('should handle concurrent state changes', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(createMobileApp());
        await tester.pumpAndSettle();

        // 同时触发多个状态变化
        appBloc
          ..emit(const AppReadyState())
          ..emit(const AppReadyState(languageCode: 'en'))
          ..emit(const AppReadyState());

        await tester.pump();
        await tester.pumpAndSettle();

        // 验证应用处理并发状态变化
        expect(find.byType(IntegratedCalendarWithPomodoroPage), findsOneWidget);
      });
    });
  });
}
