import 'package:edconnect_admin/l10n/app_localizations.dart';
import '../../errors/domain_exception.dart';
import '../base_validator.dart';
import '../../../domain/entities/registration_fields.dart';

class RegistrationFieldValidator
    implements Validator<List<BaseRegistrationField>> {
  final AppLocalizations l10n;

  RegistrationFieldValidator(this.l10n);

  @override
  void validate(List<BaseRegistrationField> fields) {
    final flattenedFields = _flattenFields(fields);
    _validateSignatureFields(flattenedFields);
    _validateFreeResponseFields(flattenedFields);
  }

  List<BaseRegistrationField> _flattenFields(
      List<BaseRegistrationField> fields) {
    return fields.expand((field) {
      var result = [field];
      if (field.childWidgets != null) {
        result.addAll(field.childWidgets!);
      }
      return result;
    }).toList();
  }

  void _validateSignatureFields(List<BaseRegistrationField> fields) {
    for (var field in fields) {
      if (field is RegistrationSubField && field.type == 'signature') {
        var parentField =
            fields.firstWhere((element) => element.id == field.parentUid);
        if (parentField.checked == true && field.checked == false) {
          throw DomainException(
              message: l10n.validationSignatureMissing,
              type: ExceptionType.validation);
        }
      } else if (field is RegistrationField && field.type == 'signature') {
        if (field.checked == false) {
          throw DomainException(
              message: l10n.validationSignatureMissing,
              type: ExceptionType.validation);
        }
      }
    }
  }

  void _validateFreeResponseFields(List<BaseRegistrationField> fields) {
    for (var field in fields) {
      if (field is RegistrationSubField && field.type == 'free_response') {
        var parentField =
            fields.firstWhere((element) => element.id == field.parentUid);
        if (parentField.checked == true && field.response!.text.isEmpty) {
          throw DomainException(
              message: l10n.validationRequiredSnackbar,
              type: ExceptionType.validation);
        }
      } else if (field is RegistrationField && field.type == 'free_response') {
        if (field.response!.text.isEmpty) {
          throw DomainException(
              message: l10n.validationRequiredSnackbar,
              type: ExceptionType.validation);
        }
      }
    }
  }
}
