abstract class GroupDataSource {
  // Watch all groups
  Stream<List<Map<String, dynamic>>> watchGroups();

  // Get all groups
  Future<List<Map<String, dynamic>>> getGroups();

  // Watch a specific group
  Stream<Map<String, dynamic>?> watchGroup(String groupId);

  // Get a specific group
  Future<Map<String, dynamic>?> getGroup(String groupId);

  // Create a new group
  Future<String> createGroup(Map<String, dynamic> groupData);

  // Update a group
  Future<void> updateGroup(String groupId, Map<String, dynamic> groupData);

  // Delete a group
  Future<void> deleteGroup(String groupId);

  // Get user's groups
  Future<List<String>> getUserGroups(String userId);

  // Add user to group
  Future<void> addUserToGroup(String userId, String groupId);

  // Remove user from group
  Future<void> removeUserFromGroup(String userId, String groupId);

  // Update a user's groups
  Future<void> updateUserGroups(
    String userId,
    List<String> newGroupIds,
    List<String> groupsToAdd,
    List<String> groupsToRemove,
  );
}
