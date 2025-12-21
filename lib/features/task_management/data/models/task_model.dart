import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'task_model.g.dart';

/// 任务优先级枚举
enum TaskPriority {
  @JsonValue('low')
  low,
  @JsonValue('medium')
  medium,
  @JsonValue('high')
  high,
  @JsonValue('urgent')
  urgent,
}

/// 任务状态枚举
enum TaskStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('in_progress')
  inProgress,
  @JsonValue('completed')
  completed,
  @JsonValue('cancelled')
  cancelled,
}

/// 任务分类枚举
enum TaskCategory {
  @JsonValue('work')
  work,
  @JsonValue('personal')
  personal,
  @JsonValue('health')
  health,
  @JsonValue('learning')
  learning,
  @JsonValue('social')
  social,
}

/// 任务数据模型
@JsonSerializable()
class TaskModel extends Equatable {

  const TaskModel({
    required this.id,
    required this.title,
    required this.startTime, required this.endTime, required this.tags, required this.priority, required this.status, required this.category, required this.createdAt, required this.updatedAt, this.description,
  });

  /// 从JSON创建TaskModel
  factory TaskModel.fromJson(Map<String, dynamic> json) =>
      _$TaskModelFromJson(json);
  /// 任务ID
  final String id;

  /// 任务标题
  final String title;

  /// 任务描述
  final String? description;

  /// 开始时间
  final DateTime startTime;

  /// 结束时间
  final DateTime endTime;

  /// 标签列表
  final List<String> tags;

  /// 优先级
  final TaskPriority priority;

  /// 状态
  final TaskStatus status;

  /// 分类
  final TaskCategory category;

  /// 创建时间
  final DateTime createdAt;

  /// 更新时间
  final DateTime updatedAt;

  /// 转换为JSON
  Map<String, dynamic> toJson() => _$TaskModelToJson(this);

  /// 数据验证
  bool isValid() {
    // 标题不能为空
    if (title.trim().isEmpty) return false;

    // 结束时间必须晚于开始时间
    if (endTime.isBefore(startTime)) return false;

    // 创建时间不能晚于更新时间
    if (createdAt.isAfter(updatedAt)) return false;

    return true;
  }

  /// 检查时间是否冲突
  bool hasTimeConflict(TaskModel other) {
    return startTime.isBefore(other.endTime) &&
        endTime.isAfter(other.startTime);
  }

  /// 获取任务持续时间
  Duration get duration => endTime.difference(startTime);

  /// 检查任务是否已完成
  bool get isCompleted => status == TaskStatus.completed;

  /// 检查任务是否进行中
  bool get isInProgress => status == TaskStatus.inProgress;

  /// 复制并更新任务
  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    List<String>? tags,
    TaskPriority? priority,
    TaskStatus? status,
    TaskCategory? category,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      tags: tags ?? this.tags,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    startTime,
    endTime,
    tags,
    priority,
    status,
    category,
    createdAt,
    updatedAt,
  ];
}
