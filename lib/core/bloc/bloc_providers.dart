import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/injection_container.dart' as di;
import 'app_bloc.dart';

/// 应用级BLoC提供者
class AppBlocProviders extends StatelessWidget {
  const AppBlocProviders({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // 应用级BLoC
        BlocProvider<AppBloc>(
          create: (context) =>
              di.sl<AppBloc>()..add(const AppInitializeEvent()),
        ),

        // 其他BLoC将在后续任务中添加
      ],
      child: child,
    );
  }
}

/// BLoC监听器组合
class AppBlocListeners extends StatelessWidget {
  const AppBlocListeners({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // 应用级BLoC监听器
        BlocListener<AppBloc, AppState>(
          listener: (context, state) {
            if (state is AppErrorState) {
              // 显示错误消息
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        ),

        // 其他BLoC监听器将在后续任务中添加
      ],
      child: child,
    );
  }
}
