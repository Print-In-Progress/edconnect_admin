import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../errors/domain_exception.dart';
import '../base_validator.dart';

class TextFieldValidator implements Validator<String> {
  final TextFieldType type;
  final bool required;
  final int? minLength;
  final int? maxLength;
  final AppLocalizations l10n;

  TextFieldValidator({
    required this.l10n,
    this.type = TextFieldType.text,
    this.required = true,
    this.minLength,
    this.maxLength,
  });

  @override
  void validate(String input) {
    if (required && input.isEmpty) {
      throw DomainException(message: '', type: ExceptionType.validation);
    }

    if (minLength != null && input.length < minLength!) {
      throw DomainException(message: '', type: ExceptionType.validation);
    }

    switch (type) {
      case TextFieldType.email:
        _validateEmail(input);
      case TextFieldType.password:
        _validatePassword(input);
      case TextFieldType.name:
        _validateName(input);
      default:
        break;
    }
  }

  void _validateEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      throw DomainException(message: '', type: ExceptionType.validation);
    }
  }

  void _validatePassword(String password) {
    if (!RegExp(r'\d').hasMatch(password)) {
      throw DomainException(message: '', type: ExceptionType.validation);
    }
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      throw DomainException(
          message: 'l10n.authPagesPasswordMustContainSpecial',
          type: ExceptionType.validation);
    }
  }

  void _validateName(String name) {
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(name)) {
      throw DomainException(message: '', type: ExceptionType.validation);
    }
  }
}

enum TextFieldType {
  text,
  email,
  password,
  name,
}
