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

  static final Map<String, Set<String>> _normalizedScreenPermissions =
      _initializeScreenPermissions();

  static Map<String, Set<String>> _initializeScreenPermissions() {
    return Map.fromEntries(
      _screenPermissions.entries.map((entry) => MapEntry(
            entry.key,
            entry.value.map((p) => p.toLowerCase()).toSet(),
          )),
    );
  }

  bool canUserAccessScreen(String screenKey, AppUser user) {
    // Fast path for admin
    if (user.hasPermission('admin')) return true;

    final requiredPermissions = _normalizedScreenPermissions[screenKey];
    if (requiredPermissions == null) return false;

    // Single set intersection check
    return user.normalizedPermissions
        .intersection(requiredPermissions)
        .isNotEmpty;
  }
}
