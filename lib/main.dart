import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:prvin/core/bloc/app_bloc.dart';
import 'package:prvin/core/bloc/app_bloc_observer.dart';
import 'package:prvin/core/bloc/bloc_providers.dart';
import 'package:prvin/core/constants/app_constants.dart';
import 'package:prvin/core/localization/localization_exports.dart';
import 'package:prvin/core/services/injection_container.dart' as di;
import 'package:prvin/core/services/performance_optimization_service.dart';
// Temporarily commented out due to compilation issues with dart:html
// import 'package:prvin/core/services/pwa_service.dart';
// import 'package:prvin/core/services/web_platform_service.dart';
// import 'package:prvin/core/services/web_router_service.dart';
import 'package:prvin/core/theme/theme_exports.dart';
import 'package:prvin/integrated_calendar_with_pomodoro.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 设置BLoC观察者
  Bloc.observer = AppBlocObserver();

  // 初始化依赖注入
  await di.init();

  // 启动性能优化服务
  PerformanceOptimizationService.instance.start();

  // 初始化Web平台服务（仅在Web平台）
  // Temporarily commented out due to compilation issues
  /*
  if (kIsWeb) {
    await WebPlatformService.instance.initialize();
    await WebRouterService.instance.initialize();
    await PWAService.instance.initialize();
  }
  */

  runApp(const PrvinApp());
}

// 用于Widget Preview的简单入口
void previewMain() {
  runApp(
    const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text(
            'Prvin AI日历预览',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
    ),
  );
}

/// Prvin AI智能日历应用
class PrvinApp extends StatelessWidget {
  const PrvinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBlocProviders(
      child: AppBlocListeners(
        child: BlocBuilder<AppBloc, AppState>(
          builder: (context, state) {
            // 根据应用状态显示不同界面
            if (state is AppLoadingState) {
              return MaterialApp(
                title: AppConstants.appName,
                theme: AppTheme.lightTheme,
                home: const SplashScreen(),
                debugShowCheckedModeBanner: false,
                // 添加本地化支持
                locale: const Locale('zh'),
                supportedLocales: const [Locale('zh'), Locale('en')],
                localizationsDelegates: const [
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
              );
            }

            if (state is AppErrorState) {
              return MaterialApp(
                title: AppConstants.appName,
                theme: AppTheme.lightTheme,
                home: ErrorScreen(message: state.message),
                debugShowCheckedModeBanner: false,
                // 添加本地化支持
                locale: const Locale('zh'),
                supportedLocales: const [Locale('zh'), Locale('en')],
                localizationsDelegates: const [
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
              );
            }

            if (state is AppReadyState) {
              // 设置当前语言到本地化服务
              AppLocalizations.setCurrentLocale(state.languageCode);

              return MaterialApp(
                title: AppConstants.appName,
                theme: AccessibilityTheme.getAdaptiveTheme(
                  context,
                  isDark: state.isDarkMode,
                ),
                home: const WebAwareMainScreen(),
                debugShowCheckedModeBanner: false,
                // 添加本地化支持
                locale: Locale(state.languageCode),
                supportedLocales: const [Locale('zh'), Locale('en')],
                localizationsDelegates: const [
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
              );
            }

            // 默认显示启动屏幕
            return MaterialApp(
              title: AppConstants.appName,
              theme: AppTheme.lightTheme,
              home: const SplashScreen(),
              debugShowCheckedModeBanner: false,
              // 添加本地化支持
              locale: const Locale('zh'),
              supportedLocales: const [Locale('zh'), Locale('en')],
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Web感知的主屏幕
/// 根据Web平台的特性提供优化的用户体验
class WebAwareMainScreen extends StatefulWidget {
  const WebAwareMainScreen({super.key});

  @override
  State<WebAwareMainScreen> createState() => _WebAwareMainScreenState();
}

class _WebAwareMainScreenState extends State<WebAwareMainScreen> {
  @override
  void initState() {
    super.initState();

    if (kIsWeb) {
      _setupWebListeners();
    }
  }

  /// 设置Web平台监听器
  void _setupWebListeners() {
    // Temporarily commented out due to compilation issues
    /*
    // 监听键盘快捷键
    WebPlatformService.instance.keyboardShortcuts.listen(
      _handleKeyboardShortcut,
    );

    // 监听路由变化
    WebRouterService.instance.routeChanges.listen(_handleRouteChange);

    // 监听PWA安装可用状态
    WebPlatformService.instance.pwaInstallAvailable.listen((available) {
      if (available && mounted) {
        _showPWAInstallPrompt();
      }
    });

    // 监听在线状态变化
    WebPlatformService.instance.onlineStatus.listen(_handleOnlineStatusChange);
    */
  }

  /// 处理键盘快捷键
  void _handleKeyboardShortcut(String shortcut) {
    switch (shortcut) {
      case 'quick-task':
        // 触发快速创建任务
        _showQuickTaskDialog();
      case 'language-toggle':
        // 触发语言切换
        _toggleLanguage();
      case 'pomodoro':
        // 启动番茄钟
        _startPomodoro();
    }
  }

  /// 处理路由变化
  void _handleRouteChange(String route) {
    // Temporarily commented out due to compilation issues
    /*
    // 更新页面标题
    WebRouterService.instance.updatePageTitle(route);

    // 根据路由执行相应操作
    switch (route) {
      case '/create-task':
        _showQuickTaskDialog();
      case '/pomodoro':
        _startPomodoro();
      case '/today':
        _showTodayTasks();
    }
    */
  }

  /// 显示PWA安装提示
  void _showPWAInstallPrompt() {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('安装应用'),
        content: const Text('将Prvin AI日历安装到您的设备上，享受更好的使用体验！'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('稍后'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              // Temporarily commented out due to compilation issues
              // await WebPlatformService.instance.promptPWAInstall();
            },
            child: const Text('安装'),
          ),
        ],
      ),
    );
  }

  /// 处理在线状态变化
  void _handleOnlineStatusChange(bool isOnline) {
    if (!mounted) return;

    final message = isOnline ? '网络连接已恢复' : '网络连接已断开，正在离线模式下运行';
    final color = isOnline ? Colors.green : Colors.orange;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// 显示快速创建任务对话框
  void _showQuickTaskDialog() {
    // 这里应该调用实际的快速创建任务功能
    // 暂时显示一个简单的提示
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('快速创建任务功能 (Ctrl+K)')));
    }
  }

  /// 切换语言
  void _toggleLanguage() {
    // 这里应该调用实际的语言切换功能
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('语言切换功能 (Ctrl+L)')));
    }
  }

  /// 启动番茄钟
  void _startPomodoro() {
    // 这里应该调用实际的番茄钟功能
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('番茄钟专注模式 (Ctrl+P)')));
    }
  }

  /// 显示今日任务
  void _showTodayTasks() {
    // 这里应该导航到今日任务视图
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('今日任务视图')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return const IntegratedCalendarWithPomodoroApp();
  }
}

/// 启动屏幕
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 应用图标占位符
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.calendar_today,
                size: 60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              AppConstants.appName,
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              context.l10n('app_subtitle', fallback: 'AI智能日程表应用'),
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 48),
            // 加载指示器
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
            ),
          ],
        ),
      ),
    );
  }
}

/// 错误屏幕
class ErrorScreen extends StatelessWidget {
  const ErrorScreen({required this.message, super.key});

  /// 错误信息
  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 80, color: Colors.red),
            const SizedBox(height: 24),
            Text(
              context.l10n('app_startup_failed', fallback: '应用启动失败'),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                // 重新初始化应用
                context.read<AppBloc>().add(const AppInitializeEvent());
              },
              child: Text(context.l10n('retry', fallback: '重试')),
            ),
          ],
        ),
      ),
    );
  }
}

/// 主屏幕 - 集成日历应用
class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const IntegratedCalendarWithPomodoroApp();
  }
}
