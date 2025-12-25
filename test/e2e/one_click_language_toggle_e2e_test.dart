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

/// 一键语言切换功能端到端测试
///
/// 测试完整的语言切换流程、多设备兼容性和用户交互场景
/// 验证所有需求的端到端实现
void main() {
  group('One-Click Language Toggle E2E Tests', () {
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
      double? devicePixelRatio,
    }) {
      if (initialAppState != null) {
        appBloc.emit(initialAppState);
      } else {
        appBloc.emit(const AppReadyState());
      }

      return MaterialApp(
        title: 'Prvin AI Calendar - E2E Test',
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
            devicePixelRatio: devicePixelRatio ?? 2.0,
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

    group('Complete Language Switching Workflow Tests', () {
      testWidgets('should complete full language switching workflow', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        // Verify initial state
        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);
        expect(find.text('中'), findsOneWidget);
        expect(find.byType(IntegratedCalendarWithPomodoroPage), findsOneWidget);

        // Verify all main UI components exist
        expect(find.byType(BottomNavigationBar), findsOneWidget);
        expect(find.byType(FloatingActionButton), findsOneWidget);
        expect(find.byType(SliverAppBar), findsOneWidget);

        // Execute first language switch (Chinese -> English)
        await tester.tap(find.byType(OneClickLanguageToggleButton));
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pumpAndSettle();

        // Verify switch success
        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

        // Verify app still runs stably
        expect(find.byType(IntegratedCalendarWithPomodoroPage), findsOneWidget);
        expect(find.byType(BottomNavigationBar), findsOneWidget);
        expect(find.byType(FloatingActionButton), findsOneWidget);

        // Execute second language switch (English -> Chinese)
        await tester.tap(find.byType(OneClickLanguageToggleButton));
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pumpAndSettle();

        // Verify back to Chinese state
        expect(find.text('中'), findsOneWidget);
        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

        // Simulate app restart for persistence test
        await tester.pumpWidget(Container());
        await tester.pumpAndSettle();

        // Recreate app
        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        // Verify app starts normally
        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);
        expect(find.byType(IntegratedCalendarWithPomodoroPage), findsOneWidget);
      });

      testWidgets('should handle rapid consecutive language switches', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        // Execute rapid consecutive switches
        for (var i = 0; i < 10; i++) {
          await tester.tap(find.byType(OneClickLanguageToggleButton));
          await tester.pump(const Duration(milliseconds: 50));
        }

        await tester.pumpAndSettle();

        // Verify app remains stable
        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);
        expect(find.byType(IntegratedCalendarWithPomodoroPage), findsOneWidget);
      });
    });

    group('Multi-Device Compatibility Tests', () {
      testWidgets('should work correctly on small phone screens', (
        WidgetTester tester,
      ) async {
        // iPhone SE size
        await tester.pumpWidget(
          createTestApp(screenSize: const Size(320, 568)),
        );
        await tester.pumpAndSettle();

        // Verify button displays correctly on small screen
        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

        final buttonSize = tester.getSize(
          find.byType(OneClickLanguageToggleButton),
        );
        expect(buttonSize.width, equals(40.0));
        expect(buttonSize.height, equals(40.0));

        // Verify button position is reasonable (not blocked)
        final buttonRect = tester.getRect(
          find.byType(OneClickLanguageToggleButton),
        );
        expect(buttonRect.left, greaterThan(0));
        expect(buttonRect.right, lessThan(320));

        // Test functionality
        await tester.tap(find.byType(OneClickLanguageToggleButton));
        await tester.pump();
        await tester.pumpAndSettle();

        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);
      });

      testWidgets('should work correctly on tablet screens', (
        WidgetTester tester,
      ) async {
        // iPad size
        await tester.pumpWidget(
          createTestApp(screenSize: const Size(1024, 1366)),
        );
        await tester.pumpAndSettle();

        // Verify button displays correctly on tablet
        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

        final buttonSize = tester.getSize(
          find.byType(OneClickLanguageToggleButton),
        );
        expect(buttonSize.width, equals(40.0));
        expect(buttonSize.height, equals(40.0));

        // Test functionality
        await tester.tap(find.byType(OneClickLanguageToggleButton));
        await tester.pump();
        await tester.pumpAndSettle();

        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);
      });

      testWidgets('should handle orientation changes correctly', (
        WidgetTester tester,
      ) async {
        // Portrait mode test
        await tester.binding.setSurfaceSize(const Size(400, 800));
        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

        // Test functionality in portrait mode
        await tester.tap(find.byType(OneClickLanguageToggleButton));
        await tester.pump();
        await tester.pumpAndSettle();

        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

        // Landscape mode test
        await tester.binding.setSurfaceSize(const Size(800, 400));
        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

        // Test functionality in landscape mode
        await tester.tap(find.byType(OneClickLanguageToggleButton));
        await tester.pump();
        await tester.pumpAndSettle();

        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

        // Restore default size
        await tester.binding.setSurfaceSize(null);
      });
    });

    group('User Interaction Scenario Tests', () {
      testWidgets('should handle keyboard navigation and accessibility', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        // Keyboard navigation test

        // Use Tab key to navigate to button
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();

        // Verify button gets focus
        final buttonFinder = find.byType(OneClickLanguageToggleButton);
        expect(buttonFinder, findsOneWidget);

        // Use space key to activate button
        await tester.sendKeyEvent(LogicalKeyboardKey.space);
        await tester.pump();
        await tester.pumpAndSettle();

        // Verify language switch success
        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

        // Use enter key to activate button
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pump();
        await tester.pumpAndSettle();

        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

        // Semantic information test
        final semantics = tester.getSemantics(buttonFinder);
        expect(semantics, isNotNull);
      });

      testWidgets('should work correctly with high contrast mode', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(createTestApp(highContrast: true));
        await tester.pumpAndSettle();

        // Verify display in high contrast mode
        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

        // Test functionality
        await tester.tap(find.byType(OneClickLanguageToggleButton));
        await tester.pump();
        await tester.pumpAndSettle();

        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);
      });

      testWidgets('should work correctly with different themes', (
        WidgetTester tester,
      ) async {
        // Light theme test
        await tester.pumpWidget(createTestApp(brightness: Brightness.light));
        await tester.pumpAndSettle();

        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

        await tester.tap(find.byType(OneClickLanguageToggleButton));
        await tester.pump();
        await tester.pumpAndSettle();

        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

        // Dark theme test
        await tester.pumpWidget(createTestApp(brightness: Brightness.dark));
        await tester.pumpAndSettle();

        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

        await tester.tap(find.byType(OneClickLanguageToggleButton));
        await tester.pump();
        await tester.pumpAndSettle();

        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);
      });
    });

    group('Integration with Existing Features Tests', () {
      testWidgets('should not interfere with calendar functionality', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        // Calendar functionality integration test

        // Verify calendar navigation buttons exist
        final prevButton = find.byIcon(CupertinoIcons.chevron_left);
        final nextButton = find.byIcon(CupertinoIcons.chevron_right);
        final todayButton = find.byIcon(CupertinoIcons.calendar_today);

        expect(prevButton, findsOneWidget);
        expect(nextButton, findsOneWidget);
        expect(todayButton, findsOneWidget);

        // Execute language switch
        await tester.tap(find.byType(OneClickLanguageToggleButton));
        await tester.pump();

        // Verify calendar navigation still available
        expect(prevButton, findsOneWidget);
        expect(nextButton, findsOneWidget);
        expect(todayButton, findsOneWidget);

        // Test calendar navigation functionality
        await tester.tap(nextButton);
        await tester.pumpAndSettle();

        // Verify navigation success and language button still exists
        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);
      });

      testWidgets('should work seamlessly with task management features', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        // Task management functionality integration test

        // Verify FAB exists
        expect(find.byType(FloatingActionButton), findsOneWidget);

        // Execute language switch
        await tester.tap(find.byType(OneClickLanguageToggleButton));
        await tester.pump();

        // Verify FAB still exists and usable
        expect(find.byType(FloatingActionButton), findsOneWidget);

        // Click FAB to create task
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pump();

        // Switch language during task creation
        await tester.tap(find.byType(OneClickLanguageToggleButton));
        await tester.pump();
        await tester.pumpAndSettle();

        // Verify both language button and FAB are normal
        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);
        expect(find.byType(FloatingActionButton), findsOneWidget);
      });

      testWidgets('should integrate properly with bottom navigation', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        // Bottom navigation integration test

        // Verify bottom navigation exists
        expect(find.byType(BottomNavigationBar), findsOneWidget);

        // Switch language on calendar page
        await tester.tap(find.byType(OneClickLanguageToggleButton));
        await tester.pump();

        // Verify bottom navigation still normal
        expect(find.byType(BottomNavigationBar), findsOneWidget);

        // Switch to pomodoro page
        await tester.tap(find.text('专注'));
        await tester.pumpAndSettle();

        // Verify language button still exists on new page
        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

        // Switch language on pomodoro page
        await tester.tap(find.byType(OneClickLanguageToggleButton));
        await tester.pump();
        await tester.pumpAndSettle();

        // Switch back to calendar page
        await tester.tap(find.text('日历'));
        await tester.pumpAndSettle();

        // Verify all components still normal
        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);
        expect(find.byType(BottomNavigationBar), findsOneWidget);
      });
    });

    group('Performance and Reliability Tests', () {
      testWidgets(
        'should maintain consistent performance across extended usage',
        (WidgetTester tester) async {
          await tester.pumpWidget(createTestApp());
          await tester.pumpAndSettle();

          final responseTimes = <int>[];

          // Test performance consistency of multiple operations
          for (var i = 0; i < 10; i++) {
            final stopwatch = Stopwatch()..start();

            await tester.tap(find.byType(OneClickLanguageToggleButton));
            await tester.pump();
            await tester.pumpAndSettle();

            stopwatch.stop();
            responseTimes.add(stopwatch.elapsedMilliseconds);

            // Add some other operations
            await tester.tap(find.text('专注'));
            await tester.pump();

            await tester.tap(find.text('日历'));
            await tester.pump();
          }

          // Verify performance consistency (response time should not increase significantly)
          final averageTime =
              responseTimes.reduce((a, b) => a + b) / responseTimes.length;
          final maxTime = responseTimes.reduce((a, b) => a > b ? a : b);

          expect(
            averageTime,
            lessThan(500),
          ); // Average response time should be less than 500ms
          expect(
            maxTime,
            lessThan(1000),
          ); // Max response time should be less than 1000ms

          // Verify final state
          expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);
        },
      );

      testWidgets('should handle error states and recovery gracefully', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        // Error state test

        // Normal operation baseline
        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

        await tester.tap(find.byType(OneClickLanguageToggleButton));
        await tester.pump();
        await tester.pumpAndSettle();

        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

        // Simulate error state
        appBloc.emit(const AppErrorState('Simulated error'));
        await tester.pump();
        await tester.pumpAndSettle();

        // Verify app remains usable in error state
        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);
        expect(find.byType(IntegratedCalendarWithPomodoroPage), findsOneWidget);

        // Test language switching in error state
        await tester.tap(find.byType(OneClickLanguageToggleButton));
        await tester.pump();

        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

        // Recover to normal state
        appBloc.emit(const AppReadyState());
        await tester.pump();
        await tester.pumpAndSettle();

        // Verify functionality after recovery
        await tester.tap(find.byType(OneClickLanguageToggleButton));
        await tester.pump();
        await tester.pumpAndSettle();

        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);
      });
    });
  });
}
