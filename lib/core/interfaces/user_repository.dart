import 'package:edconnect_admin/core/models/app_user.dart';

abstract class UserRepository {
  Future<void> saveUserDetails(AppUser user, bool withSignedPdf);

  Stream<AppUser?> getCurrentUserStream(String uid);
}
