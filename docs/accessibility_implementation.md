# 一键语言切换按钮可访问性实现

## 概述

为一键语言切换按钮添加了完整的可访问性支持，确保所有用户都能有效使用该功能。

## 实现的功能

### 1. 语义标签和描述 (Semantics Labels)

- **标签**: "语言切换按钮"
- **提示**: 动态显示当前语言和切换目标，例如："当前语言：中文，点击切换到English"
- **值**: 显示当前语言标识（"中" 或 "EN"）
- **属性**: 
  - `button: true` - 标识为按钮
  - `enabled: true` - 标识为可用状态
  - `focusable: true` - 标识为可获得焦点

### 2. 屏幕阅读器支持

- 使用 `SemanticsService.announce()` 向屏幕阅读器发送消息
- 语言切换成功后自动播报切换结果
- 焦点获得时播报按钮状态

### 3. 键盘导航支持

- **Tab键**: 支持Tab键导航到按钮
- **空格键**: 按空格键触发语言切换
- **回车键**: 按回车键触发语言切换
- **焦点指示器**: 获得焦点时显示明显的视觉指示器

### 4. 高对比度模式支持

- 检测系统高对比度设置 (`MediaQuery.highContrast`)
- 高对比度模式下调整颜色方案：
  - 使用黑白对比色替代彩色
  - 增加边框宽度（2-3px）
  - 增强文字粗细（FontWeight.w900）
  - 禁用装饰性效果（光晕、阴影）
  - 增大状态指示器尺寸

## 技术实现

### 核心组件结构

```dart
Semantics(
  label: '语言切换按钮',
  hint: '当前语言：$currentLanguageName，点击切换到$nextLanguageName',
  value: languageState.display,
  button: true,
  enabled: true,
  focusable: true,
  onTap: () => _toggleLanguage(context),
  child: Focus(
    focusNode: _focusNode,
    onKeyEvent: _handleKeyEvent,
    child: // 按钮UI
  ),
)
```

### 键盘事件处理

```dart
KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
  if (event is KeyDownEvent) {
    if (event.logicalKey == LogicalKeyboardKey.space ||
        event.logicalKey == LogicalKeyboardKey.enter) {
      _toggleLanguage(context);
      return KeyEventResult.handled;
    }
  }
  return KeyEventResult.ignored;
}
```

### 高对比度检测

```dart
bool _isHighContrastMode(BuildContext context) {
  final mediaQuery = MediaQuery.of(context);
  return mediaQuery.highContrast;
}
```

## 测试验证

创建了专门的可访问性测试文件 `test/core/widgets/accessibility_test.dart`，验证：

1. ✅ 语义标签正确设置
2. ✅ 键盘导航功能
3. ✅ 焦点管理
4. ✅ 高对比度模式支持

## 符合标准

实现符合以下可访问性标准：

- **WCAG 2.1 AA级别**
- **Flutter可访问性指南**
- **Material Design可访问性规范**

## 用户体验改进

1. **视觉障碍用户**: 通过屏幕阅读器获得完整的功能描述和状态反馈
2. **运动障碍用户**: 可以使用键盘完全操作，无需鼠标
3. **视力不佳用户**: 高对比度模式提供更好的视觉对比度
4. **认知障碍用户**: 清晰的语义标签和一致的交互模式

## 未来扩展

- 支持更多键盘快捷键
- 添加语音提示功能
- 支持更多辅助技术
- 国际化可访问性标签