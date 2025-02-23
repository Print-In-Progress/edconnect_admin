import 'package:edconnect_admin/components/buttons.dart';
import 'package:edconnect_admin/constants/database_constants.dart';
import 'package:edconnect_admin/models/providers/themeprovider.dart';
import 'package:edconnect_admin/models/providers/user_provider.dart';
import 'package:edconnect_admin/services/navigation_service.dart';
import 'package:edconnect_admin/services/url_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomePage extends ConsumerStatefulWidget {
  final List<String> permissions;
  const HomePage({super.key, required this.permissions});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  Widget _selectedScreen = const SizedBox.shrink();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedScreen = NavigationService.getScreen(0, widget.permissions);
  }

  void onDestinationSelected(int index) {
    setState(() {
      _selectedIndex = index;
      _selectedScreen = NavigationService.getScreen(index, widget.permissions);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider);
    final userAsync = ref.watch(currentUserProvider);
    final destinations = [
      NavigationRailDestination(
        icon: const Icon(Icons.article_outlined),
        selectedIcon: const Icon(Icons.article_rounded),
        label: Text(AppLocalizations.of(context)!
            .homePageManageArticlesAdminMenuButton),
      ),
      NavigationRailDestination(
        icon: const Icon(Icons.event_outlined),
        selectedIcon: const Icon(Icons.event),
        label: Text(
            AppLocalizations.of(context)!.homePageManageEventsAdminMenuButton),
      ),
      NavigationRailDestination(
        icon: const Icon(Icons.supervisor_account_outlined),
        selectedIcon: const Icon(Icons.supervisor_account),
        label: Text(AppLocalizations.of(context)!
            .homePageManageManageUsersAdminMenuButton),
      ),
      NavigationRailDestination(
        icon: const Icon(Icons.checklist_outlined),
        selectedIcon: const Icon(Icons.checklist_rounded),
        label:
            Text(AppLocalizations.of(context)!.surveysPagesNavbarButtonLabel),
      ),
      NavigationRailDestination(
        icon: const Icon(Icons.sort_outlined),
        selectedIcon: const Icon(Icons.sort),
        label: Text(AppLocalizations.of(context)!.homePageSorterButtonLabel),
      ),
      NavigationRailDestination(
        icon: const Icon(Icons.my_library_books_outlined),
        selectedIcon: const Icon(Icons.my_library_books),
        label: Text(
            AppLocalizations.of(context)!.homePagedigitalLibraryButtonLabel),
      ),
      NavigationRailDestination(
        icon: const Icon(Icons.perm_media_outlined),
        selectedIcon: const Icon(Icons.perm_media),
        label: Text(
            AppLocalizations.of(context)!.homePageSavedMediaAdminMenuButton),
      ),
      NavigationRailDestination(
        icon: const Icon(Icons.notifications_active_outlined),
        selectedIcon: const Icon(Icons.notifications_active),
        label: Text(AppLocalizations.of(context)!
            .homePageSendPushNotificationsAdminMenuButton),
      ),
      NavigationRailDestination(
        icon: const Icon(Icons.admin_panel_settings_outlined),
        selectedIcon: const Icon(Icons.admin_panel_settings),
        label: Text(
            AppLocalizations.of(context)!.homePageAdminSettingsButtonLabel),
      ),
      NavigationRailDestination(
        icon: const Icon(Icons.dashboard_outlined),
        selectedIcon: const Icon(Icons.dashboard),
        label: Text(
            AppLocalizations.of(context)!.homePageDashboardAdminMenuButton),
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
          child: Row(
        children: <Widget>[
          SingleChildScrollView(
            child: ConstrainedBox(
              constraints:
                  BoxConstraints(minHeight: MediaQuery.of(context).size.height),
              child: IntrinsicHeight(
                child: NavigationRail(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: onDestinationSelected,
                  trailing: Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: _buildTrailing(isDarkMode),
                  ),
                  labelType: NavigationRailLabelType.all,
                  destinations: destinations,
                ),
              ),
            ),
          ),
          Expanded(
              child: NestedScrollView(
                  floatHeaderSlivers: true,
                  headerSliverBuilder: (context, bool innerBoxIsScrolled) {
                    return [
                      SliverAppBar(
                        automaticallyImplyLeading: true,
                        floating: true,
                        snap: true,
                        forceMaterialTransparency: true,
                        actions: [
                          const PIPChangeThemeButton(),
                          userAsync.when(
                            data: (user) => user != null
                                ? AccountPopUpMenuButton(
                                    isDarkMode: isDarkMode,
                                    user: user,
                                  )
                                : const SizedBox.shrink(),
                            loading: () => const SizedBox(
                              width: 40,
                              child: Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                ),
                              ),
                            ),
                            error: (_, __) => const SizedBox.shrink(),
                          ),
                        ],
                        actionsIconTheme:
                            const IconThemeData(color: Colors.white),
                        iconTheme: const IconThemeData(color: Colors.white),
                        title: const Text(
                          '$customerName Admin Panel',
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    ];
                  },
                  // This is the main content
                  body: _selectedScreen)),
        ],
      )),
    );
  }

  Widget _buildLegalButton(bool isDarkMode) {
    return TextButton(
        onPressed: () =>
            UrlService.launchWebUrl('https://printinprogress.net/legal'),
        child: Text(
            AppLocalizations.of(context)!.homePageLegalNoticeButtonLabel,
            style: TextStyle(
                fontSize: 12,
                color: isDarkMode
                    ? const Color.fromRGBO(202, 196, 208, 1)
                    : Colors.black)));
  }

  Widget _buildBrandingImage(bool isDarkMode) {
    return ImageIcon(
      isDarkMode
          ? const AssetImage(
              'assets/pip_branding_dark_mode_verticalxxxhdpi.png')
          : const AssetImage(
              'assets/pip_branding_light_mode_verticalxxxhdpi.png'),
      size: 100,
      color: isDarkMode
          ? const Color.fromRGBO(246, 246, 246, 1)
          : const Color.fromRGBO(76, 76, 76, 1),
    );
  }

  Widget _buildTrailing(bool isDarkMode) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildLegalButton(isDarkMode),
        _buildBrandingImage(isDarkMode),
      ],
    );
  }
}
