import 'dart:typed_data';

import 'package:edconnect_admin/core/models/app_user.dart';
import 'package:edconnect_admin/domain/entities/registration_fields.dart';

abstract class UserDataSource {
  Future<void> saveUserDetails(
    String uid,
    String firstName,
    String lastName,
    String email,
    List<String> groups,
    String accountType,
    bool isSigned, {
    String? publicKeyPem,
    Uint8List? signatureBytes,
  });

  Future<void> changeName(String uid, String firstName, String lastName);

  Future<void> submitRegistrationUpdate(
      AppUser user, List<RegistrationField> registrationFields);

  /// Anonymize user data for GDPR compliance
  Future<void> anonymizeUserData(String uid);

  /// Delete user document from database
  Future<void> deleteUserDocument(String uid);

  /// Fetch registration fields
  Future<List<BaseRegistrationField>> getRegistrationFields();
}
