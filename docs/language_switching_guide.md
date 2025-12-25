# 语言切换功能使用指南 / Language Switching Guide

## 概述 / Overview

Prvin AI日历应用现已支持中英文双语切换功能，提供无缝的多语言用户体验。新增的一键语言切换功能让语言切换变得更加快速和直观。

The Prvin AI Calendar app now supports bilingual switching between Chinese and English, providing a seamless multilingual user experience. The new one-click language toggle feature makes language switching faster and more intuitive.

## 功能特性 / Features

### ✅ 已实现功能 / Implemented Features

1. **一键语言切换** / One-Click Language Toggle
   - 点击按钮即可在中英文之间快速切换
   - Click button to quickly switch between Chinese and English
   - 无需对话框确认，即时切换
   - No dialog confirmation needed, instant switching

2. **运行时语言切换** / Runtime Language Switching
   - 无需重启应用即可切换语言
   - Switch languages without restarting the app

3. **持久化存储** / Persistent Storage
   - 语言偏好自动保存到本地存储
   - Language preferences automatically saved to local storage

4. **完整的本地化支持** / Complete Localization Support
   - 80+ 字符串已本地化
   - 80+ strings localized
   - 支持中文和英文
   - Supports Chinese and English

5. **智能状态管理** / Intelligent State Management
   - 语言切换不影响其他应用状态
   - Language switching doesn't affect other app states
   - 完整的错误处理和恢复机制
   - Complete error handling and recovery mechanisms

6. **优雅的UI组件** / Elegant UI Components
   - 一键切换按钮（显示当前语言）
   - One-click toggle button (shows current language)
   - 传统语言切换器（地球图标 + 对话框）
   - Traditional language switcher (globe icon + dialog)
   - 完整的可访问性支持
   - Full accessibility support

## 使用方法 / Usage

### 1. 一键语言切换 / One-Click Language Toggle

#### 推荐方式：一键切换按钮 / Recommended: One-Click Toggle Button
1. 在日历页面，找到显示当前语言的按钮（"中" 或 "EN"）
2. 点击按钮即可立即切换到另一种语言
3. 按钮会自动更新显示新的语言状态

1. On the calendar page, find the button showing current language ("中" or "EN")
2. Click the button to immediately switch to the other language
3. Button automatically updates to show the new language state

**特点 / Features:**
- ⚡ 即时切换，无延迟 / Instant switching, no delay
- 🎯 一键操作，无需确认 / One-click operation, no confirmation needed
- 📱 直观显示当前语言状态 / Intuitive display of current language state
- ♿ 完整的可访问性支持 / Full accessibility support

#### 传统方式：语言切换器 / Traditional: Language Switcher
1. 在日历页面，点击右上角的地球图标 🌐
2. 在弹出的对话框中选择您想要的语言（中文/English）
3. 语言将立即切换

1. On the calendar page, tap the globe icon 🌐 in the top right
2. Select your desired language (中文/English) in the popup dialog
3. Language will switch immediately

### 2. 程序化切换 / Programmatic Switching

#### 使用一键切换API / Using One-Click Toggle API
```dart
// 在任何Widget中使用一键切换
await context.toggleLanguage();

// 或者使用扩展方法
await AppLocalizationsToggle.toggleLanguage(context);
```

#### 使用传统切换API / Using Traditional Switch API
```dart
// 切换到指定语言
context.changeLanguage('en'); // 切换到英文
context.changeLanguage('zh'); // 切换到中文

// 或者直接使用AppLocalizations
AppLocalizations.changeLanguage(context, 'en');
```

### 2. 获取本地化文本 / Get Localized Text

#### 使用扩展方法 / Using Extension Method
```dart
Text(context.l10n('app_name', fallback: '默认文本'))
```

#### 直接使用AppLocalizations / Direct AppLocalizations Usage
```dart
Text(AppLocalizations.get('app_name', fallback: '默认文本'))
```

### 3. 一键切换按钮集成 / One-Click Toggle Button Integration

#### 基本使用 / Basic Usage
```dart
import 'package:prvin/core/widgets/one_click_language_toggle_button.dart';

// 在任何页面中添加一键切换按钮
OneClickLanguageToggleButton()

// 自定义尺寸和动画
OneClickLanguageToggleButton(
  size: 48.0,
  animationDuration: Duration(milliseconds: 400),
)
```

#### 获取切换统计信息 / Get Toggle Statistics
```dart
// 获取切换统计
final stats = OneClickLanguageToggleButton.getToggleStatistics();
print('切换次数: ${stats.toggleCount}');
print('当前会话ID: ${stats.sessionId}');

// 验证幂等性
final idempotence = OneClickLanguageToggleButton.verifyToggleIdempotence();
print('幂等性验证: ${idempotence.isValid}');

// 获取性能报告
final performance = OneClickLanguageToggleButton.getPerformanceReport();
print('平均响应时间: ${performance.averageResponseTime}ms');
```

## 开发者指南 / Developer Guide

### 一键切换按钮API / One-Click Toggle Button API

#### 核心组件 / Core Components

**OneClickLanguageToggleButton** - 一键语言切换按钮
```dart
class OneClickLanguageToggleButton extends StatefulWidget {
  const OneClickLanguageToggleButton({
    super.key,
    this.size = 40.0,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  /// 按钮尺寸 / Button size
  final double size;
  
  /// 动画持续时间 / Animation duration
  final Duration animationDuration;
}
```

**LanguageToggleState** - 语言状态枚举
```dart
enum LanguageToggleState {
  chinese('zh', '中'),
  english('en', 'EN');
  
  /// 获取下一个语言状态 / Get next language state
  LanguageToggleState get next;
  
  /// 从语言代码创建状态 / Create state from language code
  static LanguageToggleState fromCode(String code);
}
```

**ToggleButtonState** - 按钮状态数据模型
```dart
class ToggleButtonState {
  const ToggleButtonState({
    required this.currentLanguage,
    required this.isAnimating,
    required this.displayText,
  });

  /// 当前语言代码 / Current language code
  final String currentLanguage;
  
  /// 是否正在执行动画 / Whether animating
  final bool isAnimating;
  
  /// 显示文本 / Display text
  final String displayText;
}
```

#### 扩展方法 / Extension Methods

**AppLocalizationsToggle** - AppLocalizations扩展
```dart
extension AppLocalizationsToggle on AppLocalizations {
  /// 一键切换语言 / One-click language toggle
  static Future<void> toggleLanguage(BuildContext context);
  
  /// 带错误处理的语言切换 / Language change with error handling
  static Future<void> changeLanguageWithErrorHandling(
    BuildContext context,
    String locale,
  );
}
```

**LocalizationExtensionToggle** - BuildContext扩展
```dart
extension LocalizationExtensionToggle on BuildContext {
  /// 一键切换语言 / One-click language toggle
  Future<void> toggleLanguage();
  
  /// 获取下一个语言的显示名称 / Get next language display name
  String get nextLanguageDisplay;
}
```

### 添加新的本地化字符串 / Adding New Localized Strings

1. 在 `lib/core/localization/app_strings.dart` 中添加新的键值对：

```dart
// 中文版本
'zh': {
  'new_key': '新的中文文本',
  // ... 其他键
},

// 英文版本
'en': {
  'new_key': 'New English Text',
  // ... 其他键
},
```

2. 在代码中使用：

```dart
Text(context.l10n('new_key', fallback: '默认文本'))
```

### 最佳实践 / Best Practices

1. **优先使用一键切换** / Prefer One-Click Toggle
   ```dart
   // 推荐：使用一键切换
   OneClickLanguageToggleButton()
   
   // 或者在代码中
   await context.toggleLanguage();
   ```

2. **始终提供fallback文本** / Always Provide Fallback Text
   ```dart
   context.l10n('key', fallback: '默认文本')
   ```

3. **保持键名一致** / Keep Key Names Consistent
   - 确保所有语言版本都有相同的键
   - Ensure all language versions have the same keys

4. **使用描述性键名** / Use Descriptive Key Names
   ```dart
   // 好的例子 / Good example
   'task_creation_success' 
   
   // 不好的例子 / Bad example
   'msg1'
   ```

5. **处理切换错误** / Handle Toggle Errors
   ```dart
   try {
     await context.toggleLanguage();
   } catch (e) {
     // 处理错误，如显示错误提示
     ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(content: Text('语言切换失败: $e')),
     );
   }
   ```

6. **监控性能** / Monitor Performance
   ```dart
   // 获取性能统计
   final performance = OneClickLanguageToggleButton.getPerformanceReport();
   if (performance.averageResponseTime > 200) {
     // 性能警告处理
   }
   ```

## 支持的语言 / Supported Languages

- 🇨🇳 中文 (zh)
- 🇺🇸 English (en)

## 技术实现 / Technical Implementation

### 核心组件 / Core Components

1. **OneClickLanguageToggleButton** - 一键切换按钮组件
2. **LanguageToggleState** - 语言状态枚举
3. **ToggleButtonState** - 按钮状态数据模型
4. **AppStrings** - 字符串常量定义
5. **AppLocalizations** - 本地化服务
6. **LanguageSwitcher** - 传统UI组件
7. **AppBloc** - 状态管理

### 架构特点 / Architecture Features

- **一键切换设计** / One-Click Toggle Design
  - 无需对话框确认
  - No dialog confirmation needed
  - 即时响应用户操作
  - Instant response to user actions
  - 智能状态显示
  - Intelligent state display

- **非侵入式设计** / Non-invasive Design
  - 现有硬编码文本继续工作
  - Existing hardcoded text continues to work
  - 支持渐进式迁移
  - Supports gradual migration
  - 向后兼容
  - Backward compatible

- **完善的错误处理** / Comprehensive Error Handling
  - 自动重试机制
  - Automatic retry mechanism
  - 状态恢复功能
  - State recovery functionality
  - 用户友好的错误提示
  - User-friendly error messages

- **性能优化** / Performance Optimization
  - 按钮状态缓存
  - Button state caching
  - 动画性能监控
  - Animation performance monitoring
  - 内存使用优化
  - Memory usage optimization

- **完整的可访问性** / Full Accessibility
  - 屏幕阅读器支持
  - Screen reader support
  - 键盘导航
  - Keyboard navigation
  - 高对比度模式
  - High contrast mode

### 正确性保证 / Correctness Guarantees

一键切换功能实现了以下正确性属性：

1. **语言切换一致性** / Language Toggle Consistency
   - 每次点击都会切换到另一种语言
   - Each click switches to the other language

2. **状态显示同步性** / State Display Synchronization
   - 按钮显示与系统语言状态同步
   - Button display syncs with system language state

3. **持久化一致性** / Persistence Consistency
   - 语言设置正确保存和恢复
   - Language settings correctly saved and restored

4. **状态保持不变性** / State Preservation Invariant
   - 语言切换不影响其他应用状态
   - Language switching doesn't affect other app states

5. **切换操作幂等性** / Toggle Operation Idempotence
   - 偶数次切换回到初始语言
   - Even number of toggles return to initial language

6. **动画状态一致性** / Animation State Consistency
   - 动画完成后按钮处于稳定状态
   - Button in stable state after animation completion

7. **错误恢复性** / Error Recovery
   - 切换失败时保持原有状态
   - Maintains original state when toggle fails

## 测试 / Testing

### 运行测试 / Running Tests

#### 本地化测试 / Localization Tests
```bash
flutter test test/core/localization/app_localizations_test.dart
```

#### 一键切换功能测试 / One-Click Toggle Tests
```bash
# 单元测试
flutter test test/core/widgets/one_click_language_toggle_button_test.dart

# 属性测试
flutter test test/core/widgets/language_toggle_consistency_property_test.dart
flutter test test/core/widgets/state_display_sync_property_test.dart
flutter test test/core/widgets/toggle_idempotence_property_test.dart

# 集成测试
flutter test test/core/widgets/one_click_language_toggle_integration_test.dart
```

#### 性能测试 / Performance Tests
```bash
flutter test test/core/widgets/language_toggle_performance_test.dart
```

### 测试覆盖范围 / Test Coverage

- ✅ 语言切换一致性属性测试
- ✅ 状态显示同步性属性测试  
- ✅ 持久化一致性属性测试
- ✅ 状态保持不变性属性测试
- ✅ 切换操作幂等性属性测试
- ✅ 动画状态一致性属性测试
- ✅ 错误恢复性属性测试
- ✅ 可访问性测试
- ✅ 性能测试
- ✅ 集成测试

## 未来扩展 / Future Extensions

1. **添加更多语言** / Add More Languages
   - 日语 (ja)
   - 韩语 (ko)
   - 法语 (fr)

2. **区域化支持** / Regionalization Support
   - 简体中文 (zh-CN)
   - 繁体中文 (zh-TW)
   - 美式英语 (en-US)
   - 英式英语 (en-GB)

3. **动态语言包** / Dynamic Language Packs
   - 从服务器加载语言包
   - Load language packs from server

## 故障排除 / Troubleshooting

### 常见问题 / Common Issues

1. **一键切换按钮无响应** / One-Click Toggle Button Not Responding
   - 检查AppBloc状态是否为AppReadyState
   - Check if AppBloc state is AppReadyState
   - 确保按钮没有被其他Widget遮挡
   - Ensure button is not covered by other widgets
   - 查看控制台是否有错误日志
   - Check console for error logs

2. **语言切换后文本没有更新** / Text Not Updated After Language Switch
   - 确保使用了 `context.l10n()` 而不是硬编码文本
   - Make sure you're using `context.l10n()` instead of hardcoded text
   - 检查Widget是否正确监听AppBloc状态变化
   - Check if Widget properly listens to AppBloc state changes

3. **切换动画卡顿** / Toggle Animation Stuttering
   - 检查设备性能是否足够
   - Check if device performance is sufficient
   - 使用性能监控API检查帧率
   - Use performance monitoring API to check frame rate
   ```dart
   final performance = OneClickLanguageToggleButton.getPerformanceReport();
   print('当前FPS: ${performance.currentFps}');
   ```

4. **键不存在错误** / Key Not Found Error
   - 检查 `app_strings.dart` 中是否定义了该键
   - Check if the key is defined in `app_strings.dart`
   - 确保所有语言版本都有该键
   - Ensure all language versions have the key

5. **应用启动时语言不正确** / Incorrect Language on App Startup
   - 检查 SharedPreferences 是否正确保存
   - Check if SharedPreferences is saving correctly
   - 确保 AppBloc 正确初始化
   - Ensure AppBloc is properly initialized

6. **切换幂等性验证失败** / Toggle Idempotence Verification Failed
   - 检查切换计数器状态
   - Check toggle counter state
   ```dart
   final stats = OneClickLanguageToggleButton.getToggleStatistics();
   print('切换次数: ${stats.toggleCount}');
   print('是否为奇数次: ${stats.isOddToggle}');
   ```
   - 必要时重置切换会话
   - Reset toggle session if necessary
   ```dart
   OneClickLanguageToggleButton.endToggleSession();
   ```

### 调试工具 / Debugging Tools

#### 获取详细统计信息 / Get Detailed Statistics
```dart
// 切换统计
final toggleStats = OneClickLanguageToggleButton.getToggleStatistics();

// 性能报告
final performance = OneClickLanguageToggleButton.getPerformanceReport();

// 缓存统计
final cacheStats = OneClickLanguageToggleButton.getCacheStatistics();

// 内存统计
final memoryStats = OneClickLanguageToggleButton.getMemoryStats();

// 动画状态报告
final animationReport = OneClickLanguageToggleButton.getAnimationStateReport();
```

#### 强制清理和重置 / Force Cleanup and Reset
```dart
// 清理缓存和内存
OneClickLanguageToggleButton.performCleanup();

// 预热性能组件
OneClickLanguageToggleButton.warmupPerformanceComponents();

// 检查动画稳定性
final isStable = OneClickLanguageToggleButton.areAnimationsStable();
```

---

## 总结 / Summary

语言切换功能已成功集成到Prvin AI日历应用中，提供了完整的中英文双语支持。新增的一键语言切换功能让用户体验更加流畅，采用非侵入式设计，支持渐进式迁移，具有完善的错误处理和性能优化机制，确保应用的稳定性和用户体验。

The language switching feature has been successfully integrated into the Prvin AI Calendar app, providing complete bilingual support for Chinese and English. The new one-click language toggle feature makes the user experience smoother, uses a non-invasive design, supports gradual migration, and has comprehensive error handling and performance optimization mechanisms to ensure app stability and user experience.

### 主要优势 / Key Advantages

- 🚀 **即时切换** - 一键操作，无需等待 / Instant switching - one-click operation, no waiting
- 🎯 **直观易用** - 按钮显示当前语言状态 / Intuitive and easy - button shows current language state  
- 🛡️ **稳定可靠** - 完整的错误处理和状态保护 / Stable and reliable - complete error handling and state protection
- ⚡ **性能优化** - 智能缓存和动画优化 / Performance optimized - intelligent caching and animation optimization
- ♿ **无障碍友好** - 完整的可访问性支持 / Accessibility friendly - full accessibility support
- 🔧 **易于维护** - 清晰的API和完善的测试覆盖 / Easy to maintain - clear API and comprehensive test coverage