import 'package:edconnect_admin/domain/entities/group.dart';

abstract class GroupRepository {
  // Stream of all groups
  Stream<List<Group>> groupsStream();

  // Get all groups as a future
  Future<List<Group>> getAllGroups();

  // Stream of specific group
  Stream<Group?> groupStream(String groupId);

  // Get a specific group
  Future<Group?> getGroup(String groupId);

  // Create a new group
  Future<String> createGroup(String name, List<String> permissions);

  // Update a group
  Future<void> updateGroup(Group group);

  // Delete a group
  Future<void> deleteGroup(String groupId);

  // Add a user to a group
  Future<void> addUserToGroup(String userId, String groupId);

  // Remove a user from a group
  Future<void> removeUserFromGroup(String userId, String groupId);

  // Update all groups for a user (bulk operation)
  Future<void> updateUserGroups(String userId, List<String> groupIds);

  // Get groups for a specific user
  Future<List<Group>> getGroupsForUser(String userId);
}
