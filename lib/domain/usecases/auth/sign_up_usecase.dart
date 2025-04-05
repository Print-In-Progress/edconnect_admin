import '../../entities/registration_request.dart';
import '../../../core/interfaces/auth_repository.dart';

class SignUpUseCase {
  final AuthRepository _authRepository;

  SignUpUseCase(this._authRepository);

  Future<void> signUp(RegistrationRequest request) async {
    return await _authRepository.signUp(request);
  }

  Future<void> signUpWithExistingAuthAccount(
      RegistrationRequest request) async {
    return await _authRepository.signUpWithExistingAuthAccount(request);
  }
}
