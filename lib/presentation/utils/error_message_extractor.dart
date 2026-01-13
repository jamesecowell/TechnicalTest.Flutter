import 'package:flutter_tech_task/core/error/failures.dart';

/// Extracts a user-friendly error message from an error object.
/// Handles Failure types and falls back to toString() for other errors.
String extractErrorMessage(Object error) {
  if (error is ServerFailure) {
    return error.message;
  } else if (error is NetworkFailure) {
    return error.message;
  } else if (error is CacheFailure) {
    return error.message;
  } else {
    return error.toString();
  }
}

