import 'package:flutter/material.dart';
import '../../core/interfaces/navigation_repository.dart';
import '../../domain/entities/navigation_item.dart';
import '../../domain/entities/permissions.dart';
import '../../presentation/pages/auth_pages/access_denied_page.dart';
import '../../presentation/pages/sample_page.dart';
import 'package:edconnect_admin/presentation/pages/sorting_module/pages/list/sorting_surveys_page.dart';

class NavigationRepositoryImpl implements NavigationRepository {
  // Cache navigation items by ID for faster lookup
  late final Map<String, NavigationItem> _navigationItemsById;

  NavigationRepositoryImpl() {
    // Build lookup map once during initialization
    _navigationItemsById = {
      for (var item in _createNavigationItems()) item.id: item
    };
  }

  // Private method for creating navigation items, only called once
  List<NavigationItem> _createNavigationItems() {
    return [
      NavigationItem(
        id: 'articles',
        titleKey: 'homePageManageArticlesAdminMenuButton',
        icon: Icons.article_outlined,
        selectedIcon: Icons.article_rounded,
        requiredPermissions: [
          Permissions.admin,
          Permissions.author,
          Permissions.editArticles,
          Permissions.createArticles,
        ],
      ),
      NavigationItem(
        id: 'events',
        titleKey: 'homePageManageEventsAdminMenuButton',
        icon: Icons.event_outlined,
        selectedIcon: Icons.event,
        requiredPermissions: [
          Permissions.admin,
          Permissions.author,
          Permissions.editEvents,
          Permissions.createEvents,
        ],
      ),
      NavigationItem(
        id: 'users',
        titleKey: 'homePageManageManageUsersAdminMenuButton',
        icon: Icons.supervisor_account_outlined,
        selectedIcon: Icons.supervisor_account,
        requiredPermissions: [Permissions.admin, Permissions.userManagement],
      ),
      NavigationItem(
        id: 'surveys',
        titleKey: 'surveysPagesNavbarButtonLabel',
        icon: Icons.checklist_outlined,
        selectedIcon: Icons.checklist_rounded,
        requiredPermissions: [
          Permissions.admin,
          Permissions.author,
          Permissions.editSurveys,
          Permissions.createSurveys,
        ],
      ),
      NavigationItem(
        id: 'survey_sorter',
        titleKey: 'homePageSorterButtonLabel',
        icon: Icons.sort_outlined,
        selectedIcon: Icons.sort,
        requiredPermissions: [
          Permissions.admin,
          Permissions.author,
          Permissions.editSurveys,
        ],
      ),
      NavigationItem(
        id: 'digital_library',
        titleKey: 'homePagedigitalLibraryButtonLabel',
        icon: Icons.my_library_books_outlined,
        selectedIcon: Icons.my_library_books,
        requiredPermissions: [Permissions.admin, Permissions.digitalLibrary],
      ),
      NavigationItem(
        id: 'media',
        titleKey: 'homePageSavedMediaAdminMenuButton',
        icon: Icons.perm_media_outlined,
        selectedIcon: Icons.perm_media,
        requiredPermissions: [
          Permissions.admin,
          Permissions.author,
          Permissions.fileManagement,
        ],
      ),
      NavigationItem(
        id: 'push_notifications',
        titleKey: 'homePageSendPushNotificationsAdminMenuButton',
        icon: Icons.notifications_active_outlined,
        selectedIcon: Icons.notifications_active,
        requiredPermissions: [
          Permissions.admin,
          Permissions.pushNotifications,
        ],
      ),
      NavigationItem(
        id: 'admin_settings',
        titleKey: 'homePageAdminSettingsButtonLabel',
        icon: Icons.admin_panel_settings_outlined,
        selectedIcon: Icons.admin_panel_settings,
        requiredPermissions: [Permissions.admin],
      ),
      NavigationItem(
        id: 'dashboard',
        titleKey: 'homePageDashboardAdminMenuButton',
        icon: Icons.dashboard_outlined,
        selectedIcon: Icons.dashboard,
        requiredPermissions: [Permissions.admin],
      ),
    ];
  }

  @override
  List<NavigationItem> getNavigationItems() {
    return _navigationItemsById.values.toList();
  }

  @override
  Widget getScreenForNavigationItem(
      String navigationItemId, List<String> userPermissions) {
    // Fast map lookup instead of list search
    final item = _navigationItemsById[navigationItemId];

    if (item == null) {
      return const SizedBox.shrink();
    }

    // Special case: if userPermissions is empty, we're still loading permissions
    // Return a loading screen instead of access denied
    if (userPermissions.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text("Loading permissions...")
          ],
        ),
      );
    }

    // Check permission
    if (!checkAccess(item.requiredPermissionIds, userPermissions)) {
      return const AccessDeniedPage();
    }

    // Return screen
    return _getScreenById(navigationItemId);
  }

  // Separate screen creation to avoid permission checks on each build
  Widget _getScreenById(String navigationItemId) {
    switch (navigationItemId) {
      case 'articles':
        return const SamplePage(title: 'Articles');
      case 'events':
        return const SamplePage(title: 'Events');
      case 'users':
        return const SamplePage(title: 'Users');
      case 'surveys':
        return const SamplePage(title: 'Surveys');
      case 'survey_sorter':
        return const SortingSurveysPage();
      case 'digital_library':
        return const SamplePage(title: 'Digital Library');
      case 'media':
        return const SamplePage(title: 'Media');
      case 'push_notifications':
        return const SamplePage(title: 'Push Notifications');
      case 'admin_settings':
        return const SamplePage(title: 'Admin Settings');
      case 'dashboard':
        return const SamplePage(title: 'Dashboard');
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  bool checkAccess(
      List<String> requiredPermissionIds, List<String> userPermissions) {
    // Admin access bypass for performance
    if (userPermissions.contains(Permissions.admin.id)) {
      return true;
    }

    // No permissions means public access
    if (requiredPermissionIds.isEmpty) {
      return true;
    }

    // Check if user has any of the required permissions
    for (final permission in requiredPermissionIds) {
      if (userPermissions.contains(permission)) {
        return true;
      }
    }
    return false;
  }

  @override
  List<Permission> getFeaturePermissions(String featureId) {
    // Direct map lookup
    return _navigationItemsById[featureId]?.requiredPermissions ?? [];
  }
}
