import 'package:equatable/equatable.dart';

/// 任务优先级枚举
enum TaskPriority { low, medium, high, urgent }

/// 任务状态枚举
enum TaskStatus { pending, inProgress, completed, cancelled }

/// 任务分类枚举
enum TaskCategory { work, personal, health, learning, social }

/// 任务实体
///
/// 表示业务领域中的任务概念，不依赖于具体的数据存储实现
class Task extends Equatable {
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

  const Task({
    required this.id,
    required this.title,
    this.description,
    required this.startTime,
    required this.endTime,
    required this.tags,
    required this.priority,
    required this.status,
    required this.category,
    required this.createdAt,
    required this.updatedAt,
  });

  /// 获取任务持续时间
  Duration get duration => endTime.difference(startTime);

  /// 检查任务是否已过期
  bool get isOverdue {
    if (status == TaskStatus.completed || status == TaskStatus.cancelled) {
      return false;
    }
    return DateTime.now().isAfter(endTime);
  }

  /// 检查任务是否正在进行
  bool get isOngoing {
    final now = DateTime.now();
    return status == TaskStatus.inProgress &&
        now.isAfter(startTime) &&
        now.isBefore(endTime);
  }

  /// 检查任务是否即将开始（15分钟内）
  bool get isUpcoming {
    if (status != TaskStatus.pending) return false;

    final now = DateTime.now();
    final fifteenMinutesLater = now.add(const Duration(minutes: 15));
    return startTime.isAfter(now) && startTime.isBefore(fifteenMinutesLater);
  }

  /// 检查任务是否与另一个任务时间冲突
  bool hasTimeConflict(Task other) {
    return startTime.isBefore(other.endTime) &&
        endTime.isAfter(other.startTime);
  }

  /// 获取任务进度百分比（基于时间）
  double get progressPercentage {
    if (status == TaskStatus.completed) return 1.0;
    if (status == TaskStatus.cancelled) return 0.0;

    final now = DateTime.now();
    if (now.isBefore(startTime)) return 0.0;
    if (now.isAfter(endTime)) return 1.0;

    final totalDuration = endTime.difference(startTime).inMilliseconds;
    final elapsedDuration = now.difference(startTime).inMilliseconds;

    return elapsedDuration / totalDuration;
  }

  /// 复制并更新任务
  Task copyWith({
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
    return Task(
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
      updatedAt: updatedAt ?? DateTime.now(),
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
