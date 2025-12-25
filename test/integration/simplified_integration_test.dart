
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
  group('Simplified Integration Tests', () {
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

    group('Basic Integration Tests', () {
      testWidgets('should render all main components correctly', (
        WidgetTester tester,
      ) async {
        // 设置初始状态
        appBloc.emit(const AppReadyState());

        await tester.pumpWidget(createTestApp());
        await tester.pump();

        // 验证主要组件存在
        expect(find.byType(IntegratedCalendarWithPomodoroPage), findsOneWidget);
        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);
        expect(find.byType(BottomNavigationBar), findsOneWidget);
        expect(find.byType(FloatingActionButton), findsOneWidget);
        expect(find.byType(SliverAppBar), findsOneWidget);

        // 验证初始语言状态
        expect(find.text('中'), findsOneWidget);
      });

      testWidgets('should handle basic language toggle interaction', (
        WidgetTester tester,
      ) async {
        appBloc.emit(const AppReadyState());

        await tester.pumpWidget(createTestApp());
        await tester.pump();

        // 验证按钮存在
        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

        // 执行点击操作
        await tester.tap(find.byType(OneClickLanguageToggleButton));
        await tester.pump();

        // 验证按钮仍然存在（不会崩溃）
        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);
        expect(find.byType(IntegratedCalendarWithPomodoroPage), findsOneWidget);
      });

      testWidgets('should maintain component layout consistency', (
        WidgetTester tester,
      ) async {
        appBloc.emit(const AppReadyState());

        await tester.pumpWidget(createTestApp());
        await tester.pump();

        // 验证头部按钮布局
        final searchButton = find.byIcon(CupertinoIcons.search);
        final languageButton = find.byType(OneClickLanguageToggleButton);
        final todayButton = find.byIcon(CupertinoIcons.calendar_today);

        expect(searchButton, findsOneWidget);
        expect(languageButton, findsOneWidget);
        expect(todayButton, findsOneWidget);

        // 验证按钮尺寸
        final buttonSize = tester.getSize(languageButton);
        expect(buttonSize.width, equals(40.0));
        expect(buttonSize.height, equals(40.0));

        // 验证按钮位置合理
        final buttonRect = tester.getRect(languageButton);
        expect(buttonRect.center.dx, greaterThan(200)); // 在屏幕右侧
      });

      testWidgets('should handle multiple interactions without crashing', (
        WidgetTester tester,
      ) async {
        appBloc.emit(const AppReadyState());

        await tester.pumpWidget(createTestApp());
        await tester.pump();

        // 执行多次交互
        for (var i = 0; i < 3; i++) {
          // 点击语言切换按钮
          await tester.tap(find.byType(OneClickLanguageToggleButton));
          await tester.pump();

          // 点击搜索按钮
          await tester.tap(find.byIcon(CupertinoIcons.search));
          await tester.pump();

          // 点击今天按钮
          await tester.tap(find.byIcon(CupertinoIcons.calendar_today));
          await tester.pump();

          // 验证应用仍然稳定
          expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);
          expect(
            find.byType(IntegratedCalendarWithPomodoroPage),
            findsOneWidget,
          );
        }
      });

      testWidgets('should work with bottom navigation', (
        WidgetTester tester,
      ) async {
        appBloc.emit(const AppReadyState());

        await tester.pumpWidget(createTestApp());
        await tester.pump();

        // 验证底部导航存在
        expect(find.byType(BottomNavigationBar), findsOneWidget);

        // 切换到番茄钟页面
        await tester.tap(find.text('专注'));
        await tester.pump();

        // 验证语言按钮在新页面仍然存在
        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

        // 在番茄钟页面测试语言切换
        await tester.tap(find.byType(OneClickLanguageToggleButton));
        await tester.pump();

        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

        // 切换回日历页面
        await tester.tap(find.text('日历'));
        await tester.pump();

        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);
      });

      testWidgets('should handle FAB interaction correctly', (
        WidgetTester tester,
      ) async {
        appBloc.emit(const AppReadyState());

        await tester.pumpWidget(createTestApp());
        await tester.pump();

        // 验证FAB存在
        expect(find.byType(FloatingActionButton), findsOneWidget);

        // 点击FAB
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pump();

        // 验证语言按钮不受影响
        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

        // 测试语言切换仍然工作
        await tester.tap(find.byType(OneClickLanguageToggleButton));
        await tester.pump();

        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);
      });
    });

    group('Screen Size Adaptation Tests', () {
      testWidgets('should work on small screens', (WidgetTester tester) async {
        appBloc.emit(const AppReadyState());

        await tester.pumpWidget(
          createTestApp(screenSize: const Size(320, 568)),
        );
        await tester.pump();

        // 验证组件在小屏幕上正确显示
        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

        final buttonSize = tester.getSize(
          find.byType(OneClickLanguageToggleButton),
        );
        expect(buttonSize.width, equals(40.0));
        expect(buttonSize.height, equals(40.0));

        // 测试功能
        await tester.tap(find.byType(OneClickLanguageToggleButton));
        await tester.pump();

        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);
      });

      testWidgets('should work on large screens', (WidgetTester tester) async {
        appBloc.emit(const AppReadyState());

        await tester.pumpWidget(
          createTestApp(screenSize: const Size(1024, 768)),
        );
        await tester.pump();

        // 验证组件在大屏幕上正确显示
        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

        final buttonSize = tester.getSize(
          find.byType(OneClickLanguageToggleButton),
        );
        expect(buttonSize.width, equals(40.0));
        expect(buttonSize.height, equals(40.0));

        // 测试功能
        await tester.tap(find.byType(OneClickLanguageToggleButton));
        await tester.pump();

        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);
      });

      testWidgets('should handle orientation changes', (
        WidgetTester tester,
      ) async {
        appBloc.emit(const AppReadyState());

        // 竖屏模式
        await tester.binding.setSurfaceSize(const Size(400, 800));
        await tester.pumpWidget(createTestApp());
        await tester.pump();

        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

        // 横屏模式
        await tester.binding.setSurfaceSize(const Size(800, 400));
        await tester.pumpWidget(createTestApp());
        await tester.pump();

        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

        // 测试功能
        await tester.tap(find.byType(OneClickLanguageToggleButton));
        await tester.pump();

        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

        // 恢复默认尺寸
        await tester.binding.setSurfaceSize(null);
      });
    });

    group('Theme Adaptation Tests', () {
      testWidgets('should work with light theme', (WidgetTester tester) async {
        appBloc.emit(const AppReadyState());

        await tester.pumpWidget(createTestApp(brightness: Brightness.light));
        await tester.pump();

        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

        // 测试功能
        await tester.tap(find.byType(OneClickLanguageToggleButton));
        await tester.pump();

        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);
      });

      testWidgets('should work with dark theme', (WidgetTester tester) async {
        appBloc.emit(const AppReadyState());

        await tester.pumpWidget(createTestApp(brightness: Brightness.dark));
        await tester.pump();

        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

        // 测试功能
        await tester.tap(find.byType(OneClickLanguageToggleButton));
        await tester.pump();

        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);
      });

      testWidgets('should work with high contrast mode', (
        WidgetTester tester,
      ) async {
        appBloc.emit(const AppReadyState());

        await tester.pumpWidget(createTestApp(highContrast: true));
        await tester.pump();

        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

        // 测试功能
        await tester.tap(find.byType(OneClickLanguageToggleButton));
        await tester.pump();

        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);
      });
    });

    group('Error Handling Tests', () {
      testWidgets('should handle error states gracefully', (
        WidgetTester tester,
      ) async {
        // 设置错误状态
        appBloc.emit(const AppErrorState('Test error'));

        await tester.pumpWidget(createTestApp());
        await tester.pump();

        // 验证应用不会崩溃
        expect(find.byType(IntegratedCalendarWithPomodoroPage), findsOneWidget);
        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

        // 验证按钮在错误状态下仍然可以交互
        await tester.tap(find.byType(OneClickLanguageToggleButton));
        await tester.pump();

        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);
      });

      testWidgets('should recover from loading states', (
        WidgetTester tester,
      ) async {
        appBloc.emit(const AppLoadingState());

        await tester.pumpWidget(createTestApp());
        await tester.pump();

        // 验证加载状态下的表现
        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

        // 恢复到正常状态
        appBloc.emit(const AppReadyState());
        await tester.pump();

        // 验证按钮恢复正常功能
        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

        await tester.tap(find.byType(OneClickLanguageToggleButton));
        await tester.pump();

        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);
      });

      testWidgets('should handle rapid state changes', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(createTestApp());
        await tester.pump();

        // 快速切换应用状态
        for (var i = 0; i < 3; i++) {
          appBloc.emit(const AppLoadingState());
          await tester.pump();

          appBloc.emit(const AppReadyState());
          await tester.pump();
        }

        // 验证应用仍然稳定
        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);
        expect(find.byType(IntegratedCalendarWithPomodoroPage), findsOneWidget);
      });
    });

    group('Accessibility Tests', () {
      testWidgets('should support keyboard navigation', (
        WidgetTester tester,
      ) async {
        appBloc.emit(const AppReadyState());

        await tester.pumpWidget(createTestApp());
        await tester.pump();

        // 模拟Tab键导航
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();

        // 模拟空格键激活
        await tester.sendKeyEvent(LogicalKeyboardKey.space);
        await tester.pump();

        // 验证按钮仍然存在
        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);
      });

      testWidgets('should provide semantic information', (
        WidgetTester tester,
      ) async {
        appBloc.emit(const AppReadyState());

        await tester.pumpWidget(createTestApp());
        await tester.pump();

        // 验证按钮具有适当的语义信息
        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

        final semantics = tester.getSemantics(
          find.byType(OneClickLanguageToggleButton),
        );
        expect(semantics, isNotNull);
      });
    });

    group('Performance Tests', () {
      testWidgets('should handle multiple rapid interactions', (
        WidgetTester tester,
      ) async {
        appBloc.emit(const AppReadyState());

        await tester.pumpWidget(createTestApp());
        await tester.pump();

        // 执行多次快速交互
        for (var i = 0; i < 10; i++) {
          await tester.tap(find.byType(OneClickLanguageToggleButton));
          await tester.pump();
        }

        // 验证应用仍然响应正常
        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);
        expect(find.byType(IntegratedCalendarWithPomodoroPage), findsOneWidget);
      });

      testWidgets('should maintain performance with concurrent operations', (
        WidgetTester tester,
      ) async {
        appBloc.emit(const AppReadyState());

        await tester.pumpWidget(createTestApp());
        await tester.pump();

        // 同时进行多种操作
        for (var i = 0; i < 5; i++) {
          await tester.tap(find.byType(OneClickLanguageToggleButton));
          await tester.pump();

          await tester.tap(find.byIcon(CupertinoIcons.search));
          await tester.pump();

          await tester.tap(find.text('专注'));
          await tester.pump();

          await tester.tap(find.text('日历'));
          await tester.pump();
        }

        // 验证应用仍然稳定
        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);
      });
    });

    group('Integration with Existing Features', () {
      testWidgets('should not interfere with calendar navigation', (
        WidgetTester tester,
      ) async {
        appBloc.emit(const AppReadyState());

        await tester.pumpWidget(createTestApp());
        await tester.pump();

        // 查找日历导航按钮
        final nextButton = find.byIcon(CupertinoIcons.chevron_right);
        expect(nextButton, findsOneWidget);

        // 执行语言切换
        await tester.tap(find.byType(OneClickLanguageToggleButton));
        await tester.pump();

        // 验证日历导航仍然可用
        expect(nextButton, findsOneWidget);

        // 测试日历导航功能
        await tester.tap(nextButton);
        await tester.pump();

        // 验证导航成功且语言按钮仍然存在
        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);
      });

      testWidgets('should preserve task-related functionality', (
        WidgetTester tester,
      ) async {
        appBloc.emit(const AppReadyState());

        await tester.pumpWidget(createTestApp());
        await tester.pump();

        // 验证任务相关UI存在
        final taskElements = find.textContaining('任务');
        expect(taskElements, findsWidgets);

        // 执行语言切换
        await tester.tap(find.byType(OneClickLanguageToggleButton));
        await tester.pump();

        // 验证任务相关功能不受影响
        expect(taskElements, findsWidgets);
      });
    });
  });
}
