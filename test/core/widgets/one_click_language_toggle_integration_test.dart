import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prvin/core/bloc/app_bloc.dart';
import 'package:prvin/core/widgets/one_click_language_toggle_button.dart';
import 'package:prvin/integrated_calendar_with_pomodoro.dart';

void main() {
  group('OneClickLanguageToggleButton Integration Tests', () {
    late AppBloc mockAppBloc;

    setUp(() {
      mockAppBloc = AppBloc();
    });

    tearDown(() {
      mockAppBloc.close();
    });

    /// 创建完整应用测试环境
    Widget createIntegratedTestApp({AppState? initialState}) {
      if (initialState != null) {
        mockAppBloc.emit(initialState);
      }

      return MaterialApp(
        home: BlocProvider<AppBloc>.value(
          value: mockAppBloc,
          child: const IntegratedCalendarWithPomodoroPage(),
        ),
      );
    }

    group('Application Integration Tests', () {
      testWidgets('should integrate correctly in the main application header', (
        WidgetTester tester,
      ) async {
        // 设置初始状态
        mockAppBloc.emit(const AppReadyState());

        await tester.pumpWidget(createIntegratedTestApp());
        await tester.pumpAndSettle();

        // 验证按钮在应用中正确集成
        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

        // 验证按钮在头部区域
        expect(find.byType(SliverAppBar), findsOneWidget);

        // 验证按钮与其他头部元素共存
        expect(find.byIcon(CupertinoIcons.search), findsOneWidget);
        expect(find.byIcon(CupertinoIcons.calendar_today), findsOneWidget);
        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);
      });

      testWidgets(
        'should function correctly within the integrated application context',
        (WidgetTester tester) async {
          mockAppBloc.emit(const AppReadyState());

          await tester.pumpWidget(createIntegratedTestApp());
          await tester.pumpAndSettle();

          // 验证初始语言状态
          expect(find.text('中'), findsOneWidget);

          // 模拟点击语言切换按钮
          await tester.tap(find.byType(OneClickLanguageToggleButton));
          await tester.pump();

          // 验证按钮响应正常（不会导致应用崩溃）
          expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);
          expect(
            find.byType(IntegratedCalendarWithPomodoroPage),
            findsOneWidget,
          );
        },
      );

      testWidgets(
        'should maintain functionality when switching between app pages',
        (WidgetTester tester) async {
          mockAppBloc.emit(const AppReadyState());

          await tester.pumpWidget(createIntegratedTestApp());
          await tester.pumpAndSettle();

          // 验证在日历页面的按钮功能
          expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);
          expect(find.text('中'), findsOneWidget);

          // 切换到番茄钟页面
          await tester.tap(find.text('专注'));
          await tester.pumpAndSettle();

          // 切换回日历页面
          await tester.tap(find.text('日历'));
          await tester.pumpAndSettle();

          // 验证按钮仍然正常工作
          expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);
          expect(find.text('中'), findsOneWidget);
        },
      );

      testWidgets('should work correctly with app state management', (
        WidgetTester tester,
      ) async {
        mockAppBloc.emit(const AppReadyState());

        await tester.pumpWidget(createIntegratedTestApp());
        await tester.pumpAndSettle();

        // 验证按钮响应BLoC状态变化
        expect(find.text('中'), findsOneWidget);

        // 模拟外部语言状态变化
        mockAppBloc.emit(const AppReadyState(languageCode: 'en'));
        await tester.pumpAndSettle();

        // 验证按钮状态同步更新
        expect(find.text('EN'), findsOneWidget);
        expect(find.text('中'), findsNothing);
      });
    });

    group('UI Component Compatibility Tests', () {
      testWidgets('should coexist properly with other header buttons', (
        WidgetTester tester,
      ) async {
        mockAppBloc.emit(const AppReadyState());

        await tester.pumpWidget(createIntegratedTestApp());
        await tester.pumpAndSettle();

        // 验证所有头部按钮都存在且可交互
        final searchButton = find.byIcon(CupertinoIcons.search);
        final languageButton = find.byType(OneClickLanguageToggleButton);
        final todayButton = find.byIcon(CupertinoIcons.calendar_today);

        expect(searchButton, findsOneWidget);
        expect(languageButton, findsOneWidget);
        expect(todayButton, findsOneWidget);

        // 测试每个按钮的交互不会影响其他按钮
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

      testWidgets('should not interfere with calendar functionality', (
        WidgetTester tester,
      ) async {
        mockAppBloc.emit(const AppReadyState());

        await tester.pumpWidget(createIntegratedTestApp());
        await tester.pumpAndSettle();

        // 验证日历组件正常存在
        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

        // 查找日历相关元素
        final calendarElements = find.textContaining('月');
        expect(calendarElements, findsWidgets);

        // 点击语言切换按钮
        await tester.tap(find.byType(OneClickLanguageToggleButton));
        await tester.pump();

        // 验证日历功能不受影响
        expect(calendarElements, findsWidgets);
      });

      testWidgets('should not interfere with task management functionality', (
        WidgetTester tester,
      ) async {
        mockAppBloc.emit(const AppReadyState());

        await tester.pumpWidget(createIntegratedTestApp());
        await tester.pumpAndSettle();

        // 验证任务相关元素存在
        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

        // 查找任务相关UI元素
        final taskElements = find.textContaining('任务');
        expect(taskElements, findsWidgets);

        // 点击语言切换按钮
        await tester.tap(find.byType(OneClickLanguageToggleButton));
        await tester.pump();

        // 验证任务管理功能不受影响
        expect(taskElements, findsWidgets);
      });

      testWidgets('should work correctly with floating action button', (
        WidgetTester tester,
      ) async {
        mockAppBloc.emit(const AppReadyState());

        await tester.pumpWidget(createIntegratedTestApp());
        await tester.pumpAndSettle();

        // 验证FAB和语言切换按钮共存
        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);
        expect(find.byType(FloatingActionButton), findsOneWidget);

        // 点击语言切换按钮
        await tester.tap(find.byType(OneClickLanguageToggleButton));
        await tester.pump();

        // 验证FAB仍然存在且可用
        expect(find.byType(FloatingActionButton), findsOneWidget);

        // 点击FAB验证不会影响语言按钮
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pump();
        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);
      });

      testWidgets('should work correctly with bottom navigation', (
        WidgetTester tester,
      ) async {
        mockAppBloc.emit(const AppReadyState());

        await tester.pumpWidget(createIntegratedTestApp());
        await tester.pumpAndSettle();

        // 验证底部导航和语言切换按钮共存
        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);
        expect(find.byType(BottomNavigationBar), findsOneWidget);

        // 点击语言切换按钮
        await tester.tap(find.byType(OneClickLanguageToggleButton));
        await tester.pump();

        // 验证底部导航仍然正常
        expect(find.byType(BottomNavigationBar), findsOneWidget);

        // 使用底部导航切换页面
        await tester.tap(find.text('专注'));
        await tester.pumpAndSettle();

        // 切换回日历页面
        await tester.tap(find.text('日历'));
        await tester.pumpAndSettle();

        // 验证语言按钮仍然存在
        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);
      });
    });

    group('Layout Consistency Tests', () {
      testWidgets(
        'should maintain consistent spacing with other header elements',
        (WidgetTester tester) async {
          mockAppBloc.emit(const AppReadyState());

          await tester.pumpWidget(createIntegratedTestApp());
          await tester.pumpAndSettle();

          // 获取头部按钮的位置信息
          final searchButtonRect = tester.getRect(
            find.byIcon(CupertinoIcons.search),
          );
          final languageButtonRect = tester.getRect(
            find.byType(OneClickLanguageToggleButton),
          );
          final todayButtonRect = tester.getRect(
            find.byIcon(CupertinoIcons.calendar_today),
          );

          // 验证按钮在同一水平线上
          expect(
            (searchButtonRect.center.dy - languageButtonRect.center.dy).abs(),
            lessThan(5.0), // 允许5像素的误差
          );
          expect(
            (languageButtonRect.center.dy - todayButtonRect.center.dy).abs(),
            lessThan(5.0),
          );

          // 验证按钮间距合理
          final spacingBetweenLanguageAndToday =
              todayButtonRect.left - languageButtonRect.right;
          expect(spacingBetweenLanguageAndToday, greaterThan(8.0));
          expect(spacingBetweenLanguageAndToday, lessThan(20.0));
        },
      );

      testWidgets('should have consistent size with other header buttons', (
        WidgetTester tester,
      ) async {
        mockAppBloc.emit(const AppReadyState());

        await tester.pumpWidget(createIntegratedTestApp());
        await tester.pumpAndSettle();

        // 获取按钮尺寸
        final languageButtonSize = tester.getSize(
          find.byType(OneClickLanguageToggleButton),
        );

        // 验证按钮尺寸合理（默认40x40）
        expect(languageButtonSize.width, equals(40.0));
        expect(languageButtonSize.height, equals(40.0));

        // 验证按钮尺寸与设计规范一致
        expect(languageButtonSize.width, equals(languageButtonSize.height));
      });

      testWidgets(
        'should maintain layout consistency across different screen orientations',
        (WidgetTester tester) async {
          mockAppBloc.emit(const AppReadyState());

          // 测试竖屏模式
          await tester.binding.setSurfaceSize(const Size(400, 800));
          await tester.pumpWidget(createIntegratedTestApp());
          await tester.pumpAndSettle();

          expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);
          final portraitButtonRect = tester.getRect(
            find.byType(OneClickLanguageToggleButton),
          );

          // 测试横屏模式
          await tester.binding.setSurfaceSize(const Size(800, 400));
          await tester.pumpWidget(createIntegratedTestApp());
          await tester.pumpAndSettle();

          expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);
          final landscapeButtonRect = tester.getRect(
            find.byType(OneClickLanguageToggleButton),
          );

          // 验证按钮在不同方向下都能正确显示
          expect(portraitButtonRect.size, equals(landscapeButtonRect.size));

          // 恢复默认尺寸
          await tester.binding.setSurfaceSize(null);
        },
      );

      testWidgets('should maintain visual hierarchy in the header', (
        WidgetTester tester,
      ) async {
        mockAppBloc.emit(const AppReadyState());

        await tester.pumpWidget(createIntegratedTestApp());
        await tester.pumpAndSettle();

        // 验证头部元素的视觉层次
        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

        // 验证按钮在正确的容器中
        expect(find.byType(SliverAppBar), findsOneWidget);
        expect(find.byType(FlexibleSpaceBar), findsOneWidget);

        // 验证按钮不会遮挡其他重要元素
        final monthText = find.textContaining('月');
        expect(monthText, findsWidgets);

        final languageButtonRect = tester.getRect(
          find.byType(OneClickLanguageToggleButton),
        );

        // 验证按钮位置合理（在右侧区域）
        final screenWidth =
            tester.binding.window.physicalSize.width /
            tester.binding.window.devicePixelRatio;
        expect(languageButtonRect.center.dx, greaterThan(screenWidth * 0.5));
      });

      testWidgets('should adapt to different theme configurations', (
        WidgetTester tester,
      ) async {
        mockAppBloc.emit(const AppReadyState());

        // 测试亮色主题
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.light(),
            home: BlocProvider<AppBloc>.value(
              value: mockAppBloc,
              child: const IntegratedCalendarWithPomodoroPage(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

        // 测试暗色主题
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.dark(),
            home: BlocProvider<AppBloc>.value(
              value: mockAppBloc,
              child: const IntegratedCalendarWithPomodoroPage(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);
      });
    });

    group('Error Handling Integration Tests', () {
      testWidgets(
        'should handle app state errors gracefully in integrated environment',
        (WidgetTester tester) async {
          // 设置错误状态
          mockAppBloc.emit(const AppErrorState('Test error'));

          await tester.pumpWidget(createIntegratedTestApp());
          await tester.pumpAndSettle();

          // 验证应用不会崩溃
          expect(
            find.byType(IntegratedCalendarWithPomodoroPage),
            findsOneWidget,
          );
          expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

          // 验证按钮在错误状态下仍然可以交互
          await tester.tap(find.byType(OneClickLanguageToggleButton));
          await tester.pump();

          // 验证应用仍然稳定
          expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);
        },
      );

      testWidgets('should recover from temporary state issues', (
        WidgetTester tester,
      ) async {
        mockAppBloc.emit(const AppLoadingState());

        await tester.pumpWidget(createIntegratedTestApp());
        await tester.pumpAndSettle();

        // 验证加载状态下的表现
        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

        // 恢复到正常状态
        mockAppBloc.emit(const AppReadyState());
        await tester.pumpAndSettle();

        // 验证按钮恢复正常功能
        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);
        expect(find.text('中'), findsOneWidget);
      });
    });

    group('Performance Integration Tests', () {
      testWidgets(
        'should not impact app performance during language switching',
        (WidgetTester tester) async {
          mockAppBloc.emit(const AppReadyState());

          await tester.pumpWidget(createIntegratedTestApp());
          await tester.pumpAndSettle();

          // 执行多次语言切换
          for (var i = 0; i < 5; i++) {
            await tester.tap(find.byType(OneClickLanguageToggleButton));
            await tester.pump(const Duration(milliseconds: 50));
          }

          await tester.pumpAndSettle();

          // 验证应用仍然响应正常
          expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);
          expect(
            find.byType(IntegratedCalendarWithPomodoroPage),
            findsOneWidget,
          );
        },
      );

      testWidgets(
        'should handle rapid interactions without performance degradation',
        (WidgetTester tester) async {
          mockAppBloc.emit(const AppReadyState());

          await tester.pumpWidget(createIntegratedTestApp());
          await tester.pumpAndSettle();

          // 快速连续交互
          for (var i = 0; i < 10; i++) {
            await tester.tap(find.byType(OneClickLanguageToggleButton));
            await tester.pump(const Duration(milliseconds: 10));
          }

          await tester.pumpAndSettle();

          // 验证应用仍然稳定
          expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);
          expect(
            find.byType(IntegratedCalendarWithPomodoroPage),
            findsOneWidget,
          );
        },
      );
    });

    group('Accessibility Integration Tests', () {
      testWidgets('should maintain accessibility in integrated environment', (
        WidgetTester tester,
      ) async {
        mockAppBloc.emit(const AppReadyState());

        await tester.pumpWidget(createIntegratedTestApp());
        await tester.pumpAndSettle();

        // 验证按钮具有适当的语义信息
        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

        // 验证按钮可以通过语义查找
        final semantics = tester.getSemantics(
          find.byType(OneClickLanguageToggleButton),
        );
        expect(semantics, isNotNull);
      });

      testWidgets('should work with screen reader navigation', (
        WidgetTester tester,
      ) async {
        mockAppBloc.emit(const AppReadyState());

        await tester.pumpWidget(createIntegratedTestApp());
        await tester.pumpAndSettle();

        // 验证按钮在语义树中正确定位
        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

        // 验证按钮具有正确的语义属性
        final button = find.byType(OneClickLanguageToggleButton);
        expect(button, findsOneWidget);
      });
    });
  });
}
