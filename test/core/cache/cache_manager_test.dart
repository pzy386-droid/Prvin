import 'package:flutter_test/flutter_test.dart';
import 'package:prvin/core/cache/cache_manager.dart';

void main() {
  group('CacheManager', () {
    late CacheManager<String, String> cacheManager;

    setUp(() {
      cacheManager = CacheManager<String, String>(
        maxSize: 3,
        ttl: const Duration(milliseconds: 100),
      );
    });

    tearDown(() {
      cacheManager.dispose();
    });

    test('should store and retrieve values', () {
      cacheManager.put('key1', 'value1');

      expect(cacheManager.get('key1'), equals('value1'));
      expect(cacheManager.containsKey('key1'), isTrue);
      expect(cacheManager.size, equals(1));
    });

    test('should return null for non-existent keys', () {
      expect(cacheManager.get('nonexistent'), isNull);
      expect(cacheManager.containsKey('nonexistent'), isFalse);
    });

    test('should respect max size limit', () {
      cacheManager.put('key1', 'value1');
      cacheManager.put('key2', 'value2');
      cacheManager.put('key3', 'value3');
      cacheManager.put('key4', 'value4'); // Should evict key1

      expect(cacheManager.size, equals(3));
      expect(cacheManager.get('key1'), isNull); // Evicted
      expect(cacheManager.get('key2'), equals('value2'));
      expect(cacheManager.get('key3'), equals('value3'));
      expect(cacheManager.get('key4'), equals('value4'));
    });

    test('should implement LRU eviction policy', () {
      cacheManager.put('key1', 'value1');
      cacheManager.put('key2', 'value2');
      cacheManager.put('key3', 'value3');

      // Access key1 to make it recently used
      cacheManager.get('key1');

      // Add key4, should evict key2 (least recently used)
      cacheManager.put('key4', 'value4');

      expect(cacheManager.get('key1'), equals('value1')); // Still there
      expect(cacheManager.get('key2'), isNull); // Evicted
      expect(cacheManager.get('key3'), equals('value3'));
      expect(cacheManager.get('key4'), equals('value4'));
    });

    test('should expire entries after TTL', () async {
      cacheManager.put('key1', 'value1');

      expect(cacheManager.get('key1'), equals('value1'));

      // Wait for TTL to expire
      await Future.delayed(const Duration(milliseconds: 150));

      expect(cacheManager.get('key1'), isNull);
      expect(cacheManager.containsKey('key1'), isFalse);
    });

    test('should remove specific keys', () {
      cacheManager.put('key1', 'value1');
      cacheManager.put('key2', 'value2');

      final removedValue = cacheManager.remove('key1');

      expect(removedValue, equals('value1'));
      expect(cacheManager.get('key1'), isNull);
      expect(cacheManager.get('key2'), equals('value2'));
      expect(cacheManager.size, equals(1));
    });

    test('should clear all entries', () {
      cacheManager.put('key1', 'value1');
      cacheManager.put('key2', 'value2');

      expect(cacheManager.size, equals(2));

      cacheManager.clear();

      expect(cacheManager.size, equals(0));
      expect(cacheManager.get('key1'), isNull);
      expect(cacheManager.get('key2'), isNull);
    });

    test('should provide accurate cache stats', () {
      cacheManager.put('key1', 'value1');
      cacheManager.put('key2', 'value2');

      final stats = cacheManager.stats;

      expect(stats.totalEntries, equals(2));
      expect(stats.validEntries, equals(2));
      expect(stats.expiredEntries, equals(0));
      expect(stats.maxSize, equals(3));
      expect(stats.hitRate, equals(1.0));
      expect(stats.usageRate, closeTo(0.67, 0.01));
    });

    test('should update stats after expiration', () async {
      cacheManager.put('key1', 'value1');
      cacheManager.put('key2', 'value2');

      // Wait for entries to expire
      await Future.delayed(const Duration(milliseconds: 150));

      final stats = cacheManager.stats;

      // After expiration, accessing entries should return null
      expect(cacheManager.get('key1'), isNull);
      expect(cacheManager.get('key2'), isNull);

      // Stats should reflect the cleanup
      final updatedStats = cacheManager.stats;
      expect(updatedStats.totalEntries, equals(0));
    });

    test('should handle cache with different types', () {
      final intCache = CacheManager<String, int>(maxSize: 5);

      intCache.put('count', 42);
      intCache.put('age', 25);

      expect(intCache.get('count'), equals(42));
      expect(intCache.get('age'), equals(25));

      intCache.dispose();
    });
  });
}
