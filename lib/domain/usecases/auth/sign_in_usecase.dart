import '../../../core/interfaces/auth_repository.dart';

class SignInUseCase {
  final AuthRepository _authRepository;

  SignInUseCase(this._authRepository);

  Future<void> execute(String email, String password) async {
    await _authRepository.signInWithEmailAndPassword(email, password);
  }
}
