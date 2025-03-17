import 'package:edconnect_admin/domain/entities/permissions.dart';

class PermissionService {
  /// Check if user has a specific permission
  bool hasPermission(String permissionId, List<String> userPermissions) {
    // Admin has all permissions
    if (userPermissions.contains(Permissions.admin.id)) {
      return true;
    }

    return userPermissions.contains(permissionId);
  }

  /// Check if user has any of the required permissions
  bool hasAnyPermission(
      List<String> requiredPermissions, List<String> userPermissions) {
    // Admin has all permissions
    if (userPermissions.contains(Permissions.admin.id)) {
      return true;
    }

    return requiredPermissions
        .any((permission) => userPermissions.contains(permission));
  }

  /// Check if user has the admin permission
  bool isAdmin(List<String> userPermissions) {
    return userPermissions.contains(Permissions.admin.id);
  }
}
