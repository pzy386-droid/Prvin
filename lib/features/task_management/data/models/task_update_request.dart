import 'package:equatable/equatable.dart';
import 'package:prvine/features/tasks/data/models/task_model.dart';

/// 任务更新请求数据
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
  /// 任务标题
  final String? title;

  /// 任务描述
  final String? description;

  /// 开始时间
  final DateTime? startTime;

  /// 结束时间
  final DateTime? endTime;

  /// 标签列表
  final List<String>? tags;

  /// 优先级
  final TaskPriority? priority;

  /// 状态
  final TaskStatus? status;

  /// 分类
  final TaskCategory? category;

  /// 数据验证
  bool isValid() {
    // 如果提供了标题，不能为空
    if (title != null && title!.trim().isEmpty) return false;

    // 如果同时提供了开始和结束时间，结束时间必须晚于开始时间
    if (startTime != null && endTime != null && endTime!.isBefore(startTime!)) {
      return false;
    }

    return true;
  }

  /// 检查是否有任何更新
  bool get hasUpdates =>
      title != null ||
      description != null ||
      startTime != null ||
      endTime != null ||
      tags != null ||
      priority != null ||
      status != null ||
      category != null;

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
