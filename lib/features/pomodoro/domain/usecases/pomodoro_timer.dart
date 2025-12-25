import 'dart:async';
import 'package:prvin/features/pomodoro/domain/entities/pomodoro_session.dart';
import 'package:prvin/features/pomodoro/domain/entities/pomodoro_stats.dart';
import 'package:prvin/features/pomodoro/domain/repositories/pomodoro_repository.dart';

/// 番茄钟计时器用例
class PomodoroTimer {
  /// 创建番茄钟计时器
  PomodoroTimer(this._repository);

  final PomodoroRepository _repository;
  PomodoroSession? _currentSession;
  Timer? _timer;

  /// 当前会话
  PomodoroSession? get currentSession => _currentSession;

  /// 是否有活跃会话
  bool get hasActiveSession =>
      _currentSession != null && _currentSession!.isActive;

  /// 开始新会话
  Future<String> startSession({
    required SessionType type,
    required Duration duration,
    String? taskId,
  }) async {
    final session = PomodoroSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      startTime: DateTime.now(),
      plannedDuration: duration,
      actualDuration: Duration.zero,
      type: type,
      associatedTaskId: taskId,
      completed: false,
      createdAt: DateTime.now(),
    );

    final sessionId = await _repository.createSession(session);
    _currentSession = session.copyWith(id: sessionId);

    return sessionId;
  }

  /// 完成当前会话
  Future<void> completeSession() async {
    if (_currentSession == null) return;

    final completedSession = _currentSession!.copyWith(
      completed: true,
      endTime: DateTime.now(),
      actualDuration: DateTime.now().difference(_currentSession!.startTime),
    );

    await _repository.updateSession(completedSession);
    _currentSession = null;
    _timer?.cancel();
  }

  /// 取消当前会话
  Future<void> cancelSession() async {
    if (_currentSession == null) return;

    await _repository.deleteSession(_currentSession!.id);
    _currentSession = null;
    _timer?.cancel();
  }

  /// 恢复活跃会话
  Future<void> restoreActiveSession() async {
    final activeSession = await _repository.getActiveSession();
    if (activeSession != null) {
      _currentSession = activeSession;
    }
  }

  /// 获取今日统计
  Future<PomodoroStats> getTodayStatistics() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final sessions = await _repository.getSessionsForDate(startOfDay);
    return PomodoroStats.fromSessions(sessions);
  }

  /// 获取指定日期的统计
  Future<PomodoroStats> getStatisticsForDate(DateTime date) async {
    final sessions = await _repository.getSessionsForDate(date);
    return PomodoroStats.fromSessions(sessions);
  }

  /// 获取所有会话
  Future<List<PomodoroSession>> getAllSessions() async {
    return _repository.getAllSessions();
  }

  /// 释放资源
  void dispose() {
    _timer?.cancel();
  }
}
