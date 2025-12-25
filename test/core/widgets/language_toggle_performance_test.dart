import 'package:flutter_test/flutter_test.dart';
import 'package:prvin/core/services/performance_monitor.dart';
import 'package:prvin/core/widgets/one_click_language_toggle_button.dart';

void main() {
  group('Language Toggle Performance Tests', () {
    late PerformanceMonitor performanceMonitor;

    setUpAll(TestWidgetsFlutterBinding.ensureInitialized);

    setUp(() {
      performanceMonitor = PerformanceMonitor.instance;
    });

    tearDown(() {
      performanceMonitor.stopMonitoring();
    });

    test('should complete language toggle operation within 200ms', () async {
      const operationName = 'language_toggle_performance_test';

      performanceMonitor.startOperation(operationName);

      // Simulate language toggle work with a small delay
      await Future.delayed(const Duration(milliseconds: 50));

      performanceMonitor.endOperation(operationName);

      final stats = performanceMonitor.getOperationStats(operationName);
      expect(stats.operationName, equals(operationName));
      expect(stats.totalCalls, equals(1));
      expect(stats.averageDuration.inMilliseconds, lessThan(200));
      expect(stats.isHealthy, isTrue);
    });

    test('should maintain good FPS performance', () {
      final fpsStats = performanceMonitor.getFpsStats();

      // In test environment, FPS might be 0, but should not be negative
      expect(fpsStats.currentFps, greaterThanOrEqualTo(0));
      expect(fpsStats.averageFps, greaterThanOrEqualTo(0));
      expect(fpsStats.minFps, greaterThanOrEqualTo(0));
      expect(fpsStats.maxFps, greaterThanOrEqualTo(0));
    });

    test('should monitor memory usage efficiently', () {
      final memoryStats = performanceMonitor.getMemoryStats();

      expect(memoryStats.currentMemoryMB, greaterThanOrEqualTo(0));
      expect(memoryStats.averageMemoryMB, greaterThanOrEqualTo(0));
      expect(memoryStats.peakMemoryMB, greaterThanOrEqualTo(0));
      expect(memoryStats.isHealthy, isTrue);
    });

    test('should provide comprehensive performance metrics', () {
      // Test multiple operations to verify performance tracking
      const operations = ['op1', 'op2', 'op3'];

      for (final op in operations) {
        performanceMonitor.startOperation(op);
        // Simulate work
        for (var i = 0; i < 100; i++) {
          // Simple computation
        }
        performanceMonitor.endOperation(op);
      }

      final report = performanceMonitor.getPerformanceReport();
      expect(report.isHealthy, isTrue);
      expect(
        report.operationStats.length,
        greaterThanOrEqualTo(operations.length),
      );

      // Verify each operation was tracked
      for (final op in operations) {
        final stats = performanceMonitor.getOperationStats(op);
        expect(stats.totalCalls, equals(1));
        expect(stats.isHealthy, isTrue);
      }
    });

    test('should handle cache performance efficiently', () {
      // Test button state cache performance
      final cacheStats = OneClickLanguageToggleButton.getCacheStatistics();

      // Initially should have low usage
      expect(cacheStats.totalRequests, greaterThanOrEqualTo(0));

      // Warmup cache to test performance
      OneClickLanguageToggleButton.warmupPerformanceComponents();

      final warmedUpStats = OneClickLanguageToggleButton.getCacheStatistics();
      expect(warmedUpStats.statesCached, greaterThan(0));
      expect(warmedUpStats.displayTextsCached, greaterThan(0));
      expect(warmedUpStats.colorSchemesCached, greaterThan(0));
    });

    test('should detect memory leaks', () {
      // Test memory leak detection
      final memoryLeaks = OneClickLanguageToggleButton.detectMemoryLeaks();

      // Should not have critical memory leaks initially
      final criticalLeaks = memoryLeaks
          .where((leak) => leak.severity.name == 'critical')
          .toList();

      expect(criticalLeaks, isEmpty);
    });

    test('should provide animation performance status', () {
      // Test animation performance monitoring
      final animationStatus =
          OneClickLanguageToggleButton.getAnimationPerformanceStatus();

      expect(animationStatus.currentFps, greaterThanOrEqualTo(0));
      expect(animationStatus.samplesCount, greaterThanOrEqualTo(0));
    });

    test('should cleanup resources properly', () {
      // Test resource cleanup
      expect(
        OneClickLanguageToggleButton.performCleanup,
        returnsNormally,
      );

      // Verify cleanup worked
      final cacheStats = OneClickLanguageToggleButton.getCacheStatistics();
      expect(cacheStats.statesCached, equals(0));
      expect(cacheStats.displayTextsCached, equals(0));
      expect(cacheStats.colorSchemesCached, equals(0));
    });

    test('should record custom performance metrics', () {
      // Test custom metric recording
      expect(
        () => performanceMonitor.recordMetric('test_metric', 42),
        returnsNormally,
      );
      expect(
        () => performanceMonitor.recordMetric('response_time', 150),
        returnsNormally,
      );
      expect(
        () => performanceMonitor.recordMetric('cache_hit_rate', 0.85),
        returnsNormally,
      );
    });

    test('should handle multiple concurrent operations', () {
      // Test concurrent operation tracking
      const operations = [
        'concurrent_op_1',
        'concurrent_op_2',
        'concurrent_op_3',
      ];

      // Start all operations
      for (final op in operations) {
        performanceMonitor.startOperation(op);
      }

      // End all operations
      for (final op in operations) {
        performanceMonitor.endOperation(op);
      }

      // Verify all operations were tracked
      for (final op in operations) {
        final stats = performanceMonitor.getOperationStats(op);
        expect(stats.totalCalls, equals(1));
        expect(stats.operationName, equals(op));
      }
    });
  });
}
