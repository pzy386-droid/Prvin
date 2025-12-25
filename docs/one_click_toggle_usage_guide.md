# 一键语言切换使用指南 / One-Click Language Toggle Usage Guide

## 快速开始 / Quick Start

### 基本使用 / Basic Usage

最简单的使用方式是直接添加按钮到您的界面中：

The simplest way to use it is to directly add the button to your interface:

```dart
import 'package:prvin/core/widgets/one_click_language_toggle_button.dart';

class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('我的应用'),
        actions: [
          // 添加一键切换按钮 / Add one-click toggle button
          OneClickLanguageToggleButton(),
          SizedBox(width: 16),
        ],
      ),
      body: Center(
        child: Text(context.l10n('welcome', fallback: '欢迎')),
      ),
    );
  }
}
```

### 程序化切换 / Programmatic Toggle

您也可以在代码中直接触发语言切换：

You can also trigger language switching directly in code:

```dart
// 使用扩展方法 / Using extension method
await context.toggleLanguage();

// 在按钮点击事件中 / In button click event
ElevatedButton(
  onPressed: () async {
    try {
      await context.toggleLanguage();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('语言已切换')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('切换失败: $e')),
      );
    }
  },
  child: Text('切换语言'),
)
```

## 自定义配置 / Custom Configuration

### 尺寸配置 / Size Configuration

根据不同的使用场景，您可以调整按钮尺寸：

Adjust button size according to different usage scenarios:

```dart
// 紧凑模式 - 适合工具栏 / Compact mode - suitable for toolbar
OneClickLanguageToggleButton(size: 32.0)

// 标准模式 - 默认尺寸 / Standard mode - default size
OneClickLanguageToggleButton(size: 40.0)

// 大尺寸模式 - 适合主要操作 / Large size mode - suitable for primary actions
OneClickLanguageToggleButton(size: 48.0)

// 超大模式 - 适合平板设备 / Extra large mode - suitable for tablets
OneClickLanguageToggleButton(size: 56.0)
```

### 动画配置 / Animation Configuration

调整动画速度以匹配您的应用风格：

Adjust animation speed to match your app style:

```dart
// 快速动画 - 适合频繁操作 / Fast animation - suitable for frequent operations
OneClickLanguageToggleButton(
  animationDuration: Duration(milliseconds: 200),
)

// 标准动画 - 默认速度 / Standard animation - default speed
OneClickLanguageToggleButton(
  animationDuration: Duration(milliseconds: 300),
)

// 慢速动画 - 更明显的视觉效果 / Slow animation - more obvious visual effect
OneClickLanguageToggleButton(
  animationDuration: Duration(milliseconds: 500),
)
```

## 集成示例 / Integration Examples

### 在AppBar中使用 / Using in AppBar

```dart
class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n('app_name', fallback: 'Prvin AI日历')),
        backgroundColor: Color(0xFF4FC3F7),
        foregroundColor: Colors.white,
        actions: [
          // 通知按钮 / Notification button
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () => _showNotifications(context),
          ),
          
          // 一键语言切换 / One-click language toggle
          OneClickLanguageToggleButton(size: 40.0),
          
          // 更多菜单 / More menu
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(child: Text('设置')),
              PopupMenuItem(child: Text('关于')),
            ],
          ),
          
          SizedBox(width: 8),
        ],
      ),
      body: _buildBody(context),
    );
  }
}
```

### 在侧边栏中使用 / Using in Drawer

```dart
class MyDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Color(0xFF4FC3F7)),
            child: Text(
              context.l10n('app_name', fallback: 'Prvin AI日历'),
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          
          ListTile(
            leading: Icon(Icons.home),
            title: Text(context.l10n('home', fallback: '首页')),
            onTap: () => Navigator.pop(context),
          ),
          
          ListTile(
            leading: Icon(Icons.settings),
            title: Text(context.l10n('settings', fallback: '设置')),
            onTap: () => _openSettings(context),
          ),
          
          Divider(),
          
          // 语言切换区域 / Language toggle section
          ListTile(
            leading: Icon(Icons.language),
            title: Text(context.l10n('language', fallback: '语言')),
            trailing: OneClickLanguageToggleButton(size: 36.0),
            onTap: () async {
              await context.toggleLanguage();
            },
          ),
        ],
      ),
    );
  }
}
```

### 在设置页面中使用 / Using in Settings Page

```dart
class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n('settings', fallback: '设置')),
      ),
      body: ListView(
        children: [
          // 语言设置区域 / Language settings section
          Card(
            margin: EdgeInsets.all(16),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n('language_settings', fallback: '语言设置'),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Icon(Icons.language, color: Color(0xFF4FC3F7)),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('当前语言 / Current Language'),
                            Text(
                              _getCurrentLanguageName(context),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      OneClickLanguageToggleButton(size: 44.0),
                    ],
                  ),
                  
                  SizedBox(height: 12),
                  
                  Text(
                    '点击按钮即可在中英文之间快速切换',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // 其他设置项 / Other settings
          // ...
        ],
      ),
    );
  }
  
  String _getCurrentLanguageName(BuildContext context) {
    final currentLocale = context.currentLocale;
    return currentLocale == 'zh' ? '中文 (Chinese)' : 'English (英文)';
  }
}
```

## 高级用法 / Advanced Usage

### 监控切换统计 / Monitoring Toggle Statistics

```dart
class LanguageStatsWidget extends StatefulWidget {
  @override
  _LanguageStatsWidgetState createState() => _LanguageStatsWidgetState();
}

class _LanguageStatsWidgetState extends State<LanguageStatsWidget> {
  late Timer _timer;
  ToggleStatistics? _stats;

  @override
  void initState() {
    super.initState();
    _updateStats();
    
    // 每秒更新统计信息 / Update statistics every second
    _timer = Timer.periodic(Duration(seconds: 1), (_) => _updateStats());
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _updateStats() {
    setState(() {
      _stats = OneClickLanguageToggleButton.getToggleStatistics();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_stats == null) return SizedBox.shrink();

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('切换统计', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('切换次数: ${_stats!.toggleCount}'),
            Text('会话ID: ${_stats!.sessionId ?? "无"}'),
            Text('初始语言: ${_stats!.initialLanguage ?? "未知"}'),
            Text('切换类型: ${_stats!.isOddToggle ? "奇数次" : "偶数次"}'),
            
            SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _resetSession,
                    child: Text('重置会话'),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _verifyIdempotence,
                    child: Text('验证幂等性'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _resetSession() {
    final summary = OneClickLanguageToggleButton.endToggleSession();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('会话已重置，总切换次数: ${summary.totalToggles}'),
      ),
    );
  }

  void _verifyIdempotence() {
    final result = OneClickLanguageToggleButton.verifyToggleIdempotence();
    final message = result.isValid 
        ? '幂等性验证通过' 
        : '幂等性验证失败: ${result.errorMessage}';
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: result.isValid ? Colors.green : Colors.red,
      ),
    );
  }
}
```

### 性能监控面板 / Performance Monitoring Panel

```dart
class PerformanceMonitorWidget extends StatefulWidget {
  @override
  _PerformanceMonitorWidgetState createState() => _PerformanceMonitorWidgetState();
}

class _PerformanceMonitorWidgetState extends State<PerformanceMonitorWidget> {
  PerformanceReport? _report;
  CacheStatistics? _cacheStats;
  MemoryStats? _memoryStats;

  @override
  void initState() {
    super.initState();
    _updateMetrics();
    
    // 每2秒更新性能指标 / Update performance metrics every 2 seconds
    Timer.periodic(Duration(seconds: 2), (_) => _updateMetrics());
  }

  void _updateMetrics() {
    if (mounted) {
      setState(() {
        _report = OneClickLanguageToggleButton.getPerformanceReport();
        _cacheStats = OneClickLanguageToggleButton.getCacheStatistics();
        _memoryStats = OneClickLanguageToggleButton.getMemoryStats();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('性能监控', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            
            if (_report != null) ...[
              _buildMetricRow('响应时间', '${_report!.averageResponseTime.toStringAsFixed(1)}ms'),
              _buildMetricRow('帧率', '${_report!.currentFps.toStringAsFixed(1)} FPS'),
            ],
            
            if (_cacheStats != null) ...[
              _buildMetricRow('缓存命中率', '${(_cacheStats!.hitRate * 100).toStringAsFixed(1)}%'),
              _buildMetricRow('缓存大小', '${_cacheStats!.size} 项'),
            ],
            
            if (_memoryStats != null) ...[
              _buildMetricRow('内存使用', '${(_memoryStats!.currentUsage / 1024 / 1024).toStringAsFixed(1)}MB'),
            ],
            
            SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _performCleanup,
                    child: Text('清理缓存'),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _checkMemoryLeaks,
                    child: Text('检查泄漏'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(value, style: TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  void _performCleanup() {
    OneClickLanguageToggleButton.performCleanup();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('缓存已清理')),
    );
  }

  void _checkMemoryLeaks() {
    final leaks = OneClickLanguageToggleButton.detectMemoryLeaks();
    final message = leaks.isEmpty 
        ? '未检测到内存泄漏' 
        : '检测到 ${leaks.length} 个内存泄漏';
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: leaks.isEmpty ? Colors.green : Colors.orange,
      ),
    );
  }
}
```

### 自定义错误处理 / Custom Error Handling

```dart
class CustomLanguageToggleButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _handleToggle(context),
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Color(0xFF4FC3F7).withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Color(0xFF4FC3F7)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            OneClickLanguageToggleButton(size: 32),
            SizedBox(width: 8),
            Text('切换语言'),
          ],
        ),
      ),
    );
  }

  Future<void> _handleToggle(BuildContext context) async {
    // 显示加载指示器 / Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      await context.toggleLanguage();
      
      // 关闭加载指示器 / Close loading indicator
      Navigator.of(context).pop();
      
      // 显示成功消息 / Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('语言切换成功'),
            ],
          ),
          backgroundColor: Colors.green,
        ),
      );
      
    } catch (e) {
      // 关闭加载指示器 / Close loading indicator
      Navigator.of(context).pop();
      
      // 显示错误对话框 / Show error dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('切换失败'),
          content: Text('语言切换失败: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('确定'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _handleToggle(context); // 重试 / Retry
              },
              child: Text('重试'),
            ),
          ],
        ),
      );
    }
  }
}
```

## 可访问性最佳实践 / Accessibility Best Practices

### 语义标签增强 / Enhanced Semantic Labels

```dart
class AccessibleLanguageToggle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        final currentLanguage = state is AppReadyState ? state.languageCode : 'zh';
        final currentName = currentLanguage == 'zh' ? '中文' : 'English';
        final nextName = currentLanguage == 'zh' ? 'English' : '中文';
        
        return Semantics(
          label: '语言切换按钮',
          hint: '当前语言是$currentName，点击切换到$nextName',
          value: currentName,
          button: true,
          enabled: true,
          onTap: () => context.toggleLanguage(),
          child: OneClickLanguageToggleButton(),
        );
      },
    );
  }
}
```

### 键盘导航支持 / Keyboard Navigation Support

```dart
class KeyboardFriendlyToggle extends StatefulWidget {
  @override
  _KeyboardFriendlyToggleState createState() => _KeyboardFriendlyToggleState();
}

class _KeyboardFriendlyToggleState extends State<KeyboardFriendlyToggle> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      onKeyEvent: _handleKeyEvent,
      child: Container(
        decoration: BoxDecoration(
          border: _isFocused 
              ? Border.all(color: Colors.blue, width: 2)
              : null,
          borderRadius: BorderRadius.circular(20),
        ),
        child: OneClickLanguageToggleButton(),
      ),
    );
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.space ||
          event.logicalKey == LogicalKeyboardKey.enter) {
        context.toggleLanguage();
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }
}
```

## 测试指南 / Testing Guide

### 单元测试示例 / Unit Test Examples

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:prvin/core/widgets/one_click_language_toggle_button.dart';

void main() {
  group('OneClickLanguageToggleButton Tests', () {
    testWidgets('should display current language', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OneClickLanguageToggleButton(),
          ),
        ),
      );

      // 验证按钮存在 / Verify button exists
      expect(find.byType(OneClickLanguageToggleButton), findsOneWidget);
      
      // 验证显示文本 / Verify display text
      expect(find.text('中'), findsOneWidget);
    });

    testWidgets('should toggle language on tap', (tester) async {
      await tester.pumpWidget(testApp);

      // 点击按钮 / Tap button
      await tester.tap(find.byType(OneClickLanguageToggleButton));
      await tester.pumpAndSettle();

      // 验证语言已切换 / Verify language switched
      expect(find.text('EN'), findsOneWidget);
    });

    testWidgets('should handle keyboard navigation', (tester) async {
      await tester.pumpWidget(testApp);

      // 获取焦点 / Get focus
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();

      // 按空格键切换 / Press space to toggle
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle();

      // 验证切换成功 / Verify toggle success
      expect(find.text('EN'), findsOneWidget);
    });
  });
}
```

### 集成测试示例 / Integration Test Examples

```dart
import 'package:integration_test/integration_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Language Toggle Integration Tests', () {
    testWidgets('should persist language across app restarts', (tester) async {
      // 启动应用 / Launch app
      await tester.pumpWidget(MyApp());
      await tester.pumpAndSettle();

      // 切换到英文 / Switch to English
      await tester.tap(find.byType(OneClickLanguageToggleButton));
      await tester.pumpAndSettle();

      // 验证切换成功 / Verify switch success
      expect(find.text('EN'), findsOneWidget);

      // 重启应用 / Restart app
      await tester.binding.defaultBinaryMessenger.send(
        'flutter/platform',
        const StandardMethodCodec().encodeMethodCall(
          const MethodCall('SystemNavigator.pop'),
        ),
      );
      
      await tester.pumpWidget(MyApp());
      await tester.pumpAndSettle();

      // 验证语言保持 / Verify language persisted
      expect(find.text('EN'), findsOneWidget);
    });

    testWidgets('should maintain app state during language switch', (tester) async {
      await tester.pumpWidget(MyApp());
      await tester.pumpAndSettle();

      // 创建一个任务 / Create a task
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      
      await tester.enterText(find.byType(TextField), '测试任务');
      await tester.tap(find.text('保存'));
      await tester.pumpAndSettle();

      // 验证任务存在 / Verify task exists
      expect(find.text('测试任务'), findsOneWidget);

      // 切换语言 / Switch language
      await tester.tap(find.byType(OneClickLanguageToggleButton));
      await tester.pumpAndSettle();

      // 验证任务仍然存在 / Verify task still exists
      expect(find.text('测试任务'), findsOneWidget);
    });
  });
}
```

## 性能优化建议 / Performance Optimization Tips

### 1. 合理使用缓存 / Proper Cache Usage

```dart
// 在应用启动时预热缓存 / Warmup cache on app startup
void main() {
  runApp(MyApp());
  
  // 预热性能组件 / Warmup performance components
  OneClickLanguageToggleButton.warmupPerformanceComponents();
}
```

### 2. 监控性能指标 / Monitor Performance Metrics

```dart
class PerformanceAwareApp extends StatefulWidget {
  @override
  _PerformanceAwareAppState createState() => _PerformanceAwareAppState();
}

class _PerformanceAwareAppState extends State<PerformanceAwareApp> {
  late Timer _performanceTimer;

  @override
  void initState() {
    super.initState();
    
    // 每30秒检查一次性能 / Check performance every 30 seconds
    _performanceTimer = Timer.periodic(Duration(seconds: 30), (_) {
      _checkPerformance();
    });
  }

  @override
  void dispose() {
    _performanceTimer.cancel();
    super.dispose();
  }

  void _checkPerformance() {
    final report = OneClickLanguageToggleButton.getPerformanceReport();
    
    // 如果性能下降，清理缓存 / If performance degrades, cleanup cache
    if (report.averageResponseTime > 300 || report.currentFps < 50) {
      OneClickLanguageToggleButton.performCleanup();
      print('性能优化：已清理缓存');
    }
    
    // 检查内存泄漏 / Check memory leaks
    final leaks = OneClickLanguageToggleButton.detectMemoryLeaks();
    if (leaks.isNotEmpty) {
      print('警告：检测到 ${leaks.length} 个内存泄漏');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}
```

### 3. 优化动画性能 / Optimize Animation Performance

```dart
class OptimizedLanguageToggle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 检查设备性能 / Check device performance
    final isLowEndDevice = _isLowEndDevice();
    
    return OneClickLanguageToggleButton(
      // 低端设备使用更短的动画 / Use shorter animation on low-end devices
      animationDuration: isLowEndDevice 
          ? Duration(milliseconds: 150)
          : Duration(milliseconds: 300),
    );
  }

  bool _isLowEndDevice() {
    // 简单的设备性能检测 / Simple device performance detection
    final report = OneClickLanguageToggleButton.getPerformanceReport();
    return report.currentFps < 45;
  }
}
```

## 故障排除 / Troubleshooting

### 常见问题解决方案 / Common Issue Solutions

#### 1. 按钮无响应 / Button Not Responding

```dart
// 检查AppBloc状态 / Check AppBloc state
void debugButtonIssue(BuildContext context) {
  final appBloc = context.read<AppBloc>();
  final state = appBloc.state;
  
  print('AppBloc状态: ${state.runtimeType}');
  
  if (state is! AppReadyState) {
    print('错误：AppBloc未处于就绪状态');
    // 尝试重新初始化 / Try to reinitialize
    appBloc.add(AppInitializeEvent());
  }
}
```

#### 2. 动画卡顿 / Animation Stuttering

```dart
// 检查动画性能 / Check animation performance
void debugAnimationIssue() {
  final status = OneClickLanguageToggleButton.getAnimationPerformanceStatus();
  final report = OneClickLanguageToggleButton.getAnimationStateReport();
  
  print('动画性能状态: $status');
  print('动画状态报告: ${report.toString()}');
  
  if (!report.allStable) {
    print('警告：检测到不稳定的动画');
    // 强制清理动画状态 / Force cleanup animation state
    OneClickLanguageToggleButton.performCleanup();
  }
}
```

#### 3. 内存使用过高 / High Memory Usage

```dart
// 监控内存使用 / Monitor memory usage
void monitorMemoryUsage() {
  final memoryStats = OneClickLanguageToggleButton.getMemoryStats();
  final leaks = OneClickLanguageToggleButton.detectMemoryLeaks();
  
  print('当前内存使用: ${(memoryStats.currentUsage / 1024 / 1024).toStringAsFixed(1)}MB');
  
  if (leaks.isNotEmpty) {
    print('检测到内存泄漏: ${leaks.length}个');
    
    // 执行清理 / Perform cleanup
    OneClickLanguageToggleButton.performCleanup();
    
    // 强制垃圾回收 / Force garbage collection
    // 注意：这只是示例，实际应用中应谨慎使用
  }
}
```

## 最佳实践总结 / Best Practices Summary

### 1. 组件使用 / Component Usage
- ✅ 使用合适的尺寸（32-56px）
- ✅ 配置适当的动画时长（200-500ms）
- ✅ 在AppBar或工具栏中使用
- ❌ 避免过小或过大的尺寸
- ❌ 避免过长的动画时长

### 2. 错误处理 / Error Handling
- ✅ 始终使用try-catch包装切换操作
- ✅ 提供用户友好的错误提示
- ✅ 实现重试机制
- ❌ 不要忽略异常
- ❌ 不要阻塞UI线程

### 3. 性能优化 / Performance Optimization
- ✅ 定期监控性能指标
- ✅ 适时清理缓存和内存
- ✅ 在低端设备上使用简化动画
- ❌ 不要频繁创建新实例
- ❌ 不要忽略内存泄漏

### 4. 可访问性 / Accessibility
- ✅ 提供清晰的语义标签
- ✅ 支持键盘导航
- ✅ 适配高对比度模式
- ❌ 不要忽略屏幕阅读器用户
- ❌ 不要依赖仅视觉的反馈

### 5. 测试 / Testing
- ✅ 编写单元测试和集成测试
- ✅ 测试可访问性功能
- ✅ 测试性能和内存使用
- ❌ 不要跳过边缘情况测试
- ❌ 不要忽略错误处理测试

通过遵循这些最佳实践，您可以确保一键语言切换功能在您的应用中稳定、高效地运行。

By following these best practices, you can ensure that the one-click language toggle feature runs stably and efficiently in your application.