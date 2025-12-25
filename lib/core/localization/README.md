# Prvin 语言切换功能使用指南

## 概述

本项目采用最小化、非侵入式的语言切换方案，支持中文和英文两种语言。该方案的核心优势是：

- ✅ **零破坏性**：不修改现有组件的接口和逻辑
- ✅ **渐进式**：可以逐步迁移，新旧代码共存
- ✅ **轻量级**：最小化依赖和复杂度
- ✅ **向后兼容**：现有硬编码文本继续工作

## 文件结构

```
lib/core/localization/
├── app_strings.dart           # 字符串常量定义（中英文映射）
├── app_localizations.dart     # 本地化服务核心
├── localization_exports.dart  # 统一导出文件
└── README.md                  # 本文档
```

## 快速开始

### 1. 在Widget中使用本地化

#### 方式一：使用BuildContext扩展（推荐）

```dart
import 'package:prvin/core/localization/localization_exports.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text(
      context.l10n('app_name'),  // 自动根据当前语言返回对应文本
    );
  }
}
```

#### 方式二：使用AppLocalizations直接调用

```dart
import 'package:prvin/core/localization/localization_exports.dart';

Text(AppLocalizations.get('app_name'))
```

#### 方式三：带fallback的使用（推荐用于迁移）

```dart
// 如果找不到对应的翻译，会使用fallback文本
Text(context.l10n('some_key', fallback: '默认文本'))
```

### 2. 切换语言

#### 在UI中使用语言切换组件

```dart
import 'package:prvin/core/widgets/language_switcher.dart';

// 完整的语言切换器
LanguageSwitcher()

// 紧凑模式（下拉菜单）
LanguageSwitcher(compact: true)

// 显示语言切换对话框
LanguageSwitcherDialog.show(context)
```

#### 编程方式切换语言

```dart
// 方式一：使用BuildContext扩展
context.changeLanguage('en');

// 方式二：使用AppLocalizations
AppLocalizations.changeLanguage(context, 'en');

// 方式三：直接使用BLoC
context.read<AppBloc>().add(AppLanguageChangedEvent('en'));
```

### 3. 添加新的翻译字符串

在 `app_strings.dart` 中添加新的键值对：

```dart
static const Map<String, Map<String, String>> _localizedValues = {
  'zh': {
    'my_new_key': '我的新文本',
    // ... 其他中文翻译
  },
  'en': {
    'my_new_key': 'My New Text',
    // ... 其他英文翻译
  },
};
```

## 渐进式迁移策略

### 现有代码（继续工作）
```dart
Text('日历')  // ✅ 继续正常显示
```

### 新代码（支持多语言）
```dart
Text(context.l10n('calendar', fallback: '日历'))  // ✅ 支持多语言，有fallback
```

### 完全迁移后
```dart
Text(context.l10n('calendar'))  // ✅ 完全使用本地化
```

## 可用的字符串键

### 应用基础
- `app_name` - 应用名称
- `app_subtitle` - 应用副标题

### 导航和标签
- `calendar` - 日历
- `focus` - 专注
- `today` - 今天
- `settings` - 设置

### 按钮文本
- `start` - 开始
- `pause` - 暂停
- `reset` - 重置
- `save` - 保存
- `cancel` - 取消
- `close` - 关闭
- `retry` - 重试
- `edit` - 编辑
- `delete` - 删除

### 任务相关
- `task` - 任务
- `create_task` - 创建任务
- `edit_task` - 编辑任务
- `today_tasks` - 今天的任务
- `no_tasks` - 暂无任务

### 番茄钟相关
- `pomodoro` - 番茄钟
- `focus_time` - 专注时间
- `pomodoro_settings` - 番茄钟设置
- `focus_preparing` - 准备开始专注
- `focus_in_progress` - 专注进行中...
- `focus_completed` - 专注完成！

更多字符串键请查看 `app_strings.dart` 文件。

## 语言持久化

语言选择会自动保存到 SharedPreferences，应用重启后会自动恢复用户的语言偏好。

## 注意事项

1. **性能**：使用简单的Map查找，性能开销极小
2. **Fallback机制**：如果找不到翻译，会依次尝试：
   - 当前语言的翻译
   - 中文翻译（默认）
   - 提供的fallback文本
   - 键名本身
3. **测试**：现有测试继续通过，因为UI文本不变
4. **扩展性**：可以轻松添加更多语言支持

## 示例

查看以下文件了解实际使用：
- `lib/main.dart` - 启动屏幕和错误屏幕的本地化示例
- `lib/integrated_calendar_with_pomodoro.dart` - 语言切换按钮集成示例
- `lib/core/widgets/language_switcher.dart` - 语言切换组件实现

## 技术支持

如有问题，请查看：
- `app_localizations.dart` - 核心实现
- `app_strings.dart` - 所有可用的翻译字符串