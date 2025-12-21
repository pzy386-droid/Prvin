import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:prvin/features/pomodoro/domain/entities/pomodoro_session.dart';
import 'package:prvin/features/pomodoro/domain/repositories/pomodoro_repository.dart';
import 'package:prvin/features/pomodoro/domain/usecases/pomodoro_timer.dart';

import 'pomodoro_timer_test.mocks.dart';

@GenerateMocks([PomodoroRepository])
void main() {
  late PomodoroTimer pomodoroTimer;
  late MockPomodoroRepository mockRepository;

  setUp(() {
    mockRepository = MockPomodoroRepository();
    pomodoroTimer = PomodoroTimer(mockRepository);
  });

  tearDown(() {
    pomodoroTimer.dispose();
  });

  group('PomodoroTimer', () {
    test('should start a new session successfully', () async {
      // Arrange
      const sessionId = 'test-session-id';
      when(
        mockRepository.createSession(any),
      ).thenAnswer((_) async => sessionId);

      // Act
      final result = await pomodoroTimer.startSession(
        type: SessionType.work,
        duration: const Duration(minutes: 25),
      );

      // Assert
      expect(result, equals(sessionId));
      expect(pomodoroTimer.hasActiveSession, isTrue);
      verify(mockRepository.createSession(any)).called(1);
    });

    test('should get today statistics', () async {
      // Arrange
      final sessions = [
        PomodoroSession(
          id: '1',
          startTime: DateTime.now(),
          plannedDuration: const Duration(minutes: 25),
          actualDuration: const Duration(minutes: 25),
          type: SessionType.work,
          completed: true,
          createdAt: DateTime.now(),
        ),
      ];
      when(
        mockRepository.getSessionsForDate(any),
      ).thenAnswer((_) async => sessions);

      // Act
      final statistics = await pomodoroTimer.getTodayStatistics();

      // Assert
      expect(statistics.totalSessions, equals(1));
      expect(statistics.completedSessions, equals(1));
      expect(statistics.workSessions, equals(1));
      verify(mockRepository.getSessionsForDate(any)).called(1);
    });

    test('should restore active session on startup', () async {
      // Arrange
      final activeSession = PomodoroSession(
        id: 'active-session',
        startTime: DateTime.now().subtract(const Duration(minutes: 5)),
        plannedDuration: const Duration(minutes: 25),
        actualDuration: const Duration(minutes: 5),
        type: SessionType.work,
        completed: false,
        createdAt: DateTime.now(),
      );
      when(
        mockRepository.getActiveSession(),
      ).thenAnswer((_) async => activeSession);

      // Act
      await pomodoroTimer.restoreActiveSession();

      // Assert
      expect(pomodoroTimer.currentSession, equals(activeSession));
      expect(pomodoroTimer.hasActiveSession, isTrue);
      verify(mockRepository.getActiveSession()).called(1);
    });

    test('should calculate statistics correctly', () async {
      // Arrange
      final sessions = [
        PomodoroSession(
          id: '1',
          startTime: DateTime.now(),
          plannedDuration: const Duration(minutes: 25),
          actualDuration: const Duration(minutes: 25),
          type: SessionType.work,
          completed: true,
          createdAt: DateTime.now(),
        ),
        PomodoroSession(
          id: '2',
          startTime: DateTime.now(),
          plannedDuration: const Duration(minutes: 5),
          actualDuration: const Duration(minutes: 5),
          type: SessionType.shortBreak,
          completed: true,
          createdAt: DateTime.now(),
        ),
      ];
      when(
        mockRepository.getSessionsForDate(any),
      ).thenAnswer((_) async => sessions);

      // Act
      final statistics = await pomodoroTimer.getTodayStatistics();

      // Assert
      expect(statistics.totalSessions, equals(2));
      expect(statistics.completedSessions, equals(2));
      expect(statistics.workSessions, equals(1));
      expect(statistics.breakSessions, equals(1));
      expect(statistics.totalWorkTime, equals(const Duration(minutes: 25)));
      expect(statistics.totalBreakTime, equals(const Duration(minutes: 5)));
      expect(statistics.completionRate, equals(1.0));
    });
  });
}
