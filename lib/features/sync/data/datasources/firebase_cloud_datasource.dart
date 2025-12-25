import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:prvin/core/error/failures.dart';
import 'package:prvin/features/sync/data/models/calendar_event_model.dart';
import 'package:prvin/features/task_management/domain/entities/task.dart'
    as task_entity;

/// Firebase云端数据源接口
abstract class FirebaseCloudDataSource {
  /// 用户认证
  Future<bool> signInAnonymously();

  /// 检查认证状态
  Future<bool> isAuthenticated();

  /// 获取用户ID
  String? getCurrentUserId();

  /// 同步任务到云端
  Future<void> syncTasksToCloud(List<task_entity.Task> tasks);

  /// 从云端获取任务
  Future<List<task_entity.Task>> getTasksFromCloud();

  /// 同步日历事件到云端
  Future<void> syncEventsToCloud(List<CalendarEventModel> events);

  /// 从云端获取日历事件
  Future<List<CalendarEventModel>> getEventsFromCloud();

  /// 检测云端数据冲突
  Future<List<Map<String, dynamic>>> detectCloudConflicts();

  /// 解决云端冲突
  Future<void> resolveCloudConflict(
    String documentId,
    Map<String, dynamic> resolvedData,
  );

  /// 监听云端数据变化
  Stream<List<task_entity.Task>> watchTasksFromCloud();

  /// 监听云端事件变化
  Stream<List<CalendarEventModel>> watchEventsFromCloud();

  /// 删除云端任务
  Future<void> deleteTaskFromCloud(String taskId);

  /// 删除云端事件
  Future<void> deleteEventFromCloud(String eventId);

  /// 获取最后同步时间
  Future<DateTime?> getLastSyncTime();

  /// 更新最后同步时间
  Future<void> updateLastSyncTime(DateTime syncTime);

  /// 清空用户云端数据
  Future<void> clearUserCloudData();
}

/// Firebase云端数据源实现
class FirebaseCloudDataSourceImpl implements FirebaseCloudDataSource {
  FirebaseCloudDataSourceImpl({required this.firestore, required this.auth});

  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  // 集合名称
  static const String _tasksCollection = 'tasks';
  static const String _eventsCollection = 'calendar_events';
  static const String _syncMetadataCollection = 'sync_metadata';

  @override
  Future<bool> signInAnonymously() async {
    try {
      final userCredential = await auth.signInAnonymously();
      return userCredential.user != null;
    } catch (e) {
      throw NetworkFailure('Firebase匿名登录失败: $e');
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    return auth.currentUser != null;
  }

  @override
  String? getCurrentUserId() {
    return auth.currentUser?.uid;
  }

  @override
  Future<void> syncTasksToCloud(List<task_entity.Task> tasks) async {
    final userId = getCurrentUserId();
    if (userId == null) {
      throw const NetworkFailure('用户未认证，无法同步到云端');
    }

    try {
      final batch = firestore.batch();
      final userTasksRef = firestore
          .collection(_tasksCollection)
          .doc(userId)
          .collection('user_tasks');

      for (final task in tasks) {
        final taskRef = userTasksRef.doc(task.id);
        final taskData = _taskToFirestoreData(task);
        batch.set(taskRef, taskData, SetOptions(merge: true));
      }

      await batch.commit();
      await updateLastSyncTime(DateTime.now());
    } catch (e) {
      throw NetworkFailure('同步任务到云端失败: $e');
    }
  }

  @override
  Future<List<task_entity.Task>> getTasksFromCloud() async {
    final userId = getCurrentUserId();
    if (userId == null) {
      throw const NetworkFailure('用户未认证，无法从云端获取数据');
    }

    try {
      final snapshot = await firestore
          .collection(_tasksCollection)
          .doc(userId)
          .collection('user_tasks')
          .get();

      return snapshot.docs
          .map((doc) => _firestoreDataToTask(doc.data()))
          .toList();
    } catch (e) {
      throw NetworkFailure('从云端获取任务失败: $e');
    }
  }

  @override
  Future<void> syncEventsToCloud(List<CalendarEventModel> events) async {
    final userId = getCurrentUserId();
    if (userId == null) {
      throw const NetworkFailure('用户未认证，无法同步到云端');
    }

    try {
      final batch = firestore.batch();
      final userEventsRef = firestore
          .collection(_eventsCollection)
          .doc(userId)
          .collection('user_events');

      for (final event in events) {
        final eventRef = userEventsRef.doc(event.id);
        final eventData = _eventToFirestoreData(event);
        batch.set(eventRef, eventData, SetOptions(merge: true));
      }

      await batch.commit();
      await updateLastSyncTime(DateTime.now());
    } catch (e) {
      throw NetworkFailure('同步事件到云端失败: $e');
    }
  }

  @override
  Future<List<CalendarEventModel>> getEventsFromCloud() async {
    final userId = getCurrentUserId();
    if (userId == null) {
      throw const NetworkFailure('用户未认证，无法从云端获取数据');
    }

    try {
      final snapshot = await firestore
          .collection(_eventsCollection)
          .doc(userId)
          .collection('user_events')
          .get();

      return snapshot.docs
          .map((doc) => _firestoreDataToEvent(doc.data()))
          .toList();
    } catch (e) {
      throw NetworkFailure('从云端获取事件失败: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> detectCloudConflicts() async {
    final userId = getCurrentUserId();
    if (userId == null) return [];

    try {
      // 检查任务冲突
      final taskConflicts = await _detectTaskConflicts(userId);

      // 检查事件冲突
      final eventConflicts = await _detectEventConflicts(userId);

      return [...taskConflicts, ...eventConflicts];
    } catch (e) {
      throw NetworkFailure('检测云端冲突失败: $e');
    }
  }

  @override
  Future<void> resolveCloudConflict(
    String documentId,
    Map<String, dynamic> resolvedData,
  ) async {
    final userId = getCurrentUserId();
    if (userId == null) {
      throw const NetworkFailure('用户未认证，无法解决冲突');
    }

    try {
      // 根据数据类型确定集合
      final isTask = resolvedData.containsKey('startTime');
      final collection = isTask ? _tasksCollection : _eventsCollection;
      final subCollection = isTask ? 'user_tasks' : 'user_events';

      await firestore
          .collection(collection)
          .doc(userId)
          .collection(subCollection)
          .doc(documentId)
          .set(resolvedData, SetOptions(merge: true));
    } catch (e) {
      throw NetworkFailure('解决云端冲突失败: $e');
    }
  }

  @override
  Stream<List<task_entity.Task>> watchTasksFromCloud() {
    final userId = getCurrentUserId();
    if (userId == null) {
      return Stream.error(const NetworkFailure('用户未认证'));
    }

    return firestore
        .collection(_tasksCollection)
        .doc(userId)
        .collection('user_tasks')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => _firestoreDataToTask(doc.data()))
              .toList(),
        );
  }

  @override
  Stream<List<CalendarEventModel>> watchEventsFromCloud() {
    final userId = getCurrentUserId();
    if (userId == null) {
      return Stream.error(const NetworkFailure('用户未认证'));
    }

    return firestore
        .collection(_eventsCollection)
        .doc(userId)
        .collection('user_events')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => _firestoreDataToEvent(doc.data()))
              .toList(),
        );
  }

  @override
  Future<void> deleteTaskFromCloud(String taskId) async {
    final userId = getCurrentUserId();
    if (userId == null) {
      throw const NetworkFailure('用户未认证，无法删除云端数据');
    }

    try {
      await firestore
          .collection(_tasksCollection)
          .doc(userId)
          .collection('user_tasks')
          .doc(taskId)
          .delete();
    } catch (e) {
      throw NetworkFailure('删除云端任务失败: $e');
    }
  }

  @override
  Future<void> deleteEventFromCloud(String eventId) async {
    final userId = getCurrentUserId();
    if (userId == null) {
      throw const NetworkFailure('用户未认证，无法删除云端数据');
    }

    try {
      await firestore
          .collection(_eventsCollection)
          .doc(userId)
          .collection('user_events')
          .doc(eventId)
          .delete();
    } catch (e) {
      throw NetworkFailure('删除云端事件失败: $e');
    }
  }

  @override
  Future<DateTime?> getLastSyncTime() async {
    final userId = getCurrentUserId();
    if (userId == null) return null;

    try {
      final doc = await firestore
          .collection(_syncMetadataCollection)
          .doc(userId)
          .get();

      if (!doc.exists) return null;

      final timestamp = doc.data()?['lastSyncTime'] as Timestamp?;
      return timestamp?.toDate();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> updateLastSyncTime(DateTime syncTime) async {
    final userId = getCurrentUserId();
    if (userId == null) return;

    try {
      await firestore.collection(_syncMetadataCollection).doc(userId).set({
        'lastSyncTime': Timestamp.fromDate(syncTime),
        'userId': userId,
      }, SetOptions(merge: true));
    } catch (e) {
      // 忽略同步时间更新失败
    }
  }

  @override
  Future<void> clearUserCloudData() async {
    final userId = getCurrentUserId();
    if (userId == null) return;

    try {
      final batch = firestore.batch();

      // 删除用户任务
      final tasksSnapshot = await firestore
          .collection(_tasksCollection)
          .doc(userId)
          .collection('user_tasks')
          .get();

      for (final doc in tasksSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // 删除用户事件
      final eventsSnapshot = await firestore
          .collection(_eventsCollection)
          .doc(userId)
          .collection('user_events')
          .get();

      for (final doc in eventsSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // 删除同步元数据
      batch.delete(firestore.collection(_syncMetadataCollection).doc(userId));

      await batch.commit();
    } catch (e) {
      throw NetworkFailure('清空用户云端数据失败: $e');
    }
  }

  /// 检测任务冲突
  Future<List<Map<String, dynamic>>> _detectTaskConflicts(String userId) async {
    // TODO: 实现任务冲突检测逻辑
    // 比较本地和云端的任务，检测时间冲突、内容冲突等
    return [];
  }

  /// 检测事件冲突
  Future<List<Map<String, dynamic>>> _detectEventConflicts(
    String userId,
  ) async {
    // TODO: 实现事件冲突检测逻辑
    // 比较本地和云端的事件，检测时间冲突、内容冲突等
    return [];
  }

  /// 将任务转换为Firestore数据
  Map<String, dynamic> _taskToFirestoreData(Task task) {
    return {
      'id': task.id,
      'title': task.title,
      'description': task.description,
      'startTime': Timestamp.fromDate(task.startTime),
      'endTime': Timestamp.fromDate(task.endTime),
      'tags': task.tags,
      'priority': task.priority.name,
      'status': task.status.name,
      'category': task.category.name,
      'createdAt': Timestamp.fromDate(task.createdAt),
      'updatedAt': Timestamp.fromDate(task.updatedAt),
      'syncedAt': Timestamp.fromDate(DateTime.now()),
    };
  }

  /// 将Firestore数据转换为任务
  Task _firestoreDataToTask(Map<String, dynamic> data) {
    return Task(
      id: data['id'] as String,
      title: data['title'] as String,
      description: data['description'] as String?,
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: (data['endTime'] as Timestamp).toDate(),
      tags: List<String>.from(data['tags'] as List),
      priority: TaskPriority.values.firstWhere(
        (e) => e.name == data['priority'],
        orElse: () => TaskPriority.medium,
      ),
      status: TaskStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => TaskStatus.pending,
      ),
      category: TaskCategory.values.firstWhere(
        (e) => e.name == data['category'],
        orElse: () => TaskCategory.other,
      ),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  /// 将事件转换为Firestore数据
  Map<String, dynamic> _eventToFirestoreData(CalendarEventModel event) {
    return {
      'id': event.id,
      'title': event.title,
      'description': event.description,
      'startTime': Timestamp.fromDate(event.startTime),
      'endTime': Timestamp.fromDate(event.endTime),
      'source': event.source.name,
      'externalId': event.externalId,
      'isAllDay': event.isAllDay,
      'location': event.location,
      'attendees': event.attendees,
      'reminders': event.reminders,
      'recurrenceRule': event.recurrenceRule,
      'metadata': event.metadata,
      'createdAt': Timestamp.fromDate(event.createdAt),
      'updatedAt': Timestamp.fromDate(event.updatedAt),
      'lastSyncAt': event.lastSyncAt != null
          ? Timestamp.fromDate(event.lastSyncAt!)
          : null,
      'syncedAt': Timestamp.fromDate(DateTime.now()),
    };
  }

  /// 将Firestore数据转换为事件
  CalendarEventModel _firestoreDataToEvent(Map<String, dynamic> data) {
    return CalendarEventModel(
      id: data['id'] as String,
      title: data['title'] as String,
      description: data['description'] as String?,
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: (data['endTime'] as Timestamp).toDate(),
      source: EventSource.values.firstWhere(
        (e) => e.name == data['source'],
        orElse: () => EventSource.local,
      ),
      externalId: data['externalId'] as String?,
      isAllDay: data['isAllDay'] as bool,
      location: data['location'] as String?,
      attendees: List<String>.from(data['attendees'] as List),
      reminders: List<int>.from(data['reminders'] as List),
      recurrenceRule: data['recurrenceRule'] as String?,
      metadata: Map<String, dynamic>.from(data['metadata'] as Map),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      lastSyncAt: data['lastSyncAt'] != null
          ? (data['lastSyncAt'] as Timestamp).toDate()
          : null,
    );
  }
}
