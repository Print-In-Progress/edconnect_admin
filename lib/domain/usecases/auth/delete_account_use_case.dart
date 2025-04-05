import 'package:edconnect_admin/core/interfaces/auth_repository.dart';
import 'package:edconnect_admin/core/interfaces/user_repository.dart';
import 'package:edconnect_admin/core/interfaces/storage_repository.dart';

class DeleteAccountUseCase {
  final AuthRepository _authRepository;
  final UserRepository _userRepository;
  final StorageRepository _storageRepository;

  DeleteAccountUseCase(
    this._authRepository,
    this._userRepository,
    this._storageRepository,
  );

  Future<void> execute(String password) async {
    final user = await _authRepository.currentUserStream.first;
    if (user == null) throw Exception('No authenticated user');

    // 1.  reauthenticate
    await _authRepository.reauthenticate(password);

    // 2. Anonymize user data (GDPR requirement)
    await _userRepository.anonymizeUserData(user.id);

    // 3. Delete user files from storage
    await _storageRepository.deleteAllUserFiles(user.id);

    // 4. Delete user document
    await _userRepository.deleteUserDocument(user.id);

    // 5. Finally delete auth account
    await _authRepository.deleteAccount();
  }
}
