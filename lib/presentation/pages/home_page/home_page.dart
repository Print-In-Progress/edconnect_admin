import 'package:edconnect_admin/presentation/providers/navigation_providers.dart';
import 'package:edconnect_admin/presentation/providers/state_providers.dart';
import 'package:edconnect_admin/presentation/providers/theme_provider.dart';
import 'package:edconnect_admin/presentation/widgets/common/buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../constants/database_constants.dart';
import '../../../../services/url_service.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeProvider);
    final navState = ref.watch(navigationProvider);
    final userState = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Row(
          children: <Widget>[
            SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height,
                ),
                child: IntrinsicHeight(
                  child: NavigationRail(
                    selectedIndex: navState.availableItems
                        .indexWhere((item) => item.id == navState.selectedId),
                    onDestinationSelected: (index) {
                      ref
                          .read(navigationProvider.notifier)
                          .selectItemById(navState.availableItems[index].id);
                    },
                    trailing: Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: _buildTrailing(context, theme.isDarkMode),
                    ),
                    labelType: NavigationRailLabelType.all,
                    destinations: navState.availableItems.map((item) {
                      final localizedTitle =
                          NavRailLocalizationHelper.getLocalizedNavigationTitle(
                              item.id, context);

                      return NavigationRailDestination(
                        icon: Icon(item.icon),
                        selectedIcon: Icon(item.selectedIcon),
                        label: Text(localizedTitle),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
            // Navigation rail - always show this

            // Main content area
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: userState.isLoading
                    ? _buildSkeletonLoader()
                    : NestedScrollView(
                        floatHeaderSlivers: true,
                        headerSliverBuilder:
                            (context, bool innerBoxIsScrolled) {
                          return [
                            SliverAppBar(
                              automaticallyImplyLeading: true,
                              floating: true,
                              snap: true,
                              forceMaterialTransparency: true,
                              actions: [
                                const PIPChangeThemeButton(),
                                // User menu (show loading placeholder if needed)
                                userState.when(
                                  data: (user) => user != null
                                      ? AccountPopUpMenuButton(
                                          isDarkMode: theme.isDarkMode,
                                          user: user,
                                        )
                                      : const SizedBox.shrink(),
                                  loading: () => const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: Column(
                                        children: [
                                          CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    Colors.white),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  error: (_, __) => IconButton(
                                    icon: const Icon(Icons.error_outline),
                                    color: Colors.red,
                                    onPressed: () =>
                                        ref.refresh(currentUserProvider),
                                  ),
                                )
                              ],
                              actionsIconTheme:
                                  const IconThemeData(color: Colors.white),
                              iconTheme:
                                  const IconThemeData(color: Colors.white),
                              title: const Text(
                                '$customerName Admin Panel',
                                style: TextStyle(color: Colors.white),
                              ),
                            )
                          ];
                        },
                        // Show skeleton loader when user data or permissions are loading
                        body: navState.currentScreen),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonLoader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header skeleton
          Container(
            width: 200,
            height: 40,
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
          ),

          // Content area skeleton
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Main content
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      // Stats row
                      Row(
                        children: List.generate(
                            3,
                            (index) => Expanded(
                                  child: Container(
                                    height: 100,
                                    margin: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                )),
                      ),

                      const SizedBox(height: 24),

                      // Content cards grid
                      Expanded(
                        child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: 6,
                          itemBuilder: (_, __) => Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Side panel skeleton
                Container(
                  width: 250,
                  margin: const EdgeInsets.only(left: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrailing(BuildContext context, bool isDarkMode) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextButton(
            onPressed: () =>
                UrlService.launchWebUrl('https://printinprogress.net/legal'),
            child: Text(
                AppLocalizations.of(context)!.homePageLegalNoticeButtonLabel,
                style: TextStyle(
                    fontSize: 12,
                    color: isDarkMode
                        ? const Color.fromRGBO(202, 196, 208, 1)
                        : Colors.black))),
        ImageIcon(
          isDarkMode
              ? const AssetImage(
                  'assets/pip_branding_dark_mode_verticalxxxhdpi.png')
              : const AssetImage(
                  'assets/pip_branding_light_mode_verticalxxxhdpi.png'),
          size: 100,
          color: isDarkMode
              ? const Color.fromRGBO(246, 246, 246, 1)
              : const Color.fromRGBO(76, 76, 76, 1),
        ),
      ],
    );
  }
}
