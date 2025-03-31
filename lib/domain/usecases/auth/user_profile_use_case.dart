import 'package:edconnect_admin/core/interfaces/user_repository.dart';
import 'package:edconnect_admin/core/models/app_user.dart';
import 'package:edconnect_admin/domain/entities/registration_fields.dart';

class UserProfileDataUseCase {
  final UserRepository _userRepository;

  UserProfileDataUseCase(this._userRepository);

  Future<void> changeName(String uid, String firstName, String lastName) async {
    await _userRepository.changeName(uid, firstName, lastName);
  }

  Future<void> submitRegistrationUpdate(
      AppUser user, List<RegistrationField> registrationFields) {
    return _userRepository.submitRegistrationUpdate(user, registrationFields);
  }
}
