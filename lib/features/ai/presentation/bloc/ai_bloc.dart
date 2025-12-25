import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prvin/core/services/language_toggle_logger.dart';
import 'package:prvin/features/ai/domain/entities/analytics_data.dart';
import 'package:prvin/features/ai/domain/usecases/ai_usecases.dart';
import 'package:prvin/features/task_management/domain/entities/task.dart';

// Events
abstract class AIEvent extends Equatable {
  const AIEvent();

  @override
  List<Object?> get props => [];
}

class AIGetTagSuggestions extends AIEvent {
  const AIGetTagSuggestions(this.taskTitle);

  final String taskTitle;

  @override
  List<Object?> get props => [taskTitle];
}

class AIGetCategorySuggestion extends AIEvent {
  const AIGetCategorySuggestion(this.taskTitle);

  final String taskTitle;

  @override
  List<Object?> get props => [taskTitle];
}

class AIGetFocusRecommendations extends AIEvent {
  const AIGetFocusRecommendations(this.userId);

  final String userId;

  @override
  List<Object?> get props => [userId];
}

class AIAnalyzeTaskPatterns extends AIEvent {
  const AIAnalyzeTaskPatterns(this.userId);

  final String userId;

  @override
  List<Object?> get props => [userId];
}

class AIGenerateAnalytics extends AIEvent {
  const AIGenerateAnalytics({required this.userId, required this.period});

  final String userId;
  final DateRange period;

  @override
  List<Object?> get props => [userId, period];
}

class AIClearSuggestions extends AIEvent {
  const AIClearSuggestions();
}

// States
abstract class AIState extends Equatable {
  const AIState();

  @override
  List<Object?> get props => [];
}

class AIInitial extends AIState {
  const AIInitial();
}

class AILoading extends AIState {
  const AILoading();
}

class AITagSuggestionsLoaded extends AIState {
  const AITagSuggestionsLoaded(this.suggestions);

  final List<String> suggestions;

  @override
  List<Object?> get props => [suggestions];
}

class AICategorySuggestionLoaded extends AIState {
  const AICategorySuggestionLoaded(this.category);

  final TaskCategory category;

  @override
  List<Object?> get props => [category];
}

class AIFocusRecommendationsLoaded extends AIState {
  const AIFocusRecommendationsLoaded(this.recommendations);

  final List<FocusRecommendation> recommendations;

  @override
  List<Object?> get props => [recommendations];
}

class AITaskPatternsLoaded extends AIState {
  const AITaskPatternsLoaded(this.patterns);

  final List<TaskPattern> patterns;

  @override
  List<Object?> get props => [patterns];
}

class AIAnalyticsLoaded extends AIState {
  const AIAnalyticsLoaded(this.analytics);

  final AnalyticsData analytics;

  @override
  List<Object?> get props => [analytics];
}

class AIError extends AIState {
  const AIError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

// BLoC
class AIBloc extends Bloc<AIEvent, AIState> {
  AIBloc(this._aiUseCases) : super(const AIInitial()) {
    on<AIGetTagSuggestions>(_onGetTagSuggestions);
    on<AIGetCategorySuggestion>(_onGetCategorySuggestion);
    on<AIGetFocusRecommendations>(_onGetFocusRecommendations);
    on<AIAnalyzeTaskPatterns>(_onAnalyzeTaskPatterns);
    on<AIGenerateAnalytics>(_onGenerateAnalytics);
    on<AIClearSuggestions>(_onClearSuggestions);
  }

  final AIUseCases _aiUseCases;

  Future<void> _onGetTagSuggestions(
    AIGetTagSuggestions event,
    Emitter<AIState> emit,
  ) async {
    try {
      emit(const AILoading());

      LanguageToggleLogger.logDebug(
        'Getting tag suggestions for: ${event.taskTitle}',
      );

      final stopwatch = Stopwatch()..start();
      final suggestions = await _aiUseCases.getTagSuggestions(event.taskTitle);
      stopwatch.stop();

      LanguageToggleLogger.logPerformanceMetric(
        'ai_tag_suggestions',
        stopwatch.elapsed,
        additionalData: {
          'taskTitle': event.taskTitle,
          'suggestionsCount': suggestions.length,
        },
      );

      emit(AITagSuggestionsLoaded(suggestions));
    } catch (e, stackTrace) {
      LanguageToggleLogger.logToggleError(
        'Failed to get tag suggestions: $e',
        stackTrace,
        additionalData: {'taskTitle': event.taskTitle},
      );
      emit(AIError('获取标签建议失败: $e'));
    }
  }

  Future<void> _onGetCategorySuggestion(
    AIGetCategorySuggestion event,
    Emitter<AIState> emit,
  ) async {
    try {
      emit(const AILoading());

      LanguageToggleLogger.logDebug(
        'Getting category suggestion for: ${event.taskTitle}',
      );

      final stopwatch = Stopwatch()..start();
      final category = await _aiUseCases.getCategorySuggestion(event.taskTitle);
      stopwatch.stop();

      LanguageToggleLogger.logPerformanceMetric(
        'ai_category_suggestion',
        stopwatch.elapsed,
        additionalData: {
          'taskTitle': event.taskTitle,
          'suggestedCategory': category.toString(),
        },
      );

      emit(AICategorySuggestionLoaded(category));
    } catch (e, stackTrace) {
      LanguageToggleLogger.logToggleError(
        'Failed to get category suggestion: $e',
        stackTrace,
        additionalData: {'taskTitle': event.taskTitle},
      );
      emit(AIError('获取分类建议失败: $e'));
    }
  }

  Future<void> _onGetFocusRecommendations(
    AIGetFocusRecommendations event,
    Emitter<AIState> emit,
  ) async {
    try {
      emit(const AILoading());

      LanguageToggleLogger.logDebug(
        'Getting focus recommendations for user: ${event.userId}',
      );

      final stopwatch = Stopwatch()..start();
      final recommendations = await _aiUseCases.getFocusRecommendations(
        event.userId,
      );
      stopwatch.stop();

      LanguageToggleLogger.logPerformanceMetric(
        'ai_focus_recommendations',
        stopwatch.elapsed,
        additionalData: {
          'userId': event.userId,
          'recommendationsCount': recommendations.length,
        },
      );

      emit(AIFocusRecommendationsLoaded(recommendations));
    } catch (e, stackTrace) {
      LanguageToggleLogger.logToggleError(
        'Failed to get focus recommendations: $e',
        stackTrace,
        additionalData: {'userId': event.userId},
      );
      emit(AIError('获取专注建议失败: $e'));
    }
  }

  Future<void> _onAnalyzeTaskPatterns(
    AIAnalyzeTaskPatterns event,
    Emitter<AIState> emit,
  ) async {
    try {
      emit(const AILoading());

      LanguageToggleLogger.logDebug(
        'Analyzing task patterns for user: ${event.userId}',
      );

      final stopwatch = Stopwatch()..start();
      final patterns = await _aiUseCases.analyzeTaskPatterns(event.userId);
      stopwatch.stop();

      LanguageToggleLogger.logPerformanceMetric(
        'ai_task_patterns',
        stopwatch.elapsed,
        additionalData: {
          'userId': event.userId,
          'patternsCount': patterns.length,
        },
      );

      emit(AITaskPatternsLoaded(patterns));
    } catch (e, stackTrace) {
      LanguageToggleLogger.logToggleError(
        'Failed to analyze task patterns: $e',
        stackTrace,
        additionalData: {'userId': event.userId},
      );
      emit(AIError('分析任务模式失败: $e'));
    }
  }

  Future<void> _onGenerateAnalytics(
    AIGenerateAnalytics event,
    Emitter<AIState> emit,
  ) async {
    try {
      emit(const AILoading());

      LanguageToggleLogger.logDebug(
        'Generating analytics for user: ${event.userId}',
      );

      final stopwatch = Stopwatch()..start();
      final analytics = await _aiUseCases.generateAnalytics(
        userId: event.userId,
        period: event.period,
      );
      stopwatch.stop();

      LanguageToggleLogger.logPerformanceMetric(
        'ai_analytics_generation',
        stopwatch.elapsed,
        additionalData: {
          'userId': event.userId,
          'periodDays': event.period.dayCount,
        },
      );

      emit(AIAnalyticsLoaded(analytics));
    } catch (e, stackTrace) {
      LanguageToggleLogger.logToggleError(
        'Failed to generate analytics: $e',
        stackTrace,
        additionalData: {'userId': event.userId},
      );
      emit(AIError('生成分析报告失败: $e'));
    }
  }

  Future<void> _onClearSuggestions(
    AIClearSuggestions event,
    Emitter<AIState> emit,
  ) async {
    LanguageToggleLogger.logDebug('Clearing AI suggestions');
    emit(const AIInitial());
  }
}
