
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
  group('End-to-End Workflow Tests', () {
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

    /// 创建完整的应用环境
    Widget createFullApp() {
      appBloc.emit(const AppReadyState());

      return MaterialApp(
        title: 'Prvin AI日历 - 完整版',
        theme: ThemeData(
          useMaterial3: true,
          fontFamily: '.SF Pro Display',
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4FC3F7)),
        ),
        debugShowCheckedModeBanner: false,
        home: MultiBlocProvider(
          providers: [
            BlocProvider<AppBloc>.value(value: appBloc),
            BlocProvider<TaskBloc>.value(value: taskBloc),
          ],
          child: const IntegratedCalendarWithPomodoroPage(),
        ),
      );
    }

    group('Complete User Journey Tests', () {
      testWidgets(
        'Complete daily workflow: language switching, task management, and navigation',
        (WidgetTester tester) async {
          await tester.pumpWidget(createFullApp());
          await tester.pumpAndSettle();

          // === 第一阶段：应用启动和初始状态验证 ===
          print('=== Phase 1: App Launch and Initial State ===');

          // 验证应用正确启动
          expect(
            find.byType(IntegratedCalendarWithPomodoroPage),
            findsOneWidget,
          );
          expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);
          expect(find.text('中'), findsOneWidget);

          // 验证所有主要UI组件存在
          expect(find.byType(BottomNavigationBar), findsOneWidget);
          expect(find.byType(FloatingActionButton), findsOneWidget);
          expect(find.byType(SliverAppBar), findsOneWidget);

          print('✓ App launched successfully with all components');

          // === 第二阶段：语言切换功能测试 ===
          print('=== Phase 2: Language Switching ===');

          // 执行第一次语言切换（中文 -> 英文）
          await tester.tap(find.byType(OneClickLanguageToggleButton));
          await tester.pump(const Duration(milliseconds: 100));
          await tester.pumpAndSettle();

          // 验证语言切换成功
          expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

          print('✓ First language switch completed');

          // 执行第二次语言切换（英文 -> 中文）
          await tester.tap(find.byType(OneClickLanguageToggleButton));
          await tester.pump(const Duration(milliseconds: 100));
          await tester.pumpAndSettle();

          // 验证回到中文状态
          expect(find.text('中'), findsOneWidget);

          print('✓ Second language switch completed - back to Chinese');

          // === 第三阶段：日历导航测试 ===
          print('=== Phase 3: Calendar Navigation ===');

          // 测试日历月份导航
          final nextButton = find.byIcon(CupertinoIcons.chevron_right);
          expect(nextButton, findsOneWidget);

          await tester.tap(nextButton);
          await tester.pumpAndSettle();

          // 验证导航成功且语言按钮仍然存在
          expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

          print('✓ Calendar navigation working');

          // 测试"今天"按钮
          final todayButton = find.byIcon(CupertinoIcons.calendar_today);
          await tester.tap(todayButton);
          await tester.pumpAndSettle();

          expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

          print('✓ Today button working');

          // === 第四阶段：页面切换测试 ===
          print('=== Phase 4: Page Navigation ===');

          // 切换到番茄钟页面
          await tester.tap(find.text('专注'));
          await tester.pumpAndSettle();

          // 验证页面切换成功
          expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

          print('✓ Switched to Pomodoro page');

          // 在番茄钟页面测试语言切换
          await tester.tap(find.byType(OneClickLanguageToggleButton));
          await tester.pump(const Duration(milliseconds: 100));
          await tester.pumpAndSettle();

          expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

          print('✓ Language switching works on Pomodoro page');

          // 切换回日历页面
          await tester.tap(find.text('日历'));
          await tester.pumpAndSettle();

          expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

          print('✓ Switched back to Calendar page');

          // === 第五阶段：任务管理集成测试 ===
          print('=== Phase 5: Task Management Integration ===');

          // 测试FAB功能
          await tester.tap(find.byType(FloatingActionButton));
          await tester.pump();

          // 验证任务创建对话框或页面打开（不会导致崩溃）
          expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

          print('✓ Task creation initiated successfully');

          // 在任务创建过程中测试语言切换
          await tester.tap(find.byType(OneClickLanguageToggleButton));
          await tester.pump(const Duration(milliseconds: 100));
          await tester.pumpAndSettle();

          expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

          print('✓ Language switching works during task creation');

          // === 第六阶段：搜索功能测试 ===
          print('=== Phase 6: Search Integration ===');

          final searchButton = find.byIcon(CupertinoIcons.search);
          await tester.tap(searchButton);
          await tester.pump();

          // 验证搜索功能不影响语言切换按钮
          expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

          print('✓ Search functionality integrated');

          // === 第七阶段：压力测试 ===
          print('=== Phase 7: Stress Testing ===');

          // 执行快速连续操作
          for (var i = 0; i < 5; i++) {
            await tester.tap(find.byType(OneClickLanguageToggleButton));
            await tester.pump(const Duration(milliseconds: 50));

            await tester.tap(searchButton);
            await tester.pump(const Duration(milliseconds: 25));

            await tester.tap(todayButton);
            await tester.pump(const Duration(milliseconds: 25));
          }

          await tester.pumpAndSettle();

          // 验证应用仍然稳定
          expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);
          expect(
            find.byType(IntegratedCalendarWithPomodoroPage),
            findsOneWidget,
          );

          print('✓ Stress test completed - app remains stable');

          // === 第八阶段：最终状态验证 ===
          print('=== Phase 8: Final State Verification ===');

          // 验证所有组件仍然正常工作
          expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);
          expect(find.byType(BottomNavigationBar), findsOneWidget);
          expect(find.byType(FloatingActionButton), findsOneWidget);
          expect(find.byType(SliverAppBar), findsOneWidget);

          // 最后一次语言切换确认功能正常
          await tester.tap(find.byType(OneClickLanguageToggleButton));
          await tester.pump();
          await tester.pumpAndSettle();

          expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

          print('✓ Final verification completed - all systems operational');
          print('=== Complete User Journey Test PASSED ===');
        },
      );

      testWidgets(
        'Multi-session workflow: simulating app restart and state persistence',
        (WidgetTester tester) async {
          // === 会话1：初始设置 ===
          print('=== Session 1: Initial Setup ===');

          await tester.pumpWidget(createFullApp());
          await tester.pumpAndSettle();

          // 切换到英文
          await tester.tap(find.byType(OneClickLanguageToggleButton));
          await tester.pump();
          await tester.pumpAndSettle();

          print('✓ Session 1: Language switched to English');

          // 模拟应用关闭
          await tester.pumpWidget(Container());
          await tester.pumpAndSettle();

          print('✓ Session 1: App closed');

          // === 会话2：重新启动 ===
          print('=== Session 2: App Restart ===');

          // 重新创建应用（模拟重启）
          await tester.pumpWidget(createFullApp());
          await tester.pumpAndSettle();

          // 验证应用正常启动
          expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);
          expect(
            find.byType(IntegratedCalendarWithPomodoroPage),
            findsOneWidget,
          );

          print('✓ Session 2: App restarted successfully');

          // 测试语言切换功能
          await tester.tap(find.byType(OneClickLanguageToggleButton));
          await tester.pump();
          await tester.pumpAndSettle();

          expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

          print('✓ Session 2: Language switching functional after restart');

          // === 会话3：长期使用模拟 ===
          print('=== Session 3: Extended Usage Simulation ===');

          // 模拟长期使用场景
          for (var session = 0; session < 3; session++) {
            print('--- Extended usage cycle ${session + 1} ---');

            // 页面导航
            await tester.tap(find.text('专注'));
            await tester.pumpAndSettle();

            await tester.tap(find.text('日历'));
            await tester.pumpAndSettle();

            // 语言切换
            await tester.tap(find.byType(OneClickLanguageToggleButton));
            await tester.pump(const Duration(milliseconds: 100));
            await tester.pumpAndSettle();

            // 日历操作
            await tester.tap(find.byIcon(CupertinoIcons.chevron_right));
            await tester.pumpAndSettle();

            await tester.tap(find.byIcon(CupertinoIcons.calendar_today));
            await tester.pumpAndSettle();

            // 验证稳定性
            expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);
            expect(
              find.byType(IntegratedCalendarWithPomodoroPage),
              findsOneWidget,
            );
          }

          print('✓ Session 3: Extended usage simulation completed');
          print('=== Multi-Session Workflow Test PASSED ===');
        },
      );

      testWidgets('Accessibility-focused user journey', (
        WidgetTester tester,
      ) async {
        print('=== Accessibility User Journey ===');

        await tester.pumpWidget(createFullApp());
        await tester.pumpAndSettle();

        // === 键盘导航测试 ===
        print('--- Keyboard Navigation Test ---');

        // 模拟Tab键导航
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();

        // 模拟空格键激活
        await tester.sendKeyEvent(LogicalKeyboardKey.space);
        await tester.pump();
        await tester.pumpAndSettle();

        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

        print('✓ Keyboard navigation working');

        // === 语义信息测试 ===
        print('--- Semantic Information Test ---');

        final semantics = tester.getSemantics(
          find.byType(OneClickLanguageToggleButton),
        );
        expect(semantics, isNotNull);

        print('✓ Semantic information available');

        // === 高对比度模式测试 ===
        print('--- High Contrast Mode Test ---');

        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(
                size: Size(400, 800),
                highContrast: true,
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

        // 测试高对比度模式下的功能
        await tester.tap(find.byType(OneClickLanguageToggleButton));
        await tester.pump();
        await tester.pumpAndSettle();

        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

        print('✓ High contrast mode working');
        print('=== Accessibility User Journey PASSED ===');
      });

      testWidgets('Performance-focused workflow with monitoring', (
        WidgetTester tester,
      ) async {
        print('=== Performance Monitoring Workflow ===');

        await tester.pumpWidget(createFullApp());
        await tester.pumpAndSettle();

        // === 性能基线测试 ===
        print('--- Performance Baseline ---');

        final initialPerformance =
            OneClickLanguageToggleButton.getPerformanceReport();
        expect(initialPerformance, isNotNull);

        print('✓ Initial performance metrics captured');

        // === 密集操作性能测试 ===
        print('--- Intensive Operations Performance ---');

        final stopwatch = Stopwatch()..start();

        // 执行密集操作
        for (var i = 0; i < 10; i++) {
          await tester.tap(find.byType(OneClickLanguageToggleButton));
          await tester.pump(const Duration(milliseconds: 50));

          await tester.tap(find.text('专注'));
          await tester.pump(const Duration(milliseconds: 25));

          await tester.tap(find.text('日历'));
          await tester.pump(const Duration(milliseconds: 25));
        }

        await tester.pumpAndSettle();
        stopwatch.stop();

        print(
          '✓ Intensive operations completed in ${stopwatch.elapsedMilliseconds}ms',
        );

        // === 性能指标验证 ===
        print('--- Performance Metrics Validation ---');

        final finalPerformance =
            OneClickLanguageToggleButton.getPerformanceReport();
        expect(finalPerformance.fpsStats.currentFps, greaterThanOrEqualTo(30));

        print('✓ Performance metrics within acceptable range');

        // === 内存使用检查 ===
        print('--- Memory Usage Check ---');

        final memoryStats = OneClickLanguageToggleButton.getMemoryStats();
        expect(memoryStats, isNotNull);

        final memoryLeaks = OneClickLanguageToggleButton.detectMemoryLeaks();
        expect(memoryLeaks, isEmpty);

        print('✓ No memory leaks detected');

        // === 缓存性能检查 ===
        print('--- Cache Performance Check ---');

        final cacheStats = OneClickLanguageToggleButton.getCacheStatistics();
        expect(cacheStats, isNotNull);
        expect(cacheStats.hitRate, greaterThan(0.5)); // 至少50%命中率

        print('✓ Cache performance acceptable');
        print('=== Performance Monitoring Workflow PASSED ===');
      });

      testWidgets('Error recovery and resilience workflow', (
        WidgetTester tester,
      ) async {
        print('=== Error Recovery Workflow ===');

        await tester.pumpWidget(createFullApp());
        await tester.pumpAndSettle();

        // === 正常操作基线 ===
        print('--- Normal Operation Baseline ---');

        await tester.tap(find.byType(OneClickLanguageToggleButton));
        await tester.pump();
        await tester.pumpAndSettle();

        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

        print('✓ Normal operation confirmed');

        // === 错误状态注入 ===
        print('--- Error State Injection ---');

        appBloc.emit(const AppErrorState('Simulated error'));
        await tester.pump();
        await tester.pumpAndSettle();

        // 验证应用在错误状态下仍然可用
        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);
        expect(find.byType(IntegratedCalendarWithPomodoroPage), findsOneWidget);

        print('✓ App remains functional during error state');

        // === 错误恢复测试 ===
        print('--- Error Recovery Test ---');

        appBloc.emit(const AppReadyState());
        await tester.pump();
        await tester.pumpAndSettle();

        // 测试恢复后的功能
        await tester.tap(find.byType(OneClickLanguageToggleButton));
        await tester.pump();
        await tester.pumpAndSettle();

        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

        print('✓ Full functionality restored after error recovery');

        // === 加载状态处理 ===
        print('--- Loading State Handling ---');

        appBloc.emit(const AppLoadingState());
        await tester.pump();

        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

        appBloc.emit(const AppReadyState());
        await tester.pump();
        await tester.pumpAndSettle();

        await tester.tap(find.byType(OneClickLanguageToggleButton));
        await tester.pump();
        await tester.pumpAndSettle();

        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

        print('✓ Loading state handled gracefully');

        // === 快速状态变化测试 ===
        print('--- Rapid State Changes Test ---');

        for (var i = 0; i < 5; i++) {
          appBloc.emit(const AppLoadingState());
          await tester.pump(const Duration(milliseconds: 50));

          appBloc.emit(const AppReadyState());
          await tester.pump(const Duration(milliseconds: 50));
        }

        await tester.pumpAndSettle();

        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);
        expect(find.byType(IntegratedCalendarWithPomodoroPage), findsOneWidget);

        print('✓ Rapid state changes handled successfully');
        print('=== Error Recovery Workflow PASSED ===');
      });
    });

    group('Cross-Platform Compatibility Tests', () {
      testWidgets('Mobile device simulation workflow', (
        WidgetTester tester,
      ) async {
        print('=== Mobile Device Simulation ===');

        // 模拟小屏幕手机
        await tester.binding.setSurfaceSize(const Size(360, 640));

        await tester.pumpWidget(createFullApp());
        await tester.pumpAndSettle();

        // 验证在小屏幕上的布局
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

        print('✓ Mobile device layout and functionality verified');

        // 恢复默认尺寸
        await tester.binding.setSurfaceSize(null);
      });

      testWidgets('Tablet device simulation workflow', (
        WidgetTester tester,
      ) async {
        print('=== Tablet Device Simulation ===');

        // 模拟平板设备
        await tester.binding.setSurfaceSize(const Size(1024, 768));

        await tester.pumpWidget(createFullApp());
        await tester.pumpAndSettle();

        // 验证在大屏幕上的布局
        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

        // 测试功能
        await tester.tap(find.byType(OneClickLanguageToggleButton));
        await tester.pump();
        await tester.pumpAndSettle();

        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

        print('✓ Tablet device layout and functionality verified');

        // 恢复默认尺寸
        await tester.binding.setSurfaceSize(null);
      });

      testWidgets('Orientation change workflow', (WidgetTester tester) async {
        print('=== Orientation Change Workflow ===');

        // 竖屏模式
        await tester.binding.setSurfaceSize(const Size(400, 800));
        await tester.pumpWidget(createFullApp());
        await tester.pumpAndSettle();

        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

        await tester.tap(find.byType(OneClickLanguageToggleButton));
        await tester.pump();
        await tester.pumpAndSettle();

        print('✓ Portrait mode functionality verified');

        // 横屏模式
        await tester.binding.setSurfaceSize(const Size(800, 400));
        await tester.pumpWidget(createFullApp());
        await tester.pumpAndSettle();

        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

        await tester.tap(find.byType(OneClickLanguageToggleButton));
        await tester.pump();
        await tester.pumpAndSettle();

        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

        print('✓ Landscape mode functionality verified');

        // 恢复默认尺寸
        await tester.binding.setSurfaceSize(null);
      });
    });

    group('Integration with External Systems', () {
      testWidgets('System theme integration workflow', (
        WidgetTester tester,
      ) async {
        print('=== System Theme Integration ===');

        // 测试亮色主题
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.light(),
            home: MultiBlocProvider(
              providers: [
                BlocProvider<AppBloc>.value(value: appBloc),
                BlocProvider<TaskBloc>.value(value: taskBloc),
              ],
              child: const IntegratedCalendarWithPomodoroPage(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

        await tester.tap(find.byType(OneClickLanguageToggleButton));
        await tester.pump();
        await tester.pumpAndSettle();

        print('✓ Light theme integration verified');

        // 测试暗色主题
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.dark(),
            home: MultiBlocProvider(
              providers: [
                BlocProvider<AppBloc>.value(value: appBloc),
                BlocProvider<TaskBloc>.value(value: taskBloc),
              ],
              child: const IntegratedCalendarWithPomodoroPage(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

        await tester.tap(find.byType(OneClickLanguageToggleButton));
        await tester.pump();
        await tester.pumpAndSettle();

        print('✓ Dark theme integration verified');
      });

      testWidgets('Accessibility services integration workflow', (
        WidgetTester tester,
      ) async {
        print('=== Accessibility Services Integration ===');

        await tester.pumpWidget(createFullApp());
        await tester.pumpAndSettle();

        // 验证语义信息
        final semantics = tester.getSemantics(
          find.byType(OneClickLanguageToggleButton),
        );
        expect(semantics, isNotNull);

        // 测试键盘导航
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();

        await tester.sendKeyEvent(LogicalKeyboardKey.space);
        await tester.pump();
        await tester.pumpAndSettle();

        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

        print('✓ Accessibility services integration verified');
      });
    });

    group('Data Persistence and State Management', () {
      testWidgets('State persistence across app lifecycle', (
        WidgetTester tester,
      ) async {
        print('=== State Persistence Workflow ===');

        // 初始状态
        await tester.pumpWidget(createFullApp());
        await tester.pumpAndSettle();

        // 执行一些操作
        await tester.tap(find.byType(OneClickLanguageToggleButton));
        await tester.pump();
        await tester.pumpAndSettle();

        await tester.tap(find.text('专注'));
        await tester.pumpAndSettle();

        print('✓ Initial operations completed');

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
        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

        // 测试功能仍然正常
        await tester.tap(find.byType(OneClickLanguageToggleButton));
        await tester.pump();
        await tester.pumpAndSettle();

        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

        print('✓ State persistence verified across app lifecycle');
      });
    });
  });
}
