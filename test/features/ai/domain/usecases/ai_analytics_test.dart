import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:prvin/features/ai/domain/entities/analytics_data.dart';
import 'package:prvin/features/ai/domain/repositories/ai_analytics_repository.dart';
import 'package:prvin/features/ai/domain/usecases/ai_analytics.dart';

import 'ai_analytics_test.mocks.dart';

@GenerateMocks([AIAnalyticsRepository])
void main() {
  late AIAnalytics aiAnalytics;
  late MockAIAnalyticsRepository mockRepository;

  setUp(() {
    mockRepository = MockAIAnalyticsRepository();
    aiAnalytics = AIAnalytics(mockRepository);
  });

  group('AIAnalytics', () {
    test('should generate today report successfully', () async {
      // Arrange
      const userId = 'test-user';
      final today = DateTime.now();
      final expectedData = AnalyticsData(
        userId: userId,
        period: DateRange(
          startDate: DateTime(today.year, today.month, today.day),
          endDate: today,
        ),
        timeDistribution: const {'work': 120, 'study': 60},
        completionRate: 0.8,
        trends: const [],
        focusPatterns: const [],
        taskPatterns: const [],
        focusRecommendations: const [],
        generatedAt: today,
      );

      when(
        mockRepository.generateAnalytics(
          userId: anyNamed('userId'),
          period: anyNamed('period'),
        ),
      ).thenAnswer((_) async => expectedData);

      // Act
      final result = await aiAnalytics.generateTodayReport(userId);

      // Assert
      expect(result.userId, equals(userId));
      expect(result.completionRate, equals(0.8));
      expect(result.timeDistribution['work'], equals(120));
      verify(
        mockRepository.generateAnalytics(
          userId: userId,
          period: anyNamed('period'),
        ),
      ).called(1);
    });

    test('should get smart tag suggestions', () async {
      // Arrange
      const taskTitle = '开发新功能';
      const expectedTags = ['开发', '编程', '技术'];
      when(
        mockRepository.getTagSuggestions(taskTitle),
      ).thenAnswer((_) async => expectedTags);

      // Act
      final result = await aiAnalytics.getSmartTagSuggestions(taskTitle);

      // Assert
      expect(result, equals(expectedTags));
      verify(mockRepository.getTagSuggestions(taskTitle)).called(1);
    });

    test('should get smart category suggestion', () async {
      // Arrange
      const taskTitle = '工作会议';
      const expectedCategory = TaskCategory.work;
      when(
        mockRepository.getCategorySuggestion(taskTitle),
      ).thenAnswer((_) async => expectedCategory);

      // Act
      final result = await aiAnalytics.getSmartCategorySuggestion(taskTitle);

      // Assert
      expect(result, equals(expectedCategory));
      verify(mockRepository.getCategorySuggestion(taskTitle)).called(1);
    });

    test('should get personalized focus advice', () async {
      // Arrange
      const userId = 'test-user';
      final expectedRecommendations = [
        FocusRecommendation(
          type: '最佳专注时间',
          message: '上午9-11点是您的最佳专注时间',
          recommendedMinutes: 25,
          bestHours: const [9, 10, 11],
          confidence: 0.8,
          generatedAt: DateTime.now(),
        ),
      ];
      when(
        mockRepository.getFocusRecommendations(userId),
      ).thenAnswer((_) async => expectedRecommendations);

      // Act
      final result = await aiAnalytics.getPersonalizedFocusAdvice(userId);

      // Assert
      expect(result.length, equals(1));
      expect(result.first.type, equals('最佳专注时间'));
      expect(result.first.recommendedMinutes, equals(25));
      verify(mockRepository.getFocusRecommendations(userId)).called(1);
    });

    test('should analyze productivity trends', () async {
      // Arrange
      const userId = 'test-user';
      final period = DateRange(
        startDate: DateTime.now().subtract(const Duration(days: 7)),
        endDate: DateTime.now(),
      );
      final trends = [
        ProductivityTrend(
          date: DateTime.now().subtract(const Duration(days: 1)),
          completedTasks: 5,
          totalWorkMinutes: 240,
          focusMinutes: 180,
          efficiencyScore: 85,
        ),
        ProductivityTrend(
          date: DateTime.now(),
          completedTasks: 3,
          totalWorkMinutes: 180,
          focusMinutes: 120,
          efficiencyScore: 75,
        ),
      ];

      when(
        mockRepository.getProductivityTrends(userId: userId, period: period),
      ).thenAnswer((_) async => trends);

      // Act
      final insights = await aiAnalytics.getProductivityInsights(
        userId: userId,
        period: period,
      );

      // Assert
      expect(insights.averageEfficiency, equals(80.0));
      expect(insights.bestDay?.efficiencyScore, equals(85.0));
      expect(insights.worstDay?.efficiencyScore, equals(75.0));
      verify(
        mockRepository.getProductivityTrends(userId: userId, period: period),
      ).called(1);
    });

    test('should generate weekly report', () async {
      // Arrange
      const userId = 'test-user';
      final now = DateTime.now();
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final expectedData = AnalyticsData(
        userId: userId,
        period: DateRange(
          startDate: DateTime(
            startOfWeek.year,
            startOfWeek.month,
            startOfWeek.day,
          ),
          endDate: now,
        ),
        timeDistribution: const {'work': 600, 'study': 300},
        completionRate: 0.75,
        trends: const [],
        focusPatterns: const [],
        taskPatterns: const [],
        focusRecommendations: const [],
        generatedAt: now,
      );

      when(
        mockRepository.generateAnalytics(
          userId: anyNamed('userId'),
          period: anyNamed('period'),
        ),
      ).thenAnswer((_) async => expectedData);

      // Act
      final result = await aiAnalytics.generateWeeklyReport(userId);

      // Assert
      expect(result.userId, equals(userId));
      expect(result.completionRate, equals(0.75));
      expect(result.period.dayCount, greaterThan(1));
      verify(
        mockRepository.generateAnalytics(
          userId: userId,
          period: anyNamed('period'),
        ),
      ).called(1);
    });
  });
}
