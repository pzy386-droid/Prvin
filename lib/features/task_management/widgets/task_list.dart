import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:prvin/core/theme/theme_exports.dart';
import 'package:prvin/core/widgets/widgets_exports.dart';
import 'package:prvin/features/task_management/widgets/task_form.dart';

/// 任务列表组件
/// 显示任务卡片列表，支持拖拽排序和快速操作
class TaskList extends StatefulWidget {
  /// 创建任务列表组件
  const TaskList({
    required this.tasks,
    super.key,
    this.onTaskTap,
    this.onTaskEdit,
    this.onTaskDelete,
    this.onTaskToggle,
    this.onTaskReorder,
    this.enableReorder = true,
    this.showCompletedTasks = true,
  });

  /// 任务列表
  final List<TaskItem> tasks;

  /// 任务点击回调
  final void Function(TaskItem task)? onTaskTap;

  /// 任务编辑回调
  final void Function(TaskItem task)? onTaskEdit;

  /// 任务删除回调
  final void Function(TaskItem task)? onTaskDelete;

  /// 任务状态切换回调
  final void Function(TaskItem task, bool completed)? onTaskToggle;

  /// 任务重新排序回调
  final void Function(int oldIndex, int newIndex)? onTaskReorder;

  /// 是否启用重新排序
  final bool enableReorder;

  /// 是否显示已完成任务
  final bool showCompletedTasks;

  @override
  State<TaskList> createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> with TickerProviderStateMixin {
  late AnimationController _listController;
  late List<AnimationController> _itemControllers;

  @override
  void initState() {
    super.initState();

    _listController = AnimationController(
      duration: AnimationTheme.mediumAnimationDuration,
      vsync: this,
    );

    _initializeItemControllers();
    _listController.forward();
  }

  void _initializeItemControllers() {
    _itemControllers = List.generate(
      widget.tasks.length,
      (index) => AnimationController(
        duration: AnimationTheme.shortAnimationDuration,
        vsync: this,
      )..forward(),
    );
  }

  @override
  void didUpdateWidget(TaskList oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.tasks.length != oldWidget.tasks.length) {
      // 清理旧的控制器
      for (final controller in _itemControllers) {
        controller.dispose();
      }

      // 创建新的控制器
      _initializeItemControllers();
    }
  }

  @override
  void dispose() {
    _listController.dispose();
    for (final controller in _itemControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredTasks = widget.showCompletedTasks
        ? widget.tasks
        : widget.tasks.where((task) => !task.isCompleted).toList();

    if (filteredTasks.isEmpty) {
      return _buildEmptyState();
    }

    return AnimatedBuilder(
      animation: _listController,
      builder: (context, child) {
        return Opacity(
          opacity: _listController.value,
          child: widget.enableReorder
              ? _buildReorderableList(filteredTasks)
              : _buildRegularList(filteredTasks),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const AppLottie(type: AppLottieType.empty, width: 120, height: 120),
          const SizedBox(height: AppTheme.spacingL),
          Text(
            '暂无任务',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppTheme.spacingS),
          Text(
            '点击右下角按钮创建第一个任务',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildReorderableList(List<TaskItem> tasks) {
    return ReorderableListView.builder(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      itemCount: tasks.length,
      onReorder: (oldIndex, newIndex) {
        if (newIndex > oldIndex) {
          newIndex -= 1;
        }
        widget.onTaskReorder?.call(oldIndex, newIndex);
      },
      itemBuilder: (context, index) {
        final task = tasks[index];
        return _buildTaskCard(task, index, key: ValueKey(task.id));
      },
    );
  }

  Widget _buildRegularList(List<TaskItem> tasks) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return _buildTaskCard(task, index);
      },
    );
  }

  Widget _buildTaskCard(TaskItem task, int index, {Key? key}) {
    if (index >= _itemControllers.length) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      key: key, // 将 key 移到最外层的 widget
      animation: _itemControllers[index],
      builder: (context, child) {
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
              .animate(
                CurvedAnimation(
                  parent: _itemControllers[index],
                  curve: Curves.easeOutBack,
                ),
              ),
          child: FadeTransition(
            opacity: _itemControllers[index],
            child: Container(
              margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
              child: TaskCard(
                task: task,
                onTap: () => widget.onTaskTap?.call(task),
                onEdit: () => widget.onTaskEdit?.call(task),
                onDelete: () => _handleTaskDelete(task, index),
                onToggle: (completed) =>
                    widget.onTaskToggle?.call(task, completed),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleTaskDelete(TaskItem task, int index) async {
    // 播放删除动画
    await _itemControllers[index].reverse();

    // 调用删除回调
    widget.onTaskDelete?.call(task);
  }
}

/// 任务卡片组件
class TaskCard extends StatefulWidget {
  /// 创建任务卡片组件
  const TaskCard({
    required this.task,
    super.key,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onToggle,
  });

  /// 任务数据
  final TaskItem task;

  /// 点击回调
  final VoidCallback? onTap;

  /// 编辑回调
  final VoidCallback? onEdit;

  /// 删除回调
  final VoidCallback? onDelete;

  /// 状态切换回调
  final void Function(bool completed)? onToggle;

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> with TickerProviderStateMixin {
  late AnimationController _hoverController;
  late AnimationController _completeController;
  late Animation<double> _hoverAnimation;
  late Animation<double> _completeAnimation;

  bool _isHovered = false;

  @override
  void initState() {
    super.initState();

    _hoverController = AnimationController(
      duration: AnimationTheme.shortAnimationDuration,
      vsync: this,
    );

    _completeController = AnimationController(
      duration: AnimationTheme.mediumAnimationDuration,
      vsync: this,
    );

    _hoverAnimation = Tween<double>(begin: 1, end: 1.02).animate(
      CurvedAnimation(
        parent: _hoverController,
        curve: AnimationTheme.defaultCurve,
      ),
    );

    _completeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _completeController,
        curve: AnimationTheme.smoothCurve,
      ),
    );

    if (widget.task.isCompleted) {
      _completeController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _hoverController.dispose();
    _completeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _setHovered(true),
      onExit: (_) => _setHovered(false),
      child: AnimatedBuilder(
        animation: Listenable.merge([_hoverAnimation, _completeAnimation]),
        builder: (context, child) {
          return Transform.scale(
            scale: _hoverAnimation.value,
            child: MicroInteractions.createDraggableWithEffects(
              data: widget.task,
              feedback: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 300,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    widget.task.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
              childWhenDragging: Opacity(
                opacity: 0.5,
                child: _buildCardContent(),
              ),
              onDragStarted: HapticFeedback.lightImpact,
              onDragEnd: () {
                // 拖拽结束时的处理
              },
              child: GestureDetector(
                onTap: widget.onTap,
                child: _buildCardContent(),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCardContent() {
    return AppCard(
      elevation: _isHovered ? 8 : 2,
      child: AnimatedOpacity(
        opacity: widget.task.isCompleted ? 0.7 : 1.0,
        duration: AnimationTheme.shortAnimationDuration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            if (widget.task.description != null) ...[
              const SizedBox(height: AppTheme.spacingS),
              _buildDescription(),
            ],
            const SizedBox(height: AppTheme.spacingM),
            _buildMetadata(),
            if (widget.task.tags.isNotEmpty) ...[
              const SizedBox(height: AppTheme.spacingM),
              _buildTags(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        // 完成状态复选框
        MicroInteractions.createInteractiveContainer(
          onTap: _toggleComplete,
          child: AnimatedContainer(
            duration: AnimationTheme.shortAnimationDuration,
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: widget.task.isCompleted
                  ? AppTheme.primaryColor
                  : Colors.transparent,
              border: Border.all(
                color: widget.task.isCompleted
                    ? AppTheme.primaryColor
                    : Colors.grey.shade400,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: widget.task.isCompleted
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : null,
          ),
        ),

        const SizedBox(width: AppTheme.spacingM),

        // 任务标题
        Expanded(
          child: Text(
            widget.task.title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              decoration: widget.task.isCompleted
                  ? TextDecoration.lineThrough
                  : null,
              color: widget.task.isCompleted ? Colors.grey.shade600 : null,
            ),
          ),
        ),

        // 优先级指示器
        if (widget.task.priority != null)
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(left: AppTheme.spacingS),
            decoration: BoxDecoration(
              color: _getPriorityColor(widget.task.priority!),
              shape: BoxShape.circle,
            ),
          ),

        // 操作按钮
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: Colors.grey.shade600),
          onSelected: _handleMenuAction,
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 16),
                  SizedBox(width: 8),
                  Text('编辑'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 16, color: Colors.red),
                  SizedBox(width: 8),
                  Text('删除', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Text(
      widget.task.description!,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: Colors.grey.shade700,
        decoration: widget.task.isCompleted ? TextDecoration.lineThrough : null,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildMetadata() {
    return Row(
      children: [
        // 分类图标
        if (widget.task.category != null) ...[
          Icon(
            _getCategoryIcon(widget.task.category!),
            size: 16,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(width: AppTheme.spacingXS),
          Text(
            _getCategoryLabel(widget.task.category!),
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: AppTheme.spacingM),
        ],

        // 时间信息
        if (widget.task.startTime != null || widget.task.endTime != null) ...[
          Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: AppTheme.spacingXS),
          Text(
            _getTimeText(),
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],

        const Spacer(),

        // 日期
        Text(
          _getDateText(),
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildTags() {
    return Wrap(
      spacing: AppTheme.spacingXS,
      runSpacing: AppTheme.spacingXS,
      children: widget.task.tags.take(3).map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingS,
            vertical: 2,
          ),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppTheme.radiusS),
          ),
          child: Text(
            tag,
            style: const TextStyle(
              fontSize: 10,
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }

  void _setHovered(bool hovered) {
    setState(() => _isHovered = hovered);
    if (hovered) {
      _hoverController.forward();
    } else {
      _hoverController.reverse();
    }
  }

  void _toggleComplete() {
    final newCompleted = !widget.task.isCompleted;

    if (newCompleted) {
      _completeController.forward();
    } else {
      _completeController.reverse();
    }

    widget.onToggle?.call(newCompleted);
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'edit':
        widget.onEdit?.call();
      case 'delete':
        widget.onDelete?.call();
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
      case '高':
        return AppTheme.errorColor;
      case 'medium':
      case '中':
        return AppTheme.warningColor;
      case 'low':
      case '低':
        return AppTheme.successColor;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'work':
        return Icons.work;
      case 'personal':
        return Icons.person;
      case 'health':
        return Icons.favorite;
      case 'study':
        return Icons.school;
      case 'meeting':
        return Icons.group;
      default:
        return Icons.task;
    }
  }

  String _getCategoryLabel(String category) {
    switch (category.toLowerCase()) {
      case 'work':
        return '工作';
      case 'personal':
        return '个人';
      case 'health':
        return '健康';
      case 'study':
        return '学习';
      case 'meeting':
        return '会议';
      default:
        return category;
    }
  }

  String _getTimeText() {
    if (widget.task.startTime != null && widget.task.endTime != null) {
      return '${_formatTime(widget.task.startTime!)} - ${_formatTime(widget.task.endTime!)}';
    } else if (widget.task.startTime != null) {
      return '${_formatTime(widget.task.startTime!)} 开始';
    } else if (widget.task.endTime != null) {
      return '${_formatTime(widget.task.endTime!)} 结束';
    }
    return '';
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _getDateText() {
    final now = DateTime.now();
    final taskDate = widget.task.date;

    if (taskDate.year == now.year &&
        taskDate.month == now.month &&
        taskDate.day == now.day) {
      return '今天';
    } else if (taskDate.year == now.year &&
        taskDate.month == now.month &&
        taskDate.day == now.day + 1) {
      return '明天';
    } else if (taskDate.year == now.year &&
        taskDate.month == now.month &&
        taskDate.day == now.day - 1) {
      return '昨天';
    } else {
      return '${taskDate.month}月${taskDate.day}日';
    }
  }
}

/// 任务项数据模型
class TaskItem {
  const TaskItem({
    required this.id,
    required this.title,
    required this.date,
    this.description,
    this.startTime,
    this.endTime,
    this.category,
    this.priority,
    this.tags = const [],
    this.isCompleted = false,
    this.createdAt,
    this.updatedAt,
  });

  /// 从TaskFormData创建TaskItem
  factory TaskItem.fromFormData(TaskFormData formData) {
    return TaskItem(
      id: formData.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: formData.title,
      description: formData.description,
      date: formData.date,
      startTime: formData.startTime,
      endTime: formData.endTime,
      category: formData.category,
      priority: formData.priority,
      tags: formData.tags,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// 任务ID
  final String id;

  /// 任务标题
  final String title;

  /// 任务描述
  final String? description;

  /// 任务日期
  final DateTime date;

  /// 开始时间
  final TimeOfDay? startTime;

  /// 结束时间
  final TimeOfDay? endTime;

  /// 任务分类
  final String? category;

  /// 优先级
  final String? priority;

  /// 标签列表
  final List<String> tags;

  /// 是否已完成
  final bool isCompleted;

  /// 创建时间
  final DateTime? createdAt;

  /// 更新时间
  final DateTime? updatedAt;

  /// 复制并修改数据
  TaskItem copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? date,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    String? category,
    String? priority,
    List<String>? tags,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TaskItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      tags: tags ?? this.tags,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// 转换为TaskFormData
  TaskFormData toFormData() {
    return TaskFormData(
      id: id,
      title: title,
      description: description,
      date: date,
      startTime: startTime,
      endTime: endTime,
      category: category,
      priority: priority,
      tags: tags,
    );
  }
}
