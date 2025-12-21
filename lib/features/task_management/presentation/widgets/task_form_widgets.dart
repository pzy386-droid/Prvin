
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:prvin/features/task_management/domain/entities/task.dart';

/// 任务标题输入框
class TaskTitleField extends StatelessWidget {
  const TaskTitleField({required this.controller, super.key});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: '任务标题',
        hintText: '输入任务标题...',
        prefixIcon: const Icon(CupertinoIcons.textformat, size: 20),
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
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.7),
        labelStyle: const TextStyle(color: Color(0xFF0277BD)),
        hintStyle: TextStyle(
          color: const Color(0xFF0288D1).withValues(alpha: 0.6),
        ),
      ),
      style: const TextStyle(
        color: Color(0xFF0277BD),
        fontWeight: FontWeight.w500,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '请输入任务标题';
        }
        if (value.trim().length < 2) {
          return '任务标题至少需要2个字符';
        }
        return null;
      },
    );
  }
}

/// 任务描述输入框
class TaskDescriptionField extends StatelessWidget {
  const TaskDescriptionField({required this.controller, super.key});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: 3,
      decoration: InputDecoration(
        labelText: '任务描述（可选）',
        hintText: '输入任务详细描述...',
        prefixIcon: const Icon(CupertinoIcons.doc_text, size: 20),
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
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.7),
        labelStyle: const TextStyle(color: Color(0xFF0277BD)),
        hintStyle: TextStyle(
          color: const Color(0xFF0288D1).withValues(alpha: 0.6),
        ),
      ),
      style: const TextStyle(
        color: Color(0xFF0277BD),
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

/// 任务时间选择器
class TaskTimeSelector extends StatelessWidget {
  const TaskTimeSelector({
    required this.startTime,
    required this.endTime,
    required this.onStartTimeChanged,
    required this.onEndTimeChanged,
    super.key,
  });

  final DateTime? startTime;
  final DateTime? endTime;
  final ValueChanged<DateTime> onStartTimeChanged;
  final ValueChanged<DateTime> onEndTimeChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTimeField(
          context,
          label: '开始时间',
          time: startTime,
          icon: CupertinoIcons.time,
          onTap: () => _selectDateTime(context, startTime, onStartTimeChanged),
        ),
        const SizedBox(height: 16),
        _buildTimeField(
          context,
          label: '结束时间',
          time: endTime,
          icon: CupertinoIcons.time_solid,
          onTap: () => _selectDateTime(context, endTime, onEndTimeChanged),
        ),
      ],
    );
  }

  Widget _buildTimeField(
    BuildContext context, {
    required String label,
    required DateTime? time,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF4FC3F7).withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF0277BD), size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF0277BD),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    time != null ? _formatDateTime(time) : '点击选择时间',
                    style: TextStyle(
                      fontSize: 16,
                      color: time != null
                          ? const Color(0xFF0277BD)
                          : const Color(0xFF0288D1).withValues(alpha: 0.6),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              CupertinoIcons.chevron_right,
              color: const Color(0xFF0288D1).withValues(alpha: 0.6),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDateTime(
    BuildContext context,
    DateTime? currentTime,
    ValueChanged<DateTime> onChanged,
  ) async {
    final now = DateTime.now();
    final initialDate = currentTime ?? now;

    // 选择日期
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF4FC3F7),
              onSurface: Color(0xFF0277BD),
            ),
          ),
          child: child!,
        );
      },
    );

    if (date == null) return;

    // 选择时间
    if (context.mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initialDate),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: Color(0xFF4FC3F7),
                onSurface: Color(0xFF0277BD),
              ),
            ),
            child: child!,
          );
        },
      );

      if (time != null) {
        final selectedDateTime = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );
        onChanged(selectedDateTime);
      }
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}年${dateTime.month}月${dateTime.day}日 '
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

/// 任务优先级选择器
class TaskPrioritySelector extends StatelessWidget {
  const TaskPrioritySelector({
    required this.priority,
    required this.onChanged,
    super.key,
  });

  final TaskPriority priority;
  final ValueChanged<TaskPriority> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '优先级',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF0277BD),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: TaskPriority.values.map((p) {
            final isSelected = p == priority;
            return Expanded(
              child: GestureDetector(
                onTap: () => onChanged(p),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(
                            colors: [
                              _getPriorityColor(p),
                              _getPriorityColor(p).withValues(alpha: 0.8),
                            ],
                          )
                        : null,
                    color: isSelected
                        ? null
                        : Colors.white.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? _getPriorityColor(p)
                          : const Color(0xFF4FC3F7).withValues(alpha: 0.3),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Text(
                    p.label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF0277BD),
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

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return const Color(0xFF81C784);
      case TaskPriority.medium:
        return const Color(0xFF4FC3F7);
      case TaskPriority.high:
        return const Color(0xFFFFB74D);
      case TaskPriority.urgent:
        return const Color(0xFFE57373);
    }
  }
}

/// 任务分类选择器
class TaskCategorySelector extends StatelessWidget {
  const TaskCategorySelector({
    required this.category,
    required this.onChanged,
    super.key,
  });

  final TaskCategory category;
  final ValueChanged<TaskCategory> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '分类',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF0277BD),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: TaskCategory.values.map((c) {
            final isSelected = c == category;
            return GestureDetector(
              onTap: () => onChanged(c),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                          colors: [
                            _getCategoryColor(c),
                            _getCategoryColor(c).withValues(alpha: 0.8),
                          ],
                        )
                      : null,
                  color: isSelected
                      ? null
                      : Colors.white.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? _getCategoryColor(c)
                        : const Color(0xFF4FC3F7).withValues(alpha: 0.3),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getCategoryIcon(c),
                      size: 16,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF0277BD),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      c.label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF0277BD),
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

  Color _getCategoryColor(TaskCategory category) {
    switch (category) {
      case TaskCategory.work:
        return const Color(0xFF4FC3F7);
      case TaskCategory.personal:
        return const Color(0xFF81C784);
      case TaskCategory.study:
        return const Color(0xFFAB47BC);
      case TaskCategory.health:
        return const Color(0xFFE57373);
      case TaskCategory.social:
        return const Color(0xFFFFB74D);
      case TaskCategory.other:
        return const Color(0xFF90A4AE);
    }
  }

  IconData _getCategoryIcon(TaskCategory category) {
    switch (category) {
      case TaskCategory.work:
        return CupertinoIcons.briefcase;
      case TaskCategory.personal:
        return CupertinoIcons.person;
      case TaskCategory.study:
        return CupertinoIcons.book;
      case TaskCategory.health:
        return CupertinoIcons.heart;
      case TaskCategory.social:
        return CupertinoIcons.group;
      case TaskCategory.other:
        return CupertinoIcons.tag;
    }
  }
}

/// 任务标签输入框
class TaskTagsField extends StatefulWidget {
  const TaskTagsField({required this.tags, required this.onChanged, super.key});

  final List<String> tags;
  final ValueChanged<List<String>> onChanged;

  @override
  State<TaskTagsField> createState() => _TaskTagsFieldState();
}

class _TaskTagsFieldState extends State<TaskTagsField> {
  final _tagController = TextEditingController();

  @override
  void dispose() {
    _tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _tagController,
                decoration: InputDecoration(
                  labelText: '添加标签',
                  hintText: '输入标签名称...',
                  prefixIcon: const Icon(CupertinoIcons.tag, size: 20),
                  suffixIcon: IconButton(
                    icon: const Icon(CupertinoIcons.add, size: 20),
                    onPressed: _addTag,
                  ),
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
                    borderSide: const BorderSide(
                      color: Color(0xFF4FC3F7),
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.7),
                  labelStyle: const TextStyle(color: Color(0xFF0277BD)),
                  hintStyle: TextStyle(
                    color: const Color(0xFF0288D1).withValues(alpha: 0.6),
                  ),
                ),
                style: const TextStyle(
                  color: Color(0xFF0277BD),
                  fontWeight: FontWeight.w500,
                ),
                onFieldSubmitted: (_) => _addTag(),
              ),
            ),
          ],
        ),
        if (widget.tags.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.tags.map((tag) {
              return TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 300),
                tween: Tween(begin: 0, end: 1),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF4FC3F7).withValues(alpha: 0.2),
                            const Color(0xFF4FC3F7).withValues(alpha: 0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF4FC3F7).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            tag,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF0277BD),
                            ),
                          ),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () => _removeTag(tag),
                            child: Icon(
                              CupertinoIcons.xmark,
                              size: 14,
                              color: const Color(
                                0xFF0277BD,
                              ).withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isNotEmpty && !widget.tags.contains(tag)) {
      final newTags = List<String>.from(widget.tags)..add(tag);
      widget.onChanged(newTags);
      _tagController.clear();
    }
  }

  void _removeTag(String tag) {
    final newTags = List<String>.from(widget.tags)..remove(tag);
    widget.onChanged(newTags);
  }
}
