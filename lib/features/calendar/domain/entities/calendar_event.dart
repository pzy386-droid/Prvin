import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// 日历事件实体
class CalendarEvent extends Equatable {
  /// 创建日历事件
  const CalendarEvent({
    required this.id,
    required this.title,
    required this.startTime, required this.endTime, required this.color, this.description,
    this.isAllDay = false,
    this.location,
    this.attendees,
    this.reminders,
    this.recurrence,
    this.createdAt,
    this.updatedAt,
  });

  /// 事件ID
  final String id;

  /// 事件标题
  final String title;

  /// 事件描述
  final String? description;

  /// 开始时间
  final DateTime startTime;

  /// 结束时间
  final DateTime endTime;

  /// 事件颜色
  final Color color;

  /// 是否全天事件
  final bool isAllDay;

  /// 地点
  final String? location;

  /// 参与者
  final List<String>? attendees;

  /// 提醒设置
  final List<EventReminder>? reminders;

  /// 重复规则
  final EventRecurrence? recurrence;

  /// 创建时间
  final DateTime? createdAt;

  /// 更新时间
  final DateTime? updatedAt;

  /// 获取事件持续时间
  Duration get duration => endTime.difference(startTime);

  /// 检查是否与另一个事件时间冲突
  bool conflictsWith(CalendarEvent other) {
    if (isAllDay || other.isAllDay) {
      return _isSameDay(startTime, other.startTime);
    }

    return startTime.isBefore(other.endTime) &&
        endTime.isAfter(other.startTime);
  }

  /// 检查事件是否在指定日期
  bool isOnDate(DateTime date) {
    if (isAllDay) {
      return _isSameDay(startTime, date);
    }

    return startTime.year == date.year &&
        startTime.month == date.month &&
        startTime.day == date.day;
  }

  /// 获取格式化的时间字符串
  String getTimeString() {
    if (isAllDay) {
      return '全天';
    }

    final startStr =
        '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
    final endStr =
        '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';

    return '$startStr - $endStr';
  }

  /// 获取格式化的日期字符串
  String getDateString() {
    return '${startTime.month}月${startTime.day}日';
  }

  /// 复制事件并更新指定字段
  CalendarEvent copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    Color? color,
    bool? isAllDay,
    String? location,
    List<String>? attendees,
    List<EventReminder>? reminders,
    EventRecurrence? recurrence,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CalendarEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      color: color ?? this.color,
      isAllDay: isAllDay ?? this.isAllDay,
      location: location ?? this.location,
      attendees: attendees ?? this.attendees,
      reminders: reminders ?? this.reminders,
      recurrence: recurrence ?? this.recurrence,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    startTime,
    endTime,
    color,
    isAllDay,
    location,
    attendees,
    reminders,
    recurrence,
    createdAt,
    updatedAt,
  ];
}

/// 事件提醒
class EventReminder extends Equatable {
  /// 创建事件提醒
  const EventReminder({
    required this.minutes,
    this.method = ReminderMethod.notification,
  });

  /// 提前多少分钟提醒
  final int minutes;

  /// 提醒方式
  final ReminderMethod method;

  /// 获取提醒描述
  String get description {
    if (minutes == 0) return '事件开始时';
    if (minutes < 60) return '$minutes分钟前';
    if (minutes < 1440) return '${minutes ~/ 60}小时前';
    return '${minutes ~/ 1440}天前';
  }

  @override
  List<Object?> get props => [minutes, method];
}

/// 提醒方式枚举
enum ReminderMethod {
  /// 通知
  notification,

  /// 邮件
  email,

  /// 短信
  sms,
}

/// 事件重复规则
class EventRecurrence extends Equatable {
  /// 创建重复规则
  const EventRecurrence({
    required this.frequency,
    this.interval = 1,
    this.endDate,
    this.count,
    this.byWeekDay,
    this.byMonthDay,
  });

  /// 重复频率
  final RecurrenceFrequency frequency;

  /// 间隔
  final int interval;

  /// 结束日期
  final DateTime? endDate;

  /// 重复次数
  final int? count;

  /// 按星期几重复（仅当频率为weekly时有效）
  final List<int>? byWeekDay;

  /// 按月份中的第几天重复（仅当频率为monthly时有效）
  final List<int>? byMonthDay;

  /// 获取重复描述
  String get description {
    switch (frequency) {
      case RecurrenceFrequency.daily:
        return interval == 1 ? '每天' : '每$interval天';
      case RecurrenceFrequency.weekly:
        return interval == 1 ? '每周' : '每$interval周';
      case RecurrenceFrequency.monthly:
        return interval == 1 ? '每月' : '每$interval月';
      case RecurrenceFrequency.yearly:
        return interval == 1 ? '每年' : '每$interval年';
    }
  }

  @override
  List<Object?> get props => [
    frequency,
    interval,
    endDate,
    count,
    byWeekDay,
    byMonthDay,
  ];
}

/// 重复频率枚举
enum RecurrenceFrequency {
  /// 每天
  daily,

  /// 每周
  weekly,

  /// 每月
  monthly,

  /// 每年
  yearly,
}
