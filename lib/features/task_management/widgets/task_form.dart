import 'package:flutter/material.dart';
import 'package:prvin/core/theme/theme_exports.dart';
import 'package:prvin/core/widgets/widgets_exports.dart';

/// 任务表单组件
/// 用于创建和编辑任务
class TaskForm extends StatefulWidget {
  /// 创建任务表单组件
  const TaskForm({super.key, this.initialTask, this.onSave, this.onCancel});

  /// 初始任务数据（编辑模式）
  final TaskFormData? initialTask;

  /// 保存回调
  final void Function(TaskFormData task)? onSave;

  /// 取消回调
  final VoidCallback? onCancel;

  @override
  State<TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _tagsController = TextEditingController();

  late DateTime _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  String _selectedCategory = 'work';
  String _selectedPriority = 'medium';
  final List<String> _tags = [];

  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // 初始化动画
    _slideController = AnimationController(
      duration: AnimationTheme.mediumAnimationDuration,
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _slideController,
            curve: AnimationTheme.smoothCurve,
          ),
        );

    // 初始化表单数据
    _initializeFormData();

    // 启动进入动画
    _slideController.forward();
  }

  void _initializeFormData() {
    if (widget.initialTask != null) {
      final task = widget.initialTask!;
      _titleController.text = task.title;
      _descriptionController.text = task.description ?? '';
      _selectedDate = task.date;
      _startTime = task.startTime;
      _endTime = task.endTime;
      _selectedCategory = task.category ?? 'work';
      _selectedPriority = task.priority ?? 'medium';
      _tags.addAll(task.tags);
      _tagsController.text = _tags.join(', ');
    } else {
      _selectedDate = DateTime.now();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppTheme.radiusL),
          ),
        ),
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppTheme.spacingL),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTitleField(),
                      const SizedBox(height: AppTheme.spacingL),
                      _buildDescriptionField(),
                      const SizedBox(height: AppTheme.spacingL),
                      _buildDateTimeSection(),
                      const SizedBox(height: AppTheme.spacingL),
                      _buildCategorySection(),
                      const SizedBox(height: AppTheme.spacingL),
                      _buildPrioritySection(),
                      const SizedBox(height: AppTheme.spacingL),
                      _buildTagsSection(),
                      const SizedBox(height: AppTheme.spacingXL),
                      _buildActionButtons(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.05),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppTheme.radiusL),
        ),
      ),
      child: Row(
        children: [
          MicroInteractions.createInteractiveContainer(
            onTap: _handleCancel,
            child: Container(
              padding: const EdgeInsets.all(AppTheme.spacingS),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(AppTheme.radiusS),
              ),
              child: const Icon(Icons.close, size: 20),
            ),
          ),
          const SizedBox(width: AppTheme.spacingM),
          Expanded(
            child: Text(
              widget.initialTask != null ? '编辑任务' : '创建任务',
              style: ResponsiveTheme.createResponsiveTextStyle(
                context,
                baseFontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
          MicroInteractions.createInteractiveContainer(
            onTap: _handleSave,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingM,
                vertical: AppTheme.spacingS,
              ),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(AppTheme.radiusS),
              ),
              child: const Text(
                '保存',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '任务标题 *',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: AppTheme.spacingS),
        AppInput(
          controller: _titleController,
          hint: '输入任务标题',
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return '请输入任务标题';
            }
            return null;
          },
          prefixIcon: Icons.task_alt,
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '任务描述',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: AppTheme.spacingS),
        AppInput(
          controller: _descriptionController,
          hint: '输入任务描述（可选）',
          maxLines: 3,
          prefixIcon: Icons.description,
        ),
      ],
    );
  }

  Widget _buildDateTimeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '时间安排',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: AppTheme.spacingM),

        // 日期选择
        _buildDateSelector(),
        const SizedBox(height: AppTheme.spacingM),

        // 时间选择
        Row(
          children: [
            Expanded(child: _buildTimeSelector('开始时间', _startTime, true)),
            const SizedBox(width: AppTheme.spacingM),
            Expanded(child: _buildTimeSelector('结束时间', _endTime, false)),
          ],
        ),
      ],
    );
  }

  Widget _buildDateSelector() {
    return MicroInteractions.createInteractiveContainer(
      onTap: _selectDate,
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: AppTheme.primaryColor),
            const SizedBox(width: AppTheme.spacingM),
            Expanded(
              child: Text(
                '${_selectedDate.year}年${_selectedDate.month}月${_selectedDate.day}日',
                style: const TextStyle(fontSize: 16),
              ),
            ),
            Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSelector(String label, TimeOfDay? time, bool isStartTime) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: AppTheme.spacingS),
        MicroInteractions.createInteractiveContainer(
          onTap: () => _selectTime(isStartTime),
          child: Container(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time, color: AppTheme.primaryColor, size: 20),
                const SizedBox(width: AppTheme.spacingS),
                Expanded(
                  child: Text(
                    time != null
                        ? '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}'
                        : '选择时间',
                    style: TextStyle(
                      fontSize: 14,
                      color: time != null
                          ? Colors.black87
                          : Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySection() {
    const categories = [
      {'key': 'work', 'label': '工作', 'icon': Icons.work},
      {'key': 'personal', 'label': '个人', 'icon': Icons.person},
      {'key': 'health', 'label': '健康', 'icon': Icons.favorite},
      {'key': 'study', 'label': '学习', 'icon': Icons.school},
      {'key': 'meeting', 'label': '会议', 'icon': Icons.group},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '任务分类',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: AppTheme.spacingM),
        Wrap(
          spacing: AppTheme.spacingS,
          runSpacing: AppTheme.spacingS,
          children: categories.map((category) {
            final isSelected = _selectedCategory == category['key'];
            return MicroInteractions.createInteractiveContainer(
              onTap: () =>
                  setState(() => _selectedCategory = category['key']! as String),
              child: AnimatedContainer(
                duration: AnimationTheme.shortAnimationDuration,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingM,
                  vertical: AppTheme.spacingS,
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
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      category['icon']! as IconData,
                      size: 16,
                      color: isSelected ? Colors.white : AppTheme.primaryColor,
                    ),
                    const SizedBox(width: AppTheme.spacingXS),
                    Text(
                      category['label']! as String,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPrioritySection() {
    const priorities = [
      {'key': 'low', 'label': '低', 'color': Colors.green},
      {'key': 'medium', 'label': '中', 'color': Colors.orange},
      {'key': 'high', 'label': '高', 'color': Colors.red},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '优先级',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: AppTheme.spacingM),
        Row(
          children: priorities.map((priority) {
            final isSelected = _selectedPriority == priority['key'];
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: AppTheme.spacingS),
                child: MicroInteractions.createInteractiveContainer(
                  onTap: () => setState(
                    () => _selectedPriority = priority['key']! as String,
                  ),
                  child: AnimatedContainer(
                    duration: AnimationTheme.shortAnimationDuration,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppTheme.spacingM,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (priority['color']! as Color).withValues(alpha: 0.1)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(AppTheme.radiusM),
                      border: Border.all(
                        color: isSelected
                            ? priority['color']! as Color
                            : Colors.grey.shade300,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: priority['color']! as Color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacingXS),
                        Text(
                          priority['label']! as String,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                            color: isSelected
                                ? priority['color']! as Color
                                : Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '标签',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: AppTheme.spacingS),
        AppInput(
          controller: _tagsController,
          hint: '输入标签，用逗号分隔',
          prefixIcon: Icons.label,
          onChanged: _updateTags,
        ),
        if (_tags.isNotEmpty) ...[
          const SizedBox(height: AppTheme.spacingM),
          Wrap(
            spacing: AppTheme.spacingS,
            runSpacing: AppTheme.spacingS,
            children: _tags.map((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingM,
                  vertical: AppTheme.spacingXS,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusL),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      tag,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingXS),
                    MicroInteractions.createInteractiveContainer(
                      onTap: () => _removeTag(tag),
                      child: const Icon(
                        Icons.close,
                        size: 14,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: AppButton(
            text: '取消',
            type: AppButtonType.outline,
            onPressed: _handleCancel,
          ),
        ),
        const SizedBox(width: AppTheme.spacingM),
        Expanded(
          child: AppButton(
            text: widget.initialTask != null ? '更新任务' : '创建任务',
            onPressed: _handleSave,
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: AppTheme.primaryColor),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _selectTime(bool isStartTime) async {
    final time = await showTimePicker(
      context: context,
      initialTime: isStartTime
          ? (_startTime ?? TimeOfDay.now())
          : (_endTime ?? TimeOfDay.now()),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: AppTheme.primaryColor),
          ),
          child: child!,
        );
      },
    );

    if (time != null) {
      setState(() {
        if (isStartTime) {
          _startTime = time;
          // 如果开始时间晚于结束时间，自动调整结束时间
          if (_endTime != null && _isTimeAfter(time, _endTime!)) {
            _endTime = TimeOfDay(
              hour: time.hour + 1 > 23 ? 23 : time.hour + 1,
              minute: time.minute,
            );
          }
        } else {
          _endTime = time;
          // 如果结束时间早于开始时间，自动调整开始时间
          if (_startTime != null && _isTimeAfter(_startTime!, time)) {
            _startTime = TimeOfDay(
              hour: time.hour - 1 < 0 ? 0 : time.hour - 1,
              minute: time.minute,
            );
          }
        }
      });
    }
  }

  bool _isTimeAfter(TimeOfDay time1, TimeOfDay time2) {
    return time1.hour > time2.hour ||
        (time1.hour == time2.hour && time1.minute > time2.minute);
  }

  void _updateTags(String value) {
    final newTags = value
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();

    setState(() {
      _tags.clear();
      _tags.addAll(newTags);
    });
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
      _tagsController.text = _tags.join(', ');
    });
  }

  void _handleSave() {
    if (_formKey.currentState?.validate() ?? false) {
      // 验证时间冲突
      if (_startTime != null &&
          _endTime != null &&
          _isTimeAfter(_startTime!, _endTime!)) {
        _showErrorDialog('时间设置错误', '开始时间不能晚于结束时间');
        return;
      }

      final taskData = TaskFormData(
        id: widget.initialTask?.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        date: _selectedDate,
        startTime: _startTime,
        endTime: _endTime,
        category: _selectedCategory,
        priority: _selectedPriority,
        tags: List.from(_tags),
      );

      widget.onSave?.call(taskData);
    }
  }

  Future<void> _handleCancel() async {
    // 检查是否有未保存的更改
    if (_hasUnsavedChanges()) {
      final shouldDiscard = await _showDiscardDialog();
      if (shouldDiscard ?? false) {
        widget.onCancel?.call();
      }
    } else {
      widget.onCancel?.call();
    }
  }

  bool _hasUnsavedChanges() {
    if (widget.initialTask == null) {
      return _titleController.text.trim().isNotEmpty ||
          _descriptionController.text.trim().isNotEmpty ||
          _tags.isNotEmpty;
    } else {
      final initial = widget.initialTask!;
      return _titleController.text.trim() != initial.title ||
          _descriptionController.text.trim() != (initial.description ?? '') ||
          _selectedDate != initial.date ||
          _startTime != initial.startTime ||
          _endTime != initial.endTime ||
          _selectedCategory != (initial.category ?? 'work') ||
          _selectedPriority != (initial.priority ?? 'medium') ||
          !_listsEqual(_tags, initial.tags);
    }
  }

  bool _listsEqual(List<String> list1, List<String> list2) {
    if (list1.length != list2.length) return false;
    for (var i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }
    return true;
  }

  Future<bool?> _showDiscardDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('放弃更改'),
        content: const Text('您有未保存的更改，确定要放弃吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('继续编辑'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('放弃更改'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}

/// 任务表单数据模型
class TaskFormData {
  const TaskFormData({
    required this.title, required this.date, this.id,
    this.description,
    this.startTime,
    this.endTime,
    this.category,
    this.priority,
    this.tags = const [],
  });

  /// 任务ID（编辑模式）
  final String? id;

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

  /// 复制并修改数据
  TaskFormData copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? date,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    String? category,
    String? priority,
    List<String>? tags,
  }) {
    return TaskFormData(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      tags: tags ?? this.tags,
    );
  }
}
