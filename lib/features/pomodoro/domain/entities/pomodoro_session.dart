import 'package:equatable/equatable.dart';

/// 会话类型枚举
enum SessionType {
  /// 工作时间
  work,

  /// 短休息
  shortBreak,

  /// 长休息
  longBreak,
}

/// 番茄钟会话实体
class PomodoroSession extends Equatable {
  /// 创建番茄钟会话实体
  const PomodoroSession({
    required this.id,
    required this.startTime,
    this.endTime,
    required this.plannedDuration,
    required this.actualDuration,
    required this.type,
    this.associatedTaskId,
    required this.completed,
    required this.createdAt,
  });

  /// 会话ID
  final String id;

  /// 开始时间
  final DateTime startTime;

  /// 结束时间（可能为空，表示会话未结束）
  final DateTime? endTime;

  /// 计划持续时间
  final Duration plannedDuration;

  /// 实际持续时间
  final Duration actualDuration;

  /// 会话类型
  final SessionType type;

  /// 关联的任务ID（可选）
  final String? associatedTaskId;

  /// 是否完成
  final bool completed;

  /// 创建时间
  final DateTime createdAt;

  /// 获取会话进度（0.0 - 1.0）
  double get progress {
    if (plannedDuration.inSeconds == 0) return 0;
    return (actualDuration.inSeconds / plannedDuration.inSeconds).clamp(
      0.0,
      1.0,
    );
  }

  /// 获取剩余时间
  Duration get remainingTime {
    final remaining = plannedDuration - actualDuration;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// 检查会话是否进行中
  bool get isActive => !completed && endTime == null;

  /// 检查会话是否超时
  bool get isOvertime => actualDuration > plannedDuration;

  /// 复制并更新会话
  PomodoroSession copyWith({
    String? id,
    DateTime? startTime,
    DateTime? endTime,
    Duration? plannedDuration,
    Duration? actualDuration,
    SessionType? type,
    String? associatedTaskId,
    bool? completed,
    DateTime? createdAt,
  }) {
    return PomodoroSession(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      plannedDuration: plannedDuration ?? this.plannedDuration,
      actualDuration: actualDuration ?? this.actualDuration,
      type: type ?? this.type,
      associatedTaskId: associatedTaskId ?? this.associatedTaskId,
      completed: completed ?? this.completed,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    startTime,
    endTime,
    plannedDuration,
    actualDuration,
    type,
    associatedTaskId,
    completed,
    createdAt,
  ];
}
