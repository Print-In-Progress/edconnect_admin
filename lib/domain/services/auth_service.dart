import 'package:edconnect_admin/domain/usecases/auth/sign_in_usecase.dart';

import '../usecases/auth/sign_up_usecase.dart';
import '../../domain/entities/registration_request.dart';

class AuthService {
  final SignUpUseCase _signUpUseCase;
  final SignInUseCase _signInUseCase;

  AuthService(this._signUpUseCase, this._signInUseCase);

  Future<String?> signUp(RegistrationRequest request) async {
    return await _signUpUseCase.execute(request);
  }

  Future<String?> signInWithEmailAndPassword(
      String email, String password) async {
    return await _signInUseCase.execute(email, password);
  }
}
