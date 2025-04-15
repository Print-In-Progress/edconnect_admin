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
      automaticallyImplyLeading: false,
      leading: showLeading ? customLeading : null,
      title: appBarContent,
      actions: actions,
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
      height: preferredSize.height,
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
      child: LayoutBuilder(builder: (context, constraints) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: _buildAppBarContent(context, ref),
            ),
            if (bottom != null)
              Flexible(
                child: Padding(
                  padding: EdgeInsets.only(top: Foundations.spacing.sm),
                  child: bottom!,
                ),
              ),
          ],
        );
      }),
    );
  }

  Widget _buildAppBarContent(BuildContext context, WidgetRef ref,
      {bool includeActions = true}) {
    final theme = ref.watch(appThemeProvider);
    final isDarkMode = theme.isDarkMode;
    final l10n = AppLocalizations.of(context)!;

    final screenWidth = MediaQuery.of(context).size.width;
    final isNarrowScreen = screenWidth < 600;

    final effectiveTitle = title ?? '$customerName Admin Panel';

    return Row(
      children: [
        if (showLeading)
          customLeading ??
              BaseIconButton(
                icon: Icons.arrow_back,
                variant: IconButtonVariant.ghost,
                size: IconButtonSize.large,
                color: foregroundColor ??
                    (isDarkMode
                        ? Foundations.darkColors.textPrimary
                        : Foundations.colors.textPrimary),
                onPressed:
                    onLeadingPressed ?? () => Navigator.of(context).pop(),
                tooltip: l10n.globalBack,
              ),
        if (showLeading) SizedBox(width: Foundations.spacing.md),
        if (!isNarrowScreen || (isNarrowScreen && !showLeading))
          Expanded(
            child: Row(
              children: [
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
  Size get preferredSize {
    // Add a small buffer to the height to prevent overflow
    double baseHeight = 65; // Increased from 60 to 65
    double bottomHeight = bottom?.preferredSize.height ?? 0;
    double paddingHeight = Foundations.spacing.sm * 2;

    if (bottom != null) {
      return Size.fromHeight(baseHeight + bottomHeight + paddingHeight);
    }

    return Size.fromHeight(baseHeight);
  }
}
