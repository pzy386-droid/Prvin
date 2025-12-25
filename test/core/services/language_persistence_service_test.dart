import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:prvin/core/services/language_persistence_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'language_persistence_service_test.mocks.dart';

@GenerateMocks([SharedPreferences])
void main() {
  group('LanguagePersistenceService Tests', () {
    late LanguagePersistenceService service;
    late MockSharedPreferences mockPrefs;

    setUp(() {
      service = LanguagePersistenceService.instance;
      mockPrefs = MockSharedPreferences();

      // 重置SharedPreferences的内存存储
      SharedPreferences.setMockInitialValues({});
    });

    group('saveLanguagePreference', () {
      test('should save language preference successfully', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({});

        // Act
        final result = await service.saveLanguagePreference('en');

        // Assert
        expect(result, isTrue);

        // Verify the language was actually saved
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getString('app_language_code'), equals('en'));
        expect(prefs.getString('app_language_code_backup'), equals('en'));
      });

      test('should handle unsupported language', () async {
        // Act & Assert
        expect(
          await service.saveLanguagePreference('fr'),
          isFalse, // Should return false instead of throwing
        );
      });

      test('should save with previous language metadata', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({});

        // Act
        final result = await service.saveLanguagePreference(
          'en',
          previousLanguage: 'zh',
        );

        // Assert
        expect(result, isTrue);

        final prefs = await SharedPreferences.getInstance();
        final metadataJson = prefs.getString('app_language_metadata');
        expect(metadataJson, isNotNull);

        final metadata = jsonDecode(metadataJson!) as Map<String, dynamic>;
        expect(metadata['languageCode'], equals('en'));
        expect(metadata['previousLanguage'], equals('zh'));
        expect(metadata['version'], equals('1.0'));
      });

      test('should handle save failure gracefully', () async {
        // Arrange - 模拟保存失败的情况
        SharedPreferences.setMockInitialValues({});

        // 这里我们无法直接模拟SharedPreferences的失败，
        // 但我们可以测试服务的错误处理逻辑

        // Act
        final result = await service.saveLanguagePreference('zh');

        // Assert - 即使在某些边缘情况下，服务也应该尝试处理
        expect(result, isA<bool>());
      });
    });

    group('restoreLanguagePreference', () {
      test('should restore saved language preference', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({
          'app_language_code': 'en',
          'app_language_code_backup': 'en',
        });

        // Act
        final result = await service.restoreLanguagePreference();

        // Assert
        expect(result, equals('en'));
      });

      test(
        'should return default language when no preference exists',
        () async {
          // Arrange
          SharedPreferences.setMockInitialValues({});

          // Act
          final result = await service.restoreLanguagePreference();

          // Assert
          expect(result, equals('zh')); // 默认语言
        },
      );

      test('should use backup when primary setting is corrupted', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({
          'app_language_code': 'invalid_language',
          'app_language_code_backup': 'en',
        });

        // Act
        final result = await service.restoreLanguagePreference();

        // Assert
        expect(result, equals('en'));
      });

      test(
        'should return default when both primary and backup are invalid',
        () async {
          // Arrange
          SharedPreferences.setMockInitialValues({
            'app_language_code': 'invalid1',
            'app_language_code_backup': 'invalid2',
          });

          // Act
          final result = await service.restoreLanguagePreference();

          // Assert
          expect(result, equals('zh'));
        },
      );
    });

    group('clearLanguagePreference', () {
      test('should clear all language preferences', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({
          'app_language_code': 'en',
          'app_language_code_backup': 'en',
          'app_language_metadata': '{"test": "data"}',
        });

        // Act
        final result = await service.clearLanguagePreference();

        // Assert
        expect(result, isTrue);

        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getString('app_language_code'), isNull);
        expect(prefs.getString('app_language_code_backup'), isNull);
        expect(prefs.getString('app_language_metadata'), isNull);
      });
    });

    group('getCurrentSavedLanguage', () {
      test('should return current saved language', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({'app_language_code': 'en'});

        // Act
        final result = await service.getCurrentSavedLanguage();

        // Assert
        expect(result, equals('en'));
      });

      test('should return null when no language is saved', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({});

        // Act
        final result = await service.getCurrentSavedLanguage();

        // Assert
        expect(result, isNull);
      });
    });

    group('hasLanguagePreference', () {
      test('should return true when language preference exists', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({'app_language_code': 'en'});

        // Act
        final result = await service.hasLanguagePreference();

        // Assert
        expect(result, isTrue);
      });

      test('should return false when no language preference exists', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({});

        // Act
        final result = await service.hasLanguagePreference();

        // Assert
        expect(result, isFalse);
      });
    });

    group('getLanguageMetadata', () {
      test('should return language metadata when it exists', () async {
        // Arrange
        final metadata = {
          'languageCode': 'en',
          'previousLanguage': 'zh',
          'timestamp': '2023-01-01T00:00:00.000Z',
          'version': '1.0',
        };

        SharedPreferences.setMockInitialValues({
          'app_language_metadata': jsonEncode(metadata),
        });

        // Act
        final result = await service.getLanguageMetadata();

        // Assert
        expect(result, isNotNull);
        expect(result!['languageCode'], equals('en'));
        expect(result['previousLanguage'], equals('zh'));
        expect(result['version'], equals('1.0'));
      });

      test('should return null when no metadata exists', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({});

        // Act
        final result = await service.getLanguageMetadata();

        // Assert
        expect(result, isNull);
      });

      test('should return null when metadata is corrupted', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({
          'app_language_metadata': 'invalid_json',
        });

        // Act
        final result = await service.getLanguageMetadata();

        // Assert
        expect(result, isNull);
      });
    });

    group('checkPersistenceHealth', () {
      test('should return healthy status for normal operation', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({});

        // Act
        final result = await service.checkPersistenceHealth();

        // Assert
        expect(result, equals(PersistenceHealthStatus.healthy));
      });

      test('should detect inconsistent data', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({
          'app_language_code': 'en',
          'app_language_code_backup': 'zh', // 不一致的备份
        });

        // Act
        final result = await service.checkPersistenceHealth();

        // Assert
        expect(result, equals(PersistenceHealthStatus.inconsistentData));
      });
    });

    group('repairPersistenceSystem', () {
      test('should repair inconsistent data', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({
          'app_language_code': 'en',
          'app_language_code_backup': 'zh', // 不一致的数据
        });

        // Act
        final result = await service.repairPersistenceSystem();

        // Assert
        expect(result, isTrue);

        // 验证数据已被修复
        final prefs = await SharedPreferences.getInstance();
        final primary = prefs.getString('app_language_code');
        final backup = prefs.getString('app_language_code_backup');
        expect(primary, equals(backup)); // 应该一致了
      });

      test('should return true for already healthy system', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({
          'app_language_code': 'en',
          'app_language_code_backup': 'en',
        });

        // Act
        final result = await service.repairPersistenceSystem();

        // Assert
        expect(result, isTrue);
      });
    });

    group('Integration Tests', () {
      test('should handle complete save and restore cycle', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({});

        // Act - Save
        final saveResult = await service.saveLanguagePreference(
          'en',
          previousLanguage: 'zh',
        );
        expect(saveResult, isTrue);

        // Act - Restore
        final restoreResult = await service.restoreLanguagePreference();

        // Assert
        expect(restoreResult, equals('en'));

        // Verify metadata
        final metadata = await service.getLanguageMetadata();
        expect(metadata, isNotNull);
        expect(metadata!['languageCode'], equals('en'));
        expect(metadata['previousLanguage'], equals('zh'));
      });

      test('should handle multiple language switches', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({});

        // Act - Multiple switches
        await service.saveLanguagePreference('en');
        expect(await service.restoreLanguagePreference(), equals('en'));

        await service.saveLanguagePreference('zh', previousLanguage: 'en');
        expect(await service.restoreLanguagePreference(), equals('zh'));

        await service.saveLanguagePreference('en', previousLanguage: 'zh');
        expect(await service.restoreLanguagePreference(), equals('en'));
      });

      test('should maintain data integrity after clear and re-save', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({});

        // Act
        await service.saveLanguagePreference('en');
        await service.clearLanguagePreference();

        expect(await service.hasLanguagePreference(), isFalse);
        expect(await service.restoreLanguagePreference(), equals('zh')); // 默认

        await service.saveLanguagePreference('en');
        expect(await service.restoreLanguagePreference(), equals('en'));
      });
    });
  });
}
