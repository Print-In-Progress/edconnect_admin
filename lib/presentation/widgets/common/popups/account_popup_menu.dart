import 'package:edconnect_admin/core/design_system/foundations.dart';
import 'package:edconnect_admin/core/models/app_theme.dart';
import 'package:edconnect_admin/core/models/app_user.dart';
import 'package:edconnect_admin/domain/services/url_service.dart';
import 'package:edconnect_admin/l10n/app_localizations.dart';
import 'package:edconnect_admin/presentation/pages/settings_pages/settings_main_page.dart';
import 'package:edconnect_admin/presentation/providers/action_providers.dart';
import 'package:edconnect_admin/presentation/providers/theme_provider.dart';
import 'package:edconnect_admin/presentation/widgets/common/buttons/base_button.dart';
import 'package:edconnect_admin/presentation/widgets/common/buttons/base_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AccountPopupMenu extends ConsumerWidget {
  final AppUser user;

  const AccountPopupMenu({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeProvider);
    final isDarkMode = theme.isDarkMode;
    final l10n = AppLocalizations.of(context)!;

    return BaseIconButton(
      icon: Icons.account_circle_outlined,
      variant: IconButtonVariant.ghost,
      color: Colors.white,
      size: IconButtonSize.large,
      tooltip: l10n.settingsManageAccount,
      onPressed: () {
        // Store the button position to show menu at the right place
        final RenderBox button = context.findRenderObject() as RenderBox;
        final RenderBox overlay = Navigator.of(context)
            .overlay!
            .context
            .findRenderObject() as RenderBox;
        final RelativeRect position = RelativeRect.fromRect(
          Rect.fromPoints(
            button.localToGlobal(Offset(0, button.size.height + 8),
                ancestor: overlay),
            button.localToGlobal(button.size.bottomRight(Offset.zero),
                ancestor: overlay),
          ),
          Offset.zero & overlay.size,
        );

        // Show custom popup without PopupMenuItem's splash effect
        _showCustomPopup(
          context: context,
          position: position,
          isDarkMode: isDarkMode,
          theme: theme,
          user: user,
          ref: ref,
          l10n: l10n,
        );
      },
    );
  }

  void _showCustomPopup({
    required BuildContext context,
    required RelativeRect position,
    required bool isDarkMode,
    required AppTheme theme,
    required AppUser user,
    required WidgetRef ref,
    required AppLocalizations l10n,
  }) {
    // The key is to use a custom route with a transparent popup menu
    Navigator.of(context).push(
      _CustomPopupRoute(
        position: position,
        barrierColor: Colors.transparent,
        builder: (context) {
          return Material(
            type: MaterialType.transparency,
            child: Stack(
              children: [
                // Invisible full-screen barrier to handle taps outside
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      color: Colors.transparent,
                    ),
                  ),
                ),

                // Positioned menu content
                Positioned(
                  top: position.top,
                  right: position.right,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    width: 280,
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? Foundations.darkColors.surface
                          : Foundations.colors.surface,
                      borderRadius: Foundations.borders.lg,
                      border: Border.all(
                        color: isDarkMode
                            ? Foundations.darkColors.border
                            : Foundations.colors.border,
                        width: Foundations.borders.thin,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          spreadRadius: 0,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(Foundations.spacing.xl),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Header with greeting and close button
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                l10n.globalGreetingOne(user.firstName),
                                style: TextStyle(
                                  color: isDarkMode
                                      ? Foundations.darkColors.textPrimary
                                      : Foundations.colors.textPrimary,
                                  fontSize: Foundations.typography.lg,
                                  fontWeight: Foundations.typography.semibold,
                                ),
                              ),
                              BaseIconButton(
                                icon: Icons.close,
                                onPressed: () => Navigator.of(context).pop(),
                                size: IconButtonSize.small,
                              ),
                            ],
                          ),
                          SizedBox(height: Foundations.spacing.md),
                          // User info
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: theme.primaryColor,
                                foregroundColor: Colors.white,
                                child: Text(
                                  '${user.firstName[0]}${user.lastName[0]}',
                                  style: TextStyle(
                                    fontSize: Foundations.typography.lg,
                                    fontWeight: Foundations.typography.bold,
                                  ),
                                ),
                              ),
                              SizedBox(width: Foundations.spacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${user.firstName} ${user.lastName}',
                                      style: TextStyle(
                                        fontSize: Foundations.typography.base,
                                        fontWeight:
                                            Foundations.typography.medium,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Tooltip(
                                      message: user.email,
                                      textStyle: TextStyle(
                                        color: isDarkMode
                                            ? Foundations.darkColors.textPrimary
                                            : Foundations.colors.textPrimary,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isDarkMode
                                            ? Foundations
                                                .darkColors.backgroundMuted
                                            : Foundations
                                                .colors.backgroundMuted,
                                        borderRadius: Foundations.borders.md,
                                      ),
                                      child: Text(
                                        user.email,
                                        style: TextStyle(
                                          fontSize: Foundations.typography.sm,
                                          color: isDarkMode
                                              ? Foundations.darkColors.textMuted
                                              : Foundations.colors.textMuted,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: Foundations.spacing.sm),
                          // First divider
                          Divider(
                            height: 1,
                            thickness: 1,
                            color: isDarkMode
                                ? Foundations.darkColors.border
                                : Foundations.colors.border,
                          ),
                          SizedBox(height: Foundations.spacing.sm),
                          // Settings button
                          BaseButton(
                            label: l10n.settingsLabel,
                            variant: ButtonVariant.text,
                            fullWidth: true,
                            prefixIcon: Icons.settings,
                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => const AccountOverview(),
                              ));
                            },
                          ),
                          SizedBox(height: Foundations.spacing.sm),
                          // Second divider
                          Divider(
                            height: 1,
                            thickness: 1,
                            color: isDarkMode
                                ? Foundations.darkColors.border
                                : Foundations.colors.border,
                          ),
                          SizedBox(height: Foundations.spacing.sm),
                          // Logout button
                          BaseButton(
                            label: l10n.globalLogout,
                            prefixIcon: Icons.logout,
                            fullWidth: true,
                            foregroundColor: Foundations.colors.error,
                            variant: ButtonVariant.text,
                            onPressed: () async {
                              Navigator.of(context).pop();
                              await ref
                                  .read(signOutStateProvider.notifier)
                                  .signOut();
                            },
                          ),
                          SizedBox(height: Foundations.spacing.sm),
                          // Footer with privacy links
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              BaseButton(
                                label: l10n.privacyPolicyLinkText,
                                variant: ButtonVariant.text,
                                size: ButtonSize.small,
                                onPressed: () {
                                  UrlService.launchWebUrl(
                                      'https://printinprogress.net/privacy');
                                },
                              ),
                              Text(
                                ' • ',
                                style: TextStyle(
                                  fontSize: Foundations.typography.xs,
                                ),
                              ),
                              BaseButton(
                                label: l10n.globalToS,
                                variant: ButtonVariant.text,
                                size: ButtonSize.small,
                                onPressed: () {
                                  UrlService.launchWebUrl(
                                      'https://printinprogress.net/terms');
                                },
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Custom route for popup menu that appears at a specific position
class _CustomPopupRoute<T> extends PopupRoute<T> {
  final WidgetBuilder builder;
  final RelativeRect position;
  @override
  final Color barrierColor;

  _CustomPopupRoute({
    required this.builder,
    required this.position,
    required this.barrierColor,
    super.settings,
  });

  @override
  bool get barrierDismissible => true;

  @override
  String? get barrierLabel => null;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 250);

  @override
  Animation<double> createAnimation() {
    return CurvedAnimation(
      parent: super.createAnimation(),
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    // Scale animation from button position (starts small from top right and grows)
    final scaleAnimation = Tween<double>(begin: 0.5, end: 1.0)
        .chain(CurveTween(curve: Curves.easeOutCubic))
        .animate(animation);

    // Origin point based animation (animates from top-right corner)
    final originAnimation =
        Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero)
            .chain(CurveTween(curve: Curves.easeOutCubic))
            .animate(animation);

    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: scaleAnimation,
        alignment: const Alignment(0.9, -0.9), // Top right alignment for origin
        child: SlideTransition(
          position: originAnimation,
          child: builder(context),
        ),
      ),
    );
  }
}
