import 'package:flutter/material.dart';
import 'package:prvin/core/theme/theme_exports.dart';
import 'package:prvin/core/widgets/widgets_exports.dart';
import 'package:prvin/features/pomodoro/models/pomodoro_session.dart';
import 'package:prvin/features/pomodoro/models/pomodoro_stats.dart';
import 'package:prvin/features/pomodoro/widgets/achievement_card.dart';
import 'package:prvin/features/pomodoro/widgets/stats_chart.dart';

/// 番茄钟统计页面
class PomodoroStatsPage extends StatefulWidget {
  /// 创建统计页面
  const PomodoroStatsPage({super.key});

  @override
  State<PomodoroStatsPage> createState() => _PomodoroStatsPageState();
}

class _PomodoroStatsPageState extends State<PomodoroStatsPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // 模拟数据
  late List<PomodoroSession> _sessions;
  late PomodoroStats _stats;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 3, vsync: this);
    _fadeController = AnimationController(
      duration: AnimationTheme.mediumAnimationDuration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: AnimationTheme.smoothCurve,
      ),
    );

    _initializeMockData();
    _fadeController.forward();
  }

  void _initializeMockData() {
    final now = DateTime.now();
    _sessions = [
      // 今天的会话
      PomodoroSession(
        id: '1',
        startTime: now.subtract(const Duration(hours: 2)),
        endTime: now.subtract(const Duration(hours: 1, minutes: 35)),
        plannedDuration: const Duration(minutes: 25),
        actualDuration: const Duration(minutes: 25),
        type: SessionType.work,
        completed: true,
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      PomodoroSession(
        id: '2',
        startTime: now.subtract(const Duration(hours: 1, minutes: 30)),
        endTime: now.subtract(const Duration(hours: 1, minutes: 25)),
        plannedDuration: const Duration(minutes: 5),
        actualDuration: const Duration(minutes: 5),
        type: SessionType.shortBreak,
        completed: true,
        createdAt: now.subtract(const Duration(hours: 1, minutes: 30)),
      ),
      // 昨天的会话
      PomodoroSession(
        id: '3',
        startTime: now.subtract(const Duration(days: 1, hours: 3)),
        endTime: now.subtract(const Duration(days: 1, hours: 2, minutes: 35)),
        plannedDuration: const Duration(minutes: 25),
        actualDuration: const Duration(minutes: 25),
        type: SessionType.work,
        completed: true,
        createdAt: now.subtract(const Duration(days: 1, hours: 3)),
      ),
      // 本周的会话
      PomodoroSession(
        id: '4',
        startTime: now.subtract(const Duration(days: 3, hours: 2)),
        endTime: now.subtract(const Duration(days: 3, hours: 1, minutes: 35)),
        plannedDuration: const Duration(minutes: 25),
        actualDuration: const Duration(minutes: 22),
        type: SessionType.work,
        createdAt: now.subtract(const Duration(days: 3, hours: 2)),
      ),
    ];

    _stats = PomodoroStats.fromSessions(_sessions);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            _buildStatsOverview(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildTodayTab(),
                  _buildWeekTab(),
                  _buildAchievementsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        '专注统计',
        style: ResponsiveTheme.createResponsiveTextStyle(
          context,
          baseFontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      backgroundColor: AppTheme.primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      actions: [
        MicroInteractions.createInteractiveContainer(
          onTap: _showStatsSettings,
          child: Container(
            margin: const EdgeInsets.only(right: AppTheme.spacingM),
            padding: const EdgeInsets.all(AppTheme.spacingS),
            child: const Icon(Icons.settings),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsOverview() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryColor.withValues(alpha: 0.8),
          ],
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: '今日专注',
                  value: '${_stats.todaySessions}',
                  subtitle: '个番茄钟',
                  icon: Icons.timer,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: _buildStatCard(
                  title: '连续天数',
                  value: '${_stats.streakDays}',
                  subtitle: '天',
                  icon: Icons.local_fire_department,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingM),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: '总专注时间',
                  value: '${_stats.totalFocusTime.inHours}',
                  subtitle: '小时',
                  icon: Icons.access_time,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: _buildStatCard(
                  title: '完成率',
                  value: '${(_stats.completionRate * 100).toInt()}%',
                  subtitle: '效率',
                  icon: Icons.trending_up,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return AppCard(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: AppTheme.spacingS),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingS),
          Text(
            value,
            style: ResponsiveTheme.createResponsiveTextStyle(
              context,
              baseFontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return ColoredBox(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: AppTheme.primaryColor,
        unselectedLabelColor: Colors.grey,
        indicatorColor: AppTheme.primaryColor,
        tabs: const [
          Tab(text: '今日', icon: Icon(Icons.today, size: 20)),
          Tab(text: '本周', icon: Icon(Icons.date_range, size: 20)),
          Tab(text: '成就', icon: Icon(Icons.emoji_events, size: 20)),
        ],
      ),
    );
  }

  Widget _buildTodayTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 今日进度
          _buildProgressSection(),
          const SizedBox(height: AppTheme.spacingL),

          // 今日会话列表
          _buildTodaySessionsList(),
        ],
      ),
    );
  }

  Widget _buildProgressSection() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '今日目标进度',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: AppTheme.spacingM),

          // 进度条
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_stats.todaySessions} / ${_stats.dailyGoal} 个番茄钟',
                    style: const TextStyle(fontSize: 14),
                  ),
                  Text(
                    '${(_stats.todayProgress * 100).toInt()}%',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingS),
              LinearProgressIndicator(
                value: _stats.todayProgress,
                backgroundColor: Colors.grey.shade200,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppTheme.primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTodaySessionsList() {
    final todaySessions = _sessions.where((session) {
      final today = DateTime.now();
      final sessionDate = session.startTime;
      return sessionDate.year == today.year &&
          sessionDate.month == today.month &&
          sessionDate.day == today.day;
    }).toList();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '今日会话记录',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: AppTheme.spacingM),

          if (todaySessions.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(AppTheme.spacingL),
                child: Text(
                  '今天还没有专注记录\n开始你的第一个番茄钟吧！',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            ...todaySessions.map(_buildSessionItem),
        ],
      ),
    );
  }

  Widget _buildSessionItem(PomodoroSession session) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingS),
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: Color(session.type.colorValue).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        border: Border.all(
          color: Color(session.type.colorValue).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Color(session.type.colorValue),
              shape: BoxShape.circle,
            ),
            child: Icon(
              session.isWorkSession ? Icons.work : Icons.coffee,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: AppTheme.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.type.displayName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '${session.actualDuration.inMinutes} 分钟',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          if (session.completed)
            const Icon(Icons.check_circle, color: AppTheme.successColor, size: 20)
          else
            const Icon(Icons.cancel, color: AppTheme.errorColor, size: 20),
        ],
      ),
    );
  }

  Widget _buildWeekTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      child: Column(
        children: [
          // 本周统计图表
          StatsChart(sessions: _sessions),
          const SizedBox(height: AppTheme.spacingL),

          // 本周总结
          _buildWeekSummary(),
        ],
      ),
    );
  }

  Widget _buildWeekSummary() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '本周总结',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: AppTheme.spacingM),

          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  '总会话',
                  '${_stats.weekSessions}',
                  Icons.timer,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  '专注时间',
                  '${_stats.totalFocusTime.inHours}h',
                  Icons.access_time,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  '平均时长',
                  '${_stats.averageSessionLength.inMinutes}min',
                  Icons.trending_up,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primaryColor, size: 24),
        const SizedBox(height: AppTheme.spacingS),
        Text(
          value,
          style: ResponsiveTheme.createResponsiveTextStyle(
            context,
            baseFontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildAchievementsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      child: Column(
        children: [
          AchievementCard(
            title: '专注新手',
            description: '完成第一个番茄钟',
            icon: Icons.star,
            isUnlocked: _stats.completedSessions > 0,
            progress: _stats.completedSessions > 0 ? 1.0 : 0.0,
          ),
          const SizedBox(height: AppTheme.spacingM),
          AchievementCard(
            title: '坚持不懈',
            description: '连续专注7天',
            icon: Icons.local_fire_department,
            isUnlocked: _stats.streakDays >= 7,
            progress: (_stats.streakDays / 7).clamp(0.0, 1.0),
          ),
          const SizedBox(height: AppTheme.spacingM),
          AchievementCard(
            title: '专注大师',
            description: '累计专注100小时',
            icon: Icons.emoji_events,
            isUnlocked: _stats.totalFocusTime.inHours >= 100,
            progress: (_stats.totalFocusTime.inHours / 100).clamp(0.0, 1.0),
          ),
        ],
      ),
    );
  }

  void _showStatsSettings() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('统计设置'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('每日目标'),
              subtitle: Text('${_stats.dailyGoal} 个番茄钟'),
              trailing: const Icon(Icons.edit),
              onTap: () {
                Navigator.of(context).pop();
                // TODO: 实现目标设置
              },
            ),
            ListTile(
              title: const Text('导出数据'),
              subtitle: const Text('导出统计数据'),
              trailing: const Icon(Icons.download),
              onTap: () {
                Navigator.of(context).pop();
                // TODO: 实现数据导出
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
}
