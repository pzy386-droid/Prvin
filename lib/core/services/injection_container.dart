import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_first_app/core/bloc/app_bloc.dart';
import 'package:my_first_app/core/database/database_helper.dart';
import 'package:my_first_app/core/services/event_bus.dart';
import 'package:my_first_app/features/tasks/data/datasources/task_local_datasource.dart';
import 'package:my_first_app/features/tasks/data/datasources/cached_task_datasource.dart';
import 'package:my_first_app/features/tasks/data/repositories/task_repository_impl.dart';
import 'package:my_first_app/features/tasks/domain/repositories/task_repository.dart';
import 'package:my_first_app/features/pomodoro/data/datasources/pomodoro_local_datasource.dart';
import 'package:my_first_app/features/sync/data/datasources/calendar_event_local_datasource.dart';
import 'package:my_first_app/core/cache/cache_manager.dart';

/// 依赖注入容器
final sl = GetIt.instance;

/// 初始化依赖注入
Future<void> init() async {
  // 核心服务
  await _initCore();

  // 外部依赖
  await _initExternal();

  // 数据源
  await _initDataSources();

  // 仓储
  await _initRepositories();

  // 用例
  await _initUseCases();

  // BLoC
  await _initBlocs();
}

Future<void> _initCore() async {
  // 事件总线 - 单例
  sl.registerLazySingleton<EventBus>(() => EventBus());

  // 缓存管理器 - 单例
  sl.registerLazySingleton<CacheManager>(
    () => CacheManager<String, dynamic>(
      maxSize: 500,
      ttl: const Duration(minutes: 30),
    ),
  );
}

Future<void> _initExternal() async {
  // SharedPreferences - 单例
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
}

Future<void> _initDataSources() async {
  // 数据库帮助类
  sl.registerLazySingleton<DatabaseHelper>(() => DatabaseHelper());

  // 任务数据源
  sl.registerLazySingleton<TaskLocalDataSource>(
    () => CachedTaskDataSource(TaskLocalDataSourceImpl(sl())),
  );

  // 番茄钟数据源
  sl.registerLazySingleton<PomodoroLocalDataSource>(
    () => PomodoroLocalDataSourceImpl(sl()),
  );

  // 日历事件数据源
  sl.registerLazySingleton<CalendarEventLocalDataSource>(
    () => CalendarEventLocalDataSourceImpl(sl()),
  );
}

Future<void> _initRepositories() async {
  // 任务仓库
  sl.registerLazySingleton<TaskRepository>(() => TaskRepositoryImpl(sl()));
}

Future<void> _initUseCases() async {
  // 用例将在后续任务中实现
}

Future<void> _initBlocs() async {
  // 应用级BLoC - 单例
  sl.registerLazySingleton<AppBloc>(() => AppBloc());
}
