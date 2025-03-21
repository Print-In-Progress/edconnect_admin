import 'package:edconnect_admin/core/models/app_user.dart';

abstract class UserRepository {
  Future<void> saveUserDetails(AppUser user, bool withSignedPdf);

  Stream<AppUser?> getCurrentUserStream(String uid);

  /// Change the user's name
  Future<void> changeName(String uid, String firstName, String lastName);

  /// Resubmit the user's registration information
  // Future<void> submitRegistrationUpdate(AppUser user);
}
