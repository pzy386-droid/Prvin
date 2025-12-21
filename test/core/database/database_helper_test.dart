import 'package:flutter_test/flutter_test.dart';
import 'package:prvin/core/database/database_helper.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  group('DatabaseHelper', () {
    late DatabaseHelper databaseHelper;

    setUpAll(() {
      // 初始化FFI
      sqfliteFfiInit();
      // 设置数据库工厂为FFI
      databaseFactory = databaseFactoryFfi;
    });

    setUp(() {
      databaseHelper = DatabaseHelper();
    });

    tearDown(() async {
      await databaseHelper.close();
    });

    test('should create database with correct tables', () async {
      final db = await databaseHelper.database;

      // 验证数据库版本
      final version = await db.getVersion();
      expect(version, equals(1));

      // 验证表是否存在
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'",
      );

      final tableNames = tables.map((table) => table['name']).toList();
      expect(tableNames, contains('tasks'));
      expect(tableNames, contains('pomodoro_sessions'));
      expect(tableNames, contains('calendar_events'));
      expect(tableNames, contains('analytics_data'));
    });

    test('should create indexes for performance optimization', () async {
      final db = await databaseHelper.database;

      // 验证索引是否存在
      final indexes = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='index' AND name NOT LIKE 'sqlite_%'",
      );

      final indexNames = indexes.map((index) => index['name']).toList();
      expect(indexNames, contains('idx_tasks_start_time'));
      expect(indexNames, contains('idx_tasks_status'));
      expect(indexNames, contains('idx_sessions_start_time'));
      expect(indexNames, contains('idx_events_start_time'));
    });

    test('should enable foreign key constraints', () async {
      final db = await databaseHelper.database;

      // 验证外键约束是否启用
      final result = await db.rawQuery('PRAGMA foreign_keys');
      expect(result.first['foreign_keys'], equals(1));
    });

    test('should clear all data successfully', () async {
      final db = await databaseHelper.database;

      // 插入一些测试数据
      await db.insert('tasks', {
        'id': 'test-task',
        'title': 'Test Task',
        'start_time': DateTime.now().millisecondsSinceEpoch,
        'end_time': DateTime.now()
            .add(const Duration(hours: 1))
            .millisecondsSinceEpoch,
        'tags': '[]',
        'priority': 'medium',
        'status': 'pending',
        'category': 'personal',
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      });

      // 验证数据存在
      var tasks = await db.query('tasks');
      expect(tasks.length, equals(1));

      // 清空所有数据
      await databaseHelper.clearAllData();

      // 验证数据已清空
      tasks = await db.query('tasks');
      expect(tasks.length, equals(0));
    });

    test('should get database info correctly', () async {
      final info = await databaseHelper.getDatabaseInfo();

      expect(info['version'], equals(1));
      expect(info['path'], isNotNull);
      expect(info['tables'], isA<List>());
      expect(info['tables'], contains('tasks'));
      expect(info['tables'], contains('pomodoro_sessions'));
      expect(info['tables'], contains('calendar_events'));
      expect(info['tables'], contains('analytics_data'));
    });
  });
}
