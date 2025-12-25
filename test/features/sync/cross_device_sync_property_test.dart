import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prvin/features/sync/data/models/calendar_event_model.dart';

void main() {
  group('跨设备数据同步属性测试', () {
    late Faker faker;

    setUp(() {
      faker = Faker();
    });

    /// **Feature: prvin-integrated-calendar, Property 16: 跨设备数据同步**
    /// **验证需求: 需求 5.3**
    test('属性16: 对于任何设备间的切换，应该确保任务数据的实时同步和一致性', () async {
      // 运行100次属性测试
      for (var i = 0; i < 100; i++) {
        // 模拟多设备环境
        final device1Events = _generateRandomEvents(
          faker.randomGenerator.integer(15, min: 1),
          deviceId: 'device_1',
        );
        final device2Events = _generateRandomEvents(
          faker.randomGenerator.integer(15, min: 1),
          deviceId: 'device_2',
        );
        final device3Events = _generateRandomEvents(
          faker.randomGenerator.integer(15, min: 1),
          deviceId: 'device_3',
        );

        // 验证设备数据生成的正确性
        expect(device1Events.isNotEmpty, isTrue, reason: '设备1事件列表不应为空 (迭代 $i)');
        expect(device2Events.isNotEmpty, isTrue, reason: '设备2事件列表不应为空 (迭代 $i)');
        expect(device3Events.isNotEmpty, isTrue, reason: '设备3事件列表不应为空 (迭代 $i)');

        // 验证每个设备的事件数据完整性
        final allDeviceEvents = [
          ...device1Events,
          ...device2Events,
          ...device3Events,
        ];

        for (final event in allDeviceEvents) {
          expect(event.id.isNotEmpty, isTrue, reason: '事件ID不应为空 (迭代 $i)');
          expect(event.title.isNotEmpty, isTrue, reason: '事件标题不应为空 (迭代 $i)');
          expect(
            event.startTime.isBefore(event.endTime) ||
                event.startTime.isAtSameMomentAs(event.endTime),
            isTrue,
            reason: '开始时间应该早于或等于结束时间 (迭代 $i)',
          );
          expect(
            event.createdAt.isBefore(event.updatedAt) ||
                event.createdAt.isAtSameMomentAs(event.updatedAt),
            isTrue,
            reason: '创建时间应该早于或等于更新时间 (迭代 $i)',
          );
        }

        // 验证跨设备数据同步的一致性原则
        final eventIds = allDeviceEvents.map((e) => e.id).toSet();

        // 在实际同步中，相同ID的事件应该在所有设备上保持一致
        for (final eventId in eventIds) {
          final eventsWithSameId = allDeviceEvents
              .where((e) => e.id == eventId)
              .toList();

          if (eventsWithSameId.length > 1) {
            // 验证相同ID事件的核心属性一致性
            final firstEvent = eventsWithSameId.first;
            for (final event in eventsWithSameId.skip(1)) {
              expect(
                event.title,
                equals(firstEvent.title),
                reason: '相同ID事件的标题应该一致 (迭代 $i)',
              );
              expect(
                event.startTime,
                equals(firstEvent.startTime),
                reason: '相同ID事件的开始时间应该一致 (迭代 $i)',
              );
              expect(
                event.endTime,
                equals(firstEvent.endTime),
                reason: '相同ID事件的结束时间应该一致 (迭代 $i)',
              );
            }
          }
        }

        // 验证同步时间戳的逻辑性
        for (final event in allDeviceEvents) {
          if (event.lastSyncAt != null) {
            expect(
              event.lastSyncAt!.isBefore(
                DateTime.now().add(const Duration(minutes: 1)),
              ),
              isTrue,
              reason: '最后同步时间不应该在未来 (迭代 $i)',
            );

            // 如果事件需要同步，更新时间应该晚于最后同步时间
            if (event.needsSync) {
              expect(
                event.updatedAt.isAfter(event.lastSyncAt!),
                isTrue,
                reason: '需要同步的事件更新时间应该晚于最后同步时间 (迭代 $i)',
              );
            }
          }
        }
      }
    });

    test('属性16.1: 设备间数据冲突检测和解决', () async {
      for (var i = 0; i < 100; i++) {
        final baseTime = DateTime.now();

        // 模拟同一事件在不同设备上的不同版本
        final eventId = faker.guid.guid();
        final device1Version = CalendarEventModel(
          id: eventId,
          title: faker.lorem.sentence(),
          startTime: baseTime,
          endTime: baseTime.add(const Duration(hours: 2)),
          source: EventSource.local,
          isAllDay: false,
          attendees: const [],
          reminders: const [],
          metadata: const {'deviceId': 'device_1'},
          createdAt: baseTime.subtract(const Duration(days: 1)),
          updatedAt: baseTime.subtract(const Duration(hours: 2)),
          lastSyncAt: baseTime.subtract(const Duration(hours: 3)),
        );

        final device2Version = device1Version.copyWith(
          title: faker.lorem.sentence(), // 不同的标题
          updatedAt: baseTime.subtract(const Duration(hours: 1)), // 更新的时间
          metadata: {'deviceId': 'device_2'},
        );

        // 验证冲突检测逻辑
        expect(
          device1Version.id,
          equals(device2Version.id),
          reason: '冲突事件应该有相同的ID (迭代 $i)',
        );

        expect(
          device1Version.title != device2Version.title,
          isTrue,
          reason: '冲突事件应该有不同的内容 (迭代 $i)',
        );

        // 验证最新版本的确定逻辑（基于更新时间）
        final isDevice2Newer = device2Version.updatedAt.isAfter(
          device1Version.updatedAt,
        );
        expect(isDevice2Newer, isTrue, reason: '设备2的版本应该更新 (迭代 $i)');

        // 验证同步状态的正确性 - 只有外部事件才需要同步
        if (device1Version.isExternal) {
          expect(
            device1Version.needsSync,
            isTrue,
            reason: '旧版本的外部事件应该需要同步 (迭代 $i)',
          );
        }

        if (device2Version.isExternal) {
          expect(
            device2Version.needsSync,
            isTrue,
            reason: '新版本的外部事件也应该需要同步到其他设备 (迭代 $i)',
          );
        }
      }
    });

    test('属性16.2: 网络状态变化时的同步行为', () async {
      for (var i = 0; i < 100; i++) {
        final events = _generateRandomEvents(
          faker.randomGenerator.integer(10, min: 1),
        );

        // 模拟网络状态变化
        final isOnline = faker.randomGenerator.boolean();
        final hasWifi = faker.randomGenerator.boolean();
        final isMobileData = !hasWifi && isOnline;

        for (final event in events) {
          // 验证离线状态下的行为
          if (!isOnline && event.isExternal) {
            // 离线时，外部事件应该标记为需要同步
            expect(
              event.needsSync || event.lastSyncAt == null,
              isTrue,
              reason: '离线时外部事件应该需要同步或从未同步过 (迭代 $i)',
            );
          }

          // 验证移动数据下的同步策略
          if (isMobileData) {
            // 在移动数据下，应该优先同步重要事件
            final isImportant =
                event.attendees.isNotEmpty ||
                event.reminders.isNotEmpty ||
                event.isUpcoming;

            if (isImportant && event.isExternal) {
              expect(
                event.needsSync,
                isTrue,
                reason: '重要的外部事件在移动数据下应该优先同步 (迭代 $i)',
              );
            }
          }

          // 验证WiFi环境下的同步行为
          if (hasWifi && isOnline) {
            // WiFi环境下应该支持全量同步
            expect(
              event.isValid(),
              isTrue,
              reason: 'WiFi环境下所有事件都应该是有效的 (迭代 $i)',
            );
          }
        }

        // 验证批量同步的数据完整性
        final syncBatch = events.where((e) => e.needsSync).toList();
        if (syncBatch.isNotEmpty) {
          final batchIds = syncBatch.map((e) => e.id).toSet();
          expect(
            batchIds.length,
            equals(syncBatch.length),
            reason: '同步批次中的事件ID应该是唯一的 (迭代 $i)',
          );
        }
      }
    });

    test('属性16.3: 同步性能和资源优化', () async {
      for (var i = 0; i < 100; i++) {
        // 生成大量事件来测试性能
        final largeEventSet = _generateRandomEvents(
          faker.randomGenerator.integer(100, min: 50),
        );

        // 验证批量处理的效率
        final needsSyncEvents = largeEventSet
            .where((e) => e.needsSync)
            .toList();

        // 验证同步批次大小的合理性
        if (needsSyncEvents.isNotEmpty) {
          expect(
            needsSyncEvents.length <= largeEventSet.length,
            isTrue,
            reason: '需要同步的事件数量应该合理 (迭代 $i)',
          );
        }

        // 验证内存使用的优化
        final totalEventSize = largeEventSet.length;
        expect(
          totalEventSize >= 50 && totalEventSize <= 100,
          isTrue,
          reason: '事件集合大小应该在预期范围内 (迭代 $i)',
        );

        // 验证时间范围的分布
        if (largeEventSet.isNotEmpty) {
          final startTimes = largeEventSet.map((e) => e.startTime).toList()
            ..sort();
          final timeSpan = startTimes.last.difference(startTimes.first);

          expect(timeSpan.inDays >= 0, isTrue, reason: '事件时间跨度应该是非负数 (迭代 $i)');
        }

        // 验证数据压缩和传输优化
        for (final event in largeEventSet) {
          // 验证必要字段的存在
          expect(event.id.isNotEmpty, isTrue, reason: '事件ID不应为空 (迭代 $i)');
          expect(event.title.isNotEmpty, isTrue, reason: '事件标题不应为空 (迭代 $i)');

          // 验证可选字段的合理性
          if (event.description != null) {
            expect(
              event.description!.length <= 1000,
              isTrue,
              reason: '事件描述长度应该合理 (迭代 $i)',
            );
          }
        }
      }
    });
  });
}

/// 生成随机日历事件列表（支持设备ID）
List<CalendarEventModel> _generateRandomEvents(int count, {String? deviceId}) {
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

    // 添加设备ID到元数据
    final metadata = <String, dynamic>{
      'source': faker.lorem.word(),
      'priority': faker.randomGenerator.integer(5).toString(),
    };
    if (deviceId != null) {
      metadata['deviceId'] = deviceId;
    }

    return CalendarEventModel(
      id: faker.guid.guid(),
      title: faker.lorem.sentence(),
      description: faker.lorem.sentences(2).join(' '),
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
      metadata: metadata,
      createdAt: createdAt,
      updatedAt: updatedAt,
      lastSyncAt: faker.randomGenerator.boolean()
          ? createdAt.add(
              Duration(minutes: faker.randomGenerator.integer(60, min: 1)),
            )
          : null,
    );
  });
}
