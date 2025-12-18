import '../../../../core/cache/cache_manager.dart';
import '../models/task_model.dart';
import 'task_local_datasource.dart';

/// 带缓存的任务数据源装饰器
class CachedTaskDataSource implements TaskLocalDataSource {
  final TaskLocalDataSource _dataSource;
  final CacheManager<String, TaskModel> _taskCache;
  final CacheManager<String, List<TaskModel>> _listCache;

  CachedTaskDataSource(this._dataSource)
    : _taskCache = CacheManager<String, TaskModel>(
        maxSize: 200,
        ttl: const Duration(minutes: 15),
      ),
      _listCache = CacheManager<String, List<TaskModel>>(
        maxSize: 50,
        ttl: const Duration(minutes: 5),
      );

  @override
  Future<List<TaskModel>> getAllTasks() async {
    const cacheKey = 'all_tasks';

    // 尝试从缓存获取
    final cached = _listCache.get(cacheKey);
    if (cached != null) {
      return cached;
    }

    // 从数据源获取
    final tasks = await _dataSource.getAllTasks();

    // 缓存结果
    _listCache.put(cacheKey, tasks);

    // 同时缓存单个任务
    for (final task in tasks) {
      _taskCache.put(task.id, task);
    }

    return tasks;
  }

  @override
  Future<List<TaskModel>> getTasksForDate(DateTime date) async {
    final cacheKey = 'tasks_${date.toIso8601String().split('T')[0]}';

    // 尝试从缓存获取
    final cached = _listCache.get(cacheKey);
    if (cached != null) {
      return cached;
    }

    // 从数据源获取
    final tasks = await _dataSource.getTasksForDate(date);

    // 缓存结果
    _listCache.put(cacheKey, tasks);

    // 同时缓存单个任务
    for (final task in tasks) {
      _taskCache.put(task.id, task);
    }

    return tasks;
  }

  @override
  Future<List<TaskModel>> getTasksByStatus(TaskStatus status) async {
    final cacheKey = 'tasks_status_${status.name}';

    // 尝试从缓存获取
    final cached = _listCache.get(cacheKey);
    if (cached != null) {
      return cached;
    }

    // 从数据源获取
    final tasks = await _dataSource.getTasksByStatus(status);

    // 缓存结果
    _listCache.put(cacheKey, tasks);

    return tasks;
  }

  @override
  Future<List<TaskModel>> getTasksByCategory(TaskCategory category) async {
    final cacheKey = 'tasks_category_${category.name}';

    // 尝试从缓存获取
    final cached = _listCache.get(cacheKey);
    if (cached != null) {
      return cached;
    }

    // 从数据源获取
    final tasks = await _dataSource.getTasksByCategory(category);

    // 缓存结果
    _listCache.put(cacheKey, tasks);

    return tasks;
  }

  @override
  Future<TaskModel?> getTaskById(String id) async {
    // 尝试从缓存获取
    final cached = _taskCache.get(id);
    if (cached != null) {
      return cached;
    }

    // 从数据源获取
    final task = await _dataSource.getTaskById(id);

    // 缓存结果
    if (task != null) {
      _taskCache.put(id, task);
    }

    return task;
  }

  @override
  Future<String> createTask(TaskModel task) async {
    // 创建任务
    final taskId = await _dataSource.createTask(task);

    // 更新缓存
    _taskCache.put(task.id, task);
    _invalidateListCaches();

    return taskId;
  }

  @override
  Future<void> updateTask(TaskModel task) async {
    // 更新任务
    await _dataSource.updateTask(task);

    // 更新缓存
    _taskCache.put(task.id, task);
    _invalidateListCaches();
  }

  @override
  Future<void> deleteTask(String id) async {
    // 删除任务
    await _dataSource.deleteTask(id);

    // 清除缓存
    _taskCache.remove(id);
    _invalidateListCaches();
  }

  @override
  Future<List<TaskModel>> searchTasks(String query) async {
    // 搜索不缓存，因为查询条件变化太多
    return await _dataSource.searchTasks(query);
  }

  @override
  Future<void> clearAllTasks() async {
    // 清空所有任务
    await _dataSource.clearAllTasks();

    // 清空所有缓存
    _taskCache.clear();
    _listCache.clear();
  }

  /// 使列表缓存失效
  void _invalidateListCaches() {
    _listCache.clear();
  }

  /// 获取缓存统计信息
  Map<String, CacheStats> getCacheStats() {
    return {'taskCache': _taskCache.stats, 'listCache': _listCache.stats};
  }

  /// 清理缓存
  void clearCache() {
    _taskCache.clear();
    _listCache.clear();
  }

  /// 销毁缓存
  void dispose() {
    _taskCache.dispose();
    _listCache.dispose();
  }
}
