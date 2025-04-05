enum ErrorCode {
  // Validation errors
  signatureMissing,
  questionMissing,
  fieldRequired,
  fieldTooShort,
  fieldTooLong,
  invalidEmail,

  // Auth errors
  emailAlreadyInUse,
  wrongPassword,
  userNotFound,
  passwordMissingNumber,
  passwordMissingSpecial,
  passwordsDoNotMatch,

  // Network errors
  networkError,

  // Generic errors
  unexpected
}

enum ExceptionType {
  validation,
  auth,
  network,
  storage,
  database,
  unexpected,
}

class DomainException implements Exception {
  final ErrorCode code;
  final ExceptionType type;
  final dynamic originalError;

  const DomainException({
    required this.code,
    required this.type,
    this.originalError,
  });

  @override
  String toString() => code.toString();
}
