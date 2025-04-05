enum ErrorCode {
  // Validation errors
  signatureMissing,
  questionMissing,
  fieldRequired,
  fieldTooShort,
  fieldTooLong,
  invalidEmail,
  signatureValidationFailed,

  // Auth errors
  emailAlreadyInUse,
  wrongPassword,
  userNotFound,
  passwordMissingNumber,
  passwordMissingSpecial,
  passwordsDoNotMatch,
  authAccountAlreadyExists,

  // Group errors
  groupNotFound,
  groupUpdateFailed,
  groupDeleteFailed,
  groupCreateFailed,
  invalidGroupOperation,
  userGroupUpdateFailed,

  // Storage errors
  fileUploadFailed,
  fileDeleteFailed,
  fileNotFound,
  invalidFileType,
  fileTooLarge,
  fileListFailed,
  storageOperationFailed,

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
