import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'package:prvin/features/task_management/domain/entities/task.dart';

/// 数据库助手类
class DatabaseHelper {

  DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  /// 获取数据库实例
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  /// 初始化数据库
  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'prvin_calendar.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// 创建数据库表
  Future<void> _onCreate(Database db, int version) async {
    // 创建任务表
    await db.execute('''
      CREATE TABLE tasks (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        start_time INTEGER NOT NULL,
        end_time INTEGER NOT NULL,
        tags TEXT,
        priority TEXT NOT NULL,
        status TEXT NOT NULL,
        category TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // 创建番茄钟会话表
    await db.execute('''
      CREATE TABLE pomodoro_sessions (
        id TEXT PRIMARY KEY,
        start_time INTEGER NOT NULL,
        end_time INTEGER,
        planned_duration INTEGER NOT NULL,
        actual_duration INTEGER,
        session_type TEXT NOT NULL,
        associated_task_id TEXT,
        completed INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (associated_task_id) REFERENCES tasks (id)
      )
    ''');

    // 创建日历事件表
    await db.execute('''
      CREATE TABLE calendar_events (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        start_time INTEGER NOT NULL,
        end_time INTEGER NOT NULL,
        event_source TEXT NOT NULL,
        external_id TEXT,
        metadata TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // 创建分析数据表
    await db.execute('''
      CREATE TABLE analytics_data (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        period_start INTEGER NOT NULL,
        period_end INTEGER NOT NULL,
        time_distribution TEXT,
        completion_rate REAL,
        trends TEXT,
        focus_patterns TEXT,
        created_at INTEGER NOT NULL
      )
    ''');

    // 创建索引以提高查询性能
    await db.execute('CREATE INDEX idx_tasks_start_time ON tasks (start_time)');
    await db.execute('CREATE INDEX idx_tasks_status ON tasks (status)');
    await db.execute('CREATE INDEX idx_tasks_category ON tasks (category)');
    await db.execute(
      'CREATE INDEX idx_pomodoro_sessions_start_time ON pomodoro_sessions (start_time)',
    );
    await db.execute(
      'CREATE INDEX idx_calendar_events_start_time ON calendar_events (start_time)',
    );
  }

  /// 数据库升级
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // 处理数据库版本升级
    if (oldVersion < 2) {
      // 示例：添加新列
      // await db.execute('ALTER TABLE tasks ADD COLUMN new_column TEXT');
    }
  }

  /// 任务相关操作

  /// 插入任务
  Future<int> insertTask(Task task) async {
    final db = await database;
    final taskMap = task.toMap();
    taskMap['tags'] = task.tags.join(','); // 将标签列表转换为字符串

    return db.insert('tasks', taskMap);
  }

  /// 更新任务
  Future<int> updateTask(Task task) async {
    final db = await database;
    final taskMap = task.toMap();
    taskMap['tags'] = task.tags.join(','); // 将标签列表转换为字符串

    return db.update(
      'tasks',
      taskMap,
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  /// 删除任务
  Future<int> deleteTask(String taskId) async {
    final db = await database;
    return db.delete('tasks', where: 'id = ?', whereArgs: [taskId]);
  }

  /// 获取所有任务
  Future<List<Task>> getAllTasks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('tasks');

    return List.generate(maps.length, (i) {
      final map = Map<String, dynamic>.from(maps[i]);
      // 将标签字符串转换回列表
      final tagsString = map['tags'] as String?;
      map['tags'] = tagsString?.isNotEmpty ?? false
          ? tagsString!.split(',')
          : <String>[];
      return Task.fromMap(map);
    });
  }

  /// 根据日期获取任务
  Future<List<Task>> getTasksForDate(DateTime date) async {
    final db = await database;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'start_time >= ? AND start_time < ?',
      whereArgs: [
        startOfDay.millisecondsSinceEpoch,
        endOfDay.millisecondsSinceEpoch,
      ],
      orderBy: 'start_time ASC',
    );

    return List.generate(maps.length, (i) {
      final map = Map<String, dynamic>.from(maps[i]);
      // 将标签字符串转换回列表
      final tagsString = map['tags'] as String?;
      map['tags'] = tagsString?.isNotEmpty ?? false
          ? tagsString!.split(',')
          : <String>[];
      return Task.fromMap(map);
    });
  }

  /// 根据日期范围获取任务
  Future<List<Task>> getTasksInRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'start_time >= ? AND start_time <= ?',
      whereArgs: [
        startDate.millisecondsSinceEpoch,
        endDate.millisecondsSinceEpoch,
      ],
      orderBy: 'start_time ASC',
    );

    return List.generate(maps.length, (i) {
      final map = Map<String, dynamic>.from(maps[i]);
      // 将标签字符串转换回列表
      final tagsString = map['tags'] as String?;
      map['tags'] = tagsString?.isNotEmpty ?? false
          ? tagsString!.split(',')
          : <String>[];
      return Task.fromMap(map);
    });
  }

  /// 搜索任务
  Future<List<Task>> searchTasks(String query) async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'title LIKE ? OR description LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'start_time DESC',
    );

    return List.generate(maps.length, (i) {
      final map = Map<String, dynamic>.from(maps[i]);
      // 将标签字符串转换回列表
      final tagsString = map['tags'] as String?;
      map['tags'] = tagsString?.isNotEmpty ?? false
          ? tagsString!.split(',')
          : <String>[];
      return Task.fromMap(map);
    });
  }

  /// 根据分类获取任务
  Future<List<Task>> getTasksByCategory(TaskCategory category) async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'category = ?',
      whereArgs: [category.name],
      orderBy: 'start_time DESC',
    );

    return List.generate(maps.length, (i) {
      final map = Map<String, dynamic>.from(maps[i]);
      // 将标签字符串转换回列表
      final tagsString = map['tags'] as String?;
      map['tags'] = tagsString?.isNotEmpty ?? false
          ? tagsString!.split(',')
          : <String>[];
      return Task.fromMap(map);
    });
  }

  /// 根据状态获取任务
  Future<List<Task>> getTasksByStatus(TaskStatus status) async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'status = ?',
      whereArgs: [status.name],
      orderBy: 'start_time DESC',
    );

    return List.generate(maps.length, (i) {
      final map = Map<String, dynamic>.from(maps[i]);
      // 将标签字符串转换回列表
      final tagsString = map['tags'] as String?;
      map['tags'] = tagsString?.isNotEmpty ?? false
          ? tagsString!.split(',')
          : <String>[];
      return Task.fromMap(map);
    });
  }

  /// 检查时间冲突
  Future<List<Task>> getConflictingTasks(
    DateTime startTime,
    DateTime endTime, {
    String? excludeTaskId,
  }) async {
    final db = await database;

    var whereClause = '''
      (start_time < ? AND end_time > ?) OR
      (start_time >= ? AND start_time < ?) OR
      (end_time > ? AND end_time <= ?)
    ''';

    var whereArgs = <dynamic>[
      endTime.millisecondsSinceEpoch,
      startTime.millisecondsSinceEpoch,
      startTime.millisecondsSinceEpoch,
      endTime.millisecondsSinceEpoch,
      startTime.millisecondsSinceEpoch,
      endTime.millisecondsSinceEpoch,
    ];

    if (excludeTaskId != null) {
      whereClause += ' AND id != ?';
      whereArgs.add(excludeTaskId);
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: whereClause,
      whereArgs: whereArgs,
    );

    return List.generate(maps.length, (i) {
      final map = Map<String, dynamic>.from(maps[i]);
      // 将标签字符串转换回列表
      final tagsString = map['tags'] as String?;
      map['tags'] = tagsString?.isNotEmpty ?? false
          ? tagsString!.split(',')
          : <String>[];
      return Task.fromMap(map);
    });
  }

  /// 获取任务统计信息
  Future<Map<String, dynamic>> getTaskStatistics() async {
    final db = await database;

    // 总任务数
    final totalTasks =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM tasks'),
        ) ??
        0;

    // 已完成任务数
    final completedTasks =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM tasks WHERE status = ?', [
            'completed',
          ]),
        ) ??
        0;

    // 进行中任务数
    final inProgressTasks =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM tasks WHERE status = ?', [
            'inProgress',
          ]),
        ) ??
        0;

    // 待办任务数
    final pendingTasks =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM tasks WHERE status = ?', [
            'pending',
          ]),
        ) ??
        0;

    // 按分类统计
    final categoryStats = await db.rawQuery('''
      SELECT category, COUNT(*) as count 
      FROM tasks 
      GROUP BY category
    ''');

    return {
      'totalTasks': totalTasks,
      'completedTasks': completedTasks,
      'inProgressTasks': inProgressTasks,
      'pendingTasks': pendingTasks,
      'completionRate': totalTasks > 0 ? completedTasks / totalTasks : 0.0,
      'categoryStats': categoryStats,
    };
  }

  /// 清理数据库
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('tasks');
    await db.delete('pomodoro_sessions');
    await db.delete('calendar_events');
    await db.delete('analytics_data');
  }

  /// 关闭数据库
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
