# Prvin 数据模型文档

## 概述

本文档描述了Prvin应用中的核心数据模型，包括任务管理、番茄钟会话、日历事件和AI分析数据。

## 核心数据模型

### 1. TaskModel (任务模型)

**位置**: `lib/features/tasks/data/models/task_model.dart`

**功能**: 表示用户的任务和待办事项

**主要属性**:
- `id`: 唯一标识符
- `title`: 任务标题
- `description`: 任务描述（可选）
- `startTime`: 开始时间
- `endTime`: 结束时间
- `tags`: 标签列表
- `priority`: 优先级（低、中、高、紧急）
- `status`: 状态（待处理、进行中、已完成、已取消）
- `category`: 分类（工作、个人、健康、学习、社交）

**验证规则**:
- 标题不能为空
- 结束时间必须晚于开始时间
- 创建时间不能晚于更新时间

**特殊方法**:
- `hasTimeConflict()`: 检查与其他任务的时间冲突
- `duration`: 获取任务持续时间
- `isCompleted`: 检查任务是否已完成

### 2. PomodoroSessionModel (番茄钟会话模型)

**位置**: `lib/features/pomodoro/data/models/pomodoro_session_model.dart`

**功能**: 表示番茄钟专注会话

**主要属性**:
- `id`: 唯一标识符
- `startTime`: 开始时间
- `endTime`: 结束时间（可选，进行中的会话为null）
- `plannedDuration`: 计划持续时间
- `actualDuration`: 实际持续时间
- `type`: 会话类型（工作、短休息、长休息）
- `associatedTaskId`: 关联的任务ID（可选）
- `completed`: 是否完成

**验证规则**:
- 计划持续时间必须大于0
- 已完成的会话必须有结束时间且晚于开始时间
- 实际持续时间不能为负数

**特殊方法**:
- `progress`: 获取会话进度（0.0-1.0）
- `remainingTime`: 获取剩余时间
- `isActive`: 检查会话是否进行中
- `isOvertime`: 检查会话是否超时

### 3. CalendarEventModel (日历事件模型)

**位置**: `lib/features/sync/data/models/calendar_event_model.dart`

**功能**: 表示日历事件，支持外部日历服务同步

**主要属性**:
- `id`: 唯一标识符
- `title`: 事件标题
- `description`: 事件描述（可选）
- `startTime`: 开始时间
- `endTime`: 结束时间
- `source`: 事件来源（本地、Google、Outlook、Apple）
- `externalId`: 外部服务的事件ID
- `isAllDay`: 是否全天事件
- `location`: 事件位置（可选）
- `attendees`: 参与者邮箱列表
- `reminders`: 提醒时间列表（分钟）
- `recurrenceRule`: 重复规则（可选）
- `lastSyncAt`: 最后同步时间

**验证规则**:
- 标题不能为空
- 非全天事件的结束时间必须晚于开始时间
- 外部事件必须有外部ID

**特殊方法**:
- `hasTimeConflict()`: 检查与其他事件的时间冲突
- `isExternal`: 检查是否来自外部服务
- `needsSync`: 检查是否需要同步
- `isOngoing`: 检查事件是否正在进行
- `isUpcoming`: 检查事件是否即将开始

### 4. AnalyticsDataModel (分析数据模型)

**位置**: `lib/features/ai/data/models/analytics_data_model.dart`

**功能**: 表示AI分析生成的用户数据洞察

**主要组件**:
- `DateRange`: 日期范围
- `ProductivityTrend`: 生产力趋势
- `FocusPattern`: 专注模式
- `TaskPattern`: 任务模式
- `FocusRecommendation`: 专注建议

**主要属性**:
- `userId`: 用户ID
- `period`: 分析周期
- `timeDistribution`: 时间分配（分类 -> 分钟数）
- `completionRate`: 任务完成率
- `trends`: 生产力趋势列表
- `focusPatterns`: 专注模式列表
- `taskPatterns`: 任务模式列表
- `focusRecommendations`: 专注建议列表

**验证规则**:
- 用户ID不能为空
- 完成率必须在0-1之间
- 时间分配不能有负值
- 生成时间应该合理

**特殊方法**:
- `totalWorkMinutes`: 获取总工作时间
- `mostActiveCategory`: 获取最活跃的任务分类
- `averageDailyCompletedTasks`: 获取平均每日完成任务数
- `bestFocusHours`: 获取最佳专注时间段

## 辅助数据类型

### 请求数据类型

- `TaskCreateRequest`: 任务创建请求
- `TaskUpdateRequest`: 任务更新请求

### 错误和警告类型

- `ConflictWarning`: 冲突警告（时间冲突、资源冲突、同步冲突）

## 序列化支持

所有数据模型都支持JSON序列化和反序列化：
- 使用`json_annotation`包进行代码生成
- 提供`fromJson()`和`toJson()`方法
- 支持复杂嵌套对象的序列化

## 数据验证

每个数据模型都包含`isValid()`方法：
- 验证必填字段
- 检查数据逻辑一致性
- 确保业务规则合规性

## 测试覆盖

- 单元测试：验证具体功能和边界情况
- 属性测试：验证通用属性和随机数据
- 集成测试：验证模型间的交互

## 使用示例

```dart
// 创建任务
final task = TaskModel(
  id: uuid.v4(),
  title: '完成项目报告',
  startTime: DateTime.now(),
  endTime: DateTime.now().add(Duration(hours: 2)),
  tags: ['工作', '重要'],
  priority: TaskPriority.high,
  status: TaskStatus.pending,
  category: TaskCategory.work,
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);

// 验证任务
if (task.isValid()) {
  // 保存任务
}

// 检查时间冲突
if (task.hasTimeConflict(otherTask)) {
  // 处理冲突
}

// 序列化
final json = task.toJson();
final taskFromJson = TaskModel.fromJson(json);
```

## 扩展性

数据模型设计考虑了未来扩展：
- 使用枚举类型便于添加新选项
- 元数据字段支持自定义属性
- 版本化序列化支持数据迁移
- 插件化架构支持新功能集成