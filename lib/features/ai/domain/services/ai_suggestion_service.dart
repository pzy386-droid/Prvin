import 'package:prvin/features/ai/domain/repositories/ai_analytics_repository.dart';
import 'package:prvin/features/task_management/domain/entities/task.dart';

/// AI建议服务
class AISuggestionService {
  /// 构造函数
  const AISuggestionService(this._repository);

  final AIAnalyticsRepository _repository;

  /// 获取任务创建建议
  Future<TaskSuggestion> getTaskCreationSuggestions(String taskTitle) async {
    try {
      // 并行获取标签和分类建议
      final futures = await Future.wait([
        _repository.getTagSuggestions(taskTitle),
        _repository.getCategorySuggestion(taskTitle),
      ]);

      final tagSuggestions = futures[0] as List<String>;
      final categorySuggestion = futures[1] as TaskCategory;

      return TaskSuggestion(
        suggestedTags: tagSuggestions,
        suggestedCategory: categorySuggestion,
        confidence: _calculateConfidence(taskTitle, tagSuggestions),
        reasoning: _generateReasoning(
          taskTitle,
          categorySuggestion,
          tagSuggestions,
        ),
      );
    } catch (e) {
      // 返回默认建议
      return const TaskSuggestion(
        suggestedTags: ['routine'],
        suggestedCategory: TaskCategory.other,
        confidence: 0.1,
        reasoning: '无法分析任务内容，提供默认建议',
      );
    }
  }

  /// 获取任务优化建议
  Future<List<TaskOptimizationSuggestion>> getTaskOptimizationSuggestions(
    List<Task> tasks,
  ) async {
    final suggestions = <TaskOptimizationSuggestion>[];

    // 检查时间冲突
    final conflicts = _detectTimeConflicts(tasks);
    for (final conflict in conflicts) {
      suggestions.add(
        TaskOptimizationSuggestion(
          type: TaskOptimizationType.timeConflict,
          message: '任务"${conflict.task1.title}"与"${conflict.task2.title}"时间冲突',
          affectedTasks: [conflict.task1, conflict.task2],
          priority: OptimizationPriority.high,
        ),
      );
    }

    // 检查任务分布
    final distributionSuggestion = _analyzeTaskDistribution(tasks);
    if (distributionSuggestion != null) {
      suggestions.add(distributionSuggestion);
    }

    // 检查任务持续时间
    final durationSuggestions = _analyzeDurations(tasks);
    suggestions.addAll(durationSuggestions);

    return suggestions;
  }

  /// 获取专注时间建议
  Future<FocusTimeSuggestion> getFocusTimeSuggestion(
    String userId,
    DateTime targetDate,
  ) async {
    try {
      final recommendations = await _repository.getFocusRecommendations(userId);

      if (recommendations.isNotEmpty) {
        final bestRecommendation = recommendations.first;
        return FocusTimeSuggestion(
          recommendedDuration: Duration(
            minutes: bestRecommendation.recommendedMinutes,
          ),
          bestTimeSlots: bestRecommendation.bestHours
              .map(
                (hour) => TimeSlot(
                  hour: hour,
                  confidence: bestRecommendation.confidence,
                ),
              )
              .toList(),
          reasoning: bestRecommendation.message,
        );
      }
    } catch (e) {
      // 忽略错误，返回默认建议
    }

    // 返回默认建议
    return const FocusTimeSuggestion(
      recommendedDuration: Duration(minutes: 25),
      bestTimeSlots: [
        TimeSlot(hour: 9, confidence: 0.8),
        TimeSlot(hour: 14, confidence: 0.7),
        TimeSlot(hour: 19, confidence: 0.6),
      ],
      reasoning: '建议使用番茄钟技术，在上午、下午或晚上进行专注工作',
    );
  }

  // 私有辅助方法

  double _calculateConfidence(String taskTitle, List<String> suggestions) {
    if (taskTitle.isEmpty) return 0.1;
    if (suggestions.isEmpty) return 0.2;

    // 基于任务标题长度和建议数量计算置信度
    final titleScore = (taskTitle.length / 50.0).clamp(0.0, 1.0);
    final suggestionScore = (suggestions.length / 5.0).clamp(0.0, 1.0);

    return (titleScore * 0.6 + suggestionScore * 0.4).clamp(0.1, 0.9);
  }

  String _generateReasoning(
    String taskTitle,
    TaskCategory category,
    List<String> tags,
  ) {
    final buffer = StringBuffer();

    buffer.write('基于任务标题"$taskTitle"的分析：');
    buffer.write('建议分类为${category.label}');

    if (tags.isNotEmpty) {
      buffer.write('，推荐标签：${tags.join('、')}');
    }

    return buffer.toString();
  }

  List<TaskConflict> _detectTimeConflicts(List<Task> tasks) {
    final conflicts = <TaskConflict>[];

    for (var i = 0; i < tasks.length; i++) {
      for (var j = i + 1; j < tasks.length; j++) {
        final task1 = tasks[i];
        final task2 = tasks[j];

        if (_tasksOverlap(task1, task2)) {
          conflicts.add(TaskConflict(task1: task1, task2: task2));
        }
      }
    }

    return conflicts;
  }

  bool _tasksOverlap(Task task1, Task task2) {
    return task1.startTime.isBefore(task2.endTime) &&
        task2.startTime.isBefore(task1.endTime);
  }

  TaskOptimizationSuggestion? _analyzeTaskDistribution(List<Task> tasks) {
    if (tasks.length < 3) return null;

    final categoryCount = <TaskCategory, int>{};
    for (final task in tasks) {
      categoryCount[task.category] = (categoryCount[task.category] ?? 0) + 1;
    }

    final maxCategory = categoryCount.entries.reduce(
      (a, b) => a.value > b.value ? a : b,
    );

    if (maxCategory.value > tasks.length * 0.7) {
      return TaskOptimizationSuggestion(
        type: TaskOptimizationType.categoryImbalance,
        message: '任务过于集中在${maxCategory.key.label}分类，建议增加其他类型任务',
        affectedTasks: tasks
            .where((t) => t.category == maxCategory.key)
            .toList(),
        priority: OptimizationPriority.medium,
      );
    }

    return null;
  }

  List<TaskOptimizationSuggestion> _analyzeDurations(List<Task> tasks) {
    final suggestions = <TaskOptimizationSuggestion>[];

    for (final task in tasks) {
      final duration = task.duration;

      if (duration.inMinutes > 120) {
        suggestions.add(
          TaskOptimizationSuggestion(
            type: TaskOptimizationType.longDuration,
            message:
                '任务"${task.title}"持续时间过长(${duration.inMinutes}分钟)，建议分解为多个小任务',
            affectedTasks: [task],
            priority: OptimizationPriority.medium,
          ),
        );
      } else if (duration.inMinutes < 15) {
        suggestions.add(
          TaskOptimizationSuggestion(
            type: TaskOptimizationType.shortDuration,
            message:
                '任务"${task.title}"持续时间过短(${duration.inMinutes}分钟)，建议与其他任务合并',
            affectedTasks: [task],
            priority: OptimizationPriority.low,
          ),
        );
      }
    }

    return suggestions;
  }
}

/// 任务建议
class TaskSuggestion {
  /// 构造函数
  const TaskSuggestion({
    required this.suggestedTags,
    required this.suggestedCategory,
    required this.confidence,
    required this.reasoning,
  });

  /// 建议的标签
  final List<String> suggestedTags;

  /// 建议的分类
  final TaskCategory suggestedCategory;

  /// 置信度 (0-1)
  final double confidence;

  /// 推理说明
  final String reasoning;
}

/// 任务优化建议
class TaskOptimizationSuggestion {
  /// 构造函数
  const TaskOptimizationSuggestion({
    required this.type,
    required this.message,
    required this.affectedTasks,
    required this.priority,
  });

  /// 建议类型
  final TaskOptimizationType type;

  /// 建议消息
  final String message;

  /// 受影响的任务
  final List<Task> affectedTasks;

  /// 优先级
  final OptimizationPriority priority;
}

/// 任务优化类型
enum TaskOptimizationType {
  /// 时间冲突
  timeConflict,

  /// 分类不平衡
  categoryImbalance,

  /// 持续时间过长
  longDuration,

  /// 持续时间过短
  shortDuration,
}

/// 优化优先级
enum OptimizationPriority {
  /// 低优先级
  low,

  /// 中优先级
  medium,

  /// 高优先级
  high,
}

/// 任务冲突
class TaskConflict {
  /// 构造函数
  const TaskConflict({required this.task1, required this.task2});

  /// 任务1
  final Task task1;

  /// 任务2
  final Task task2;
}

/// 专注时间建议
class FocusTimeSuggestion {
  /// 构造函数
  const FocusTimeSuggestion({
    required this.recommendedDuration,
    required this.bestTimeSlots,
    required this.reasoning,
  });

  /// 建议的专注时长
  final Duration recommendedDuration;

  /// 最佳时间段
  final List<TimeSlot> bestTimeSlots;

  /// 推理说明
  final String reasoning;
}

/// 时间段
class TimeSlot {
  /// 构造函数
  const TimeSlot({required this.hour, required this.confidence});

  /// 小时 (0-23)
  final int hour;

  /// 置信度 (0-1)
  final double confidence;
}
