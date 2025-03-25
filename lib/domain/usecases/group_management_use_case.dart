import 'package:edconnect_admin/core/interfaces/group_repository.dart';
import 'package:edconnect_admin/domain/entities/group.dart';

class GroupManagementUseCase {
  final GroupRepository _groupRepository;

  GroupManagementUseCase(this._groupRepository);

  // Get streams of groups
  Stream<List<Group>> getGroupsStream() {
    return _groupRepository.groupsStream();
  }

  Stream<Group?> getGroupStream(String groupId) {
    return _groupRepository.groupStream(groupId);
  }

  // Get groups
  Future<List<Group>> getAllGroups() {
    return _groupRepository.getAllGroups();
  }

  Future<Group?> getGroup(String groupId) {
    return _groupRepository.getGroup(groupId);
  }

  // Group CRUD operations
  Future<String> createGroup(String name, List<String> permissions) {
    return _groupRepository.createGroup(name, permissions);
  }

  Future<void> updateGroup(Group group) {
    return _groupRepository.updateGroup(group);
  }

  Future<void> deleteGroup(String groupId) {
    return _groupRepository.deleteGroup(groupId);
  }

  // User-group management
  Future<void> addUserToGroup(String userId, String groupId) {
    return _groupRepository.addUserToGroup(userId, groupId);
  }

  Future<void> removeUserFromGroup(String userId, String groupId) {
    return _groupRepository.removeUserFromGroup(userId, groupId);
  }

  Future<void> updateUserGroups(String userId, List<String> groupIds) {
    return _groupRepository.updateUserGroups(userId, groupIds);
  }

  // Get groups for a user
  Future<List<Group>> getGroupsForUser(String userId) {
    return _groupRepository.getGroupsForUser(userId);
  }
}
