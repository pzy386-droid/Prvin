import 'dart:async';
import 'package:uuid/uuid.dart';
import '../entities/pomodoro_session.dart';
import '../repositories/pomodoro_repository.dart';

/// 番茄钟计时器用例
class PomodoroTimer {
  /// 创建番茄钟计时器
  PomodoroTimer(this._repository);

  final PomodoroRepository _repository;
  final Uuid _uuid = const Uuid();

  Timer? _timer;
  PomodoroSession? _currentSession;
  final StreamController<PomodoroSession?> _sessionController =
      StreamController<PomodoroSession?>.broadcast();

  /// 当前会话流
  Stream<PomodoroSession?> get sessionStream => _sessionController.stream;

  /// 当前会话
  PomodoroSession? get currentSession => _currentSession;

  /// 是否有活动会话
  bool get hasActiveSession => _currentSession?.isActive ?? false;

  /// 开始新的番茄钟会话
  Future<String> startSession({
    required SessionType type,
    required Duration duration,
    String? associatedTaskId,
  }) async {
    // 如果有活动会话，先停止它
    if (hasActiveSession) {
      await stopCurrentSession();
    }

    final now = DateTime.now();
    final session = PomodoroSession(
      id: _uuid.v4(),
      startTime: now,
      plannedDuration: duration,
      actualDuration: Duration.zero,
      type: type,
      associatedTaskId: associatedTaskId,
      completed: false,
      createdAt: now,
    );

    final sessionId = await _repository.createSession(session);
    _currentSession = session;
    _sessionController.add(_currentSession);

    // 启动计时器
    _startTimer();

    return sessionId;
  }

  /// 暂停当前会话
  Future<void> pauseCurrentSession() async {
    if (!hasActiveSession) return;

    _stopTimer();

    // 更新会话状态但不标记为完成
    final updatedSession = _currentSession!.copyWith(
      actualDuration: _calculateActualDuration(),
    );

    await _repository.updateSession(updatedSession);
    _currentSession = updatedSession;
    _sessionController.add(_currentSession);
  }

  /// 恢复当前会话
  Future<void> resumeCurrentSession() async {
    if (_currentSession == null || _currentSession!.completed) return;

    _startTimer();
  }

  /// 停止当前会话
  Future<void> stopCurrentSession() async {
    if (!hasActiveSession) return;

    _stopTimer();

    final now = DateTime.now();
    final updatedSession = _currentSession!.copyWith(
      endTime: now,
      actualDuration: _calculateActualDuration(),
      completed: true,
    );

    await _repository.updateSession(updatedSession);
    _currentSession = null;
    _sessionController.add(null);
  }

  /// 完成当前会话
  Future<void> completeCurrentSession() async {
    if (!hasActiveSession) return;

    _stopTimer();

    final now = DateTime.now();
    final updatedSession = _currentSession!.copyWith(
      endTime: now,
      actualDuration: _currentSession!.plannedDuration,
      completed: true,
    );

    await _repository.updateSession(updatedSession);
    _currentSession = null;
    _sessionController.add(null);
  }

  /// 获取今日会话统计
  Future<PomodoroStatistics> getTodayStatistics() async {
    final today = DateTime.now();
    final sessions = await _repository.getSessionsForDate(today);
    return _calculateStatistics(sessions);
  }

  /// 获取指定日期会话统计
  Future<PomodoroStatistics> getStatisticsForDate(DateTime date) async {
    final sessions = await _repository.getSessionsForDate(date);
    return _calculateStatistics(sessions);
  }

  /// 获取任务相关的会话统计
  Future<PomodoroStatistics> getTaskStatistics(String taskId) async {
    final sessions = await _repository.getSessionsForTask(taskId);
    return _calculateStatistics(sessions);
  }

  /// 恢复活动会话（应用启动时调用）
  Future<void> restoreActiveSession() async {
    final activeSession = await _repository.getActiveSession();
    if (activeSession != null) {
      _currentSession = activeSession;
      _sessionController.add(_currentSession);

      // 如果会话还在进行中，重新启动计时器
      if (activeSession.isActive) {
        _startTimer();
      }
    }
  }

  /// 启动计时器
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_currentSession == null) {
        timer.cancel();
        return;
      }

      final updatedSession = _currentSession!.copyWith(
        actualDuration: _calculateActualDuration(),
      );

      _currentSession = updatedSession;
      _sessionController.add(_currentSession);

      // 检查是否达到计划时间
      if (updatedSession.actualDuration >= updatedSession.plannedDuration) {
        completeCurrentSession();
      }
    });
  }

  /// 停止计时器
  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  /// 计算实际持续时间
  Duration _calculateActualDuration() {
    if (_currentSession == null) return Duration.zero;

    final now = DateTime.now();
    final elapsed = now.difference(_currentSession!.startTime);
    return elapsed;
  }

  /// 计算会话统计
  PomodoroStatistics _calculateStatistics(List<PomodoroSession> sessions) {
    final completedSessions = sessions.where((s) => s.completed).toList();
    final workSessions = completedSessions
        .where((s) => s.type == SessionType.work)
        .toList();
    final breakSessions = completedSessions
        .where((s) => s.type != SessionType.work)
        .toList();

    final totalWorkTime = workSessions.fold<Duration>(
      Duration.zero,
      (sum, session) => sum + session.actualDuration,
    );

    final totalBreakTime = breakSessions.fold<Duration>(
      Duration.zero,
      (sum, session) => sum + session.actualDuration,
    );

    return PomodoroStatistics(
      totalSessions: sessions.length,
      completedSessions: completedSessions.length,
      workSessions: workSessions.length,
      breakSessions: breakSessions.length,
      totalWorkTime: totalWorkTime,
      totalBreakTime: totalBreakTime,
      averageSessionLength: completedSessions.isNotEmpty
          ? Duration(
              milliseconds:
                  completedSessions
                      .map((s) => s.actualDuration.inMilliseconds)
                      .reduce((a, b) => a + b) ~/
                  completedSessions.length,
            )
          : Duration.zero,
    );
  }

  /// 释放资源
  void dispose() {
    _timer?.cancel();
    _sessionController.close();
  }
}

/// 番茄钟统计数据
class PomodoroStatistics {
  /// 创建番茄钟统计数据
  const PomodoroStatistics({
    required this.totalSessions,
    required this.completedSessions,
    required this.workSessions,
    required this.breakSessions,
    required this.totalWorkTime,
    required this.totalBreakTime,
    required this.averageSessionLength,
  });

  /// 总会话数
  final int totalSessions;

  /// 完成的会话数
  final int completedSessions;

  /// 工作会话数
  final int workSessions;

  /// 休息会话数
  final int breakSessions;

  /// 总工作时间
  final Duration totalWorkTime;

  /// 总休息时间
  final Duration totalBreakTime;

  /// 平均会话长度
  final Duration averageSessionLength;

  /// 完成率
  double get completionRate {
    if (totalSessions == 0) return 0.0;
    return completedSessions / totalSessions;
  }

  /// 工作效率（工作时间占比）
  double get workEfficiency {
    final totalTime = totalWorkTime + totalBreakTime;
    if (totalTime.inMilliseconds == 0) return 0.0;
    return totalWorkTime.inMilliseconds / totalTime.inMilliseconds;
  }
}
