import 'package:edconnect_admin/models/registration_fields.dart';

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
