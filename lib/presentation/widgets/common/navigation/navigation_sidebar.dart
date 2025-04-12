import 'package:edconnect_admin/core/design_system/foundations.dart';
import 'package:edconnect_admin/l10n/app_localizations.dart';
import 'package:edconnect_admin/presentation/providers/theme_provider.dart';
import 'package:edconnect_admin/presentation/providers/navigation_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Controls whether the sidebar is expanded or collapsed
final sidebarExpandedProvider = StateProvider<bool>((ref) => true);

class CollapsibleSidebar extends ConsumerWidget {
  /// Trailing widget to display at the bottom of the sidebar
  final Widget? trailing;

  /// Custom width for the expanded sidebar
  final double expandedWidth;

  /// Custom width for the collapsed sidebar
  final double collapsedWidth;

  /// Animation duration for the collapse/expand transition
  final Duration animationDuration;

  /// Optional header widget that sits at the top of the sidebar
  final Widget? header;

  const CollapsibleSidebar({
    super.key,
    this.trailing,
    this.expandedWidth = 240.0,
    this.collapsedWidth = 72.0,
    this.animationDuration = const Duration(milliseconds: 250),
    this.header,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeProvider);
    final isDarkMode = theme.isDarkMode;
    final isExpanded = ref.watch(sidebarExpandedProvider);
    final navState = ref.watch(navigationProvider);

    return AnimatedContainer(
      duration: animationDuration,
      width: isExpanded ? expandedWidth : collapsedWidth,
      curve: Curves.easeInOutCubic,
      decoration: BoxDecoration(
        color: isDarkMode
            ? Foundations.darkColors.surface
            : Foundations.colors.surface,
        border: Border(
          right: BorderSide(
            color: isDarkMode
                ? Foundations.darkColors.border
                : Foundations.colors.border,
            width: Foundations.borders.thin,
          ),
        ),
        boxShadow: isDarkMode ? null : Foundations.effects.shadowSm,
      ),
      child: Column(
        children: [
          // Header section
          if (header != null) _buildHeader(header!, isExpanded),

          // Toggle button
          _buildToggleButton(context, ref, isExpanded, isDarkMode),

          // Navigation items
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(
                vertical: Foundations.spacing.md,
                horizontal: Foundations.spacing.sm,
              ),
              children: navState.availableItems.map((item) {
                final isSelected = item.id == navState.selectedId;
                return _buildNavItem(
                  context: context,
                  icon: item.icon,
                  selectedIcon: item.selectedIcon,
                  label: NavRailLocalizationHelper.getLocalizedNavigationTitle(
                      item.id, context),
                  isSelected: isSelected,
                  isExpanded: isExpanded,
                  isDarkMode: isDarkMode,
                  ref: ref,
                  onTap: () {
                    ref
                        .read(navigationProvider.notifier)
                        .selectItemById(item.id);
                  },
                );
              }).toList(),
            ),
          ),

          // Trailing widget (e.g., logo, profile, etc.)
          if (trailing != null)
            AnimatedContainer(
              duration: animationDuration,
              padding: EdgeInsets.all(
                  isExpanded ? Foundations.spacing.md : Foundations.spacing.sm),
              child: trailing,
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(Widget header, bool isExpanded) {
    return AnimatedContainer(
      duration: animationDuration,
      height: 64,
      padding: EdgeInsets.symmetric(
        horizontal:
            isExpanded ? Foundations.spacing.lg : Foundations.spacing.sm,
        vertical: Foundations.spacing.md,
      ),
      child: isExpanded
          ? header
          : Center(
              child: AspectRatio(
                aspectRatio: 1.0,
                child: header,
              ),
            ),
    );
  }

  Widget _buildToggleButton(
      BuildContext context, WidgetRef ref, bool isExpanded, bool isDarkMode) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Foundations.spacing.sm,
        vertical: Foundations.spacing.sm,
      ),
      child: InkWell(
        borderRadius: Foundations.borders.md,
        onTap: () {
          ref.read(sidebarExpandedProvider.notifier).state = !isExpanded;
        },
        child: Container(
          height: 40,
          padding: EdgeInsets.symmetric(horizontal: Foundations.spacing.md),
          decoration: BoxDecoration(
            borderRadius: Foundations.borders.md,
            color: isDarkMode
                ? Foundations.darkColors.backgroundSubtle.withValues(alpha: 0.2)
                : Foundations.colors.backgroundSubtle.withValues(alpha: 0.2),
          ),
          child: Row(
            // Use different alignment based on expansion state
            mainAxisAlignment: isExpanded
                ? MainAxisAlignment.spaceBetween
                : MainAxisAlignment.center,
            mainAxisSize:
                MainAxisSize.max, // This ensures the row takes full width
            children: [
              if (isExpanded)
                // Wrap the text in Flexible to allow it to shrink if needed
                Flexible(
                  child: Text(
                    AppLocalizations.of(context)!.navHideSidebar,
                    style: TextStyle(
                      fontSize: Foundations.typography.sm,
                      fontWeight: Foundations.typography.medium,
                      color: isDarkMode
                          ? Foundations.darkColors.textSecondary
                          : Foundations.colors.textSecondary,
                    ),
                    overflow:
                        TextOverflow.ellipsis, // Add ellipsis if text overflows
                  ),
                ),
              // For the icon, we want it centered when collapsed, but at the end when expanded
              Icon(
                isExpanded
                    ? Icons.chevron_left_rounded
                    : Icons.chevron_right_rounded,
                size: 20,
                color: isDarkMode
                    ? Foundations.darkColors.textSecondary
                    : Foundations.colors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required bool isSelected,
    required bool isExpanded,
    required bool isDarkMode,
    required VoidCallback onTap,
    required WidgetRef ref,
  }) {
    // Use theme primary color for selection highlight in light mode
    final appTheme = ref.watch(appThemeProvider);

    final Color backgroundColor = isSelected
        ? isDarkMode
            ? Foundations.darkColors.backgroundSubtle
            : appTheme.accentLight.withValues(
                alpha: 0.2) // Use theme accent for better visibility
        : Colors.transparent;

    final Color iconColor = isSelected
        ? isDarkMode
            ? Foundations.darkColors.textPrimary
            : appTheme
                .primaryColor // Use theme primary color for selected icon in light mode
        : isDarkMode
            ? Foundations.darkColors.textMuted
            : Foundations.colors.textMuted;

    final Color textColor = isSelected
        ? isDarkMode
            ? Foundations.darkColors.textPrimary
            : appTheme
                .primaryColor // Use theme primary color for selected text in light mode
        : isDarkMode
            ? Foundations.darkColors.textMuted
            : Foundations.colors.textMuted;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Material(
        color: Colors.transparent,
        borderRadius: Foundations.borders.md,
        child: InkWell(
          borderRadius: Foundations.borders.md,
          onTap: onTap,
          hoverColor: isDarkMode
              ? Foundations.darkColors.backgroundSubtle.withValues(alpha: 0.3)
              : appTheme.accentLight.withValues(alpha: 0.1),
          splashColor: isDarkMode
              ? Foundations.darkColors.backgroundSubtle.withValues(alpha: 0.5)
              : appTheme.accentLight.withValues(alpha: 0.2),
          child: AnimatedContainer(
            duration: animationDuration,
            height: 40,
            padding: EdgeInsets.symmetric(
              horizontal: isExpanded ? Foundations.spacing.md : 0.0,
            ),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: Foundations.borders.md,
            ),
            child: Row(
              mainAxisAlignment: isExpanded
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.center,
              children: [
                // Icon (always visible)
                Icon(
                  isSelected ? selectedIcon : icon,
                  color: iconColor,
                  size: 20,
                ),

                // Label (only visible when expanded)
                if (isExpanded) ...[
                  SizedBox(width: Foundations.spacing.md),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: Foundations.typography.sm,
                        fontWeight: isSelected
                            ? Foundations.typography.medium
                            : Foundations.typography.regular,
                        color: textColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
