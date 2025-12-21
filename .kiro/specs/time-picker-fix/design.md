# 时间选择器层级修复设计文档

## 概述

本设计文档描述了如何解决任务创建浮层中时间选择器被阻挡的问题。当前的实现中，虽然使用了`useRootNavigator: true`参数，但时间选择器仍然无法正常显示。我们需要采用更可靠的解决方案来确保时间选择器能够正确显示在最顶层。

## 架构

### 当前问题分析

1. **层级冲突**: 任务创建浮层使用`showDialog`显示，时间选择器也使用`showTimePicker`，两者可能存在层级冲突
2. **Context问题**: 时间选择器使用的context可能不是正确的根context
3. **Navigator栈问题**: 多个Navigator可能导致层级管理混乱

### 解决方案架构

我们将采用以下架构来解决问题：

1. **使用Overlay直接管理**: 绕过Dialog系统，直接使用Overlay来显示任务创建浮层
2. **全局Context管理**: 确保时间选择器使用应用的根context
3. **层级优先级设置**: 明确设置各组件的层级优先级

## 组件和接口

### 1. OverlayTaskCreator
新的任务创建组件，使用Overlay而不是Dialog：

```dart
class OverlayTaskCreator {
  static OverlayEntry? _overlayEntry;
  
  static void show(BuildContext context, {DateTime? initialDate}) {
    // 使用Overlay显示任务创建界面
  }
  
  static void hide() {
    // 隐藏任务创建界面
  }
}
```

### 2. RootTimePicker
专门的时间选择器包装器，确保使用根Navigator：

```dart
class RootTimePicker {
  static Future<TimeOfDay?> show(
    BuildContext context, {
    required TimeOfDay initialTime,
  }) {
    // 获取根context并显示时间选择器
  }
}
```

### 3. LayerManager
层级管理器，统一管理所有浮层组件的层级：

```dart
class LayerManager {
  static const int taskOverlayLevel = 100;
  static const int timePickerLevel = 200;
  
  static void showWithLevel(Widget widget, int level) {
    // 按层级显示组件
  }
}
```

## 数据模型

### TimePickerState
时间选择器的状态管理：

```dart
class TimePickerState {
  final bool isVisible;
  final TimeOfDay? selectedTime;
  final String? errorMessage;
  
  const TimePickerState({
    this.isVisible = false,
    this.selectedTime,
    this.errorMessage,
  });
}
```

## 正确性属性

*A property is a characteristic or behavior that should hold true across all valid executions of a system-essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Property 1: 时间选择器层级优先
*For any* 时间选择器显示请求，时间选择器应该显示在所有其他组件之上，包括任务创建浮层
**Validates: Requirements 1.3**

### Property 2: 时间按钮响应性
*For any* 时间按钮点击事件，系统应该立即显示时间选择器且不被其他组件阻挡
**Validates: Requirements 1.1, 1.2, 3.1**

### Property 3: 时间状态同步
*For any* 时间选择操作，选择的时间应该正确更新到对应的时间字段，且浮层状态保持不变
**Validates: Requirements 1.4, 3.2, 3.3**

### Property 4: 取消操作状态保持
*For any* 时间选择取消操作，系统应该关闭时间选择器并保持任务创建浮层的所有状态不变
**Validates: Requirements 1.5, 3.3**

### Property 5: 主题色彩一致性
*For any* 时间选择器显示，应该使用应用的主题色彩（#4FC3F7）
**Validates: Requirements 2.1**

### Property 6: 背景遮罩效果
*For any* 时间选择器显示，应该提供适当的背景遮罩效果
**Validates: Requirements 2.3**

### Property 7: 错误处理机制
*For any* 时间选择过程中的错误，系统应该显示清晰的错误提示信息并提供恢复机制
**Validates: Requirements 3.4, 4.4**

### Property 8: Navigator层级管理
*For any* 层级管理操作，系统应该正确使用Navigator的层级管理机制
**Validates: Requirements 4.2**

### Property 9: 状态管理一致性
*For any* 时间状态操作，系统应该确保时间状态的正确更新和同步
**Validates: Requirements 4.3**

## 错误处理

### 1. 层级冲突处理
- 检测层级冲突并自动调整
- 提供降级方案（如使用全屏Dialog）

### 2. Context错误处理
- 验证context的有效性
- 提供context获取失败的备用方案

### 3. 时间选择错误处理
- 处理时间选择器显示失败
- 处理时间格式错误
- 处理时间范围验证错误

## 测试策略

### 单元测试
- 测试OverlayTaskCreator的显示和隐藏功能
- 测试RootTimePicker的时间选择功能
- 测试LayerManager的层级管理功能

### 集成测试
- 测试任务创建浮层与时间选择器的交互
- 测试不同屏幕尺寸下的显示效果
- 测试多次打开关闭的内存泄漏问题

### 属性测试
- 使用Flutter的widget测试框架验证所有正确性属性
- 生成随机的时间选择场景进行测试
- 验证在各种设备和屏幕配置下的行为一致性

### 用户验收测试
- 验证用户可以在不关闭浮层的情况下选择时间
- 验证时间选择器的视觉效果和交互体验
- 验证错误场景下的用户体验