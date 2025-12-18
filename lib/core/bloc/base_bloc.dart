import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../error/failures.dart';

/// 基础状态类，所有BLoC状态都应该继承此类
abstract class BaseState extends Equatable {
  const BaseState();
}

/// 初始状态
class InitialState extends BaseState {
  const InitialState();

  @override
  List<Object?> get props => [];
}

/// 加载状态
class LoadingState extends BaseState {
  const LoadingState();

  @override
  List<Object?> get props => [];
}

/// 成功状态
class SuccessState<T> extends BaseState {
  const SuccessState(this.data);

  final T data;

  @override
  List<Object?> get props => [data];
}

/// 错误状态
class ErrorState extends BaseState {
  const ErrorState(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}

/// 基础事件类，所有BLoC事件都应该继承此类
abstract class BaseEvent extends Equatable {
  const BaseEvent();
}

/// 基础BLoC类，提供通用的错误处理和状态管理
abstract class BaseBloc<Event extends BaseEvent, State extends BaseState>
    extends Bloc<Event, State> {
  BaseBloc(super.initialState);

  /// 处理错误的通用方法
  State handleError(Failure failure) {
    return ErrorState(failure) as State;
  }

  /// 处理加载状态的通用方法
  State handleLoading() {
    return const LoadingState() as State;
  }

  /// 处理成功状态的通用方法
  State handleSuccess<T>(T data) {
    return SuccessState<T>(data) as State;
  }
}
