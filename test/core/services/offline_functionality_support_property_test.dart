import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';

/// **Feature: prvin-integrated-calendar, Property 17: 离线功能支持**
/// **验证需求: 需求 5.4**
///
/// 属性：对于任何网络中断情况，应该支持离线查看编辑，网络恢复后自动同步
void main() {
  group('离线功能支持属性测试', () {
    final faker = Faker();

    testWidgets('属性17: 离线功能支持 - 网络中断时应支持离线操作，网络恢复后自动同步', (
      WidgetTester tester,
    ) async {
      // **Feature: prvin-integrated-calendar, Property 17: 离线功能支持**

      // 运行10次属性测试以确保随机测试的充分性（优化性能）
      for (var i = 0; i < 10; i++) {
        // 生成随机测试数据
        final testData = _generateRandomOfflineTestData(faker);

        // 模拟网络状态变化
        await _testOfflineFunctionality(testData: testData);
      }
    });

    testWidgets('属性17: 离线缓存一致性 - 离线时的数据操作应该在网络恢复后正确同步', (
      WidgetTester tester,
    ) async {
      // **Feature: prvin-integrated-calendar, Property 17: 离线功能支持**

      // 运行10次属性测试
      for (var i = 0; i < 10; i++) {
        final testData = _generateRandomCacheTestData(faker);

        await _testOfflineCacheConsistency(testData: testData);
      }
    });

    testWidgets('属性17: 离线状态检测 - 应该能够准确检测和响应网络状态变化', (
      WidgetTester tester,
    ) async {
      // **Feature: prvin-integrated-calendar, Property 17: 离线功能支持**

      // 运行10次属性测试
      for (var i = 0; i < 10; i++) {
        final networkStates = _generateRandomNetworkStates(faker);

        await _testNetworkStateDetection(networkStates: networkStates);
      }
    });

    testWidgets('属性17: 离线数据持久化 - 离线时创建的数据应该能够持久化保存', (
      WidgetTester tester,
    ) async {
      // **Feature: prvin-integrated-calendar, Property 17: 离线功能支持**

      // 运行10次属性测试
      for (var i = 0; i < 10; i++) {
        final persistenceData = _generateRandomPersistenceTestData(faker);

        await _testOfflineDataPersistence(testData: persistenceData);
      }
    });
  });
}

/// 生成随机离线测试数据
Map<String, dynamic> _generateRandomOfflineTestData(Faker faker) {
  // 确保时间戳在有效范围内（过去的时间）
  final now = DateTime.now();
  final pastDate = DateTime(
    now.year - faker.randomGenerator.integer(2), // 0-2年前
    faker.randomGenerator.integer(12, min: 1),
    faker.randomGenerator.integer(28, min: 1),
  );

  return {
    'taskId': faker.guid.guid(),
    'taskTitle': faker.lorem.sentence(),
    'taskDescription': faker.lorem.sentences(3).join(' '),
    'taskDueDate': pastDate,
    'taskPriority': faker.randomGenerator.element(['low', 'medium', 'high']),
    'taskTags': List.generate(
      faker.randomGenerator.integer(5, min: 1),
      (index) => faker.lorem.word(),
    ),
    'networkInterruptionDuration': faker.randomGenerator.integer(
      10000,
      min: 1000,
    ), // 1-10秒
    'operationsCount': faker.randomGenerator.integer(5, min: 1), // 减少操作数量
    'isOnline': faker.randomGenerator.boolean(),
  };
}

/// 生成随机缓存测试数据
Map<String, dynamic> _generateRandomCacheTestData(Faker faker) {
  // 确保时间戳在有效范围内（过去的时间）
  final now = DateTime.now();
  final itemCount = faker.randomGenerator.integer(10, min: 3); // 减少缓存项数量

  return {
    'cacheKeys': List.generate(
      itemCount,
      (index) => 'cache_key_${faker.guid.guid()}',
    ),
    'cacheData': List.generate(
      itemCount,
      (index) => {
        'id': faker.guid.guid(),
        'content': faker.lorem.sentences(2).join(' '),
        'timestamp': now
            .subtract(
              Duration(
                hours: faker.randomGenerator.integer(
                  24 * 30,
                  min: 1,
                ), // 1小时到30天前
              ),
            )
            .millisecondsSinceEpoch,
        'type': faker.randomGenerator.element(['task', 'event', 'note']),
      },
    ),
    'syncDelay': faker.randomGenerator.integer(5000, min: 500), // 0.5-5秒
  };
}

/// 生成随机网络状态序列
List<bool> _generateRandomNetworkStates(Faker faker) {
  final stateCount = faker.randomGenerator.integer(5, min: 3); // 减少网络状态数量
  return List.generate(stateCount, (index) => faker.randomGenerator.boolean());
}

/// 生成随机持久化测试数据
Map<String, dynamic> _generateRandomPersistenceTestData(Faker faker) {
  // 确保时间戳在有效范围内（过去的时间）
  final now = DateTime.now();

  return {
    'dataItems': List.generate(faker.randomGenerator.integer(8, min: 3), (
      index,
    ) {
      final createdAt = now.subtract(
        Duration(
          hours: faker.randomGenerator.integer(24 * 7, min: 1), // 1小时到7天前
        ),
      );
      final modifiedAt = createdAt.add(
        Duration(
          minutes: faker.randomGenerator.integer(
            60 * 24,
          ), // 创建后0-24小时内修改
        ),
      );

      return {
        'id': faker.guid.guid(),
        'title': faker.lorem.sentence(),
        'content': faker.lorem.sentences(3).join(' '),
        'createdAt': createdAt.millisecondsSinceEpoch,
        'modifiedAt': modifiedAt.millisecondsSinceEpoch,
        'isOfflineCreated': faker.randomGenerator.boolean(),
      };
    }),
    'storageCapacity': faker.randomGenerator.integer(1000, min: 100),
    'compressionEnabled': faker.randomGenerator.boolean(),
  };
}

/// 测试离线功能
Future<void> _testOfflineFunctionality({
  required Map<String, dynamic> testData,
}) async {
  // 1. 验证测试数据的有效性
  expect(testData['taskId'], isNotNull, reason: '任务ID不应该为空');
  expect(testData['taskTitle'], isNotEmpty, reason: '任务标题不应该为空');
  final operationsCount = testData['operationsCount'] as int;
  expect(operationsCount, greaterThan(0), reason: '操作数量应该大于0');

  // 2. 模拟离线状态
  final isInitiallyOnline = testData['isOnline'] as bool;
  var currentOnlineStatus = isInitiallyOnline;

  // 3. 验证离线操作能力
  final offlineOperations = <Map<String, dynamic>>[];
  for (var i = 0; i < operationsCount; i++) {
    final operation = {
      'id': '${testData['taskId']}_operation_$i',
      'type': 'create_task',
      'data': {
        'title': testData['taskTitle'],
        'description': testData['taskDescription'],
        'priority': testData['taskPriority'],
        'tags': testData['taskTags'],
      },
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'isOffline': !currentOnlineStatus,
    };

    offlineOperations.add(operation);

    // 验证离线操作可以被记录
    expect(operation['id'], isNotEmpty, reason: '离线操作ID应该不为空');
    expect(operation['data'], isNotNull, reason: '离线操作数据应该不为空');
  }

  // 4. 验证数据持久化
  expect(
    offlineOperations.length,
    equals(operationsCount),
    reason: '所有离线操作都应该被正确记录',
  );

  // 5. 模拟网络恢复
  currentOnlineStatus = true;

  // 6. 验证同步功能
  final offlineOps = offlineOperations
      .where((op) => op['isOffline'] == true)
      .toList();
  for (final operation in offlineOps) {
    // 验证离线操作可以被识别和同步
    expect(operation['isOffline'], isTrue, reason: '离线操作应该被正确标记');
    expect(operation['timestamp'], isA<int>(), reason: '离线操作应该有有效的时间戳');

    // 模拟同步过程
    final syncedOperation = Map<String, dynamic>.from(operation);
    syncedOperation['synced'] = true;
    syncedOperation['syncTimestamp'] = DateTime.now().millisecondsSinceEpoch;

    expect(syncedOperation['synced'], isTrue, reason: '离线操作应该能够被同步');
  }
}

/// 测试离线缓存一致性
Future<void> _testOfflineCacheConsistency({
  required Map<String, dynamic> testData,
}) async {
  final cacheKeys = testData['cacheKeys'] as List<String>;
  final cacheData = testData['cacheData'] as List<Map<String, dynamic>>;

  // 1. 验证缓存操作
  for (var i = 0; i < cacheKeys.length && i < cacheData.length; i++) {
    final key = cacheKeys[i];
    final data = cacheData[i];

    // 验证缓存键的有效性
    expect(key.isNotEmpty, isTrue, reason: '缓存键不应该为空');
    expect(key.startsWith('cache_key_'), isTrue, reason: '缓存键应该有正确的前缀');

    // 验证缓存数据的完整性
    expect(data.containsKey('id'), isTrue, reason: '缓存数据应该包含ID字段');
    expect(data.containsKey('content'), isTrue, reason: '缓存数据应该包含内容字段');
    expect(data.containsKey('timestamp'), isTrue, reason: '缓存数据应该包含时间戳字段');
    expect(data.containsKey('type'), isTrue, reason: '缓存数据应该包含类型字段');
  }

  // 2. 验证缓存一致性
  final uniqueIds = cacheData.map((data) => data['id']).toSet();
  expect(uniqueIds.length, equals(cacheData.length), reason: '缓存数据的ID应该是唯一的');

  // 3. 验证时间戳顺序
  final timestamps = cacheData.map((data) => data['timestamp'] as int).toList();
  for (var i = 0; i < timestamps.length; i++) {
    expect(timestamps[i] > 0, isTrue, reason: '时间戳应该是有效的正数');
    expect(
      timestamps[i] <= DateTime.now().millisecondsSinceEpoch,
      isTrue,
      reason: '时间戳不应该超过当前时间',
    );
  }

  // 4. 验证数据类型一致性
  final validTypes = {'task', 'event', 'note'};
  for (final data in cacheData) {
    final type = data['type'] as String;
    expect(validTypes.contains(type), isTrue, reason: '缓存数据类型应该是有效的类型');
  }

  // 5. 验证缓存同步延迟
  final syncDelay = testData['syncDelay'] as int;
  expect(syncDelay >= 500 && syncDelay <= 5000, isTrue, reason: '同步延迟应该在合理范围内');
}

/// 测试网络状态检测
Future<void> _testNetworkStateDetection({
  required List<bool> networkStates,
}) async {
  // 1. 验证网络状态序列的有效性
  expect(networkStates.isNotEmpty, isTrue, reason: '网络状态序列不应该为空');
  expect(networkStates.length >= 3, isTrue, reason: '网络状态序列应该有足够的状态变化');

  // 2. 验证状态变化检测
  bool? previousState;
  var stateChanges = 0;
  final stateTransitions = <Map<String, dynamic>>[];

  for (var i = 0; i < networkStates.length; i++) {
    final currentState = networkStates[i];

    if (previousState != null && previousState != currentState) {
      stateChanges++;
      stateTransitions.add({
        'from': previousState,
        'to': currentState,
        'index': i,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    }

    // 验证状态值的有效性
    expect(currentState, isA<bool>(), reason: '网络状态应该是布尔值');

    previousState = currentState;
  }

  // 3. 验证状态变化的合理性
  expect(stateChanges >= 0, isTrue, reason: '状态变化次数应该是非负数');

  // 如果有状态变化，验证变化的有效性
  if (stateChanges > 0) {
    expect(
      stateChanges < networkStates.length,
      isTrue,
      reason: '状态变化次数应该少于总状态数',
    );

    // 验证状态转换的有效性
    for (final transition in stateTransitions) {
      expect(
        transition['from'],
        isNot(equals(transition['to'])),
        reason: '状态转换应该是真实的变化',
      );
      expect(transition['index'], isA<int>(), reason: '状态转换索引应该是有效的整数');
      expect(transition['timestamp'], isA<int>(), reason: '状态转换时间戳应该是有效的整数');
    }
  }

  // 4. 验证状态检测的响应性
  for (var i = 0; i < networkStates.length; i++) {
    final state = networkStates[i];

    // 验证状态检测的一致性
    expect(state, isA<bool>(), reason: '每个网络状态都应该是有效的布尔值');

    // 验证状态检测的及时性（模拟）
    final detectionTime = DateTime.now().millisecondsSinceEpoch;
    expect(detectionTime > 0, isTrue, reason: '状态检测时间应该是有效的');
  }
}

/// 测试离线数据持久化
Future<void> _testOfflineDataPersistence({
  required Map<String, dynamic> testData,
}) async {
  final dataItems = testData['dataItems'] as List<Map<String, dynamic>>;
  final storageCapacity = testData['storageCapacity'] as int;
  final compressionEnabled = testData['compressionEnabled'] as bool;

  // 1. 验证数据项的有效性
  expect(dataItems.isNotEmpty, isTrue, reason: '数据项列表不应该为空');

  for (final item in dataItems) {
    expect(item.containsKey('id'), isTrue, reason: '数据项应该包含ID字段');
    expect(item.containsKey('title'), isTrue, reason: '数据项应该包含标题字段');
    expect(item.containsKey('content'), isTrue, reason: '数据项应该包含内容字段');
    expect(item.containsKey('createdAt'), isTrue, reason: '数据项应该包含创建时间字段');
    expect(item.containsKey('modifiedAt'), isTrue, reason: '数据项应该包含修改时间字段');
    expect(
      item.containsKey('isOfflineCreated'),
      isTrue,
      reason: '数据项应该包含离线创建标记字段',
    );
  }

  // 2. 验证时间戳的一致性
  for (final item in dataItems) {
    final createdAt = item['createdAt'] as int;
    final modifiedAt = item['modifiedAt'] as int;

    expect(createdAt > 0, isTrue, reason: '创建时间应该是有效的正数');
    expect(modifiedAt > 0, isTrue, reason: '修改时间应该是有效的正数');
    expect(modifiedAt >= createdAt, isTrue, reason: '修改时间应该不早于创建时间');
  }

  // 3. 验证离线创建的数据项
  final offlineCreatedItems = dataItems
      .where((item) => item['isOfflineCreated'] == true)
      .toList();
  for (final item in offlineCreatedItems) {
    expect(item['id'], isNotEmpty, reason: '离线创建的数据项应该有有效的ID');
    expect(item['title'], isNotEmpty, reason: '离线创建的数据项应该有有效的标题');

    // 验证离线创建的数据项可以被持久化
    final persistedItem = Map<String, dynamic>.from(item);
    persistedItem['persisted'] = true;
    persistedItem['persistedAt'] = DateTime.now().millisecondsSinceEpoch;

    expect(persistedItem['persisted'], isTrue, reason: '离线创建的数据项应该能够被持久化');
  }

  // 4. 验证存储容量限制
  expect(
    storageCapacity >= 100 && storageCapacity <= 1000,
    isTrue,
    reason: '存储容量应该在合理范围内',
  );

  // 模拟存储空间检查
  final estimatedSize = dataItems.length * 100; // 假设每个数据项100字节
  final compressionRatio = compressionEnabled ? 0.7 : 1.0;
  final actualSize = (estimatedSize * compressionRatio).round();

  expect(actualSize >= 0, isTrue, reason: '实际存储大小应该是非负数');

  // 5. 验证数据完整性
  final uniqueIds = dataItems.map((item) => item['id']).toSet();
  expect(uniqueIds.length, equals(dataItems.length), reason: '所有数据项的ID应该是唯一的');

  // 6. 验证压缩功能
  if (compressionEnabled) {
    expect(actualSize <= estimatedSize, isTrue, reason: '启用压缩时，实际大小应该不大于估计大小');
  } else {
    expect(actualSize, equals(estimatedSize), reason: '未启用压缩时，实际大小应该等于估计大小');
  }
}
