# 一键语言切换 API 文档 / One-Click Language Toggle API Documentation

## 概述 / Overview

一键语言切换功能提供了快速、直观的中英文切换体验。本文档详细介绍了所有相关的API、组件和扩展方法。

The one-click language toggle feature provides a fast and intuitive Chinese-English switching experience. This document details all related APIs, components, and extension methods.

## 核心组件 / Core Components

### OneClickLanguageToggleButton

主要的一键切换按钮组件，提供完整的切换功能和状态管理。

The main one-click toggle button component that provides complete switching functionality and state management.

#### 构造函数 / Constructor

```dart
OneClickLanguageToggleButton({
  Key? key,
  double size = 40.0,
  Duration animationDuration = const Duration(milliseconds: 300),
})
```

**参数 / Parameters:**

- `size`: 按钮尺寸（像素）/ Button size (pixels)
  - 建议值 / Recommended values: 32.0 - 64.0
  - 默认值 / Default: 40.0

- `animationDuration`: 动画持续时间 / Animation duration
  - 建议值 / Recommended values: 200ms - 500ms
  - 默认值 / Default: 300ms

#### 静态方法 / Static Methods

##### getToggleStatistics()

获取切换统计信息 / Get toggle statistics

```dart
static ToggleStatistics getToggleStatistics()
```

**返回值 / Returns:** `ToggleStatistics`

```dart
class ToggleStatistics {
  final int toggleCount;           // 切换次数 / Toggle count
  final String? sessionId;         // 会话ID / Session ID
  final String? initialLanguage;   // 初始语言 / Initial language
  final bool isOddToggle;          // 是否奇数次切换 / Is odd toggle
  final bool isEvenToggle;         // 是否偶数次切换 / Is even toggle
  final DateTime sessionStartTime; // 会话开始时间 / Session start time
}
```

##### getToggleCount()

获取当前切换计数 / Get current toggle count

```dart
static int getToggleCount()
```

**返回值 / Returns:** 当前会话的切换次数 / Current session toggle count

##### verifyToggleIdempotence()

验证切换操作的幂等性 / Verify toggle operation idempotence

```dart
static ToggleIdempotenceResult verifyToggleIdempotence()
```

**返回值 / Returns:** `ToggleIdempotenceResult`

```dart
class ToggleIdempotenceResult {
  final bool isValid;              // 是否有效 / Is valid
  final int toggleCount;           // 切换次数 / Toggle count
  final String? expectedLanguage;  // 期望语言 / Expected language
  final String? actualLanguage;    // 实际语言 / Actual language
  final String? errorMessage;      // 错误信息 / Error message
}
```

##### endToggleSession()

结束切换会话并获取摘要 / End toggle session and get summary

```dart
static ToggleSessionSummary endToggleSession()
```

**返回值 / Returns:** `ToggleSessionSummary`

```dart
class ToggleSessionSummary {
  final String sessionId;         // 会话ID / Session ID
  final int totalToggles;         // 总切换次数 / Total toggles
  final Duration duration;        // 持续时间 / Duration
  final String initialLanguage;   // 初始语言 / Initial language
  final String finalLanguage;     // 最终语言 / Final language
  final Duration averageToggleTime; // 平均切换时间 / Average toggle time
}
```

##### getPerformanceReport()

获取性能监控报告 / Get performance monitoring report

```dart
static PerformanceReport getPerformanceReport()
```

**返回值 / Returns:** `PerformanceReport`

```dart
class PerformanceReport {
  final double averageResponseTime; // 平均响应时间(ms) / Average response time (ms)
  final double currentFps;          // 当前帧率 / Current FPS
  final int memoryUsage;            // 内存使用(bytes) / Memory usage (bytes)
  final double cacheHitRate;        // 缓存命中率 / Cache hit rate
  final PerformanceStatus status;   // 性能状态 / Performance status
}
```

##### getCacheStatistics()

获取缓存统计信息 / Get cache statistics

```dart
static CacheStatistics getCacheStatistics()
```

##### getMemoryStats()

获取内存使用统计 / Get memory usage statistics

```dart
static MemoryStats getMemoryStats()
```

##### detectMemoryLeaks()

检测内存泄漏 / Detect memory leaks

```dart
static List<MemoryLeak> detectMemoryLeaks()
```

##### getAnimationPerformanceStatus()

获取动画性能状态 / Get animation performance status

```dart
static PerformanceStatus getAnimationPerformanceStatus()
```

##### getAnimationStateReport()

获取动画状态报告 / Get animation state report

```dart
static AnimationStateReport getAnimationStateReport()
```

##### areAnimationsStable()

检查所有动画是否处于稳定状态 / Check if all animations are stable

```dart
static bool areAnimationsStable()
```

##### performCleanup()

强制清理缓存和内存 / Force cleanup cache and memory

```dart
static void performCleanup()
```

##### warmupPerformanceComponents()

预热性能优化组件 / Warmup performance optimization components

```dart
static void warmupPerformanceComponents()
```

## 数据模型 / Data Models

### LanguageToggleState

语言切换状态枚举 / Language toggle state enumeration

```dart
enum LanguageToggleState {
  chinese('zh', '中'),
  english('en', 'EN');

  const LanguageToggleState(this.code, this.display);

  final String code;     // 语言代码 / Language code
  final String display;  // 显示文本 / Display text

  // 获取下一个语言状态 / Get next language state
  LanguageToggleState get next;

  // 从语言代码创建状态 / Create state from language code
  static LanguageToggleState fromCode(String code);
}
```

### ToggleButtonState

按钮状态数据模型 / Button state data model

```dart
class ToggleButtonState {
  const ToggleButtonState({
    required this.currentLanguage,
    required this.isAnimating,
    required this.displayText,
  });

  final String currentLanguage; // 当前语言代码 / Current language code
  final bool isAnimating;       // 是否正在动画 / Is animating
  final String displayText;     // 显示文本 / Display text

  // 创建状态副本 / Create state copy
  ToggleButtonState copyWith({
    String? currentLanguage,
    bool? isAnimating,
    String? displayText,
  });
}
```

## 扩展方法 / Extension Methods

### AppLocalizationsToggle

AppLocalizations的扩展方法 / Extension methods for AppLocalizations

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

#### 使用示例 / Usage Examples

```dart
// 一键切换 / One-click toggle
await AppLocalizationsToggle.toggleLanguage(context);

// 切换到指定语言 / Switch to specific language
await AppLocalizationsToggle.changeLanguageWithErrorHandling(context, 'en');
```

### LocalizationExtensionToggle

BuildContext的扩展方法 / Extension methods for BuildContext

```dart
extension LocalizationExtensionToggle on BuildContext {
  /// 一键切换语言 / One-click language toggle
  Future<void> toggleLanguage();

  /// 获取下一个语言的显示名称 / Get next language display name
  String get nextLanguageDisplay;
}
```

#### 使用示例 / Usage Examples

```dart
// 在任何Widget中使用 / Use in any Widget
await context.toggleLanguage();

// 获取下一个语言显示 / Get next language display
final nextLang = context.nextLanguageDisplay; // "EN" 或 "中"
```

## 错误处理 / Error Handling

### 异常类型 / Exception Types

#### UnsupportedLanguageException

不支持的语言异常 / Unsupported language exception

```dart
class UnsupportedLanguageException implements Exception {
  final String language;
  final String message;
}
```

#### StateAccessException

状态访问异常 / State access exception

```dart
class StateAccessException implements Exception {
  final String message;
  final String? attemptedAction;
}
```

#### AnimationException

动画异常 / Animation exception

```dart
class AnimationException implements Exception {
  final String message;
  final dynamic originalError;
}
```

### 错误处理最佳实践 / Error Handling Best Practices

```dart
try {
  await context.toggleLanguage();
} on UnsupportedLanguageException catch (e) {
  // 处理不支持的语言 / Handle unsupported language
  print('不支持的语言: ${e.language}');
} on StateAccessException catch (e) {
  // 处理状态访问错误 / Handle state access error
  print('状态访问失败: ${e.message}');
} on AnimationException catch (e) {
  // 处理动画错误 / Handle animation error
  print('动画执行失败: ${e.message}');
} catch (e) {
  // 处理其他错误 / Handle other errors
  print('未知错误: $e');
}
```

## 性能优化 / Performance Optimization

### 性能监控 / Performance Monitoring

```dart
// 开始监控 / Start monitoring
OneClickLanguageToggleButton.warmupPerformanceComponents();

// 获取性能报告 / Get performance report
final report = OneClickLanguageToggleButton.getPerformanceReport();

// 检查性能状态 / Check performance status
if (report.averageResponseTime > 200) {
  print('警告：响应时间过长');
}

if (report.currentFps < 60) {
  print('警告：帧率过低');
}
```

### 缓存管理 / Cache Management

```dart
// 获取缓存统计 / Get cache statistics
final cacheStats = OneClickLanguageToggleButton.getCacheStatistics();
print('缓存命中率: ${(cacheStats.hitRate * 100).toStringAsFixed(1)}%');

// 清理缓存 / Clear cache
OneClickLanguageToggleButton.performCleanup();
```

### 内存管理 / Memory Management

```dart
// 获取内存统计 / Get memory statistics
final memoryStats = OneClickLanguageToggleButton.getMemoryStats();
print('当前内存使用: ${(memoryStats.currentUsage / 1024 / 1024).toStringAsFixed(1)}MB');

// 检测内存泄漏 / Detect memory leaks
final leaks = OneClickLanguageToggleButton.detectMemoryLeaks();
if (leaks.isNotEmpty) {
  print('检测到 ${leaks.length} 个内存泄漏');
}
```

## 可访问性 / Accessibility

### 语义标签 / Semantic Labels

按钮自动提供以下语义信息 / Button automatically provides the following semantic information:

- **label**: "语言切换按钮" / "Language toggle button"
- **hint**: 当前语言和切换提示 / Current language and toggle hint
- **value**: 当前语言显示 / Current language display
- **button**: true
- **enabled**: true
- **focusable**: true

### 键盘导航 / Keyboard Navigation

支持的键盘操作 / Supported keyboard operations:

- **Tab**: 导航到按钮 / Navigate to button
- **Space**: 执行切换 / Execute toggle
- **Enter**: 执行切换 / Execute toggle

### 屏幕阅读器 / Screen Reader

- 自动播报语言切换结果 / Automatically announce language switch result
- 提供详细的状态描述 / Provide detailed state description
- 支持焦点管理 / Support focus management

## 测试 / Testing

### 单元测试 / Unit Tests

```dart
testWidgets('should display correct language indicator', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: OneClickLanguageToggleButton(),
      ),
    ),
  );

  // 验证按钮显示 / Verify button display
  expect(find.text('中'), findsOneWidget);
});
```

### 属性测试 / Property Tests

```dart
test('Property: Language toggle consistency', () {
  // **Feature: one-click-language-toggle, Property 1: 语言切换一致性**
  forAll(languageStateGenerator, (initialLanguage) {
    final result = toggleLanguage(initialLanguage);
    expect(result, isNot(equals(initialLanguage)));
    expect(supportedLanguages.contains(result), isTrue);
  });
});
```

### 集成测试 / Integration Tests

```dart
testWidgets('should integrate with app state management', (tester) async {
  // 测试与AppBloc的集成 / Test integration with AppBloc
  await tester.pumpWidget(testApp);
  
  // 点击切换按钮 / Tap toggle button
  await tester.tap(find.byType(OneClickLanguageToggleButton));
  await tester.pumpAndSettle();
  
  // 验证状态更新 / Verify state update
  final appState = tester.widget<BlocProvider<AppBloc>>(
    find.byType(BlocProvider<AppBloc>),
  ).bloc.state;
  
  expect(appState, isA<AppReadyState>());
});
```

## 最佳实践 / Best Practices

### 1. 组件使用 / Component Usage

```dart
// ✅ 推荐：使用默认配置
OneClickLanguageToggleButton()

// ✅ 推荐：适当的尺寸配置
OneClickLanguageToggleButton(size: 48.0) // 适合平板

// ❌ 不推荐：过小的尺寸
OneClickLanguageToggleButton(size: 16.0) // 难以点击

// ❌ 不推荐：过长的动画
OneClickLanguageToggleButton(
  animationDuration: Duration(seconds: 2), // 用户体验差
)
```

### 2. 程序化切换 / Programmatic Toggle

```dart
// ✅ 推荐：使用扩展方法
await context.toggleLanguage();

// ✅ 推荐：错误处理
try {
  await context.toggleLanguage();
} catch (e) {
  // 处理错误
}

// ❌ 不推荐：忽略错误
context.toggleLanguage(); // 没有await和错误处理
```

### 3. 性能监控 / Performance Monitoring

```dart
// ✅ 推荐：定期检查性能
final report = OneClickLanguageToggleButton.getPerformanceReport();
if (report.averageResponseTime > 200) {
  // 采取优化措施
}

// ✅ 推荐：适时清理缓存
if (cacheStats.size > 1000) {
  OneClickLanguageToggleButton.performCleanup();
}
```

### 4. 可访问性 / Accessibility

```dart
// ✅ 推荐：提供语义标签
Semantics(
  label: '语言切换',
  hint: '点击切换应用语言',
  child: OneClickLanguageToggleButton(),
)

// ✅ 推荐：支持键盘导航
Focus(
  child: OneClickLanguageToggleButton(),
)
```

## 故障排除 / Troubleshooting

### 常见问题 / Common Issues

1. **按钮无响应 / Button Not Responding**
   ```dart
   // 检查AppBloc状态 / Check AppBloc state
   final state = context.read<AppBloc>().state;
   if (state is! AppReadyState) {
     // AppBloc未就绪 / AppBloc not ready
   }
   ```

2. **动画卡顿 / Animation Stuttering**
   ```dart
   // 检查性能状态 / Check performance status
   final status = OneClickLanguageToggleButton.getAnimationPerformanceStatus();
   if (status.currentFps < 60) {
     // 性能不足，禁用复杂动画 / Poor performance, disable complex animations
   }
   ```

3. **内存泄漏 / Memory Leaks**
   ```dart
   // 检测内存泄漏 / Detect memory leaks
   final leaks = OneClickLanguageToggleButton.detectMemoryLeaks();
   if (leaks.isNotEmpty) {
     OneClickLanguageToggleButton.performCleanup();
   }
   ```

### 调试工具 / Debugging Tools

```dart
// 启用详细日志 / Enable verbose logging
LanguageToggleLogger.setLogLevel(LogLevel.debug);

// 获取详细统计 / Get detailed statistics
final stats = OneClickLanguageToggleButton.getToggleStatistics();
final performance = OneClickLanguageToggleButton.getPerformanceReport();
final cache = OneClickLanguageToggleButton.getCacheStatistics();

print('统计信息: ${stats.toString()}');
print('性能报告: ${performance.toString()}');
print('缓存状态: ${cache.toString()}');
```

## 版本兼容性 / Version Compatibility

| 版本 / Version | Flutter | Dart | 功能 / Features |
|---------------|---------|------|----------------|
| 1.0.0 | ≥3.10.0 | ≥3.0.0 | 基本切换功能 / Basic toggle |
| 1.1.0 | ≥3.10.0 | ≥3.0.0 | 性能监控 / Performance monitoring |
| 1.2.0 | ≥3.13.0 | ≥3.1.0 | 可访问性增强 / Accessibility enhancements |
| 1.3.0 | ≥3.16.0 | ≥3.2.0 | 动画优化 / Animation optimization |

## 许可证 / License

MIT License - 详见项目根目录的LICENSE文件 / See LICENSE file in project root for details.