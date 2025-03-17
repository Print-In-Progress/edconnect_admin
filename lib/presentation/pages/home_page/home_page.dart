import 'package:edconnect_admin/presentation/providers/auth_provider.dart';
import 'package:edconnect_admin/presentation/providers/navigation_providers.dart';
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
    final userAsync = ref.watch(authStateProvider);

    final navState = ref.watch(navigationStateProvider);

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
                  selectedIndex: navState.selectedIndex,
                  onDestinationSelected: (index) {
                    ref
                        .read(navigationStateProvider.notifier)
                        .selectItem(index);
                  },
                  trailing: Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: _buildTrailing(context, theme.isDarkMode),
                  ),
                  labelType: NavigationRailLabelType.all,
                  destinations: navState.destinations,
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
                              isDarkMode: theme.isDarkMode,
                              user: user,
                            )
                          : const SizedBox.shrink(),
                      loading: () => const SizedBox(
                        width: 40,
                        child: Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      ),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                  ],
                  actionsIconTheme: const IconThemeData(color: Colors.white),
                  iconTheme: const IconThemeData(color: Colors.white),
                  title: const Text(
                    '$customerName Admin Panel',
                    style: TextStyle(color: Colors.white),
                  ),
                )
              ];
            },
            body: navState.currentScreen,
          )),
        ],
      )),
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
