// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pomodoro_session_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PomodoroSessionModel _$PomodoroSessionModelFromJson(
  Map<String, dynamic> json,
) => PomodoroSessionModel(
  id: json['id'] as String,
  startTime: DateTime.parse(json['startTime'] as String),
  plannedDuration: Duration(
    microseconds: (json['plannedDuration'] as num).toInt(),
  ),
  actualDuration: Duration(
    microseconds: (json['actualDuration'] as num).toInt(),
  ),
  type: $enumDecode(_$SessionTypeEnumMap, json['type']),
  completed: json['completed'] as bool,
  createdAt: DateTime.parse(json['createdAt'] as String),
  endTime: json['endTime'] == null
      ? null
      : DateTime.parse(json['endTime'] as String),
  associatedTaskId: json['associatedTaskId'] as String?,
);

Map<String, dynamic> _$PomodoroSessionModelToJson(
  PomodoroSessionModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'startTime': instance.startTime.toIso8601String(),
  'endTime': instance.endTime?.toIso8601String(),
  'plannedDuration': instance.plannedDuration.inMicroseconds,
  'actualDuration': instance.actualDuration.inMicroseconds,
  'type': _$SessionTypeEnumMap[instance.type]!,
  'associatedTaskId': instance.associatedTaskId,
  'completed': instance.completed,
  'createdAt': instance.createdAt.toIso8601String(),
};

const _$SessionTypeEnumMap = {
  SessionType.work: 'work',
  SessionType.shortBreak: 'short_break',
  SessionType.longBreak: 'long_break',
};
