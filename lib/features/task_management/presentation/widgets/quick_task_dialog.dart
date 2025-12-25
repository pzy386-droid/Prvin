import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:prvin/features/task_management/domain/entities/task.dart';
import 'package:prvin/features/task_management/presentation/bloc/task_bloc.dart';

/// 快速创建任务对话框
class QuickTaskDialog extends StatefulWidget {
  const QuickTaskDialog({super.key, this.initialDate});

  final DateTime? initialDate;

  @override
  State<QuickTaskDialog> createState() => _QuickTaskDialogState();
}

class _QuickTaskDialogState extends State<QuickTaskDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final _titleController = TextEditingController();
  DateTime? _startTime;
  DateTime? _endTime;
  TaskPriority _priority = TaskPriority.medium;
  TaskCategory _category = TaskCategory.other;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animationController.forward();

    // 设置默认时间
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

  @override
  void dispose() {
    _animationController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TaskBloc, TaskState>(
      listener: (context, state) {
        if (state.isSuccess && state.message != null) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message!),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        } else if (state.hasError) {
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
        }
      },
      child: ScaleTransition(
        scale: CurvedAnimation(
          parent: _animationController,
          curve: Curves.easeOutCubic,
        ),
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
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
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 20),
                      _buildTitleField(),
                      const SizedBox(height: 16),
                      _buildTimeSelector(),
                      const SizedBox(height: 16),
                      _buildPrioritySelector(),
                      const SizedBox(height: 16),
                      _buildCategorySelector(),
                      const SizedBox(height: 24),
                      _buildButtons(),
                    ],
                  ),
                ),
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
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF4FC3F7), Color(0xFF29B6F6)],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(CupertinoIcons.add, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        const Text(
          '创建任务',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0277BD),
          ),
        ),
      ],
    );
  }

  Widget _buildTitleField() {
    return TextField(
      controller: _titleController,
      autofocus: true,
      decoration: InputDecoration(
        hintText: '输入任务内容...',
        hintStyle: TextStyle(
          color: const Color(0xFF0288D1).withValues(alpha: 0.5),
        ),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: const Color(0xFF4FC3F7).withValues(alpha: 0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: const Color(0xFF4FC3F7).withValues(alpha: 0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF4FC3F7), width: 2),
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
            time: _startTime!,
            onTap: () => _selectTime(true),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildTimeButton(
            label: '结束',
            time: _endTime!,
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
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF4FC3F7).withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: const Color(0xFF0288D1).withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(
                fontSize: 16,
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
            fontSize: 12,
            color: const Color(0xFF0288D1).withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: TaskPriority.values.map((priority) {
            final isSelected = _priority == priority;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: InkWell(
                  onTap: () => setState(() => _priority = priority),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF4FC3F7).withValues(alpha: 0.2)
                          : Colors.white.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
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
                        fontSize: 12,
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
            fontSize: 12,
            color: const Color(0xFF0288D1).withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: TaskCategory.values.map((category) {
            final isSelected = _category == category;
            return InkWell(
              onTap: () => setState(() => _category = category),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF4FC3F7).withValues(alpha: 0.2)
                      : Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF4FC3F7)
                        : const Color(0xFF4FC3F7).withValues(alpha: 0.2),
                  ),
                ),
                child: Text(
                  _getCategoryLabel(category),
                  style: TextStyle(
                    fontSize: 12,
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
        return Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: state.isLoading
                    ? null
                    : () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  '取消',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0288D1),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: state.isLoading ? null : _saveTask,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: const Color(0xFF4FC3F7),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: state.isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
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
                          fontSize: 14,
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
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(isStart ? _startTime! : _endTime!),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF4FC3F7)),
          ),
          child: child!,
        );
      },
    );

    if (time != null) {
      setState(() {
        final date = isStart ? _startTime! : _endTime!;
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
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('请输入任务内容'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    if (_startTime!.isAfter(_endTime!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('开始时间不能晚于结束时间'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    final request = TaskCreateRequest(
      title: _titleController.text.trim(),
      startTime: _startTime!,
      endTime: _endTime!,
      priority: _priority,
      category: _category,
    );

    context.read<TaskBloc>().add(TaskCreateRequested(request));
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
