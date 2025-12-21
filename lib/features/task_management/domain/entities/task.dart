import 'package:equatable/equatable.dart';

/// 任务优先级枚举
enum TaskPriority {
  low('低', 1),
  medium('中', 2),
  high('高', 3),
  urgent('紧急', 4);

  const TaskPriority(this.label, this.value);
  final String label;
  final int value;
}

/// 任务状态枚举
enum TaskStatus {
  pending('待办'),
  inProgress('进行中'),
  completed('已完成'),
  cancelled('已取消');

  const TaskStatus(this.label);
  final String label;
}

/// 任务分类枚举
enum TaskCategory {
  work('工作'),
  personal('个人'),
  study('学习'),
  health('健康'),
  social('社交'),
  other('其他');

  const TaskCategory(this.label);
  final String label;
}

/// 任务实体类
class Task extends Equatable {
  const Task({
    required this.id,
    required this.title,
    required this.startTime, required this.endTime, required this.createdAt, required this.updatedAt, this.description,
    this.tags = const [],
    this.priority = TaskPriority.medium,
    this.status = TaskStatus.pending,
    this.category = TaskCategory.other,
  });

  /// 从Map创建任务实例
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      startTime: DateTime.fromMillisecondsSinceEpoch(map['startTime'] as int),
      endTime: DateTime.fromMillisecondsSinceEpoch(map['endTime'] as int),
      tags: List<String>.from(map['tags'] as List),
      priority: TaskPriority.values.firstWhere(
        (e) => e.name == map['priority'],
        orElse: () => TaskPriority.medium,
      ),
      status: TaskStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => TaskStatus.pending,
      ),
      category: TaskCategory.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => TaskCategory.other,
      ),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int),
    );
  }

  final String id;
  final String title;
  final String? description;
  final DateTime startTime;
  final DateTime endTime;
  final List<String> tags;
  final TaskPriority priority;
  final TaskStatus status;
  final TaskCategory category;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// 任务持续时间
  Duration get duration => endTime.difference(startTime);

  /// 是否是今天的任务
  bool get isToday {
    final now = DateTime.now();
    return startTime.year == now.year &&
        startTime.month == now.month &&
        startTime.day == now.day;
  }

  /// 是否已过期
  bool get isOverdue {
    return DateTime.now().isAfter(endTime) && status != TaskStatus.completed;
  }

  /// 复制任务并修改部分属性
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
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// 转换为Map用于序列化
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startTime': startTime.millisecondsSinceEpoch,
      'endTime': endTime.millisecondsSinceEpoch,
      'tags': tags,
      'priority': priority.name,
      'status': status.name,
      'category': category.name,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
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

  @override
  String toString() {
    return 'Task(id: $id, title: $title, startTime: $startTime, endTime: $endTime, priority: $priority, status: $status)';
  }
}

/// 任务创建请求
class TaskCreateRequest extends Equatable {
  const TaskCreateRequest({
    required this.title,
    required this.startTime, required this.endTime, this.description,
    this.tags = const [],
    this.priority = TaskPriority.medium,
    this.category = TaskCategory.other,
  });

  final String title;
  final String? description;
  final DateTime startTime;
  final DateTime endTime;
  final List<String> tags;
  final TaskPriority priority;
  final TaskCategory category;

  @override
  List<Object?> get props => [
    title,
    description,
    startTime,
    endTime,
    tags,
    priority,
    category,
  ];
}

/// 任务更新请求
class TaskUpdateRequest extends Equatable {
  const TaskUpdateRequest({
    this.title,
    this.description,
    this.startTime,
    this.endTime,
    this.tags,
    this.priority,
    this.status,
    this.category,
  });

  final String? title;
  final String? description;
  final DateTime? startTime;
  final DateTime? endTime;
  final List<String>? tags;
  final TaskPriority? priority;
  final TaskStatus? status;
  final TaskCategory? category;

  @override
  List<Object?> get props => [
    title,
    description,
    startTime,
    endTime,
    tags,
    priority,
    status,
    category,
  ];
}

/// 时间冲突警告
class ConflictWarning extends Equatable {
  const ConflictWarning({
    required this.conflictingTask,
    required this.newTask,
    required this.overlapDuration,
  });

  final Task conflictingTask;
  final Task newTask;
  final Duration overlapDuration;

  @override
  List<Object> get props => [conflictingTask, newTask, overlapDuration];
}
