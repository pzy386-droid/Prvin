import 'dart:convert';

import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prvin/core/services/language_persistence_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// **Feature: one-click-language-toggle, Property 3: 持久化一致性**
/// *对于任何*语言切换操作，新的语言设置应该被正确保存到本地存储，并在应用重启后恢复
/// **Validates: Requirements 1.3, 1.4**
void main() {
  group('Language Persistence Consistency Property Tests', () {
    late LanguagePersistenceService service;
    final faker = Faker();

    setUp(() {
      service = LanguagePersistenceService.instance;
      // 重置SharedPreferences的内存存储
      SharedPreferences.setMockInitialValues({});
    });

    test(
      'Property 3: 持久化一致性 - save and restore should be consistent for all supported languages',
      () async {
        // **Feature: one-click-language-toggle, Property 3: 持久化一致性**

        // 运行100次迭代以确保属性在各种输入下都成立
        for (var i = 0; i < 100; i++) {
          // 生成随机的语言状态
          final targetLanguage = _generateRandomSupportedLanguage(faker);
          final previousLanguage = _generateRandomSupportedLanguage(faker);

          // 清理之前的状态
          await service.clearLanguagePreference();

          // 执行保存操作
          final saveResult = await service.saveLanguagePreference(
            targetLanguage,
            previousLanguage: previousLanguage,
          );

          // 验证保存操作成功
          expect(
            saveResult,
            isTrue,
            reason:
                'Save operation should succeed for supported language: $targetLanguage',
          );

          // 验证立即读取的一致性
          final immediateRestore = await service.getCurrentSavedLanguage();
          expect(
            immediateRestore,
            equals(targetLanguage),
            reason:
                'Immediate restore should return the saved language: $targetLanguage',
          );

          // 模拟应用重启：获取当前保存的数据并重新设置mock
          final currentPrefs = await SharedPreferences.getInstance();
          final currentData = <String, Object>{};

          // 收集当前保存的数据
          for (final key in currentPrefs.getKeys()) {
            final value = currentPrefs.get(key);
            if (value != null) {
              currentData[key] = value;
            }
          }

          // 重新设置mock数据以模拟应用重启
          SharedPreferences.setMockInitialValues(currentData);

          // 验证重启后的恢复一致性
          final restoreResult = await service.restoreLanguagePreference();
          expect(
            restoreResult,
            equals(targetLanguage),
            reason:
                'Restore after restart should return the saved language: $targetLanguage',
          );

          // 验证元数据的一致性
          final metadata = await service.getLanguageMetadata();
          expect(
            metadata,
            isNotNull,
            reason: 'Metadata should exist after save operation',
          );
          expect(
            metadata!['languageCode'],
            equals(targetLanguage),
            reason: 'Metadata should contain correct language code',
          );
          expect(
            metadata['previousLanguage'],
            equals(previousLanguage),
            reason: 'Metadata should contain correct previous language',
          );
        }
      },
    );

    test(
      'Property 3: 持久化一致性 - multiple save operations should maintain consistency',
      () async {
        // **Feature: one-click-language-toggle, Property 3: 持久化一致性**

        for (var i = 0; i < 50; i++) {
          // 清理初始状态
          await service.clearLanguagePreference();

          // 生成随机的语言切换序列
          final switchSequence = _generateLanguageSwitchSequence(faker, 5);
          String? previousLang;

          for (final targetLang in switchSequence) {
            // 保存语言设置
            final saveResult = await service.saveLanguagePreference(
              targetLang,
              previousLanguage: previousLang,
            );

            expect(
              saveResult,
              isTrue,
              reason: 'Each save in sequence should succeed: $targetLang',
            );

            // 验证保存后立即恢复的一致性
            final restoreResult = await service.restoreLanguagePreference();
            expect(
              restoreResult,
              equals(targetLang),
              reason: 'Restore should match last saved language: $targetLang',
            );

            // 验证当前保存的语言
            final currentSaved = await service.getCurrentSavedLanguage();
            expect(
              currentSaved,
              equals(targetLang),
              reason: 'Current saved language should match: $targetLang',
            );

            previousLang = targetLang;
          }

          // 验证最终状态的一致性
          final finalLanguage = switchSequence.last;
          final finalRestore = await service.restoreLanguagePreference();
          expect(
            finalRestore,
            equals(finalLanguage),
            reason:
                'Final restore should match last language in sequence: $finalLanguage',
          );
        }
      },
    );

    test(
      'Property 3: 持久化一致性 - backup and primary storage should remain synchronized',
      () async {
        // **Feature: one-click-language-toggle, Property 3: 持久化一致性**

        for (var i = 0; i < 30; i++) {
          final targetLanguage = _generateRandomSupportedLanguage(faker);

          // 清理状态
          await service.clearLanguagePreference();

          // 保存语言设置
          await service.saveLanguagePreference(targetLanguage);

          // 直接检查SharedPreferences中的数据一致性
          final prefs = await SharedPreferences.getInstance();
          final primaryLanguage = prefs.getString('app_language_code');
          final backupLanguage = prefs.getString('app_language_code_backup');

          expect(
            primaryLanguage,
            equals(targetLanguage),
            reason:
                'Primary storage should contain correct language: $targetLanguage',
          );

          expect(
            backupLanguage,
            equals(targetLanguage),
            reason:
                'Backup storage should contain correct language: $targetLanguage',
          );

          expect(
            primaryLanguage,
            equals(backupLanguage),
            reason: 'Primary and backup storage should be synchronized',
          );

          // 验证元数据存储
          final metadataJson = prefs.getString('app_language_metadata');
          expect(metadataJson, isNotNull, reason: 'Metadata should be stored');

          final metadata = jsonDecode(metadataJson!) as Map<String, dynamic>;
          expect(
            metadata['languageCode'],
            equals(targetLanguage),
            reason: 'Metadata should contain correct language code',
          );

          // 验证健康检查通过
          final healthStatus = await service.checkPersistenceHealth();
          expect(
            healthStatus,
            equals(PersistenceHealthStatus.healthy),
            reason: 'Persistence system should be healthy after save',
          );
        }
      },
    );

    test(
      'Property 3: 持久化一致性 - round-trip consistency with metadata preservation',
      () async {
        // **Feature: one-click-language-toggle, Property 3: 持久化一致性**

        for (var i = 0; i < 40; i++) {
          final targetLanguage = _generateRandomSupportedLanguage(faker);
          final previousLanguage = _generateRandomSupportedLanguage(faker);

          // 清理状态
          await service.clearLanguagePreference();

          // 记录保存前的时间戳
          final beforeSave = DateTime.now();

          // 执行保存操作
          final saveResult = await service.saveLanguagePreference(
            targetLanguage,
            previousLanguage: previousLanguage,
          );

          expect(saveResult, isTrue);

          // 记录保存后的时间戳
          final afterSave = DateTime.now();

          // 验证完整的往返一致性
          final restoreResult = await service.restoreLanguagePreference();
          expect(
            restoreResult,
            equals(targetLanguage),
            reason: 'Round-trip should preserve language: $targetLanguage',
          );

          // 验证元数据的完整性和时间戳
          final metadata = await service.getLanguageMetadata();
          expect(metadata, isNotNull);
          expect(metadata!['languageCode'], equals(targetLanguage));
          expect(metadata['previousLanguage'], equals(previousLanguage));
          expect(metadata['version'], equals('1.0'));

          // 验证时间戳在合理范围内
          final timestampStr = metadata['timestamp'] as String;
          final timestamp = DateTime.parse(timestampStr);
          expect(
            timestamp.isAfter(beforeSave.subtract(const Duration(seconds: 1))),
            isTrue,
            reason: 'Timestamp should be after save operation start',
          );
          expect(
            timestamp.isBefore(afterSave.add(const Duration(seconds: 1))),
            isTrue,
            reason: 'Timestamp should be before save operation end',
          );

          // 验证存在性检查
          final hasPreference = await service.hasLanguagePreference();
          expect(
            hasPreference,
            isTrue,
            reason: 'Should detect language preference exists',
          );
        }
      },
    );

    test(
      'Property 3: 持久化一致性 - consistency under concurrent operations simulation',
      () async {
        // **Feature: one-click-language-toggle, Property 3: 持久化一致性**

        for (var i = 0; i < 20; i++) {
          // 清理状态
          await service.clearLanguagePreference();

          // 模拟并发操作：快速连续的保存操作
          final languages = _generateLanguageSwitchSequence(faker, 3);
          final futures = <Future<bool>>[];

          // 启动多个并发保存操作
          for (var j = 0; j < languages.length; j++) {
            futures.add(
              service.saveLanguagePreference(
                languages[j],
                previousLanguage: j > 0 ? languages[j - 1] : null,
              ),
            );
          }

          // 等待所有操作完成
          final results = await Future.wait(futures);

          // 验证至少有一个操作成功
          expect(
            results.any((result) => result),
            isTrue,
            reason: 'At least one concurrent save should succeed',
          );

          // 验证最终状态的一致性
          final finalLanguage = await service.restoreLanguagePreference();
          expect(
            languages,
            contains(finalLanguage),
            reason: 'Final language should be one of the saved languages',
          );

          // 验证系统健康状态
          final healthStatus = await service.checkPersistenceHealth();
          expect(
            healthStatus,
            anyOf([
              PersistenceHealthStatus.healthy,
              PersistenceHealthStatus.inconsistentData, // 可能由于并发导致
            ]),
            reason:
                'System should be healthy or have recoverable inconsistency',
          );

          // 如果有不一致，尝试修复
          if (healthStatus == PersistenceHealthStatus.inconsistentData) {
            final repairResult = await service.repairPersistenceSystem();
            expect(
              repairResult,
              isTrue,
              reason: 'System repair should succeed',
            );

            // 验证修复后的一致性
            final afterRepairLanguage = await service
                .restoreLanguagePreference();
            expect(
              languages,
              contains(afterRepairLanguage),
              reason: 'Language after repair should be valid',
            );
          }
        }
      },
    );

    test(
      'Property 3: 持久化一致性 - error recovery maintains data integrity',
      () async {
        // **Feature: one-click-language-toggle, Property 3: 持久化一致性**

        for (var i = 0; i < 15; i++) {
          final validLanguage = _generateRandomSupportedLanguage(faker);

          // 清理状态
          await service.clearLanguagePreference();

          // 首先保存一个有效的语言设置
          final initialSave = await service.saveLanguagePreference(
            validLanguage,
          );
          expect(initialSave, isTrue);

          // 验证初始状态
          final initialRestore = await service.restoreLanguagePreference();
          expect(initialRestore, equals(validLanguage));

          // 尝试保存无效的语言（应该失败但不破坏现有数据）
          final invalidLanguage = faker.lorem.word();
          final invalidSave = await service.saveLanguagePreference(
            invalidLanguage,
          );
          expect(
            invalidSave,
            isFalse,
            reason: 'Invalid language save should fail',
          );

          // 验证原有数据仍然完整
          final afterInvalidRestore = await service.restoreLanguagePreference();
          expect(
            afterInvalidRestore,
            equals(validLanguage),
            reason:
                'Original valid language should be preserved after invalid save attempt',
          );

          // 验证元数据仍然正确
          final metadata = await service.getLanguageMetadata();
          expect(metadata, isNotNull);
          expect(
            metadata!['languageCode'],
            equals(validLanguage),
            reason:
                'Metadata should preserve original language after failed save',
          );

          // 验证系统健康状态
          final healthStatus = await service.checkPersistenceHealth();
          expect(
            healthStatus,
            equals(PersistenceHealthStatus.healthy),
            reason: 'System should remain healthy after failed save attempt',
          );
        }
      },
    );
  });
}

/// 生成随机的支持语言
String _generateRandomSupportedLanguage(Faker faker) {
  const supportedLanguages = ['zh', 'en'];
  final randomIndex = faker.randomGenerator.integer(supportedLanguages.length);
  return supportedLanguages[randomIndex];
}

/// 生成语言切换序列
List<String> _generateLanguageSwitchSequence(Faker faker, int length) {
  const supportedLanguages = ['zh', 'en'];
  final sequence = <String>[];

  for (var i = 0; i < length; i++) {
    final randomIndex = faker.randomGenerator.integer(
      supportedLanguages.length,
    );
    sequence.add(supportedLanguages[randomIndex]);
  }

  return sequence;
}
