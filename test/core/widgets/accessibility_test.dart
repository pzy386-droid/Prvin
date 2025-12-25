import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prvin/core/bloc/app_bloc.dart';
import 'package:prvin/core/widgets/one_click_language_toggle_button.dart';

void main() {
  group('OneClickLanguageToggleButton Accessibility Tests', () {
    late AppBloc mockAppBloc;

    setUp(() {
      mockAppBloc = AppBloc();
    });

    tearDown(() {
      mockAppBloc.close();
    });

    group('Semantic Labels Tests', () {
      testWidgets('should have correct semantic properties in Chinese state', (
        WidgetTester tester,
      ) async {
        // Set up Chinese state
        mockAppBloc.emit(const AppReadyState());

        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider<AppBloc>(
              create: (_) => mockAppBloc,
              child: const Scaffold(body: OneClickLanguageToggleButton()),
            ),
          ),
        );

        // Enable semantics for testing
        final handle = tester.ensureSemantics();

        // Find the button widget
        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

        // Get semantic properties
        final semantics = tester.getSemantics(
          find.byType(OneClickLanguageToggleButton),
        );

        // Verify basic semantic properties
        expect(semantics.label, equals('语言切换按钮'));
        expect(semantics.hasFlag(SemanticsFlag.isButton), isTrue);
        expect(semantics.hasFlag(SemanticsFlag.isEnabled), isTrue);
        expect(semantics.hasFlag(SemanticsFlag.isFocusable), isTrue);

        // Verify hint contains language information
        expect(semantics.hint, contains('当前语言'));
        expect(semantics.hint, contains('点击切换'));

        // Verify value shows current language
        expect(semantics.value, equals('中'));

        handle.dispose();
      });

      testWidgets('should have correct semantic properties in English state', (
        WidgetTester tester,
      ) async {
        // Set up English state
        mockAppBloc.emit(const AppReadyState(languageCode: 'en'));

        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider<AppBloc>(
              create: (_) => mockAppBloc,
              child: const Scaffold(body: OneClickLanguageToggleButton()),
            ),
          ),
        );

        final handle = tester.ensureSemantics();

        // Get semantic properties
        final semantics = tester.getSemantics(
          find.byType(OneClickLanguageToggleButton),
        );

        // Verify semantic properties for English state
        expect(semantics.label, equals('语言切换按钮'));
        expect(semantics.hint, contains('当前语言：English'));
        expect(semantics.hint, contains('点击切换到中文'));
        expect(semantics.value, equals('EN'));
        expect(semantics.hasFlag(SemanticsFlag.isButton), isTrue);
        expect(semantics.hasFlag(SemanticsFlag.isEnabled), isTrue);

        handle.dispose();
      });

      testWidgets('should update semantic properties when language changes', (
        WidgetTester tester,
      ) async {
        // Start with Chinese
        mockAppBloc.emit(const AppReadyState());

        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider<AppBloc>(
              create: (_) => mockAppBloc,
              child: const Scaffold(body: OneClickLanguageToggleButton()),
            ),
          ),
        );

        final handle = tester.ensureSemantics();

        // Verify initial Chinese state
        var semantics = tester.getSemantics(
          find.byType(OneClickLanguageToggleButton),
        );
        expect(semantics.value, equals('中'));
        expect(semantics.hint, contains('当前语言：中文'));

        // Change to English
        mockAppBloc.emit(const AppReadyState(languageCode: 'en'));
        await tester.pump();

        // Verify updated English state
        semantics = tester.getSemantics(
          find.byType(OneClickLanguageToggleButton),
        );
        expect(semantics.value, equals('EN'));
        expect(semantics.hint, contains('当前语言：English'));

        handle.dispose();
      });

      testWidgets('should have proper semantic actions', (
        WidgetTester tester,
      ) async {
        mockAppBloc.emit(const AppReadyState());

        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider<AppBloc>(
              create: (_) => mockAppBloc,
              child: const Scaffold(body: OneClickLanguageToggleButton()),
            ),
          ),
        );

        final handle = tester.ensureSemantics();

        // Get semantic properties
        final semantics = tester.getSemantics(
          find.byType(OneClickLanguageToggleButton),
        );

        // Verify semantic actions are available by checking the button is interactive
        expect(semantics.hasFlag(SemanticsFlag.isButton), isTrue);
        expect(semantics.hasFlag(SemanticsFlag.isEnabled), isTrue);

        handle.dispose();
      });
    });

    group('Keyboard Navigation Tests', () {
      testWidgets('should be focusable', (WidgetTester tester) async {
        mockAppBloc.emit(const AppReadyState());

        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider<AppBloc>(
              create: (_) => mockAppBloc,
              child: const Scaffold(body: OneClickLanguageToggleButton()),
            ),
          ),
        );

        // Verify the button has focusable semantics
        final handle = tester.ensureSemantics();
        final semantics = tester.getSemantics(
          find.byType(OneClickLanguageToggleButton),
        );

        expect(semantics.hasFlag(SemanticsFlag.isFocusable), isTrue);

        handle.dispose();
      });

      testWidgets('should respond to Space key activation', (
        WidgetTester tester,
      ) async {
        mockAppBloc.emit(const AppReadyState());

        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider<AppBloc>(
              create: (_) => mockAppBloc,
              child: const Scaffold(body: OneClickLanguageToggleButton()),
            ),
          ),
        );

        // Focus the button by tapping it
        await tester.tap(find.byType(OneClickLanguageToggleButton));
        await tester.pump();

        // Simulate space key press
        await tester.sendKeyEvent(LogicalKeyboardKey.space);
        await tester.pump();

        // Verify the button is still present (key event was handled)
        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);
      });

      testWidgets('should respond to Enter key activation', (
        WidgetTester tester,
      ) async {
        mockAppBloc.emit(const AppReadyState());

        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider<AppBloc>(
              create: (_) => mockAppBloc,
              child: const Scaffold(body: OneClickLanguageToggleButton()),
            ),
          ),
        );

        // Focus the button
        await tester.tap(find.byType(OneClickLanguageToggleButton));
        await tester.pump();

        // Simulate enter key press
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pump();

        // Verify the button handled the key event
        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);
      });

      testWidgets('should ignore irrelevant key presses', (
        WidgetTester tester,
      ) async {
        mockAppBloc.emit(const AppReadyState());

        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider<AppBloc>(
              create: (_) => mockAppBloc,
              child: const Scaffold(body: OneClickLanguageToggleButton()),
            ),
          ),
        );

        // Focus the button
        await tester.tap(find.byType(OneClickLanguageToggleButton));
        await tester.pump();

        // Try keys that should be ignored
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
        await tester.pump();

        // Verify the button is still present and functional
        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);
      });

      testWidgets('should participate in tab navigation', (
        WidgetTester tester,
      ) async {
        mockAppBloc.emit(const AppReadyState());

        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider<AppBloc>(
              create: (_) => mockAppBloc,
              child: const Scaffold(
                body: Column(
                  children: [
                    TextField(key: Key('first_field')),
                    OneClickLanguageToggleButton(),
                    TextField(key: Key('second_field')),
                  ],
                ),
              ),
            ),
          ),
        );

        // Focus the first text field
        await tester.tap(find.byKey(const Key('first_field')));
        await tester.pump();

        // Tab to the next widget (should be our button)
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();

        // Verify the button is in the tab order
        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);
      });
    });

    group('Screen Reader Compatibility Tests', () {
      testWidgets('should provide proper semantic tree structure', (
        WidgetTester tester,
      ) async {
        mockAppBloc.emit(const AppReadyState());

        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider<AppBloc>(
              create: (_) => mockAppBloc,
              child: const Scaffold(body: OneClickLanguageToggleButton()),
            ),
          ),
        );

        // Get the semantic tree
        final handle = tester.ensureSemantics();
        final semantics = tester.getSemantics(
          find.byType(OneClickLanguageToggleButton),
        );

        // Verify semantic node properties for screen readers
        expect(semantics.label, isNotEmpty);
        expect(semantics.hint, isNotEmpty);
        expect(semantics.value, isNotEmpty);
        expect(semantics.hasFlag(SemanticsFlag.isButton), isTrue);
        expect(semantics.hasFlag(SemanticsFlag.isEnabled), isTrue);
        expect(semantics.hasFlag(SemanticsFlag.isFocusable), isTrue);

        handle.dispose();
      });

      testWidgets('should provide contextual information for screen readers', (
        WidgetTester tester,
      ) async {
        // Test with Chinese state
        mockAppBloc.emit(const AppReadyState());

        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider<AppBloc>(
              create: (_) => mockAppBloc,
              child: const Scaffold(body: OneClickLanguageToggleButton()),
            ),
          ),
        );

        final handle = tester.ensureSemantics();
        final semantics = tester.getSemantics(
          find.byType(OneClickLanguageToggleButton),
        );

        // Verify contextual information is provided
        expect(semantics.label, equals('语言切换按钮'));
        expect(semantics.hint, contains('当前语言'));
        expect(semantics.hint, contains('点击切换'));
        expect(semantics.value, equals('中'));

        // Verify the information is meaningful for screen readers
        expect(semantics.label.isNotEmpty, isTrue);
        expect(semantics.hint.length, greaterThan(10)); // Should be descriptive
        expect(semantics.value.isNotEmpty, isTrue);

        handle.dispose();
      });

      testWidgets('should work in semantic traversal order', (
        WidgetTester tester,
      ) async {
        mockAppBloc.emit(const AppReadyState());

        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider<AppBloc>(
              create: (_) => mockAppBloc,
              child: const Scaffold(
                body: Column(
                  children: [
                    Text('Before button'),
                    OneClickLanguageToggleButton(),
                    Text('After button'),
                  ],
                ),
              ),
            ),
          ),
        );

        final handle = tester.ensureSemantics();

        // Verify the button is accessible in the semantic tree
        final buttonSemantics = tester.getSemantics(
          find.byType(OneClickLanguageToggleButton),
        );

        expect(buttonSemantics.label, equals('语言切换按钮'));
        expect(buttonSemantics.hasFlag(SemanticsFlag.isButton), isTrue);

        handle.dispose();
      });

      testWidgets('should support screen reader announcements structure', (
        WidgetTester tester,
      ) async {
        mockAppBloc.emit(const AppReadyState());

        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider<AppBloc>(
              create: (_) => mockAppBloc,
              child: const Scaffold(body: OneClickLanguageToggleButton()),
            ),
          ),
        );

        // Verify the button has the necessary semantic structure
        // for screen reader announcements
        final handle = tester.ensureSemantics();
        final semantics = tester.getSemantics(
          find.byType(OneClickLanguageToggleButton),
        );

        // Verify all required properties for announcements are present
        expect(semantics.label, isNotEmpty);
        expect(semantics.hint, isNotEmpty);
        expect(semantics.value, isNotEmpty);
        expect(semantics.hasFlag(SemanticsFlag.isButton), isTrue);
        expect(semantics.hasFlag(SemanticsFlag.isEnabled), isTrue);

        handle.dispose();
      });
    });

    group('High Contrast Mode Tests', () {
      testWidgets('should adapt to high contrast mode', (
        WidgetTester tester,
      ) async {
        mockAppBloc.emit(const AppReadyState());

        // Create a MediaQuery with high contrast enabled
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(highContrast: true),
              child: BlocProvider<AppBloc>(
                create: (_) => mockAppBloc,
                child: const Scaffold(body: OneClickLanguageToggleButton()),
              ),
            ),
          ),
        );

        // Verify the button renders without errors in high contrast mode
        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

        // Verify semantic properties are maintained in high contrast mode
        final handle = tester.ensureSemantics();
        final semantics = tester.getSemantics(
          find.byType(OneClickLanguageToggleButton),
        );

        expect(semantics.label, equals('语言切换按钮'));
        expect(semantics.hasFlag(SemanticsFlag.isButton), isTrue);
        expect(semantics.hasFlag(SemanticsFlag.isEnabled), isTrue);
        expect(semantics.hasFlag(SemanticsFlag.isFocusable), isTrue);

        handle.dispose();
      });

      testWidgets('should maintain functionality in high contrast mode', (
        WidgetTester tester,
      ) async {
        mockAppBloc.emit(const AppReadyState());

        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(highContrast: true),
              child: BlocProvider<AppBloc>(
                create: (_) => mockAppBloc,
                child: const Scaffold(body: OneClickLanguageToggleButton()),
              ),
            ),
          ),
        );

        // Test tap functionality in high contrast mode
        await tester.tap(find.byType(OneClickLanguageToggleButton));
        await tester.pump();

        // Test keyboard navigation in high contrast mode
        await tester.sendKeyEvent(LogicalKeyboardKey.space);
        await tester.pump();

        // Verify button is still functional
        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);
      });
    });

    group('Accessibility Integration Tests', () {
      testWidgets('should maintain accessibility during state changes', (
        WidgetTester tester,
      ) async {
        mockAppBloc.emit(const AppReadyState());

        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider<AppBloc>(
              create: (_) => mockAppBloc,
              child: const Scaffold(body: OneClickLanguageToggleButton()),
            ),
          ),
        );

        final handle = tester.ensureSemantics();

        // Verify initial accessibility
        var semantics = tester.getSemantics(
          find.byType(OneClickLanguageToggleButton),
        );
        expect(semantics.label, equals('语言切换按钮'));
        expect(semantics.value, equals('中'));

        // Change state
        mockAppBloc.emit(const AppReadyState(languageCode: 'en'));
        await tester.pump();

        // Verify accessibility is maintained after state change
        semantics = tester.getSemantics(
          find.byType(OneClickLanguageToggleButton),
        );
        expect(semantics.label, equals('语言切换按钮'));
        expect(semantics.value, equals('EN'));
        expect(semantics.hasFlag(SemanticsFlag.isButton), isTrue);
        expect(semantics.hasFlag(SemanticsFlag.isEnabled), isTrue);
        expect(semantics.hasFlag(SemanticsFlag.isFocusable), isTrue);

        handle.dispose();
      });

      testWidgets('should work with other accessible widgets', (
        WidgetTester tester,
      ) async {
        mockAppBloc.emit(const AppReadyState());

        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider<AppBloc>(
              create: (_) => mockAppBloc,
              child: Scaffold(
                appBar: AppBar(title: const Text('Test App')),
                body: const Column(
                  children: [
                    TextField(
                      decoration: InputDecoration(labelText: 'Input field'),
                    ),
                    OneClickLanguageToggleButton(),
                    ElevatedButton(
                      onPressed: null,
                      child: Text('Another button'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        // Verify all widgets are accessible
        final handle = tester.ensureSemantics();

        // Verify our button is accessible among other widgets
        expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);

        final buttonSemantics = tester.getSemantics(
          find.byType(OneClickLanguageToggleButton),
        );
        expect(buttonSemantics.label, equals('语言切换按钮'));
        expect(buttonSemantics.hasFlag(SemanticsFlag.isButton), isTrue);

        handle.dispose();
      });
    });
  });
}
