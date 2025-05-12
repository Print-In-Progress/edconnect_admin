import 'package:edconnect_admin/core/errors/domain_exception.dart';
import 'package:edconnect_admin/core/errors/error_handler.dart';
import 'package:edconnect_admin/core/interfaces/group_repository.dart';
import 'package:edconnect_admin/data/datasource/group_data_source.dart';
import 'package:edconnect_admin/domain/entities/group.dart';

class FirebaseGroupRepositoryImpl implements GroupRepository {
  final GroupDataSource _dataSource;

  FirebaseGroupRepositoryImpl(this._dataSource);

  @override
  Stream<List<Group>> groupsStream() {
    try {
      return _dataSource.watchGroups().map((dataList) {
        return dataList.map((data) {
          return Group.fromJson(data, data['id'] as String);
        }).toList();
      });
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<List<Group>> getAllGroups() async {
    try {
      final dataList = await _dataSource.getGroups();
      return dataList.map((data) {
        return Group.fromJson(data, data['id'] as String);
      }).toList();
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
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
    try {
      final data = await _dataSource.getGroup(groupId);
      if (data == null) {
        throw const DomainException(
          code: ErrorCode.groupNotFound,
          type: ExceptionType.database,
        );
      }
      return Group.fromJson(data, data['id'] as String);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<String> createGroup(
      String name, List<String> permissions, List<String> memberIds) async {
    try {
      return await _dataSource.createGroup({
        'name': name,
        'permissions': permissions,
        'member_ids': memberIds,
      });
    } catch (e) {
      throw DomainException(
        code: ErrorCode.groupCreateFailed,
        type: ExceptionType.database,
        originalError: e,
      );
    }
  }

  @override
  Future<void> updateGroup(Group group) async {
    try {
      await _dataSource.updateGroup(group.id, group.toJson());
    } catch (e) {
      throw DomainException(
        code: ErrorCode.groupUpdateFailed,
        type: ExceptionType.database,
        originalError: e,
      );
    }
  }

  @override
  Future<void> deleteGroup(String groupId) async {
    try {
      await _dataSource.deleteGroup(groupId);
    } catch (e) {
      throw DomainException(
        code: ErrorCode.groupDeleteFailed,
        type: ExceptionType.database,
        originalError: e,
      );
    }
  }

  @override
  Future<void> addUserToGroup(String userId, String groupId) async {
    try {
      await _dataSource.addUserToGroup(userId, groupId);
    } catch (e) {
      throw DomainException(
        code: ErrorCode.invalidGroupOperation,
        type: ExceptionType.database,
        originalError: e,
      );
    }
  }

  @override
  Future<void> removeUserFromGroup(String userId, String groupId) async {
    try {
      await _dataSource.removeUserFromGroup(userId, groupId);
    } catch (e) {
      throw DomainException(
        code: ErrorCode.invalidGroupOperation,
        type: ExceptionType.database,
        originalError: e,
      );
    }
  }

  @override
  Future<void> updateUserGroups(String userId, List<String> newGroupIds) async {
    try {
      final currentGroups = await _dataSource.getUserGroups(userId);

      final groupsToAdd = newGroupIds
          .where((groupId) => !currentGroups.contains(groupId))
          .toList();

      final groupsToRemove = currentGroups
          .where((groupId) => !newGroupIds.contains(groupId))
          .toList();

      await _dataSource.updateUserGroups(
        userId,
        newGroupIds,
        groupsToAdd,
        groupsToRemove,
      );
    } catch (e) {
      throw DomainException(
        code: ErrorCode.userGroupUpdateFailed,
        type: ExceptionType.database,
        originalError: e,
      );
    }
  }

  @override
  Future<List<Group>> getGroupsForUser(String userId) async {
    try {
      final groupIds = await _dataSource.getUserGroups(userId);
      final allGroups = await getAllGroups();
      return allGroups.where((group) => groupIds.contains(group.id)).toList();
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }
}
