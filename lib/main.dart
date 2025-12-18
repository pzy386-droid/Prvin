import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prvin/core/constants/app_constants.dart';
import 'package:prvin/core/theme/app_theme.dart';
import 'package:prvin/core/services/injection_container.dart' as di;
import 'package:prvin/core/bloc/app_bloc_observer.dart';
import 'package:prvin/core/bloc/bloc_providers.dart';
import 'package:prvin/core/bloc/app_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 设置BLoC观察者
  Bloc.observer = AppBlocObserver();

  // 初始化依赖注入
  await di.init();

  runApp(const PrvinApp());
}

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
              );
            }

            if (state is AppErrorState) {
              return MaterialApp(
                title: AppConstants.appName,
                theme: AppTheme.lightTheme,
                home: ErrorScreen(message: state.message),
                debugShowCheckedModeBanner: false,
              );
            }

            if (state is AppReadyState) {
              return MaterialApp(
                title: AppConstants.appName,
                theme: state.isDarkMode
                    ? AppTheme.darkTheme
                    : AppTheme.lightTheme,
                home: const MainScreen(),
                debugShowCheckedModeBanner: false,
              );
            }

            // 默认显示启动屏幕
            return MaterialApp(
              title: AppConstants.appName,
              theme: AppTheme.lightTheme,
              home: const SplashScreen(),
              debugShowCheckedModeBanner: false,
            );
          },
        ),
      ),
    );
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
              'AI智能日程表应用',
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
  const ErrorScreen({super.key, required this.message});

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
              '应用启动失败',
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
              child: const Text('重试'),
            ),
          ],
        ),
      ),
    );
  }
}

/// 主屏幕 - 临时实现
class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppConstants.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: () {
              // 切换主题
              final currentState = context.read<AppBloc>().state;
              if (currentState is AppReadyState) {
                context.read<AppBloc>().add(
                  AppThemeChangedEvent(!currentState.isDarkMode),
                );
              }
            },
          ),
        ],
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today, size: 100, color: AppTheme.primaryColor),
            SizedBox(height: 24),
            Text(
              '欢迎使用 Prvin',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'AI智能日程表应用',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 32),
            Text(
              '功能正在开发中...',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
