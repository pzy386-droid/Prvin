import 'dart:async';

/// 应用级事件总线
class EventBus {
  factory EventBus() => _instance;
  EventBus._internal();
  static final EventBus _instance = EventBus._internal();

  final Map<Type, StreamController> _controllers = {};
  final Map<Type, Stream> _streams = {};

  /// 发布事件
  void publish<T>(T event) {
    final controller = _controllers[T];
    if (controller != null) {
      controller.add(event);
    }
  }

  /// 订阅事件
  Stream<T> subscribe<T>() {
    if (!_streams.containsKey(T)) {
      final controller = StreamController<T>.broadcast();
      _controllers[T] = controller;
      _streams[T] = controller.stream;
    }
    return _streams[T]! as Stream<T>;
  }

  /// 清理资源
  void dispose() {
    for (final controller in _controllers.values) {
      controller.close();
    }
    _controllers.clear();
    _streams.clear();
  }
}

/// 事件基类
abstract class AppEvent {
  const AppEvent();
}

/// 任务相关事件
class TaskCreatedEvent extends AppEvent {
  const TaskCreatedEvent(this.taskId);
  final String taskId;
}

class TaskUpdatedEvent extends AppEvent {
  const TaskUpdatedEvent(this.taskId);
  final String taskId;
}

class TaskDeletedEvent extends AppEvent {
  const TaskDeletedEvent(this.taskId);
  final String taskId;
}

/// 番茄钟相关事件
class PomodoroStartedEvent extends AppEvent {
  const PomodoroStartedEvent(this.sessionId);
  final String sessionId;
}

class PomodoroCompletedEvent extends AppEvent {
  const PomodoroCompletedEvent(this.sessionId);
  final String sessionId;
}

/// 同步相关事件
class SyncStartedEvent extends AppEvent {
  const SyncStartedEvent();
}

class SyncCompletedEvent extends AppEvent {
  const SyncCompletedEvent();
}

class SyncFailedEvent extends AppEvent {
  const SyncFailedEvent(this.error);
  final String error;
}
