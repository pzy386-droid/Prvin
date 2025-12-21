import 'package:prvin/features/pomodoro/models/pomodoro_session.dart';

/// 番茄钟统计数据模型
class PomodoroStats {
  /// 创建统计数据
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
    this.dailyGoal = 8,
    this.weeklyGoal = 40,
  });

  /// 从会话列表计算统计数据
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

    var totalFocusTime = Duration.zero;
    var totalBreakTime = Duration.zero;
    var completedSessions = 0;
    var todaySessions = 0;
    var weekSessions = 0;
    var monthSessions = 0;

    for (final session in sessions) {
      if (session.completed) {
        completedSessions++;
      }

      if (session.isWorkSession) {
        totalFocusTime += session.actualDuration;
      } else {
        totalBreakTime += session.actualDuration;
      }

      final sessionDate = DateTime(
        session.startTime.year,
        session.startTime.month,
        session.startTime.day,
      );

      if (sessionDate == today) {
        todaySessions++;
      }

      if (sessionDate.isAfter(weekStart.subtract(const Duration(days: 1)))) {
        weekSessions++;
      }

      if (sessionDate.isAfter(monthStart.subtract(const Duration(days: 1)))) {
        monthSessions++;
      }
    }

    // 计算平均会话时长
    final totalDuration = totalFocusTime + totalBreakTime;
    final averageSessionLength = sessions.isNotEmpty
        ? Duration(
            milliseconds: totalDuration.inMilliseconds ~/ sessions.length,
          )
        : Duration.zero;

    // 计算连续天数（简化实现）
    final streakDays = _calculateStreakDays(sessions);

    return PomodoroStats(
      totalSessions: sessions.length,
      completedSessions: completedSessions,
      totalFocusTime: totalFocusTime,
      totalBreakTime: totalBreakTime,
      averageSessionLength: averageSessionLength,
      streakDays: streakDays,
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

  /// 平均会话时长
  final Duration averageSessionLength;

  /// 连续天数
  final int streakDays;

  /// 今日会话数
  final int todaySessions;

  /// 本周会话数
  final int weekSessions;

  /// 本月会话数
  final int monthSessions;

  /// 每日目标
  final int dailyGoal;

  /// 每周目标
  final int weeklyGoal;

  /// 完成率
  double get completionRate {
    if (totalSessions == 0) return 0;
    return completedSessions / totalSessions;
  }

  /// 今日完成率
  double get todayProgress {
    if (dailyGoal == 0) return 0;
    return (todaySessions / dailyGoal).clamp(0.0, 1.0);
  }

  /// 本周完成率
  double get weekProgress {
    if (weeklyGoal == 0) return 0;
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
    var currentDate = today;

    final sessionDates = <DateTime>{};
    for (final session in sortedSessions) {
      final sessionDate = DateTime(
        session.startTime.year,
        session.startTime.month,
        session.startTime.day,
      );
      sessionDates.add(sessionDate);
    }

    while (sessionDates.contains(currentDate)) {
      streakDays++;
      currentDate = currentDate.subtract(const Duration(days: 1));
    }

    return streakDays;
  }

  /// 复制并修改数据
  PomodoroStats copyWith({
    int? totalSessions,
    int? completedSessions,
    Duration? totalFocusTime,
    Duration? totalBreakTime,
    Duration? averageSessionLength,
    int? streakDays,
    int? todaySessions,
    int? weekSessions,
    int? monthSessions,
    int? dailyGoal,
    int? weeklyGoal,
  }) {
    return PomodoroStats(
      totalSessions: totalSessions ?? this.totalSessions,
      completedSessions: completedSessions ?? this.completedSessions,
      totalFocusTime: totalFocusTime ?? this.totalFocusTime,
      totalBreakTime: totalBreakTime ?? this.totalBreakTime,
      averageSessionLength: averageSessionLength ?? this.averageSessionLength,
      streakDays: streakDays ?? this.streakDays,
      todaySessions: todaySessions ?? this.todaySessions,
      weekSessions: weekSessions ?? this.weekSessions,
      monthSessions: monthSessions ?? this.monthSessions,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      weeklyGoal: weeklyGoal ?? this.weeklyGoal,
    );
  }

  @override
  String toString() {
    return 'PomodoroStats(total: $totalSessions, completed: $completedSessions, '
        'focusTime: ${totalFocusTime.inMinutes}min, streak: ${streakDays}d)';
  }
}

/// 每日统计数据
class DailyStats {
  /// 创建每日统计
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

  /// 专注效率
  double get focusEfficiency {
    if (totalTime.inMilliseconds == 0) return 0;
    return focusTime.inMilliseconds / totalTime.inMilliseconds;
  }
}
