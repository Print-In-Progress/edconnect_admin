import 'dart:typed_data';

import 'package:edconnect_admin/core/models/app_user.dart';
import 'package:edconnect_admin/models/registration_fields.dart';

abstract class UserDataSource {
  Future<void> saveUserDetails(
    String uid,
    String firstName,
    String lastName,
    String email,
    List<String> groups,
    bool isSigned, {
    String? publicKeyPem,
    Uint8List? signatureBytes,
  });

  Future<void> changeName(String uid, String firstName, String lastName);

  Future<void> submitRegistrationUpdate(
      AppUser user, List<RegistrationField> registrationFields);
}
