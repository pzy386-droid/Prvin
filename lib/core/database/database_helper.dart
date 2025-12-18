import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../constants/app_constants.dart';

/// 数据库帮助类，管理SQLite数据库的创建、升级和连接
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  /// 获取数据库实例
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  /// 初始化数据库
  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, AppConstants.databaseName);

    return await openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: _onConfigure,
    );
  }

  /// 配置数据库（启用外键约束）
  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  /// 创建数据库表
  Future<void> _onCreate(Database db, int version) async {
    await _createTasksTable(db);
    await _createPomodoroSessionsTable(db);
    await _createCalendarEventsTable(db);
    await _createAnalyticsDataTable(db);
    await _createIndexes(db);
  }

  /// 升级数据库
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // 数据迁移逻辑将在后续版本中实现
    if (oldVersion < newVersion) {
      // 示例：添加新列或表
      // await db.execute('ALTER TABLE tasks ADD COLUMN new_column TEXT');
    }
  }

  /// 创建任务表
  Future<void> _createTasksTable(Database db) async {
    await db.execute('''
      CREATE TABLE tasks (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        start_time INTEGER NOT NULL,
        end_time INTEGER NOT NULL,
        tags TEXT NOT NULL, -- JSON数组
        priority TEXT NOT NULL,
        status TEXT NOT NULL,
        category TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');
  }

  /// 创建番茄钟会话表
  Future<void> _createPomodoroSessionsTable(Database db) async {
    await db.execute('''
      CREATE TABLE pomodoro_sessions (
        id TEXT PRIMARY KEY,
        start_time INTEGER NOT NULL,
        end_time INTEGER,
        planned_duration INTEGER NOT NULL,
        actual_duration INTEGER NOT NULL,
        type TEXT NOT NULL,
        associated_task_id TEXT,
        completed INTEGER NOT NULL,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (associated_task_id) REFERENCES tasks (id) ON DELETE SET NULL
      )
    ''');
  }

  /// 创建日历事件表
  Future<void> _createCalendarEventsTable(Database db) async {
    await db.execute('''
      CREATE TABLE calendar_events (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        start_time INTEGER NOT NULL,
        end_time INTEGER NOT NULL,
        source TEXT NOT NULL,
        external_id TEXT,
        is_all_day INTEGER NOT NULL,
        location TEXT,
        attendees TEXT NOT NULL, -- JSON数组
        reminders TEXT NOT NULL, -- JSON数组
        recurrence_rule TEXT,
        metadata TEXT NOT NULL, -- JSON对象
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        last_sync_at INTEGER
      )
    ''');
  }

  /// 创建分析数据表
  Future<void> _createAnalyticsDataTable(Database db) async {
    await db.execute('''
      CREATE TABLE analytics_data (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        period_start INTEGER NOT NULL,
        period_end INTEGER NOT NULL,
        time_distribution TEXT NOT NULL, -- JSON对象
        completion_rate REAL NOT NULL,
        trends TEXT NOT NULL, -- JSON数组
        focus_patterns TEXT NOT NULL, -- JSON数组
        task_patterns TEXT NOT NULL, -- JSON数组
        focus_recommendations TEXT NOT NULL, -- JSON数组
        generated_at INTEGER NOT NULL
      )
    ''');
  }

  /// 创建索引以优化查询性能
  Future<void> _createIndexes(Database db) async {
    // 任务表索引
    await db.execute('CREATE INDEX idx_tasks_start_time ON tasks (start_time)');
    await db.execute('CREATE INDEX idx_tasks_status ON tasks (status)');
    await db.execute('CREATE INDEX idx_tasks_category ON tasks (category)');
    await db.execute('CREATE INDEX idx_tasks_created_at ON tasks (created_at)');

    // 番茄钟会话表索引
    await db.execute(
      'CREATE INDEX idx_sessions_start_time ON pomodoro_sessions (start_time)',
    );
    await db.execute(
      'CREATE INDEX idx_sessions_type ON pomodoro_sessions (type)',
    );
    await db.execute(
      'CREATE INDEX idx_sessions_task_id ON pomodoro_sessions (associated_task_id)',
    );

    // 日历事件表索引
    await db.execute(
      'CREATE INDEX idx_events_start_time ON calendar_events (start_time)',
    );
    await db.execute(
      'CREATE INDEX idx_events_source ON calendar_events (source)',
    );
    await db.execute(
      'CREATE INDEX idx_events_external_id ON calendar_events (external_id)',
    );

    // 分析数据表索引
    await db.execute(
      'CREATE INDEX idx_analytics_user_id ON analytics_data (user_id)',
    );
    await db.execute(
      'CREATE INDEX idx_analytics_period ON analytics_data (period_start, period_end)',
    );
  }

  /// 关闭数据库连接
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }

  /// 清空所有数据（用于测试）
  Future<void> clearAllData() async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('tasks');
      await txn.delete('pomodoro_sessions');
      await txn.delete('calendar_events');
      await txn.delete('analytics_data');
    });
  }

  /// 获取数据库信息
  Future<Map<String, dynamic>> getDatabaseInfo() async {
    final db = await database;
    final version = await db.getVersion();
    final path = db.path;

    // 获取表信息
    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'",
    );

    return {
      'version': version,
      'path': path,
      'tables': tables.map((table) => table['name']).toList(),
    };
  }
}
