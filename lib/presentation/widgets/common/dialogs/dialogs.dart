import 'package:edconnect_admin/core/design_system/foundations.dart';
import 'package:edconnect_admin/l10n/app_localizations.dart';
import 'package:edconnect_admin/presentation/providers/theme_provider.dart';
import 'package:edconnect_admin/presentation/widgets/common/buttons/base_button.dart';
import 'package:edconnect_admin/presentation/widgets/common/buttons/base_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Variants for dialog appearance
enum DialogVariant {
  default_,
  danger,
  info,
  success,
  warning,
}

/// A dialog system that provides consistent dialog components
class Dialogs {
  // Singleton instance
  static final Dialogs _instance = Dialogs._internal();
  factory Dialogs() => _instance;
  Dialogs._internal();

  /// Show a basic dialog with customizable content and actions
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required Widget content,
    List<Widget>? actions,
    DialogVariant variant = DialogVariant.default_,
    bool barrierDismissible = true,
    bool showCloseIcon = true,
    bool showCancelButton = false,
    bool scrollable = false,
    double? width,
    EdgeInsets? contentPadding,
  }) async {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => _BaseDialog(
        title: title,
        content: content,
        actions: actions,
        variant: variant,
        showCloseIcon: showCloseIcon,
        showCancelButton: showCancelButton,
        scrollable: scrollable,
        width: width,
        contentPadding: contentPadding,
      ),
    );
  }

  /// Show a confirmation dialog with Yes/No options
  static Future<bool?> confirm({
    required BuildContext context,
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
    DialogVariant variant = DialogVariant.default_,
    bool barrierDismissible = true,
    bool dangerous = false,
  }) async {
    final l10n = AppLocalizations.of(context)!;

    return showDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => _BaseDialog(
        title: title,
        content: Text(message),
        variant: variant,
        scrollable: false,
        actions: [
          BaseButton(
            label: cancelText ?? l10n.globalCancel,
            variant: ButtonVariant.text,
            onPressed: () => Navigator.of(context).pop(false),
          ),
          BaseButton(
            label: confirmText ?? l10n.globalConfirm,
            variant: ButtonVariant.filled,
            backgroundColor: dangerous ? Foundations.colors.error : null,
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
  }

  /// Show an alert dialog with a single OK button
  static Future<void> alert({
    required BuildContext context,
    required String title,
    required String message,
    String? buttonText,
    DialogVariant variant = DialogVariant.default_,
    bool barrierDismissible = true,
  }) async {
    final l10n = AppLocalizations.of(context)!;

    return showDialog<void>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => _BaseDialog(
        title: title,
        content: Text(message),
        variant: variant,
        scrollable: false,
        actions: [
          BaseButton(
            label: buttonText ?? l10n.globalOk,
            variant: ButtonVariant.filled,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  /// Show a custom form dialog
  static Future<T?> form<T>({
    required BuildContext context,
    required String title,
    required Widget form,
    required List<Widget> actions,
    DialogVariant variant = DialogVariant.default_,
    bool barrierDismissible = true,
    bool showCloseIcon = true,
    bool showCancelButton = true,
    double? width,
  }) async {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => _BaseDialog(
        title: title,
        content: form,
        actions: actions,
        variant: variant,
        showCloseIcon: showCloseIcon,
        showCancelButton: showCancelButton,
        scrollable: true,
        width: width ?? 480,
        contentPadding: EdgeInsets.all(Foundations.spacing.lg),
      ),
    );
  }

  /// Show a loading dialog
  static Future<void> loading({
    required BuildContext context,
    required String message,
    bool barrierDismissible = false,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => _LoadingDialog(message: message),
    );
  }
}

class _BaseDialog extends ConsumerWidget {
  final String title;
  final Widget content;
  final List<Widget>? actions;
  final DialogVariant variant;
  final bool showCloseIcon;
  final bool showCancelButton;
  final bool scrollable;
  final double? width;
  final EdgeInsets? contentPadding;

  const _BaseDialog({
    required this.title,
    required this.content,
    this.actions,
    this.variant = DialogVariant.default_,
    this.showCloseIcon = true,
    this.showCancelButton = false,
    this.scrollable = false,
    this.width,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeProvider);
    final isDarkMode = theme.isDarkMode;
    final screenSize = MediaQuery.of(context).size;

    // Calculate dialog width based on screen size
    final double effectiveWidth =
        width ?? (screenSize.width < 600 ? screenSize.width * 0.9 : 400);

    // Get the appropriate icon for the variant
    final IconData? variantIcon = _getVariantIcon();
    final Color variantColor = _getVariantColor(isDarkMode);

    return Dialog(
      elevation: 0,
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: Foundations.spacing.lg,
        vertical: Foundations.spacing.xl2,
      ),
      child: AnimatedContainer(
        duration: Foundations.effects.shortAnimation,
        width: effectiveWidth,
        constraints: BoxConstraints(maxWidth: effectiveWidth),
        decoration: BoxDecoration(
          color: isDarkMode
              ? Foundations.darkColors.surface
              : Foundations.colors.surface,
          borderRadius: Foundations.borders.lg,
          border: Border.all(
            color: isDarkMode
                ? Foundations.darkColors.border
                : Foundations.colors.border,
            width: Foundations.borders.normal,
          ),
          boxShadow: isDarkMode ? null : Foundations.effects.shadowLg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Dialog header
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Foundations.spacing.lg,
                vertical: Foundations.spacing.md,
              ),
              child: Row(
                children: [
                  if (variantIcon != null) ...[
                    Icon(
                      variantIcon,
                      color: variantColor,
                      size: 20,
                    ),
                    SizedBox(width: Foundations.spacing.sm),
                  ],
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: Foundations.typography.lg,
                        fontWeight: Foundations.typography.semibold,
                        color: isDarkMode
                            ? Foundations.darkColors.textPrimary
                            : Foundations.colors.textPrimary,
                      ),
                    ),
                  ),
                  if (showCloseIcon)
                    BaseIconButton(
                        icon: Icons.close,
                        size: IconButtonSize.medium,
                        tooltip: 'Close',
                        onPressed: () => Navigator.of(context).pop()),
                ],
              ),
            ),

            // Divider
            Divider(
              height: 1,
              thickness: 1,
              color: isDarkMode
                  ? Foundations.darkColors.border
                  : Foundations.colors.border,
            ),

            // Dialog content
            if (scrollable)
              Flexible(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding:
                      contentPadding ?? EdgeInsets.all(Foundations.spacing.lg),
                  child: content,
                ),
              )
            else
              Padding(
                padding:
                    contentPadding ?? EdgeInsets.all(Foundations.spacing.lg),
                child: content,
              ),

            // Action buttons (if provided)
            if (actions != null && actions!.isNotEmpty || showCancelButton)
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Foundations.spacing.lg,
                  vertical: Foundations.spacing.md,
                ),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? Foundations.darkColors.backgroundSubtle
                          .withValues(alpha: 0.3)
                      : Foundations.colors.backgroundSubtle
                          .withValues(alpha: 0.3),
                  borderRadius: BorderRadius.only(
                    bottomLeft:
                        Radius.circular(Foundations.borders.lg.bottomLeft.x),
                    bottomRight:
                        Radius.circular(Foundations.borders.lg.bottomRight.x),
                  ),
                  border: Border(
                    top: BorderSide(
                      color: isDarkMode
                          ? Foundations.darkColors.border
                          : Foundations.colors.border,
                      width: Foundations.borders.thin,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (showCancelButton) ...[
                      BaseButton(
                        label: AppLocalizations.of(context)!.globalCancel,
                        variant: ButtonVariant.text,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                    if (actions != null)
                      ...actions!.map((action) {
                        final int index = actions!.indexOf(action);
                        return Padding(
                          padding: EdgeInsets.only(
                            left: index > 0 || showCancelButton
                                ? Foundations.spacing.sm
                                : 0,
                          ),
                          child: action,
                        );
                      }),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData? _getVariantIcon() {
    return switch (variant) {
      DialogVariant.default_ => null,
      DialogVariant.danger => Icons.error_outline,
      DialogVariant.info => Icons.info_outline,
      DialogVariant.success => Icons.check_circle_outline,
      DialogVariant.warning => Icons.warning_amber_outlined,
    };
  }

  Color _getVariantColor(bool isDarkMode) {
    return switch (variant) {
      DialogVariant.default_ => isDarkMode
          ? Foundations.darkColors.textPrimary
          : Foundations.colors.textPrimary,
      DialogVariant.danger => Foundations.colors.error,
      DialogVariant.info => Foundations.colors.info,
      DialogVariant.success => Foundations.colors.success,
      DialogVariant.warning => Foundations.colors.warning,
    };
  }
}

class _LoadingDialog extends StatelessWidget {
  final String message;

  const _LoadingDialog({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0,
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: Foundations.spacing.lg,
        vertical: Foundations.spacing.xl2,
      ),
      child: Container(
        padding: EdgeInsets.all(Foundations.spacing.lg),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Foundations.darkColors.surface
              : Foundations.colors.surface,
          borderRadius: Foundations.borders.lg,
          boxShadow: Theme.of(context).brightness == Brightness.dark
              ? null
              : Foundations.effects.shadowMd,
        ),
        child: IntrinsicHeight(
          child: Column(
            children: [
              const CircularProgressIndicator(),
              SizedBox(height: Foundations.spacing.lg),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: Foundations.typography.base,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Foundations.darkColors.textPrimary
                      : Foundations.colors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
