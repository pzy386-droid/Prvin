import 'package:prvin/core/services/language_persistence_service.dart';
import 'package:prvin/core/services/language_toggle_logger.dart';

/// 语言持久化功能演示服务
///
/// 提供持久化功能的演示和验证方法
class LanguagePersistenceDemo {
  static final LanguagePersistenceService _persistenceService =
      LanguagePersistenceService.instance;

  /// 演示完整的持久化流程
  static Future<void> demonstratePersistenceFlow() async {
    LanguageToggleLogger.logDebug('=== Language Persistence Demo Started ===');

    try {
      // 1. 检查系统健康状态
      await _demonstrateHealthCheck();

      // 2. 演示保存和恢复
      await _demonstrateSaveAndRestore();

      // 3. 演示错误处理
      await _demonstrateErrorHandling();

      // 4. 演示数据修复
      await _demonstrateDataRepair();

      // 5. 演示元数据功能
      await _demonstrateMetadata();

      LanguageToggleLogger.logDebug(
        '=== Language Persistence Demo Completed Successfully ===',
      );
    } catch (e, stackTrace) {
      LanguageToggleLogger.logToggleError(
        'Persistence demo failed: $e',
        stackTrace,
      );
    }
  }

  /// 演示健康检查功能
  static Future<void> _demonstrateHealthCheck() async {
    LanguageToggleLogger.logDebug('--- Demonstrating Health Check ---');

    final healthStatus = await _persistenceService.checkPersistenceHealth();
    LanguageToggleLogger.logDebug('Persistence system health: $healthStatus');

    switch (healthStatus) {
      case PersistenceHealthStatus.healthy:
        LanguageToggleLogger.logDebug('✓ System is healthy');
      case PersistenceHealthStatus.inconsistentData:
        LanguageToggleLogger.logWarning('⚠ Inconsistent data detected');
      case PersistenceHealthStatus.readFailure:
        LanguageToggleLogger.logWarning('⚠ Read failure detected');
      case PersistenceHealthStatus.writeFailure:
        LanguageToggleLogger.logWarning('⚠ Write failure detected');
      case PersistenceHealthStatus.systemError:
        LanguageToggleLogger.logWarning('⚠ System error detected');
    }
  }

  /// 演示保存和恢复功能
  static Future<void> _demonstrateSaveAndRestore() async {
    LanguageToggleLogger.logDebug('--- Demonstrating Save and Restore ---');

    // 保存中文设置
    final saveZhResult = await _persistenceService.saveLanguagePreference('zh');
    LanguageToggleLogger.logDebug('Save Chinese result: $saveZhResult');

    // 恢复设置
    var restoredLanguage = await _persistenceService
        .restoreLanguagePreference();
    LanguageToggleLogger.logDebug('Restored language: $restoredLanguage');

    // 保存英文设置
    final saveEnResult = await _persistenceService.saveLanguagePreference(
      'en',
      previousLanguage: 'zh',
    );
    LanguageToggleLogger.logDebug('Save English result: $saveEnResult');

    // 再次恢复设置
    restoredLanguage = await _persistenceService.restoreLanguagePreference();
    LanguageToggleLogger.logDebug(
      'Restored language after switch: $restoredLanguage',
    );

    // 验证当前保存的语言
    final currentSaved = await _persistenceService.getCurrentSavedLanguage();
    LanguageToggleLogger.logDebug('Current saved language: $currentSaved');

    // 检查是否有语言偏好设置
    final hasPreference = await _persistenceService.hasLanguagePreference();
    LanguageToggleLogger.logDebug('Has language preference: $hasPreference');
  }

  /// 演示错误处理功能
  static Future<void> _demonstrateErrorHandling() async {
    LanguageToggleLogger.logDebug('--- Demonstrating Error Handling ---');

    // 尝试保存不支持的语言
    final unsupportedResult = await _persistenceService.saveLanguagePreference(
      'fr',
    );
    LanguageToggleLogger.logDebug(
      'Unsupported language save result: $unsupportedResult',
    );

    // 验证系统仍然正常工作
    final healthAfterError = await _persistenceService.checkPersistenceHealth();
    LanguageToggleLogger.logDebug('Health after error: $healthAfterError');

    // 验证可以正常保存支持的语言
    final normalSaveResult = await _persistenceService.saveLanguagePreference(
      'zh',
    );
    LanguageToggleLogger.logDebug('Normal save after error: $normalSaveResult');
  }

  /// 演示数据修复功能
  static Future<void> _demonstrateDataRepair() async {
    LanguageToggleLogger.logDebug('--- Demonstrating Data Repair ---');

    // 检查当前健康状态
    var healthStatus = await _persistenceService.checkPersistenceHealth();
    LanguageToggleLogger.logDebug('Health before repair: $healthStatus');

    // 尝试修复系统
    final repairResult = await _persistenceService.repairPersistenceSystem();
    LanguageToggleLogger.logDebug('Repair result: $repairResult');

    // 检查修复后的健康状态
    healthStatus = await _persistenceService.checkPersistenceHealth();
    LanguageToggleLogger.logDebug('Health after repair: $healthStatus');
  }

  /// 演示元数据功能
  static Future<void> _demonstrateMetadata() async {
    LanguageToggleLogger.logDebug('--- Demonstrating Metadata ---');

    // 保存带有元数据的语言设置
    await _persistenceService.saveLanguagePreference(
      'en',
      previousLanguage: 'zh',
    );

    // 获取元数据
    final metadata = await _persistenceService.getLanguageMetadata();
    if (metadata != null) {
      LanguageToggleLogger.logDebug('Language metadata:');
      LanguageToggleLogger.logDebug(
        '  - Language Code: ${metadata['languageCode']}',
      );
      LanguageToggleLogger.logDebug(
        '  - Previous Language: ${metadata['previousLanguage']}',
      );
      LanguageToggleLogger.logDebug('  - Timestamp: ${metadata['timestamp']}');
      LanguageToggleLogger.logDebug('  - Version: ${metadata['version']}');
    } else {
      LanguageToggleLogger.logWarning('No metadata found');
    }
  }

  /// 清理演示数据
  static Future<void> cleanupDemo() async {
    LanguageToggleLogger.logDebug('--- Cleaning up demo data ---');

    final clearResult = await _persistenceService.clearLanguagePreference();
    LanguageToggleLogger.logDebug('Clear result: $clearResult');

    // 验证清理结果
    final hasPreference = await _persistenceService.hasLanguagePreference();
    LanguageToggleLogger.logDebug(
      'Has preference after cleanup: $hasPreference',
    );

    final restoredAfterClear = await _persistenceService
        .restoreLanguagePreference();
    LanguageToggleLogger.logDebug(
      'Restored after clear (should be default): $restoredAfterClear',
    );
  }

  /// 获取持久化系统状态报告
  static Future<Map<String, dynamic>> getSystemStatusReport() async {
    final healthStatus = await _persistenceService.checkPersistenceHealth();
    final hasPreference = await _persistenceService.hasLanguagePreference();
    final currentLanguage = await _persistenceService.getCurrentSavedLanguage();
    final metadata = await _persistenceService.getLanguageMetadata();

    return {
      'healthStatus': healthStatus.toString(),
      'hasPreference': hasPreference,
      'currentLanguage': currentLanguage,
      'metadata': metadata,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// 验证持久化功能的完整性
  static Future<bool> validatePersistenceIntegrity() async {
    try {
      LanguageToggleLogger.logDebug('--- Validating Persistence Integrity ---');

      // 1. 健康检查
      final healthStatus = await _persistenceService.checkPersistenceHealth();
      if (healthStatus != PersistenceHealthStatus.healthy) {
        LanguageToggleLogger.logWarning('Health check failed: $healthStatus');
        return false;
      }

      // 2. 保存和恢复测试
      const testLanguage = 'en';
      final saveResult = await _persistenceService.saveLanguagePreference(
        testLanguage,
      );
      if (!saveResult) {
        LanguageToggleLogger.logWarning('Save test failed');
        return false;
      }

      final restoredLanguage = await _persistenceService
          .restoreLanguagePreference();
      if (restoredLanguage != testLanguage) {
        LanguageToggleLogger.logWarning(
          'Restore test failed: expected $testLanguage, got $restoredLanguage',
        );
        return false;
      }

      // 3. 元数据测试
      final metadata = await _persistenceService.getLanguageMetadata();
      if (metadata == null || metadata['languageCode'] != testLanguage) {
        LanguageToggleLogger.logWarning('Metadata test failed');
        return false;
      }

      LanguageToggleLogger.logDebug(
        '✓ Persistence integrity validation passed',
      );
      return true;
    } catch (e, stackTrace) {
      LanguageToggleLogger.logToggleError(
        'Persistence integrity validation failed: $e',
        stackTrace,
      );
      return false;
    }
  }
}
