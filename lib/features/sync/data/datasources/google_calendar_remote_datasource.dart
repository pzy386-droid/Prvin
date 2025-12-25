
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:prvin/core/error/failures.dart';
import 'package:prvin/features/sync/data/models/calendar_event_model.dart';

/// Google Calendar远程数据源接口
abstract class GoogleCalendarRemoteDataSource {
  /// 认证Google Calendar
  Future<bool> authenticate();

  /// 检查认证状态
  Future<bool> isAuthenticated();

  /// 获取Google Calendar事件
  Future<List<CalendarEventModel>> getEvents({
    DateTime? timeMin,
    DateTime? timeMax,
    int? maxResults,
  });

  /// 创建Google Calendar事件
  Future<CalendarEventModel> createEvent(CalendarEventModel event);

  /// 更新Google Calendar事件
  Future<CalendarEventModel> updateEvent(CalendarEventModel event);

  /// 删除Google Calendar事件
  Future<void> deleteEvent(String externalId);

  /// 获取日历列表
  Future<List<Map<String, String>>> getCalendarList();

  /// 断开认证
  Future<void> signOut();
}

/// Google Calendar远程数据源实现
class GoogleCalendarRemoteDataSourceImpl
    implements GoogleCalendarRemoteDataSource {
  GoogleCalendarRemoteDataSourceImpl({required this.httpClient});

  final http.Client httpClient;

  // Google Calendar API客户端
  calendar.CalendarApi? _calendarApi;
  AuthClient? _authClient;

  // OAuth 2.0配置 - 在实际应用中应该从环境变量或配置文件读取
  static const String _clientId = 'your-google-client-id';
  static const String _clientSecret = 'your-google-client-secret';
  static const List<String> _scopes = [calendar.CalendarApi.calendarScope];

  @override
  Future<bool> authenticate() async {
    try {
      // 创建OAuth 2.0客户端凭据
      final clientId = ClientId(_clientId, _clientSecret);

      // 获取访问凭据
      final accessCredentials = await obtainAccessCredentialsViaUserConsent(
        clientId,
        _scopes,
        httpClient,
        (String url) {
          // 在实际应用中，这里应该打开浏览器或显示URL给用户
          print('请在浏览器中打开以下URL进行授权: $url');
        },
      );

      // 创建认证客户端
      _authClient = authenticatedClient(httpClient, accessCredentials);

      // 创建Calendar API客户端
      _calendarApi = calendar.CalendarApi(_authClient!);

      return true;
    } catch (e) {
      throw NetworkFailure('Google Calendar认证失败: $e');
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    return _calendarApi != null && _authClient != null;
  }

  @override
  Future<List<CalendarEventModel>> getEvents({
    DateTime? timeMin,
    DateTime? timeMax,
    int? maxResults,
  }) async {
    if (_calendarApi == null) {
      throw const NetworkFailure('未认证Google Calendar');
    }

    try {
      final events = await _calendarApi!.events.list(
        'primary',
        timeMin: timeMin,
        timeMax: timeMax,
        maxResults: maxResults ?? 100,
        singleEvents: true,
        orderBy: 'startTime',
      );

      return events.items?.map(_convertToCalendarEventModel).toList() ?? [];
    } catch (e) {
      throw NetworkFailure('获取Google Calendar事件失败: $e');
    }
  }

  @override
  Future<CalendarEventModel> createEvent(CalendarEventModel event) async {
    if (_calendarApi == null) {
      throw const NetworkFailure('未认证Google Calendar');
    }

    try {
      final googleEvent = _convertToGoogleEvent(event);
      final createdEvent = await _calendarApi!.events.insert(
        googleEvent,
        'primary',
      );

      return _convertToCalendarEventModel(createdEvent);
    } catch (e) {
      throw NetworkFailure('创建Google Calendar事件失败: $e');
    }
  }

  @override
  Future<CalendarEventModel> updateEvent(CalendarEventModel event) async {
    if (_calendarApi == null) {
      throw const NetworkFailure('未认证Google Calendar');
    }

    if (event.externalId == null) {
      throw const NetworkFailure('事件缺少外部ID，无法更新');
    }

    try {
      final googleEvent = _convertToGoogleEvent(event);
      final updatedEvent = await _calendarApi!.events.update(
        googleEvent,
        'primary',
        event.externalId!,
      );

      return _convertToCalendarEventModel(updatedEvent);
    } catch (e) {
      throw NetworkFailure('更新Google Calendar事件失败: $e');
    }
  }

  @override
  Future<void> deleteEvent(String externalId) async {
    if (_calendarApi == null) {
      throw const NetworkFailure('未认证Google Calendar');
    }

    try {
      await _calendarApi!.events.delete('primary', externalId);
    } catch (e) {
      throw NetworkFailure('删除Google Calendar事件失败: $e');
    }
  }

  @override
  Future<List<Map<String, String>>> getCalendarList() async {
    if (_calendarApi == null) {
      throw const NetworkFailure('未认证Google Calendar');
    }

    try {
      final calendarList = await _calendarApi!.calendarList.list();

      return calendarList.items
              ?.map(
                (cal) => {
                  'id': cal.id ?? '',
                  'summary': cal.summary ?? '',
                  'description': cal.description ?? '',
                  'primary': (cal.primary ?? false).toString(),
                },
              )
              .toList() ??
          [];
    } catch (e) {
      throw NetworkFailure('获取日历列表失败: $e');
    }
  }

  @override
  Future<void> signOut() async {
    _authClient?.close();
    _authClient = null;
    _calendarApi = null;
  }

  /// 将Google Calendar事件转换为CalendarEventModel
  CalendarEventModel _convertToCalendarEventModel(calendar.Event googleEvent) {
    final startTime = _parseDateTime(googleEvent.start);
    final endTime = _parseDateTime(googleEvent.end);
    final isAllDay = googleEvent.start?.date != null;

    return CalendarEventModel(
      id: googleEvent.id ?? '',
      title: googleEvent.summary ?? '无标题事件',
      description: googleEvent.description,
      startTime: startTime,
      endTime: endTime,
      source: EventSource.googleCalendar,
      externalId: googleEvent.id,
      isAllDay: isAllDay,
      location: googleEvent.location,
      attendees:
          googleEvent.attendees?.map((a) => a.email ?? '').toList() ?? [],
      reminders: _parseReminders(googleEvent.reminders),
      recurrenceRule: googleEvent.recurrence?.join(';'),
      metadata: {
        'htmlLink': googleEvent.htmlLink ?? '',
        'status': googleEvent.status ?? '',
        'visibility': googleEvent.visibility ?? '',
        'creator': googleEvent.creator?.email ?? '',
        'organizer': googleEvent.organizer?.email ?? '',
      },
      createdAt: googleEvent.created ?? DateTime.now(),
      updatedAt: googleEvent.updated ?? DateTime.now(),
      lastSyncAt: DateTime.now(),
    );
  }

  /// 将CalendarEventModel转换为Google Calendar事件
  calendar.Event _convertToGoogleEvent(CalendarEventModel event) {
    final googleEvent = calendar.Event();

    googleEvent.id = event.externalId;
    googleEvent.summary = event.title;
    googleEvent.description = event.description;
    googleEvent.location = event.location;

    // 设置时间
    if (event.isAllDay) {
      googleEvent.start = calendar.EventDateTime(
        date: DateTime(
          event.startTime.year,
          event.startTime.month,
          event.startTime.day,
        ),
      );
      googleEvent.end = calendar.EventDateTime(
        date: DateTime(
          event.endTime.year,
          event.endTime.month,
          event.endTime.day,
        ),
      );
    } else {
      googleEvent.start = calendar.EventDateTime(
        dateTime: event.startTime,
        timeZone: 'Asia/Shanghai',
      );
      googleEvent.end = calendar.EventDateTime(
        dateTime: event.endTime,
        timeZone: 'Asia/Shanghai',
      );
    }

    // 设置参与者
    if (event.attendees.isNotEmpty) {
      googleEvent.attendees = event.attendees.map((email) {
        final attendee = calendar.EventAttendee();
        attendee.email = email;
        return attendee;
      }).toList();
    }

    // 设置提醒
    if (event.reminders.isNotEmpty) {
      final reminders = calendar.EventReminders();
      reminders.useDefault = false;
      reminders.overrides = event.reminders.map((minutes) {
        final reminder = calendar.EventReminder();
        reminder.method = 'popup';
        reminder.minutes = minutes;
        return reminder;
      }).toList();
      googleEvent.reminders = reminders;
    }

    // 设置重复规则
    if (event.recurrenceRule != null && event.recurrenceRule!.isNotEmpty) {
      googleEvent.recurrence = [event.recurrenceRule!];
    }

    return googleEvent;
  }

  /// 解析Google Calendar的日期时间
  DateTime _parseDateTime(calendar.EventDateTime? eventDateTime) {
    if (eventDateTime?.dateTime != null) {
      return eventDateTime!.dateTime!;
    } else if (eventDateTime?.date != null) {
      return eventDateTime!.date!;
    }
    return DateTime.now();
  }

  /// 解析提醒设置
  List<int> _parseReminders(calendar.EventReminders? reminders) {
    if (reminders?.overrides == null) {
      return reminders?.useDefault ?? false ? [10] : []; // 默认10分钟提醒
    }

    return reminders!.overrides!
        .map((reminder) => reminder.minutes ?? 10)
        .toList();
  }
}
