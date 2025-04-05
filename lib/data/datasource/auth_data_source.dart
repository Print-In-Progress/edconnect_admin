abstract class AuthDataSource {
  /// Create user with email and password
  /// Returns userId on success
  Future<String> createUserWithEmailAndPassword(String email, String password);

  /// Sign up to organization with existing auth account
  Future<String?> signUpWithExistingAuthAccount(String email, String password);

  /// Send verification email to current user
  Future<void> sendEmailVerification();

  /// Refresh current user data
  Future<void> reloadUser();

  /// Check if current user's email is verified
  bool get isEmailVerified;

  /// Stream of authentication state changes, emitting userId or null
  Stream<String?> get authStateChanges;

  /// Current user id if authenticated, null otherwise
  String? get currentUserId;

  /// sign out the current user
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
