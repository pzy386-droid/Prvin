import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:prvin/core/theme/ios_theme.dart';
import 'package:prvin/features/calendar/domain/entities/calendar_event.dart';

/// 事件添加/编辑底部弹窗
class EventBottomSheet extends StatefulWidget {
  const EventBottomSheet({
    required this.selectedDate, super.key,
    this.existingEvent,
    this.onEventAdded,
    this.onEventUpdated,
    this.onEventDeleted,
  });

  final DateTime selectedDate;
  final CalendarEvent? existingEvent;
  final Function(CalendarEvent)? onEventAdded;
  final Function(CalendarEvent)? onEventUpdated;
  final Function(String)? onEventDeleted;

  @override
  State<EventBottomSheet> createState() => _EventBottomSheetState();
}

class _EventBottomSheetState extends State<EventBottomSheet>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  DateTime? _startTime;
  DateTime? _endTime;
  bool _isAllDay = false;
  Color _selectedColor = IOSTheme.primaryBlue;

  final List<Color> _eventColors = [
    IOSTheme.primaryBlue,
    IOSTheme.systemRed,
    IOSTheme.systemOrange,
    IOSTheme.systemYellow,
    IOSTheme.systemGreen,
    IOSTheme.systemTeal,
    IOSTheme.systemIndigo,
    IOSTheme.systemPurple,
    IOSTheme.systemPink,
  ];

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: IOSTheme.normalAnimation,
      vsync: this,
    );

    _titleController = TextEditingController();
    _descriptionController = TextEditingController();

    if (widget.existingEvent != null) {
      _titleController.text = widget.existingEvent!.title;
      _descriptionController.text = widget.existingEvent!.description ?? '';
      _startTime = widget.existingEvent!.startTime;
      _endTime = widget.existingEvent!.endTime;
      _isAllDay = widget.existingEvent!.isAllDay;
      _selectedColor = widget.existingEvent!.color;
    } else {
      _startTime = DateTime(
        widget.selectedDate.year,
        widget.selectedDate.month,
        widget.selectedDate.day,
        DateTime.now().hour + 1,
      );
      _endTime = _startTime!.add(const Duration(hours: 1));
    }

    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IOSAnimations.slideIn(
      controller: _slideController,
      begin: const Offset(0, 1),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: IOSTheme.systemBackground,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(IOSTheme.cardCornerRadius),
          ),
        ),
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(IOSTheme.spacing16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTitleField(),
                    const SizedBox(height: IOSTheme.spacing20),
                    _buildDescriptionField(),
                    const SizedBox(height: IOSTheme.spacing20),
                    _buildAllDayToggle(),
                    const SizedBox(height: IOSTheme.spacing20),
                    if (!_isAllDay) ...[
                      _buildTimeSection(),
                      const SizedBox(height: IOSTheme.spacing20),
                    ],
                    _buildColorSection(),
                    const SizedBox(height: IOSTheme.spacing32),
                    if (widget.existingEvent != null) _buildDeleteButton(),
                  ],
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
      padding: const EdgeInsets.all(IOSTheme.spacing16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: IOSTheme.systemGray5, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          const Spacer(),
          Text(
            widget.existingEvent != null ? '编辑事件' : '新建事件',
            style: IOSTheme.headline,
          ),
          const Spacer(),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: _saveEvent,
            child: Text(
              '保存',
              style: IOSTheme.body.copyWith(fontWeight: FontWeight.w600),
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
        const Text('标题', style: IOSTheme.headline),
        const SizedBox(height: IOSTheme.spacing8),
        CupertinoTextField(
          controller: _titleController,
          placeholder: '输入事件标题',
          style: IOSTheme.body,
          decoration: BoxDecoration(
            color: IOSTheme.tertiarySystemBackground,
            borderRadius: BorderRadius.circular(IOSTheme.cornerRadius),
          ),
          padding: const EdgeInsets.all(IOSTheme.spacing12),
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('描述', style: IOSTheme.headline),
        const SizedBox(height: IOSTheme.spacing8),
        CupertinoTextField(
          controller: _descriptionController,
          placeholder: '添加描述（可选）',
          style: IOSTheme.body,
          maxLines: 3,
          decoration: BoxDecoration(
            color: IOSTheme.tertiarySystemBackground,
            borderRadius: BorderRadius.circular(IOSTheme.cornerRadius),
          ),
          padding: const EdgeInsets.all(IOSTheme.spacing12),
        ),
      ],
    );
  }

  Widget _buildAllDayToggle() {
    return Row(
      children: [
        const Text('全天', style: IOSTheme.headline),
        const Spacer(),
        CupertinoSwitch(
          value: _isAllDay,
          onChanged: (value) {
            setState(() {
              _isAllDay = value;
              if (value) {
                _startTime = DateTime(
                  widget.selectedDate.year,
                  widget.selectedDate.month,
                  widget.selectedDate.day,
                );
                _endTime = _startTime!.add(const Duration(days: 1));
              }
            });
          },
        ),
      ],
    );
  }

  Widget _buildTimeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('时间', style: IOSTheme.headline),
        const SizedBox(height: IOSTheme.spacing12),
        _buildTimeRow('开始', _startTime!, (time) {
          setState(() {
            _startTime = time;
            if (_endTime!.isBefore(_startTime!)) {
              _endTime = _startTime!.add(const Duration(hours: 1));
            }
          });
        }),
        const SizedBox(height: IOSTheme.spacing8),
        _buildTimeRow('结束', _endTime!, (time) {
          setState(() {
            _endTime = time;
          });
        }),
      ],
    );
  }

  Widget _buildTimeRow(
    String label,
    DateTime time,
    Function(DateTime) onChanged,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: IOSTheme.tertiarySystemBackground,
        borderRadius: BorderRadius.circular(IOSTheme.cornerRadius),
      ),
      child: CupertinoButton(
        padding: const EdgeInsets.all(IOSTheme.spacing12),
        onPressed: () => _showTimePicker(time, onChanged),
        child: Row(
          children: [
            Text(label, style: IOSTheme.body),
            const Spacer(),
            Text(
              _formatTime(time),
              style: IOSTheme.body.copyWith(color: IOSTheme.primaryBlue),
            ),
            const SizedBox(width: IOSTheme.spacing8),
            const Icon(
              CupertinoIcons.chevron_right,
              color: IOSTheme.systemGray2,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('颜色', style: IOSTheme.headline),
        const SizedBox(height: IOSTheme.spacing12),
        Wrap(
          spacing: IOSTheme.spacing12,
          runSpacing: IOSTheme.spacing12,
          children: _eventColors.map((color) {
            final isSelected = color == _selectedColor;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedColor = color;
                });
              },
              child: AnimatedContainer(
                duration: IOSTheme.fastAnimation,
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: isSelected
                      ? Border.all(color: Colors.white, width: 3)
                      : null,
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: color.withValues(alpha: 0.5),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: isSelected
                    ? const Icon(
                        CupertinoIcons.check_mark,
                        color: Colors.white,
                        size: 20,
                      )
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDeleteButton() {
    return SizedBox(
      width: double.infinity,
      child: CupertinoButton(
        color: IOSTheme.systemRed,
        onPressed: _deleteEvent,
        child: const Text('删除事件'),
      ),
    );
  }

  void _showTimePicker(DateTime initialTime, Function(DateTime) onChanged) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 300,
        color: IOSTheme.systemBackground,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(IOSTheme.spacing16),
              child: Row(
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.pop(context),
                    child: const Text('取消'),
                  ),
                  const Spacer(),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.pop(context),
                    child: const Text('确定'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoDatePicker(
                initialDateTime: initialTime,
                onDateTimeChanged: onChanged,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.month}月${time.day}日 ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  void _saveEvent() {
    if (_titleController.text.trim().isEmpty) {
      _showAlert('请输入事件标题');
      return;
    }

    final event = CalendarEvent(
      id:
          widget.existingEvent?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      startTime: _startTime!,
      endTime: _endTime!,
      color: _selectedColor,
      isAllDay: _isAllDay,
    );

    if (widget.existingEvent != null) {
      widget.onEventUpdated?.call(event);
    } else {
      widget.onEventAdded?.call(event);
    }

    Navigator.pop(context);
  }

  void _deleteEvent() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('删除事件'),
        content: const Text('确定要删除这个事件吗？此操作无法撤销。'),
        actions: [
          CupertinoDialogAction(
            child: const Text('取消'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('删除'),
            onPressed: () {
              Navigator.pop(context);
              widget.onEventDeleted?.call(widget.existingEvent!.id);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showAlert(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('提示'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('确定'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
