import '../models/app_user.dart';
import '../../domain/entities/registration_request.dart';

abstract class AuthRepository {
  /// Returns null on success or an error message on failure
  Future<String?> signUp(RegistrationRequest request);

  /// sign up if user exists in Auth but not in Database (for example, if user was created in another organization)
  Future<String?> signUpWithExistingAuth();

  /// Send email verification to current user
  Future<void> sendEmailVerification();

  /// Check if email is verified
  Future<bool> isEmailVerified();

  /// reload auth user
  Future<void> reloadUser();

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

  /// Reauthenticate the current user (for sensitive operations)
  Future<String?> reauthenticate(String password);

  /// Change password (requires recent authentication)
  Future<String?> changePassword(String newPassword);

  /// Delete the current user's account (requires recent authentication)
  Future<void> deleteAccount();
}
