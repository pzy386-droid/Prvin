/// 番茄钟会话数据模型
class PomodoroSession {
  /// 创建番茄钟会话
  const PomodoroSession({
    required this.id,
    required this.startTime,
    required this.plannedDuration, required this.actualDuration, required this.type, this.endTime,
    this.associatedTaskId,
    this.completed = false,
    this.createdAt,
  });

  /// 从JSON创建
  factory PomodoroSession.fromJson(Map<String, dynamic> json) {
    return PomodoroSession(
      id: json['id'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'] as String)
          : null,
      plannedDuration: Duration(milliseconds: json['plannedDuration'] as int),
      actualDuration: Duration(milliseconds: json['actualDuration'] as int),
      type: SessionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => SessionType.work,
      ),
      associatedTaskId: json['associatedTaskId'] as String?,
      completed: json['completed'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }

  /// 会话ID
  final String id;

  /// 开始时间
  final DateTime startTime;

  /// 结束时间
  final DateTime? endTime;

  /// 计划时长
  final Duration plannedDuration;

  /// 实际时长
  final Duration actualDuration;

  /// 会话类型
  final SessionType type;

  /// 关联的任务ID
  final String? associatedTaskId;

  /// 是否完成
  final bool completed;

  /// 创建时间
  final DateTime? createdAt;

  /// 复制并修改数据
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

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'plannedDuration': plannedDuration.inMilliseconds,
      'actualDuration': actualDuration.inMilliseconds,
      'type': type.name,
      'associatedTaskId': associatedTaskId,
      'completed': completed,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  /// 获取会话效率百分比
  double get efficiency {
    if (plannedDuration.inMilliseconds == 0) return 0;
    return (actualDuration.inMilliseconds / plannedDuration.inMilliseconds)
        .clamp(0.0, 1.0);
  }

  /// 是否为工作会话
  bool get isWorkSession => type == SessionType.work;

  /// 是否为休息会话
  bool get isBreakSession =>
      type == SessionType.shortBreak || type == SessionType.longBreak;

  @override
  String toString() {
    return 'PomodoroSession(id: $id, type: $type, completed: $completed, '
        'duration: ${actualDuration.inMinutes}min)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PomodoroSession &&
        other.id == id &&
        other.startTime == startTime &&
        other.endTime == endTime &&
        other.plannedDuration == plannedDuration &&
        other.actualDuration == actualDuration &&
        other.type == type &&
        other.associatedTaskId == associatedTaskId &&
        other.completed == completed;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      startTime,
      endTime,
      plannedDuration,
      actualDuration,
      type,
      associatedTaskId,
      completed,
    );
  }
}

/// 会话类型枚举
enum SessionType {
  /// 工作会话
  work,

  /// 短休息
  shortBreak,

  /// 长休息
  longBreak,
}

/// 会话类型扩展
extension SessionTypeExtension on SessionType {
  /// 获取显示名称
  String get displayName {
    switch (this) {
      case SessionType.work:
        return '专注时间';
      case SessionType.shortBreak:
        return '短休息';
      case SessionType.longBreak:
        return '长休息';
    }
  }

  /// 获取默认时长
  Duration get defaultDuration {
    switch (this) {
      case SessionType.work:
        return const Duration(minutes: 25);
      case SessionType.shortBreak:
        return const Duration(minutes: 5);
      case SessionType.longBreak:
        return const Duration(minutes: 15);
    }
  }

  /// 获取颜色
  int get colorValue {
    switch (this) {
      case SessionType.work:
        return 0xFF6366F1; // 蓝紫色
      case SessionType.shortBreak:
        return 0xFF10B981; // 绿色
      case SessionType.longBreak:
        return 0xFF8B5CF6; // 紫色
    }
  }
}
