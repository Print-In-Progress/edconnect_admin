import 'package:edconnect_admin/core/interfaces/auth_repository.dart';

class UserCredentialsUseCase {
  final AuthRepository _authRepository;

  UserCredentialsUseCase(this._authRepository);

  Future<void> resetPassword(String email) async {
    await _authRepository.resetPassword(email);
  }

  Future<void> changeEmail(String newEmail) async {
    await _authRepository.changeEmail(newEmail);
  }

  Future<void> reauthenticate(String password) async {
    await _authRepository.reauthenticate(password);
  }

  Future<void> changePassword(String newPassword) async {
    await _authRepository.changePassword(newPassword);
  }
}
