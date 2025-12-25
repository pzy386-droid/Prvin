import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart' as path;
import 'dart:io';

/// **Feature: prvin-integrated-calendar, Task 6.3: 数据迁移和兼容性测试**
/// **验证需求: 需求 11.4**
///
/// 基于现有的数据库架构测试迁移，验证向后兼容性
void main() {
  group('Data Migration and Compatibility Tests', () {
    late Database database;
    late String testDbPath;

    setUpAll(() {
      // 初始化 FFI
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    });

    setUp(() async {
      // 创建临时测试数据库
      testDbPath = path.join(
        Directory.systemTemp.path,
        'test_migration_${DateTime.now().millisecondsSinceEpoch}.db',
      );
    });

    tearDown(() async {
      // 确保数据库连接已关闭
      try {
        if (database.isOpen) {
          await database.close();
        }
      } catch (e) {
        // 忽略关闭错误
      }

      // 清理测试数据库
      try {
        if (await File(testDbPath).exists()) {
          await File(testDbPath).delete();
        }
      } catch (e) {
        // 忽略删除错误，可能文件正在被使用
      }
    });

    /// **Feature: prvin-integrated-calendar, Task 6.3: 数据迁移和兼容性测试**
    /// **验证需求: 需求 11.4**
    test(
      'should migrate from version 1 to current version successfully',
      () async {
        // 创建版本1的数据库结构
        database = await openDatabase(
          testDbPath,
          version: 1,
          onCreate: (db, version) async {
            // 模拟旧版本的数据库结构
            await db.execute('''
            CREATE TABLE tasks_v1 (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              title TEXT NOT NULL,
              description TEXT,
              start_time TEXT NOT NULL,
              end_time TEXT NOT NULL,
              created_at TEXT NOT NULL
            )
          ''');

            // 插入一些测试数据
            await db.insert('tasks_v1', {
              'title': 'Test Task 1',
              'description': 'Test Description',
              'start_time': '2024-01-01 10:00:00',
              'end_time': '2024-01-01 11:00:00',
              'created_at': '2024-01-01 09:00:00',
            });
          },
        );

        await database.close();

        // 执行迁移到当前版本
        database = await openDatabase(
          testDbPath,
          version: 3, // 假设当前版本是3
          onUpgrade: (db, oldVersion, newVersion) async {
            await _performMigration(db, oldVersion, newVersion);
          },
        );

        // 验证迁移后的数据结构
        final tables = await database.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table'",
        );

        final tableNames = tables
            .map((table) => table['name'] as String)
            .toList();

        // 验证新表结构存在
        expect(tableNames, contains('tasks'));
        expect(tableNames, contains('task_categories'));
        expect(tableNames, contains('pomodoro_sessions'));

        // 验证数据迁移成功
        final migratedTasks = await database.query('tasks');
        expect(migratedTasks.length, equals(1));
        expect(migratedTasks.first['title'], equals('Test Task 1'));
        expect(migratedTasks.first['priority'], isNotNull); // 新字段应该有默认值
        expect(migratedTasks.first['status'], isNotNull); // 新字段应该有默认值
      },
    );

    /// **Feature: prvin-integrated-calendar, Task 6.3: 数据迁移和兼容性测试**
    /// **验证需求: 需求 11.4**
    test('should handle incremental migrations correctly', () async {
      // 测试从版本1到版本2，再到版本3的增量迁移

      // 创建版本1数据库
      database = await openDatabase(
        testDbPath,
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE tasks_v1 (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              title TEXT NOT NULL,
              start_time TEXT NOT NULL,
              end_time TEXT NOT NULL
            )
          ''');
        },
      );
      await database.close();

      // 迁移到版本2
      database = await openDatabase(
        testDbPath,
        version: 2,
        onUpgrade: (db, oldVersion, newVersion) async {
          if (oldVersion < 2) {
            // 添加新字段
            await db.execute(
              'ALTER TABLE tasks_v1 ADD COLUMN priority INTEGER DEFAULT 1',
            );
            await db.execute(
              'ALTER TABLE tasks_v1 ADD COLUMN tags TEXT DEFAULT ""',
            );
          }
        },
      );
      await database.close();

      // 迁移到版本3
      database = await openDatabase(
        testDbPath,
        version: 3,
        onUpgrade: (db, oldVersion, newVersion) async {
          if (oldVersion < 3) {
            // 重命名表并添加更多字段
            await db.execute('ALTER TABLE tasks_v1 RENAME TO tasks');
            await db.execute(
              'ALTER TABLE tasks ADD COLUMN status INTEGER DEFAULT 0',
            );
            await db.execute(
              'ALTER TABLE tasks ADD COLUMN category_id INTEGER',
            );

            // 创建新的关联表
            await db.execute('''
              CREATE TABLE task_categories (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL,
                color TEXT NOT NULL,
                created_at TEXT NOT NULL
              )
            ''');
          }
        },
      );

      // 验证最终结构
      final columns = await database.rawQuery('PRAGMA table_info(tasks)');
      final columnNames = columns.map((col) => col['name'] as String).toList();

      expect(columnNames, contains('priority'));
      expect(columnNames, contains('tags'));
      expect(columnNames, contains('status'));
      expect(columnNames, contains('category_id'));

      // 验证关联表存在
      final tables = await database.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table'",
      );
      final tableNames = tables
          .map((table) => table['name'] as String)
          .toList();
      expect(tableNames, contains('task_categories'));
    });

    /// **Feature: prvin-integrated-calendar, Task 6.3: 数据迁移和兼容性测试**
    /// **验证需求: 需求 11.4**
    test('should preserve data integrity during migration', () async {
      // 创建包含复杂数据的旧版本数据库
      database = await openDatabase(
        testDbPath,
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE tasks_v1 (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              title TEXT NOT NULL,
              description TEXT,
              start_time TEXT NOT NULL,
              end_time TEXT NOT NULL,
              created_at TEXT NOT NULL
            )
          ''');

          // 插入多条测试数据
          final testData = [
            {
              'title': 'Meeting with Team',
              'description': 'Weekly standup meeting',
              'start_time': '2024-01-01 10:00:00',
              'end_time': '2024-01-01 11:00:00',
              'created_at': '2024-01-01 09:00:00',
            },
            {
              'title': 'Code Review',
              'description': 'Review PR #123',
              'start_time': '2024-01-01 14:00:00',
              'end_time': '2024-01-01 15:00:00',
              'created_at': '2024-01-01 13:00:00',
            },
            {
              'title': 'Documentation Update',
              'description': null, // 测试NULL值处理
              'start_time': '2024-01-02 09:00:00',
              'end_time': '2024-01-02 10:00:00',
              'created_at': '2024-01-02 08:00:00',
            },
          ];

          for (final data in testData) {
            await db.insert('tasks_v1', data);
          }
        },
      );

      // 获取迁移前的数据
      final originalTasks = await database.query('tasks_v1');
      await database.close();

      // 执行迁移
      database = await openDatabase(
        testDbPath,
        version: 2,
        onUpgrade: (db, oldVersion, newVersion) async {
          await _performMigration(db, oldVersion, newVersion);
        },
      );

      // 验证数据完整性
      final migratedTasks = await database.query('tasks');

      expect(migratedTasks.length, equals(originalTasks.length));

      for (int i = 0; i < originalTasks.length; i++) {
        final original = originalTasks[i];
        final migrated = migratedTasks[i];

        expect(migrated['title'], equals(original['title']));
        expect(migrated['description'], equals(original['description']));
        expect(migrated['start_time'], equals(original['start_time']));
        expect(migrated['end_time'], equals(original['end_time']));
        expect(migrated['created_at'], equals(original['created_at']));

        // 验证新字段有默认值
        expect(migrated['priority'], isNotNull);
        expect(migrated['status'], isNotNull);
      }
    });

    /// **Feature: prvin-integrated-calendar, Task 6.3: 数据迁移和兼容性测试**
    /// **验证需求: 需求 11.4**
    test('should handle migration errors gracefully', () async {
      // 创建一个会导致迁移错误的场景
      database = await openDatabase(
        testDbPath,
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE tasks_v1 (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              title TEXT NOT NULL
            )
          ''');
        },
      );
      await database.close();

      // 尝试执行有问题的迁移
      try {
        database = await openDatabase(
          testDbPath,
          version: 2,
          onUpgrade: (db, oldVersion, newVersion) async {
            // 故意执行一个会失败的SQL语句
            await db.execute(
              'ALTER TABLE non_existent_table ADD COLUMN test TEXT',
            );
          },
        );

        // 如果没有抛出异常，测试失败
        fail('Expected migration to throw an exception');
      } catch (e) {
        // 验证异常被正确处理
        expect(e, isA<DatabaseException>());
      }

      // 验证数据库仍然可以以原始版本打开
      database = await openDatabase(testDbPath, version: 1);
      final tables = await database.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table'",
      );
      expect(tables.isNotEmpty, isTrue);
    });

    /// **Feature: prvin-integrated-calendar, Task 6.3: 数据迁移和兼容性测试**
    /// **验证需求: 需求 11.4**
    test('should support rollback on migration failure', () async {
      // 创建初始数据库
      database = await openDatabase(
        testDbPath,
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE tasks_v1 (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              title TEXT NOT NULL
            )
          ''');

          await db.insert('tasks_v1', {'title': 'Test Task'});
        },
      );

      // 验证初始数据存在
      final initialData = await database.query('tasks_v1');
      expect(initialData.length, equals(1));
      await database.close();

      // 创建数据库备份（模拟回滚机制）
      final backupPath = '$testDbPath.backup';
      await File(testDbPath).copy(backupPath);

      // 尝试执行失败的迁移
      try {
        database = await openDatabase(
          testDbPath,
          version: 2,
          onUpgrade: (db, oldVersion, newVersion) async {
            // 开始事务
            await db.transaction((txn) async {
              await txn.execute(
                'ALTER TABLE tasks_v1 ADD COLUMN new_field TEXT',
              );
              // 故意抛出异常模拟迁移失败
              throw Exception('Migration failed');
            });
          },
        );
        fail('Expected migration to fail');
      } catch (e) {
        // 迁移失败，执行回滚
        await File(backupPath).copy(testDbPath);
      }

      // 验证回滚后数据完整性
      database = await openDatabase(testDbPath, version: 1);
      final restoredData = await database.query('tasks_v1');
      expect(restoredData.length, equals(1));
      expect(restoredData.first['title'], equals('Test Task'));

      // 清理备份文件
      if (await File(backupPath).exists()) {
        await File(backupPath).delete();
      }
    });
  });
}

/// 模拟数据库迁移逻辑
Future<void> _performMigration(
  Database db,
  int oldVersion,
  int newVersion,
) async {
  if (oldVersion < 2) {
    // 从版本1迁移到版本2
    await db.execute('ALTER TABLE tasks_v1 RENAME TO tasks');
    await db.execute('ALTER TABLE tasks ADD COLUMN priority INTEGER DEFAULT 1');
    await db.execute('ALTER TABLE tasks ADD COLUMN status INTEGER DEFAULT 0');
    await db.execute('ALTER TABLE tasks ADD COLUMN tags TEXT DEFAULT ""');
    await db.execute('ALTER TABLE tasks ADD COLUMN category_id INTEGER');
    await db.execute('ALTER TABLE tasks ADD COLUMN updated_at TEXT');

    // 创建新表
    await db.execute('''
      CREATE TABLE task_categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        color TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE pomodoro_sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        task_id INTEGER,
        start_time TEXT NOT NULL,
        end_time TEXT,
        duration INTEGER NOT NULL,
        completed INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        FOREIGN KEY (task_id) REFERENCES tasks (id)
      )
    ''');
  }

  if (oldVersion < 3) {
    // 从版本2迁移到版本3
    await db.execute('ALTER TABLE tasks ADD COLUMN external_id TEXT');
    await db.execute(
      'ALTER TABLE tasks ADD COLUMN sync_status INTEGER DEFAULT 0',
    );

    // 创建同步相关表
    await db.execute('''
      CREATE TABLE sync_conflicts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        task_id INTEGER NOT NULL,
        conflict_type TEXT NOT NULL,
        local_data TEXT NOT NULL,
        remote_data TEXT NOT NULL,
        resolved INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        FOREIGN KEY (task_id) REFERENCES tasks (id)
      )
    ''');
  }
}
