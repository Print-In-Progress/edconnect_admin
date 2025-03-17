import '../entities/permissions.dart';

class PermissionService {
  /// Check if a user has access to a specific feature
  bool hasFeatureAccess(String featureId, List<String> userPermissions) {
    final requiredPermissions = Permissions.featurePermissionSets[featureId];
    if (requiredPermissions == null || requiredPermissions.isEmpty) {
      return false;
    }

    return requiredPermissions
        .any((permission) => userPermissions.contains(permission));
  }

  /// Check if user has a specific permission
  bool hasPermission(String permissionId, List<String> userPermissions) {
    return userPermissions.contains(permissionId);
  }

  /// Check if user has the admin permission
  bool isAdmin(List<String> userPermissions) {
    return userPermissions.contains(Permissions.admin.id);
  }

  /// Get all permissions a user can manage (needed for admin UI)
  List<Permission> getManageablePermissions(List<String> userPermissions) {
    // Only admins can manage permissions
    if (!isAdmin(userPermissions)) {
      return [];
    }

    return Permissions.allPermissions;
  }

  /// Get permissions grouped by category (for permission management UI)
  Map<PermissionCategory, List<Permission>> getPermissionsByCategory() {
    final result = <PermissionCategory, List<Permission>>{};

    for (final category in PermissionCategory.values) {
      result[category] = Permissions.getByCategory(category);
    }

    return result;
  }
}
