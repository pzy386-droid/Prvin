import 'package:flutter/material.dart';
import 'package:prvin/core/theme/theme_exports.dart';
import 'package:prvin/core/widgets/widgets_exports.dart';
import 'package:prvin/features/calendar/widgets/calendar_exports.dart';

/// 日历演示页面
/// 展示日历界面组件的功能
class CalendarDemoPage extends StatefulWidget {
  const CalendarDemoPage({super.key});

  @override
  State<CalendarDemoPage> createState() => _CalendarDemoPageState();
}

class _CalendarDemoPageState extends State<CalendarDemoPage> {
  DateTime _selectedDate = DateTime.now();
  CalendarViewType _currentViewType = CalendarViewType.month;

  // 示例任务数据
  late List<CalendarTask> _tasks;

  @override
  void initState() {
    super.initState();
    _generateSampleTasks();
  }

  void _generateSampleTasks() {
    final now = DateTime.now();
    _tasks = [
      // 今天的任务
      CalendarTask(
        id: '1',
        title: '团队会议',
        date: now,
        description: '讨论项目进度和下周计划',
        category: 'work',
        priority: 'high',
        startTime: const TimeOfDay(hour: 9, minute: 0),
        endTime: const TimeOfDay(hour: 10, minute: 30),
      ),
      CalendarTask(
        id: '2',
        title: '代码审查',
        date: now,
        description: '审查UI组件库的代码',
        category: 'work',
        priority: 'medium',
        startTime: const TimeOfDay(hour: 14, minute: 0),
        endTime: const TimeOfDay(hour: 15, minute: 0),
      ),
      CalendarTask(
        id: '3',
        title: '健身',
        date: now,
        description: '晚上去健身房锻炼',
        category: 'health',
        priority: 'low',
        startTime: const TimeOfDay(hour: 19, minute: 0),
        endTime: const TimeOfDay(hour: 20, minute: 30),
        isCompleted: true,
      ),

      // 明天的任务
      CalendarTask(
        id: '4',
        title: '产品设计评审',
        date: now.add(const Duration(days: 1)),
        description: '评审新功能的设计方案',
        category: 'work',
        priority: 'high',
        startTime: const TimeOfDay(hour: 10, minute: 0),
        endTime: const TimeOfDay(hour: 11, minute: 30),
      ),
      CalendarTask(
        id: '5',
        title: '学习Flutter',
        date: now.add(const Duration(days: 1)),
        description: '学习Flutter高级动画技巧',
        category: 'learning',
        priority: 'medium',
        startTime: const TimeOfDay(hour: 20, minute: 0),
        endTime: const TimeOfDay(hour: 21, minute: 30),
      ),

      // 后天的任务
      CalendarTask(
        id: '6',
        title: '朋友聚餐',
        date: now.add(const Duration(days: 2)),
        description: '和大学同学聚餐',
        category: 'social',
        priority: 'low',
        startTime: const TimeOfDay(hour: 18, minute: 30),
        endTime: const TimeOfDay(hour: 21, minute: 0),
      ),

      // 本周其他任务
      CalendarTask(
        id: '7',
        title: '项目演示',
        date: now.add(const Duration(days: 3)),
        description: '向客户演示项目进展',
        category: 'work',
        priority: 'high',
        startTime: const TimeOfDay(hour: 15, minute: 0),
        endTime: const TimeOfDay(hour: 16, minute: 30),
      ),
      CalendarTask(
        id: '8',
        title: '读书',
        date: now.add(const Duration(days: 4)),
        description: '阅读《Flutter实战》',
        category: 'learning',
        priority: 'low',
        startTime: const TimeOfDay(hour: 21, minute: 0),
        endTime: const TimeOfDay(hour: 22, minute: 0),
      ),

      // 下周的任务
      CalendarTask(
        id: '9',
        title: '医院体检',
        date: now.add(const Duration(days: 7)),
        description: '年度健康体检',
        category: 'health',
        priority: 'medium',
        startTime: const TimeOfDay(hour: 8, minute: 0),
        endTime: const TimeOfDay(hour: 11, minute: 0),
      ),
      CalendarTask(
        id: '10',
        title: '技术分享',
        date: now.add(const Duration(days: 8)),
        description: '分享Flutter开发经验',
        category: 'work',
        priority: 'medium',
        startTime: const TimeOfDay(hour: 14, minute: 0),
        endTime: const TimeOfDay(hour: 15, minute: 30),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('日历界面演示'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () {
              setState(() {
                _selectedDate = DateTime.now();
              });
            },
            tooltip: '回到今天',
          ),
        ],
      ),
      body: Column(
        children: [
          // 统计信息卡片
          _buildStatsCard(),

          // 日历组件
          Expanded(
            child: CalendarView(
              initialDate: _selectedDate,
              initialViewType: _currentViewType,
              tasks: _tasks,
              onDateTap: _onDateTap,
              onViewTypeChanged: _onViewTypeChanged,
            ),
          ),
        ],
      ),
      floatingActionButton: AppFloatingActionButton(
        onPressed: _showAddTaskDialog,
        icon: Icons.add,
        heroTag: 'add_task',
      ),
    );
  }

  Widget _buildStatsCard() {
    final today = DateTime.now();
    final todayTasks = _tasks.where((task) => task.isOnDate(today)).toList();
    final completedTasks = todayTasks.where((task) => task.isCompleted).length;
    final totalTasks = _tasks.length;
    final completedAllTasks = _tasks.where((task) => task.isCompleted).length;

    return AppCard(
      margin: const EdgeInsets.all(AppTheme.spacingM),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              '今日任务',
              '${todayTasks.length}',
              Icons.today,
              AppTheme.primaryColor,
            ),
          ),
          Container(width: 1, height: 40, color: Colors.grey.shade300),
          Expanded(
            child: _buildStatItem(
              '已完成',
              '$completedTasks/${todayTasks.length}',
              Icons.check_circle,
              AppTheme.successColor,
            ),
          ),
          Container(width: 1, height: 40, color: Colors.grey.shade300),
          Expanded(
            child: _buildStatItem(
              '总进度',
              '$completedAllTasks/$totalTasks',
              Icons.trending_up,
              AppTheme.infoColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  void _onDateTap(DateTime date) {
    setState(() {
      _selectedDate = date;
    });

    final dateTasks = _tasks.where((task) => task.isOnDate(date)).toList();

    _showTasksBottomSheet(date, dateTasks);
  }

  void _onViewTypeChanged(CalendarViewType viewType) {
    setState(() {
      _currentViewType = viewType;
    });

    _showSnackBar('切换到${_getViewTypeName(viewType)}视图');
  }

  String _getViewTypeName(CalendarViewType viewType) {
    switch (viewType) {
      case CalendarViewType.month:
        return '月';
      case CalendarViewType.week:
        return '周';
      case CalendarViewType.day:
        return '日';
    }
  }

  void _showTasksBottomSheet(DateTime date, List<CalendarTask> tasks) {
    DialogUtils.showBottomSheet<void>(
      context,
      isScrollControlled: true,
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            Row(
              children: [
                const Icon(Icons.calendar_today, color: AppTheme.primaryColor),
                const SizedBox(width: AppTheme.spacingS),
                Text(
                  '${date.month}月${date.day}日的任务',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),

            const SizedBox(height: AppTheme.spacingM),

            // 任务列表
            if (tasks.isEmpty)
              Center(
                child: Column(
                  children: [
                    SimpleLottie.empty(size: 80),
                    const SizedBox(height: AppTheme.spacingM),
                    Text(
                      '这一天还没有任务',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: AppTheme.spacingM),
                    AppButton(
                      text: '添加任务',
                      onPressed: () {
                        Navigator.of(context).pop();
                        _showAddTaskDialog();
                      },
                      icon: Icons.add,
                    ),
                  ],
                ),
              )
            else
              ...tasks.map(
                (task) => Padding(
                  padding: const EdgeInsets.only(bottom: AppTheme.spacingM),
                  child: TaskCard(
                    title: task.title,
                    description: task.description,
                    category: task.category,
                    priority: task.priority,
                    dueDate: task.date,
                    isCompleted: task.isCompleted,
                    tags: task.category != null ? [task.category!] : [],
                    onTap: () => _showTaskDetails(task),
                    onToggleComplete: () => _toggleTaskComplete(task),
                  ),
                ),
              ),

            // 底部间距
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
          ],
        ),
      ),
    );
  }

  void _showAddTaskDialog() {
    DialogUtils.showInfo(
      context,
      title: '添加任务',
      message: '这里将显示任务创建表单。\n\n在实际应用中，这里会有完整的任务创建界面，包括标题、描述、时间、分类等字段。',
      buttonText: '知道了',
    );
  }

  void _showTaskDetails(CalendarTask task) {
    Navigator.of(context).pop(); // 关闭底部弹窗

    DialogUtils.showInfo(
      context,
      title: task.title,
      message:
          '任务详情：\n\n'
          '描述：${task.description ?? '无'}\n'
          '分类：${task.category ?? '无'}\n'
          '优先级：${task.priority ?? '无'}\n'
          '状态：${task.isCompleted ? '已完成' : '未完成'}\n'
          '时间：${task.startTime != null ? '${task.startTime!.format(context)} - ${task.endTime?.format(context) ?? ''}' : '全天'}',
      buttonText: '关闭',
    );
  }

  void _toggleTaskComplete(CalendarTask task) {
    setState(() {
      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _tasks[index] = CalendarTask(
          id: task.id,
          title: task.title,
          date: task.date,
          description: task.description,
          category: task.category,
          priority: task.priority,
          isCompleted: !task.isCompleted,
          startTime: task.startTime,
          endTime: task.endTime,
        );
      }
    });

    _showSnackBar(task.isCompleted ? '任务已标记为未完成' : '任务已完成！');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
        ),
      ),
    );
  }
}
