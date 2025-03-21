import 'package:edconnect_admin/core/interfaces/user_repository.dart';

class UserProfileDataUseCase {
  final UserRepository _userRepository;

  UserProfileDataUseCase(this._userRepository);

  Future<void> changeName(String uid, String firstName, String lastName) async {
    await _userRepository.changeName(uid, firstName, lastName);
  }
  // Future<void> resubmitRegistration(RegistrationData data) async { ... }
}
