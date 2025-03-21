import '../models/app_user.dart';
import '../../domain/entities/registration_request.dart';

abstract class AuthRepository {
  /// Returns null on success or an error message on failure
  Future<String?> signUp(RegistrationRequest request);

  /// Send email verification to current user
  Future<void> sendEmailVerification();

  /// Check if email is verified
  Future<bool> isEmailVerified();

  /// Stream of current authenticated user
  Stream<AppUser?> get currentUserStream;

  /// Sign out the current user
  Future<void> signOut();

  /// Sign in with email and password
  Future<String?> signInWithEmailAndPassword(String email, String password);

  /// Reset password
  Future<String?> resetPassword(String email);

  /// Change email
  Future<String?> changeEmail(String email);
}
