import 'package:equatable/equatable.dart';
import 'package:prvine/features/tasks/data/models/task_model.dart';

/// 任务创建请求数据
class TaskCreateRequest extends Equatable {

  const TaskCreateRequest({
    required this.title,
    required this.startTime, required this.endTime, this.description,
    this.tags = const [],
    this.priority = TaskPriority.medium,
    this.category = TaskCategory.personal,
  });
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

  /// 分类
  final TaskCategory category;

  /// 数据验证
  bool isValid() {
    // 标题不能为空
    if (title.trim().isEmpty) return false;

    // 结束时间必须晚于开始时间
    if (endTime.isBefore(startTime)) return false;

    return true;
  }

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
