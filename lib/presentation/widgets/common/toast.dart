import 'package:edconnect_admin/l10n/app_localizations.dart';
import 'package:edconnect_admin/presentation/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:edconnect_admin/core/design_system/foundations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Variants for toast notifications
enum ToastVariant { success, error, warning, info, default_ }

/// A shadcn-inspired toast notification
class Toast {
  /// The main message to display
  final String message;

  /// Optional description for additional context
  final String? description;

  /// The variant determines the color and icon
  final ToastVariant variant;

  /// Callback when the action button is pressed
  final VoidCallback? onAction;

  /// Label for the action button (defaults to "Dismiss")
  final String? actionLabel;

  /// Whether the toast can be dismissed by swiping
  final bool dismissible;

  /// How long the toast should remain visible
  final Duration duration;

  const Toast({
    required this.message,
    this.description,
    this.variant = ToastVariant.default_,
    this.onAction,
    this.actionLabel,
    this.dismissible = true,
    this.duration = const Duration(seconds: 5),
  });

  /// Create a SnackBar from this toast configuration
  SnackBar createSnackBar(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDarkMode =
        ProviderScope.containerOf(context).read(appThemeProvider).isDarkMode;

    return SnackBar(
      content: _ToastContent(
        message: message,
        description: description,
        variant: variant,
        isDarkMode: isDarkMode,
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      duration: duration,
      padding: EdgeInsets.zero,
      margin: EdgeInsets.only(
        bottom: Foundations.spacing.lg,
        right: Foundations.spacing.lg,
        left: Foundations.spacing.lg,
      ),
      behavior: SnackBarBehavior.floating,
      dismissDirection:
          dismissible ? DismissDirection.horizontal : DismissDirection.none,
      action: onAction != null
          ? SnackBarAction(
              label: actionLabel ?? l10n.globalDismiss,
              textColor: _getActionColor(isDarkMode),
              onPressed: onAction!,
            )
          : null,
    );
  }

  Color _getActionColor(bool isDarkMode) {
    return switch (variant) {
      ToastVariant.success => Foundations.colors.success,
      ToastVariant.error => Foundations.colors.error,
      ToastVariant.warning => Foundations.colors.warning,
      ToastVariant.info => Foundations.colors.info,
      ToastVariant.default_ => isDarkMode
          ? Foundations.darkColors.textPrimary
          : Foundations.colors.textPrimary,
    };
  }
}

class _ToastContent extends StatelessWidget {
  final String message;
  final String? description;
  final ToastVariant variant;
  final bool isDarkMode;

  const _ToastContent({
    required this.message,
    required this.variant,
    required this.isDarkMode,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    // Get screen width for responsive sizing
    final screenWidth = MediaQuery.of(context).size.width;

    // Calculate ideal width - use smaller value on mobile
    final toastWidth = screenWidth < 600 ? screenWidth * 0.9 : 420.0;

    return Container(
      width: toastWidth,
      padding: EdgeInsets.all(Foundations.spacing.md),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: Foundations.borders.md,
        border: Border.all(
          color: _getBorderColor(),
          width: Foundations.borders.normal,
        ),
        boxShadow: isDarkMode ? null : Foundations.effects.shadowMd,
      ),
      child: Row(
        crossAxisAlignment: description != null
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          _buildIcon(),
          SizedBox(width: Foundations.spacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message,
                  style: TextStyle(
                    fontSize: Foundations.typography.sm,
                    fontWeight: Foundations.typography.medium,
                    color: _getTextColor(),
                  ),
                ),
                if (description != null) ...[
                  SizedBox(height: Foundations.spacing.xs),
                  Text(
                    description!,
                    style: TextStyle(
                      fontSize: Foundations.typography.xs,
                      color: _getDescriptionColor(),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIcon() {
    return Icon(
      _getIcon(),
      color: _getIconColor(),
      size: 18,
    );
  }

  IconData _getIcon() {
    return switch (variant) {
      ToastVariant.success => Icons.check_circle,
      ToastVariant.error => Icons.error,
      ToastVariant.warning => Icons.warning_rounded,
      ToastVariant.info => Icons.info,
      ToastVariant.default_ => Icons.notifications,
    };
  }

  Color _getBackgroundColor() {
    return isDarkMode
        ? Foundations.darkColors.surface
        : Foundations.colors.surface;
  }

  Color _getBorderColor() {
    return isDarkMode
        ? Foundations.darkColors.border
        : Foundations.colors.border;
  }

  Color _getTextColor() {
    return isDarkMode
        ? Foundations.darkColors.textPrimary
        : Foundations.colors.textPrimary;
  }

  Color _getDescriptionColor() {
    return isDarkMode
        ? Foundations.darkColors.textSecondary
        : Foundations.colors.textSecondary;
  }

  Color _getIconColor() {
    return switch (variant) {
      ToastVariant.success => Foundations.colors.success,
      ToastVariant.error => Foundations.colors.error,
      ToastVariant.warning => Foundations.colors.warning,
      ToastVariant.info => Foundations.colors.info,
      ToastVariant.default_ => isDarkMode
          ? Foundations.darkColors.textMuted
          : Foundations.colors.textMuted,
    };
  }
}

class Toaster {
  static final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  /// Get the scaffold messenger key to use in your MaterialApp
  static GlobalKey<ScaffoldMessengerState> get scaffoldMessengerKey =>
      _scaffoldMessengerKey;

  /// Show a toast notification
  static void show({
    required BuildContext context,
    required String message,
    String? description,
    ToastVariant variant = ToastVariant.default_,
    VoidCallback? onAction,
    String? actionLabel,
    Duration duration = const Duration(seconds: 5),
  }) {
    final toast = Toast(
      message: message,
      description: description,
      variant: variant,
      onAction: onAction,
      actionLabel: actionLabel,
      duration: duration,
    );

    ScaffoldMessenger.of(context).showSnackBar(toast.createSnackBar(context));
  }

  /// Show a success toast
  static void success(BuildContext context, String message,
      {String? description}) {
    show(
      context: context,
      message: message,
      description: description,
      variant: ToastVariant.success,
    );
  }

  /// Show an error toast
  static void error(BuildContext context, String message,
      {String? description}) {
    show(
      context: context,
      message: message,
      description: description,
      variant: ToastVariant.error,
    );
  }

  /// Show a warning toast
  static void warning(BuildContext context, String message,
      {String? description}) {
    show(
      context: context,
      message: message,
      description: description,
      variant: ToastVariant.warning,
    );
  }

  /// Show an info toast
  static void info(BuildContext context, String message,
      {String? description}) {
    show(
      context: context,
      message: message,
      description: description,
      variant: ToastVariant.info,
    );
  }

  /// Dismiss the currently showing toast
  static void dismiss(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }

  /// Dismiss all toasts
  static void dismissAll(BuildContext context) {
    ScaffoldMessenger.of(context).clearSnackBars();
  }
}
