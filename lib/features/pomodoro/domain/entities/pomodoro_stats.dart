import 'package:equatable/equatable.dart';
import 'package:prvin/features/pomodoro/domain/entities/pomodoro_session.dart';

/// 番茄钟统计数据实体
class PomodoroStats extends Equatable {
  /// 创建番茄钟统计数据
  const PomodoroStats({
    required this.totalSessions,
    required this.completedSessions,
    required this.totalFocusTime,
    required this.totalBreakTime,
    required this.averageSessionLength,
    required this.streakDays,
    required this.todaySessions,
    required this.weekSessions,
    required this.monthSessions,
  });

  /// 从会话列表创建统计数据
  factory PomodoroStats.fromSessions(List<PomodoroSession> sessions) {
    if (sessions.isEmpty) {
      return const PomodoroStats(
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
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    final monthStart = DateTime(now.year, now.month);

    final completedSessions = sessions.where((s) => s.completed).length;

    var totalFocusTime = Duration.zero;
    var totalBreakTime = Duration.zero;

    for (final session in sessions.where((s) => s.completed)) {
      if (session.type == SessionType.work) {
        totalFocusTime += session.actualDuration;
      } else {
        totalBreakTime += session.actualDuration;
      }
    }

    final todaySessions = sessions
        .where((s) => s.startTime.isAfter(today))
        .length;

    final weekSessions = sessions
        .where((s) => s.startTime.isAfter(weekStart))
        .length;

    final monthSessions = sessions
        .where((s) => s.startTime.isAfter(monthStart))
        .length;

    final averageSessionLength = completedSessions > 0
        ? Duration(
            milliseconds:
                (totalFocusTime.inMilliseconds +
                    totalBreakTime.inMilliseconds) ~/
                completedSessions,
          )
        : Duration.zero;

    return PomodoroStats(
      totalSessions: sessions.length,
      completedSessions: completedSessions,
      totalFocusTime: totalFocusTime,
      totalBreakTime: totalBreakTime,
      averageSessionLength: averageSessionLength,
      streakDays: _calculateStreakDays(sessions),
      todaySessions: todaySessions,
      weekSessions: weekSessions,
      monthSessions: monthSessions,
    );
  }

  /// 总会话数
  final int totalSessions;

  /// 完成的会话数
  final int completedSessions;

  /// 总专注时间
  final Duration totalFocusTime;

  /// 总休息时间
  final Duration totalBreakTime;

  /// 平均会话长度
  final Duration averageSessionLength;

  /// 连续天数
  final int streakDays;

  /// 今日会话数
  final int todaySessions;

  /// 本周会话数
  final int weekSessions;

  /// 本月会话数
  final int monthSessions;

  /// 完成率
  double get completionRate {
    if (totalSessions == 0) return 0;
    return completedSessions / totalSessions;
  }

  /// 今日进度（假设目标是8个会话）
  double get todayProgress {
    const dailyGoal = 8;
    return (todaySessions / dailyGoal).clamp(0.0, 1.0);
  }

  /// 本周进度（假设目标是40个会话）
  double get weekProgress {
    const weeklyGoal = 40;
    return (weekSessions / weeklyGoal).clamp(0.0, 1.0);
  }

  /// 平均每日会话数
  double get averageDailySessions {
    if (streakDays == 0) return 0;
    return totalSessions / streakDays;
  }

  /// 专注效率
  double get focusEfficiency {
    final totalTime = totalFocusTime + totalBreakTime;
    if (totalTime.inMilliseconds == 0) return 0;
    return totalFocusTime.inMilliseconds / totalTime.inMilliseconds;
  }

  /// 计算连续天数
  static int _calculateStreakDays(List<PomodoroSession> sessions) {
    if (sessions.isEmpty) return 0;

    final sortedSessions = sessions.where((s) => s.completed).toList()
      ..sort((a, b) => b.startTime.compareTo(a.startTime));

    if (sortedSessions.isEmpty) return 0;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    var streakDays = 0;
    var currentDay = today;

    for (final session in sortedSessions) {
      final sessionDay = DateTime(
        session.startTime.year,
        session.startTime.month,
        session.startTime.day,
      );

      if (sessionDay == currentDay) {
        if (streakDays == 0 ||
            sessionDay == today.subtract(Duration(days: streakDays))) {
          streakDays++;
          currentDay = currentDay.subtract(const Duration(days: 1));
        } else {
          break;
        }
      }
    }

    return streakDays;
  }

  @override
  List<Object?> get props => [
    totalSessions,
    completedSessions,
    totalFocusTime,
    totalBreakTime,
    averageSessionLength,
    streakDays,
    todaySessions,
    weekSessions,
    monthSessions,
  ];
}

/// 每日统计数据
class DailyStats extends Equatable {
  /// 创建每日统计数据
  const DailyStats({
    required this.date,
    required this.sessions,
    required this.focusTime,
    required this.breakTime,
    required this.completedSessions,
  });

  /// 日期
  final DateTime date;

  /// 会话数
  final int sessions;

  /// 专注时间
  final Duration focusTime;

  /// 休息时间
  final Duration breakTime;

  /// 完成的会话数
  final int completedSessions;

  /// 完成率
  double get completionRate {
    if (sessions == 0) return 0;
    return completedSessions / sessions;
  }

  /// 总时间
  Duration get totalTime => focusTime + breakTime;

  @override
  List<Object?> get props => [
    date,
    sessions,
    focusTime,
    breakTime,
    completedSessions,
  ];
}
