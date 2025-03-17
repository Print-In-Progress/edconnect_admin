import 'package:edconnect_admin/constants/screen_access.dart';
import 'package:edconnect_admin/presentation/pages/auth_pages/access_denied_page.dart';
import 'package:edconnect_admin/presentation/pages/sample_page.dart';
import 'package:flutter/material.dart';

class NavigationService {
  static const Map<int, ScreenAccess> screenMapping = {
    0: ScreenPermissions.articles,
    1: ScreenPermissions.events,
    2: ScreenPermissions.users,
    3: ScreenPermissions.surveys,
    4: ScreenPermissions.surveys,
    5: ScreenPermissions.digitalLibrary,
    6: ScreenPermissions.media,
    7: ScreenPermissions.pushNotifications,
    8: ScreenPermissions.adminSettings,
    9: ScreenPermissions.dashboard,
  };

  static Widget getScreen(int index, List<String> permissions) {
    final screen = screenMapping[index];
    if (screen == null) return const SizedBox.shrink();

    return screen.hasAccess(permissions)
        ? _buildScreenForKey(screen.screenKey, permissions)
        : const AccessDeniedPage();
  }

  // static Widget _buildScreenForKey(String screenKey, List<String> permissions) {
  //   switch (screenKey) {
  //     case 'articles':
  //       return ArticlesPage(permissions: permissions);
  //     case 'events':
  //       return EventsManagmentPage(permissions: permissions);
  //     case 'users':
  //       return const UserManagmentPage();
  //     case 'surveys':
  //       return SurveysPage(permissions: permissions);
  //     case 'digital_library':
  //       return const DigitalLibrary();
  //     case 'media':
  //       return const ManageMediaPage();
  //     case 'push_notifications':
  //       return const PushNotificationsPage();
  //     case 'admin_settings':
  //       return const AdminSettingsPage();
  //     case 'dashboard':
  //       return const DashboardPage();
  //     default:
  //       return const SizedBox.shrink();
  //   }
  // }
  static Widget _buildScreenForKey(String screenKey, List<String> permissions) {
    switch (screenKey) {
      case 'articles':
        return SamplePage();
      case 'events':
        return SamplePage();
      case 'users':
        return const SamplePage();
      case 'surveys':
        return SamplePage();
      case 'digital_library':
        return const SamplePage();
      case 'media':
        return const SamplePage();
      case 'push_notifications':
        return const SamplePage();
      case 'admin_settings':
        return const SamplePage();
      case 'dashboard':
        return const SamplePage();
      default:
        return const SizedBox.shrink();
    }
  }
}
