/// 应用常量定义
class AppConstants {
  // 应用信息
  static const String appName = 'Prvin';
  static const String appVersion = '1.0.0';

  // 数据库
  static const String databaseName = 'prvine.db';
  static const int databaseVersion = 1;

  // 番茄钟默认时长
  static const Duration defaultPomodoroWorkDuration = Duration(minutes: 25);
  static const Duration defaultPomodoroShortBreak = Duration(minutes: 5);
  static const Duration defaultPomodoroLongBreak = Duration(minutes: 15);

  // 性能要求
  static const Duration maxStartupTime = Duration(seconds: 3);
  static const Duration maxResponseTime = Duration(milliseconds: 500);
  static const int minFrameRate = 60;

  // API端点
  static const String googleCalendarApiUrl =
      'https://www.googleapis.com/calendar/v3';
  static const String outlookApiUrl = 'https://graph.microsoft.com/v1.0';
}
