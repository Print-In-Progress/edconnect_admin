import 'package:edconnect_admin/core/interfaces/user_repository.dart';
import 'package:edconnect_admin/core/models/app_user.dart';
import 'package:edconnect_admin/domain/usecases/auth/user_credential_repository.dart';
import 'package:edconnect_admin/domain/usecases/auth/user_profile_use_case.dart';
import 'package:edconnect_admin/domain/entities/registration_fields.dart';

class UserService {
  final UserCredentialsUseCase _credentialsUseCase;
  final UserProfileDataUseCase _profileDataUseCase;
  final UserRepository _userRepository;

  UserService(
      this._credentialsUseCase, this._profileDataUseCase, this._userRepository);

  // Credential operations
  Future<void> resetPassword(String email) async {
    await _credentialsUseCase.resetPassword(email);
  }

  Future<void> changeEmail(String newEmail, String password) async {
    await _credentialsUseCase.changeEmail(newEmail);
  }

  Future<void> changeName(String uid, String firstName, String lastName) async {
    await _profileDataUseCase.changeName(uid, firstName, lastName);
  }

  Future<void> submitRegistrationUpdate(
      AppUser user, List<RegistrationField> registrationFields) async {
    await _userRepository.submitRegistrationUpdate(user, registrationFields);
  }
}
