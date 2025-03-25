import 'package:edconnect_admin/core/interfaces/group_repository.dart';
import 'package:edconnect_admin/data/datasource/group_data_source.dart';
import 'package:edconnect_admin/domain/entities/group.dart';

class FirebaseGroupRepositoryImpl implements GroupRepository {
  final GroupDataSource _dataSource;

  FirebaseGroupRepositoryImpl(this._dataSource);

  @override
  Stream<List<Group>> groupsStream() {
    return _dataSource.watchGroups().map((dataList) {
      return dataList.map((data) {
        return Group.fromJson(data, data['id'] as String);
      }).toList();
    });
  }

  @override
  Future<List<Group>> getAllGroups() async {
    final dataList = await _dataSource.getGroups();
    return dataList.map((data) {
      return Group.fromJson(data, data['id'] as String);
    }).toList();
  }

  @override
  Stream<Group?> groupStream(String groupId) {
    return _dataSource.watchGroup(groupId).map((data) {
      if (data == null) return null;
      return Group.fromJson(data, data['id'] as String);
    });
  }

  @override
  Future<Group?> getGroup(String groupId) async {
    final data = await _dataSource.getGroup(groupId);
    if (data == null) return null;
    return Group.fromJson(data, data['id'] as String);
  }

  @override
  Future<String> createGroup(String name, List<String> permissions) async {
    return await _dataSource.createGroup({
      'name': name,
      'permissions': permissions,
      'member_ids': [],
    });
  }

  @override
  Future<void> updateGroup(Group group) async {
    await _dataSource.updateGroup(group.id, group.toJson());
  }

  @override
  Future<void> deleteGroup(String groupId) async {
    await _dataSource.deleteGroup(groupId);
  }

  @override
  Future<void> addUserToGroup(String userId, String groupId) async {
    await _dataSource.addUserToGroup(userId, groupId);
  }

  @override
  Future<void> removeUserFromGroup(String userId, String groupId) async {
    await _dataSource.removeUserFromGroup(userId, groupId);
  }

  @override
  Future<void> updateUserGroups(String userId, List<String> newGroupIds) async {
    try {
      // Get user's current groups
      final currentGroups = await _dataSource.getUserGroups(userId);

      // Calculate groups to add and remove
      final groupsToAdd = newGroupIds
          .where((groupId) => !currentGroups.contains(groupId))
          .toList();

      final groupsToRemove = currentGroups
          .where((groupId) => !newGroupIds.contains(groupId))
          .toList();

      // Perform the update in a single batch operation
      await _dataSource.updateUserGroups(
        userId,
        newGroupIds,
        groupsToAdd,
        groupsToRemove,
      );
    } catch (e) {
      throw Exception('Failed to update user groups: $e');
    }
  }

  @override
  Future<List<Group>> getGroupsForUser(String userId) async {
    // Get user's group IDs
    final groupIds = await _dataSource.getUserGroups(userId);

    // Get all groups
    final allGroups = await getAllGroups();

    // Filter to only include the user's groups
    return allGroups.where((group) => groupIds.contains(group.id)).toList();
  }
}
