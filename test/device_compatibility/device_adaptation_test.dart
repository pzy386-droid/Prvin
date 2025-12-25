
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prvin/core/bloc/app_bloc.dart';
import 'package:prvin/core/widgets/one_click_language_toggle_button.dart';
import 'package:prvin/features/task_management/data/repositories/task_repository_impl.dart';
import 'package:prvin/features/task_management/domain/usecases/task_usecases.dart';
import 'package:prvin/features/task_management/presentation/bloc/task_bloc.dart';
import 'package:prvin/integrated_calendar_with_pomodoro.dart';

void main() {
  group('Device Compatibility and Adaptation Tests', () {
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

    /// 创建适配不同设备的测试应用
    Widget createAdaptiveTestApp({
      Size? screenSize,
      double? devicePixelRatio,
      Brightness? brightness,
      bool highContrast = false,
      double? textScaleFactor,
    }) {
      appBloc.emit(const AppReadyState());

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
            devicePixelRatio: devicePixelRatio ?? 2.0,
            textScaler: TextScaler.linear(textScaleFactor ?? 1.0),
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

    group('Screen Size Adaptation Tests', () {
      testWidgets('should adapt to iPhone SE (small screen)', (
        WidgetTester tester,
      ) async {
        // iPhone SE 尺寸: 320x568
        await tester.pumpWidget(
          createAdaptiveTestApp(screenSize: const Size(320, 568)),
        );
        await tester.pumpAndSettle();

        // 验证组件在小屏幕上正确显示
        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

        final buttonRect = tester.getRect(
          find.byType(OneClickLanguageToggleButton),
        );

        // 验证按钮尺寸适合小屏幕
        expect(buttonRect.width, equals(40.0));
        expect(buttonRect.height, equals(40.0));

        // 验证按钮位置合理（不超出屏幕边界）
        expect(buttonRect.right, lessThanOrEqualTo(320.0));
        expect(buttonRect.bottom, lessThanOrEqualTo(568.0));

        // 测试功能
        await tester.tap(find.byType(OneClickLanguageToggleButton));
        await tester.pump();
        await tester.pumpAndSettle();

        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

        // 验证与其他组件的间距
        final searchButton = find.byIcon(CupertinoIcons.search);
        if (searchButton.evaluate().isNotEmpty) {
          final searchRect = tester.getRect(searchButton);
          final spacing = buttonRect.left - searchRect.right;
          expect(spacing, greaterThan(8.0)); // 最小间距
        }
      });

      testWidgets('should adapt to iPhone 14 Pro (standard screen)', (
        WidgetTester tester,
      ) async {
        // iPhone 14 Pro 尺寸: 393x852
        await tester.pumpWidget(
          createAdaptiveTestApp(screenSize: const Size(393, 852)),
        );
        await tester.pumpAndSettle();

        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

        final buttonRect = tester.getRect(
          find.byType(OneClickLanguageToggleButton),
        );

        // 验证按钮在标准屏幕上的表现
        expect(buttonRect.width, equals(40.0));
        expect(buttonRect.height, equals(40.0));

        // 测试功能
        await tester.tap(find.byType(OneClickLanguageToggleButton));
        await tester.pump();
        await tester.pumpAndSettle();

        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

        // 验证布局在标准屏幕上的合理性
        expect(buttonRect.center.dx, greaterThan(196.5)); // 屏幕中心右侧
      });

      testWidgets('should adapt to iPhone 14 Pro Max (large screen)', (
        WidgetTester tester,
      ) async {
        // iPhone 14 Pro Max 尺寸: 430x932
        await tester.pumpWidget(
          createAdaptiveTestApp(screenSize: const Size(430, 932)),
        );
        await tester.pumpAndSettle();

        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

        final buttonRect = tester.getRect(
          find.byType(OneClickLanguageToggleButton),
        );

        // 验证按钮在大屏幕上保持合适尺寸
        expect(buttonRect.width, equals(40.0));
        expect(buttonRect.height, equals(40.0));

        // 测试功能
        await tester.tap(find.byType(OneClickLanguageToggleButton));
        await tester.pump();
        await tester.pumpAndSettle();

        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);
      });

      testWidgets('should adapt to iPad (tablet screen)', (
        WidgetTester tester,
      ) async {
        // iPad 尺寸: 820x1180 (竖屏)
        await tester.pumpWidget(
          createAdaptiveTestApp(screenSize: const Size(820, 1180)),
        );
        await tester.pumpAndSettle();

        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

        final buttonRect = tester.getRect(
          find.byType(OneClickLanguageToggleButton),
        );

        // 在平板上按钮尺寸保持一致
        expect(buttonRect.width, equals(40.0));
        expect(buttonRect.height, equals(40.0));

        // 测试功能
        await tester.tap(find.byType(OneClickLanguageToggleButton));
        await tester.pump();
        await tester.pumpAndSettle();

        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

        // 验证在大屏幕上的布局合理性
        expect(buttonRect.center.dx, greaterThan(410)); // 屏幕中心右侧
      });

      testWidgets('should adapt to iPad Pro (extra large screen)', (
        WidgetTester tester,
      ) async {
        // iPad Pro 12.9" 尺寸: 1024x1366
        await tester.pumpWidget(
          createAdaptiveTestApp(screenSize: const Size(1024, 1366)),
        );
        await tester.pumpAndSettle();

        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

        final buttonRect = tester.getRect(
          find.byType(OneClickLanguageToggleButton),
        );

        // 即使在超大屏幕上也保持合适的按钮尺寸
        expect(buttonRect.width, equals(40.0));
        expect(buttonRect.height, equals(40.0));

        // 测试功能
        await tester.tap(find.byType(OneClickLanguageToggleButton));
        await tester.pump();
        await tester.pumpAndSettle();

        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);
      });
    });

    group('Orientation Adaptation Tests', () {
      testWidgets('should maintain functionality in portrait orientation', (
        WidgetTester tester,
      ) async {
        // 竖屏模式
        await tester.binding.setSurfaceSize(const Size(400, 800));

        await tester.pumpWidget(createAdaptiveTestApp());
        await tester.pumpAndSettle();

        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

        final portraitButtonRect = tester.getRect(
          find.byType(OneClickLanguageToggleButton),
        );

        // 测试竖屏模式下的功能
        await tester.tap(find.byType(OneClickLanguageToggleButton));
        await tester.pump();
        await tester.pumpAndSettle();

        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

        // 验证布局合理性
        expect(portraitButtonRect.top, greaterThan(0));
        expect(portraitButtonRect.right, lessThanOrEqualTo(400));

        // 恢复默认尺寸
        await tester.binding.setSurfaceSize(null);
      });

      testWidgets('should maintain functionality in landscape orientation', (
        WidgetTester tester,
      ) async {
        // 横屏模式
        await tester.binding.setSurfaceSize(const Size(800, 400));

        await tester.pumpWidget(createAdaptiveTestApp());
        await tester.pumpAndSettle();

        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

        final landscapeButtonRect = tester.getRect(
          find.byType(OneClickLanguageToggleButton),
        );

        // 测试横屏模式下的功能
        await tester.tap(find.byType(OneClickLanguageToggleButton));
        await tester.pump();
        await tester.pumpAndSettle();

        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

        // 验证横屏布局
        expect(landscapeButtonRect.top, greaterThan(0));
        expect(landscapeButtonRect.right, lessThanOrEqualTo(800));

        // 恢复默认尺寸
        await tester.binding.setSurfaceSize(null);
      });

      testWidgets('should handle orientation changes smoothly', (
        WidgetTester tester,
      ) async {
        // 开始于竖屏
        await tester.binding.setSurfaceSize(const Size(400, 800));
        await tester.pumpWidget(createAdaptiveTestApp());
        await tester.pumpAndSettle();

        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

        // 切换到横屏
        await tester.binding.setSurfaceSize(const Size(800, 400));
        await tester.pumpWidget(createAdaptiveTestApp());
        await tester.pumpAndSettle();

        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

        // 测试功能在方向切换后仍然正常
        await tester.tap(find.byType(OneClickLanguageToggleButton));
        await tester.pump();
        await tester.pumpAndSettle();

        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

        // 切换回竖屏
        await tester.binding.setSurfaceSize(const Size(400, 800));
        await tester.pumpWidget(createAdaptiveTestApp());
        await tester.pumpAndSettle();

        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

        // 再次测试功能
        await tester.tap(find.byType(OneClickLanguageToggleButton));
        await tester.pump();
        await tester.pumpAndSettle();

        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

        // 恢复默认尺寸
        await tester.binding.setSurfaceSize(null);
      });
    });

    group('Pixel Density Adaptation Tests', () {
      testWidgets('should work correctly on low density screens (1x)', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(createAdaptiveTestApp(devicePixelRatio: 1));
        await tester.pumpAndSettle();

        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

        // 测试功能
        await tester.tap(find.byType(OneClickLanguageToggleButton));
        await tester.pump();
        await tester.pumpAndSettle();

        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);
      });

      testWidgets('should work correctly on standard density screens (2x)', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(createAdaptiveTestApp(devicePixelRatio: 2));
        await tester.pumpAndSettle();

        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

        // 测试功能
        await tester.tap(find.byType(OneClickLanguageToggleButton));
        await tester.pump();
        await tester.pumpAndSettle();

        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);
      });

      testWidgets('should work correctly on high density screens (3x)', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(createAdaptiveTestApp(devicePixelRatio: 3));
        await tester.pumpAndSettle();

        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

        // 测试功能
        await tester.tap(find.byType(OneClickLanguageToggleButton));
        await tester.pump();
        await tester.pumpAndSettle();

        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);
      });

      testWidgets('should work correctly on ultra-high density screens (4x)', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(createAdaptiveTestApp(devicePixelRatio: 4));
        await tester.pumpAndSettle();

        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

        // 测试功能
        await tester.tap(find.byType(OneClickLanguageToggleButton));
        await tester.pump();
        await tester.pumpAndSettle();

        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);
      });
    });

    group('Text Scale Factor Adaptation Tests', () {
      testWidgets('should adapt to small text scale (0.8x)', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(createAdaptiveTestApp(textScaleFactor: 0.8));
        await tester.pumpAndSettle();

        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

        // 验证按钮在小字体缩放下仍然可用
        await tester.tap(find.byType(OneClickLanguageToggleButton));
        await tester.pump();
        await tester.pumpAndSettle();

        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);
      });

      testWidgets('should adapt to normal text scale (1.0x)', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(createAdaptiveTestApp(textScaleFactor: 1));
        await tester.pumpAndSettle();

        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

        // 测试标准字体缩放
        await tester.tap(find.byType(OneClickLanguageToggleButton));
        await tester.pump();
        await tester.pumpAndSettle();

        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);
      });

      testWidgets('should adapt to large text scale (1.3x)', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(createAdaptiveTestApp(textScaleFactor: 1.3));
        await tester.pumpAndSettle();

        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

        // 验证按钮在大字体缩放下仍然可用
        await tester.tap(find.byType(OneClickLanguageToggleButton));
        await tester.pump();
        await tester.pumpAndSettle();

        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);
      });

      testWidgets('should adapt to extra large text scale (2.0x)', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(createAdaptiveTestApp(textScaleFactor: 2));
        await tester.pumpAndSettle();

        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

        // 验证按钮在超大字体缩放下仍然可用
        await tester.tap(find.byType(OneClickLanguageToggleButton));
        await tester.pump();
        await tester.pumpAndSettle();

        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);
      });
    });

    group('Theme Adaptation Tests', () {
      testWidgets('should adapt to light theme', (WidgetTester tester) async {
        await tester.pumpWidget(
          createAdaptiveTestApp(brightness: Brightness.light),
        );
        await tester.pumpAndSettle();

        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

        // 测试亮色主题下的功能
        await tester.tap(find.byType(OneClickLanguageToggleButton));
        await tester.pump();
        await tester.pumpAndSettle();

        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);
      });

      testWidgets('should adapt to dark theme', (WidgetTester tester) async {
        await tester.pumpWidget(
          createAdaptiveTestApp(brightness: Brightness.dark),
        );
        await tester.pumpAndSettle();

        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

        // 测试暗色主题下的功能
        await tester.tap(find.byType(OneClickLanguageToggleButton));
        await tester.pump();
        await tester.pumpAndSettle();

        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);
      });

      testWidgets('should adapt to high contrast mode', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(createAdaptiveTestApp(highContrast: true));
        await tester.pumpAndSettle();

        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

        // 测试高对比度模式下的功能
        await tester.tap(find.byType(OneClickLanguageToggleButton));
        await tester.pump();
        await tester.pumpAndSettle();

        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);
      });

      testWidgets('should adapt to high contrast dark mode', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          createAdaptiveTestApp(
            brightness: Brightness.dark,
            highContrast: true,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

        // 测试高对比度暗色模式下的功能
        await tester.tap(find.byType(OneClickLanguageToggleButton));
        await tester.pump();
        await tester.pumpAndSettle();

        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);
      });
    });

    group('Layout Consistency Tests', () {
      testWidgets(
        'should maintain consistent spacing across different screen sizes',
        (WidgetTester tester) async {
          final screenSizes = [
            const Size(320, 568), // iPhone SE
            const Size(375, 667), // iPhone 8
            const Size(414, 896), // iPhone 11 Pro Max
            const Size(768, 1024), // iPad
          ];

          for (final size in screenSizes) {
            await tester.pumpWidget(createAdaptiveTestApp(screenSize: size));
            await tester.pumpAndSettle();

            expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

            // 验证按钮尺寸一致性
            final buttonSize = tester.getSize(
              find.byType(OneClickLanguageToggleButton),
            );
            expect(buttonSize.width, equals(40.0));
            expect(buttonSize.height, equals(40.0));

            // 验证按钮与其他元素的相对位置
            final buttonRect = tester.getRect(
              find.byType(OneClickLanguageToggleButton),
            );

            // 按钮应该在屏幕右侧区域
            expect(buttonRect.center.dx, greaterThan(size.width * 0.5));

            // 按钮不应该超出屏幕边界
            expect(buttonRect.right, lessThanOrEqualTo(size.width));
            expect(buttonRect.bottom, lessThanOrEqualTo(size.height));

            // 测试功能
            await tester.tap(find.byType(OneClickLanguageToggleButton));
            await tester.pump();
            await tester.pumpAndSettle();

            expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);
          }
        },
      );

      testWidgets(
        'should maintain visual hierarchy across different configurations',
        (WidgetTester tester) async {
          final configurations = [
            // 标准配置
            {
              'size': const Size(375, 667),
              'pixelRatio': 2.0,
              'textScale': 1.0,
              'brightness': Brightness.light,
            },
            // 大屏高密度
            {
              'size': const Size(414, 896),
              'pixelRatio': 3.0,
              'textScale': 1.0,
              'brightness': Brightness.dark,
            },
            // 小屏大字体
            {
              'size': const Size(320, 568),
              'pixelRatio': 2.0,
              'textScale': 1.5,
              'brightness': Brightness.light,
            },
            // 平板配置
            {
              'size': const Size(768, 1024),
              'pixelRatio': 2.0,
              'textScale': 1.0,
              'brightness': Brightness.dark,
            },
          ];

          for (final config in configurations) {
            await tester.pumpWidget(
              createAdaptiveTestApp(
                screenSize: config['size']! as Size,
                devicePixelRatio: config['pixelRatio']! as double,
                textScaleFactor: config['textScale']! as double,
                brightness: config['brightness']! as Brightness,
              ),
            );
            await tester.pumpAndSettle();

            // 验证核心组件存在
            expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);
            expect(find.byType(SliverAppBar), findsOneWidget);
            expect(find.byType(BottomNavigationBar), findsOneWidget);

            // 验证按钮在视觉层次中的正确位置
            final buttonRect = tester.getRect(
              find.byType(OneClickLanguageToggleButton),
            );

            // 按钮应该在头部区域
            expect(buttonRect.top, lessThan(200));

            // 测试功能
            await tester.tap(find.byType(OneClickLanguageToggleButton));
            await tester.pump();
            await tester.pumpAndSettle();

            expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);
          }
        },
      );
    });

    group('Performance Across Devices Tests', () {
      testWidgets('should maintain good performance on low-end devices', (
        WidgetTester tester,
      ) async {
        // 模拟低端设备：小屏幕、低像素密度
        await tester.pumpWidget(
          createAdaptiveTestApp(
            screenSize: const Size(320, 568),
            devicePixelRatio: 1,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

        // 执行多次操作测试性能
        for (var i = 0; i < 10; i++) {
          await tester.tap(find.byType(OneClickLanguageToggleButton));
          await tester.pump(const Duration(milliseconds: 50));
        }

        await tester.pumpAndSettle();

        // 验证应用仍然响应
        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

        // 检查性能指标
        final performanceReport =
            OneClickLanguageToggleButton.getPerformanceReport();
        expect(performanceReport.fpsStats.currentFps, greaterThanOrEqualTo(30));
      });

      testWidgets('should utilize high-end device capabilities', (
        WidgetTester tester,
      ) async {
        // 模拟高端设备：大屏幕、高像素密度
        await tester.pumpWidget(
          createAdaptiveTestApp(
            screenSize: const Size(414, 896),
            devicePixelRatio: 3,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

        // 执行密集操作
        for (var i = 0; i < 20; i++) {
          await tester.tap(find.byType(OneClickLanguageToggleButton));
          await tester.pump(const Duration(milliseconds: 25));
        }

        await tester.pumpAndSettle();

        // 验证高端设备上的性能表现
        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

        final performanceReport =
            OneClickLanguageToggleButton.getPerformanceReport();
        expect(performanceReport.fpsStats.currentFps, greaterThanOrEqualTo(45));
      });
    });

    group('Edge Case Device Configurations', () {
      testWidgets('should handle extremely small screens', (
        WidgetTester tester,
      ) async {
        // 极小屏幕测试
        await tester.pumpWidget(
          createAdaptiveTestApp(screenSize: const Size(240, 320)),
        );
        await tester.pumpAndSettle();

        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

        // 验证按钮在极小屏幕上仍然可用
        final buttonRect = tester.getRect(
          find.byType(OneClickLanguageToggleButton),
        );
        expect(buttonRect.width, equals(40.0));
        expect(buttonRect.height, equals(40.0));

        // 测试功能
        await tester.tap(find.byType(OneClickLanguageToggleButton));
        await tester.pump();
        await tester.pumpAndSettle();

        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);
      });

      testWidgets('should handle extremely large screens', (
        WidgetTester tester,
      ) async {
        // 极大屏幕测试（如大型平板或桌面）
        await tester.pumpWidget(
          createAdaptiveTestApp(screenSize: const Size(1920, 1080)),
        );
        await tester.pumpAndSettle();

        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

        // 验证按钮在极大屏幕上保持合适尺寸
        final buttonRect = tester.getRect(
          find.byType(OneClickLanguageToggleButton),
        );
        expect(buttonRect.width, equals(40.0));
        expect(buttonRect.height, equals(40.0));

        // 测试功能
        await tester.tap(find.byType(OneClickLanguageToggleButton));
        await tester.pump();
        await tester.pumpAndSettle();

        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);
      });

      testWidgets('should handle unusual aspect ratios', (
        WidgetTester tester,
      ) async {
        // 超宽屏幕测试
        await tester.pumpWidget(
          createAdaptiveTestApp(screenSize: const Size(800, 200)),
        );
        await tester.pumpAndSettle();

        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

        // 测试功能
        await tester.tap(find.byType(OneClickLanguageToggleButton));
        await tester.pump();
        await tester.pumpAndSettle();

        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

        // 超高屏幕测试
        await tester.pumpWidget(
          createAdaptiveTestApp(screenSize: const Size(200, 800)),
        );
        await tester.pumpAndSettle();

        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

        await tester.tap(find.byType(OneClickLanguageToggleButton));
        await tester.pump();
        await tester.pumpAndSettle();

        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);
      });
    });
  });
}
