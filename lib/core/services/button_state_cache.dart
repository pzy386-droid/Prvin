import 'package:flutter/material.dart';
import 'package:prvin/core/widgets/one_click_language_toggle_button.dart';

/// 按钮状态缓存管理器
///
/// 专门为一键语言切换按钮提供状态缓存功能，
/// 优化按钮渲染性能和减少不必要的重建
class ButtonStateCache {
  ButtonStateCache._();

  static final ButtonStateCache _instance = ButtonStateCache._();
  static ButtonStateCache get instance => _instance;

  // 缓存存储
  final Map<String, CachedButtonState> _stateCache = {};
  final Map<String, CachedDisplayText> _displayTextCache = {};
  final Map<String, CachedColorScheme> _colorSchemeCache = {};

  // 缓存统计
  int _hitCount = 0;
  int _missCount = 0;
  int _totalRequests = 0;

  /// 获取或创建按钮状态
  ToggleButtonState getOrCreateButtonState({
    required String languageCode,
    required bool isAnimating,
  }) {
    _totalRequests++;

    final cacheKey = _generateStateKey(languageCode, isAnimating);
    final cached = _stateCache[cacheKey];

    if (cached != null && !cached.isExpired) {
      _hitCount++;
      cached.updateLastAccessed();
      return cached.state;
    }

    _missCount++;

    // 创建新状态
    final languageState = LanguageToggleState.fromCode(languageCode);
    final newState = ToggleButtonState(
      currentLanguage: languageCode,
      isAnimating: isAnimating,
      displayText: languageState.display,
    );

    // 缓存新状态
    _stateCache[cacheKey] = CachedButtonState(
      state: newState,
      createdAt: DateTime.now(),
      lastAccessed: DateTime.now(),
    );

    // 清理过期缓存
    _cleanupExpiredStates();

    return newState;
  }

  /// 获取或创建显示文本
  String getOrCreateDisplayText(String languageCode) {
    _totalRequests++;

    final cached = _displayTextCache[languageCode];

    if (cached != null && !cached.isExpired) {
      _hitCount++;
      cached.updateLastAccessed();
      return cached.text;
    }

    _missCount++;

    // 创建新显示文本
    final languageState = LanguageToggleState.fromCode(languageCode);
    final displayText = languageState.display;

    // 缓存显示文本
    _displayTextCache[languageCode] = CachedDisplayText(
      text: displayText,
      createdAt: DateTime.now(),
      lastAccessed: DateTime.now(),
    );

    return displayText;
  }

  /// 获取或创建颜色方案
  CachedColorScheme getOrCreateColorScheme({
    required String languageCode,
    required bool isDarkMode,
    required bool isHighContrast,
    required bool isHovered,
    required bool isFocused,
  }) {
    _totalRequests++;

    final cacheKey = _generateColorKey(
      languageCode,
      isDarkMode,
      isHighContrast,
      isHovered,
      isFocused,
    );

    final cached = _colorSchemeCache[cacheKey];

    if (cached != null && !cached.isExpired) {
      _hitCount++;
      cached.updateLastAccessed();
      return cached;
    }

    _missCount++;

    // 创建新颜色方案
    final colorScheme = _createColorScheme(
      languageCode,
      isDarkMode,
      isHighContrast,
      isHovered,
      isFocused,
    );

    // 缓存颜色方案
    _colorSchemeCache[cacheKey] = colorScheme;

    // 清理过期缓存
    _cleanupExpiredColors();

    return colorScheme;
  }

  /// 预热缓存
  void warmupCache() {
    // 预创建常用的状态组合
    const languages = ['zh', 'en'];
    const animatingStates = [true, false];
    const darkModes = [true, false];
    const contrastModes = [true, false];

    for (final lang in languages) {
      // 预热显示文本
      getOrCreateDisplayText(lang);

      // 预热按钮状态
      for (final animating in animatingStates) {
        getOrCreateButtonState(languageCode: lang, isAnimating: animating);
      }

      // 预热颜色方案（只预热最常用的组合）
      for (final dark in darkModes) {
        for (final contrast in contrastModes) {
          getOrCreateColorScheme(
            languageCode: lang,
            isDarkMode: dark,
            isHighContrast: contrast,
            isHovered: false,
            isFocused: false,
          );
        }
      }
    }
  }

  /// 清除所有缓存
  void clearCache() {
    _stateCache.clear();
    _displayTextCache.clear();
    _colorSchemeCache.clear();
    _resetStatistics();
  }

  /// 清理过期的状态缓存
  void _cleanupExpiredStates() {
    _stateCache.removeWhere((key, cached) => cached.isExpired);
  }

  /// 清理过期的颜色缓存
  void _cleanupExpiredColors() {
    _colorSchemeCache.removeWhere((key, cached) => cached.isExpired);
  }

  /// 生成状态缓存键
  String _generateStateKey(String languageCode, bool isAnimating) {
    return 'state_${languageCode}_$isAnimating';
  }

  /// 生成颜色缓存键
  String _generateColorKey(
    String languageCode,
    bool isDarkMode,
    bool isHighContrast,
    bool isHovered,
    bool isFocused,
  ) {
    return 'color_${languageCode}_${isDarkMode}_${isHighContrast}_${isHovered}_$isFocused';
  }

  /// 创建颜色方案
  CachedColorScheme _createColorScheme(
    String languageCode,
    bool isDarkMode,
    bool isHighContrast,
    bool isHovered,
    bool isFocused,
  ) {
    // 根据语言确定基础颜色
    Color primaryColor;
    if (languageCode == 'zh') {
      primaryColor = const Color(0xFF4CAF50); // 绿色 - 中文
    } else {
      primaryColor = const Color(0xFF2196F3); // 蓝色 - 英文
    }

    // 高对比度模式调整
    if (isHighContrast) {
      primaryColor = isDarkMode ? Colors.white : Colors.black;
    }

    // 计算各种状态的颜色
    final hoverAlpha = isHighContrast ? 0.9 : (isHovered ? 0.2 : 0.15);
    final borderAlpha = isHighContrast
        ? 1.0
        : (isHovered || isFocused ? 0.6 : 0.3);

    return CachedColorScheme(
      primaryColor: primaryColor,
      backgroundColor: primaryColor.withValues(alpha: hoverAlpha),
      borderColor: primaryColor.withValues(alpha: borderAlpha),
      textColor: isHighContrast
          ? (isDarkMode ? Colors.black : Colors.white)
          : (isDarkMode ? Colors.white : primaryColor),
      shadowColor: primaryColor.withValues(alpha: isHighContrast ? 0.6 : 0.3),
      createdAt: DateTime.now(),
      lastAccessed: DateTime.now(),
    );
  }

  /// 重置统计信息
  void _resetStatistics() {
    _hitCount = 0;
    _missCount = 0;
    _totalRequests = 0;
  }

  /// 获取缓存统计信息
  CacheStatistics getStatistics() {
    final hitRate = _totalRequests > 0 ? _hitCount / _totalRequests : 0.0;

    return CacheStatistics(
      totalRequests: _totalRequests,
      hitCount: _hitCount,
      missCount: _missCount,
      hitRate: hitRate,
      statesCached: _stateCache.length,
      displayTextsCached: _displayTextCache.length,
      colorSchemesCached: _colorSchemeCache.length,
    );
  }

  /// 获取缓存健康状态
  bool get isHealthy {
    final stats = getStatistics();
    return stats.hitRate >= 0.7 && // 命中率至少70%
        stats.statesCached <= 100 && // 状态缓存不超过100个
        stats.colorSchemesCached <= 200; // 颜色缓存不超过200个
  }

  /// 销毁缓存管理器
  void dispose() {
    clearCache();
  }
}

/// 缓存的按钮状态
class CachedButtonState {
  CachedButtonState({
    required this.state,
    required this.createdAt,
    required this.lastAccessed,
  });

  final ToggleButtonState state;
  final DateTime createdAt;
  DateTime lastAccessed;

  static const Duration _ttl = Duration(minutes: 5);

  bool get isExpired => DateTime.now().difference(createdAt) > _ttl;

  void updateLastAccessed() {
    lastAccessed = DateTime.now();
  }
}

/// 缓存的显示文本
class CachedDisplayText {
  CachedDisplayText({
    required this.text,
    required this.createdAt,
    required this.lastAccessed,
  });

  final String text;
  final DateTime createdAt;
  DateTime lastAccessed;

  static const Duration _ttl = Duration(hours: 1);

  bool get isExpired => DateTime.now().difference(createdAt) > _ttl;

  void updateLastAccessed() {
    lastAccessed = DateTime.now();
  }
}

/// 缓存的颜色方案
class CachedColorScheme {
  CachedColorScheme({
    required this.primaryColor,
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
    required this.shadowColor,
    required this.createdAt,
    required this.lastAccessed,
  });

  final Color primaryColor;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
  final Color shadowColor;
  final DateTime createdAt;
  DateTime lastAccessed;

  static const Duration _ttl = Duration(minutes: 10);

  bool get isExpired => DateTime.now().difference(createdAt) > _ttl;

  void updateLastAccessed() {
    lastAccessed = DateTime.now();
  }
}

/// 缓存统计信息
class CacheStatistics {
  const CacheStatistics({
    required this.totalRequests,
    required this.hitCount,
    required this.missCount,
    required this.hitRate,
    required this.statesCached,
    required this.displayTextsCached,
    required this.colorSchemesCached,
  });

  final int totalRequests;
  final int hitCount;
  final int missCount;
  final double hitRate;
  final int statesCached;
  final int displayTextsCached;
  final int colorSchemesCached;

  @override
  String toString() {
    return 'CacheStatistics('
        'requests: $totalRequests, '
        'hits: $hitCount, '
        'misses: $missCount, '
        'hitRate: ${(hitRate * 100).toStringAsFixed(1)}%, '
        'cached: states=$statesCached, texts=$displayTextsCached, colors=$colorSchemesCached'
        ')';
  }
}
