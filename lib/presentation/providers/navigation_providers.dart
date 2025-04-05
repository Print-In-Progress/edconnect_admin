import 'package:edconnect_admin/presentation/pages/auth_pages/access_denied_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/interfaces/navigation_repository.dart';
import '../../data/repositories/navigation_repository_impl.dart';
import '../../domain/entities/navigation_item.dart';
import '../../domain/services/permission_service.dart';
import '../providers/state_providers.dart';
import 'package:edconnect_admin/l10n/app_localizations.dart';

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
    // Listen to both user and groups data
    _ref.listen(userWithResolvedGroupsProvider, (_, next) {
      if (next != null) {
        _updateNavigation();
      }
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
      currentScreen:
          const SizedBox.shrink(), // Start with empty widget instead of loading
    );
  }

  void _updateNavigation() {
    final navigationRepository = _ref.read(navigationRepositoryProvider);
    final user = _ref.read(userWithResolvedGroupsProvider);
    final permissionService = _ref.read(permissionServiceProvider);

    if (user == null) return;

    // Get appropriate screen based on permission
    final hasPermission =
        permissionService.canUserAccessScreen(state.selectedId, user);
    final screen = hasPermission
        ? navigationRepository.getScreenForNavigationItem(
            state.selectedId, user.allPermissions)
        : const AccessDeniedPage();

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
      final hasPermission = permissionService.canUserAccessScreen(id, user);
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
      'dashboard': l10n.navDashboard,
      'articles': l10n.navArticles,
      'events': l10n.navEvents,
      'users': l10n.navUsers,
      'comments': l10n.navComments,
      'digital_library': l10n.navDigitalLibrary,
      'media': l10n.navMedia,
      'push_notifications': l10n.navPushNotifications,
      'admin_settings': l10n.navAdminSettings,
      'surveys': l10n.navSurveys,
      'survey_sorter': l10n.navSurveySorter,
    };

    return navigationTitles[id] ?? id;
  }
}
