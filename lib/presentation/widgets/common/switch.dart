import 'package:edconnect_admin/core/design_system/foundations.dart';
import 'package:edconnect_admin/presentation/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Size variants for the switch component
enum SwitchSize {
  small,
  medium,
  large,
}

/// A shadcn-inspired switch component with hover effect and press states
class BaseSwitch extends ConsumerStatefulWidget {
  /// Current state of the switch
  final bool value;

  /// Callback when the switch state changes
  final ValueChanged<bool> onChanged;

  /// Primary label text displayed next to the switch
  final String? label;

  /// Optional description text displayed below the label
  final String? description;

  /// Optional custom child widget that replaces label and description
  /// Useful for rich content like TextButtons for privacy policy links
  final Widget? child;

  /// Whether the switch is disabled
  final bool disabled;

  /// Size variant of the switch
  final SwitchSize size;

  /// Container decoration - set to true to add a subtle background
  /// and border like the terms checkbox in your registration form
  final bool hasContainer;

  /// If true, a subtle background appears on hover
  final bool showHoverEffect;

  /// Custom color for the switch when active
  /// If not provided, uses the theme's primary color
  final Color? activeColor;

  /// Custom widget to show at the start (before switch)
  final Widget? leading;

  /// Custom widget to show at the end (after content)
  final Widget? trailing;

  const BaseSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.description,
    this.child,
    this.disabled = false,
    this.size = SwitchSize.medium,
    this.hasContainer = false,
    this.showHoverEffect = true,
    this.activeColor,
    this.leading,
    this.trailing,
  }) : assert(child == null || (label == null && description == null),
            'Cannot provide both child and label/description');

  @override
  ConsumerState<BaseSwitch> createState() => _BaseSwitchState();
}

class _BaseSwitchState extends ConsumerState<BaseSwitch> {
  bool _isHovering = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(appThemeProvider);
    final isDarkMode = theme.isDarkMode;

    // Size mappings
    final switchWidth = switch (widget.size) {
      SwitchSize.small => 36.0,
      SwitchSize.medium => 44.0,
      SwitchSize.large => 52.0,
    };

    final switchHeight = switch (widget.size) {
      SwitchSize.small => 20.0,
      SwitchSize.medium => 24.0,
      SwitchSize.large => 28.0,
    };

    final thumbSize = switch (widget.size) {
      SwitchSize.small => 12.0,
      SwitchSize.medium => 16.0,
      SwitchSize.large => 20.0,
    };

    final labelFontSize = switch (widget.size) {
      SwitchSize.small => Foundations.typography.sm,
      SwitchSize.medium => Foundations.typography.base,
      SwitchSize.large => Foundations.typography.lg,
    };

    final descriptionFontSize = switch (widget.size) {
      SwitchSize.small => Foundations.typography.xs,
      SwitchSize.medium => Foundations.typography.sm,
      SwitchSize.large => Foundations.typography.base,
    };

    final contentPadding = switch (widget.size) {
      SwitchSize.small => EdgeInsets.all(Foundations.spacing.sm),
      SwitchSize.medium => EdgeInsets.all(Foundations.spacing.md),
      SwitchSize.large => EdgeInsets.all(Foundations.spacing.lg),
    };

    // Colors
    final textColor = widget.disabled
        ? (isDarkMode
            ? Foundations.darkColors.textDisabled
            : Foundations.colors.textDisabled)
        : (isDarkMode
            ? Foundations.darkColors.textPrimary
            : Foundations.colors.textPrimary);

    final descriptionColor = widget.disabled
        ? (isDarkMode
            ? Foundations.darkColors.textDisabled
            : Foundations.colors.textDisabled)
        : (isDarkMode
            ? Foundations.darkColors.textMuted
            : Foundations.colors.textMuted);

    final activeTrackColor = widget.disabled
        ? (isDarkMode
            ? Foundations.darkColors.textDisabled
            : Foundations.colors.textDisabled)
        : (widget.activeColor ?? theme.primaryColor);

    final inactiveTrackColor = widget.disabled
        ? (isDarkMode
            ? Foundations.darkColors.backgroundSubtle.withValues(alpha: 0.3)
            : Foundations.colors.backgroundSubtle.withValues(alpha: 0.3))
        : (isDarkMode
            ? Foundations.darkColors.backgroundSubtle
            : Foundations.colors.backgroundSubtle);

    final thumbColor =
        isDarkMode ? Foundations.darkColors.surface : Colors.white;

    // Create the switch component with a custom appearance
    Widget buildSwitch() {
      return GestureDetector(
        onTap: widget.disabled ? null : () => widget.onChanged(!widget.value),
        onTapDown:
            widget.disabled ? null : (_) => setState(() => _isPressed = true),
        onTapUp:
            widget.disabled ? null : (_) => setState(() => _isPressed = false),
        onTapCancel:
            widget.disabled ? null : () => setState(() => _isPressed = false),
        child: MouseRegion(
          cursor: widget.disabled
              ? SystemMouseCursors.forbidden
              : SystemMouseCursors.click,
          onEnter: (_) => setState(() => _isHovering = true),
          onExit: (_) => setState(() => _isHovering = false),
          child: AnimatedContainer(
            duration: Foundations.effects.shortAnimation,
            width: switchWidth,
            height: switchHeight,
            decoration: BoxDecoration(
              borderRadius: Foundations.borders.full,
              border: Border.all(
                color: widget.value
                    ? activeTrackColor
                    : (isDarkMode
                        ? Foundations.darkColors.border
                        : Foundations.colors.border),
                width: 1.5,
              ),
              color: widget.value ? activeTrackColor : inactiveTrackColor,
              boxShadow: _isPressed
                  ? [
                      BoxShadow(
                        color: activeTrackColor.withValues(alpha: 0.3),
                        blurRadius: 8,
                        spreadRadius: 2,
                      )
                    ]
                  : (_isHovering && !widget.disabled)
                      ? [
                          BoxShadow(
                            color: activeTrackColor.withValues(alpha: 0.2),
                            blurRadius: 4,
                            spreadRadius: 1,
                          )
                        ]
                      : null,
            ),
            child: Stack(
              children: [
                AnimatedAlign(
                  duration: Foundations.effects.shortAnimation,
                  curve: Curves.easeInOut,
                  alignment: widget.value
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: (switchHeight - thumbSize) / 2),
                    child: Container(
                      width: thumbSize,
                      height: thumbSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: thumbColor,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 1,
                            spreadRadius: 0.5,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Create the content that will be wrapped by the clickable area
    Widget buildContent() {
      return Row(
        crossAxisAlignment: widget.description != null || widget.child != null
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          if (widget.leading != null) ...[
            widget.leading!,
            SizedBox(width: Foundations.spacing.sm),
          ],

          // Custom styled switch
          buildSwitch(),

          SizedBox(width: Foundations.spacing.md),

          // Either display the provided child or the label/description
          Expanded(
            child: widget.child ??
                (widget.description != null
                    // If we have a description, use Column layout
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (widget.label != null)
                            Text(
                              widget.label!,
                              style: TextStyle(
                                fontSize: labelFontSize,
                                fontWeight: widget.value
                                    ? Foundations.typography.medium
                                    : Foundations.typography.regular,
                                color: textColor,
                              ),
                            ),
                          SizedBox(height: Foundations.spacing.xs),
                          Text(
                            widget.description!,
                            style: TextStyle(
                              fontSize: descriptionFontSize,
                              color: descriptionColor,
                            ),
                          ),
                        ],
                      )
                    // If only label, align with switch
                    : widget.label != null
                        ? Text(
                            widget.label!,
                            style: TextStyle(
                              fontSize: labelFontSize,
                              fontWeight: widget.value
                                  ? Foundations.typography.medium
                                  : Foundations.typography.regular,
                              color: textColor,
                            ),
                          )
                        : const SizedBox.shrink()),
          ),

          // Optional trailing widget
          if (widget.trailing != null) ...[
            SizedBox(width: Foundations.spacing.sm),
            widget.trailing!,
          ],
        ],
      );
    }

    // Build the complete switch component with container and tap behavior
    Widget switchContent = buildContent();

    // Make the entire widget tappable unless disabled
    if (!widget.disabled) {
      switchContent = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => widget.onChanged(!widget.value),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: widget.showHoverEffect
              ? (isDarkMode
                  ? Foundations.darkColors.backgroundSubtle
                      .withValues(alpha: 0.1)
                  : Foundations.colors.backgroundSubtle.withValues(alpha: 0.1))
              : Colors.transparent,
          borderRadius: Foundations.borders.md,
          child: Padding(
            padding: contentPadding,
            child: switchContent,
          ),
        ),
      );
    } else {
      // If disabled, still apply padding but no tap effect
      switchContent = Padding(
        padding: contentPadding,
        child: switchContent,
      );
    }

    // Wrap in a container if requested
    if (widget.hasContainer) {
      return Container(
        decoration: BoxDecoration(
          color: isDarkMode
              ? Foundations.darkColors.backgroundSubtle.withValues(alpha: 0.2)
              : Foundations.colors.backgroundSubtle.withValues(alpha: 0.2),
          borderRadius: Foundations.borders.md,
          border: Border.all(
            color: isDarkMode
                ? Foundations.darkColors.border
                : Foundations.colors.border,
            width: Foundations.borders.thin,
          ),
        ),
        child: switchContent,
      );
    }

    return switchContent;
  }
}
