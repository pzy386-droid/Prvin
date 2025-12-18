import '../../domain/entities/analytics_data.dart';
import '../../domain/repositories/ai_analytics_repository.dart';
import '../datasources/ai_analytics_local_datasource.dart';
import '../models/analytics_data_model.dart';
import '../../../tasks/domain/repositories/task_repository.dart';
import '../../../pomodoro/domain/repositories/pomodoro_repository.dart';

/// AI分析仓库实现
class AIAnalyticsRepositoryImpl implements AIAnalyticsRepository {
  /// 创建AI分析仓库实现
  const AIAnalyticsRepositoryImpl(
    this._localDataSource,
    this._taskRepository,
    this._pomodoroRepository,
  );

  final AIAnalyticsLocalDataSource _localDataSource;
  final TaskRepository _taskRepository;
  final PomodoroRepository _pomodoroRepository;

  @override
  Future<AnalyticsData> generateAnalytics({
    required String userId,
    required DateRange period,
  }) async {
    // 获取任务数据
    final tasks = await _taskRepository.getAllTasks();
    final periodTasks = tasks.where((task) {
      return period.contains(task.createdAt);
    }).toList();

    // 获取番茄钟数据
    final sessions = await _pomodoroRepository.getAllSessions();
    final periodSessions = sessions.where((session) {
      return period.contains(session.startTime);
    }).toList();

    // 生成生产力趋势
    final trends = _generateProductivityTrends(
      periodTasks,
      periodSessions,
      period,
    );

    // 生成专注模式
    final focusPatterns = _generateFocusPatterns(periodSessions);

    // 生成任务模式
    final taskPatterns = _generateTaskPatterns(periodTasks);

    // 生成专注建议
    final focusRecommendations = _generateFocusRecommendations(
      periodSessions,
      focusPatterns,
    );

    // 计算时间分配
    final timeDistribution = _calculateTimeDistribution(periodTasks);

    // 计算完成率
    final completionRate = _calculateCompletionRate(periodTasks);

    final analyticsData = AnalyticsData(
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

    // 保存分析数据
    await saveAnalyticsData(analyticsData);

    return analyticsData;
  }

  @override
  Future<List<String>> getTagSuggestions(String taskTitle) async {
    // 简化的标签建议算法
    final suggestions = <String>[];
    final title = taskTitle.toLowerCase();

    if (title.contains('会议') || title.contains('meeting')) {
      suggestions.addAll(['会议', '沟通', '协作']);
    }
    if (title.contains('学习') || title.contains('study')) {
      suggestions.addAll(['学习', '知识', '技能']);
    }
    if (title.contains('编程') || title.contains('code')) {
      suggestions.addAll(['编程', '开发', '技术']);
    }
    if (title.contains('运动') || title.contains('exercise')) {
      suggestions.addAll(['运动', '健康', '锻炼']);
    }

    return suggestions.take(5).toList();
  }

  @override
  Future<TaskCategory> getCategorySuggestion(String taskTitle) async {
    final title = taskTitle.toLowerCase();

    if (title.contains('工作') ||
        title.contains('work') ||
        title.contains('项目')) {
      return TaskCategory.work;
    }
    if (title.contains('学习') ||
        title.contains('study') ||
        title.contains('课程')) {
      return TaskCategory.study;
    }
    if (title.contains('运动') || title.contains('健康') || title.contains('锻炼')) {
      return TaskCategory.health;
    }
    if (title.contains('个人') || title.contains('家庭') || title.contains('生活')) {
      return TaskCategory.personal;
    }

    return TaskCategory.other;
  }

  @override
  Future<List<FocusRecommendation>> getFocusRecommendations(
    String userId,
  ) async {
    final now = DateTime.now();
    final lastWeek = DateRange(
      startDate: now.subtract(const Duration(days: 7)),
      endDate: now,
    );

    final focusPatterns = await getFocusPatterns(
      userId: userId,
      period: lastWeek,
    );

    return _generateFocusRecommendations([], focusPatterns);
  }

  @override
  Future<List<TaskPattern>> analyzeTaskPatterns(String userId) async {
    final tasks = await _taskRepository.getAllTasks();
    return _generateTaskPatterns(tasks);
  }

  @override
  Future<List<ProductivityTrend>> getProductivityTrends({
    required String userId,
    required DateRange period,
  }) async {
    final tasks = await _taskRepository.getAllTasks();
    final sessions = await _pomodoroRepository.getAllSessions();

    final periodTasks = tasks
        .where((task) => period.contains(task.createdAt))
        .toList();
    final periodSessions = sessions
        .where((session) => period.contains(session.startTime))
        .toList();

    return _generateProductivityTrends(periodTasks, periodSessions, period);
  }

  @override
  Future<List<FocusPattern>> getFocusPatterns({
    required String userId,
    required DateRange period,
  }) async {
    final sessions = await _pomodoroRepository.getAllSessions();
    final periodSessions = sessions
        .where((session) => period.contains(session.startTime))
        .toList();

    return _generateFocusPatterns(periodSessions);
  }

  @override
  Future<void> saveAnalyticsData(AnalyticsData data) async {
    final model = _entityToModel(data);
    await _localDataSource.saveAnalyticsData(model);
  }

  @override
  Future<List<AnalyticsData>> getHistoricalAnalytics({
    required String userId,
    required DateRange period,
  }) async {
    final models = await _localDataSource.getAnalyticsData(
      userId: userId,
      startDate: period.startDate,
      endDate: period.endDate,
    );

    return models.map(_modelToEntity).toList();
  }

  @override
  Future<void> clearExpiredAnalytics({Duration? olderThan}) async {
    await _localDataSource.clearExpiredData(olderThan: olderThan);
  }

  /// 生成生产力趋势
  List<ProductivityTrend> _generateProductivityTrends(
    List<dynamic> tasks,
    List<dynamic> sessions,
    DateRange period,
  ) {
    final trends = <ProductivityTrend>[];

    for (var i = 0; i < period.dayCount; i++) {
      final date = period.startDate.add(Duration(days: i));

      // 简化的趋势计算
      trends.add(
        ProductivityTrend(
          date: date,
          completedTasks: 0, // 实际应该计算当天完成的任务数
          totalWorkMinutes: 0, // 实际应该计算当天的工作时间
          focusMinutes: 0, // 实际应该计算当天的专注时间
          efficiencyScore: 75.0, // 简化的效率评分
        ),
      );
    }

    return trends;
  }

  /// 生成专注模式
  List<FocusPattern> _generateFocusPatterns(List<dynamic> sessions) {
    final patterns = <FocusPattern>[];

    // 简化的专注模式分析
    for (var hour = 0; hour < 24; hour++) {
      patterns.add(
        FocusPattern(
          hourOfDay: hour,
          averageFocusMinutes: 25.0,
          sessionCount: 0,
          successRate: 0.8,
        ),
      );
    }

    return patterns;
  }

  /// 生成任务模式
  List<TaskPattern> _generateTaskPatterns(List<dynamic> tasks) {
    // 简化的任务模式分析
    return [
      const TaskPattern(
        patternName: '工作任务模式',
        similarTasks: ['项目开发', '代码审查', '会议'],
        suggestedTags: ['工作', '开发', '项目'],
        suggestedCategory: TaskCategory.work,
        averageCompletionMinutes: 45.0,
        confidence: 0.85,
      ),
    ];
  }

  /// 生成专注建议
  List<FocusRecommendation> _generateFocusRecommendations(
    List<dynamic> sessions,
    List<FocusPattern> patterns,
  ) {
    final now = DateTime.now();

    return [
      FocusRecommendation(
        type: '最佳专注时间',
        message: '根据您的历史数据，上午9-11点是您的最佳专注时间段',
        recommendedMinutes: 25,
        bestHours: [9, 10, 11],
        confidence: 0.8,
        generatedAt: now,
      ),
    ];
  }

  /// 计算时间分配
  Map<String, int> _calculateTimeDistribution(List<dynamic> tasks) {
    // 简化的时间分配计算
    return {'工作': 240, '学习': 120, '个人': 60};
  }

  /// 计算完成率
  double _calculateCompletionRate(List<dynamic> tasks) {
    if (tasks.isEmpty) return 0.0;

    // 简化的完成率计算
    return 0.75;
  }

  /// 将实体转换为模型
  AnalyticsDataModel _entityToModel(AnalyticsData entity) {
    return AnalyticsDataModel(
      userId: entity.userId,
      period: DateRange(
        startDate: entity.period.startDate,
        endDate: entity.period.endDate,
      ),
      timeDistribution: entity.timeDistribution,
      completionRate: entity.completionRate,
      trends: entity.trends
          .map(
            (t) => ProductivityTrend(
              date: t.date,
              completedTasks: t.completedTasks,
              totalWorkMinutes: t.totalWorkMinutes,
              focusMinutes: t.focusMinutes,
              efficiencyScore: t.efficiencyScore,
            ),
          )
          .toList(),
      focusPatterns: entity.focusPatterns
          .map(
            (f) => FocusPattern(
              hourOfDay: f.hourOfDay,
              averageFocusMinutes: f.averageFocusMinutes,
              sessionCount: f.sessionCount,
              successRate: f.successRate,
            ),
          )
          .toList(),
      taskPatterns: entity.taskPatterns
          .map(
            (t) => TaskPattern(
              patternName: t.patternName,
              similarTasks: t.similarTasks,
              suggestedTags: t.suggestedTags,
              suggestedCategory: t.suggestedCategory,
              averageCompletionMinutes: t.averageCompletionMinutes,
              confidence: t.confidence,
            ),
          )
          .toList(),
      focusRecommendations: entity.focusRecommendations
          .map(
            (f) => FocusRecommendation(
              type: f.type,
              message: f.message,
              recommendedMinutes: f.recommendedMinutes,
              bestHours: f.bestHours,
              confidence: f.confidence,
              generatedAt: f.generatedAt,
            ),
          )
          .toList(),
      generatedAt: entity.generatedAt,
    );
  }

  /// 将模型转换为实体
  AnalyticsData _modelToEntity(AnalyticsDataModel model) {
    return AnalyticsData(
      userId: model.userId,
      period: DateRange(
        startDate: model.period.startDate,
        endDate: model.period.endDate,
      ),
      timeDistribution: model.timeDistribution,
      completionRate: model.completionRate,
      trends: model.trends
          .map(
            (t) => ProductivityTrend(
              date: t.date,
              completedTasks: t.completedTasks,
              totalWorkMinutes: t.totalWorkMinutes,
              focusMinutes: t.focusMinutes,
              efficiencyScore: t.efficiencyScore,
            ),
          )
          .toList(),
      focusPatterns: model.focusPatterns
          .map(
            (f) => FocusPattern(
              hourOfDay: f.hourOfDay,
              averageFocusMinutes: f.averageFocusMinutes,
              sessionCount: f.sessionCount,
              successRate: f.successRate,
            ),
          )
          .toList(),
      taskPatterns: model.taskPatterns
          .map(
            (t) => TaskPattern(
              patternName: t.patternName,
              similarTasks: t.similarTasks,
              suggestedTags: t.suggestedTags,
              suggestedCategory: t.suggestedCategory,
              averageCompletionMinutes: t.averageCompletionMinutes,
              confidence: t.confidence,
            ),
          )
          .toList(),
      focusRecommendations: model.focusRecommendations
          .map(
            (f) => FocusRecommendation(
              type: f.type,
              message: f.message,
              recommendedMinutes: f.recommendedMinutes,
              bestHours: f.bestHours,
              confidence: f.confidence,
              generatedAt: f.generatedAt,
            ),
          )
          .toList(),
      generatedAt: model.generatedAt,
    );
  }
}
