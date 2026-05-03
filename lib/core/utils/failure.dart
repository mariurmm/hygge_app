/// Base class for all domain-layer failures.
///
/// Repositories catch raw exceptions and rethrow them as [Failure] subtypes.
/// BLoCs/Cubits pattern-match on the subtype to decide what to show the user.
abstract class Failure implements Exception {
  const Failure({required this.message, this.code, this.cause, this.stackTrace});

  final String message;
  final String? code;
  final Object? cause;
  final StackTrace? stackTrace;

  @override
  String toString() => '$runtimeType(code: $code, message: $message)';
}

// ── Concrete failures ─────────────────────────────────────────────────────────

class AuthFailure extends Failure {
  const AuthFailure({required super.message, super.code, super.cause, super.stackTrace});
}

class PermissionFailure extends Failure {
  const PermissionFailure({required super.message, super.code, super.cause, super.stackTrace});
}

class NotFoundFailure extends Failure {
  const NotFoundFailure({required super.message, super.code, super.cause, super.stackTrace});
}

class NetworkFailure extends Failure {
  const NetworkFailure({required super.message, super.code, super.cause, super.stackTrace});
}

class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.code, super.cause, super.stackTrace});
}

class UnknownFailure extends Failure {
  const UnknownFailure({required super.message, super.code, super.cause, super.stackTrace});
}
