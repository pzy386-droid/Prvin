import 'package:dartz/dartz.dart';
import 'package:prvine/core/error/failures.dart';

/// 通用类型定义
typedef ResultFuture<T> = Future<Either<Failure, T>>;
typedef ResultVoid = Future<Either<Failure, void>>;
typedef DataMap = Map<String, dynamic>;
