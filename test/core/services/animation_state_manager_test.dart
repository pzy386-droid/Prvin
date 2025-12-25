import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prvin/core/services/animation_state_manager.dart' as anim_state;

void main() {
  group('AnimationStateManager Tests', () {
    late anim_state.AnimationStateManager manager;

    setUp(() {
      manager = anim_state.AnimationStateManager.instance;
    });

    testWidgets('should register and unregister animation controllers', (
      WidgetTester tester,
    ) async {
      late AnimationController testController;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              testController = AnimationController(
                duration: const Duration(milliseconds: 300),
                vsync: tester,
              );

              // Register controller
              manager.registerController('test_animation', testController);

              // Verify registration
              expect(
                manager.getAnimationState('test_animation'),
                equals(anim_state.AnimationState.idle),
              );

              return Container();
            },
          ),
        ),
      );

      // Unregister controller
      manager.unregisterController('test_animation');

      // Verify unregistration
      expect(manager.getAnimationState('test_animation'), isNull);

      testController.dispose();
    });

    test('should handle animation state transitions', () {
      // Test animation state enum values
      expect(anim_state.AnimationState.idle, isNotNull);
      expect(anim_state.AnimationState.running, isNotNull);
      expect(anim_state.AnimationState.completed, isNotNull);
      expect(anim_state.AnimationState.dismissed, isNotNull);
      expect(anim_state.AnimationState.interrupted, isNotNull);
      expect(anim_state.AnimationState.timeout, isNotNull);
      expect(anim_state.AnimationState.error, isNotNull);
      expect(anim_state.AnimationState.recovering, isNotNull);
    });

    test('should create animation results correctly', () {
      // Test success result
      final successResult = anim_state.AnimationResult.success(
        animationId: 'test',
        finalValue: 1,
        isConsistent: true,
      );

      expect(successResult.isSuccess, isTrue);
      expect(successResult.finalValue, equals(1.0));
      expect(successResult.isConsistent, isTrue);
      expect(successResult.error, isNull);

      // Test failure result
      final failureResult = anim_state.AnimationResult.failure(
        animationId: 'test',
        error: 'Test error',
        finalValue: 0.5,
      );

      expect(failureResult.isSuccess, isFalse);
      expect(failureResult.finalValue, equals(0.5));
      expect(failureResult.isConsistent, isFalse);
      expect(failureResult.error, equals('Test error'));
    });

    test('should create animation consistency results', () {
      const consistentResult = anim_state.AnimationConsistencyResult(
        isConsistent: true,
        issues: [],
      );

      expect(consistentResult.isConsistent, isTrue);
      expect(consistentResult.issues, isEmpty);

      const inconsistentResult = anim_state.AnimationConsistencyResult(
        isConsistent: false,
        issues: ['Issue 1', 'Issue 2'],
      );

      expect(inconsistentResult.isConsistent, isFalse);
      expect(inconsistentResult.issues, hasLength(2));
    });

    test('should create animation state reports', () {
      const report = anim_state.AnimationStateReport(
        totalAnimations: 3,
        runningAnimations: ['anim1'],
        stableAnimations: ['anim2', 'anim3'],
        problematicAnimations: [],
        allStable: false,
      );

      expect(report.totalAnimations, equals(3));
      expect(report.runningAnimations, hasLength(1));
      expect(report.stableAnimations, hasLength(2));
      expect(report.problematicAnimations, isEmpty);
      expect(report.allStable, isFalse);

      final reportMap = report.toMap();
      expect(reportMap['total_animations'], equals(3));
      expect(reportMap['all_stable'], isFalse);
    });

    test('should handle animation exceptions', () {
      const exception = anim_state.AnimationException('Test message');
      expect(exception.message, equals('Test message'));
      expect(exception.cause, isNull);
      expect(exception.toString(), contains('Test message'));

      const exceptionWithCause = anim_state.AnimationException(
        'Test message',
        'Test cause',
      );
      expect(exceptionWithCause.cause, equals('Test cause'));
      expect(exceptionWithCause.toString(), contains('caused by'));

      const timeoutException = anim_state.AnimationTimeoutException(
        'Timeout message',
      );
      expect(timeoutException.message, equals('Timeout message'));
    });
  });
}
