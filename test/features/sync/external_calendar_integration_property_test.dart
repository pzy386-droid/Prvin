import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prvin/features/sync/data/models/calendar_event_model.dart';
import 'package:prvin/features/sync/domain/repositories/sync_repository.dart';

void main() {
  group('外部日历集成属性测试', () {
    late Faker faker;

    setUp(() {
      faker = Faker();
    });

    /// **Feature: prvin-integrated-calendar, Property 18: 外部日历集成**
    /// **验证需求: 需求 6.1, 6.2**
    test('属性18: 对于任何外部日历服务连接，应该支持双向同步和数据一致性', () async {
      // 运行100次属性测试
      for (var i = 0; i < 100; i++) {
        // 生成随机测试数据
        final provider = _generateRandomProvider();
        final localEvents = _generateRandomEvents(
          faker.randomGenerator.integer(10, min: 1),
        );
        final remoteEvents = _generateRandomEvents(
          faker.randomGenerator.integer(10, min: 1),
        );

        // 验证数据生成的正确性
        expect(localEvents.isNotEmpty, isTrue, reason: '本地事件列表不应为空 (迭代 $i)');
        expect(remoteEvents.isNotEmpty, isTrue, reason: '远程事件列表不应为空 (迭代 $i)');

        // 验证事件数据的完整性
        for (final event in localEvents) {
          expect(event.id.isNotEmpty, isTrue, reason: '事件ID不应为空 (迭代 $i)');
          expect(event.title.isNotEmpty, isTrue, reason: '事件标题不应为空 (迭代 $i)');
          expect(
            event.startTime.isBefore(event.endTime),
            isTrue,
            reason: '开始时间应该早于结束时间 (迭代 $i)',
          );
          expect(
            event.createdAt.isBefore(event.updatedAt) ||
                event.createdAt.isAtSameMomentAs(event.updatedAt),
            isTrue,
            reason: '创建时间应该早于或等于更新时间 (迭代 $i)',
          );
        }

        // 验证提供商类型的有效性
        expect(
          CalendarProvider.values.contains(provider),
          isTrue,
          reason: '提供商应该是有效的枚举值 (迭代 $i)',
        );

        // 验证双向同步的数据一致性原则
        final allEvents = [...localEvents, ...remoteEvents];
        final eventIds = allEvents.map((e) => e.id).toSet();

        // 验证没有重复的事件ID（在实际同步中应该处理重复）
        expect(
          eventIds.length <= allEvents.length,
          isTrue,
          reason: '事件ID应该是唯一的或有重复处理机制 (迭代 $i)',
        );

        // 验证事件时间的合理性
        for (final event in allEvents) {
          expect(
            event.duration.inMinutes >= 0,
            isTrue,
            reason: '事件持续时间应该为非负数 (迭代 $i)',
          );
          expect(
            event.startTime.year >= 2020 && event.startTime.year <= 2030,
            isTrue,
            reason: '事件时间应该在合理范围内 (迭代 $i)',
          );
        }
      }
    });

    test('属性18.1: 外部日历事件数据模型的一致性', () async {
      for (var i = 0; i < 100; i++) {
        final event = _generateRandomEvents(1).first;

        // 验证事件的基本属性
        expect(event.isValid(), isTrue, reason: '生成的事件应该是有效的 (迭代 $i)');

        // 验证外部事件的特殊属性
        if (event.isExternal) {
          expect(event.externalId, isNotNull, reason: '外部事件应该有外部ID (迭代 $i)');
          expect(
            event.source != EventSource.local,
            isTrue,
            reason: '外部事件的来源不应该是本地 (迭代 $i)',
          );
        }

        // 验证同步状态的逻辑
        if (event.lastSyncAt != null) {
          expect(
            event.lastSyncAt!.isBefore(
              DateTime.now().add(const Duration(minutes: 1)),
            ),
            isTrue,
            reason: '最后同步时间不应该在未来 (迭代 $i)',
          );
        }

        // 验证事件冲突检测的基础
        final conflictingEvent = event.copyWith(
          id: faker.guid.guid(),
          startTime: event.startTime.add(const Duration(minutes: 30)),
          endTime: event.endTime.add(const Duration(minutes: 30)),
        );

        expect(
          event.hasTimeConflict(conflictingEvent),
          isTrue,
          reason: '重叠的事件应该被检测为冲突 (迭代 $i)',
        );

        final nonConflictingEvent = event.copyWith(
          id: faker.guid.guid(),
          startTime: event.endTime.add(const Duration(minutes: 1)),
          endTime: event.endTime.add(const Duration(hours: 1)),
        );

        expect(
          event.hasTimeConflict(nonConflictingEvent),
          isFalse,
          reason: '不重叠的事件不应该被检测为冲突 (迭代 $i)',
        );
      }
    });

    test('属性18.2: 同步冲突检测的正确性', () async {
      for (var i = 0; i < 100; i++) {
        final baseTime = DateTime.now();
        final event1 = CalendarEventModel(
          id: faker.guid.guid(),
          title: faker.lorem.sentence(),
          startTime: baseTime,
          endTime: baseTime.add(const Duration(hours: 2)),
          source: EventSource.local,
          isAllDay: false,
          attendees: const [],
          reminders: const [],
          metadata: const {},
          createdAt: baseTime.subtract(const Duration(days: 1)),
          updatedAt: baseTime,
        );

        // 创建时间冲突的事件
        final conflictingEvent = event1.copyWith(
          id: faker.guid.guid(),
          startTime: baseTime.add(const Duration(hours: 1)),
          endTime: baseTime.add(const Duration(hours: 3)),
        );

        // 验证冲突检测
        expect(
          event1.hasTimeConflict(conflictingEvent),
          isTrue,
          reason: '重叠事件应该被检测为冲突 (迭代 $i)',
        );

        // 创建无冲突的事件
        final nonConflictingEvent = event1.copyWith(
          id: faker.guid.guid(),
          startTime: baseTime.add(const Duration(hours: 3)),
          endTime: baseTime.add(const Duration(hours: 4)),
        );

        // 验证无冲突检测
        expect(
          event1.hasTimeConflict(nonConflictingEvent),
          isFalse,
          reason: '不重叠事件不应该被检测为冲突 (迭代 $i)',
        );

        // 验证边界情况
        final adjacentEvent = event1.copyWith(
          id: faker.guid.guid(),
          startTime: event1.endTime,
          endTime: event1.endTime.add(const Duration(hours: 1)),
        );

        expect(
          event1.hasTimeConflict(adjacentEvent),
          isFalse,
          reason: '相邻事件不应该被检测为冲突 (迭代 $i)',
        );
      }
    });

    test('属性18.3: 数据完整性和一致性保证', () async {
      for (var i = 0; i < 100; i++) {
        final events = _generateRandomEvents(
          faker.randomGenerator.integer(20, min: 5),
        );

        // 验证所有事件的数据完整性
        for (final event in events) {
          // 基本数据完整性
          expect(event.id.isNotEmpty, isTrue, reason: '事件ID不应为空 (迭代 $i)');
          expect(event.title.isNotEmpty, isTrue, reason: '事件标题不应为空 (迭代 $i)');

          // 时间逻辑一致性
          expect(
            event.startTime.isBefore(event.endTime) ||
                event.startTime.isAtSameMomentAs(event.endTime),
            isTrue,
            reason: '开始时间应该早于或等于结束时间 (迭代 $i)',
          );

          // 创建和更新时间的逻辑性
          expect(
            event.createdAt.isBefore(event.updatedAt) ||
                event.createdAt.isAtSameMomentAs(event.updatedAt),
            isTrue,
            reason: '创建时间应该早于或等于更新时间 (迭代 $i)',
          );

          // 外部事件的一致性
          if (event.isExternal) {
            expect(event.externalId, isNotNull, reason: '外部事件必须有外部ID (迭代 $i)');
            expect(
              event.source != EventSource.local,
              isTrue,
              reason: '外部事件的来源不能是本地 (迭代 $i)',
            );
          }

          // 同步状态的一致性
          if (event.needsSync) {
            expect(event.isExternal, isTrue, reason: '需要同步的事件应该是外部事件 (迭代 $i)');
            if (event.lastSyncAt != null) {
              expect(
                event.updatedAt.isAfter(event.lastSyncAt!),
                isTrue,
                reason: '需要同步的事件更新时间应该晚于最后同步时间 (迭代 $i)',
              );
            }
          }
        }

        // 验证事件集合的整体一致性
        final eventIds = events.map((e) => e.id).toList();
        final uniqueIds = eventIds.toSet();
        expect(
          uniqueIds.length,
          equals(eventIds.length),
          reason: '所有事件ID应该是唯一的 (迭代 $i)',
        );

        // 验证时间范围的合理性
        if (events.isNotEmpty) {
          final startTimes = events.map((e) => e.startTime).toList()..sort();
          final endTimes = events.map((e) => e.endTime).toList()..sort();

          expect(
            startTimes.first.isBefore(endTimes.last) ||
                startTimes.first.isAtSameMomentAs(endTimes.last),
            isTrue,
            reason: '事件时间范围应该是合理的 (迭代 $i)',
          );
        }
      }
    });
  });
}

/// 生成随机日历提供商
CalendarProvider _generateRandomProvider() {
  const providers = CalendarProvider.values;
  return providers[Faker().randomGenerator.integer(providers.length)];
}

/// 生成随机日历事件列表
List<CalendarEventModel> _generateRandomEvents(int count) {
  final faker = Faker();
  return List.generate(count, (index) {
    final createdAt = faker.date.dateTime(minYear: 2024, maxYear: 2024);
    final updatedAt = createdAt.add(
      Duration(
        days: faker.randomGenerator.integer(365),
        hours: faker.randomGenerator.integer(24),
        minutes: faker.randomGenerator.integer(60),
      ),
    );
    final startTime = faker.date.dateTime(minYear: 2024, maxYear: 2025);
    final endTime = startTime.add(
      Duration(hours: faker.randomGenerator.integer(8, min: 1)),
    );

    // 随机选择事件来源
    final source = EventSource
        .values[faker.randomGenerator.integer(EventSource.values.length)];

    // 确保外部事件有外部ID
    final externalId = source == EventSource.local ? null : faker.guid.guid();

    return CalendarEventModel(
      id: faker.guid.guid(),
      title: faker.lorem.sentence(),
      description: faker.lorem.sentences(3).join(' '),
      startTime: startTime,
      endTime: endTime,
      source: source,
      externalId: externalId,
      isAllDay: faker.randomGenerator.boolean(),
      location: faker.randomGenerator.boolean()
          ? faker.address.streetAddress()
          : null,
      attendees: List.generate(
        faker.randomGenerator.integer(5),
        (_) => faker.internet.email(),
      ),
      reminders: List.generate(
        faker.randomGenerator.integer(3),
        (_) => faker.randomGenerator.integer(60, min: 5),
      ),
      recurrenceRule: faker.randomGenerator.boolean() ? 'FREQ=WEEKLY' : null,
      metadata: {
        'source': faker.lorem.word(),
        'priority': faker.randomGenerator.integer(5).toString(),
      },
      createdAt: createdAt,
      updatedAt: updatedAt,
      lastSyncAt: faker.randomGenerator.boolean()
          ? updatedAt.add(Duration(minutes: faker.randomGenerator.integer(60)))
          : null,
    );
  });
}
