import 'package:flutter_test/flutter_test.dart';
import 'package:prvin/core/bloc/app_bloc.dart';
import 'package:prvin/core/services/language_persistence_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Language Persistence Integration Tests', () {
    late AppBloc appBloc;
    late LanguagePersistenceService persistenceService;

    setUp(() {
      // 重置SharedPreferences
      SharedPreferences.setMockInitialValues({});

      appBloc = AppBloc();
      persistenceService = LanguagePersistenceService.instance;
    });

    tearDown(() {
      appBloc.close();
    });

    test('should persist language changes through AppBloc', () async {
      // Arrange - 初始化应用
      appBloc.add(const AppInitializeEvent());

      // 等待初始化完成
      await Future.delayed(const Duration(seconds: 3));

      // 验证初始状态
      expect(appBloc.state, isA<AppReadyState>());
      final initialState = appBloc.state as AppReadyState;
      expect(initialState.languageCode, equals('zh')); // 默认语言

      // Act - 切换语言
      appBloc.add(const AppLanguageChangedEvent('en'));

      // 等待状态更新和持久化
      await Future.delayed(const Duration(milliseconds: 500));

      // Assert - 验证状态已更新
      expect(appBloc.state, isA<AppReadyState>());
      final updatedState = appBloc.state as AppReadyState;
      expect(updatedState.languageCode, equals('en'));

      // 验证持久化服务中的数据
      final savedLanguage = await persistenceService.getCurrentSavedLanguage();
      expect(savedLanguage, equals('en'));

      // 验证恢复功能
      final restoredLanguage = await persistenceService
          .restoreLanguagePreference();
      expect(restoredLanguage, equals('en'));
    });

    test('should handle app restart with persisted language', () async {
      // Arrange - 先保存一个语言设置
      await persistenceService.saveLanguagePreference('en');

      // Act - 创建新的AppBloc实例（模拟应用重启）
      final newAppBloc = AppBloc();
      newAppBloc.add(const AppInitializeEvent());

      // 等待初始化完成
      await Future.delayed(const Duration(seconds: 3));

      // Assert - 验证恢复的语言设置
      expect(newAppBloc.state, isA<AppReadyState>());
      final state = newAppBloc.state as AppReadyState;
      expect(state.languageCode, equals('en'));

      // 清理
      await newAppBloc.close();
    });

    test('should handle persistence failure gracefully', () async {
      // Arrange - 初始化应用
      appBloc.add(const AppInitializeEvent());
      await Future.delayed(const Duration(seconds: 3));

      // Act - 尝试保存不支持的语言（这会触发错误处理）
      final saveResult = await persistenceService.saveLanguagePreference('fr');

      // Assert - 验证错误被正确处理
      expect(saveResult, isFalse); // 保存应该失败

      // 验证应用状态仍然正常
      expect(appBloc.state, isA<AppReadyState>());

      // 验证可以正常切换到支持的语言
      appBloc.add(const AppLanguageChangedEvent('en'));
      await Future.delayed(const Duration(milliseconds: 500));

      final state = appBloc.state as AppReadyState;
      expect(state.languageCode, equals('en'));
    });

    test('should repair corrupted persistence data', () async {
      // Arrange - 模拟损坏的数据
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('app_language_code', 'en');
      await prefs.setString('app_language_code_backup', 'zh'); // 不一致的备份

      // Act - 检查健康状态
      final healthStatus = await persistenceService.checkPersistenceHealth();
      expect(healthStatus, equals(PersistenceHealthStatus.inconsistentData));

      // 修复系统
      final repairResult = await persistenceService.repairPersistenceSystem();
      expect(repairResult, isTrue);

      // Assert - 验证数据已修复
      final repairedHealthStatus = await persistenceService
          .checkPersistenceHealth();
      expect(repairedHealthStatus, equals(PersistenceHealthStatus.healthy));

      // 验证数据一致性
      final primary = prefs.getString('app_language_code');
      final backup = prefs.getString('app_language_code_backup');
      expect(primary, equals(backup));
    });

    test('should handle multiple rapid language switches', () async {
      // Arrange
      appBloc.add(const AppInitializeEvent());
      await Future.delayed(const Duration(seconds: 3));

      // Act - 快速连续切换语言
      appBloc.add(const AppLanguageChangedEvent('en'));
      await Future.delayed(const Duration(milliseconds: 100));

      appBloc.add(const AppLanguageChangedEvent('zh'));
      await Future.delayed(const Duration(milliseconds: 100));

      appBloc.add(const AppLanguageChangedEvent('en'));
      await Future.delayed(const Duration(milliseconds: 500));

      // Assert - 验证最终状态
      expect(appBloc.state, isA<AppReadyState>());
      final finalState = appBloc.state as AppReadyState;
      expect(finalState.languageCode, equals('en'));

      // 验证持久化的数据与最终状态一致
      final savedLanguage = await persistenceService.getCurrentSavedLanguage();
      expect(savedLanguage, equals('en'));
    });

    test('should maintain metadata consistency', () async {
      // Arrange
      SharedPreferences.setMockInitialValues({});

      // Act - 保存语言设置
      await persistenceService.saveLanguagePreference(
        'en',
        previousLanguage: 'zh',
      );

      // Assert - 验证元数据
      final metadata = await persistenceService.getLanguageMetadata();
      expect(metadata, isNotNull);
      expect(metadata!['languageCode'], equals('en'));
      expect(metadata['previousLanguage'], equals('zh'));
      expect(metadata['version'], equals('1.0'));
      expect(metadata['timestamp'], isA<String>());

      // 验证时间戳格式
      final timestamp = DateTime.parse(metadata['timestamp'] as String);
      expect(timestamp.isBefore(DateTime.now()), isTrue);
    });
  });
}
