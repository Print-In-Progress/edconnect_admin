class Failure {
  final String message;

  Failure(this.message);

  @override
  String toString() => message;
}

class ValidationFailure extends Failure {
  ValidationFailure(String message) : super(message);
}

class AuthFailure extends Failure {
  AuthFailure(String message) : super(message);
}

class StorageFailure extends Failure {
  StorageFailure(String message) : super(message);
}
