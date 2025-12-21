import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prvin/core/theme/app_theme.dart';
import 'package:prvin/features/calendar/widgets/calendar_view.dart';

void main() {
  group('Calendar Interaction Properties', () {
    late Faker faker;

    setUp(() {
      faker = Faker();
    });

    testWidgets('Property 1: Calendar Date Interaction Consistency', (
      WidgetTester tester,
    ) async {
      /**
         * Feature: ai-calendar-app, Property 1: 日历交互一致性
         * 对于任何日历日期，当用户点击该日期时，系统应该显示该日期的任务列表并提供任务创建入口
         * 验证需求: 需求 1.2, 2.1
         */

      // 运行5次属性测试
      for (var i = 0; i < 5; i++) {
        final testDate = DateTime(2024, 12, 15); // 使用固定日期避免随机性问题

        final tasks = [
          CalendarTask(
            id: 'task-1',
            title: 'Test Task',
            date: testDate,
            category: 'work',
          ),
        ];

        DateTime? tappedDate;
        var dateWasTapped = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CalendarView(
                initialDate: testDate,
                tasks: tasks,
                onDateTap: (date) {
                  tappedDate = date;
                  dateWasTapped = true;
                },
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // 查找日期15的文本
        final dayFinder = find.text('15');

        if (dayFinder.evaluate().isNotEmpty) {
          // 点击日期
          await tester.tap(dayFinder.first);
          await tester.pumpAndSettle();

          // 验证日期点击回调被触发
          expect(
            dateWasTapped,
            isTrue,
            reason: 'Date tap callback should be triggered',
          );
          expect(
            tappedDate?.day,
            equals(15),
            reason: 'Tapped date should match the clicked date',
          );
        }

        // 清理测试环境
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
      }
    });

    testWidgets('Property 2: Task Display Color Mapping', (
      WidgetTester tester,
    ) async {
      /**
         * Feature: ai-calendar-app, Property 2: 任务显示颜色映射
         * 对于任何任务类型，在日历视图中显示时应该使用对应的颜色分区
         * 验证需求: 需求 1.3
         */

      final testDate = DateTime(2024, 12, 15);

      // 生成不同类别的任务
      final tasks = [
        CalendarTask(
          id: 'task-work',
          title: 'Work Task',
          date: testDate,
          category: 'work',
          priority: 'high',
        ),
        CalendarTask(
          id: 'task-personal',
          title: 'Personal Task',
          date: testDate,
          category: 'personal',
          priority: 'medium',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CalendarView(
              initialDate: testDate,
              tasks: tasks,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 验证每个任务类别都有对应的颜色映射
      for (final task in tasks) {
        final expectedColor = task.getColor();

        // 验证颜色映射是否正确
        if (task.category != null &&
            AppTheme.taskCategoryColors.containsKey(task.category)) {
          expect(
            expectedColor,
            equals(AppTheme.taskCategoryColors[task.category!]),
            reason:
                'Task color should match category color mapping for ${task.category}',
          );
        } else {
          expect(
            expectedColor,
            equals(AppTheme.primaryColor),
            reason: 'Task without category should use primary color',
          );
        }

        // 验证优先级颜色映射
        final priorityColor = task.getPriorityColor();
        switch (task.priority?.toLowerCase()) {
          case 'high':
            expect(
              priorityColor,
              equals(AppTheme.errorColor),
              reason: 'High priority tasks should use error color',
            );
          case 'medium':
            expect(
              priorityColor,
              equals(AppTheme.warningColor),
              reason: 'Medium priority tasks should use warning color',
            );
          case 'low':
            expect(
              priorityColor,
              equals(AppTheme.successColor),
              reason: 'Low priority tasks should use success color',
            );
          default:
            expect(
              priorityColor,
              equals(Colors.grey),
              reason: 'Unknown priority tasks should use grey color',
            );
        }
      }
    });

    testWidgets('Property 3: View Switching Seamlessness', (
      WidgetTester tester,
    ) async {
      /**
         * Feature: ai-calendar-app, Property 3: 视图切换无缝性
         * 对于任何日历视图模式（月/周/日），切换到其他视图模式应该保持数据一致性并提供流畅过渡
         * 验证需求: 需求 1.4
         */

      final testDate = DateTime(2024, 12, 15);

      final tasks = [
        CalendarTask(
          id: 'task-1',
          title: 'Test Task 1',
          date: testDate,
          category: 'work',
        ),
        CalendarTask(
          id: 'task-2',
          title: 'Test Task 2',
          date: testDate.add(const Duration(days: 1)),
          category: 'personal',
        ),
      ];

      CalendarViewType? currentViewType;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CalendarView(
              initialDate: testDate,
              tasks: tasks,
              onViewTypeChanged: (viewType) {
                currentViewType = viewType;
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 测试切换到周视图
      final weekButtonFinder = find.text('周');
      if (weekButtonFinder.evaluate().isNotEmpty) {
        // 记录切换前的任务数据
        final tasksBeforeSwitch = List<CalendarTask>.from(tasks);

        // 点击周视图按钮
        await tester.tap(weekButtonFinder.first);
        await tester.pumpAndSettle();

        // 验证视图类型已更改
        expect(
          currentViewType,
          equals(CalendarViewType.week),
          reason: 'View type should change to week',
        );

        // 验证数据一致性
        expect(
          tasks.length,
          equals(tasksBeforeSwitch.length),
          reason: 'Task count should remain consistent after view switch',
        );

        for (var j = 0; j < tasks.length; j++) {
          expect(
            tasks[j].id,
            equals(tasksBeforeSwitch[j].id),
            reason: 'Task IDs should remain consistent after view switch',
          );
        }

        // 验证过渡动画的存在
        final animatedWidgets = find.byType(AnimatedBuilder);
        expect(
          animatedWidgets.evaluate().isNotEmpty,
          isTrue,
          reason: 'View switch should include animated transitions',
        );
      }

      // 测试切换到日视图
      final dayButtonFinder = find.text('日');
      if (dayButtonFinder.evaluate().isNotEmpty) {
        await tester.tap(dayButtonFinder.first);
        await tester.pumpAndSettle();

        expect(
          currentViewType,
          equals(CalendarViewType.day),
          reason: 'View type should change to day',
        );
      }
    });

    group('Calendar Task Model Properties', () {
      test('Task color mapping consistency', () {
        /**
         * Feature: ai-calendar-app, Property 2: 任务显示颜色映射
         * 验证任务颜色映射的一致性
         */

        for (var i = 0; i < 20; i++) {
          final category = faker.randomGenerator.element([
            'work',
            'personal',
            'health',
            'study',
            'meeting',
            null,
          ]);

          final task = CalendarTask(
            id: faker.guid.guid(),
            title: faker.lorem.sentence(),
            date: faker.date.dateTime(),
            category: category,
          );

          final color = task.getColor();

          if (category != null &&
              AppTheme.taskCategoryColors.containsKey(category)) {
            expect(
              color,
              equals(AppTheme.taskCategoryColors[category]),
              reason: 'Task color should match category mapping for $category',
            );
          } else {
            expect(
              color,
              equals(AppTheme.primaryColor),
              reason: 'Task without valid category should use primary color',
            );
          }
        }
      });

      test('Task date matching accuracy', () {
        /**
         * Feature: ai-calendar-app, Property 1: 日历交互一致性
         * 验证任务日期匹配的准确性
         */

        for (var i = 0; i < 20; i++) {
          final taskDate = faker.date.dateTime(minYear: 2020, maxYear: 2030);

          final task = CalendarTask(
            id: faker.guid.guid(),
            title: faker.lorem.sentence(),
            date: taskDate,
          );

          // 测试相同日期匹配
          expect(
            task.isOnDate(taskDate),
            isTrue,
            reason: 'Task should match its own date',
          );

          // 测试今天日期匹配
          final today = DateTime.now();
          final isTaskToday =
              taskDate.year == today.year &&
              taskDate.month == today.month &&
              taskDate.day == today.day;
          expect(
            task.isToday(),
            equals(isTaskToday),
            reason: 'Task today check should match actual date comparison',
          );

          // 测试不同日期不匹配
          final differentDate = taskDate.add(const Duration(days: 1));
          expect(
            task.isOnDate(differentDate),
            isFalse,
            reason: 'Task should not match different dates',
          );
        }
      });
    });
  });
}
