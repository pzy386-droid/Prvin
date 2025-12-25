import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prvin/core/services/help_system_service.dart';
import 'package:prvin/core/widgets/help_system_widgets.dart';

import 'package:prvin/features/task_management/domain/entities/task.dart';
import 'package:prvin/features/task_management/presentation/bloc/task_bloc.dart';

/// 任务创建对话框
///
/// 提供优雅的任务创建界面，支持时间选择、优先级设置、分类选择等功能
/// 包含改进的错误处理和用户反馈机制
class TaskCreationDialog extends StatefulWidget {
  const TaskCreationDialog({super.key, this.initialDate});

  /// 初始日期，用于设置任务的默认开始时间
  final DateTime? initialDate;

  @override
  State<TaskCreationDialog> createState() => _TaskCreationDialogState();
}

class _TaskCreationDialogState extends State<TaskCreationDialog>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  final _titleController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late DateTime _startTime;
  late DateTime _endTime;
  TaskPriority _priority = TaskPriority.medium;
  TaskCategory _category = TaskCategory.other;
  bool _isValidating = false;

  @override
  void initState() {
    super.initState();

    // 滑动动画控制器
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    // 苹果风格的滑动动画 - 从右下角滑入
    _slideAnimation =
        Tween<Offset>(begin: const Offset(1.2, 1.2), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    // 弹性缩放动画
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.elasticOut),
    );

    // 淡入动画
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _slideController,
        curve: const Interval(0, 0.6, curve: Curves.easeOut),
      ),
    );

    // 设置默认时间
    final now = DateTime.now();
    final initialDate = widget.initialDate ?? now;
    _startTime = DateTime(
      initialDate.year,
      initialDate.month,
      initialDate.day,
      now.hour,
    );
    _endTime = _startTime.add(const Duration(hours: 1));

    // 启动动画
    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // 监听成功状态 - 只关闭弹窗，不显示消息
        BlocListener<TaskBloc, TaskState>(
          listenWhen: (previous, current) {
            return previous.status == TaskBlocStatus.loading &&
                current.status == TaskBlocStatus.success &&
                current.message != null &&
                current.message!.contains('创建');
          },
          listener: (context, state) {
            _closeWithAnimation();
          },
        ),
        // 监听错误状态
        BlocListener<TaskBloc, TaskState>(
          listenWhen: (previous, current) {
            return previous.status == TaskBlocStatus.loading &&
                (current.status == TaskBlocStatus.failure ||
                    current.status == TaskBlocStatus.conflict);
          },
          listener: (context, state) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? '操作失败'),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          },
        ),
      ],
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Align(
          alignment: Alignment.bottomRight,
          child: AnimatedBuilder(
            animation: _slideController,
            builder: (context, child) {
              return SlideTransition(
                position: _slideAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildTaskCard(),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTaskCard() {
    return Container(
      width: 320,
      constraints: const BoxConstraints(maxHeight: 500),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.95),
            Colors.white.withValues(alpha: 0.85),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4FC3F7).withValues(alpha: 0.2),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 16),
                  _buildTitleField(),
                  const SizedBox(height: 12),
                  _buildTimeSelector(),
                  const SizedBox(height: 12),
                  _buildPrioritySelector(),
                  const SizedBox(height: 12),
                  _buildCategorySelector(),
                  const SizedBox(height: 16),
                  _buildButtons(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF4FC3F7), Color(0xFF29B6F6)],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(CupertinoIcons.add, color: Colors.white, size: 16),
        ),
        const SizedBox(width: 10),
        const Text(
          '创建任务',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0277BD),
          ),
        ),
        const Spacer(),
        HelpButton(helpContext: HelpContext.taskCreation, size: 16),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: _closeWithAnimation,
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: const Color(0xFF0288D1).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              CupertinoIcons.xmark,
              size: 14,
              color: Color(0xFF0288D1),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleController,
      autofocus: true,
      style: const TextStyle(fontSize: 14),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '请输入任务内容';
        }
        if (value.trim().length > 100) {
          return '任务内容不能超过100个字符';
        }
        return null;
      },
      decoration: InputDecoration(
        hintText: '输入任务内容...',
        hintStyle: TextStyle(
          color: const Color(0xFF0288D1).withValues(alpha: 0.5),
          fontSize: 14,
        ),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.5),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: const Color(0xFF4FC3F7).withValues(alpha: 0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: const Color(0xFF4FC3F7).withValues(alpha: 0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF4FC3F7), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
    );
  }

  Widget _buildTimeSelector() {
    return Row(
      children: [
        Expanded(
          child: _buildTimeButton(
            label: '开始',
            time: _startTime,
            onTap: () => _selectTime(true),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildTimeButton(
            label: '结束',
            time: _endTime,
            onTap: () => _selectTime(false),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeButton({
    required String label,
    required DateTime time,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.5),
          border: Border.all(
            color: const Color(0xFF4FC3F7).withValues(alpha: 0.3),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: const Color(0xFF0288D1).withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${time.hour.toString().padLeft(2, '0')}:'
              '${time.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0277BD),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrioritySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '优先级',
          style: TextStyle(
            fontSize: 10,
            color: const Color(0xFF0288D1).withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: TaskPriority.values.map((priority) {
            final isSelected = _priority == priority;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: InkWell(
                  onTap: () => setState(() => _priority = priority),
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF4FC3F7).withValues(alpha: 0.2)
                          : Colors.white.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF4FC3F7)
                            : const Color(0xFF4FC3F7).withValues(alpha: 0.2),
                      ),
                    ),
                    child: Text(
                      _getPriorityLabel(priority),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                        color: const Color(0xFF0277BD),
                      ),
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

  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '分类',
          style: TextStyle(
            fontSize: 10,
            color: const Color(0xFF0288D1).withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: TaskCategory.values.map((category) {
            final isSelected = _category == category;
            return InkWell(
              onTap: () => setState(() => _category = category),
              borderRadius: BorderRadius.circular(6),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF4FC3F7).withValues(alpha: 0.2)
                      : Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF4FC3F7)
                        : const Color(0xFF4FC3F7).withValues(alpha: 0.2),
                  ),
                ),
                child: Text(
                  _getCategoryLabel(category),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: const Color(0xFF0277BD),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildButtons() {
    return BlocBuilder<TaskBloc, TaskState>(
      builder: (context, state) {
        final isLoading = state.status == TaskBlocStatus.loading;

        return Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: isLoading || _isValidating
                    ? null
                    : _closeWithAnimation,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  '取消',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0288D1),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: isLoading || _isValidating ? null : _saveTask,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  backgroundColor: const Color(0xFF4FC3F7),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: isLoading || _isValidating
                    ? const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Text(
                        '保存',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _selectTime(bool isStart) async {
    // 直接使用showTimePicker，不需要特殊处理
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(isStart ? _startTime : _endTime),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF4FC3F7)),
            timePickerTheme: const TimePickerThemeData(
              backgroundColor: Colors.white,
              hourMinuteTextColor: Color(0xFF0277BD),
              dayPeriodTextColor: Color(0xFF0277BD),
            ),
          ),
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
            child: child!,
          ),
        );
      },
    );

    if (time != null) {
      setState(() {
        final date = isStart ? _startTime : _endTime;
        final newTime = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );
        if (isStart) {
          _startTime = newTime;
        } else {
          _endTime = newTime;
        }
      });
    }
  }

  void _saveTask() {
    setState(() => _isValidating = true);

    // 使用Form验证
    if (!_formKey.currentState!.validate()) {
      setState(() => _isValidating = false);
      return;
    }

    // 验证时间逻辑
    if (_startTime.isAfter(_endTime)) {
      _showErrorSnackBar('开始时间不能晚于结束时间');
      setState(() => _isValidating = false);
      return;
    }

    // 验证时间间隔（至少15分钟）
    if (_endTime.difference(_startTime).inMinutes < 15) {
      _showErrorSnackBar('任务时长至少需要15分钟');
      setState(() => _isValidating = false);
      return;
    }

    final request = TaskCreateRequest(
      title: _titleController.text.trim(),
      startTime: _startTime,
      endTime: _endTime,
      priority: _priority,
      category: _category,
    );

    context.read<TaskBloc>().add(TaskCreateRequested(request));
    setState(() => _isValidating = false);
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _closeWithAnimation() {
    _slideController.reverse().then((_) {
      Navigator.of(context).pop();
    });
  }

  String _getPriorityLabel(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return '低';
      case TaskPriority.medium:
        return '中';
      case TaskPriority.high:
        return '高';
      case TaskPriority.urgent:
        return '紧急';
    }
  }

  String _getCategoryLabel(TaskCategory category) {
    switch (category) {
      case TaskCategory.work:
        return '工作';
      case TaskCategory.personal:
        return '个人';
      case TaskCategory.study:
        return '学习';
      case TaskCategory.health:
        return '健康';
      case TaskCategory.social:
        return '社交';
      case TaskCategory.other:
        return '其他';
    }
  }
}
