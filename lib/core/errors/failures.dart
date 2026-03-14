import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  String get message;

  @override
  String toString() => message;

  @override
  List<Object> get props => [];
}

class DatabaseFailure extends Failure {
  final String message;

  DatabaseFailure(this.message);

  @override
  List<Object> get props => [message];
}

class NetworkFailure extends Failure {
  final String message;

  NetworkFailure(this.message);

  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  final String message;

  ServerFailure(this.message);

  @override
  List<Object> get props => [message];
}

class CacheFailure extends Failure {
  final String message;

  CacheFailure(this.message);

  @override
  List<Object> get props => [message];
}

class ValidationFailure extends Failure {
  final String message;

  ValidationFailure(this.message);

  @override
  List<Object> get props => [message];
}

class PermissionFailure extends Failure {
  final String message;

  PermissionFailure(this.message);

  @override
  List<Object> get props => [message];
}

class MLKitFailure extends Failure {
  final String message;

  MLKitFailure(this.message);

  @override
  List<Object> get props => [message];
}

class UnknownFailure extends Failure {
  final String message;

  UnknownFailure(this.message);

  @override
  List<Object> get props => [message];
}
