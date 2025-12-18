import 'package:equatable/equatable.dart';

/// 应用错误基类
abstract class Failure extends Equatable {
  const Failure([this.message]);

  final String? message;

  @override
  List<Object?> get props => [message];
}

/// 网络错误
class NetworkFailure extends Failure {
  const NetworkFailure([super.message]);
}

/// 服务器错误
class ServerFailure extends Failure {
  const ServerFailure([super.message]);
}

/// 缓存错误
class CacheFailure extends Failure {
  const CacheFailure([super.message]);
}

/// 数据库错误
class DatabaseFailure extends Failure {
  const DatabaseFailure([super.message]);
}

/// 认证错误
class AuthFailure extends Failure {
  const AuthFailure([super.message]);
}

/// 同步冲突错误
class SyncConflictFailure extends Failure {
  const SyncConflictFailure([super.message]);
}

/// AI服务错误
class AIServiceFailure extends Failure {
  const AIServiceFailure([super.message]);
}
