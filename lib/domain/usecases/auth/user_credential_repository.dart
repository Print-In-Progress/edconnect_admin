import 'package:edconnect_admin/core/interfaces/auth_repository.dart';

class UserCredentialsUseCase {
  final AuthRepository _authRepository;

  UserCredentialsUseCase(this._authRepository);

  Future<String?> resetPassword(String email) async {
    return await _authRepository.resetPassword(email);
  }

  Future<String?> changeEmail(String newEmail) async {
    return await _authRepository.changeEmail(newEmail);
  }

  Future<String?> reauthenticate(String password) async {
    return await _authRepository.reauthenticate(password);
  }

  Future<String?> changePassword(String newPassword) async {
    return await _authRepository.changePassword(newPassword);
  }
}
