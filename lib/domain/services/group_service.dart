import 'package:edconnect_admin/domain/entities/group.dart';
import 'package:edconnect_admin/domain/usecases/group_management_use_case.dart';

class GroupService {
  final GroupManagementUseCase _groupManagementUseCase;

  GroupService(this._groupManagementUseCase);

  // Group streams
  Stream<List<Group>> groupsStream() {
    return _groupManagementUseCase.getGroupsStream();
  }

  Stream<Group?> groupStream(String groupId) {
    return _groupManagementUseCase.getGroupStream(groupId);
  }

  // Get groups
  Future<List<Group>> getAllGroups() {
    return _groupManagementUseCase.getAllGroups();
  }

  Future<Group?> getGroup(String groupId) {
    return _groupManagementUseCase.getGroup(groupId);
  }

  // Group CRUD operations
  Future<String> createGroup(
      String name, List<String> permissions, List<String> memberIds) {
    return _groupManagementUseCase.createGroup(name, permissions, memberIds);
  }

  Future<void> updateGroup(Group group) {
    return _groupManagementUseCase.updateGroup(group);
  }

  Future<void> deleteGroup(String groupId) {
    return _groupManagementUseCase.deleteGroup(groupId);
  }

  // User-group management
  Future<void> addUserToGroup(String userId, String groupId) {
    return _groupManagementUseCase.addUserToGroup(userId, groupId);
  }

  Future<void> removeUserFromGroup(String userId, String groupId) {
    return _groupManagementUseCase.removeUserFromGroup(userId, groupId);
  }

  Future<void> updateUserGroups(String userId, List<String> groupIds) {
    return _groupManagementUseCase.updateUserGroups(userId, groupIds);
  }

  // Get groups for a user
  Future<List<Group>> getGroupsForUser(String userId) {
    return _groupManagementUseCase.getGroupsForUser(userId);
  }
}
