import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:prvin/features/task_management/domain/entities/task.dart';
import 'package:prvin/features/task_management/presentation/bloc/task_bloc.dart';
import 'package:prvin/features/task_management/presentation/widgets/task_form_widgets.dart';

/// 任务表单页面（创建/编辑）
class TaskFormPage extends StatefulWidget {
  const TaskFormPage({super.key, this.task, this.initialDate});

  final Task? task;
  final DateTime? initialDate;

  /// 是否是编辑模式
  bool get isEditing => task != null;

  @override
  State<TaskFormPage> createState() => _TaskFormPageState();
}

class _TaskFormPageState extends State<TaskFormPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime? _startTime;
  DateTime? _endTime;
  TaskPriority _priority = TaskPriority.medium;
  TaskCategory _category = TaskCategory.other;
  List<String> _tags = [];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _initializeForm();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _initializeForm() {
    if (widget.task != null) {
      // 编辑模式 - 填充现有数据
      final task = widget.task!;
      _titleController.text = task.title;
      _descriptionController.text = task.description ?? '';
      _startTime = task.startTime;
      _endTime = task.endTime;
      _priority = task.priority;
      _category = task.category;
      _tags = List.from(task.tags);
    } else {
      // 创建模式 - 设置默认值
      final now = DateTime.now();
      final initialDate = widget.initialDate ?? now;
      _startTime = DateTime(
        initialDate.year,
        initialDate.month,
        initialDate.day,
        now.hour,
      );
      _endTime = _startTime!.add(const Duration(hours: 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB), Color(0xFFE1F5FE)],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeController,
            child: Column(
              children: [
                _buildAppBar(),
                Expanded(child: _buildForm()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          _buildBackButton(),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              widget.isEditing ? '编辑任务' : '创建任务',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0277BD),
              ),
            ),
          ),
          _buildSaveButton(),
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4FC3F7).withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.of(context).pop(),
          borderRadius: BorderRadius.circular(12),
          child: const Icon(
            CupertinoIcons.back,
            color: Color(0xFF0277BD),
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return BlocConsumer<TaskBloc, TaskState>(
      listener: (context, state) {
        if (state.isSuccess && state.message != null) {
          _showSuccessMessage(state.message!);
          Navigator.of(context).pop();
        } else if (state.hasError) {
          _showErrorMessage(state.errorMessage ?? '操作失败');
        } else if (state.hasConflict) {
          _showConflictDialog(state.conflicts);
        }
      },
      builder: (context, state) {
        return TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 300),
          tween: Tween(begin: 0, end: 1),
          builder: (context, value, child) {
            return Transform.scale(
              scale: 0.9 + (0.1 * value),
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4FC3F7), Color(0xFF29B6F6)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4FC3F7).withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: state.isLoading ? null : _saveTask,
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (state.isLoading)
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          else
                            const Icon(
                              CupertinoIcons.checkmark,
                              color: Colors.white,
                              size: 16,
                            ),
                          const SizedBox(width: 8),
                          Text(
                            widget.isEditing ? '更新' : '保存',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildFormCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('基本信息'),
                  const SizedBox(height: 16),
                  TaskTitleField(controller: _titleController),
                  const SizedBox(height: 16),
                  TaskDescriptionField(controller: _descriptionController),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildFormCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('时间安排'),
                  const SizedBox(height: 16),
                  TaskTimeSelector(
                    startTime: _startTime,
                    endTime: _endTime,
                    onStartTimeChanged: (time) =>
                        setState(() => _startTime = time),
                    onEndTimeChanged: (time) => setState(() => _endTime = time),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildFormCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('任务属性'),
                  const SizedBox(height: 16),
                  TaskPrioritySelector(
                    priority: _priority,
                    onChanged: (priority) =>
                        setState(() => _priority = priority),
                  ),
                  const SizedBox(height: 16),
                  TaskCategorySelector(
                    category: _category,
                    onChanged: (category) =>
                        setState(() => _category = category),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildFormCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('标签'),
                  const SizedBox(height: 16),
                  TaskTagsField(
                    tags: _tags,
                    onChanged: (tags) => setState(() => _tags = tags),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100), // 底部间距
          ],
        ),
      ),
    );
  }

  Widget _buildFormCard({required Widget child}) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      tween: Tween(begin: 0, end: 1),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.4 * value),
                    Colors.white.withValues(alpha: 0.1 * value),
                    Colors.white.withValues(alpha: 0.3 * value),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3 * value),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(
                      0xFF4FC3F7,
                    ).withValues(alpha: 0.15 * value),
                    blurRadius: 20 * value,
                    offset: Offset(0, 8 * value),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: 8 * value,
                    sigmaY: 8 * value,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1 * value),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: child,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Color(0xFF0277BD),
      ),
    );
  }

  void _saveTask() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_startTime == null || _endTime == null) {
      _showErrorMessage('请选择开始和结束时间');
      return;
    }

    if (_startTime!.isAfter(_endTime!)) {
      _showErrorMessage('开始时间不能晚于结束时间');
      return;
    }

    final taskBloc = context.read<TaskBloc>();

    if (widget.isEditing) {
      // 更新任务
      final request = TaskUpdateRequest(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        startTime: _startTime,
        endTime: _endTime,
        priority: _priority,
        category: _category,
        tags: _tags,
      );
      taskBloc.add(TaskUpdateRequested(widget.task!.id, request));
    } else {
      // 创建任务
      final request = TaskCreateRequest(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        startTime: _startTime!,
        endTime: _endTime!,
        priority: _priority,
        category: _category,
        tags: _tags,
      );
      taskBloc.add(TaskCreateRequested(request));
    }
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showConflictDialog(List<ConflictWarning> conflicts) {
    showCupertinoDialog<void>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('时间冲突'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('检测到以下时间冲突：'),
            const SizedBox(height: 8),
            ...conflicts.map(
              (conflict) => Text(
                '与"${conflict.conflictingTask.title}"冲突',
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('取消'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            child: const Text('调整时间'),
            onPressed: () {
              Navigator.pop(context);
              // 可以在这里实现自动调整时间的逻辑
            },
          ),
        ],
      ),
    );
  }
}
