import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'pomodoro_session_model.g.dart';

/// 会话类型枚举
enum SessionType {
  @JsonValue('work')
  work,
  @JsonValue('short_break')
  shortBreak,
  @JsonValue('long_break')
  longBreak,
}

/// 番茄钟会话数据模型
@JsonSerializable()
class PomodoroSessionModel extends Equatable {

  const PomodoroSessionModel({
    required this.id,
    required this.startTime,
    required this.plannedDuration, required this.actualDuration, required this.type, required this.completed, required this.createdAt, this.endTime,
    this.associatedTaskId,
  });

  /// 从JSON创建PomodoroSessionModel
  factory PomodoroSessionModel.fromJson(Map<String, dynamic> json) =>
      _$PomodoroSessionModelFromJson(json);
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

  /// 转换为JSON
  Map<String, dynamic> toJson() => _$PomodoroSessionModelToJson(this);

  /// 数据验证
  bool isValid() {
    // 计划持续时间必须大于0
    if (plannedDuration.inSeconds <= 0) return false;

    // 如果会话已结束，结束时间不能为空且必须晚于开始时间
    if (completed && (endTime == null || endTime!.isBefore(startTime))) {
      return false;
    }

    // 实际持续时间不能为负数
    if (actualDuration.inSeconds < 0) return false;

    return true;
  }

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
  PomodoroSessionModel copyWith({
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
    return PomodoroSessionModel(
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
