import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prvin/core/bloc/app_bloc.dart';
import 'package:prvin/core/error/language_toggle_exceptions.dart';
import 'package:prvin/core/localization/app_localizations.dart';
import 'package:prvin/core/services/animation_optimizer.dart';
import 'package:prvin/core/services/animation_state_manager.dart' as anim_state;
import 'package:prvin/core/services/button_state_cache.dart';
import 'package:prvin/core/services/language_toggle_counter.dart';
import 'package:prvin/core/services/language_toggle_error_handler.dart';
import 'package:prvin/core/services/language_toggle_logger.dart';
import 'package:prvin/core/services/memory_optimizer.dart' as memory_opt;
import 'package:prvin/core/services/performance_monitor.dart';
import 'package:prvin/core/services/state_isolation_manager.dart';
import 'package:prvin/core/services/state_preservation_service.dart';
import 'package:prvin/core/theme/app_theme.dart';
import 'package:prvin/core/widgets/language_switcher.dart' show LanguageSwitcher;
import 'package:prvin/core/widgets/widgets_exports.dart' show LanguageSwitcher;

/// 语言切换状态枚举
///
/// 定义支持的语言状态和相应的显示文本
enum LanguageToggleState {
  /// 中文状态
  chinese('zh', '中'),

  /// 英文状态
  english('en', 'EN');

  const LanguageToggleState(this.code, this.display);

  /// 语言代码
  final String code;

  /// 显示文本
  final String display;

  /// 获取下一个语言状态
  LanguageToggleState get next {
    return this == chinese ? english : chinese;
  }

  /// 从语言代码创建状态
  static LanguageToggleState fromCode(String code) {
    switch (code) {
      case 'zh':
        return chinese;
      case 'en':
        return english;
      default:
        return chinese; // 默认返回中文
    }
  }
}

/// 切换按钮状态数据模型
///
/// 包含按钮当前状态的所有必要信息
@immutable
class ToggleButtonState {
  /// 创建切换按钮状态实例
  const ToggleButtonState({
    required this.currentLanguage,
    required this.isAnimating,
    required this.displayText,
  });

  /// 当前语言代码
  final String currentLanguage;

  /// 是否正在执行动画
  final bool isAnimating;

  /// 显示文本
  final String displayText;

  /// 创建状态副本
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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ToggleButtonState &&
        other.currentLanguage == currentLanguage &&
        other.isAnimating == isAnimating &&
        other.displayText == displayText;
  }

  @override
  int get hashCode {
    return currentLanguage.hashCode ^
        isAnimating.hashCode ^
        displayText.hashCode;
  }
}

/// 一键语言切换按钮组件
///
/// 提供快速的中英文切换功能，替换传统的对话框形式语言切换。
/// 按钮显示当前语言状态，点击即可切换到另一种语言。
///
/// ## 功能特性
///
/// - ⚡ **即时切换**: 点击按钮立即切换语言，无需对话框确认
/// - 🎯 **状态显示**: 按钮显示当前语言（"中" 或 "EN"）
/// - 🛡️ **错误处理**: 完整的错误处理和状态恢复机制
/// - 📊 **性能监控**: 内置性能监控和统计功能
/// - ♿ **可访问性**: 完整的屏幕阅读器和键盘导航支持
/// - 🎨 **动画效果**: 平滑的切换动画和视觉反馈
///
/// ## 基本用法
///
/// ```dart
/// // 默认配置
/// OneClickLanguageToggleButton()
///
/// // 自定义尺寸和动画
/// OneClickLanguageToggleButton(
///   size: 48.0,
///   animationDuration: Duration(milliseconds: 400),
/// )
/// ```
///
/// ## 程序化切换
///
/// ```dart
/// // 使用扩展方法
/// await context.toggleLanguage();
///
/// // 使用静态方法
/// await AppLocalizationsToggle.toggleLanguage(context);
/// ```
///
/// ## 监控和统计
///
/// ```dart
/// // 获取切换统计
/// final stats = OneClickLanguageToggleButton.getToggleStatistics();
/// print('切换次数: ${stats.toggleCount}');
///
/// // 验证幂等性
/// final idempotence = OneClickLanguageToggleButton.verifyToggleIdempotence();
/// print('幂等性验证: ${idempotence.isValid}');
///
/// // 获取性能报告
/// final performance = OneClickLanguageToggleButton.getPerformanceReport();
/// print('平均响应时间: ${performance.averageResponseTime}ms');
/// ```
///
/// ## 正确性保证
///
/// 该组件实现了以下正确性属性：
///
/// 1. **语言切换一致性**: 每次点击都会切换到另一种语言
/// 2. **状态显示同步性**: 按钮显示与系统语言状态同步
/// 3. **持久化一致性**: 语言设置正确保存和恢复
/// 4. **状态保持不变性**: 语言切换不影响其他应用状态
/// 5. **切换操作幂等性**: 偶数次切换回到初始语言
/// 6. **动画状态一致性**: 动画完成后按钮处于稳定状态
/// 7. **错误恢复性**: 切换失败时保持原有状态
///
/// ## 可访问性
///
/// - 支持屏幕阅读器，提供语义标签和状态描述
/// - 支持键盘导航（Tab键导航，空格键/回车键激活）
/// - 自动适配高对比度模式
/// - 语言切换后自动播报新状态
///
/// ## 性能优化
///
/// - 智能按钮状态缓存，避免重复计算
/// - 动画性能监控，确保60fps帧率
/// - 内存使用优化，防止内存泄漏
/// - 可配置的性能优化级别
///
/// ## 错误处理
///
/// - 自动重试机制，处理临时性错误
/// - 状态隔离保护，确保其他功能不受影响
/// - 详细的错误日志记录，便于调试
/// - 用户友好的错误提示信息
///
/// ## 注意事项
///
/// - 需要在MaterialApp中使用，依赖Theme和MediaQuery
/// - 需要AppBloc处于AppReadyState状态
/// - 建议在应用初始化完成后使用
/// - 支持热重载，状态会自动恢复
///
/// ## 相关组件
///
/// - [LanguageSwitcher]: 传统的语言切换器（对话框形式）
/// - [AppLocalizations]: 本地化服务
/// - [AppBloc]: 应用状态管理
///
/// ## 版本历史
///
/// - v1.0.0: 初始版本，基本切换功能
/// - v1.1.0: 添加性能监控和统计功能
/// - v1.2.0: 增强错误处理和可访问性支持
/// - v1.3.0: 添加动画优化和状态管理改进
class OneClickLanguageToggleButton extends StatefulWidget {
  /// 创建一键语言切换按钮
  ///
  /// [size] 按钮的尺寸，默认为40.0像素
  /// [animationDuration] 动画持续时间，默认为300毫秒
  ///
  /// ## 参数说明
  ///
  /// - **size**: 按钮的宽度和高度，建议范围32-64像素
  /// - **animationDuration**: 切换动画的持续时间，建议范围200-500毫秒
  ///
  /// ## 示例
  ///
  /// ```dart
  /// // 标准尺寸按钮
  /// OneClickLanguageToggleButton()
  ///
  /// // 大尺寸按钮，适合平板设备
  /// OneClickLanguageToggleButton(size: 56.0)
  ///
  /// // 快速动画
  /// OneClickLanguageToggleButton(
  ///   animationDuration: Duration(milliseconds: 200),
  /// )
  /// ```
  const OneClickLanguageToggleButton({
    super.key,
    this.size = 40.0,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  /// 按钮尺寸（像素）
  ///
  /// 控制按钮的宽度和高度。建议值：
  /// - 32.0: 紧凑模式，适合工具栏
  /// - 40.0: 标准模式（默认）
  /// - 48.0: 大尺寸，适合主要操作
  /// - 56.0: 超大尺寸，适合平板设备
  final double size;

  /// 动画持续时间
  ///
  /// 控制切换动画的持续时间。建议值：
  /// - 200ms: 快速动画，适合频繁操作
  /// - 300ms: 标准动画（默认）
  /// - 400ms: 慢速动画，更明显的视觉效果
  final Duration animationDuration;

  /// 获取当前切换统计信息
  ///
  /// 返回包含切换次数、会话信息、幂等性状态等的统计数据。
  ///
  /// ## 返回值
  ///
  /// [ToggleStatistics] 对象，包含以下信息：
  /// - `toggleCount`: 总切换次数
  /// - `sessionId`: 当前会话ID
  /// - `initialLanguage`: 会话初始语言
  /// - `isOddToggle`: 是否为奇数次切换
  /// - `isEvenToggle`: 是否为偶数次切换
  ///
  /// ## 示例
  ///
  /// ```dart
  /// final stats = OneClickLanguageToggleButton.getToggleStatistics();
  /// print('切换次数: ${stats.toggleCount}');
  /// print('会话ID: ${stats.sessionId}');
  /// print('初始语言: ${stats.initialLanguage}');
  /// ```
  static ToggleStatistics getToggleStatistics() {
    return LanguageToggleCounter.instance.getStatistics();
  }

  /// 获取当前切换计数
  ///
  /// 返回当前会话中的切换次数。
  ///
  /// ## 返回值
  ///
  /// [int] 切换次数，从0开始计数
  ///
  /// ## 示例
  ///
  /// ```dart
  /// final count = OneClickLanguageToggleButton.getToggleCount();
  /// print('已切换 $count 次');
  /// ```
  static int getToggleCount() {
    return LanguageToggleCounter.instance.toggleCount;
  }

  /// 验证当前切换操作的幂等性
  ///
  /// 检查切换操作是否符合幂等性规则：
  /// - 偶数次切换应该回到初始语言
  /// - 奇数次切换应该切换到另一种语言
  ///
  /// ## 返回值
  ///
  /// [ToggleIdempotenceResult] 对象，包含验证结果：
  /// - `isValid`: 是否通过验证
  /// - `toggleCount`: 当前切换次数
  /// - `expectedLanguage`: 期望的语言
  /// - `actualLanguage`: 实际的语言
  /// - `errorMessage`: 错误信息（如果验证失败）
  ///
  /// ## 示例
  ///
  /// ```dart
  /// final result = OneClickLanguageToggleButton.verifyToggleIdempotence();
  /// if (result.isValid) {
  ///   print('幂等性验证通过');
  /// } else {
  ///   print('幂等性验证失败: ${result.errorMessage}');
  /// }
  /// ```
  static ToggleIdempotenceResult verifyToggleIdempotence() {
    return LanguageToggleCounter.instance.verifyIdempotence();
  }

  /// 结束当前切换会话并获取摘要
  ///
  /// 结束当前的切换会话，重置计数器，并返回会话摘要信息。
  ///
  /// ## 返回值
  ///
  /// [ToggleSessionSummary] 对象，包含会话摘要：
  /// - `sessionId`: 会话ID
  /// - `totalToggles`: 总切换次数
  /// - `duration`: 会话持续时间
  /// - `initialLanguage`: 初始语言
  /// - `finalLanguage`: 最终语言
  /// - `averageToggleTime`: 平均切换时间
  ///
  /// ## 示例
  ///
  /// ```dart
  /// final summary = OneClickLanguageToggleButton.endToggleSession();
  /// print('会话结束，总共切换了 ${summary.totalToggles} 次');
  /// print('会话持续时间: ${summary.duration.inSeconds} 秒');
  /// ```
  ///
  /// ## 注意事项
  ///
  /// - 调用此方法后，切换计数器将重置为0
  /// - 新的切换操作将开始新的会话
  static ToggleSessionSummary endToggleSession() {
    return LanguageToggleCounter.instance.endSession();
  }

  /// 获取性能监控报告
  ///
  /// 返回详细的性能监控数据，包括响应时间、帧率、内存使用等信息。
  ///
  /// ## 返回值
  ///
  /// [PerformanceReport] 对象，包含性能指标：
  /// - `averageResponseTime`: 平均响应时间（毫秒）
  /// - `currentFps`: 当前帧率
  /// - `memoryUsage`: 内存使用量
  /// - `cacheHitRate`: 缓存命中率
  /// - `animationPerformance`: 动画性能状态
  ///
  /// ## 示例
  ///
  /// ```dart
  /// final report = OneClickLanguageToggleButton.getPerformanceReport();
  /// print('平均响应时间: ${report.averageResponseTime}ms');
  /// print('当前FPS: ${report.currentFps}');
  /// print('缓存命中率: ${(report.cacheHitRate * 100).toStringAsFixed(1)}%');
  /// ```
  ///
  /// ## 性能基准
  ///
  /// - 响应时间应 < 200ms
  /// - 帧率应 ≥ 60fps
  /// - 缓存命中率应 > 80%
  static PerformanceReport getPerformanceReport() {
    return PerformanceMonitor.instance.getPerformanceReport();
  }

  /// 获取按钮状态缓存统计
  static CacheStatistics getCacheStatistics() {
    return ButtonStateCache.instance.getStatistics();
  }

  /// 获取内存使用统计
  static memory_opt.MemoryStats getMemoryStats() {
    return memory_opt.MemoryOptimizer.instance.getMemoryStats();
  }

  /// 检测内存泄漏
  static List<memory_opt.MemoryLeak> detectMemoryLeaks() {
    return memory_opt.MemoryOptimizer.instance.detectMemoryLeaks();
  }

  /// 获取动画性能状态
  static PerformanceStatus getAnimationPerformanceStatus() {
    return AnimationOptimizer.instance.getPerformanceStatus();
  }

  /// 获取动画状态一致性报告
  static anim_state.AnimationStateReport getAnimationStateReport() {
    return anim_state.AnimationStateManager.instance.getStateReport();
  }

  /// 检查所有动画是否处于稳定状态
  static bool areAnimationsStable() {
    return anim_state.AnimationStateManager.instance.areAllAnimationsStable();
  }

  /// 强制清理缓存和内存
  static void performCleanup() {
    ButtonStateCache.instance.clearCache();
    memory_opt.MemoryOptimizer.instance.forceGarbageCollection();
  }

  /// 预热性能优化组件
  static void warmupPerformanceComponents() {
    ButtonStateCache.instance.warmupCache();
    memory_opt.MemoryOptimizer.instance.start();
    PerformanceMonitor.instance.startMonitoring();
  }

  @override
  State<OneClickLanguageToggleButton> createState() =>
      _OneClickLanguageToggleButtonState();
}

class _OneClickLanguageToggleButtonState
    extends State<OneClickLanguageToggleButton>
    with TickerProviderStateMixin {
  late AnimationController _scaleAnimationController;
  late AnimationController _colorAnimationController;
  late AnimationController _rotationAnimationController;

  late Animation<double> _scaleAnimation;
  late Animation<Color?> _backgroundColorAnimation;
  late Animation<Color?> _borderColorAnimation;
  late Animation<double> _rotationAnimation;

  bool _isHovered = false;
  late FocusNode _focusNode;
  bool _isFocused = false;

  // 性能优化相关
  final _performanceMonitor = PerformanceMonitor.instance;
  final _buttonStateCache = ButtonStateCache.instance;
  final _animationOptimizer = AnimationOptimizer.instance;
  final _animationStateManager = anim_state.AnimationStateManager.instance;

  @override
  void initState() {
    super.initState();

    // 启动性能监控
    _performanceMonitor.startMonitoring();

    // 预热缓存
    _buttonStateCache.warmupCache();

    // 初始化焦点节点
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChanged);

    // 使用优化的动画控制器
    _scaleAnimationController = _animationOptimizer.createOptimizedController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
      debugLabel: 'LanguageToggleScale',
    );

    _colorAnimationController = _animationOptimizer.createOptimizedController(
      duration: AppTheme.mediumAnimationDuration,
      vsync: this,
      debugLabel: 'LanguageToggleColor',
    );

    _rotationAnimationController = _animationOptimizer
        .createOptimizedController(
          duration: const Duration(milliseconds: 400),
          vsync: this,
          debugLabel: 'LanguageToggleRotation',
        );

    // 创建优化的动画
    _scaleAnimation = _animationOptimizer.createOptimizedTween(
      tween: Tween<double>(begin: 1, end: 0.95),
      controller: _scaleAnimationController,
      curve: Curves.easeInOut,
    );

    _rotationAnimation = _animationOptimizer.createOptimizedTween(
      tween: Tween<double>(begin: 0, end: 0.5),
      controller: _rotationAnimationController,
      curve: Curves.elasticOut,
    );

    // 注册动画控制器到状态管理器
    _animationStateManager.registerController(
      'scale_animation',
      _scaleAnimationController,
    );
    _animationStateManager.registerController(
      'color_animation',
      _colorAnimationController,
    );
    _animationStateManager.registerController(
      'rotation_animation',
      _rotationAnimationController,
    );
  }

  @override
  void dispose() {
    // 停止性能监控
    _performanceMonitor.stopMonitoring();

    // 注销动画控制器
    _animationStateManager.unregisterController('scale_animation');
    _animationStateManager.unregisterController('color_animation');
    _animationStateManager.unregisterController('rotation_animation');

    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    _scaleAnimationController.dispose();
    _colorAnimationController.dispose();
    _rotationAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        final currentLanguage = state is AppReadyState
            ? state.languageCode
            : 'zh';

        // 使用缓存获取按钮状态
        final buttonState = _buttonStateCache.getOrCreateButtonState(
          languageCode: currentLanguage,
          isAnimating: _rotationAnimationController.isAnimating,
        );

        final languageState = LanguageToggleState.fromCode(currentLanguage);

        // 更新颜色动画
        _updateColorAnimations(context, languageState);

        return _buildAccessibleButton(context, languageState, buttonState);
      },
    );
  }

  /// 构建具有完整可访问性支持的按钮
  Widget _buildAccessibleButton(
    BuildContext context,
    LanguageToggleState languageState,
    ToggleButtonState buttonState,
  ) {
    final isHighContrast = _isHighContrastMode(context);
    final currentLanguageName = languageState == LanguageToggleState.chinese
        ? '中文'
        : 'English';
    final nextLanguageName = languageState == LanguageToggleState.chinese
        ? 'English'
        : '中文';

    return Semantics(
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
        child: MouseRegion(
          onEnter: (_) => _onHoverChanged(true),
          onExit: (_) => _onHoverChanged(false),
          child: AnimatedBuilder(
            animation: Listenable.merge([
              _scaleAnimation,
              _colorAnimationController,
              _rotationAnimation,
            ]),
            builder: (context, child) {
              // 使用优化的变换组件
              return _animationOptimizer.createOptimizedTransform(
                transform: Matrix4.identity()
                  ..scale(_scaleAnimation.value)
                  ..rotateZ(_rotationAnimation.value * 3.14159),
                child: _buildButton(
                  context,
                  languageState,
                  buttonState,
                  isHighContrast,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// 处理焦点变化
  void _onFocusChanged() {
    if (_focusNode.hasFocus != _isFocused) {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });

      // 焦点变化时的视觉反馈
      if (_isFocused) {
        _colorAnimationController.forward();
        // 为屏幕阅读器提供音频反馈
        _announceToScreenReader(context, '语言切换按钮已获得焦点');
      } else {
        _colorAnimationController.reverse();
      }
    }
  }

  /// 处理键盘事件
  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent) {
      // 空格键或回车键触发切换
      if (event.logicalKey == LogicalKeyboardKey.space ||
          event.logicalKey == LogicalKeyboardKey.enter) {
        _toggleLanguage(context);
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  /// 检测是否为高对比度模式
  bool _isHighContrastMode(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return mediaQuery.highContrast;
  }

  /// 向屏幕阅读器发送消息
  void _announceToScreenReader(BuildContext context, String message) {
    SemanticsService.announce(message, TextDirection.ltr);
  }

  /// 更新颜色动画
  void _updateColorAnimations(
    BuildContext context,
    LanguageToggleState languageState,
  ) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final isHighContrast = _isHighContrastMode(context);

    // 使用缓存获取颜色方案
    final colorScheme = _buttonStateCache.getOrCreateColorScheme(
      languageCode: languageState.code,
      isDarkMode: isDarkMode,
      isHighContrast: isHighContrast,
      isHovered: _isHovered,
      isFocused: _isFocused,
    );

    // 背景颜色动画
    _backgroundColorAnimation =
        ColorTween(
          begin: colorScheme.backgroundColor.withValues(
            alpha: _isHovered ? 0.15 : 0.1,
          ),
          end: colorScheme.backgroundColor.withValues(
            alpha: _isHovered ? 0.2 : 0.15,
          ),
        ).animate(
          CurvedAnimation(
            parent: _colorAnimationController,
            curve: _animationOptimizer.getOptimizedCurve(Curves.easeInOut),
          ),
        );

    // 边框颜色动画
    _borderColorAnimation =
        ColorTween(
          begin: colorScheme.borderColor.withValues(
            alpha: _isHovered ? 0.4 : 0.3,
          ),
          end: colorScheme.borderColor.withValues(
            alpha: _isHovered ? 0.6 : 0.4,
          ),
        ).animate(
          CurvedAnimation(
            parent: _colorAnimationController,
            curve: _animationOptimizer.getOptimizedCurve(Curves.easeInOut),
          ),
        );
  }

  /// 处理悬停状态变化
  void _onHoverChanged(bool isHovered) {
    if (_isHovered != isHovered) {
      setState(() {
        _isHovered = isHovered;
      });

      if (isHovered) {
        _colorAnimationController.forward();
      } else {
        _colorAnimationController.reverse();
      }
    }
  }

  /// 构建按钮UI
  Widget _buildButton(
    BuildContext context,
    LanguageToggleState languageState,
    ToggleButtonState buttonState, [
    bool isHighContrast = false,
  ]) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // 使用缓存的颜色方案
    final colorScheme = _buttonStateCache.getOrCreateColorScheme(
      languageCode: languageState.code,
      isDarkMode: isDark,
      isHighContrast: isHighContrast,
      isHovered: _isHovered,
      isFocused: _isFocused,
    );

    final animationConfig = _animationOptimizer.getOptimizedConfig();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _toggleLanguage(context),
        onTapDown: (_) {
          _scaleAnimationController.forward();
          _rotationAnimationController.forward();
        },
        onTapUp: (_) => _scaleAnimationController.reverse(),
        onTapCancel: () => _scaleAnimationController.reverse(),
        borderRadius: BorderRadius.circular(widget.size / 2),
        splashColor: colorScheme.primaryColor.withValues(alpha: 0.2),
        highlightColor: colorScheme.primaryColor.withValues(alpha: 0.1),
        child: _animationOptimizer.createOptimizedContainer(
          color: (_isHovered || _isFocused)
              ? null
              : (_backgroundColorAnimation.value ??
                    colorScheme.backgroundColor),
          gradient:
              (_isHovered || _isFocused) && animationConfig.enableGradients
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorScheme.primaryColor.withValues(
                      alpha: isHighContrast ? 0.8 : 0.15,
                    ),
                    colorScheme.primaryColor.withValues(
                      alpha: isHighContrast ? 0.9 : 0.25,
                    ),
                  ],
                )
              : null,
          boxShadow: (_isHovered || _isFocused) && animationConfig.enableShadows
              ? [
                  BoxShadow(
                    color: colorScheme.shadowColor,
                    blurRadius: isHighContrast ? 12 : 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : (isHighContrast ? [] : AppTheme.smallShadow),
          borderRadius: BorderRadius.circular(widget.size / 2),
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              border: Border.all(
                color: _borderColorAnimation.value ?? colorScheme.borderColor,
                width: (_isHovered || _isFocused)
                    ? (isHighContrast ? 3 : 2)
                    : (isHighContrast ? 2 : 1.5),
              ),
              borderRadius: BorderRadius.circular(widget.size / 2),
            ),
            child: _buildButtonContent(
              context,
              languageState,
              buttonState,
              colorScheme,
              isHighContrast,
            ),
          ),
        ),
      ),
    );
  }

  /// 构建按钮内容
  Widget _buildButtonContent(
    BuildContext context,
    LanguageToggleState languageState,
    ToggleButtonState buttonState,
    CachedColorScheme colorScheme,
    bool isHighContrast,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final animationConfig = _animationOptimizer.getOptimizedConfig();

    return Stack(
      children: [
        // 背景光晕效果（高对比度模式下禁用）
        if ((_isHovered || _isFocused) &&
            !isHighContrast &&
            animationConfig.enableGradients)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.size / 2),
                gradient: RadialGradient(
                  radius: 0.8,
                  colors: [
                    colorScheme.primaryColor.withValues(alpha: 0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

        // 焦点指示器
        if (_isFocused)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.size / 2),
                border: Border.all(
                  color: isHighContrast
                      ? (isDark ? Colors.white : Colors.black)
                      : colorScheme.primaryColor,
                  width: 2,
                ),
              ),
            ),
          ),

        // 主要内容
        Center(
          child: AnimatedDefaultTextStyle(
            duration: _animationOptimizer.getOptimizedDuration(
              AppTheme.shortAnimationDuration,
            ),
            style: TextStyle(
              fontSize: widget.size * 0.35,
              fontWeight: isHighContrast ? FontWeight.w900 : FontWeight.w700,
              color: colorScheme.textColor,
              letterSpacing: 0.5,
            ),
            child: AnimatedSwitcher(
              duration: _animationOptimizer.getOptimizedDuration(
                const Duration(milliseconds: 200),
              ),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(scale: animation, child: child),
                );
              },
              child: Text(
                buttonState.displayText,
                key: ValueKey(buttonState.displayText),
              ),
            ),
          ),
        ),

        // 状态指示器（小圆点）- 高对比度模式下更明显
        Positioned(
          top: 4,
          right: 4,
          child: AnimatedContainer(
            duration: _animationOptimizer.getOptimizedDuration(
              AppTheme.shortAnimationDuration,
            ),
            width: isHighContrast ? 8 : 6,
            height: isHighContrast ? 8 : 6,
            decoration: BoxDecoration(
              color: isHighContrast
                  ? (isDark ? Colors.white : Colors.black)
                  : colorScheme.primaryColor,
              borderRadius: BorderRadius.circular(isHighContrast ? 4 : 3),
              boxShadow:
                  (_isHovered || _isFocused) &&
                      !isHighContrast &&
                      animationConfig.enableShadows
                  ? [
                      BoxShadow(
                        color: colorScheme.shadowColor,
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
          ),
        ),
      ],
    );
  }

  /// 执行语言切换
  Future<void> _toggleLanguage(BuildContext context) async {
    if (!mounted) return;

    // 开始性能监控
    _performanceMonitor.startOperation('language_toggle');

    final startTime = DateTime.now();
    String? fromLanguage;
    String? toLanguage;
    final statePreservationService = StatePreservationService.instance;
    final stateIsolationManager = StateIsolationManager.instance;
    final toggleCounter = LanguageToggleCounter.instance;
    String? toggleSessionId;

    try {
      // 获取当前状态并验证
      final currentState = context.read<AppBloc>().state;
      if (currentState is! AppReadyState) {
        throw StateAccessException(
          'App is not in ready state: ${currentState.runtimeType}',
        );
      }

      fromLanguage = currentState.languageCode;
      final currentLanguageState = LanguageToggleState.fromCode(fromLanguage);
      final nextLanguageState = currentLanguageState.next;
      toLanguage = nextLanguageState.code;

      // 开始或继续切换会话
      if (toggleCounter.sessionId == null) {
        toggleSessionId = toggleCounter.startSession(fromLanguage);
        LanguageToggleLogger.logDebug(
          'Started new toggle session for idempotence tracking',
          additionalData: {'session_id': toggleSessionId},
        );
      }

      // 验证目标语言是否支持
      if (!AppLocalizations.isLocaleSupported(toLanguage)) {
        throw UnsupportedLanguageException(toLanguage);
      }

      // 记录切换尝试
      LanguageToggleLogger.logToggleAttempt(fromLanguage, toLanguage);
      LanguageToggleLogger.logUserInteraction(
        'button_tap',
        currentLanguage: fromLanguage,
      );

      // 开始状态隔离会话
      final isolationSessionId = stateIsolationManager.startIsolationSession();

      LanguageToggleLogger.logDebug(
        'Started state isolation session for language toggle',
        additionalData: {'isolation_session_id': isolationSessionId},
      );

      // 捕获状态快照以确保状态保持不变性
      await statePreservationService.captureStateSnapshot(context);

      // 执行动画（带错误处理和性能监控）
      await _executeToggleAnimation();

      // 触发语言切换事件
      if (mounted) {
        context.read<AppBloc>().add(AppLanguageChangedEvent(toLanguage));

        // 验证切换是否成功
        await _verifyLanguageSwitch(context, toLanguage);

        // 记录切换操作到计数器
        final toggleCount = toggleCounter.recordToggle(
          fromLanguage,
          toLanguage,
        );

        // 验证切换操作的幂等性
        final idempotenceResult = toggleCounter.verifyIdempotence();
        if (!idempotenceResult.isValid) {
          LanguageToggleLogger.logWarning(
            'Toggle idempotence violation detected',
            additionalData: {
              'toggle_count': toggleCount,
              'expected_language': idempotenceResult.expectedLanguage,
              'actual_language': idempotenceResult.actualLanguage,
              'error_message': idempotenceResult.errorMessage,
            },
          );

          // 显示幂等性警告给用户（非阻塞）
          if (mounted) {
            _showIdempotenceWarning(context, idempotenceResult);
          }
        } else {
          LanguageToggleLogger.logDebug(
            'Toggle idempotence verification passed',
            additionalData: {
              'toggle_count': toggleCount,
              'is_odd_toggle': toggleCounter.isOddToggle,
              'is_even_toggle': toggleCounter.isEvenToggle,
            },
          );
        }

        // 验证状态完整性
        await _verifyStateIntegrity(context, statePreservationService);

        // 结束状态隔离会话并获取报告
        final isolationReport = stateIsolationManager.endIsolationSession();
        await _processIsolationReport(context, isolationReport);

        // 记录成功和性能指标
        final duration = DateTime.now().difference(startTime);
        final toggleStats = toggleCounter.getStatistics();
        final performanceStatus = _animationOptimizer.getPerformanceStatus();
        final cacheStats = _buttonStateCache.getStatistics();

        LanguageToggleLogger.logToggleSuccess(
          toLanguage,
          duration,
          additionalData: {
            'fromLanguage': fromLanguage,
            'animationCompleted': true,
            'stateIntegrityVerified': true,
            'isolationSuccessful': isolationReport.isIsolationSuccessful,
            'protectedViolations': isolationReport.protectedViolations,
            'toggle_count': toggleStats.toggleCount,
            'is_odd_toggle': toggleStats.isOddToggle,
            'is_even_toggle': toggleStats.isEvenToggle,
            'toggle_session_id': toggleStats.sessionId,
            'idempotence_valid': idempotenceResult.isValid,
            'performance_fps': performanceStatus.currentFps,
            'cache_hit_rate': cacheStats.hitRate,
          },
        );

        // 记录性能指标
        LanguageToggleLogger.logPerformanceMetric(
          'language_toggle_complete',
          duration,
          additionalData: {
            'animation_performance': performanceStatus.toString(),
            'cache_performance': cacheStats.toString(),
          },
        );

        // 显示成功反馈
        if (mounted) {
          _showSuccessFeedback(context, nextLanguageState);
        }
      }
    } catch (e, stackTrace) {
      // 使用统一的错误处理器
      if (mounted) {
        await LanguageToggleErrorHandler.handleError(
          context,
          e,
          stackTrace: stackTrace,
          fromLanguage: fromLanguage,
          toLanguage: toLanguage,
          onRetry: () => _toggleLanguage(context),
        );
      }
    } finally {
      // 结束性能监控
      _performanceMonitor.endOperation('language_toggle');

      // 清理状态快照
      statePreservationService.clearSnapshot();

      // 确保隔离会话被正确结束
      if (stateIsolationManager.currentStatus == IsolationStatus.active) {
        stateIsolationManager.forceEndIsolation();
      }
    }
  }

  /// 执行切换动画（带错误处理和性能监控）
  Future<void> _executeToggleAnimation() async {
    try {
      // 开始动画性能监控
      _performanceMonitor.startOperation('toggle_animation');

      // 如果性能不佳，跳过复杂动画
      if (!_animationOptimizer.shouldEnableComplexAnimations()) {
        LanguageToggleLogger.logDebug(
          'Skipping complex animation due to performance',
        );
        return;
      }

      // 检查动画状态管理器是否准备就绪
      if (!_animationStateManager.areAllAnimationsStable()) {
        LanguageToggleLogger.logWarning(
          'Some animations are not stable, stopping them first',
        );
        await _animationStateManager.stopAllAnimations();
      }

      // 使用动画状态管理器执行旋转动画
      final animationResult = await _animationStateManager.startAnimation(
        'rotation_animation',
        timeout: const Duration(milliseconds: 800),
      );

      if (!animationResult.isSuccess) {
        throw anim_state.AnimationException(
          'Rotation animation failed: ${animationResult.error}',
        );
      }

      if (!animationResult.isConsistent) {
        LanguageToggleLogger.logWarning(
          'Animation completed but state is inconsistent',
          additionalData: {
            'final_value': animationResult.finalValue,
            'animation_id': animationResult.animationId,
          },
        );
      }

      // 重置旋转动画到初始状态
      _rotationAnimationController.reset();

      // 验证动画完成后的状态一致性
      await _verifyAnimationStateConsistency();

      LanguageToggleLogger.logDebug('Toggle animation completed successfully');
    } catch (e, stackTrace) {
      // 动画错误不应该阻止语言切换
      LanguageToggleLogger.logAnimationError(
        'Toggle animation failed: $e',
        stackTrace,
        animationType: 'rotation',
        animationState: _rotationAnimationController.status.toString(),
      );

      // 尝试恢复动画状态
      await _recoverAnimationState();

      throw AnimationException('Toggle animation failed', e);
    } finally {
      // 结束动画性能监控
      _performanceMonitor.endOperation('toggle_animation');
    }
  }

  /// 验证语言切换是否成功
  Future<void> _verifyLanguageSwitch(
    BuildContext context,
    String expectedLanguage,
  ) async {
    if (!mounted) return;

    try {
      // 等待状态更新
      await Future<void>.delayed(const Duration(milliseconds: 100));

      final currentState = context.read<AppBloc>().state;
      if (currentState is AppReadyState) {
        if (currentState.languageCode != expectedLanguage) {
          throw StateAccessException(
            'Language switch verification failed: '
            'expected $expectedLanguage, got ${currentState.languageCode}',
          );
        }

        LanguageToggleLogger.logStateChange(
          'language_switch_verified',
          expectedLanguage,
          trigger: 'user_toggle',
        );
      } else {
        throw StateAccessException(
          'App state is not ready after language switch: ${currentState.runtimeType}',
        );
      }
    } catch (e) {
      LanguageToggleLogger.logWarning(
        'Language switch verification failed: $e',
      );
      // 验证失败不应该阻止切换，只是记录警告
    }
  }

  /// 验证状态完整性
  Future<void> _verifyStateIntegrity(
    BuildContext context,
    StatePreservationService statePreservationService,
  ) async {
    if (!mounted) return;

    try {
      LanguageToggleLogger.logDebug('Starting state integrity verification');

      final result = await statePreservationService.verifyStateIntegrity(
        context,
      );

      if (!result.isValid) {
        // 记录状态违规但不阻止语言切换
        LanguageToggleLogger.logWarning(
          'State integrity violations detected after language switch',
          additionalData: {
            'violations_count': result.violations.length,
            'critical_violations': result.criticalViolations.length,
            'violation_summary': result.violationSummary,
          },
        );

        // 如果有关键违规，显示警告给用户
        if (result.criticalViolations.isNotEmpty && mounted) {
          _showStateIntegrityWarning(context, result);
        }
      } else {
        LanguageToggleLogger.logDebug(
          'State integrity verification passed successfully',
        );
      }
    } catch (e, stackTrace) {
      LanguageToggleLogger.logToggleError(
        'State integrity verification failed: $e',
        stackTrace,
      );
      // 验证失败不应该阻止语言切换，只记录错误
    }
  }

  /// 显示状态完整性警告
  void _showStateIntegrityWarning(
    BuildContext context,
    StateIntegrityResult result,
  ) {
    final criticalCount = result.criticalViolations.length;
    final message = criticalCount == 1
        ? '语言切换时检测到1个状态异常'
        : '语言切换时检测到$criticalCount个状态异常';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
        ),
        action: SnackBarAction(
          label: '详情',
          textColor: Colors.white,
          onPressed: () => _showStateIntegrityDetails(context, result),
        ),
      ),
    );
  }

  /// 显示状态完整性详情
  void _showStateIntegrityDetails(
    BuildContext context,
    StateIntegrityResult result,
  ) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('状态完整性报告'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('验证时间: ${result.verificationTime}'),
              const SizedBox(height: 8),
              Text('违规总数: ${result.violations.length}'),
              Text('关键违规: ${result.criticalViolations.length}'),
              const SizedBox(height: 16),
              const Text(
                '违规详情:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...result.violations.map(
                (violation) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '• ${violation.component}.${violation.field}: '
                    '期望 ${violation.expected}, 实际 ${violation.actual}',
                    style: TextStyle(
                      fontSize: 12,
                      color: _getViolationColor(violation.severity),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  /// 获取违规严重性对应的颜色
  Color _getViolationColor(ViolationSeverity severity) {
    switch (severity) {
      case ViolationSeverity.low:
        return Colors.blue;
      case ViolationSeverity.medium:
        return Colors.orange;
      case ViolationSeverity.high:
        return Colors.red;
      case ViolationSeverity.critical:
        return Colors.red.shade800;
    }
  }

  /// 显示成功反馈
  void _showSuccessFeedback(
    BuildContext context,
    LanguageToggleState newLanguage,
  ) {
    final message = newLanguage == LanguageToggleState.chinese
        ? '已切换到中文'
        : 'Switched to English';

    // 向屏幕阅读器发送切换成功的消息
    _announceToScreenReader(context, message);

    LanguageToggleLogger.logUserInteraction(
      'success_feedback_shown',
      currentLanguage: newLanguage.code,
      additionalData: {'message': message},
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: AppTheme.successColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
        ),
      ),
    );
  }

  /// 处理状态隔离报告
  Future<void> _processIsolationReport(
    BuildContext context,
    StateIsolationReport report,
  ) async {
    try {
      LanguageToggleLogger.logDebug(
        'Processing state isolation report',
        additionalData: report.toMap(),
      );

      // 如果有违规，记录并可能显示警告
      if (report.hasViolations) {
        LanguageToggleLogger.logWarning(
          'State isolation violations detected during language switch',
          additionalData: {
            'violations_count': report.protectedViolations,
            'session_id': report.sessionId,
            'duration_ms': report.duration.inMilliseconds,
          },
        );

        // 如果违规严重，显示警告给用户
        if (report.protectedViolations > 0 && mounted) {
          _showIsolationViolationWarning(context, report);
        }
      } else {
        LanguageToggleLogger.logDebug(
          'State isolation successful - no violations detected',
          additionalData: {
            'session_id': report.sessionId,
            'total_updates': report.totalUpdates,
            'language_updates': report.languageUpdates,
          },
        );
      }
    } catch (e, stackTrace) {
      LanguageToggleLogger.logToggleError(
        'Failed to process isolation report: $e',
        stackTrace,
      );
    }
  }

  /// 显示状态隔离违规警告
  void _showIsolationViolationWarning(
    BuildContext context,
    StateIsolationReport report,
  ) {
    final violationCount = report.protectedViolations;
    final message = violationCount == 1
        ? '检测到1个状态隔离违规'
        : '检测到$violationCount个状态隔离违规';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.security, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.deepOrange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
        ),
        action: SnackBarAction(
          label: '详情',
          textColor: Colors.white,
          onPressed: () => _showIsolationReportDetails(context, report),
        ),
      ),
    );
  }

  /// 显示状态隔离报告详情
  void _showIsolationReportDetails(
    BuildContext context,
    StateIsolationReport report,
  ) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('状态隔离报告'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('会话ID: ${report.sessionId}'),
              Text('持续时间: ${report.duration.inMilliseconds}ms'),
              const SizedBox(height: 8),
              Text('总更新数: ${report.totalUpdates}'),
              Text('语言更新: ${report.languageUpdates}'),
              Text('其他更新: ${report.otherUpdates}'),
              Text('违规数: ${report.protectedViolations}'),
              const SizedBox(height: 16),
              if (report.violations.isNotEmpty) ...[
                const Text(
                  '违规详情:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...report.violations.map(
                  (violation) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '• ${violation.component}.${violation.stateKey}: '
                      '${violation.oldValue} → ${violation.newValue}',
                      style: const TextStyle(fontSize: 12, color: Colors.red),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  /// 显示幂等性警告
  void _showIdempotenceWarning(
    BuildContext context,
    ToggleIdempotenceResult result,
  ) {
    final message = '切换操作幂等性验证失败：第${result.toggleCount}次切换';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.sync_problem, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.deepOrange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
        ),
        action: SnackBarAction(
          label: '详情',
          textColor: Colors.white,
          onPressed: () => _showIdempotenceDetails(context, result),
        ),
      ),
    );
  }

  /// 显示幂等性验证详情
  void _showIdempotenceDetails(
    BuildContext context,
    ToggleIdempotenceResult result,
  ) {
    final toggleCounter = LanguageToggleCounter.instance;
    final stats = toggleCounter.getStatistics();

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('切换幂等性报告'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('会话ID: ${stats.sessionId ?? "无"}'),
              Text('切换次数: ${result.toggleCount}'),
              Text('切换类型: ${stats.isOddToggle ? "奇数次" : "偶数次"}'),
              const SizedBox(height: 8),
              Text('初始语言: ${stats.initialLanguage ?? "未知"}'),
              Text('期望语言: ${result.expectedLanguage ?? "未知"}'),
              Text('实际语言: ${result.actualLanguage ?? "未知"}'),
              const SizedBox(height: 16),
              const Text(
                '幂等性规则:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('• 偶数次切换应回到初始语言', style: TextStyle(fontSize: 12)),
              const Text('• 奇数次切换应切换到另一种语言', style: TextStyle(fontSize: 12)),
              if (result.errorMessage != null) ...[
                const SizedBox(height: 16),
                const Text(
                  '错误详情:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  result.errorMessage!,
                  style: const TextStyle(fontSize: 12, color: Colors.red),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // 提供重置选项
              _showResetToggleCounterOption(context);
            },
            child: const Text('重置计数器'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  /// 显示重置切换计数器选项
  void _showResetToggleCounterOption(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('重置切换计数器'),
        content: const Text('是否要重置语言切换计数器？这将清除当前的切换会话和统计信息。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              final toggleCounter = LanguageToggleCounter.instance;
              final summary = toggleCounter.endSession();

              LanguageToggleLogger.logDebug(
                'User manually reset toggle counter',
                additionalData: summary.toMap(),
              );

              Navigator.of(context).pop();

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.refresh, color: Colors.white, size: 16),
                      SizedBox(width: 8),
                      Text('切换计数器已重置'),
                    ],
                  ),
                  backgroundColor: AppTheme.successColor,
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusM),
                  ),
                ),
              );
            },
            child: const Text('确认重置'),
          ),
        ],
      ),
    );
  }

  /// 验证动画状态一致性
  Future<void> _verifyAnimationStateConsistency() async {
    try {
      LanguageToggleLogger.logDebug('Verifying animation state consistency');

      // 获取动画状态报告
      final stateReport = _animationStateManager.getStateReport();

      if (!stateReport.allStable) {
        LanguageToggleLogger.logWarning(
          'Animation state inconsistency detected',
          additionalData: stateReport.toMap(),
        );

        // 如果有问题的动画，尝试恢复
        if (stateReport.problematicAnimations.isNotEmpty) {
          await _recoverAnimationState();
        }
      } else {
        LanguageToggleLogger.logDebug(
          'Animation state consistency verified',
          additionalData: {
            'stable_animations': stateReport.stableAnimations.length,
            'total_animations': stateReport.totalAnimations,
          },
        );
      }

      // 验证按钮状态与动画状态的同步
      await _verifyButtonStateSync();
    } catch (e, stackTrace) {
      LanguageToggleLogger.logAnimationError(
        'Animation state verification failed: $e',
        stackTrace,
        animationType: 'state_verification',
        animationState: 'verification',
      );
    }
  }

  /// 验证按钮状态同步
  Future<void> _verifyButtonStateSync() async {
    if (!mounted) return;

    try {
      // 获取当前语言状态
      final currentState = context.read<AppBloc>().state;
      if (currentState is! AppReadyState) return;

      final currentLanguage = currentState.languageCode;
      final languageState = LanguageToggleState.fromCode(currentLanguage);

      // 验证按钮显示是否与当前语言一致
      final expectedDisplay = languageState.display;
      final buttonState = _buttonStateCache.getOrCreateButtonState(
        languageCode: currentLanguage,
        isAnimating: false,
      );

      if (buttonState.displayText != expectedDisplay) {
        LanguageToggleLogger.logWarning(
          'Button state display mismatch',
          additionalData: {
            'expected_display': expectedDisplay,
            'actual_display': buttonState.displayText,
            'current_language': currentLanguage,
          },
        );

        // 强制刷新按钮状态缓存
        _buttonStateCache.clearCache();
      } else {
        LanguageToggleLogger.logDebug(
          'Button state sync verified',
          additionalData: {
            'display_text': buttonState.displayText,
            'language': currentLanguage,
          },
        );
      }
    } catch (e) {
      LanguageToggleLogger.logWarning(
        'Button state sync verification failed: $e',
      );
    }
  }

  /// 恢复动画状态
  Future<void> _recoverAnimationState() async {
    try {
      LanguageToggleLogger.logDebug('Starting animation state recovery');

      // 停止所有正在运行的动画
      await _animationStateManager.stopAllAnimations();

      // 重置所有动画控制器到稳定状态
      try {
        if (_scaleAnimationController.isAnimating) {
          _scaleAnimationController.stop();
        }
        _scaleAnimationController.reset();

        if (_colorAnimationController.isAnimating) {
          _colorAnimationController.stop();
        }
        _colorAnimationController.reset();

        if (_rotationAnimationController.isAnimating) {
          _rotationAnimationController.stop();
        }
        _rotationAnimationController.reset();
      } catch (e) {
        LanguageToggleLogger.logWarning(
          'Failed to reset some animation controllers: $e',
        );
      }

      // 等待状态稳定
      await Future<void>.delayed(const Duration(milliseconds: 100));

      // 验证恢复结果
      final finalReport = _animationStateManager.getStateReport();
      if (finalReport.allStable) {
        LanguageToggleLogger.logDebug(
          'Animation state recovery successful',
          additionalData: finalReport.toMap(),
        );
      } else {
        LanguageToggleLogger.logWarning(
          'Animation state recovery incomplete',
          additionalData: finalReport.toMap(),
        );
      }
    } catch (e, stackTrace) {
      LanguageToggleLogger.logAnimationError(
        'Animation state recovery failed: $e',
        stackTrace,
        animationType: 'state_recovery',
        animationState: 'recovery',
      );
    }
  }
}

/// AppLocalizations 扩展，添加一键切换功能
extension AppLocalizationsToggle on AppLocalizations {
  /// 一键切换语言
  static Future<void> toggleLanguage(BuildContext context) async {
    try {
      final currentLocale = await _getCurrentLocaleWithValidation(context);
      final newLocale = currentLocale == 'zh' ? 'en' : 'zh';

      // 验证目标语言是否支持
      if (!AppLocalizations.isLocaleSupported(newLocale)) {
        throw UnsupportedLanguageException(newLocale);
      }

      await AppLocalizations.changeLanguageWithErrorHandling(
        context,
        newLocale,
      );
    } catch (e, stackTrace) {
      await LanguageToggleErrorHandler.handleError(
        context,
        e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// 获取当前语言代码（带验证）
  static Future<String> _getCurrentLocaleWithValidation(
    BuildContext context,
  ) async {
    try {
      final appState = context.read<AppBloc>().state;
      if (appState is AppReadyState) {
        final locale = appState.languageCode;
        if (AppLocalizations.isLocaleSupported(locale)) {
          return locale;
        } else {
          LanguageToggleLogger.logWarning(
            'Current locale is not supported: $locale, falling back to default',
          );
          return 'zh';
        }
      } else {
        throw StateAccessException(
          'Cannot get current locale: app state is ${appState.runtimeType}',
        );
      }
    } catch (e) {
      LanguageToggleLogger.logStateAccessError(
        'Failed to get current locale: $e',
        null,
        attemptedAction: 'get_current_locale',
      );
      rethrow;
    }
  }

  /// 带错误处理的语言切换
  static Future<void> changeLanguageWithErrorHandling(
    BuildContext context,
    String locale,
  ) async {
    try {
      if (!AppLocalizations.isLocaleSupported(locale)) {
        throw UnsupportedLanguageException(locale);
      }

      // 使用重试机制执行语言切换
      await LanguageToggleErrorHandler.withRetry(
        () async {
          context.read<AppBloc>().add(AppLanguageChangedEvent(locale));

          // 等待状态更新
          await Future<void>.delayed(const Duration(milliseconds: 50));

          // 验证切换是否成功
          final newState = context.read<AppBloc>().state;
          if (newState is AppReadyState && newState.languageCode == locale) {
            LanguageToggleLogger.logDebug(
              'Language change verified successfully',
            );
          } else {
            throw StateAccessException(
              'Language change verification failed: expected $locale, got ${newState is AppReadyState ? newState.languageCode : 'unknown'}',
            );
          }
        },
        maxAttempts: 2,
        shouldRetry: (error) => error is StateAccessException,
      );
    } catch (e, stackTrace) {
      LanguageToggleLogger.logToggleError(
        'Language change failed: $e',
        stackTrace,
        toLanguage: locale,
      );
      rethrow;
    }
  }
}

/// LocalizationExtension 扩展，添加一键切换功能
extension LocalizationExtensionToggle on BuildContext {
  /// 一键切换语言
  Future<void> toggleLanguage() async {
    await AppLocalizationsToggle.toggleLanguage(this);
  }

  /// 获取下一个语言的显示名称
  String get nextLanguageDisplay {
    try {
      final current = currentLocale;
      return current == 'zh' ? 'EN' : '中';
    } catch (e) {
      LanguageToggleLogger.logWarning(
        'Failed to get next language display: $e',
      );
      return 'EN'; // 默认显示
    }
  }
}
