import 'package:flutter_bloc/flutter_bloc.dart';

/// 应用级BLoC观察者，用于监控所有BLoC的状态变化
class AppBlocObserver extends BlocObserver {
  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    // 在开发模式下记录BLoC创建
    // print('BLoC Created: ${bloc.runtimeType}');
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    // 在开发模式下记录状态变化
    // print('BLoC Change: ${bloc.runtimeType} - $change');
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    // 在开发模式下记录状态转换
    // print('BLoC Transition: ${bloc.runtimeType} - $transition');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    // 记录BLoC错误
    print('BLoC Error: ${bloc.runtimeType} - $error');
    print('Stack Trace: $stackTrace');
  }

  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    // 在开发模式下记录BLoC关闭
    // print('BLoC Closed: ${bloc.runtimeType}');
  }
}
