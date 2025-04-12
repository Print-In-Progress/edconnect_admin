import 'package:edconnect_admin/core/constants/database_constants.dart';
import 'package:edconnect_admin/core/design_system/foundations.dart';
import 'package:edconnect_admin/core/models/app_user.dart';
import 'package:edconnect_admin/l10n/app_localizations.dart';
import 'package:edconnect_admin/presentation/providers/theme_provider.dart';
import 'package:edconnect_admin/presentation/widgets/common/buttons/base_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BaseAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final String? title;
  final AppUser? user;
  final Color? foregroundColor;
  final List<Widget>? actions;
  final bool showLeading;
  final bool showDivider;
  final VoidCallback? onLeadingPressed;
  final Widget? customLeading;
  final PreferredSizeWidget? bottom;
  final bool floating;
  final bool snap;
  final bool pinned;
  final bool forceMaterialTransparency;

  /// Create a standard AppBar with Shadcn styling
  const BaseAppBar({
    super.key,
    this.title,
    this.user,
    this.foregroundColor,
    this.actions,
    this.showLeading = false,
    this.showDivider = true,
    this.onLeadingPressed,
    this.customLeading,
    this.bottom,
    this.floating = false,
    this.snap = false,
    this.pinned = false,
    this.forceMaterialTransparency = false,
  });

  /// Create a SliverAppBar version with the same styling
  SliverAppBar asSliverAppBar(BuildContext context, WidgetRef ref) {
    // Don't include actions in the appBarContent
    final appBarContent =
        _buildAppBarContent(context, ref, includeActions: false);

    return SliverAppBar(
      floating: floating,
      snap: snap,
      pinned: pinned,
      forceMaterialTransparency: forceMaterialTransparency,
      backgroundColor: ref.watch(appThemeProvider).isDarkMode
          ? Foundations.darkColors.surface
          : Foundations.colors.surface,
      automaticallyImplyLeading: showLeading,
      leading: showLeading ? customLeading : null,
      title: appBarContent,
      actions: actions, // This will render the actions once
      bottom: bottom,
      foregroundColor: foregroundColor ??
          (ref.watch(appThemeProvider).isDarkMode
              ? Foundations.darkColors.textPrimary
              : Foundations.colors.textPrimary),
      elevation: 0,
      flexibleSpace: showDivider
          ? FlexibleSpaceBar(
              background: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 1,
                  color: ref.watch(appThemeProvider).isDarkMode
                      ? Foundations.darkColors.border
                      : Foundations.colors.border,
                ),
              ),
            )
          : null,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeProvider);
    final isDarkMode = theme.isDarkMode;

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode
            ? Foundations.darkColors.surface
            : Foundations.colors.surface,
        boxShadow: isDarkMode ? null : Foundations.effects.shadowSm,
        border: showDivider
            ? Border(
                bottom: BorderSide(
                  color: isDarkMode
                      ? Foundations.darkColors.border
                      : Foundations.colors.border,
                  width: Foundations.borders.thin,
                ),
              )
            : null,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: Foundations.spacing.xl,
        vertical: Foundations.spacing.sm,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildAppBarContent(context, ref),

          // Optional bottom widget (tabs, etc.)
          if (bottom != null)
            Padding(
              padding: EdgeInsets.only(top: Foundations.spacing.sm),
              child: bottom!,
            ),
        ],
      ),
    );
  }

  Widget _buildAppBarContent(BuildContext context, WidgetRef ref,
      {bool includeActions = true}) {
    final theme = ref.watch(appThemeProvider);
    final isDarkMode = theme.isDarkMode;
    final l10n = AppLocalizations.of(context)!;

    // Retrieve screen width for responsive design
    final screenWidth = MediaQuery.of(context).size.width;
    final isNarrowScreen = screenWidth < 600;

    // Determine title to display - use provided title, constant, or empty
    final effectiveTitle = title ?? '$customerName Admin Panel';

    return Row(
      children: [
        // Leading section (back button or custom widget)
        if (showLeading)
          customLeading ??
              BaseIconButton(
                icon: Icons.arrow_back,
                variant: IconButtonVariant.ghost,
                size: IconButtonSize.medium,
                color: foregroundColor ??
                    (isDarkMode
                        ? Foundations.darkColors.textPrimary
                        : Foundations.colors.textPrimary),
                onPressed:
                    onLeadingPressed ?? () => Navigator.of(context).pop(),
                tooltip: l10n.globalBack,
              ),

        // Conditional spacer after the leading widget
        if (showLeading) SizedBox(width: Foundations.spacing.md),

        // Title section
        if (!isNarrowScreen || (isNarrowScreen && !showLeading))
          Expanded(
            child: Row(
              children: [
                // Page title with optional breadcrumb styling
                Expanded(
                  child: Text(
                    effectiveTitle,
                    style: TextStyle(
                      fontSize: isNarrowScreen
                          ? Foundations.typography.base
                          : Foundations.typography.lg,
                      fontWeight: Foundations.typography.semibold,
                      color: foregroundColor ??
                          (isDarkMode
                              ? Foundations.darkColors.textPrimary
                              : Foundations.colors.textPrimary),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

        // Actions section - only include if requested
        if (includeActions)
          Expanded(
            flex: isNarrowScreen ? 2 : 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: actions ?? [],
            ),
          ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(bottom != null ? 100 : 60);
}
