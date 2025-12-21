import 'package:flutter_test/flutter_test.dart';
import 'package:prvin/features/pomodoro/models/pomodoro_session.dart';
import 'package:prvin/features/pomodoro/models/pomodoro_stats.dart';

void main() {
  group('PomodoroSession Tests', () {
    test('should create session with correct properties', () {
      final now = DateTime.now();
      final session = PomodoroSession(
        id: 'test-1',
        startTime: now,
        endTime: now.add(const Duration(minutes: 25)),
        plannedDuration: const Duration(minutes: 25),
        actualDuration: const Duration(minutes: 25),
        type: SessionType.work,
        completed: true,
        createdAt: now,
      );

      expect(session.id, 'test-1');
      expect(session.type, SessionType.work);
      expect(session.completed, true);
      expect(session.isWorkSession, true);
      expect(session.isBreakSession, false);
      expect(session.efficiency, 1.0);
    });

    test('should calculate efficiency correctly', () {
      final session = PomodoroSession(
        id: 'test-1',
        startTime: DateTime.now(),
        plannedDuration: const Duration(minutes: 25),
        actualDuration: const Duration(minutes: 20),
        type: SessionType.work,
      );

      expect(session.efficiency, 0.8);
    });

    test('should convert to/from JSON correctly', () {
      final now = DateTime.now();
      final session = PomodoroSession(
        id: 'test-1',
        startTime: now,
        plannedDuration: const Duration(minutes: 25),
        actualDuration: const Duration(minutes: 25),
        type: SessionType.work,
        completed: true,
        createdAt: now,
      );

      final json = session.toJson();
      final restored = PomodoroSession.fromJson(json);

      expect(restored.id, session.id);
      expect(restored.type, session.type);
      expect(restored.completed, session.completed);
      expect(restored.plannedDuration, session.plannedDuration);
      expect(restored.actualDuration, session.actualDuration);
    });
  });

  group('SessionType Tests', () {
    test('should have correct display names', () {
      expect(SessionType.work.displayName, '专注时间');
      expect(SessionType.shortBreak.displayName, '短休息');
      expect(SessionType.longBreak.displayName, '长休息');
    });

    test('should have correct default durations', () {
      expect(SessionType.work.defaultDuration, const Duration(minutes: 25));
      expect(
        SessionType.shortBreak.defaultDuration,
        const Duration(minutes: 5),
      );
      expect(
        SessionType.longBreak.defaultDuration,
        const Duration(minutes: 15),
      );
    });

    test('should have different color values', () {
      expect(
        SessionType.work.colorValue,
        isNot(SessionType.shortBreak.colorValue),
      );
      expect(
        SessionType.shortBreak.colorValue,
        isNot(SessionType.longBreak.colorValue),
      );
      expect(
        SessionType.work.colorValue,
        isNot(SessionType.longBreak.colorValue),
      );
    });
  });

  group('PomodoroStats Tests', () {
    test('should create empty stats correctly', () {
      const stats = PomodoroStats(
        totalSessions: 0,
        completedSessions: 0,
        totalFocusTime: Duration.zero,
        totalBreakTime: Duration.zero,
        averageSessionLength: Duration.zero,
        streakDays: 0,
        todaySessions: 0,
        weekSessions: 0,
        monthSessions: 0,
      );

      expect(stats.completionRate, 0.0);
      expect(stats.todayProgress, 0.0);
      expect(stats.weekProgress, 0.0);
      expect(stats.averageDailySessions, 0.0);
      expect(stats.focusEfficiency, 0.0);
    });

    test('should calculate stats from sessions correctly', () {
      final now = DateTime.now();
      final sessions = [
        PomodoroSession(
          id: '1',
          startTime: now,
          plannedDuration: const Duration(minutes: 25),
          actualDuration: const Duration(minutes: 25),
          type: SessionType.work,
          completed: true,
        ),
        PomodoroSession(
          id: '2',
          startTime: now.add(const Duration(minutes: 30)),
          plannedDuration: const Duration(minutes: 5),
          actualDuration: const Duration(minutes: 5),
          type: SessionType.shortBreak,
          completed: true,
        ),
        PomodoroSession(
          id: '3',
          startTime: now.add(const Duration(minutes: 40)),
          plannedDuration: const Duration(minutes: 25),
          actualDuration: const Duration(minutes: 20),
          type: SessionType.work,
        ),
      ];

      final stats = PomodoroStats.fromSessions(sessions);

      expect(stats.totalSessions, 3);
      expect(stats.completedSessions, 2);
      expect(stats.completionRate, closeTo(0.67, 0.01));
      expect(stats.totalFocusTime, const Duration(minutes: 45));
      expect(stats.totalBreakTime, const Duration(minutes: 5));
      expect(stats.focusEfficiency, 0.9);
    });

    test('should handle empty sessions list', () {
      final stats = PomodoroStats.fromSessions([]);

      expect(stats.totalSessions, 0);
      expect(stats.completedSessions, 0);
      expect(stats.totalFocusTime, Duration.zero);
      expect(stats.totalBreakTime, Duration.zero);
      expect(stats.streakDays, 0);
    });
  });

  group('DailyStats Tests', () {
    test('should calculate completion rate correctly', () {
      final stats = DailyStats(
        date: DateTime.now(),
        sessions: 4,
        focusTime: const Duration(minutes: 100),
        breakTime: const Duration(minutes: 20),
        completedSessions: 3,
      );

      expect(stats.completionRate, 0.75);
      expect(stats.totalTime, const Duration(minutes: 120));
      expect(stats.focusEfficiency, closeTo(0.83, 0.01));
    });

    test('should handle zero sessions', () {
      final stats = DailyStats(
        date: DateTime.now(),
        sessions: 0,
        focusTime: Duration.zero,
        breakTime: Duration.zero,
        completedSessions: 0,
      );

      expect(stats.completionRate, 0.0);
      expect(stats.totalTime, Duration.zero);
      expect(stats.focusEfficiency, 0.0);
    });
  });
}
