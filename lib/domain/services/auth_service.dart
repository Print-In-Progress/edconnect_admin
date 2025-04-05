import 'package:edconnect_admin/domain/usecases/auth/sign_in_usecase.dart';

import '../usecases/auth/sign_up_usecase.dart';
import '../../domain/entities/registration_request.dart';

class AuthService {
  final SignUpUseCase _signUpUseCase;
  final SignInUseCase _signInUseCase;

  AuthService(this._signUpUseCase, this._signInUseCase);

  Future<void> signUp(RegistrationRequest request) async {
    return await _signUpUseCase.signUp(request);
  }

  Future<void> signUpWithExistingAuthAccount(
      RegistrationRequest request) async {
    return await _signUpUseCase.signUpWithExistingAuthAccount(request);
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    await _signInUseCase.execute(email, password);
  }
}
