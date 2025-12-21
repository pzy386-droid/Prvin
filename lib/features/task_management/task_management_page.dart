import 'package:flutter/material.dart';
import 'package:prvin/core/theme/theme_exports.dart';
import 'package:prvin/features/task_management/widgets/task_form.dart';
import 'package:prvin/features/task_management/widgets/task_list.dart';

/// 任务管理页面
/// 提供任务的创建、编辑、删除和列表显示功能
class TaskManagementPage extends StatefulWidget {
  /// 创建任务管理页面
  const TaskManagementPage({super.key});

  @override
  State<TaskManagementPage> createState() => _TaskManagementPageState();
}

class _TaskManagementPageState extends State<TaskManagementPage>
    with TickerProviderStateMixin {
  final List<TaskItem> _tasks = [];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late AnimationController _fabController;
  late Animation<double> _fabAnimation;

  bool _showCompletedTasks = true;
  String _selectedFilter = 'all'; // all, today, week, month
  String _selectedSort = 'date'; // date, priority, category

  @override
  void initState() {
    super.initState();

    _fabController = AnimationController(
      duration: AnimationTheme.mediumAnimationDuration,
      vsync: this,
    );

    _fabAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _fabController,
        curve: AnimationTheme.smoothCurve,
      ),
    );

    _initializeSampleTasks();
    _fabController.forward();
  }

  void _initializeSampleTasks() {
    // 添加一些示例任务
    final now = DateTime.now();
    _tasks.addAll([
      TaskItem(
        id: '1',
        title: '完成项目报告',
        description: '整理本月项目进度，准备汇报材料',
        date: now,
        startTime: const TimeOfDay(hour: 9, minute: 0),
        endTime: const TimeOfDay(hour: 11, minute: 0),
        category: 'work',
        priority: 'high',
        tags: ['项目', '报告', '重要'],
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      TaskItem(
        id: '2',
        title: '健身锻炼',
        description: '跑步30分钟，力量训练',
        date: now,
        startTime: const TimeOfDay(hour: 18, minute: 0),
        endTime: const TimeOfDay(hour: 19, minute: 30),
        category: 'health',
        priority: 'medium',
        tags: ['健身', '运动'],
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      TaskItem(
        id: '3',
        title: '学习Flutter',
        description: '完成动画章节的学习',
        date: now.add(const Duration(days: 1)),
        startTime: const TimeOfDay(hour: 20, minute: 0),
        endTime: const TimeOfDay(hour: 22, minute: 0),
        category: 'study',
        priority: 'medium',
        tags: ['学习', 'Flutter', '编程'],
        createdAt: now.subtract(const Duration(hours: 5)),
      ),
      TaskItem(
        id: '4',
        title: '团队会议',
        description: '讨论下周工作安排',
        date: now.add(const Duration(days: 2)),
        startTime: const TimeOfDay(hour: 14, minute: 0),
        endTime: const TimeOfDay(hour: 15, minute: 30),
        category: 'meeting',
        priority: 'high',
        tags: ['会议', '团队'],
        isCompleted: true,
        createdAt: now.subtract(const Duration(days: 3)),
      ),
    ]);
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: TaskList(
              tasks: _getFilteredTasks(),
              onTaskTap: _handleTaskTap,
              onTaskEdit: _handleTaskEdit,
              onTaskDelete: _handleTaskDelete,
              onTaskToggle: _handleTaskToggle,
              onTaskReorder: _handleTaskReorder,
              showCompletedTasks: _showCompletedTasks,
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        '任务管理',
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
        // 搜索按钮
        MicroInteractions.createInteractiveContainer(
          onTap: _showSearchDialog,
          child: Container(
            margin: const EdgeInsets.only(right: AppTheme.spacingS),
            padding: const EdgeInsets.all(AppTheme.spacingS),
            child: const Icon(Icons.search),
          ),
        ),

        // 更多选项
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: _handleMenuAction,
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'toggle_completed',
              child: Row(
                children: [
                  Icon(
                    _showCompletedTasks
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  const SizedBox(width: 8),
                  Text(_showCompletedTasks ? '隐藏已完成' : '显示已完成'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'export',
              child: Row(
                children: [
                  Icon(Icons.download),
                  SizedBox(width: 8),
                  Text('导出任务'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'settings',
              child: Row(
                children: [
                  Icon(Icons.settings),
                  SizedBox(width: 8),
                  Text('设置'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 过滤器选项
          Row(
            children: [
              Text(
                '筛选：',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: AppTheme.spacingS),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('全部', 'all'),
                      _buildFilterChip('今天', 'today'),
                      _buildFilterChip('本周', 'week'),
                      _buildFilterChip('本月', 'month'),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppTheme.spacingS),

          // 排序选项
          Row(
            children: [
              Text(
                '排序：',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: AppTheme.spacingS),
              Expanded(
                child: Row(
                  children: [
                    _buildSortChip('日期', 'date'),
                    _buildSortChip('优先级', 'priority'),
                    _buildSortChip('分类', 'category'),
                  ],
                ),
              ),

              // 任务统计
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingM,
                  vertical: AppTheme.spacingXS,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusL),
                ),
                child: Text(
                  '${_getFilteredTasks().length} 个任务',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;

    return Padding(
      padding: const EdgeInsets.only(right: AppTheme.spacingS),
      child: MicroInteractions.createInteractiveContainer(
        onTap: () => setState(() => _selectedFilter = value),
        child: AnimatedContainer(
          duration: AnimationTheme.shortAnimationDuration,
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingM,
            vertical: AppTheme.spacingXS,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.primaryColor
                : AppTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppTheme.radiusL),
            border: isSelected
                ? null
                : Border.all(
                    color: AppTheme.primaryColor.withValues(alpha: 0.3),
                  ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : AppTheme.primaryColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSortChip(String label, String value) {
    final isSelected = _selectedSort == value;

    return Padding(
      padding: const EdgeInsets.only(right: AppTheme.spacingS),
      child: MicroInteractions.createInteractiveContainer(
        onTap: () => setState(() => _selectedSort = value),
        child: AnimatedContainer(
          duration: AnimationTheme.shortAnimationDuration,
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingS,
            vertical: 2,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.primaryColor.withValues(alpha: 0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppTheme.radiusS),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected ? AppTheme.primaryColor : Colors.grey.shade600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return ScaleTransition(
      scale: _fabAnimation,
      child: FloatingActionButton.extended(
        onPressed: _showCreateTaskForm,
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('创建任务'),
      ),
    );
  }

  List<TaskItem> _getFilteredTasks() {
    var filtered = List<TaskItem>.from(_tasks);

    // 应用过滤器
    switch (_selectedFilter) {
      case 'today':
        final today = DateTime.now();
        filtered = filtered.where((task) {
          return task.date.year == today.year &&
              task.date.month == today.month &&
              task.date.day == today.day;
        }).toList();
      case 'week':
        final now = DateTime.now();
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        final weekEnd = weekStart.add(const Duration(days: 6));
        filtered = filtered.where((task) {
          return task.date.isAfter(
                weekStart.subtract(const Duration(days: 1)),
              ) &&
              task.date.isBefore(weekEnd.add(const Duration(days: 1)));
        }).toList();
      case 'month':
        final now = DateTime.now();
        filtered = filtered.where((task) {
          return task.date.year == now.year && task.date.month == now.month;
        }).toList();
    }

    // 应用排序
    switch (_selectedSort) {
      case 'date':
        filtered.sort((a, b) => a.date.compareTo(b.date));
      case 'priority':
        filtered.sort((a, b) {
          final priorityOrder = {'high': 0, 'medium': 1, 'low': 2};
          final aPriority = priorityOrder[a.priority?.toLowerCase()] ?? 3;
          final bPriority = priorityOrder[b.priority?.toLowerCase()] ?? 3;
          return aPriority.compareTo(bPriority);
        });
      case 'category':
        filtered.sort((a, b) {
          final aCategory = a.category ?? '';
          final bCategory = b.category ?? '';
          return aCategory.compareTo(bCategory);
        });
    }

    return filtered;
  }

  void _showCreateTaskForm() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TaskForm(
        onSave: _handleTaskCreate,
        onCancel: () => Navigator.of(context).pop(),
      ),
    );
  }

  void _showEditTaskForm(TaskItem task) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TaskForm(
        initialTask: task.toFormData(),
        onSave: (formData) => _handleTaskUpdate(task.id, formData),
        onCancel: () => Navigator.of(context).pop(),
      ),
    );
  }

  void _showSearchDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('搜索任务'),
        content: const TextField(
          decoration: InputDecoration(
            hintText: '输入关键词搜索任务...',
            prefixIcon: Icon(Icons.search),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('搜索'),
          ),
        ],
      ),
    );
  }

  void _handleTaskCreate(TaskFormData formData) {
    final newTask = TaskItem.fromFormData(formData);
    setState(() {
      _tasks.add(newTask);
    });
    Navigator.of(context).pop();

    // 显示成功提示
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('任务 "${newTask.title}" 创建成功'),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  void _handleTaskUpdate(String taskId, TaskFormData formData) {
    final index = _tasks.indexWhere((task) => task.id == taskId);
    if (index != -1) {
      setState(() {
        _tasks[index] = TaskItem.fromFormData(formData.copyWith(id: taskId));
      });
      Navigator.of(context).pop();

      // 显示成功提示
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('任务 "${formData.title}" 更新成功'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    }
  }

  void _handleTaskTap(TaskItem task) {
    // 显示任务详情
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(task.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.description != null) ...[
              Text('描述：${task.description}'),
              const SizedBox(height: 8),
            ],
            Text('日期：${task.date.year}年${task.date.month}月${task.date.day}日'),
            if (task.startTime != null || task.endTime != null) ...[
              const SizedBox(height: 4),
              Text('时间：${_getTaskTimeText(task)}'),
            ],
            if (task.category != null) ...[
              const SizedBox(height: 4),
              Text('分类：${task.category}'),
            ],
            if (task.priority != null) ...[
              const SizedBox(height: 4),
              Text('优先级：${task.priority}'),
            ],
            if (task.tags.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text('标签：${task.tags.join(', ')}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _handleTaskEdit(task);
            },
            child: const Text('编辑'),
          ),
        ],
      ),
    );
  }

  void _handleTaskEdit(TaskItem task) {
    _showEditTaskForm(task);
  }

  void _handleTaskDelete(TaskItem task) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除任务'),
        content: Text('确定要删除任务 "${task.title}" 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _tasks.removeWhere((t) => t.id == task.id);
              });
              Navigator.of(context).pop();

              // 显示删除提示
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('任务 "${task.title}" 已删除'),
                  backgroundColor: AppTheme.errorColor,
                  action: SnackBarAction(
                    label: '撤销',
                    textColor: Colors.white,
                    onPressed: () {
                      setState(() {
                        _tasks.add(task);
                      });
                    },
                  ),
                ),
              );
            },
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _handleTaskToggle(TaskItem task, bool completed) {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      setState(() {
        _tasks[index] = task.copyWith(
          isCompleted: completed,
          updatedAt: DateTime.now(),
        );
      });
    }
  }

  void _handleTaskReorder(int oldIndex, int newIndex) {
    setState(() {
      final task = _tasks.removeAt(oldIndex);
      _tasks.insert(newIndex, task);
    });
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'toggle_completed':
        setState(() {
          _showCompletedTasks = !_showCompletedTasks;
        });
      case 'export':
        // TODO: 实现导出功能
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('导出功能开发中...')));
      case 'settings':
        // TODO: 实现设置功能
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('设置功能开发中...')));
    }
  }

  String _getTaskTimeText(TaskItem task) {
    if (task.startTime != null && task.endTime != null) {
      return '${_formatTime(task.startTime!)} - ${_formatTime(task.endTime!)}';
    } else if (task.startTime != null) {
      return '${_formatTime(task.startTime!)} 开始';
    } else if (task.endTime != null) {
      return '${_formatTime(task.endTime!)} 结束';
    }
    return '全天';
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
