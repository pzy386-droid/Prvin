import 'package:prvin/features/pomodoro/domain/entities/pomodoro_session.dart';

/// 番茄钟仓库接口
abstract class PomodoroRepository {
  /// 获取所有会话
  Future<List<PomodoroSession>> getAllSessions();

  /// 获取指定日期的会话
  Future<List<PomodoroSession>> getSessionsForDate(DateTime date);

  /// 按类型获取会话
  Future<List<PomodoroSession>> getSessionsByType(SessionType type);

  /// 获取任务关联的会话
  Future<List<PomodoroSession>> getSessionsForTask(String taskId);

  /// 根据ID获取会话
  Future<PomodoroSession?> getSessionById(String id);

  /// 获取当前活动会话
  Future<PomodoroSession?> getActiveSession();

  /// 创建新会话
  Future<String> createSession(PomodoroSession session);

  /// 更新会话
  Future<void> updateSession(PomodoroSession session);

  /// 删除会话
  Future<void> deleteSession(String id);

  /// 清空所有会话
  Future<void> clearAllSessions();
}
