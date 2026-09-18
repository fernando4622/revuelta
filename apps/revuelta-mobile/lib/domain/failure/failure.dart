sealed class Failure {
  final String message;
  final String? code;

  const Failure(this.message, {this.code});

  @override
  String toString() => message;
}

class NetworkFailure extends Failure {
  const NetworkFailure([String message = 'Network connection failed']) : super(message, code: 'NETWORK_ERROR');
}

class AuthFailure extends Failure {
  const AuthFailure(String message, {String? code}) : super(message, code: code ?? 'AUTH_ERROR');
}

class ValidationFailure extends Failure {
  const ValidationFailure(String message, {String? code}) : super(message, code: code ?? 'VALIDATION_ERROR');
}

class ConflictFailure extends Failure {
  const ConflictFailure(String message, {String? code}) : super(message, code: code ?? 'CONFLICT_ERROR');
}

class NotFoundFailure extends Failure {
  const NotFoundFailure(String message, {String? code}) : super(message, code: code ?? 'NOT_FOUND_ERROR');
}

class ServerFailure extends Failure {
  const ServerFailure(String message, {String? code}) : super(message, code: code ?? 'SERVER_ERROR');
}
