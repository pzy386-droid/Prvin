import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'calendar_event_model.g.dart';

/// 事件来源枚举
enum EventSource {
  @JsonValue('local')
  local,
  @JsonValue('googleCalendar')
  googleCalendar,
  @JsonValue('outlook')
  outlook,
  @JsonValue('apple')
  apple,
}

/// 日历事件数据模型
@JsonSerializable()
class CalendarEventModel extends Equatable {
  const CalendarEventModel({
    required this.id,
    required this.title,
    this.description,
    required this.startTime,
    required this.endTime,
    required this.source,
    this.externalId,
    required this.isAllDay,
    this.location,
    required this.attendees,
    required this.reminders,
    this.recurrenceRule,
    required this.metadata,
    required this.createdAt,
    required this.updatedAt,
    this.lastSyncAt,
  });

  /// 从JSON创建CalendarEventModel
  factory CalendarEventModel.fromJson(Map<String, dynamic> json) =>
      _$CalendarEventModelFromJson(json);

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

  /// 事件来源
  final EventSource source;

  /// 外部服务的事件ID
  final String? externalId;

  /// 是否全天事件
  final bool isAllDay;

  /// 事件位置
  final String? location;

  /// 参与者邮箱列表
  final List<String> attendees;

  /// 提醒时间（分钟）
  final List<int> reminders;

  /// 重复规则
  final String? recurrenceRule;

  /// 元数据
  final Map<String, dynamic> metadata;

  /// 创建时间
  final DateTime createdAt;

  /// 更新时间
  final DateTime updatedAt;

  /// 最后同步时间
  final DateTime? lastSyncAt;

  /// 转换为JSON
  Map<String, dynamic> toJson() => _$CalendarEventModelToJson(this);

  /// 数据验证
  bool isValid() {
    // 标题不能为空
    if (title.trim().isEmpty) return false;

    // 对于非全天事件，结束时间必须晚于开始时间
    if (!isAllDay && endTime.isBefore(startTime)) return false;

    // 对于全天事件，结束时间应该是开始时间的同一天或之后
    if (isAllDay && endTime.isBefore(startTime)) return false;

    // 创建时间不能晚于更新时间
    if (createdAt.isAfter(updatedAt)) return false;

    // 外部事件必须有外部ID
    if (source != EventSource.local &&
        (externalId == null || externalId!.isEmpty)) {
      return false;
    }

    return true;
  }

  /// 检查事件是否与另一个事件时间冲突
  bool hasTimeConflict(CalendarEventModel other) {
    return startTime.isBefore(other.endTime) &&
        endTime.isAfter(other.startTime);
  }

  /// 获取事件持续时间
  Duration get duration => endTime.difference(startTime);

  /// 检查事件是否来自外部服务
  bool get isExternal => source != EventSource.local;

  /// 检查事件是否需要同步
  bool get needsSync {
    if (!isExternal) return false;
    if (lastSyncAt == null) return true;
    return updatedAt.isAfter(lastSyncAt!);
  }

  /// 检查事件是否正在进行
  bool get isOngoing {
    final now = DateTime.now();
    return now.isAfter(startTime) && now.isBefore(endTime);
  }

  /// 检查事件是否即将开始（15分钟内）
  bool get isUpcoming {
    final now = DateTime.now();
    final fifteenMinutesLater = now.add(const Duration(minutes: 15));
    return startTime.isAfter(now) && startTime.isBefore(fifteenMinutesLater);
  }

  /// 复制并更新事件
  CalendarEventModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    EventSource? source,
    String? externalId,
    bool? isAllDay,
    String? location,
    List<String>? attendees,
    List<int>? reminders,
    String? recurrenceRule,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSyncAt,
  }) {
    return CalendarEventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      source: source ?? this.source,
      externalId: externalId ?? this.externalId,
      isAllDay: isAllDay ?? this.isAllDay,
      location: location ?? this.location,
      attendees: attendees ?? this.attendees,
      reminders: reminders ?? this.reminders,
      recurrenceRule: recurrenceRule ?? this.recurrenceRule,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    startTime,
    endTime,
    source,
    externalId,
    isAllDay,
    location,
    attendees,
    reminders,
    recurrenceRule,
    metadata,
    createdAt,
    updatedAt,
    lastSyncAt,
  ];
}
