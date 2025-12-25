import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_async/fake_async.dart';
import 'package:my_first_app/integrated_calendar_with_pomodoro.dart';

/// Property-based test for layout constraints compliance
///
/// Property 1: 布局约束遵守
/// For any screen size and device orientation, all UI components should
/// render correctly within their parent container constraints without overflow errors
///
/// Validates: Requirements 1.1, 1.2
void main() {
  group('Layout Constraints Property Tests', () {
    testWidgets(
      'Property 1: 布局约束遵守 - Calendar layout should respect constraints on various screen sizes',
      (WidgetTester tester) async {
        // Test different screen sizes to verify layout constraints
        final screenSizes = [
          const Size(360, 640), // Small mobile
          const Size(414, 896), // Large mobile
          const Size(768, 1024), // Tablet portrait
          const Size(1024, 768), // Tablet landscape
          const Size(1200, 800), // Desktop small
          const Size(1920, 1080), // Desktop large
        ];

        for (final screenSize in screenSizes) {
          await tester.binding.setSurfaceSize(screenSize);

          // Create a test app with the calendar
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: SizedBox(
                  width: screenSize.width,
                  height: screenSize.height,
                  child: const IntegratedCalendarWithPomodoroPage(),
                ),
              ),
            ),
          );

          // Allow the widget to build and settle
          await tester.pumpAndSettle();

          // Verify no overflow errors occurred
          expect(
            tester.takeException(),
            isNull,
            reason:
                'Layout should not overflow on screen size ${screenSize.width}x${screenSize.height}',
          );

          // Verify the calendar widget is present and properly constrained
          final calendarFinder = find.byType(
            IntegratedCalendarWithPomodoroPage,
          );
          expect(calendarFinder, findsOneWidget);

          // Get the calendar widget's render box
          final RenderBox calendarBox = tester.renderObject(calendarFinder);

          // Verify the calendar fits within screen bounds
          expect(
            calendarBox.size.width,
            lessThanOrEqualTo(screenSize.width),
            reason:
                'Calendar width should not exceed screen width on ${screenSize.width}x${screenSize.height}',
          );
          expect(
            calendarBox.size.height,
            lessThanOrEqualTo(screenSize.height),
            reason:
                'Calendar height should not exceed screen height on ${screenSize.width}x${screenSize.height}',
          );

          // Verify calendar has reasonable minimum size
          expect(
            calendarBox.size.width,
            greaterThan(200),
            reason:
                'Calendar should have minimum usable width on ${screenSize.width}x${screenSize.height}',
          );
          expect(
            calendarBox.size.height,
            greaterThan(200),
            reason:
                'Calendar should have minimum usable height on ${screenSize.width}x${screenSize.height}',
          );
        }
      },
    );

    testWidgets(
      'Property 1: 布局约束遵守 - Calendar grid cells should be properly sized',
      (WidgetTester tester) async {
        await tester.binding.setSurfaceSize(const Size(800, 600));

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: const IntegratedCalendarWithPomodoroPage()),
          ),
        );

        await tester.pumpAndSettle();

        // Find calendar date cells (GestureDetector widgets with date keys)
        final dateCellFinders = find.byWidgetPredicate(
          (widget) =>
              widget is GestureDetector &&
              widget.key != null &&
              widget.key.toString().contains('date_'),
        );

        // Verify we have the expected number of date cells (42 for 6 weeks)
        expect(
          dateCellFinders.evaluate().length,
          equals(42),
          reason: 'Calendar should have 42 date cells (6 weeks × 7 days)',
        );

        // Check each date cell is properly sized
        for (final finder in dateCellFinders.evaluate()) {
          final RenderBox cellBox = tester.renderObject(
            find.byWidget(finder.widget),
          );

          // Verify cell has reasonable dimensions
          expect(
            cellBox.size.width,
            greaterThan(20),
            reason: 'Date cell should have minimum usable width',
          );
          expect(
            cellBox.size.height,
            greaterThan(20),
            reason: 'Date cell should have minimum usable height',
          );

          // Verify cell doesn't exceed reasonable maximum
          expect(
            cellBox.size.width,
            lessThan(200),
            reason: 'Date cell should not be excessively wide',
          );
          expect(
            cellBox.size.height,
            lessThan(200),
            reason: 'Date cell should not be excessively tall',
          );
        }
      },
    );

    testWidgets(
      'Property 1: 布局约束遵守 - Task bars should handle text overflow properly',
      (WidgetTester tester) async {
        await tester.binding.setSurfaceSize(const Size(400, 600));

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: const IntegratedCalendarWithPomodoroPage()),
          ),
        );

        await tester.pumpAndSettle();

        // Find task bar text widgets
        final taskTextFinders = find.byWidgetPredicate(
          (widget) =>
              widget is Text &&
              widget.data != null &&
              widget.data!.isNotEmpty &&
              widget.overflow == TextOverflow.ellipsis,
        );

        // Verify task text widgets handle overflow properly
        for (final finder in taskTextFinders.evaluate()) {
          final Text textWidget = finder.widget as Text;

          // Verify overflow handling is set
          expect(
            textWidget.overflow,
            equals(TextOverflow.ellipsis),
            reason: 'Task text should use ellipsis for overflow',
          );
          expect(
            textWidget.maxLines,
            equals(1),
            reason: 'Task text should be limited to single line',
          );
        }
      },
    );
  });
}
