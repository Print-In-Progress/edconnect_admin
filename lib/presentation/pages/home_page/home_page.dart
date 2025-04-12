import 'package:edconnect_admin/core/design_system/foundations.dart';
import 'package:edconnect_admin/core/models/app_theme.dart';
import 'package:edconnect_admin/presentation/providers/navigation_providers.dart';
import 'package:edconnect_admin/presentation/providers/state_providers.dart';
import 'package:edconnect_admin/presentation/providers/theme_provider.dart';
import 'package:edconnect_admin/presentation/widgets/common/buttons/toggle_theme_button.dart';
import 'package:edconnect_admin/presentation/widgets/common/navigation/app_bar.dart';
import 'package:edconnect_admin/presentation/widgets/common/navigation/navigation_sidebar.dart';
import 'package:edconnect_admin/presentation/widgets/common/popups/account_popup_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/database_constants.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeProvider);
    final navState = ref.watch(navigationProvider);
    final user = ref.watch(userWithResolvedGroupsProvider);
    final isExpanded = ref.watch(sidebarExpandedProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Row(
          children: <Widget>[
            // Collapsible sidebar
            CollapsibleSidebar(
              header: _buildSidebarHeader(context, theme, isExpanded),
              trailing:
                  _buildSidebarTrailing(context, theme.isDarkMode, isExpanded),
            ),

            // Main content area
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 50),
                child: user == null
                    ? _buildSkeletonLoader()
                    : NestedScrollView(
                        floatHeaderSlivers: true,
                        headerSliverBuilder:
                            (context, bool innerBoxIsScrolled) {
                          return [
                            BaseAppBar(
                              user: user,
                              floating: true,
                              snap: true,
                              forceMaterialTransparency: true,
                              showDivider: false,
                              foregroundColor: Foundations.colors.surface,
                              actions: [
                                const ToggleThemeButton(),
                                SizedBox(width: Foundations.spacing.xs),
                                AccountPopupMenu(user: user),
                                SizedBox(width: Foundations.spacing.sm),
                              ],
                            ).asSliverAppBar(
                              context,
                              ref,
                            ),
                          ];
                        },
                        body: navState.currentScreen,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Header for the sidebar
  Widget _buildSidebarHeader(
      BuildContext context, AppTheme theme, bool isExpanded) {
    if (isExpanded) {
      return Row(
        children: [
          Image.asset(
            theme.logoUrl.isEmpty
                ? theme.isDarkMode
                    ? 'assets/edconnect_logo.png' // Fallback to EdConnect logo
                    : 'assets/edconnect_logo.png'
                : theme.logoUrl, // Customer logo when available
            height: 40,
          ),
          SizedBox(width: Foundations.spacing.sm),
          Flexible(
            child: Text(
              customerName,
              style: TextStyle(
                fontSize: Foundations.typography.lg,
                fontWeight: Foundations.typography.bold,
                color: theme.isDarkMode
                    ? Foundations.darkColors.textPrimary
                    : Foundations.colors.textPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    } else {
      // Just the logo when collapsed
      return Image.asset(
        theme.logoUrl.isEmpty
            ? theme.isDarkMode
                ? 'assets/edconnect_logo.png'
                : 'assets/edconnect_logo.png'
            : theme.logoUrl,
        height: 32,
      );
    }
  }

  Widget _buildSidebarTrailing(
      BuildContext context, bool isDarkMode, bool isExpanded) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.all(
              isExpanded ? Foundations.spacing.sm : Foundations.spacing.xs),
          child: ImageIcon(
            isDarkMode
                ? const AssetImage(
                    'assets/pip_branding_dark_mode_verticalxxxhdpi.png')
                : const AssetImage(
                    'assets/pip_branding_light_mode_verticalxxxhdpi.png'),
            size: isExpanded ? 100 : 48, // Smaller icon when collapsed
            color: isDarkMode
                ? const Color.fromRGBO(246, 246, 246, 1)
                : const Color.fromRGBO(76, 76, 76, 1),
          ),
        ),
        if (isExpanded)
          Padding(
            padding: EdgeInsets.only(top: Foundations.spacing.xs),
            child: Text(
              "Powered by EdConnect",
              style: TextStyle(
                fontSize: Foundations.typography.xs,
                color: isDarkMode
                    ? Foundations.darkColors.textMuted
                    : Foundations.colors.textMuted,
              ),
            ),
          ),
      ],
    );
  }

  // Skeleton loader when user data is loading
  Widget _buildSkeletonLoader() {
    // Your existing skeleton loader code
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
              color: Colors.grey.withValues(alpha: 0.2),
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
                                      color: Colors.grey.withValues(alpha: 0.2),
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
                              color: Colors.grey.withValues(alpha: 0.2),
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
                    color: Colors.grey.withValues(alpha: 0.2),
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
}
