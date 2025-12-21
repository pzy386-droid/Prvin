import 'package:flutter/material.dart';
import 'package:prvin/core/theme/theme_exports.dart';
import 'package:prvin/features/ai/domain/entities/analytics_data.dart';
import 'package:prvin/features/ai/presentation/widgets/analytics_overview_cards.dart';
import 'package:prvin/features/ai/presentation/widgets/focus_pattern_chart.dart';
import 'package:prvin/features/ai/presentation/widgets/focus_recommendations_list.dart';
import 'package:prvin/features/ai/presentation/widgets/productivity_trend_chart.dart';
import 'package:prvin/features/ai/presentation/widgets/task_pattern_list.dart';
import 'package:prvin/features/ai/presentation/widgets/time_distribution_chart.dart';

/// AI分析报告页面
/// 提供数据可视化图表，展示时间分配、完成率等统计信息
class AIAnalyticsPage extends StatefulWidget {
  /// 创建AI分析报告页面
  const AIAnalyticsPage({super.key});

  @override
  State<AIAnalyticsPage> createState() => _AIAnalyticsPageState();
}

class _AIAnalyticsPageState extends State<AIAnalyticsPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // 模拟数据 - 实际应用中应该从BLoC或Repository获取
  late AnalyticsData _analyticsData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fadeController = AnimationController(
      duration: AnimationTheme.mediumAnimationDuration,
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _loadAnalyticsData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadAnalyticsData() async {
    // 模拟加载延迟
    await Future<void>.delayed(const Duration(seconds: 1));

    // 创建模拟数据
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    setState(() {
      _analyticsData = AnalyticsData(
        userId: 'user_123',
        period: DateRange(startDate: weekAgo, endDate: now),
        timeDistribution: const {
          '工作': 480, // 8小时
          '学习': 240, // 4小时
          '个人': 120, // 2小时
          '健康': 60, // 1小时
        },
        completionRate: 0.85,
        trends: _generateMockTrends(weekAgo, now),
        focusPatterns: _generateMockFocusPatterns(),
        taskPatterns: _generateMockTaskPatterns(),
        focusRecommendations: _generateMockRecommendations(),
        generatedAt: now,
      );
      _isLoading = false;
    });

    await _fadeController.forward();
  }

  List<ProductivityTrend> _generateMockTrends(DateTime start, DateTime end) {
    final trends = <ProductivityTrend>[];
    for (var i = 0; i < 7; i++) {
      final date = start.add(Duration(days: i));
      trends.add(
        ProductivityTrend(
          date: date,
          completedTasks: 5 + (i * 2) % 8,
          totalWorkMinutes: 300 + (i * 30) % 200,
          focusMinutes: 120 + (i * 20) % 100,
          efficiencyScore: 70 + (i * 5) % 25,
        ),
      );
    }
    return trends;
  }

  List<FocusPattern> _generateMockFocusPatterns() {
    return [
      const FocusPattern(
        hourOfDay: 9,
        averageFocusMinutes: 45.5,
        sessionCount: 12,
        successRate: 0.92,
      ),
      const FocusPattern(
        hourOfDay: 14,
        averageFocusMinutes: 38.2,
        sessionCount: 8,
        successRate: 0.75,
      ),
      const FocusPattern(
        hourOfDay: 19,
        averageFocusMinutes: 42.1,
        sessionCount: 6,
        successRate: 0.83,
      ),
    ];
  }

  List<TaskPattern> _generateMockTaskPatterns() {
    return [
      const TaskPattern(
        patternName: '代码开发',
        similarTasks: ['实现登录功能', '修复bug', '代码重构'],
        suggestedTags: ['开发', '编程', '技术'],
        suggestedCategory: TaskCategory.work,
        averageCompletionMinutes: 120.5,
        confidence: 0.89,
      ),
      const TaskPattern(
        patternName: '学习计划',
        similarTasks: ['阅读技术文档', '观看教程', '练习算法'],
        suggestedTags: ['学习', '提升', '技能'],
        suggestedCategory: TaskCategory.study,
        averageCompletionMinutes: 90.3,
        confidence: 0.76,
      ),
    ];
  }

  List<FocusRecommendation> _generateMockRecommendations() {
    final now = DateTime.now();
    return [
      FocusRecommendation(
        type: '最佳时间段',
        message: '根据您的历史数据，上午9-11点是您专注度最高的时间段',
        recommendedMinutes: 45,
        bestHours: const [9, 10, 11],
        confidence: 0.92,
        generatedAt: now,
      ),
      FocusRecommendation(
        type: '休息建议',
        message: '建议每45分钟专注后休息10-15分钟，这样可以提高整体效率',
        recommendedMinutes: 45,
        bestHours: const [],
        confidence: 0.85,
        generatedAt: now,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryColor.withValues(alpha: 0.1),
              AppTheme.primaryColor.withValues(alpha: 0.05),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              if (_isLoading) _buildLoadingIndicator() else _buildContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      child: Row(
        children: [
          MicroInteractions.createInteractiveContainer(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.all(AppTheme.spacingS),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppTheme.radiusS),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back,
                color: AppTheme.primaryColor,
                size: 24,
              ),
            ),
          ),
          const Spacer(),
          Text(
            'AI智能分析',
            style: ResponsiveTheme.createResponsiveTextStyle(
              context,
              baseFontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          const Spacer(),
          MicroInteractions.createInteractiveContainer(
            onTap: _showSettingsDialog,
            child: Container(
              padding: const EdgeInsets.all(AppTheme.spacingS),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppTheme.radiusS),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.settings,
                color: AppTheme.primaryColor,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
            ),
            const SizedBox(height: AppTheme.spacingL),
            Text(
              '正在分析您的数据...',
              style: ResponsiveTheme.createResponsiveTextStyle(
                context,
                baseFontSize: 16,
                color: AppTheme.primaryColor.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Expanded(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            _buildTabBar(),
            Expanded(child: _buildTabBarView()),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
          color: AppTheme.primaryColor,
        ),
        labelColor: Colors.white,
        unselectedLabelColor: AppTheme.primaryColor,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        tabs: const [
          Tab(text: '概览'),
          Tab(text: '趋势'),
          Tab(text: '建议'),
        ],
      ),
    );
  }

  Widget _buildTabBarView() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildOverviewTab(),
        _buildTrendsTab(),
        _buildRecommendationsTab(),
      ],
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnalyticsOverviewCards(analyticsData: _analyticsData),
          const SizedBox(height: AppTheme.spacingL),
          TimeDistributionChart(
            timeDistribution: _analyticsData.timeDistribution,
          ),
          const SizedBox(height: AppTheme.spacingL),
          FocusPatternChart(focusPatterns: _analyticsData.focusPatterns),
        ],
      ),
    );
  }

  Widget _buildTrendsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProductivityTrendChart(trends: _analyticsData.trends),
          const SizedBox(height: AppTheme.spacingL),
          TaskPatternList(taskPatterns: _analyticsData.taskPatterns),
        ],
      ),
    );
  }

  Widget _buildRecommendationsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FocusRecommendationsList(
            recommendations: _analyticsData.focusRecommendations,
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('分析设置'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('分析周期'),
              subtitle: const Text('最近7天'),
              trailing: const Icon(Icons.edit),
              onTap: () {
                Navigator.of(context).pop();
                // TODO: 实现周期设置
              },
            ),
            ListTile(
              title: const Text('数据导出'),
              subtitle: const Text('导出分析报告'),
              trailing: const Icon(Icons.download),
              onTap: () {
                Navigator.of(context).pop();
                // TODO: 实现数据导出
              },
            ),
            ListTile(
              title: const Text('刷新数据'),
              subtitle: const Text('重新生成分析'),
              trailing: const Icon(Icons.refresh),
              onTap: () {
                Navigator.of(context).pop();
                _refreshAnalytics();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  void _refreshAnalytics() {
    setState(() {
      _isLoading = true;
    });
    _fadeController.reset();
    _loadAnalyticsData();
  }
}
