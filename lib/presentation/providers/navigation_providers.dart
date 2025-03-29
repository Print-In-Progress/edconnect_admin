import 'package:edconnect_admin/presentation/pages/auth_pages/access_denied_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/interfaces/navigation_repository.dart';
import '../../data/repositories/navigation_repository_impl.dart';
import '../../domain/entities/navigation_item.dart';
import '../../domain/services/permission_service.dart';
import '../providers/state_providers.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Navigation repository provider
final navigationRepositoryProvider = Provider<NavigationRepository>((ref) {
  return NavigationRepositoryImpl();
});

// Permission service provider
final permissionServiceProvider = Provider<PermissionService>((ref) {
  return PermissionService();
});

// Navigation state class
class NavigationState {
  final List<NavigationItem> availableItems;
  final String selectedId;
  final List<NavigationRailDestination> destinations;
  final Widget currentScreen;

  NavigationState({
    required this.availableItems,
    required this.selectedId,
    required this.destinations,
    required this.currentScreen,
  });

  NavigationState copyWith({
    List<NavigationItem>? availableItems,
    String? selectedId,
    List<NavigationRailDestination>? destinations,
    Widget? currentScreen,
  }) {
    return NavigationState(
      availableItems: availableItems ?? this.availableItems,
      selectedId: selectedId ?? this.selectedId,
      destinations: destinations ?? this.destinations,
      currentScreen: currentScreen ?? this.currentScreen,
    );
  }
}

class NavigationNotifier extends StateNotifier<NavigationState> {
  final Ref _ref;

  NavigationNotifier(this._ref) : super(_createInitialState()) {
    _ref.listen(currentUserProvider, (_, next) {
      next.whenData((user) {
        if (user != null) {
          _updateNavigation();
        }
      });
    });
  }

  static NavigationState _createInitialState() {
    final navigationRepository = NavigationRepositoryImpl();
    final allItems = navigationRepository.getNavigationItems();
    final initialId = allItems.isNotEmpty ? allItems.first.id : '';

    return NavigationState(
      availableItems: allItems,
      selectedId: initialId,
      destinations: allItems
          .map((item) => NavigationRailDestination(
                icon: Icon(item.icon),
                selectedIcon: Icon(item.selectedIcon),
                label: Text(item.titleKey),
              ))
          .toList(),
      // Show loading indicator as initial screen
      currentScreen: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  void _updateNavigation() {
    final navigationRepository = _ref.read(navigationRepositoryProvider);
    final user = _ref.read(userWithResolvedGroupsProvider);

    if (user == null) return;

    final screen = navigationRepository.getScreenForNavigationItem(
      state.selectedId,
      user.allPermissions,
    );

    state = state.copyWith(
      currentScreen: screen,
    );
  }

  void selectItemById(String id) {
    if (id == state.selectedId) return;

    final user = _ref.read(userWithResolvedGroupsProvider);
    final permissionService = _ref.read(permissionServiceProvider);
    final navigationRepository = _ref.read(navigationRepositoryProvider);

    if (user != null) {
      // Debug prints
      print('--- Permission Debug Info ---');
      print('Selected Navigation ID: $id');
      print('User Direct Permissions: ${user.permissions}');
      print('User Group IDs: ${user.groupIds}');
      print(
          'User Resolved Groups: ${user.groups.map((g) => "${g.name}: ${g.permissions}")}');
      print('All User Permissions: ${user.allPermissions}');

      final hasPermission = permissionService.canUserAccessScreen(id, user);
      print('Has Permission for $id: $hasPermission');
      print('-------------------------');

      final screen = hasPermission
          ? navigationRepository.getScreenForNavigationItem(
              id, user.allPermissions)
          : const AccessDeniedPage();

      state = state.copyWith(
        selectedId: id,
        currentScreen: screen,
      );
    }
  }
}

// Main navigation provider
final navigationProvider =
    StateNotifierProvider<NavigationNotifier, NavigationState>((ref) {
  return NavigationNotifier(ref);
});

class NavRailLocalizationHelper {
  static String getLocalizedNavigationTitle(String id, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final Map<String, String> navigationTitles = {
      'dashboard': l10n.homePageDashboardAdminMenuButton,
      'articles': l10n.homePageManageArticlesAdminMenuButton,
      'events': l10n.homePageManageEventsAdminMenuButton,
      'users': l10n.homePageManageManageUsersAdminMenuButton,
      'comments': l10n.homePageManageCommentsAdminMenuButton,
      'digital_library': l10n.homePagedigitalLibraryButtonLabel,
      'media': l10n.homePageSavedMediaAdminMenuButton,
      'push_notifications': l10n.homePageSendPushNotificationsAdminMenuButton,
      'admin_settings': l10n.homePageAdminSettingsButtonLabel,
      'surveys': l10n.homePageSurveyButtonLabel,
      'survey_sorter': l10n.homePageSorterButtonLabel,
    };

    return navigationTitles[id] ?? id;
  }
}
