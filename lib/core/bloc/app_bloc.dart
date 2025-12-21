import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

  /// 处理应用初始化
  Future<void> _onInitialize(
    AppInitializeEvent event,
    Emitter<AppState> emit,
  ) async {
    emit(const AppLoadingState());

    try {
      // 模拟初始化过程
      await Future<void>.delayed(const Duration(seconds: 2));

      // 加载用户偏好设置
      // TODO: 从SharedPreferences加载设置

      emit(const AppReadyState());
    } catch (e) {
      emit(AppErrorState('初始化失败: $e'));
    }
  }

  /// 处理主题切换
  void _onThemeChanged(AppThemeChangedEvent event, Emitter<AppState> emit) {
    if (state is AppReadyState) {
      final currentState = state as AppReadyState;
      emit(currentState.copyWith(isDarkMode: event.isDarkMode));

      // TODO: 保存主题偏好到SharedPreferences
    }
  }

  /// 处理语言切换
  void _onLanguageChanged(
    AppLanguageChangedEvent event,
    Emitter<AppState> emit,
  ) {
    if (state is AppReadyState) {
      final currentState = state as AppReadyState;
      emit(currentState.copyWith(languageCode: event.languageCode));

      // TODO: 保存语言偏好到SharedPreferences
    }
  }
}
