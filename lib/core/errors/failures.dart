import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  String get message;

  @override
  String toString() => message;

  @override
  List<Object> get props => [];
}

class DatabaseFailure extends Failure {
  @override
  final String message;

  DatabaseFailure(this.message);

  @override
  List<Object> get props => [message];
}

class NetworkFailure extends Failure {
  @override
  final String message;

  NetworkFailure(this.message);

  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  @override
  final String message;

  ServerFailure(this.message);

  @override
  List<Object> get props => [message];
}

class CacheFailure extends Failure {
  @override
  final String message;

  CacheFailure(this.message);

  @override
  List<Object> get props => [message];
}

class ValidationFailure extends Failure {
  @override
  final String message;

  ValidationFailure(this.message);

  @override
  List<Object> get props => [message];
}

class PermissionFailure extends Failure {
  @override
  final String message;

  PermissionFailure(this.message);

  @override
  List<Object> get props => [message];
}

class MLKitFailure extends Failure {
  @override
  final String message;

  MLKitFailure(this.message);

  @override
  List<Object> get props => [message];
}

class UnknownFailure extends Failure {
  @override
  final String message;

  UnknownFailure(this.message);

  @override
  List<Object> get props => [message];
}
