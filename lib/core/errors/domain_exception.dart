enum ExceptionType { validation, auth, network, storage, database, unexpected }

class DomainException implements Exception {
  final String message;
  final ExceptionType type;
  final dynamic originalError;

  const DomainException({
    required this.message,
    required this.type,
    this.originalError,
  });

  @override
  String toString() => message;
}
