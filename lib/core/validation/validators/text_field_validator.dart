import '../../errors/domain_exception.dart';
import '../base_validator.dart';

class TextFieldValidator implements Validator<String> {
  final TextFieldType type;
  final bool required;
  final int? minLength;
  final int? maxLength;

  TextFieldValidator({
    this.type = TextFieldType.text,
    this.required = true,
    this.minLength,
    this.maxLength,
  });

  @override
  void validate(String input) {
    if (required && input.isEmpty) {
      throw const DomainException(
          code: ErrorCode.fieldRequired, type: ExceptionType.validation);
    }

    if (minLength != null && input.length < minLength!) {
      throw const DomainException(
          code: ErrorCode.fieldTooShort, type: ExceptionType.validation);
    }

    if (maxLength != null && input.length > maxLength!) {
      throw const DomainException(
          code: ErrorCode.fieldTooLong, type: ExceptionType.validation);
    }

    switch (type) {
      case TextFieldType.email:
        _validateEmail(input);
      case TextFieldType.password:
        _validatePassword(input);
      case TextFieldType.number:
        _validateNumber(input);
      default:
        break;
    }
  }

  void _validateNumber(String input) {
    if (!RegExp(r'^[0-9]+$').hasMatch(input)) {
      throw const DomainException(
          code: ErrorCode.fieldRequired, type: ExceptionType.validation);
    }
  }

  void _validateEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      throw const DomainException(
          code: ErrorCode.invalidEmail, type: ExceptionType.validation);
    }
  }

  void _validatePassword(String password) {
    if (!RegExp(r'\d').hasMatch(password)) {
      throw const DomainException(
          code: ErrorCode.passwordMissingNumber,
          type: ExceptionType.validation);
    }
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      throw const DomainException(
          code: ErrorCode.passwordMissingSpecial,
          type: ExceptionType.validation);
    }
  }
}

enum TextFieldType {
  text,
  email,
  password,
  name,
  number,
}
