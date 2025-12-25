# 一键语言切换功能设计文档

## 概述

本设计文档描述了一键语言切换功能的技术实现方案。该功能将替换现有的对话框形式语言切换，提供更直观、快速的中英文切换体验。设计采用非侵入式方法，完全兼容现有的本地化系统和状态管理架构。

## 架构

### 系统架构图

```
┌─────────────────────────────────────────────────────────────┐
│                    用户界面层 (UI Layer)                      │
├─────────────────────────────────────────────────────────────┤
│  OneClickLanguageToggleButton                              │
│  ├─ 状态显示 (中/EN)                                        │
│  ├─ 点击处理                                               │
│  └─ 动画效果                                               │
├─────────────────────────────────────────────────────────────┤
│                   状态管理层 (State Layer)                   │
├─────────────────────────────────────────────────────────────┤
│  AppBloc (现有)                                            │
│  ├─ AppLanguageChangedEvent                                │
│  ├─ AppReadyState.languageCode                             │
│  └─ 语言切换逻辑                                            │
├─────────────────────────────────────────────────────────────┤
│                  本地化层 (Localization Layer)               │
├─────────────────────────────────────────────────────────────┤
│  AppLocalizations (现有)                                   │
│  ├─ 语言切换方法                                            │
│  ├─ 当前语言获取                                            │
│  └─ 字符串本地化                                            │
├─────────────────────────────────────────────────────────────┤
│                   持久化层 (Persistence Layer)               │
├─────────────────────────────────────────────────────────────┤
│  SharedPreferences (现有)                                  │
│  └─ 语言设置存储                                            │
└─────────────────────────────────────────────────────────────┘
```

## 组件和接口

### 1. OneClickLanguageToggleButton 组件

**职责**: 提供一键语言切换的用户界面

**接口**:
```dart
class OneClickLanguageToggleButton extends StatelessWidget {
  const OneClickLanguageToggleButton({
    super.key,
    this.size = 40.0,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  final double size;
  final Duration animationDuration;
}
```

**主要方法**:
- `_toggleLanguage(BuildContext context)`: 执行语言切换
- `_getCurrentLanguageDisplay(String locale)`: 获取当前语言显示文本
- `_buildButton(BuildContext context, String currentLanguage)`: 构建按钮UI

### 2. 语言切换逻辑扩展

**扩展 AppLocalizations**:
```dart
extension AppLocalizationsToggle on AppLocalizations {
  static void toggleLanguage(BuildContext context) {
    final currentLocale = _getCurrentLocale(context);
    final newLocale = currentLocale == 'zh' ? 'en' : 'zh';
    changeLanguage(context, newLocale);
  }
}
```

### 3. BuildContext 扩展增强

**扩展 LocalizationExtension**:
```dart
extension LocalizationExtension on BuildContext {
  // 现有方法保持不变...
  
  /// 一键切换语言
  void toggleLanguage() {
    AppLocalizations.toggleLanguage(this);
  }
  
  /// 获取下一个语言的显示名称
  String get nextLanguageDisplay {
    final current = currentLocale;
    return current == 'zh' ? 'EN' : '中';
  }
}
```

## 数据模型

### 语言状态模型

```dart
enum LanguageToggleState {
  chinese('zh', '中'),
  english('en', 'EN');

  const LanguageToggleState(this.code, this.display);
  
  final String code;
  final String display;
  
  LanguageToggleState get next {
    return this == chinese ? english : chinese;
  }
}
```

### 按钮状态模型

```dart
class ToggleButtonState {
  const ToggleButtonState({
    required this.currentLanguage,
    required this.isAnimating,
    required this.displayText,
  });

  final String currentLanguage;
  final bool isAnimating;
  final String displayText;
  
  ToggleButtonState copyWith({
    String? currentLanguage,
    bool? isAnimating,
    String? displayText,
  }) {
    return ToggleButtonState(
      currentLanguage: currentLanguage ?? this.currentLanguage,
      isAnimating: isAnimating ?? this.isAnimating,
      displayText: displayText ?? this.displayText,
    );
  }
}
```

## 正确性属性

*属性是一个特征或行为，应该在系统的所有有效执行中保持为真——本质上是关于系统应该做什么的正式声明。属性作为人类可读规范和机器可验证正确性保证之间的桥梁。*

### 属性 1: 语言切换一致性
*对于任何*当前语言状态，点击一键切换按钮应该将语言切换到另一种支持的语言
**验证: 需求 1.1**

### 属性 2: 状态显示同步性
*对于任何*语言切换操作，按钮显示的语言标识应该与系统当前语言状态保持同步
**验证: 需求 2.1, 2.2, 2.3**

### 属性 3: 持久化一致性
*对于任何*语言切换操作，新的语言设置应该被正确保存到本地存储，并在应用重启后恢复
**验证: 需求 1.3, 1.4**

### 属性 4: 状态保持不变性
*对于任何*语言切换操作，除了界面语言外的所有应用状态（任务数据、日期选择、番茄钟状态等）应该保持不变
**验证: 需求 3.1, 3.2, 3.3**

### 属性 5: 切换操作幂等性
*对于任何*连续的语言切换操作，奇数次点击应该切换到一种语言，偶数次点击应该回到原始语言
**验证: 需求 1.1**

### 属性 6: 动画状态一致性
*对于任何*语言切换动画，动画完成后按钮应该处于稳定状态，显示正确的语言标识
**验证: 需求 1.5, 2.4**

### 属性 7: 错误恢复性
*对于任何*语言切换失败的情况，系统应该保持原有语言状态不变，不应该进入不一致状态
**验证: 需求 3.4**

## 错误处理

### 错误类型和处理策略

1. **BLoC状态访问失败**
   - 错误: 无法访问AppBloc或状态不是AppReadyState
   - 处理: 使用默认语言'zh'，记录警告日志
   - 恢复: 尝试重新获取状态

2. **SharedPreferences保存失败**
   - 错误: 无法保存语言设置到本地存储
   - 处理: 继续使用新语言，但记录错误日志
   - 恢复: 在下次切换时重试保存

3. **不支持的语言代码**
   - 错误: 尝试切换到不支持的语言
   - 处理: 忽略切换请求，保持当前语言
   - 恢复: 显示错误提示给用户

4. **动画执行异常**
   - 错误: 按钮动画执行失败
   - 处理: 跳过动画，直接更新按钮状态
   - 恢复: 重置动画控制器

### 错误处理流程

```dart
Future<void> _handleLanguageToggle(BuildContext context) async {
  try {
    // 1. 获取当前语言
    final currentLocale = context.currentLocale;
    
    // 2. 确定目标语言
    final targetLocale = currentLocale == 'zh' ? 'en' : 'zh';
    
    // 3. 验证目标语言支持
    if (!AppLocalizations.isLocaleSupported(targetLocale)) {
      throw UnsupportedLanguageException(targetLocale);
    }
    
    // 4. 执行切换
    context.toggleLanguage();
    
    // 5. 验证切换结果
    await _verifyLanguageSwitch(context, targetLocale);
    
  } on UnsupportedLanguageException catch (e) {
    _logger.warning('Unsupported language: ${e.language}');
    _showErrorSnackBar(context, 'Language not supported');
  } on StateAccessException catch (e) {
    _logger.error('Failed to access app state: $e');
    _showErrorSnackBar(context, 'Language switch failed');
  } catch (e) {
    _logger.error('Unexpected error during language toggle: $e');
    _showErrorSnackBar(context, 'An error occurred');
  }
}
```

## 测试策略

### 单元测试

**测试覆盖范围**:
1. OneClickLanguageToggleButton组件测试
2. 语言切换逻辑测试
3. 状态同步测试
4. 错误处理测试

**关键测试用例**:
```dart
group('OneClickLanguageToggleButton Tests', () {
  testWidgets('should display correct language indicator', (tester) async {
    // 测试按钮显示正确的语言标识
  });
  
  testWidgets('should toggle language on tap', (tester) async {
    // 测试点击切换语言功能
  });
  
  testWidgets('should handle animation correctly', (tester) async {
    // 测试动画效果
  });
});
```

### 属性基于测试

**测试框架**: 使用Flutter的内置测试框架结合自定义属性测试工具

**属性测试配置**:
- 最小迭代次数: 100次
- 测试数据生成: 随机语言状态、按钮状态、用户交互序列

**关键属性测试**:

```dart
// 属性1测试: 语言切换一致性
group('Property Tests', () {
  test('Property 1: Language toggle consistency', () {
    // **Feature: one-click-language-toggle, Property 1: 语言切换一致性**
    // 对于任何当前语言状态，点击切换按钮应该切换到另一种语言
    
    forAll(languageStateGenerator, (initialLanguage) {
      final result = toggleLanguage(initialLanguage);
      expect(result, isNot(equals(initialLanguage)));
      expect(supportedLanguages.contains(result), isTrue);
    });
  });
  
  test('Property 2: State display synchronization', () {
    // **Feature: one-click-language-toggle, Property 2: 状态显示同步性**
    // 对于任何语言切换操作，按钮显示应该与系统状态同步
    
    forAll(languageToggleSequenceGenerator, (toggleSequence) {
      var currentLanguage = 'zh';
      for (final toggle in toggleSequence) {
        currentLanguage = performToggle(currentLanguage);
        final displayText = getDisplayText(currentLanguage);
        expect(displayText, equals(getExpectedDisplay(currentLanguage)));
      }
    });
  });
  
  test('Property 3: Persistence consistency', () {
    // **Feature: one-click-language-toggle, Property 3: 持久化一致性**
    // 对于任何语言切换操作，设置应该被正确保存和恢复
    
    forAll(languageStateGenerator, (targetLanguage) async {
      await saveLanguagePreference(targetLanguage);
      final restored = await loadLanguagePreference();
      expect(restored, equals(targetLanguage));
    });
  });
  
  test('Property 4: State preservation invariant', () {
    // **Feature: one-click-language-toggle, Property 4: 状态保持不变性**
    // 对于任何语言切换操作，其他应用状态应该保持不变
    
    forAll(appStateGenerator, (initialState) {
      final stateBeforeToggle = captureNonLanguageState(initialState);
      performLanguageToggle(initialState);
      final stateAfterToggle = captureNonLanguageState(initialState);
      expect(stateAfterToggle, equals(stateBeforeToggle));
    });
  });
  
  test('Property 5: Toggle operation idempotence', () {
    // **Feature: one-click-language-toggle, Property 5: 切换操作幂等性**
    // 对于任何连续切换操作，偶数次切换应该回到原始状态
    
    forAll(languageStateGenerator, (initialLanguage) {
      var currentLanguage = initialLanguage;
      
      // 执行偶数次切换
      for (int i = 0; i < 4; i++) {
        currentLanguage = toggleLanguage(currentLanguage);
      }
      
      expect(currentLanguage, equals(initialLanguage));
    });
  });
});
```

### 集成测试

**测试场景**:
1. 完整的语言切换流程测试
2. 与现有功能的兼容性测试
3. 性能测试
4. 用户体验测试

### Widget测试

**测试重点**:
1. 按钮渲染正确性
2. 用户交互响应
3. 动画效果验证
4. 状态更新同步

## 性能考虑

### 优化策略

1. **按钮状态缓存**
   - 缓存语言显示文本，避免重复计算
   - 使用const构造函数减少重建

2. **动画优化**
   - 使用硬件加速的动画
   - 避免在动画期间进行复杂计算

3. **状态管理优化**
   - 最小化BLoC状态更新范围
   - 使用BlocBuilder的buildWhen参数优化重建

4. **内存管理**
   - 及时释放动画控制器
   - 避免内存泄漏

### 性能指标

- 语言切换响应时间: < 200ms
- 按钮动画帧率: 60fps
- 内存使用增量: < 1MB
- CPU使用峰值: < 10%

## 可访问性

### 无障碍支持

1. **语义标签**
   ```dart
   Semantics(
     label: 'Toggle language between Chinese and English',
     hint: 'Currently ${currentLanguage == 'zh' ? 'Chinese' : 'English'}',
     button: true,
     child: toggleButton,
   )
   ```

2. **屏幕阅读器支持**
   - 提供清晰的按钮描述
   - 语言切换后播放确认信息

3. **键盘导航**
   - 支持Tab键导航
   - 支持空格键和回车键激活

4. **高对比度支持**
   - 在高对比度模式下调整颜色
   - 确保文本可读性

## 国际化扩展

### 未来语言支持

设计支持轻松添加更多语言:

```dart
enum SupportedLanguage {
  chinese('zh', '中'),
  english('en', 'EN'),
  japanese('ja', '日'),  // 未来扩展
  korean('ko', '한'),    // 未来扩展
  french('fr', 'FR');    // 未来扩展
  
  // 切换逻辑将自动支持循环切换
  SupportedLanguage get next {
    final values = SupportedLanguage.values;
    final currentIndex = values.indexOf(this);
    return values[(currentIndex + 1) % values.length];
  }
}
```

### 区域化支持

为支持区域变体做准备:
- zh-CN (简体中文)
- zh-TW (繁体中文)  
- en-US (美式英语)
- en-GB (英式英语)

## 部署和维护

### 部署策略

1. **渐进式部署**
   - 首先部署到测试环境
   - 逐步推广到生产环境
   - 保留回滚机制

2. **功能开关**
   - 支持通过配置启用/禁用新功能
   - 便于A/B测试和问题排查

### 监控和日志

1. **关键指标监控**
   - 语言切换成功率
   - 切换响应时间
   - 错误发生频率

2. **日志记录**
   ```dart
   class LanguageToggleLogger {
     static void logToggleAttempt(String from, String to) {
       logger.info('Language toggle: $from -> $to');
     }
     
     static void logToggleSuccess(String language, Duration duration) {
       logger.info('Language toggle successful: $language (${duration.inMilliseconds}ms)');
     }
     
     static void logToggleError(String error, StackTrace stackTrace) {
       logger.error('Language toggle failed: $error', stackTrace);
     }
   }
   ```

### 维护指南

1. **代码维护**
   - 定期更新依赖
   - 代码质量检查
   - 性能监控

2. **用户反馈处理**
   - 收集用户使用数据
   - 分析常见问题
   - 持续改进用户体验