import 'package:equatable/equatable.dart';

/// 冲突警告类型枚举
enum ConflictType {
  /// 时间冲突
  timeConflict,

  /// 资源冲突
  resourceConflict,

  /// 数据同步冲突
  syncConflict,
}

/// 冲突严重程度枚举
enum ConflictSeverity {
  /// 低级警告
  low,

  /// 中级警告
  medium,

  /// 高级警告
  high,

  /// 严重错误
  critical,
}

/// 冲突警告数据模型
class ConflictWarning extends Equatable {

  const ConflictWarning({
    required this.id,
    required this.type,
    required this.severity,
    required this.message,
    required this.conflictingIds,
    required this.suggestions,
    required this.createdAt,
  });
  /// 冲突ID
  final String id;

  /// 冲突类型
  final ConflictType type;

  /// 严重程度
  final ConflictSeverity severity;

  /// 警告消息
  final String message;

  /// 冲突的任务/事件ID列表
  final List<String> conflictingIds;

  /// 建议的解决方案
  final List<String> suggestions;

  /// 创建时间
  final DateTime createdAt;

  /// 检查是否为严重冲突
  bool get isCritical => severity == ConflictSeverity.critical;

  /// 检查是否为时间冲突
  bool get isTimeConflict => type == ConflictType.timeConflict;

  @override
  List<Object?> get props => [
    id,
    type,
    severity,
    message,
    conflictingIds,
    suggestions,
    createdAt,
  ];
}
