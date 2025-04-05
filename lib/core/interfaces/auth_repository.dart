import '../models/app_user.dart';
import '../../domain/entities/registration_request.dart';

abstract class AuthRepository {
  /// Returns null on success or an error message on failure
  Future<void> signUp(RegistrationRequest request);

  /// sign up if user exists in Auth but not in Database (for example, if user was created in another organization)
  Future<void> signUpWithExistingAuthAccount(RegistrationRequest request);

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
  Future<void> signInWithEmailAndPassword(String email, String password);

  /// Reset password
  Future<void> resetPassword(String email);

  /// Change email
  Future<void> changeEmail(String email);

  /// Reauthenticate the current user (for sensitive operations)
  Future<void> reauthenticate(String password);

  /// Change password (requires recent authentication)
  Future<void> changePassword(String newPassword);

  /// Delete the current user's account (requires recent authentication)
  Future<void> deleteAccount();
}
