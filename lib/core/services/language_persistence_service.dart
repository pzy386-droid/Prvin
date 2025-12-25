import 'dart:async';
import 'dart:convert';

import 'package:prvin/core/error/language_toggle_exceptions.dart';
import 'package:prvin/core/services/injection_container.dart';
import 'package:prvin/core/services/language_toggle_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 语言持久化服务
///
/// 负责语言设置的保存、恢复和验证，提供完整的错误处理和降级策略
class LanguagePersistenceService {
  // 私有构造函数
  LanguagePersistenceService._();

  /// 单例实例
  static final LanguagePersistenceService _instance =
      LanguagePersistenceService._();

  /// 获取单例实例
  static LanguagePersistenceService get instance => _instance;

  // SharedPreferences键名常量
  static const String _languageKey = 'app_language_code';
  static const String _languageBackupKey = 'app_language_code_backup';
  static const String _languageMetadataKey = 'app_language_metadata';

  // 默认语言设置
  static const String _defaultLanguage = 'zh';

  // 支持的语言列表
  static const List<String> _supportedLanguages = ['zh', 'en'];

  // 重试配置
  static const int _maxRetryAttempts = 3;
  static const Duration _retryDelay = Duration(milliseconds: 200);

  /// 保存语言设置
  ///
  /// [languageCode] - 要保存的语言代码
  /// [previousLanguage] - 之前的语言代码（用于回滚）
  ///
  /// 返回保存是否成功
  Future<bool> saveLanguagePreference(
    String languageCode, {
    String? previousLanguage,
  }) async {
    try {
      // 验证语言代码
      if (!_isLanguageSupported(languageCode)) {
        throw UnsupportedLanguageException(languageCode);
      }

      LanguageToggleLogger.logDebug(
        'Attempting to save language preference: $languageCode',
        additionalData: {
          'previousLanguage': previousLanguage,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      // 使用重试机制保存
      final success = await _withRetry<bool>(
        () => _performSave(languageCode, previousLanguage),
        shouldRetry: (error) =>
            error is PreferencesSaveException || error is TimeoutException,
      );

      if (success) {
        LanguageToggleLogger.logDebug(
          'Language preference saved successfully: $languageCode',
          additionalData: {
            'key': _languageKey,
            'previousLanguage': previousLanguage,
          },
        );
        return true;
      } else {
        throw const PreferencesSaveException(
          'Failed to save language preference after retries',
        );
      }
    } catch (e, stackTrace) {
      LanguageToggleLogger.logPreferencesSaveError(
        'Failed to save language preference: $e',
        stackTrace,
        key: _languageKey,
        value: languageCode,
      );

      // 尝试降级策略：保存到备份位置
      await _attemptBackupSave(languageCode, previousLanguage);

      return false;
    }
  }

  /// 执行实际的保存操作
  Future<bool> _performSave(
    String languageCode,
    String? previousLanguage,
  ) async {
    final prefs = await _getSharedPreferences();

    // 创建语言元数据
    final metadata = _createLanguageMetadata(languageCode, previousLanguage);

    // 执行原子性保存操作
    final results = await Future.wait([
      prefs.setString(_languageKey, languageCode),
      prefs.setString(_languageBackupKey, languageCode),
      prefs.setString(_languageMetadataKey, jsonEncode(metadata)),
    ]);

    // 检查所有保存操作是否成功
    final allSuccessful = results.every((result) => result);

    if (!allSuccessful) {
      throw const PreferencesSaveException(
        'One or more SharedPreferences save operations failed',
      );
    }

    return true;
  }

  /// 尝试备份保存
  Future<void> _attemptBackupSave(
    String languageCode,
    String? previousLanguage,
  ) async {
    try {
      final prefs = await _getSharedPreferences();
      await prefs.setString(_languageBackupKey, languageCode);

      LanguageToggleLogger.logWarning(
        'Primary save failed, but backup save succeeded for: $languageCode',
      );
    } catch (e) {
      LanguageToggleLogger.logToggleError(
        'Both primary and backup save failed: $e',
        null,
        toLanguage: languageCode,
      );
    }
  }

  /// 恢复语言设置
  ///
  /// 返回恢复的语言代码，如果失败则返回默认语言
  Future<String> restoreLanguagePreference() async {
    try {
      LanguageToggleLogger.logDebug(
        'Attempting to restore language preference',
      );

      final prefs = await _getSharedPreferences();

      // 尝试从主要位置恢复
      var languageCode = prefs.getString(_languageKey);

      if (languageCode != null && _isLanguageSupported(languageCode)) {
        // 验证语言设置的完整性
        final isValid = await _validateLanguageSetting(languageCode);

        if (isValid) {
          LanguageToggleLogger.logDebug(
            'Language preference restored successfully: $languageCode',
          );
          return languageCode;
        } else {
          LanguageToggleLogger.logWarning(
            'Primary language setting validation failed, trying backup',
          );
        }
      }

      // 尝试从备份位置恢复
      languageCode = prefs.getString(_languageBackupKey);

      if (languageCode != null && _isLanguageSupported(languageCode)) {
        LanguageToggleLogger.logWarning(
          'Restored language from backup: $languageCode',
        );

        // 尝试修复主要设置
        await _repairPrimaryLanguageSetting(languageCode);

        return languageCode;
      }

      // 如果都失败了，使用默认语言
      LanguageToggleLogger.logWarning(
        'Failed to restore language preference, using default: $_defaultLanguage',
      );

      return _defaultLanguage;
    } catch (e, stackTrace) {
      LanguageToggleLogger.logToggleError(
        'Error during language preference restoration: $e',
        stackTrace,
      );

      return _defaultLanguage;
    }
  }

  /// 验证语言设置的完整性
  Future<bool> _validateLanguageSetting(String languageCode) async {
    try {
      final prefs = await _getSharedPreferences();

      // 检查主要设置
      final primaryLanguage = prefs.getString(_languageKey);
      if (primaryLanguage != languageCode) {
        return false;
      }

      // 检查备份设置
      final backupLanguage = prefs.getString(_languageBackupKey);
      if (backupLanguage != languageCode) {
        LanguageToggleLogger.logWarning(
          'Backup language setting inconsistent: expected $languageCode, got $backupLanguage',
        );
        // 备份不一致不算致命错误，但需要修复
        await _repairBackupLanguageSetting(languageCode);
      }

      // 检查元数据
      final metadataJson = prefs.getString(_languageMetadataKey);
      if (metadataJson != null) {
        try {
          final metadata = jsonDecode(metadataJson) as Map<String, dynamic>;
          final metadataLanguage = metadata['languageCode'] as String?;

          if (metadataLanguage != languageCode) {
            LanguageToggleLogger.logWarning(
              'Language metadata inconsistent: expected $languageCode, got $metadataLanguage',
            );
          }
        } catch (e) {
          LanguageToggleLogger.logWarning(
            'Failed to parse language metadata: $e',
          );
        }
      }

      return true;
    } catch (e) {
      LanguageToggleLogger.logWarning('Language setting validation failed: $e');
      return false;
    }
  }

  /// 修复主要语言设置
  Future<void> _repairPrimaryLanguageSetting(String languageCode) async {
    try {
      final prefs = await _getSharedPreferences();
      await prefs.setString(_languageKey, languageCode);

      LanguageToggleLogger.logDebug(
        'Repaired primary language setting: $languageCode',
      );
    } catch (e) {
      LanguageToggleLogger.logWarning(
        'Failed to repair primary language setting: $e',
      );
    }
  }

  /// 修复备份语言设置
  Future<void> _repairBackupLanguageSetting(String languageCode) async {
    try {
      final prefs = await _getSharedPreferences();
      await prefs.setString(_languageBackupKey, languageCode);

      LanguageToggleLogger.logDebug(
        'Repaired backup language setting: $languageCode',
      );
    } catch (e) {
      LanguageToggleLogger.logWarning(
        'Failed to repair backup language setting: $e',
      );
    }
  }

  /// 清除语言设置
  ///
  /// 用于重置或清理损坏的设置
  Future<bool> clearLanguagePreference() async {
    try {
      LanguageToggleLogger.logDebug('Clearing language preferences');

      final prefs = await _getSharedPreferences();

      final results = await Future.wait([
        prefs.remove(_languageKey),
        prefs.remove(_languageBackupKey),
        prefs.remove(_languageMetadataKey),
      ]);

      final allSuccessful = results.every((result) => result);

      if (allSuccessful) {
        LanguageToggleLogger.logDebug(
          'Language preferences cleared successfully',
        );
      } else {
        LanguageToggleLogger.logWarning(
          'Some language preferences failed to clear',
        );
      }

      return allSuccessful;
    } catch (e, stackTrace) {
      LanguageToggleLogger.logToggleError(
        'Failed to clear language preferences: $e',
        stackTrace,
      );
      return false;
    }
  }

  /// 获取当前保存的语言设置（不进行恢复逻辑）
  Future<String?> getCurrentSavedLanguage() async {
    try {
      final prefs = await _getSharedPreferences();
      return prefs.getString(_languageKey);
    } catch (e) {
      LanguageToggleLogger.logWarning(
        'Failed to get current saved language: $e',
      );
      return null;
    }
  }

  /// 检查语言设置是否存在
  Future<bool> hasLanguagePreference() async {
    try {
      final prefs = await _getSharedPreferences();
      return prefs.containsKey(_languageKey);
    } catch (e) {
      LanguageToggleLogger.logWarning(
        'Failed to check language preference existence: $e',
      );
      return false;
    }
  }

  /// 获取语言设置元数据
  Future<Map<String, dynamic>?> getLanguageMetadata() async {
    try {
      final prefs = await _getSharedPreferences();
      final metadataJson = prefs.getString(_languageMetadataKey);

      if (metadataJson != null) {
        return jsonDecode(metadataJson) as Map<String, dynamic>;
      }

      return null;
    } catch (e) {
      LanguageToggleLogger.logWarning('Failed to get language metadata: $e');
      return null;
    }
  }

  /// 验证持久化系统的健康状态
  Future<PersistenceHealthStatus> checkPersistenceHealth() async {
    try {
      final prefs = await _getSharedPreferences();

      // 检查基本读写能力
      const testKey = 'language_persistence_health_test';
      const testValue = 'test_value';

      final writeSuccess = await prefs.setString(testKey, testValue);
      if (!writeSuccess) {
        return PersistenceHealthStatus.writeFailure;
      }

      final readValue = prefs.getString(testKey);
      if (readValue != testValue) {
        return PersistenceHealthStatus.readFailure;
      }

      // 清理测试数据
      await prefs.remove(testKey);

      // 检查语言设置的一致性
      final primaryLanguage = prefs.getString(_languageKey);
      final backupLanguage = prefs.getString(_languageBackupKey);

      if (primaryLanguage != null && backupLanguage != null) {
        if (primaryLanguage != backupLanguage) {
          return PersistenceHealthStatus.inconsistentData;
        }
      }

      return PersistenceHealthStatus.healthy;
    } catch (e) {
      LanguageToggleLogger.logToggleError(
        'Persistence health check failed: $e',
        null,
      );
      return PersistenceHealthStatus.systemError;
    }
  }

  /// 修复持久化系统
  Future<bool> repairPersistenceSystem() async {
    try {
      LanguageToggleLogger.logDebug('Attempting to repair persistence system');

      final healthStatus = await checkPersistenceHealth();

      switch (healthStatus) {
        case PersistenceHealthStatus.healthy:
          LanguageToggleLogger.logDebug(
            'Persistence system is healthy, no repair needed',
          );
          return true;

        case PersistenceHealthStatus.inconsistentData:
          return await _repairInconsistentData();

        case PersistenceHealthStatus.readFailure:
        case PersistenceHealthStatus.writeFailure:
        case PersistenceHealthStatus.systemError:
          return await _repairSystemError();
      }
    } catch (e, stackTrace) {
      LanguageToggleLogger.logToggleError(
        'Persistence system repair failed: $e',
        stackTrace,
      );
      return false;
    }
  }

  /// 修复数据不一致问题
  Future<bool> _repairInconsistentData() async {
    try {
      final prefs = await _getSharedPreferences();

      final primaryLanguage = prefs.getString(_languageKey);
      final backupLanguage = prefs.getString(_languageBackupKey);

      // 优先使用主要设置
      String correctLanguage;
      if (primaryLanguage != null && _isLanguageSupported(primaryLanguage)) {
        correctLanguage = primaryLanguage;
      } else if (backupLanguage != null &&
          _isLanguageSupported(backupLanguage)) {
        correctLanguage = backupLanguage;
      } else {
        correctLanguage = _defaultLanguage;
      }

      // 统一所有设置
      final results = await Future.wait([
        prefs.setString(_languageKey, correctLanguage),
        prefs.setString(_languageBackupKey, correctLanguage),
        prefs.setString(
          _languageMetadataKey,
          jsonEncode(_createLanguageMetadata(correctLanguage, null)),
        ),
      ]);

      final success = results.every((result) => result);

      if (success) {
        LanguageToggleLogger.logDebug(
          'Inconsistent data repaired, unified to: $correctLanguage',
        );
      }

      return success;
    } catch (e) {
      LanguageToggleLogger.logWarning('Failed to repair inconsistent data: $e');
      return false;
    }
  }

  /// 修复系统错误
  Future<bool> _repairSystemError() async {
    try {
      // 清除所有设置并重新初始化
      await clearLanguagePreference();

      // 使用默认语言重新初始化
      final success = await saveLanguagePreference(_defaultLanguage);

      if (success) {
        LanguageToggleLogger.logDebug(
          'System error repaired, reset to default language: $_defaultLanguage',
        );
      }

      return success;
    } catch (e) {
      LanguageToggleLogger.logWarning('Failed to repair system error: $e');
      return false;
    }
  }

  /// 创建语言元数据
  Map<String, dynamic> _createLanguageMetadata(
    String languageCode,
    String? previousLanguage,
  ) {
    return {
      'languageCode': languageCode,
      'previousLanguage': previousLanguage,
      'timestamp': DateTime.now().toIso8601String(),
      'version': '1.0',
    };
  }

  /// 检查语言是否支持
  bool _isLanguageSupported(String languageCode) {
    return _supportedLanguages.contains(languageCode);
  }

  /// 获取SharedPreferences实例
  Future<SharedPreferences> _getSharedPreferences() async {
    try {
      // 优先使用依赖注入容器中的实例
      if (sl.isRegistered<SharedPreferences>()) {
        return sl<SharedPreferences>();
      }

      // 如果没有注册，直接获取实例
      return await SharedPreferences.getInstance();
    } catch (e) {
      LanguageToggleLogger.logWarning(
        'Failed to get SharedPreferences from DI container, using direct instance: $e',
      );
      return SharedPreferences.getInstance();
    }
  }

  /// 带重试机制的操作执行
  Future<T> _withRetry<T>(
    Future<T> Function() operation, {
    int maxAttempts = _maxRetryAttempts,
    Duration delay = _retryDelay,
    bool Function(dynamic error)? shouldRetry,
  }) async {
    var attempts = 0;

    while (attempts < maxAttempts) {
      try {
        attempts++;
        final result = await operation();

        if (attempts > 1) {
          LanguageToggleLogger.logDebug(
            'Operation succeeded after $attempts attempts',
          );
        }

        return result;
      } catch (error, stackTrace) {
        final isLastAttempt = attempts >= maxAttempts;
        final shouldRetryError = shouldRetry?.call(error) ?? true;

        if (isLastAttempt || !shouldRetryError) {
          LanguageToggleLogger.logToggleError(
            'Operation failed after $attempts attempts: $error',
            stackTrace,
          );
          rethrow;
        }

        LanguageToggleLogger.logWarning(
          'Operation failed (attempt $attempts/$maxAttempts), retrying in ${delay.inMilliseconds}ms: $error',
        );

        await Future<void>.delayed(delay);
      }
    }

    throw Exception('Unreachable code');
  }
}

/// 持久化系统健康状态
enum PersistenceHealthStatus {
  /// 系统健康
  healthy,

  /// 读取失败
  readFailure,

  /// 写入失败
  writeFailure,

  /// 数据不一致
  inconsistentData,

  /// 系统错误
  systemError,
}
