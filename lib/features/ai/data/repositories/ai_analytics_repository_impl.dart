import 'dart:math';

import 'package:prvin/features/ai/data/datasources/ai_local_datasource.dart';
import 'package:prvin/features/ai/domain/entities/analytics_data.dart';
import 'package:prvin/features/ai/domain/repositories/ai_analytics_repository.dart';
import 'package:prvin/features/task_management/domain/entities/task.dart';

/// AI分析仓库实现
class AIAnalyticsRepositoryImpl implements AIAnalyticsRepository {
  /// 构造函数
  const AIAnalyticsRepositoryImpl(this._localDataSource);

  final AILocalDataSource _localDataSource;

  // 预定义的关键词映射
  static const Map<String, List<String>> _categoryKeywords = {
    'work': [
      '会议',
      '项目',
      '报告',
      '工作',
      '任务',
      '开发',
      '设计',
      '测试',
      '部署',
      '客户',
      '合作',
      '团队',
      '管理',
      '计划',
      '预算',
      '销售',
      '市场',
      'meeting',
      'project',
      'report',
      'work',
      'task',
      'development',
      'design',
      'test',
      'deploy',
      'client',
      'cooperation',
      'team',
      'management',
      'plan',
      'budget',
      'sales',
      'marketing',
    ],
    'study': [
      '学习',
      '课程',
      '考试',
      '作业',
      '研究',
      '阅读',
      '笔记',
      '复习',
      '练习',
      '培训',
      '教程',
      '书籍',
      '论文',
      '知识',
      '技能',
      'study',
      'course',
      'exam',
      'homework',
      'research',
      'reading',
      'notes',
      'review',
      'practice',
      'training',
      'tutorial',
      'book',
      'paper',
      'knowledge',
      'skill',
    ],
    'health': [
      '运动',
      '健身',
      '跑步',
      '游泳',
      '瑜伽',
      '医院',
      '体检',
      '药物',
      '饮食',
      '睡眠',
      '休息',
      '锻炼',
      '康复',
      '治疗',
      'exercise',
      'fitness',
      'running',
      'swimming',
      'yoga',
      'hospital',
      'checkup',
      'medicine',
      'diet',
      'sleep',
      'rest',
      'workout',
      'recovery',
      'treatment',
    ],
    'personal': [
      '购物',
      '家务',
      '清洁',
      '整理',
      '维修',
      '装修',
      '搬家',
      '旅行',
      '度假',
      '娱乐',
      '电影',
      '音乐',
      '游戏',
      '爱好',
      '兴趣',
      'shopping',
      'housework',
      'cleaning',
      'organizing',
      'repair',
      'renovation',
      'moving',
      'travel',
      'vacation',
      'entertainment',
      'movie',
      'music',
      'game',
      'hobby',
      'interest',
    ],
    'social': [
      '聚会',
      '朋友',
      '家人',
      '约会',
      '聊天',
      '电话',
      '拜访',
      '庆祝',
      '生日',
      '婚礼',
      '聚餐',
      '社交',
      '活动',
      '志愿',
      'party',
      'friends',
      'family',
      'date',
      'chat',
      'phone',
      'visit',
      'celebrate',
      'birthday',
      'wedding',
      'dinner',
      'social',
      'activity',
      'volunteer',
    ],
  };

  static const Map<String, List<String>> _commonTags = {
    'urgent': ['紧急', '急', '立即', '马上', 'urgent', 'asap', 'immediate'],
    'important': ['重要', '关键', '核心', 'important', 'key', 'critical'],
    'routine': ['日常', '例行', '常规', 'routine', 'regular', 'daily'],
    'creative': ['创意', '设计', '创作', 'creative', 'design', 'create'],
    'communication': ['沟通', '交流', '联系', 'communication', 'contact', 'call'],
    'planning': ['计划', '规划', '安排', 'planning', 'schedule', 'organize'],
    'review': ['检查', '审查', '复习', 'review', 'check', 'inspect'],
    'research': ['研究', '调研', '分析', 'research', 'analysis', 'investigate'],
  };

  @override
  Future<AnalyticsData> generateAnalytics({
    required String userId,
    required DateRange period,
  }) async {
    try {
      // 获取指定时间范围内的任务数据
      final tasks = await _getTasksInPeriod(userId, period);

      // 生成时间分配统计
      final timeDistribution = _calculateTimeDistribution(tasks);

      // 计算完成率
      final completionRate = _calculateCompletionRate(tasks);

      // 生成生产力趋势
      final trends = await _generateProductivityTrends(userId, period);

      // 分析专注模式
      final focusPatterns = await _analyzeFocusPatterns(userId, period);

      // 检测任务模式
      final taskPatterns = await _detectTaskPatterns(tasks);

      // 生成专注建议
      final focusRecommendations = await _generateFocusRecommendations(
        userId,
        focusPatterns,
        trends,
      );

      return AnalyticsData(
        userId: userId,
        period: period,
        timeDistribution: timeDistribution,
        completionRate: completionRate,
        trends: trends,
        focusPatterns: focusPatterns,
        taskPatterns: taskPatterns,
        focusRecommendations: focusRecommendations,
        generatedAt: DateTime.now(),
      );
    } catch (e) {
      throw Exception('生成分析数据失败: $e');
    }
  }

  @override
  Future<List<String>> getTagSuggestions(String taskTitle) async {
    final suggestions = <String>[];
    final titleLower = taskTitle.toLowerCase();

    // 基于关键词匹配生成标签建议
    for (final entry in _commonTags.entries) {
      final tagName = entry.key;
      final keywords = entry.value;

      for (final keyword in keywords) {
        if (titleLower.contains(keyword.toLowerCase())) {
          suggestions.add(tagName);
          break;
        }
      }
    }

    // 为工作相关任务添加特定标签
    final workKeywords = [
      '会议',
      '项目',
      '报告',
      '工作',
      '任务',
      '开发',
      '设计',
      'meeting',
      'project',
      'work',
    ];
    final hasWorkKeyword = workKeywords.any(
      (keyword) => titleLower.contains(keyword.toLowerCase()),
    );
    if (hasWorkKeyword && !suggestions.contains('important')) {
      suggestions.add('important');
    }
    if (hasWorkKeyword && !suggestions.contains('planning')) {
      suggestions.add('planning');
    }

    // 添加一些通用标签建议
    if (suggestions.isEmpty) {
      suggestions.addAll(['routine', 'planning']);
    }

    // 限制建议数量
    return suggestions.take(5).toList();
  }

  @override
  Future<TaskCategory> getCategorySuggestion(String taskTitle) async {
    final titleLower = taskTitle.toLowerCase();
    final categoryScores = <String, int>{};

    // 计算每个分类的匹配分数
    for (final entry in _categoryKeywords.entries) {
      final category = entry.key;
      final keywords = entry.value;
      var score = 0;

      for (final keyword in keywords) {
        if (titleLower.contains(keyword.toLowerCase())) {
          // 给更长的关键词更高的权重，并且给精确匹配更高分数
          final keywordLength = keyword.length;
          final exactMatch = titleLower == keyword.toLowerCase();
          score += exactMatch ? keywordLength * 3 : keywordLength;
        }
      }

      if (score > 0) {
        categoryScores[category] = score;
      }
    }

    // 找到得分最高的分类
    if (categoryScores.isNotEmpty) {
      final bestCategory = categoryScores.entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key;

      switch (bestCategory) {
        case 'work':
          return TaskCategory.work;
        case 'study':
          return TaskCategory.study;
        case 'health':
          return TaskCategory.health;
        case 'personal':
          return TaskCategory.personal;
        case 'social':
          return TaskCategory.social;
        default:
          return TaskCategory.other;
      }
    }

    // 默认返回其他分类
    return TaskCategory.other;
  }

  @override
  Future<List<FocusRecommendation>> getFocusRecommendations(
    String userId,
  ) async {
    final recommendations = <FocusRecommendation>[];
    final now = DateTime.now();

    // 总是提供上午建议
    recommendations.add(
      FocusRecommendation(
        type: 'morning_focus',
        message: '上午是专注度最高的时间段，建议进行重要任务',
        recommendedMinutes: 45,
        bestHours: const [9, 10, 11],
        confidence: 0.8,
        generatedAt: now,
      ),
    );

    // 总是提供下午建议
    recommendations.add(
      FocusRecommendation(
        type: 'afternoon_focus',
        message: '下午适合进行创意性工作和头脑风暴',
        recommendedMinutes: 35,
        bestHours: const [14, 15, 16],
        confidence: 0.7,
        generatedAt: now,
      ),
    );

    // 通用番茄钟建议
    recommendations.add(
      FocusRecommendation(
        type: 'pomodoro',
        message: '建议使用番茄钟技术，25分钟专注+5分钟休息',
        recommendedMinutes: 25,
        bestHours: const [9, 10, 14, 15, 19, 20],
        confidence: 0.9,
        generatedAt: now,
      ),
    );

    return recommendations;
  }

  @override
  Future<List<TaskPattern>> analyzeTaskPatterns(String userId) async {
    try {
      // 获取用户的历史任务
      final tasks = await _getUserTasks(userId);
      final patterns = <TaskPattern>[];

      // 按分类分组任务
      final tasksByCategory = <TaskCategory, List<Task>>{};
      for (final task in tasks) {
        tasksByCategory.putIfAbsent(task.category, () => []).add(task);
      }

      // 为每个分类生成模式
      for (final entry in tasksByCategory.entries) {
        final category = entry.key;
        final categoryTasks = entry.value;

        if (categoryTasks.length >= 3) {
          // 分析相似任务
          final similarTasks = categoryTasks
              .map((task) => task.title)
              .take(5)
              .toList();

          // 生成建议标签
          final suggestedTags = await _generateTagsForCategory(category);

          // 计算平均完成时间
          final completedTasks = categoryTasks
              .where((task) => task.status == TaskStatus.completed)
              .toList();

          final averageMinutes = completedTasks.isNotEmpty
              ? completedTasks
                        .map((task) => task.duration.inMinutes)
                        .reduce((a, b) => a + b) /
                    completedTasks.length
              : 30.0;

          patterns.add(
            TaskPattern(
              patternName: '${category.label}任务模式',
              similarTasks: similarTasks,
              suggestedTags: suggestedTags,
              suggestedCategory: category,
              averageCompletionMinutes: averageMinutes,
              confidence: min(categoryTasks.length / 10.0, 1),
            ),
          );
        }
      }

      return patterns;
    } catch (e) {
      throw Exception('分析任务模式失败: $e');
    }
  }

  @override
  Future<List<ProductivityTrend>> getProductivityTrends({
    required String userId,
    required DateRange period,
  }) async {
    return _generateProductivityTrends(userId, period);
  }

  @override
  Future<List<FocusPattern>> getFocusPatterns({
    required String userId,
    required DateRange period,
  }) async {
    return _analyzeFocusPatterns(userId, period);
  }

  @override
  Future<void> saveAnalyticsData(AnalyticsData data) async {
    await _localDataSource.saveAnalyticsData(data);
  }

  @override
  Future<List<AnalyticsData>> getHistoricalAnalytics({
    required String userId,
    required DateRange period,
  }) async {
    return _localDataSource.getHistoricalAnalytics(userId, period);
  }

  @override
  Future<void> clearExpiredAnalytics({Duration? olderThan}) async {
    final duration = olderThan ?? const Duration(days: 90);
    await _localDataSource.clearExpiredData(duration);
  }

  // 私有辅助方法

  Future<List<Task>> _getTasksInPeriod(String userId, DateRange period) async {
    return _localDataSource.getTasksInPeriod(userId, period);
  }

  Future<List<Task>> _getUserTasks(String userId) async {
    return _localDataSource.getUserTasks(userId);
  }

  Map<String, int> _calculateTimeDistribution(List<Task> tasks) {
    final distribution = <String, int>{};

    for (final task in tasks) {
      final category = task.category.label;
      final minutes = task.duration.inMinutes;
      distribution[category] = (distribution[category] ?? 0) + minutes;
    }

    return distribution;
  }

  double _calculateCompletionRate(List<Task> tasks) {
    if (tasks.isEmpty) return 0;

    final completedTasks = tasks
        .where((task) => task.status == TaskStatus.completed)
        .length;

    return completedTasks / tasks.length;
  }

  Future<List<ProductivityTrend>> _generateProductivityTrends(
    String userId,
    DateRange period,
  ) async {
    final trends = <ProductivityTrend>[];
    final random = Random();

    // 生成模拟的生产力趋势数据
    for (var i = 0; i < period.dayCount; i++) {
      final date = period.startDate.add(Duration(days: i));
      trends.add(
        ProductivityTrend(
          date: date,
          completedTasks: random.nextInt(8) + 2,
          totalWorkMinutes: random.nextInt(300) + 180,
          focusMinutes: random.nextInt(120) + 60,
          efficiencyScore: random.nextDouble() * 40 + 60,
        ),
      );
    }

    return trends;
  }

  Future<List<FocusPattern>> _analyzeFocusPatterns(
    String userId,
    DateRange period,
  ) async {
    final patterns = <FocusPattern>[];
    final random = Random();

    // 生成24小时的专注模式数据
    for (var hour = 0; hour < 24; hour++) {
      patterns.add(
        FocusPattern(
          hourOfDay: hour,
          averageFocusMinutes: _getFocusMinutesForHour(hour, random),
          sessionCount: random.nextInt(5) + 1,
          successRate: _getSuccessRateForHour(hour, random),
        ),
      );
    }

    return patterns;
  }

  double _getFocusMinutesForHour(int hour, Random random) {
    // 模拟不同时间段的专注时长
    if (hour >= 9 && hour <= 11) {
      return random.nextDouble() * 20 + 40; // 上午高专注
    } else if (hour >= 14 && hour <= 16) {
      return random.nextDouble() * 15 + 30; // 下午中等专注
    } else if (hour >= 19 && hour <= 21) {
      return random.nextDouble() * 10 + 25; // 晚上低专注
    } else {
      return random.nextDouble() * 10 + 10; // 其他时间很低专注
    }
  }

  double _getSuccessRateForHour(int hour, Random random) {
    // 模拟不同时间段的成功率
    if (hour >= 9 && hour <= 11) {
      return random.nextDouble() * 0.2 + 0.8; // 上午高成功率
    } else if (hour >= 14 && hour <= 16) {
      return random.nextDouble() * 0.3 + 0.6; // 下午中等成功率
    } else if (hour >= 19 && hour <= 21) {
      return random.nextDouble() * 0.3 + 0.5; // 晚上低成功率
    } else {
      return random.nextDouble() * 0.4 + 0.2; // 其他时间很低成功率
    }
  }

  Future<List<TaskPattern>> _detectTaskPatterns(List<Task> tasks) async {
    // 这里实现任务模式检测逻辑
    // 暂时返回空列表，在analyzeTaskPatterns中实现
    return [];
  }

  Future<List<FocusRecommendation>> _generateFocusRecommendations(
    String userId,
    List<FocusPattern> focusPatterns,
    List<ProductivityTrend> trends,
  ) async {
    final recommendations = <FocusRecommendation>[];
    final now = DateTime.now();

    // 基于专注模式生成建议
    if (focusPatterns.isNotEmpty) {
      final bestPattern = focusPatterns
          .where((pattern) => pattern.successRate > 0.7)
          .fold<FocusPattern?>(
            null,
            (best, current) =>
                best == null || current.successRate > best.successRate
                ? current
                : best,
          );

      if (bestPattern != null) {
        recommendations.add(
          FocusRecommendation(
            type: 'optimal_time',
            message: '您在${bestPattern.hourOfDay}点的专注效果最好',
            recommendedMinutes: bestPattern.averageFocusMinutes.round(),
            bestHours: [bestPattern.hourOfDay],
            confidence: bestPattern.successRate,
            generatedAt: now,
          ),
        );
      }
    }

    return recommendations;
  }

  Future<List<String>> _generateTagsForCategory(TaskCategory category) async {
    switch (category) {
      case TaskCategory.work:
        return ['important', 'planning', 'communication'];
      case TaskCategory.study:
        return ['research', 'review', 'planning'];
      case TaskCategory.health:
        return ['routine', 'important'];
      case TaskCategory.personal:
        return ['routine', 'planning'];
      case TaskCategory.social:
        return ['communication', 'planning'];
      case TaskCategory.other:
        return ['routine'];
    }
  }
}
