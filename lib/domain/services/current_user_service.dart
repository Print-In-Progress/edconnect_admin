import 'package:edconnect_admin/core/interfaces/user_repository.dart';
import 'package:edconnect_admin/core/models/app_user.dart';

class CurrentUserService {
  final UserRepository _userRepository;

  CurrentUserService(this._userRepository);

  Stream<AppUser?> getUserStream(String uid) {
    return _userRepository.getCurrentUserStream(uid);
  }
}
