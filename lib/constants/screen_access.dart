import 'package:edconnect_admin/constants/app_permissions.dart';

class ScreenAccess {
  final String screenKey;
  final List<String> requiredPermissions;

  const ScreenAccess({
    required this.screenKey,
    required this.requiredPermissions,
  });

  bool hasAccess(List<String> userPermissions) {
    return requiredPermissions
        .any((permission) => userPermissions.contains(permission));
  }
}

class ScreenPermissions {
  static const articles = ScreenAccess(
    screenKey: 'articles',
    requiredPermissions: AppPermissions.articlePermissions,
  );

  static const events = ScreenAccess(
    screenKey: 'events',
    requiredPermissions: AppPermissions.eventPermissions,
  );

  static const users = ScreenAccess(
    screenKey: 'users',
    requiredPermissions: [AppPermissions.admin, AppPermissions.userManagement],
  );

  static const surveys = ScreenAccess(
    screenKey: 'surveys',
    requiredPermissions: AppPermissions.surveyPermissions,
  );

  static const digitalLibrary = ScreenAccess(
    screenKey: 'digital_library',
    requiredPermissions: [
      AppPermissions.admin,
      AppPermissions.author,
      AppPermissions.digitalLibrary
    ],
  );

  static const media = ScreenAccess(
    screenKey: 'media',
    requiredPermissions: [
      AppPermissions.admin,
      AppPermissions.author,
      AppPermissions.fileManagement
    ],
  );

  static const pushNotifications = ScreenAccess(
    screenKey: 'push_notifications',
    requiredPermissions: [
      AppPermissions.admin,
      AppPermissions.pushNotifications
    ],
  );

  static const adminSettings = ScreenAccess(
    screenKey: 'admin_settings',
    requiredPermissions: AppPermissions.adminPermissions,
  );

  static const dashboard = ScreenAccess(
    screenKey: 'dashboard',
    requiredPermissions: AppPermissions.adminPermissions,
  );
}
