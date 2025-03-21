import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/interfaces/navigation_repository.dart';
import '../../data/repositories/navigation_repository_impl.dart';
import '../../domain/entities/navigation_item.dart';
import '../../domain/services/permission_service.dart';
import 'auth_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Create a singleton repository for better performance
final _navigationRepository = NavigationRepositoryImpl();

// Repository provider using the singleton
final navigationRepositoryProvider = Provider<NavigationRepository>((ref) {
  return _navigationRepository;
});

// Permission service provider
final permissionServiceProvider = Provider<PermissionService>((ref) {
  return PermissionService();
});

// Combined navigation state notifier for better performance
class NavigationStateNotifier extends StateNotifier<_NavigationState> {
  final Ref _ref;

  NavigationStateNotifier(this._ref) : super(_initialState(_ref)) {
    // Only rebuild when permissions change
    _ref.listen(
        authStateProvider.select((state) => state.valueOrNull?.permissions),
        (prev, next) {
      if (prev != next) _updateState();
    });
  }

  static _NavigationState _initialState(Ref ref) {
    // Get user permissions
    final userPermissions =
        ref.read(authStateProvider).valueOrNull?.permissions ?? [];

    // Get all items
    final allItems = _navigationRepository.getNavigationItems();

    // Filter available items
    final availableItems = allItems
        .where((item) => _navigationRepository.checkAccess(
            item.requiredPermissionIds, userPermissions))
        .toList();

    // Default selection
    final selectedId = availableItems.isNotEmpty ? availableItems.first.id : '';
    final selectedIndex =
        availableItems.indexWhere((item) => item.id == selectedId);

    // Get destinations
    final destinations = availableItems
        .map((item) => NavigationRailDestination(
              icon: Icon(item.icon),
              selectedIcon: Icon(item.selectedIcon),
              label: Builder(
                builder: (context) => Text(
                  _getLocalizedLabel(context, item.titleKey),
                ),
              ),
            ))
        .toList();

    // Get screen
    final currentScreen = selectedId.isNotEmpty
        ? _navigationRepository.getScreenForNavigationItem(
            selectedId, userPermissions)
        : const SizedBox.shrink();
    return _NavigationState(
      allItems: allItems,
      availableItems: availableItems,
      selectedId: selectedId,
      selectedIndex: selectedIndex >= 0 ? selectedIndex : 0,
      destinations: destinations,
      currentScreen: currentScreen,
    );
  }

  void _updateState() {
    final userPermissions = _ref.watch(
        authStateProvider.select((s) => s.valueOrNull?.permissions ?? []));
    final allItems = state.allItems;

    // Filter available items
    final availableItems = allItems
        .where((item) => _navigationRepository.checkAccess(
            item.requiredPermissionIds, userPermissions))
        .toList();

    // Preserve selection if possible
    final selectedId = availableItems.any((item) => item.id == state.selectedId)
        ? state.selectedId
        : (availableItems.isNotEmpty ? availableItems.first.id : '');

    final selectedIndex =
        availableItems.indexWhere((item) => item.id == selectedId);

    // Get destinations
    final destinations = availableItems
        .map((item) => NavigationRailDestination(
              icon: Icon(item.icon),
              selectedIcon: Icon(item.selectedIcon),
              label: Text(item.titleKey),
            ))
        .toList();

    // Get screen
    final currentScreen = selectedId.isNotEmpty
        ? _navigationRepository.getScreenForNavigationItem(
            selectedId, userPermissions)
        : const SizedBox.shrink();

    state = _NavigationState(
      allItems: allItems,
      availableItems: availableItems,
      selectedId: selectedId,
      selectedIndex: selectedIndex >= 0 ? selectedIndex : 0,
      destinations: destinations,
      currentScreen: currentScreen,
    );
  }

  void selectItem(int index) {
    if (index < 0 || index >= state.availableItems.length) return;

    final newId = state.availableItems[index].id;
    if (newId == state.selectedId) return;

    final userPermissions =
        _ref.read(authStateProvider).valueOrNull?.permissions ?? [];
    final screen = _navigationRepository.getScreenForNavigationItem(
        newId, userPermissions);

    state = state.copyWith(
      selectedId: newId,
      selectedIndex: index,
      currentScreen: screen,
    );
  }
}

// Navigation state class
class _NavigationState {
  final List<NavigationItem> allItems;
  final List<NavigationItem> availableItems;
  final String selectedId;
  final int selectedIndex;
  final List<NavigationRailDestination> destinations;
  final Widget currentScreen;

  _NavigationState({
    required this.allItems,
    required this.availableItems,
    required this.selectedId,
    required this.selectedIndex,
    required this.destinations,
    required this.currentScreen,
  });

  _NavigationState copyWith({
    List<NavigationItem>? allItems,
    List<NavigationItem>? availableItems,
    String? selectedId,
    int? selectedIndex,
    List<NavigationRailDestination>? destinations,
    Widget? currentScreen,
  }) {
    return _NavigationState(
      allItems: allItems ?? this.allItems,
      availableItems: availableItems ?? this.availableItems,
      selectedId: selectedId ?? this.selectedId,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      destinations: destinations ?? this.destinations,
      currentScreen: currentScreen ?? this.currentScreen,
    );
  }
}

// Main navigation state provider
final navigationStateProvider =
    StateNotifierProvider<NavigationStateNotifier, _NavigationState>((ref) {
  return NavigationStateNotifier(ref);
});

/// Helper function to translate keys
String _getLocalizedLabel(BuildContext context, String titleKey) {
  final l10n = AppLocalizations.of(context)!;
  switch (titleKey) {
    case 'homePageManageArticlesAdminMenuButton':
      return l10n.homePageManageArticlesAdminMenuButton;
    case 'homePageManageEventsAdminMenuButton':
      return l10n.homePageManageEventsAdminMenuButton;
    case 'homePageManageManageUsersAdminMenuButton':
      return l10n.homePageManageManageUsersAdminMenuButton;
    case 'surveysPagesNavbarButtonLabel':
      return l10n.surveysPagesNavbarButtonLabel;
    case 'homePageSorterButtonLabel':
      return l10n.homePageSorterButtonLabel;
    case 'homePagedigitalLibraryButtonLabel':
      return l10n.homePagedigitalLibraryButtonLabel;
    case 'homePageSavedMediaAdminMenuButton':
      return l10n.homePageSavedMediaAdminMenuButton;
    case 'homePageSendPushNotificationsAdminMenuButton':
      return l10n.homePageSendPushNotificationsAdminMenuButton;
    case 'homePageAdminSettingsButtonLabel':
      return l10n.homePageAdminSettingsButtonLabel;
    case 'homePageDashboardAdminMenuButton':
      return l10n.homePageDashboardAdminMenuButton;
    default:
      return titleKey;
  }
}
