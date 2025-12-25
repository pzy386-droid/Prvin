import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:prvin/core/services/state_isolation_manager.dart';
import 'package:prvin/core/services/state_preservation_service.dart';
import 'package:prvin/features/task_management/presentation/bloc/task_bloc.dart';

// Mock classes
class MockBlocProvider extends Mock {}

class MockTaskBloc extends Mock implements TaskBloc {}

class MockTaskState extends Mock implements TaskState {}

void main() {
  group('StatePreservationService', () {
    late StatePreservationService service;
    late MockBlocProvider mockContext;
    late MockTaskBloc mockTaskBloc;
    late MockTaskState mockTaskState;

    setUp(() {
      service = StatePreservationService.instance;
      mockContext = MockBlocProvider();
      mockTaskBloc = MockTaskBloc();
      mockTaskState = MockTaskState();
    });

    tearDown(() {
      service.clearSnapshot();
    });

    test('should be a singleton', () {
      final instance1 = StatePreservationService.instance;
      final instance2 = StatePreservationService.instance;
      expect(identical(instance1, instance2), isTrue);
    });

    test('should capture state snapshot successfully', () async {
      // Arrange
      when(mockTaskState.selectedDate).thenReturn(DateTime(2023, 12, 25));
      when(mockTaskState.searchQuery).thenReturn('test query');
      when(mockTaskState.filterCategory).thenReturn(null);
      when(mockTaskState.filterStatus).thenReturn(null);
      when(mockTaskState.tasks).thenReturn([]);
      when(mockTaskState.status).thenReturn(TaskBlocStatus.success);

      // Mock the context.read<TaskBloc>() call
      when(mockContext.read<TaskBloc>()).thenReturn(mockTaskBloc);
      when(mockTaskBloc.state).thenReturn(mockTaskState);

      // Act
      await service.captureStateSnapshot(mockContext);

      // Assert
      final report = service.getIsolationReport();
      expect(report.hasSnapshot, isTrue);
      expect(report.protectedComponents, contains('task_management'));
    });

    test('should detect state violations during verification', () async {
      // Arrange - First capture a snapshot
      when(mockTaskState.selectedDate).thenReturn(DateTime(2023, 12, 25));
      when(mockTaskState.searchQuery).thenReturn('original query');
      when(mockTaskState.filterCategory).thenReturn(null);
      when(mockTaskState.filterStatus).thenReturn(null);
      when(mockTaskState.tasks).thenReturn([]);
      when(mockTaskState.status).thenReturn(TaskBlocStatus.success);

      when(mockContext.read<TaskBloc>()).thenReturn(mockTaskBloc);
      when(mockTaskBloc.state).thenReturn(mockTaskState);

      await service.captureStateSnapshot(mockContext);

      // Arrange - Change state to simulate violation
      final modifiedState = MockTaskState();
      when(
        modifiedState.selectedDate,
      ).thenReturn(DateTime(2023, 12, 26)); // Different date
      when(
        modifiedState.searchQuery,
      ).thenReturn('modified query'); // Different query
      when(modifiedState.filterCategory).thenReturn(null);
      when(modifiedState.filterStatus).thenReturn(null);
      when(modifiedState.tasks).thenReturn([]);
      when(modifiedState.status).thenReturn(TaskBlocStatus.success);

      when(mockTaskBloc.state).thenReturn(modifiedState);

      // Act
      final result = await service.verifyStateIntegrity(mockContext);

      // Assert
      expect(result.isValid, isFalse);
      expect(result.violations, isNotEmpty);
      expect(result.violations.any((v) => v.field == 'selected_date'), isTrue);
      expect(result.violations.any((v) => v.field == 'search_query'), isTrue);
    });

    test('should pass verification when state is unchanged', () async {
      // Arrange - Capture snapshot
      when(mockTaskState.selectedDate).thenReturn(DateTime(2023, 12, 25));
      when(mockTaskState.searchQuery).thenReturn('test query');
      when(mockTaskState.filterCategory).thenReturn(null);
      when(mockTaskState.filterStatus).thenReturn(null);
      when(mockTaskState.tasks).thenReturn([]);
      when(mockTaskState.status).thenReturn(TaskBlocStatus.success);

      when(mockContext.read<TaskBloc>()).thenReturn(mockTaskBloc);
      when(mockTaskBloc.state).thenReturn(mockTaskState);

      await service.captureStateSnapshot(mockContext);

      // Act - Verify with same state
      final result = await service.verifyStateIntegrity(mockContext);

      // Assert
      expect(result.isValid, isTrue);
      expect(result.violations, isEmpty);
    });

    test('should handle verification without snapshot', () async {
      // Arrange - No snapshot captured
      when(mockContext.read<TaskBloc>()).thenReturn(mockTaskBloc);
      when(mockTaskBloc.state).thenReturn(mockTaskState);

      // Act
      final result = await service.verifyStateIntegrity(mockContext);

      // Assert
      expect(result.isValid, isFalse);
      expect(result.violations, hasLength(1));
      expect(result.violations.first.field, equals('snapshot'));
    });

    test('should clear snapshot correctly', () {
      // Arrange
      service.clearSnapshot();

      // Act & Assert
      final report = service.getIsolationReport();
      expect(report.hasSnapshot, isFalse);
    });
  });

  group('StateIsolationManager', () {
    late StateIsolationManager manager;

    setUp(() {
      manager = StateIsolationManager.instance;
    });

    tearDown(() {
      if (manager.currentStatus == IsolationStatus.active) {
        manager.forceEndIsolation();
      }
    });

    test('should be a singleton', () {
      final instance1 = StateIsolationManager.instance;
      final instance2 = StateIsolationManager.instance;
      expect(identical(instance1, instance2), isTrue);
    });

    test('should start and end isolation session', () {
      // Act
      final sessionId = manager.startIsolationSession();
      expect(manager.currentStatus, equals(IsolationStatus.active));

      final report = manager.endIsolationSession();

      // Assert
      expect(sessionId, isNotEmpty);
      expect(report.sessionId, equals(sessionId));
      expect(manager.currentStatus, equals(IsolationStatus.inactive));
    });

    test('should allow language-related state updates', () {
      // Arrange
      manager.startIsolationSession();

      // Act
      final validation = manager.validateStateUpdate(
        stateKey: 'language_code',
        oldValue: 'zh',
        newValue: 'en',
        component: 'app_bloc',
      );

      // Assert
      expect(validation.isAllowed, isTrue);
      expect(validation.reason, isNull);

      manager.endIsolationSession();
    });

    test('should block protected state updates', () {
      // Arrange
      manager.startIsolationSession();

      // Act
      final validation = manager.validateStateUpdate(
        stateKey: 'selected_date',
        oldValue: DateTime(2023, 12, 25),
        newValue: DateTime(2023, 12, 26),
        component: 'task_bloc',
      );

      // Assert
      expect(validation.isAllowed, isFalse);
      expect(validation.reason, isNotNull);
      expect(validation.severity, equals(ViolationSeverity.high));

      manager.endIsolationSession();
    });

    test('should allow updates when no isolation session is active', () {
      // Act - No session started
      final validation = manager.validateStateUpdate(
        stateKey: 'selected_date',
        oldValue: DateTime(2023, 12, 25),
        newValue: DateTime(2023, 12, 26),
        component: 'task_bloc',
      );

      // Assert
      expect(validation.isAllowed, isTrue);
    });

    test('should force end isolation session', () {
      // Arrange
      manager.startIsolationSession();
      expect(manager.currentStatus, equals(IsolationStatus.active));

      // Act
      manager.forceEndIsolation();

      // Assert
      expect(manager.currentStatus, equals(IsolationStatus.inactive));
    });
  });
}
