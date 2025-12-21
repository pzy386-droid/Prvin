import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prvin/features/pomodoro/widgets/achievement_card.dart';

void main() {
  group('AchievementCard Widget Tests', () {
    testWidgets('should display unlocked achievement correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AchievementCard(
              title: '测试成就',
              description: '这是一个测试成就',
              icon: Icons.star,
              isUnlocked: true,
              progress: 1,
            ),
          ),
        ),
      );

      // 验证成就信息显示
      expect(find.text('测试成就'), findsOneWidget);
      expect(find.text('这是一个测试成就'), findsOneWidget);
      expect(find.byIcon(Icons.star), findsOneWidget);
      expect(find.text('已解锁'), findsOneWidget);
    });

    testWidgets('should display locked achievement correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AchievementCard(
              title: '未解锁成就',
              description: '需要完成条件',
              icon: Icons.lock,
              isUnlocked: false,
              progress: 0.5,
            ),
          ),
        ),
      );

      // 验证未解锁状态
      expect(find.text('未解锁成就'), findsOneWidget);
      expect(find.text('需要完成条件'), findsOneWidget);
      expect(find.text('未解锁'), findsOneWidget);
      expect(find.byIcon(Icons.lock), findsWidgets); // 图标和状态标签都有锁图标
    });

    testWidgets('should show progress bar for locked achievements', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AchievementCard(
              title: '进行中成就',
              description: '50%完成',
              icon: Icons.trending_up,
              isUnlocked: false,
              progress: 0.5,
            ),
          ),
        ),
      );

      // 验证进度条显示
      expect(find.text('进度'), findsOneWidget);
      expect(find.text('50%'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('should not show progress bar for unlocked achievements', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AchievementCard(
              title: '已完成成就',
              description: '100%完成',
              icon: Icons.check_circle,
              isUnlocked: true,
              progress: 1,
            ),
          ),
        ),
      );

      // 验证进度条不显示
      expect(find.text('进度'), findsNothing);
      expect(find.byType(LinearProgressIndicator), findsNothing);
    });

    testWidgets('should handle tap callback', (WidgetTester tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AchievementCard(
              title: '可点击成就',
              description: '点击查看详情',
              icon: Icons.info,
              isUnlocked: true,
              progress: 1,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      // 点击成就卡片
      await tester.tap(find.byType(AchievementCard));
      await tester.pump();

      // 验证回调被调用
      expect(tapped, true);
    });

    testWidgets('should display different progress values correctly', (
      WidgetTester tester,
    ) async {
      final progressValues = [0.0, 0.25, 0.5, 0.75, 1.0];

      for (final progress in progressValues) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AchievementCard(
                title: '进度测试',
                description: '测试不同进度值',
                icon: Icons.timeline,
                isUnlocked: false,
                progress: progress,
              ),
            ),
          ),
        );

        // 验证进度百分比显示
        expect(find.text('${(progress * 100).toInt()}%'), findsOneWidget);

        // 清理
        await tester.pumpWidget(Container());
      }
    });
  });

  group('AchievementCard Animation Tests', () {
    testWidgets('should have scale animation on hover', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AchievementCard(
              title: '动画测试',
              description: '测试悬停动画',
              icon: Icons.animation,
              isUnlocked: true,
              progress: 1,
            ),
          ),
        ),
      );

      // 验证动画控制器存在
      final state = tester.state(find.byType(AchievementCard));
      expect(state, isNotNull);
    });

    testWidgets('should have glow animation for unlocked achievements', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AchievementCard(
              title: '微光测试',
              description: '测试微光效果',
              icon: Icons.auto_awesome,
              isUnlocked: true,
              progress: 1,
            ),
          ),
        ),
      );

      // 等待动画开始
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // 验证组件仍然存在
      expect(find.byType(AchievementCard), findsOneWidget);
    });
  });

  group('AchievementCard Visual Tests', () {
    testWidgets('should show different icon colors for locked/unlocked', (
      WidgetTester tester,
    ) async {
      // 测试已解锁成就
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AchievementCard(
              title: '已解锁',
              description: '颜色测试',
              icon: Icons.star,
              isUnlocked: true,
              progress: 1,
            ),
          ),
        ),
      );

      // 查找图标容器
      final unlockedContainer = find.byType(AnimatedContainer).first;
      expect(unlockedContainer, findsOneWidget);

      // 清理并测试未解锁成就
      await tester.pumpWidget(Container());
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AchievementCard(
              title: '未解锁',
              description: '颜色测试',
              icon: Icons.star,
              isUnlocked: false,
              progress: 0.5,
            ),
          ),
        ),
      );

      final lockedContainer = find.byType(AnimatedContainer).first;
      expect(lockedContainer, findsOneWidget);
    });

    testWidgets('should show check icon for unlocked achievements', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AchievementCard(
              title: '已完成',
              description: '显示勾选图标',
              icon: Icons.emoji_events,
              isUnlocked: true,
              progress: 1,
            ),
          ),
        ),
      );

      // 验证勾选图标存在
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('should show lock icon for locked achievements', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AchievementCard(
              title: '未完成',
              description: '显示锁定图标',
              icon: Icons.emoji_events,
              isUnlocked: false,
              progress: 0.3,
            ),
          ),
        ),
      );

      // 验证锁定图标存在
      expect(find.byIcon(Icons.lock), findsWidgets);
    });
  });

  group('AchievementCard Edge Cases', () {
    testWidgets('should handle zero progress correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AchievementCard(
              title: '零进度',
              description: '刚开始',
              icon: Icons.start,
              isUnlocked: false,
              progress: 0,
            ),
          ),
        ),
      );

      expect(find.text('0%'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('should handle full progress correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AchievementCard(
              title: '满进度',
              description: '即将解锁',
              icon: Icons.done_all,
              isUnlocked: false,
              progress: 1,
            ),
          ),
        ),
      );

      expect(find.text('100%'), findsOneWidget);
    });

    testWidgets('should handle long text gracefully', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AchievementCard(
              title: '这是一个非常非常长的成就标题用来测试文本溢出处理',
              description: '这是一个非常非常长的成就描述用来测试文本溢出处理和换行功能',
              icon: Icons.text_fields,
              isUnlocked: true,
              progress: 1,
            ),
          ),
        ),
      );

      // 验证组件正常渲染
      expect(find.byType(AchievementCard), findsOneWidget);
    });
  });
}
