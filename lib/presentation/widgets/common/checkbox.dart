import 'package:edconnect_admin/core/design_system/foundations.dart';
import 'package:edconnect_admin/presentation/providers/theme_provider.dart';
import 'package:edconnect_admin/presentation/widgets/common/cards/base_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Determines the checkbox size variant
enum CheckboxSize {
  small,
  medium,
  large,
}

/// A Shadcn-style checkbox component supporting tri-state values,
/// labels, descriptions, and rich content.
class BaseCheckbox extends ConsumerWidget {
  /// Current checkbox value
  final bool? value;

  /// Callback when checkbox value changes
  final ValueChanged<bool?> onChanged;

  /// Primary label text displayed next to the checkbox
  final String? label;

  /// Optional description text displayed below the label
  final String? description;

  /// Optional custom child widget that replaces label and description
  /// Useful for rich content like TextButtons for privacy policy links
  final Widget? child;

  /// Whether the checkbox is disabled
  final bool disabled;

  /// Whether the checkbox supports indeterminate/null state
  final bool triState;

  /// Size variant of the checkbox
  final CheckboxSize size;

  /// Whether to use a card container with background and border
  final bool hasContainer;

  /// If true, a subtle background appears on hover
  final bool showHoverEffect;

  /// Custom color for the checkbox when checked
  /// If not provided, uses the theme's primary color
  final Color? activeColor;

  /// Custom widget to show at the start (before checkbox)
  final Widget? leading;

  /// Custom widget to show at the end (after all content)
  final Widget? trailing;

  const BaseCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.description,
    this.child,
    this.disabled = false,
    this.triState = false,
    this.size = CheckboxSize.medium,
    this.hasContainer = false,
    this.showHoverEffect = true,
    this.activeColor,
    this.leading,
    this.trailing,
  }) : assert(child == null || (label == null && description == null),
            'Cannot provide both child and label/description');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeProvider);
    final isDarkMode = theme.isDarkMode;

    // Size mappings
    final checkboxSize = switch (size) {
      CheckboxSize.small => 16.0,
      CheckboxSize.medium => 20.0,
      CheckboxSize.large => 24.0,
    };

    final labelFontSize = switch (size) {
      CheckboxSize.small => Foundations.typography.sm,
      CheckboxSize.medium => Foundations.typography.base,
      CheckboxSize.large => Foundations.typography.lg,
    };

    final descriptionFontSize = switch (size) {
      CheckboxSize.small => Foundations.typography.xs,
      CheckboxSize.medium => Foundations.typography.sm,
      CheckboxSize.large => Foundations.typography.base,
    };

    final contentPadding = switch (size) {
      CheckboxSize.small => EdgeInsets.all(Foundations.spacing.sm),
      CheckboxSize.medium => EdgeInsets.all(Foundations.spacing.md),
      CheckboxSize.large => EdgeInsets.all(Foundations.spacing.lg),
    };

    // Colors
    final textColor = disabled
        ? (isDarkMode
            ? Foundations.darkColors.textDisabled
            : Foundations.colors.textDisabled)
        : (isDarkMode
            ? Foundations.darkColors.textPrimary
            : Foundations.colors.textPrimary);

    final descriptionColor = disabled
        ? (isDarkMode
            ? Foundations.darkColors.textDisabled
            : Foundations.colors.textDisabled)
        : (isDarkMode
            ? Foundations.darkColors.textMuted
            : Foundations.colors.textMuted);

    final checkColor =
        isDarkMode ? Foundations.darkColors.textPrimary : Colors.white;

    final activeBoxColor = disabled
        ? (isDarkMode
            ? Foundations.darkColors.textDisabled
            : Foundations.colors.textDisabled)
        : activeColor ?? theme.primaryColor;

    // Build the checkbox content
    Widget checkboxContent = Row(
      crossAxisAlignment: description != null || child != null
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        if (leading != null) ...[
          leading!,
          SizedBox(width: Foundations.spacing.sm),
        ],

        // Custom styled checkbox
        SizedBox(
          width: checkboxSize,
          height: checkboxSize,
          child: Checkbox(
            value: value,
            tristate: triState,
            onChanged: disabled ? null : onChanged,
            activeColor: activeBoxColor,
            checkColor: checkColor,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
            shape: RoundedRectangleBorder(
              borderRadius: Foundations.borders.xs,
            ),
            side: BorderSide(
              width: Foundations.borders.normal,
              color: disabled
                  ? (isDarkMode
                      ? Foundations.darkColors.textDisabled
                      : Foundations.colors.textDisabled)
                  : (isDarkMode
                      ? Foundations.darkColors.border
                      : Foundations.colors.border),
            ),
          ),
        ),

        SizedBox(width: Foundations.spacing.md),

        // Either display the provided child or the label/description
        Expanded(
          child: child ??
              (description != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (label != null)
                          Text(
                            label!,
                            style: TextStyle(
                              fontSize: labelFontSize,
                              fontWeight: value == true
                                  ? Foundations.typography.medium
                                  : Foundations.typography.regular,
                              color: textColor,
                            ),
                          ),
                        SizedBox(height: Foundations.spacing.xs),
                        Text(
                          description!,
                          style: TextStyle(
                            fontSize: descriptionFontSize,
                            color: descriptionColor,
                          ),
                        ),
                      ],
                    )
                  // If only label, align with checkbox
                  : Text(
                      label ?? '',
                      style: TextStyle(
                        fontSize: labelFontSize,
                        fontWeight: value == true
                            ? Foundations.typography.medium
                            : Foundations.typography.regular,
                        color: textColor,
                      ),
                    )),
        ),

        // Optional trailing widget
        if (trailing != null) ...[
          SizedBox(width: Foundations.spacing.sm),
          trailing!,
        ],
      ],
    );
    // Create the tappable wrapper
    Widget tappableContent;
    if (!disabled) {
      tappableContent = InkWell(
        onTap: () => onChanged(!(value ?? false)),
        splashColor: Colors.transparent,
        borderRadius: Foundations.borders.md,
        highlightColor: Colors.transparent,
        hoverColor: showHoverEffect
            ? (isDarkMode
                ? Foundations.darkColors.backgroundSubtle.withValues(alpha: 0.5)
                : theme.accentLight.withValues(alpha: 0.1))
            : Colors.transparent,
        child: Padding(
          padding: contentPadding,
          child: checkboxContent,
        ),
      );
    } else {
      // Disabled state - no tap behavior
      tappableContent = Padding(
        padding: contentPadding,
        child: checkboxContent,
      );
    }

    // Use BaseCard for container if requested
    if (hasContainer) {
      return BaseCard(
        variant: CardVariant.outlined,
        padding: EdgeInsets.zero,
        backgroundColor: isDarkMode
            ? Foundations.darkColors.backgroundSubtle.withValues(alpha: 0.1)
            : Foundations.colors.backgroundSubtle.withValues(alpha: 0.1),
        borderColor: isDarkMode
            ? Foundations.darkColors.border
            : Foundations.colors.border,
        margin: EdgeInsets.zero,
        child: Material(
          color: Colors.transparent,
          child: tappableContent,
        ),
      );
    }

    // No container - just the tappable content
    return Material(
      color: Colors.transparent,
      child: tappableContent,
    );
  }
}
