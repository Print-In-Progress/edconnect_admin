import 'package:edconnect_admin/core/interfaces/storage_repository.dart';
import 'package:edconnect_admin/core/interfaces/user_repository.dart';
import 'package:edconnect_admin/core/models/app_user.dart';

class UserManagementUseCase {
  final UserRepository _userRepository;
  final StorageRepository _storageRepository;

  UserManagementUseCase(this._userRepository, this._storageRepository);

  Stream<List<AppUser>> getAllUsers() {
    return _userRepository.getAllUsersStream();
  }

  Future<void> deleteUser(String userId) async {
    await _userRepository.anonymizeUserData(userId);
    await _storageRepository.deleteAllUserFiles(userId);
    await _userRepository.deleteUserDocument(userId);
  }
}
