import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prvin/core/error/language_toggle_exceptions.dart';
import 'package:prvin/core/services/language_persistence_service.dart';
import 'package:prvin/core/services/language_toggle_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 应用级事件
abstract class AppEvent extends Equatable {
  const AppEvent();
}

/// 应用初始化事件
class AppInitializeEvent extends AppEvent {
  const AppInitializeEvent();

  @override
  List<Object?> get props => [];
}

/// 应用主题切换事件
class AppThemeChangedEvent extends AppEvent {
  const AppThemeChangedEvent(this.isDarkMode);

  final bool isDarkMode;

  @override
  List<Object?> get props => [isDarkMode];
}

/// 应用语言切换事件
class AppLanguageChangedEvent extends AppEvent {
  const AppLanguageChangedEvent(this.languageCode);

  final String languageCode;

  @override
  List<Object?> get props => [languageCode];
}

/// 应用状态
abstract class AppState extends Equatable {
  const AppState();
}

/// 应用初始状态
class AppInitialState extends AppState {
  const AppInitialState();

  @override
  List<Object?> get props => [];
}

/// 应用加载状态
class AppLoadingState extends AppState {
  const AppLoadingState();

  @override
  List<Object?> get props => [];
}

/// 应用就绪状态
class AppReadyState extends AppState {
  const AppReadyState({this.isDarkMode = false, this.languageCode = 'zh'});

  final bool isDarkMode;
  final String languageCode;

  AppReadyState copyWith({bool? isDarkMode, String? languageCode}) {
    return AppReadyState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      languageCode: languageCode ?? this.languageCode,
    );
  }

  @override
  List<Object?> get props => [isDarkMode, languageCode];
}

/// 应用错误状态
class AppErrorState extends AppState {
  const AppErrorState(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

/// 应用级BLoC
class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc() : super(const AppInitialState()) {
    on<AppInitializeEvent>(_onInitialize);
    on<AppThemeChangedEvent>(_onThemeChanged);
    on<AppLanguageChangedEvent>(_onLanguageChanged);
  }

  // SharedPreferences键名常量
  static const String _themeKey = 'app_theme_dark_mode';
  static const String _languageKey = 'app_language_code';

  /// 处理应用初始化
  Future<void> _onInitialize(
    AppInitializeEvent event,
    Emitter<AppState> emit,
  ) async {
    emit(const AppLoadingState());

    try {
      // 模拟初始化过程
      await Future<void>.delayed(const Duration(seconds: 2));

      // 从持久化服务恢复用户偏好设置
      final persistenceService = LanguagePersistenceService.instance;

      // 检查持久化系统健康状态
      final healthStatus = await persistenceService.checkPersistenceHealth();
      if (healthStatus != PersistenceHealthStatus.healthy) {
        LanguageToggleLogger.logWarning(
          'Persistence system health check failed: $healthStatus, attempting repair',
        );

        final repairSuccess = await persistenceService
            .repairPersistenceSystem();
        if (!repairSuccess) {
          LanguageToggleLogger.logWarning(
            'Persistence system repair failed, using fallback initialization',
          );
        }
      }

      // 恢复语言设置
      final languageCode = await persistenceService.restoreLanguagePreference();

      // 从SharedPreferences加载主题设置（保持原有逻辑）
      final prefs = await SharedPreferences.getInstance();
      final isDarkMode = prefs.getBool(_themeKey) ?? false;

      emit(AppReadyState(isDarkMode: isDarkMode, languageCode: languageCode));

      LanguageToggleLogger.logDebug(
        'App initialization completed successfully',
        additionalData: {
          'languageCode': languageCode,
          'isDarkMode': isDarkMode,
          'persistenceHealth': healthStatus.toString(),
        },
      );
    } catch (e) {
      LanguageToggleLogger.logToggleError(
        'App initialization failed: $e',
        null,
      );
      emit(AppErrorState('初始化失败: $e'));
    }
  }

  /// 处理主题切换
  void _onThemeChanged(AppThemeChangedEvent event, Emitter<AppState> emit) {
    if (state is AppReadyState) {
      final currentState = state as AppReadyState;
      emit(currentState.copyWith(isDarkMode: event.isDarkMode));

      // 保存主题偏好到SharedPreferences（异步，不阻塞状态更新）
      _saveThemePreferenceWithErrorHandling(event.isDarkMode);
    }
  }

  /// 处理语言切换
  Future<void> _onLanguageChanged(
    AppLanguageChangedEvent event,
    Emitter<AppState> emit,
  ) async {
    if (state is AppReadyState) {
      final currentState = state as AppReadyState;
      final previousLanguage = currentState.languageCode;

      try {
        // 记录语言切换开始
        LanguageToggleLogger.logStateChange(
          previousLanguage,
          event.languageCode,
          trigger: 'AppLanguageChangedEvent',
        );

        // 更新状态
        emit(currentState.copyWith(languageCode: event.languageCode));

        // 保存语言偏好到SharedPreferences（异步，不阻塞状态更新）
        _saveLanguagePreferenceWithErrorHandling(
          event.languageCode,
          previousLanguage,
        );

        LanguageToggleLogger.logToggleSuccess(
          event.languageCode,
          Duration.zero, // BLoC内部切换是即时的
          additionalData: {
            'previousLanguage': previousLanguage,
            'trigger': 'bloc_event',
          },
        );
      } catch (e, stackTrace) {
        LanguageToggleLogger.logToggleError(
          'Language change in BLoC failed: $e',
          stackTrace,
          fromLanguage: previousLanguage,
          toLanguage: event.languageCode,
        );

        // 如果状态更新失败，保持原状态
        emit(currentState);
      }
    } else {
      LanguageToggleLogger.logWarning(
        'Attempted to change language when app is not ready. Current state: ${state.runtimeType}',
      );
    }
  }

  /// 保存语言偏好（带错误处理）
  Future<void> _saveLanguagePreferenceWithErrorHandling(
    String languageCode,
    String previousLanguage,
  ) async {
    try {
      final persistenceService = LanguagePersistenceService.instance;

      final success = await persistenceService.saveLanguagePreference(
        languageCode,
        previousLanguage: previousLanguage,
      );

      if (success) {
        LanguageToggleLogger.logDebug(
          'Language preference saved successfully via persistence service: $languageCode',
          additionalData: {
            'previousLanguage': previousLanguage,
            'service': 'LanguagePersistenceService',
          },
        );
      } else {
        // 如果新服务失败，尝试使用原有的直接保存方式作为降级策略
        await _fallbackLanguageSave(languageCode, previousLanguage);
      }
    } catch (e, stackTrace) {
      LanguageToggleLogger.logPreferencesSaveError(
        'Persistence service failed, attempting fallback save: $e',
        stackTrace,
        key: _languageKey,
        value: languageCode,
      );

      // 降级策略：使用原有的直接保存方式
      await _fallbackLanguageSave(languageCode, previousLanguage);
    }
  }

  /// 降级语言保存策略
  Future<void> _fallbackLanguageSave(
    String languageCode,
    String previousLanguage,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final success = await prefs.setString(_languageKey, languageCode);

      if (!success) {
        throw const PreferencesSaveException(
          'SharedPreferences.setString returned false for key: $_languageKey',
        );
      }

      LanguageToggleLogger.logWarning(
        'Language preference saved using fallback method: $languageCode',
        additionalData: {
          'key': _languageKey,
          'previousLanguage': previousLanguage,
          'method': 'fallback_direct_save',
        },
      );
    } catch (e, stackTrace) {
      LanguageToggleLogger.logPreferencesSaveError(
        'Fallback language save also failed: $e',
        stackTrace,
        key: _languageKey,
        value: languageCode,
      );

      // 不重新抛出异常，因为这不应该影响当前会话的语言切换
      // 只是下次启动时可能不会记住用户的选择
    }
  }

  /// 保存主题偏好（带错误处理）
  Future<void> _saveThemePreferenceWithErrorHandling(bool isDarkMode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final success = await prefs.setBool(_themeKey, isDarkMode);

      if (!success) {
        LanguageToggleLogger.logWarning(
          'SharedPreferences.setBool returned false for theme preference',
        );
      } else {
        LanguageToggleLogger.logDebug(
          'Theme preference saved successfully: $isDarkMode',
        );
      }
    } catch (e, stackTrace) {
      LanguageToggleLogger.logToggleError(
        'Failed to save theme preference: $e',
        stackTrace,
      );
    }
  }
}
