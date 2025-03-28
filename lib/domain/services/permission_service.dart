import 'package:edconnect_admin/core/models/app_user.dart';
import 'package:edconnect_admin/domain/entities/permissions.dart';

class PermissionService {
  // Screen permission mappings using proper Permissions class
  static final Map<String, List<String>> _screenPermissions = {
    'dashboard': [Permissions.admin.id],
    'articles': [
      Permissions.admin.id,
      Permissions.author.id,
      Permissions.createArticles.id,
      Permissions.editArticles.id
    ],
    'events': [
      Permissions.admin.id,
      Permissions.author.id,
      Permissions.createEvents.id,
      Permissions.editEvents.id
    ],
    'users': [Permissions.admin.id, Permissions.userManagement.id],
    'surveys': [
      Permissions.admin.id,
      Permissions.author.id,
      Permissions.createSurveys.id,
      Permissions.editSurveys.id
    ],
    'digital_library': [
      Permissions.admin.id,
      Permissions.author.id,
      Permissions.digitalLibrary.id
    ],
    'media': [
      Permissions.admin.id,
      Permissions.author.id,
      Permissions.fileManagement.id
    ],
    'push_notifications': [
      Permissions.admin.id,
      Permissions.pushNotifications.id
    ],
    'admin_settings': [Permissions.admin.id],
  };

  // Check if user has access to a screen
  bool canUserAccessScreen(String screenKey, AppUser user) {
    // Admin always has access to everything
    if (user.hasPermission(Permissions.admin.id)) {
      return true;
    }

    // Get required permissions for the screen
    final requiredPermissions = _screenPermissions[screenKey];
    if (requiredPermissions == null) return false;

    // Check if user has any of the required permissions
    return requiredPermissions
        .any((permission) => user.hasPermission(permission));
  }

  // Check if a list of permissions contains a specific permission
  bool hasPermission(String permissionId, List<String> userPermissions) {
    return userPermissions.contains(permissionId);
  }

  // Check if permissions list contains any of the required permissions
  bool hasAnyPermission(
      List<String> requiredPermissions, List<String> userPermissions) {
    // Admin bypass
    if (userPermissions.contains(Permissions.admin.id)) {
      return true;
    }

    // Check for any permission match
    return requiredPermissions
        .any((permission) => userPermissions.contains(permission));
  }

  // Get required permissions for a screen
  List<String> getRequiredPermissionsForScreen(String screenKey) {
    return _screenPermissions[screenKey] ?? [];
  }
}
