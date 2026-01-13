/// Base class for all failures in the application
abstract class Failure {
  final String message;
  
  const Failure(this.message);
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;
}

/// Failure when server returns an error
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

/// Failure when there's a network issue
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

/// Failure when there's a cache/local storage issue
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

