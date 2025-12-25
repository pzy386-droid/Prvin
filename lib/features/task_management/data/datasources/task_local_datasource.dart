import 'dart:convert';

import 'package:prvin/core/database/database_helper.dart';
import 'package:prvin/core/error/failures.dart';
import 'package:prvin/features/task_management/data/models/task_model.dart';
import 'package:prvin/features/task_management/domain/entities/task.dart'
    as entities;
import 'package:sqflite/sqflite.dart';

/// 任务本地数据源接口
abstract class TaskLocalDataSource {
  Future<List<TaskModel>> getAllTasks();
  Future<List<TaskModel>> getTasksForDate(DateTime date);
  Future<List<TaskModel>> getTasksByStatus(entities.TaskStatus status);
  Future<List<TaskModel>> getTasksByCategory(entities.TaskCategory category);
  Future<TaskModel?> getTaskById(String id);
  Future<String> createTask(TaskModel task);
  Future<void> updateTask(TaskModel task);
  Future<void> deleteTask(String id);
  Future<List<TaskModel>> searchTasks(String query);
  Future<void> clearAllTasks();
}

/// 任务本地数据源实现
class TaskLocalDataSourceImpl implements TaskLocalDataSource {
  TaskLocalDataSourceImpl(this._databaseHelper);
  final DatabaseHelper _databaseHelper;

  @override
  Future<List<TaskModel>> getAllTasks() async {
    try {
      final db = await _databaseHelper.database;
      final maps = await db.query('tasks', orderBy: 'created_at DESC');
      return maps.map(_mapToTaskModel).toList();
    } catch (e) {
      throw DatabaseFailure('获取所有任务失败: $e');
    }
  }

  @override
  Future<List<TaskModel>> getTasksForDate(DateTime date) async {
    try {
      final db = await _databaseHelper.database;
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final maps = await db.query(
        'tasks',
        where: 'start_time >= ? AND start_time < ?',
        whereArgs: [
          startOfDay.millisecondsSinceEpoch,
          endOfDay.millisecondsSinceEpoch,
        ],
        orderBy: 'start_time ASC',
      );

      return maps.map(_mapToTaskModel).toList();
    } catch (e) {
      throw DatabaseFailure('获取指定日期任务失败: $e');
    }
  }

  @override
  Future<List<TaskModel>> getTasksByStatus(entities.TaskStatus status) async {
    try {
      final db = await _databaseHelper.database;
      final maps = await db.query(
        'tasks',
        where: 'status = ?',
        whereArgs: [status.name],
        orderBy: 'created_at DESC',
      );
      return maps.map(_mapToTaskModel).toList();
    } catch (e) {
      throw DatabaseFailure('按状态获取任务失败: $e');
    }
  }

  @override
  Future<List<TaskModel>> getTasksByCategory(
    entities.TaskCategory category,
  ) async {
    try {
      final db = await _databaseHelper.database;
      final maps = await db.query(
        'tasks',
        where: 'category = ?',
        whereArgs: [category.name],
        orderBy: 'created_at DESC',
      );
      return maps.map(_mapToTaskModel).toList();
    } catch (e) {
      throw DatabaseFailure('按分类获取任务失败: $e');
    }
  }

  @override
  Future<TaskModel?> getTaskById(String id) async {
    try {
      final db = await _databaseHelper.database;
      final maps = await db.query(
        'tasks',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (maps.isEmpty) return null;
      return _mapToTaskModel(maps.first);
    } catch (e) {
      throw DatabaseFailure('根据ID获取任务失败: $e');
    }
  }

  @override
  Future<String> createTask(TaskModel task) async {
    try {
      final db = await _databaseHelper.database;
      await db.insert(
        'tasks',
        _taskModelToMap(task),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return task.id;
    } catch (e) {
      throw DatabaseFailure('创建任务失败: $e');
    }
  }

  @override
  Future<void> updateTask(TaskModel task) async {
    try {
      final db = await _databaseHelper.database;
      final updatedTask = task.copyWith(updatedAt: DateTime.now());

      final count = await db.update(
        'tasks',
        _taskModelToMap(updatedTask),
        where: 'id = ?',
        whereArgs: [task.id],
      );

      if (count == 0) {
        throw const DatabaseFailure('任务不存在，无法更新');
      }
    } catch (e) {
      throw DatabaseFailure('更新任务失败: $e');
    }
  }

  @override
  Future<void> deleteTask(String id) async {
    try {
      final db = await _databaseHelper.database;
      final count = await db.delete('tasks', where: 'id = ?', whereArgs: [id]);

      if (count == 0) {
        throw const DatabaseFailure('任务不存在，无法删除');
      }
    } catch (e) {
      throw DatabaseFailure('删除任务失败: $e');
    }
  }

  @override
  Future<List<TaskModel>> searchTasks(String query) async {
    try {
      final db = await _databaseHelper.database;
      final maps = await db.query(
        'tasks',
        where: 'title LIKE ? OR description LIKE ?',
        whereArgs: ['%$query%', '%$query%'],
        orderBy: 'created_at DESC',
      );
      return maps.map(_mapToTaskModel).toList();
    } catch (e) {
      throw DatabaseFailure('搜索任务失败: $e');
    }
  }

  @override
  Future<void> clearAllTasks() async {
    try {
      final db = await _databaseHelper.database;
      await db.delete('tasks');
    } catch (e) {
      throw DatabaseFailure('清空所有任务失败: $e');
    }
  }

  /// 将数据库映射转换为TaskModel
  TaskModel _mapToTaskModel(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      startTime: DateTime.fromMillisecondsSinceEpoch(map['start_time'] as int),
      endTime: DateTime.fromMillisecondsSinceEpoch(map['end_time'] as int),
      tags: List<String>.from(jsonDecode(map['tags'] as String) as List),
      priority: TaskPriority.values.firstWhere(
        (e) => e.name == map['priority'],
        orElse: () => TaskPriority.medium,
      ),
      status: TaskStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => TaskStatus.pending,
      ),
      category: TaskCategory.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => TaskCategory.personal,
      ),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }

  /// 将TaskModel转换为数据库映射
  Map<String, dynamic> _taskModelToMap(TaskModel task) {
    return {
      'id': task.id,
      'title': task.title,
      'description': task.description,
      'start_time': task.startTime.millisecondsSinceEpoch,
      'end_time': task.endTime.millisecondsSinceEpoch,
      'tags': jsonEncode(task.tags),
      'priority': task.priority.name,
      'status': task.status.name,
      'category': task.category.name,
      'created_at': task.createdAt.millisecondsSinceEpoch,
      'updated_at': task.updatedAt.millisecondsSinceEpoch,
    };
  }
}
