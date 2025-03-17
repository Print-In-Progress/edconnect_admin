import '../../../core/interfaces/auth_repository.dart';

class SignInUseCase {
  final AuthRepository _authRepository;

  SignInUseCase(this._authRepository);

  Future<String?> execute(String email, String password) async {
    return await _authRepository.signInWithEmailAndPassword(email, password);
  }
}
