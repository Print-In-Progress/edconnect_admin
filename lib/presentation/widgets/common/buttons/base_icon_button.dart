import 'package:edconnect_admin/core/design_system/foundations.dart';
import 'package:edconnect_admin/presentation/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum IconButtonSize { small, medium, large }

enum IconButtonVariant {
  /// Filled background with icon
  filled,

  /// Outlined border with transparent background
  outlined,

  /// Transparent background (no border or fill)
  ghost
}

class BaseIconButton extends ConsumerWidget {
  /// The icon to display
  final IconData icon;

  /// Callback when the button is pressed
  final VoidCallback? onPressed;

  /// Visual style variant
  final IconButtonVariant variant;

  /// Size variant
  final IconButtonSize size;

  /// Whether the button is in a loading state
  final bool isLoading;

  /// Whether the button is disabled
  final bool disabled;

  /// Custom color for the button (will use accent color if not provided)
  final Color? color;

  /// Tooltip text to display on hover
  final String? tooltip;

  const BaseIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.variant = IconButtonVariant.ghost,
    this.size = IconButtonSize.medium,
    this.isLoading = false,
    this.disabled = false,
    this.color,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeProvider);
    final isDarkMode = theme.isDarkMode;

    // Size mapping
    final double buttonSize = switch (size) {
      IconButtonSize.small => 32.0,
      IconButtonSize.medium => 40.0,
      IconButtonSize.large => 48.0,
    };

    final double iconSize = switch (size) {
      IconButtonSize.small => 16.0,
      IconButtonSize.medium => 20.0,
      IconButtonSize.large => 24.0,
    };

    // Determine the colors based on variant and theme
    final Color effectiveColor = color ??
        (theme.isDarkMode
            ? Foundations.darkColors.textPrimary
            : theme.primaryColor);

    // Build different button styles based on variant
    Widget buttonContent;

    switch (variant) {
      case IconButtonVariant.filled:
        buttonContent = Material(
          color: disabled
              ? (isDarkMode
                  ? Foundations.darkColors.textDisabled
                  : Foundations.colors.textDisabled)
              : effectiveColor,
          shape: RoundedRectangleBorder(
            borderRadius: Foundations.borders.md,
          ),
          child: InkWell(
            onTap: (isLoading || disabled) ? null : onPressed,
            hoverColor: isDarkMode
                ? HSLColor.fromColor(effectiveColor)
                    .withLightness(
                        (HSLColor.fromColor(effectiveColor).lightness - 0.05)
                            .clamp(0.0, 1.0))
                    .toColor()
                : theme.accentDark,
            splashColor: isDarkMode
                ? HSLColor.fromColor(effectiveColor)
                    .withLightness(
                        (HSLColor.fromColor(effectiveColor).lightness - 0.1)
                            .clamp(0.0, 1.0))
                    .toColor()
                : HSLColor.fromColor(theme.accentDark)
                    .withLightness(
                        (HSLColor.fromColor(theme.accentDark).lightness - 0.05)
                            .clamp(0.0, 1.0))
                    .toColor(),
            borderRadius: Foundations.borders.md,
            child: SizedBox(
              width: buttonSize,
              height: buttonSize,
              child: Center(
                child: isLoading
                    ? SizedBox(
                        width: iconSize * 0.8,
                        height: iconSize * 0.8,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: isDarkMode
                              ? Foundations.darkColors.textPrimary
                              : Colors.white,
                        ),
                      )
                    : Icon(
                        icon,
                        size: iconSize,
                        color: isDarkMode
                            ? Foundations.darkColors.textPrimary
                            : Colors.white,
                      ),
              ),
            ),
          ),
        );
        break;

      case IconButtonVariant.outlined:
        buttonContent = Material(
          color: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: Foundations.borders.md,
            side: BorderSide(
              color: disabled
                  ? (isDarkMode
                      ? Foundations.darkColors.textDisabled
                      : Foundations.colors.textDisabled)
                  : effectiveColor,
              width: Foundations.borders.normal,
            ),
          ),
          child: InkWell(
            onTap: (isLoading || disabled) ? null : onPressed,
            borderRadius: Foundations.borders.md,
            hoverColor: isDarkMode
                ? Foundations.darkColors.backgroundSubtle.withValues(alpha: 0.4)
                : theme.accentLight.withValues(alpha: 0.4),
            splashColor: isDarkMode
                ? Foundations.darkColors.backgroundSubtle.withValues(alpha: 0.5)
                : theme.accentLight.withValues(alpha: 0.2),
            highlightColor: effectiveColor.withValues(alpha: 0.05),
            child: SizedBox(
              width: buttonSize,
              height: buttonSize,
              child: Center(
                child: isLoading
                    ? SizedBox(
                        width: iconSize * 0.8,
                        height: iconSize * 0.8,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: effectiveColor,
                        ),
                      )
                    : Icon(
                        icon,
                        size: iconSize,
                        color: disabled
                            ? (isDarkMode
                                ? Foundations.darkColors.textDisabled
                                : Foundations.colors.textDisabled)
                            : effectiveColor,
                      ),
              ),
            ),
          ),
        );
        break;

      case IconButtonVariant.ghost:
        buttonContent = Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: (isLoading || disabled) ? null : onPressed,
            borderRadius: Foundations.borders.md,
            hoverColor: isDarkMode
                ? Foundations.darkColors.backgroundSubtle.withValues(alpha: 0.4)
                : theme.accentLight.withValues(alpha: 0.4),
            splashColor: isDarkMode
                ? Foundations.darkColors.backgroundSubtle.withValues(alpha: 0.5)
                : theme.accentLight.withValues(alpha: 0.2),
            highlightColor: effectiveColor.withValues(alpha: 0.05),
            child: SizedBox(
              width: buttonSize,
              height: buttonSize,
              child: Center(
                child: isLoading
                    ? SizedBox(
                        width: iconSize * 0.8,
                        height: iconSize * 0.8,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: effectiveColor,
                        ),
                      )
                    : Icon(
                        icon,
                        size: iconSize,
                        color: disabled
                            ? (isDarkMode
                                ? Foundations.darkColors.textDisabled
                                : Foundations.colors.textDisabled)
                            : effectiveColor,
                      ),
              ),
            ),
          ),
        );
        break;
    }

    // Add tooltip if provided
    if (tooltip != null) {
      return Tooltip(
        message: tooltip!,
        textStyle: TextStyle(
          color: isDarkMode
              ? Foundations.darkColors.textPrimary
              : Foundations.colors.textPrimary,
        ),
        decoration: BoxDecoration(
          color: isDarkMode
              ? Foundations.darkColors.backgroundMuted
              : Foundations.colors.backgroundMuted,
          borderRadius: Foundations.borders.md,
        ),
        child: buttonContent,
      );
    }

    return buttonContent;
  }
}
