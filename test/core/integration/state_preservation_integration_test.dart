import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prvin/core/bloc/app_bloc.dart';
import 'package:prvin/core/services/state_isolation_manager.dart';
import 'package:prvin/core/services/state_preservation_service.dart';
import 'package:prvin/core/widgets/one_click_language_toggle_button.dart';
import 'package:prvin/features/task_management/data/repositories/task_repository_impl.dart';
import 'package:prvin/features/task_management/domain/usecases/task_usecases.dart';
import 'package:prvin/features/task_management/presentation/bloc/task_bloc.dart';

void main() {
  group('State Preservation Integration Tests', () {
    late AppBloc appBloc;
    late TaskBloc taskBloc;
    late StatePreservationService statePreservationService;
    late StateIsolationManager stateIsolationManager;

    setUp(() {
      appBloc = AppBloc();
      final repository = TaskRepositoryImpl();
      final useCases = TaskUseCases(repository);
      taskBloc = TaskBloc(useCases);
      statePreservationService = StatePreservationService.instance;
      stateIsolationManager = StateIsolationManager.instance;
    });

    tearDown(() {
      appBloc.close();
      taskBloc.close();
      statePreservationService.clearSnapshot();
      if (stateIsolationManager.currentStatus == IsolationStatus.active) {
        stateIsolationManager.forceEndIsolation();
      }
    });

    testWidgets('should preserve task state during language switching', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: MultiBlocProvider(
            providers: [
              BlocProvider<AppBloc>.value(value: appBloc),
              BlocProvider<TaskBloc>.value(value: taskBloc),
            ],
            child: const Scaffold(body: OneClickLanguageToggleButton()),
          ),
        ),
      );

      // Wait for initial state
      await tester.pump();

      // Get initial task state
      final initialTaskState = taskBloc.state;

      // Act - Trigger language toggle
      await tester.tap(find.byType(OneClickLanguageToggleButton));
      await tester.pump();

      // Allow some time for async operations
      await tester.pump(const Duration(milliseconds: 100));

      // Assert - Task state should be preserved
      final finalTaskState = taskBloc.state;

      // Core task management state should remain unchanged
      expect(
        finalTaskState.selectedDate,
        equals(initialTaskState.selectedDate),
      );
      expect(finalTaskState.searchQuery, equals(initialTaskState.searchQuery));
      expect(
        finalTaskState.filterCategory,
        equals(initialTaskState.filterCategory),
      );
      expect(
        finalTaskState.filterStatus,
        equals(initialTaskState.filterStatus),
      );
      expect(
        finalTaskState.tasks.length,
        equals(initialTaskState.tasks.length),
      );
    });

    test(
      'StatePreservationService should capture and verify state correctly',
      () async {
        // Arrange
        final context = MockBuildContext();

        // Act - Capture state
        await statePreservationService.captureStateSnapshot(context);

        // Assert - Should have snapshot
        final report = statePreservationService.getIsolationReport();
        expect(report.hasSnapshot, isTrue);
        expect(report.protectedComponents, contains('task_management'));

        // Act - Verify state (should pass since no changes)
        final result = await statePreservationService.verifyStateIntegrity(
          context,
        );

        // Assert - Should be valid
        expect(result.isValid, isTrue);
        expect(result.violations, isEmpty);
      },
    );

    test('StateIsolationManager should control state updates correctly', () {
      // Act - Start isolation
      final sessionId = stateIsolationManager.startIsolationSession();
      expect(
        stateIsolationManager.currentStatus,
        equals(IsolationStatus.active),
      );

      // Test language-related updates (should be allowed)
      final languageValidation = stateIsolationManager.validateStateUpdate(
        stateKey: 'language_code',
        oldValue: 'zh',
        newValue: 'en',
        component: 'app_bloc',
      );
      expect(languageValidation.isAllowed, isTrue);

      // Test protected state updates (should be blocked)
      final protectedValidation = stateIsolationManager.validateStateUpdate(
        stateKey: 'selected_date',
        oldValue: DateTime(2023, 12, 25),
        newValue: DateTime(2023, 12, 26),
        component: 'task_bloc',
      );
      expect(protectedValidation.isAllowed, isFalse);
      expect(protectedValidation.severity, equals(ViolationSeverity.high));

      // Act - End isolation
      final report = stateIsolationManager.endIsolationSession();
      expect(report.sessionId, equals(sessionId));
      expect(report.protectedViolations, equals(1)); // One blocked update
      expect(
        stateIsolationManager.currentStatus,
        equals(IsolationStatus.inactive),
      );
    });
  });
}

// Mock BuildContext for testing
class MockBuildContext extends BuildContext {
  @override
  bool get debugDoingBuild => false;

  @override
  InheritedWidget? dependOnInheritedElement(
    InheritedElement? ancestor, {
    Object? aspect,
  }) {
    return null;
  }

  @override
  T? dependOnInheritedWidgetOfExactType<T extends InheritedWidget>({
    Object? aspect,
  }) {
    return null;
  }

  @override
  DiagnosticsNode describeElement(
    String name, {
    DiagnosticsTreeStyle style = DiagnosticsTreeStyle.errorProperty,
  }) {
    throw UnimplementedError();
  }

  @override
  List<DiagnosticsNode> describeMissingAncestor({
    required Type expectedAncestorType,
  }) {
    throw UnimplementedError();
  }

  @override
  DiagnosticsNode describeOwnershipChain(String name) {
    throw UnimplementedError();
  }

  @override
  DiagnosticsNode describeWidget(
    String name, {
    DiagnosticsTreeStyle style = DiagnosticsTreeStyle.errorProperty,
  }) {
    throw UnimplementedError();
  }

  @override
  void dispatchNotification(Notification notification) {}

  @override
  T? findAncestorRenderObjectOfType<T extends RenderObject>() {
    return null;
  }

  @override
  T? findAncestorStateOfType<T extends State<StatefulWidget>>() {
    return null;
  }

  @override
  T? findAncestorWidgetOfExactType<T extends Widget>() {
    return null;
  }

  @override
  RenderObject? findRenderObject() {
    return null;
  }

  @override
  T? findRootAncestorStateOfType<T extends State<StatefulWidget>>() {
    return null;
  }

  @override
  InheritedElement?
  getElementForInheritedWidgetOfExactType<T extends InheritedWidget>() {
    return null;
  }

  @override
  BuildOwner? get owner => null;

  @override
  Size? get size => null;

  @override
  void visitAncestorElements(bool Function(Element element) visitor) {}

  @override
  void visitChildElements(ElementVisitor visitor) {}

  @override
  Widget get widget => Container();

  @override
  bool get mounted => true;

  // Add the read method for BlocProvider
  T read<T>() {
    // Return mock instances for testing
    if (T == TaskBloc) {
      final repository = TaskRepositoryImpl();
      final useCases = TaskUseCases(repository);
      return TaskBloc(useCases) as T;
    }
    throw UnimplementedError('Mock for type $T not implemented');
  }
}
