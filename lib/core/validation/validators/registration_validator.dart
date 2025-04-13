import '../../errors/domain_exception.dart';
import '../base_validator.dart';
import '../../../domain/entities/registration_request.dart';
import 'text_field_validator.dart';
import 'registration_field_validator.dart';

class RegistrationValidator implements Validator<RegistrationRequest> {
  final TextFieldValidator _emailValidator;
  final TextFieldValidator _nameValidator;
  final TextFieldValidator _passwordValidator;
  final RegistrationFieldValidator _fieldValidator;

  RegistrationValidator()
      : _emailValidator = TextFieldValidator(type: TextFieldType.email),
        _nameValidator = TextFieldValidator(type: TextFieldType.name),
        _passwordValidator = TextFieldValidator(
          type: TextFieldType.password,
        ),
        _fieldValidator = RegistrationFieldValidator();

  @override
  void validate(RegistrationRequest request) {
    _emailValidator.validate(request.email);
    _nameValidator.validate(request.firstName);
    _nameValidator.validate(request.lastName);
    _passwordValidator.validate(request.password);

    if (request.password != request.confirmedPassword) {
      throw const DomainException(
          code: ErrorCode.passwordsDoNotMatch, type: ExceptionType.validation);
    }

    _fieldValidator.validate(request.registrationFields);
  }
}
