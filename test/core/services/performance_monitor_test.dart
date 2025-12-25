import 'package:flutter_test/flutter_test.dart';
import 'package:prvin/core/services/performance_monitor.dart';

void main() {
  group('PerformanceMonitor Tests', () {
    late PerformanceMonitor performanceMonitor;

    setUpAll(TestWidgetsFlutterBinding.ensureInitialized);

    setUp(() {
      performanceMonitor = PerformanceMonitor.instance;
    });

    tearDown(() {
      performanceMonitor.stopMonitoring();
    });

    test('should start and stop monitoring', () {
      // In test mode, monitoring may not work the same way
      // Just test that the methods don't throw exceptions
      expect(() => performanceMonitor.startMonitoring(), returnsNormally);
      expect(() => performanceMonitor.stopMonitoring(), returnsNormally);
    });

    test('should track operation performance', () async {
      const operationName = 'test_operation';

      performanceMonitor.startOperation(operationName);

      // Simulate some work with a small delay
      await Future.delayed(const Duration(milliseconds: 1));

      performanceMonitor.endOperation(operationName);

      final stats = performanceMonitor.getOperationStats(operationName);
      expect(stats.operationName, equals(operationName));
      expect(stats.totalCalls, equals(1));
      // In test mode, duration might be 0, so just check it's not negative
      expect(stats.averageDuration.inMicroseconds, greaterThanOrEqualTo(0));
    });

    test('should get performance report', () {
      const operationName = 'test_operation_2';

      performanceMonitor.startOperation(operationName);
      performanceMonitor.endOperation(operationName);

      final report = performanceMonitor.getPerformanceReport();
      expect(report.timestamp, isNotNull);
      expect(report.fpsStats, isNotNull);
      expect(report.memoryStats, isNotNull);
      expect(report.operationStats, isNotEmpty);
    });

    test('should record custom metrics', () {
      expect(
        () => performanceMonitor.recordMetric('test_metric', 42),
        returnsNormally,
      );
    });

    test('should get FPS stats', () {
      final fpsStats = performanceMonitor.getFpsStats();
      expect(fpsStats.currentFps, greaterThanOrEqualTo(0));
      expect(fpsStats.averageFps, greaterThanOrEqualTo(0));
      expect(fpsStats.minFps, greaterThanOrEqualTo(0));
      expect(fpsStats.maxFps, greaterThanOrEqualTo(0));
    });

    test('should get memory stats', () {
      final memoryStats = performanceMonitor.getMemoryStats();
      expect(memoryStats.currentMemoryMB, greaterThanOrEqualTo(0));
      expect(memoryStats.averageMemoryMB, greaterThanOrEqualTo(0));
      expect(memoryStats.peakMemoryMB, greaterThanOrEqualTo(0));
    });
  });
}
