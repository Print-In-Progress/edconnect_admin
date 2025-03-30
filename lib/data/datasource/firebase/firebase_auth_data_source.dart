import 'package:firebase_auth/firebase_auth.dart';
import '../auth_data_source.dart';

class FirebaseAuthDataSource implements AuthDataSource {
  final FirebaseAuth _firebaseAuth;

  FirebaseAuthDataSource({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  @override
  Future<String> createUserWithEmailAndPassword(
      String email, String password) async {
    final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (userCredential.user == null) {
      throw Exception('Failed to create user account');
    }

    return userCredential.user!.uid;
  }

  @override
  Future<String?> signUpWithExistingAuthAccount(
      String email, String password) async {
    try {
      // Attempt to sign in with existing account
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        return 'Failed to authenticate user';
      }

      return userCredential.user!.uid;
    } on FirebaseAuthException catch (e) {
      return 'AuthError: ${e.code}';
    } catch (e) {
      return 'UnexpectedError: $e';
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    await _firebaseAuth.currentUser?.sendEmailVerification();
  }

  @override
  Future<void> reloadUser() async {
    await _firebaseAuth.currentUser?.reload();
  }

  @override
  bool get isEmailVerified => _firebaseAuth.currentUser?.emailVerified ?? false;

  @override
  Stream<String?> get authStateChanges =>
      _firebaseAuth.authStateChanges().map((user) => user?.uid);

  @override
  String? get currentUserId => _firebaseAuth.currentUser?.uid;

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  @override
  Future<String?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on Exception catch (e) {
      return 'AuthError: $e';
    } catch (e) {
      return 'UnexpectedError: $e';
    }
    return null;
  }

  @override
  Future<String?> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on Exception catch (e) {
      return 'AuthError: $e';
    } catch (e) {
      return 'UnexpectedError: $e';
    }
    return null;
  }

  @override
  Future<String?> changeEmail(String email) async {
    try {
      await _firebaseAuth.currentUser!.verifyBeforeUpdateEmail(email);
    } on Exception catch (e) {
      return 'AuthError: $e';
    } catch (e) {
      return 'UnexpectedError: $e';
    }
    return null;
  }

  @override
  Future<String?> reauthenticate(String password) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null || user.email == null) {
        return 'No authenticated user found';
      }

      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);
      return null;
    } catch (e) {
      return 'AuthError: $e';
    }
  }

  @override
  Future<String?> changePassword(String newPassword) async {
    try {
      await _firebaseAuth.currentUser?.updatePassword(newPassword);
      return null;
    } catch (e) {
      return 'AuthError: $e';
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      await _firebaseAuth.currentUser?.delete();
    } catch (e) {
      throw Exception('Failed to delete account: $e');
    }
  }
}
