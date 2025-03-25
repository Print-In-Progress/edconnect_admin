abstract class AuthDataSource {
  /// Create user with email and password
  /// Returns userId on success
  Future<String> createUserWithEmailAndPassword(String email, String password);

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
  Future<String?> signInWithEmailAndPassword(String email, String password);

  /// Reset password
  Future<String?> resetPassword(String email);

  /// Change email
  Future<String?> changeEmail(String email);
}
