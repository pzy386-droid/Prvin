import 'package:flutter_test/flutter_test.dart';
import 'package:prvin/core/services/button_state_cache.dart';

void main() {
  group('ButtonStateCache Tests', () {
    late ButtonStateCache cache;

    setUp(() {
      cache = ButtonStateCache.instance;
      cache.clearCache();
    });

    tearDown(() {
      cache.clearCache();
    });

    test('should cache and retrieve button states', () {
      const languageCode = 'zh';
      const isAnimating = false;

      final state1 = cache.getOrCreateButtonState(
        languageCode: languageCode,
        isAnimating: isAnimating,
      );

      final state2 = cache.getOrCreateButtonState(
        languageCode: languageCode,
        isAnimating: isAnimating,
      );

      expect(state1.currentLanguage, equals(languageCode));
      expect(state1.isAnimating, equals(isAnimating));
      expect(state1.displayText, equals('中'));

      // Should return the same cached instance
      expect(state1.currentLanguage, equals(state2.currentLanguage));
      expect(state1.isAnimating, equals(state2.isAnimating));
      expect(state1.displayText, equals(state2.displayText));
    });

    test('should cache and retrieve display text', () {
      const languageCode = 'en';

      final text1 = cache.getOrCreateDisplayText(languageCode);
      final text2 = cache.getOrCreateDisplayText(languageCode);

      expect(text1, equals('EN'));
      expect(text1, equals(text2));
    });

    test('should cache and retrieve color schemes', () {
      const languageCode = 'zh';
      const isDarkMode = false;
      const isHighContrast = false;
      const isHovered = false;
      const isFocused = false;

      final scheme1 = cache.getOrCreateColorScheme(
        languageCode: languageCode,
        isDarkMode: isDarkMode,
        isHighContrast: isHighContrast,
        isHovered: isHovered,
        isFocused: isFocused,
      );

      final scheme2 = cache.getOrCreateColorScheme(
        languageCode: languageCode,
        isDarkMode: isDarkMode,
        isHighContrast: isHighContrast,
        isHovered: isHovered,
        isFocused: isFocused,
      );

      expect(scheme1.primaryColor, equals(scheme2.primaryColor));
      expect(scheme1.backgroundColor, equals(scheme2.backgroundColor));
      expect(scheme1.borderColor, equals(scheme2.borderColor));
      expect(scheme1.textColor, equals(scheme2.textColor));
    });

    test('should warmup cache', () {
      cache.warmupCache();

      final stats = cache.getStatistics();
      expect(stats.statesCached, greaterThan(0));
      expect(stats.displayTextsCached, greaterThan(0));
      expect(stats.colorSchemesCached, greaterThan(0));
    });

    test('should provide cache statistics', () {
      // Create some cached items
      cache.getOrCreateButtonState(languageCode: 'zh', isAnimating: false);
      cache.getOrCreateDisplayText('en');
      cache.getOrCreateColorScheme(
        languageCode: 'zh',
        isDarkMode: false,
        isHighContrast: false,
        isHovered: false,
        isFocused: false,
      );

      final stats = cache.getStatistics();
      expect(stats.totalRequests, greaterThan(0));
      expect(stats.statesCached, greaterThan(0));
      expect(stats.displayTextsCached, greaterThan(0));
      expect(stats.colorSchemesCached, greaterThan(0));
    });

    test('should clear cache', () {
      // Add some items to cache
      cache.getOrCreateButtonState(languageCode: 'zh', isAnimating: false);
      cache.getOrCreateDisplayText('en');

      var stats = cache.getStatistics();
      expect(stats.statesCached, greaterThan(0));
      expect(stats.displayTextsCached, greaterThan(0));

      // Clear cache
      cache.clearCache();

      stats = cache.getStatistics();
      expect(stats.statesCached, equals(0));
      expect(stats.displayTextsCached, equals(0));
      expect(stats.colorSchemesCached, equals(0));
    });

    test('should work with cache statistics', () {
      cache.warmupCache();

      final stats = cache.getStatistics();

      // Verify the cache is working
      expect(stats.statesCached, greaterThan(0));
      expect(stats.colorSchemesCached, greaterThan(0));
      expect(stats.displayTextsCached, greaterThan(0));
      expect(stats.totalRequests, greaterThan(0));
    });
  });
}
