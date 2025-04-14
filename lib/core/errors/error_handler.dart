import 'package:firebase_auth/firebase_auth.dart';
import 'domain_exception.dart';

class ErrorHandler {
  static DomainException handle(dynamic error) {
    if (error is DomainException) return error;

    // Handle Firebase Auth Errors
    if (error is FirebaseAuthException) {
      return _handleFirebaseAuthError(error);
    }

    // Handle Network Errors
    if (error.toString().contains('SocketException') ||
        error.toString().contains('TimeoutException')) {
      return DomainException(
        code: ErrorCode.networkError,
        type: ExceptionType.network,
        originalError: error,
      );
    }

    // Handle Validation Errors
    if (error.toString().contains('SignatureMissing')) {
      return const DomainException(
        code: ErrorCode.signatureMissing,
        type: ExceptionType.validation,
      );
    }

    if (error.toString().contains('QuestionMissing')) {
      return const DomainException(
        code: ErrorCode.questionMissing,
        type: ExceptionType.validation,
      );
    }

    // Default error
    return DomainException(
      code: ErrorCode.unexpected,
      type: ExceptionType.unexpected,
      originalError: error.toString(),
    );
  }

  static DomainException _handleFirebaseAuthError(FirebaseAuthException error) {
    final code = switch (error.code) {
      'email-already-in-use' => ErrorCode.emailAlreadyInUse,
      'wrong-password' => ErrorCode.wrongPassword,
      'user-not-found' => ErrorCode.userNotFound,
      _ => ErrorCode.unexpected
    };

    return DomainException(
      code: code,
      type: ExceptionType.auth,
      originalError: error.message ?? error.toString(),
    );
  }
}
