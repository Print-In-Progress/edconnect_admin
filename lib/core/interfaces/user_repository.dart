import 'package:edconnect_admin/core/models/app_user.dart';
import 'package:edconnect_admin/models/registration_fields.dart';

abstract class UserRepository {
  Future<void> saveUserDetails(AppUser user, bool withSignedPdf);

  Stream<AppUser?> getCurrentUserStream(String uid);

  /// Change the user's name
  Future<void> changeName(String uid, String firstName, String lastName);

  /// Resubmit the user's registration information
  Future<void> submitRegistrationUpdate(
      AppUser user, List<RegistrationField> registrationFields);

  /// Get a user by ID (single fetch, not a stream)
  Future<AppUser?> getUser(String userId);
}
