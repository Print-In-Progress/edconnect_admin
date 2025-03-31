import 'package:edconnect_admin/domain/entities/registration_fields.dart';

bool passwordConfirmed(String password, String confirmedPassword) {
  if (password.trim() == confirmedPassword.trim()) {
    return true;
  } else {
    return false;
  }
}

String validateCustomRegistrationFields(flattenedRegistrationList) {
  for (var field in flattenedRegistrationList) {
    if (field is RegistrationSubField && field.type == 'signature') {
      var parentField = flattenedRegistrationList
          .firstWhere((element) => element.id == field.parentUid);
      if (parentField.checked == true && field.checked == false) {
        return 'SignatureMissing';
      }
    } else if (field is RegistrationField && field.type == 'signature') {
      if (field.checked == false) {
        return 'SignatureMissing';
      }
    } else if (field is RegistrationSubField && field.type == 'free_response') {
      var parentField = flattenedRegistrationList
          .firstWhere((element) => element.id == field.parentUid);
      if (parentField.checked == true && field.response!.text.isEmpty) {
        return 'QuestionMissing';
      }
    } else if (field is RegistrationField && field.type == 'free_response') {
      if (field.response!.text.isEmpty) {
        return 'QuestionMissing';
      }
    }
  }
  return '';
}

List<BaseRegistrationField> flattenRegistrationFields(
    List<BaseRegistrationField> fields) {
  List<BaseRegistrationField> flattenedList = [];

  for (var field in fields) {
    flattenedList.add(field);
    if (field.childWidgets != null && field.childWidgets!.isNotEmpty) {
      flattenedList.addAll(flattenRegistrationFields(field.childWidgets!));
    }
  }

  return flattenedList;
}
