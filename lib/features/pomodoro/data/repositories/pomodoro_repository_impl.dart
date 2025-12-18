import '../../domain/entities/pomodoro_session.dart';
import '../../domain/repositories/pomodoro_repository.dart';
import '../datasources/pomodoro_local_datasource.dart';
import '../models/pomodoro_session_model.dart';

/// 番茄钟仓库实现
class PomodoroRepositoryImpl implements PomodoroRepository {
  /// 创建番茄钟仓库实现
  const PomodoroRepositoryImpl(this._localDataSource);

  final PomodoroLocalDataSource _localDataSource;

  @override
  Future<List<PomodoroSession>> getAllSessions() async {
    final models = await _localDataSource.getAllSessions();
    return models.map<PomodoroSession>(_modelToEntity).toList();
  }

  @override
  Future<List<PomodoroSession>> getSessionsForDate(DateTime date) async {
    final models = await _localDataSource.getSessionsForDate(date);
    return models.map<PomodoroSession>(_modelToEntity).toList();
  }

  @override
  Future<List<PomodoroSession>> getSessionsByType(SessionType type) async {
    final modelType = _entityTypeToModelType(type);
    final models = await _localDataSource.getSessionsByType(modelType);
    return models.map<PomodoroSession>(_modelToEntity).toList();
  }

  @override
  Future<List<PomodoroSession>> getSessionsForTask(String taskId) async {
    final models = await _localDataSource.getSessionsForTask(taskId);
    return models.map<PomodoroSession>(_modelToEntity).toList();
  }

  @override
  Future<PomodoroSession?> getSessionById(String id) async {
    final model = await _localDataSource.getSessionById(id);
    return model != null ? _modelToEntity(model) : null;
  }

  @override
  Future<PomodoroSession?> getActiveSession() async {
    final model = await _localDataSource.getActiveSession();
    return model != null ? _modelToEntity(model) : null;
  }

  @override
  Future<String> createSession(PomodoroSession session) async {
    final model = _entityToModel(session);
    return _localDataSource.createSession(model);
  }

  @override
  Future<void> updateSession(PomodoroSession session) async {
    final model = _entityToModel(session);
    await _localDataSource.updateSession(model);
  }

  @override
  Future<void> deleteSession(String id) async {
    await _localDataSource.deleteSession(id);
  }

  @override
  Future<void> clearAllSessions() async {
    await _localDataSource.clearAllSessions();
  }

  /// 将模型转换为实体
  PomodoroSession _modelToEntity(PomodoroSessionModel model) {
    return PomodoroSession(
      id: model.id,
      startTime: model.startTime,
      endTime: model.endTime,
      plannedDuration: model.plannedDuration,
      actualDuration: model.actualDuration,
      type: _modelTypeToEntityType(model.type),
      associatedTaskId: model.associatedTaskId,
      completed: model.completed,
      createdAt: model.createdAt,
    );
  }

  /// 将实体转换为模型
  PomodoroSessionModel _entityToModel(PomodoroSession entity) {
    return PomodoroSessionModel(
      id: entity.id,
      startTime: entity.startTime,
      endTime: entity.endTime,
      plannedDuration: entity.plannedDuration,
      actualDuration: entity.actualDuration,
      type: _entityTypeToModelType(entity.type),
      associatedTaskId: entity.associatedTaskId,
      completed: entity.completed,
      createdAt: entity.createdAt,
    );
  }

  /// 将模型会话类型转换为实体会话类型
  SessionType _modelTypeToEntityType(SessionType modelType) {
    switch (modelType) {
      case SessionType.work:
        return SessionType.work;
      case SessionType.shortBreak:
        return SessionType.shortBreak;
      case SessionType.longBreak:
        return SessionType.longBreak;
    }
  }

  /// 将实体会话类型转换为模型会话类型
  SessionType _entityTypeToModelType(SessionType entityType) {
    switch (entityType) {
      case SessionType.work:
        return SessionType.work;
      case SessionType.shortBreak:
        return SessionType.shortBreak;
      case SessionType.longBreak:
        return SessionType.longBreak;
    }
  }
}
