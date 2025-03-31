import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../errors/domain_exception.dart';
import '../base_validator.dart';
import '../../../domain/entities/registration_request.dart';
import 'text_field_validator.dart';
import 'registration_field_validator.dart';

class RegistrationValidator implements Validator<RegistrationRequest> {
  final AppLocalizations l10n;
  final TextFieldValidator _emailValidator;
  final TextFieldValidator _nameValidator;
  final TextFieldValidator _passwordValidator;
  final RegistrationFieldValidator _fieldValidator;

  RegistrationValidator(this.l10n)
      : _emailValidator =
            TextFieldValidator(l10n: l10n, type: TextFieldType.email),
        _nameValidator =
            TextFieldValidator(l10n: l10n, type: TextFieldType.name),
        _passwordValidator = TextFieldValidator(
          l10n: l10n,
          type: TextFieldType.password,
          minLength: 8,
        ),
        _fieldValidator = RegistrationFieldValidator(l10n);

  @override
  void validate(RegistrationRequest request) {
    _emailValidator.validate(request.email);
    _nameValidator.validate(request.firstName);
    _nameValidator.validate(request.lastName);
    _passwordValidator.validate(request.password);

    if (request.password != request.confirmedPassword) {
      throw DomainException(
          message: 'Password and confirmed password do not match',
          type: ExceptionType.validation);
    }

    _fieldValidator.validate(request.registrationFields);
  }
}
