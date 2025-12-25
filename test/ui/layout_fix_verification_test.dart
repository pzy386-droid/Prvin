import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../lib/debug_calendar.dart';

/// Simple test to verify layout fixes work correctly
///
/// Property 1: 布局约束遵守 - Simplified version
/// Verifies that the calendar layout respects constraints without overflow
void main() {
  group('Layout Fix Verification Tests', () {
    testWidgets('Calendar layout should not overflow on different screen sizes', (
      WidgetTester tester,
    ) async {
      // Test different screen sizes
      final screenSizes = [
        const Size(360, 640), // Small mobile
        const Size(414, 896), // Large mobile
        const Size(768, 1024), // Tablet portrait
        const Size(1024, 768), // Tablet landscape
        const Size(1200, 800), // Desktop
      ];

      for (final screenSize in screenSizes) {
        await tester.binding.setSurfaceSize(screenSize);

        // Create a simple test calendar
        await tester.pumpWidget(MaterialApp(home: const DebugCalendar()));

        // Allow the widget to build and settle
        await tester.pumpAndSettle();

        // Verify no exceptions occurred (no overflow errors)
        expect(
          tester.takeException(),
          isNull,
          reason:
              'Layout should not overflow on screen size ${screenSize.width}x${screenSize.height}',
        );

        // Verify the calendar widget is present
        final calendarFinder = find.byType(DebugCalendar);
        expect(calendarFinder, findsOneWidget);

        // Verify basic calendar structure is present
        expect(find.text('Debug Calendar'), findsOneWidget);
        expect(find.text('2025年12月'), findsOneWidget);

        // Verify week days are present
        expect(find.text('日'), findsOneWidget);
        expect(find.text('一'), findsOneWidget);
        expect(find.text('六'), findsOneWidget);
      }
    });

    testWidgets('Calendar grid should have proper structure', (
      WidgetTester tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(800, 600));

      await tester.pumpWidget(MaterialApp(home: const DebugCalendar()));

      await tester.pumpAndSettle();

      // Verify no overflow errors
      expect(tester.takeException(), isNull);

      // Verify calendar structure
      expect(find.byType(DebugCalendar), findsOneWidget);
      expect(find.byType(Column), findsWidgets); // Should have column layout
      expect(
        find.byType(Row),
        findsWidgets,
      ); // Should have row layouts for days
      expect(
        find.byType(Expanded),
        findsWidgets,
      ); // Should use Expanded for flexible layout
    });

    testWidgets('Calendar should handle small screen sizes gracefully', (
      WidgetTester tester,
    ) async {
      // Test very small screen size
      await tester.binding.setSurfaceSize(const Size(300, 400));

      await tester.pumpWidget(MaterialApp(home: const DebugCalendar()));

      await tester.pumpAndSettle();

      // Verify no overflow errors even on small screen
      expect(
        tester.takeException(),
        isNull,
        reason: 'Calendar should handle small screens without overflow',
      );

      // Verify calendar is still functional
      expect(find.byType(DebugCalendar), findsOneWidget);
      expect(find.text('Debug Calendar'), findsOneWidget);
    });
  });
}
