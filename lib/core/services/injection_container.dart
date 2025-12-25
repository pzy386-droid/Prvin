import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:prvin/core/bloc/app_bloc.dart';
import 'package:prvin/core/cache/cache_manager.dart';
import 'package:prvin/core/database/database_helper.dart';
import 'package:prvin/core/services/event_bus.dart';
import 'package:prvin/core/services/performance_optimization_service.dart';
// Temporarily commented out due to compilation issues with dart:html
// import 'package:prvin/core/services/pwa_service.dart';
// import 'package:prvin/core/services/web_platform_service.dart';
// import 'package:prvin/core/services/web_router_service.dart';
import 'package:prvin/features/sync/data/datasources/calendar_event_local_datasource.dart';
import 'package:prvin/features/task_management/data/datasources/cached_task_datasource.dart';
import 'package:prvin/features/task_management/data/datasources/task_local_datasource.dart';
import 'package:prvin/features/task_management/data/repositories/task_repository_impl.dart';
import 'package:prvin/features/task_management/domain/repositories/task_repository.dart';
import 'package:prvin/features/task_management/domain/usecases/task_usecases.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 依赖注入容器
final sl = GetIt.instance;

/// 初始化依赖注入
Future<void> init() async {
  // 核心服务
  await _initCore();

  // Web平台服务（仅在Web平台）
  // Temporarily commented out due to compilation issues
  /*
  if (kIsWeb) {
    await _initWebServices();
  }
  */

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
  sl.registerLazySingleton<EventBus>(EventBus.new);

  // 缓存管理器 - 单例
  sl.registerLazySingleton<CacheManager<String, dynamic>>(
    () => CacheManager<String, dynamic>(maxSize: 500),
  );

  // 性能优化服务 - 单例
  sl.registerLazySingleton<PerformanceOptimizationService>(
    () => PerformanceOptimizationService.instance,
  );
}

Future<void> _initWebServices() async {
  // Temporarily commented out due to compilation issues
  /*
  // Web平台服务 - 单例
  sl.registerLazySingleton<WebPlatformService>(
    () => WebPlatformService.instance,
  );

  // Web路由服务 - 单例
  sl.registerLazySingleton<WebRouterService>(() => WebRouterService.instance);

  // PWA服务 - 单例
  sl.registerLazySingleton<PWAService>(() => PWAService.instance);
  */
}

Future<void> _initExternal() async {
  // SharedPreferences - 单例
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
}

Future<void> _initDataSources() async {
  // 数据库帮助类
  sl.registerLazySingleton<DatabaseHelper>(DatabaseHelper.new);

  // 任务数据源
  sl.registerLazySingleton<TaskLocalDataSource>(
    () => TaskLocalDataSourceImpl(sl()),
  );

  // 缓存任务数据源装饰器
  sl.registerLazySingleton<TaskLocalDataSource>(
    () => CachedTaskDataSource(sl<TaskLocalDataSource>()),
    instanceName: 'cached',
  );

  // 日历事件数据源
  sl.registerLazySingleton<CalendarEventLocalDataSource>(
    () => CalendarEventLocalDataSourceImpl(sl()),
  );
}

Future<void> _initRepositories() async {
  // 任务仓库
  sl.registerLazySingleton<TaskRepository>(TaskRepositoryImpl.new);
}

Future<void> _initUseCases() async {
  // 任务管理用例
  sl.registerLazySingleton<TaskUseCases>(() => TaskUseCases(sl()));

  // AI分析用例 - 暂时禁用
  // sl.registerLazySingleton<AIAnalytics>(() => AIAnalytics(sl()));
}

Future<void> _initBlocs() async {
  // 应用级BLoC - 单例
  sl.registerLazySingleton<AppBloc>(AppBloc.new);
}
