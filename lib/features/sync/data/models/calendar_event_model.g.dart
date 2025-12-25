// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_event_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CalendarEventModel _$CalendarEventModelFromJson(Map<String, dynamic> json) =>
    CalendarEventModel(
      id: json['id'] as String,
      title: json['title'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      source: $enumDecode(_$EventSourceEnumMap, json['source']),
      isAllDay: json['isAllDay'] as bool,
      attendees: (json['attendees'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      reminders: (json['reminders'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      description: json['description'] as String?,
      externalId: json['externalId'] as String?,
      location: json['location'] as String?,
      recurrenceRule: json['recurrenceRule'] as String?,
      lastSyncAt: json['lastSyncAt'] == null
          ? null
          : DateTime.parse(json['lastSyncAt'] as String),
    );

Map<String, dynamic> _$CalendarEventModelToJson(CalendarEventModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'startTime': instance.startTime.toIso8601String(),
      'endTime': instance.endTime.toIso8601String(),
      'source': _$EventSourceEnumMap[instance.source]!,
      'externalId': instance.externalId,
      'isAllDay': instance.isAllDay,
      'location': instance.location,
      'attendees': instance.attendees,
      'reminders': instance.reminders,
      'recurrenceRule': instance.recurrenceRule,
      'metadata': instance.metadata,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'lastSyncAt': instance.lastSyncAt?.toIso8601String(),
    };

const _$EventSourceEnumMap = {
  EventSource.local: 'local',
  EventSource.googleCalendar: 'googleCalendar',
  EventSource.outlook: 'outlook',
  EventSource.apple: 'apple',
};
