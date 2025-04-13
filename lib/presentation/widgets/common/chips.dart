import 'package:edconnect_admin/core/design_system/foundations.dart';
import 'package:edconnect_admin/presentation/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Variant styles for the Chip component
enum ChipVariant {
  /// Default style with subtle background and border
  default_,

  /// Primary colored background
  primary,

  /// Secondary colored background
  secondary,

  /// Outlined style with border only
  outlined,

  /// Ghost style with no background or border, just text
  ghost,
}

/// Available sizes for the Chip component
enum ChipSize {
  /// Small, compact size
  small,

  /// Medium, standard size
  medium,

  /// Large size
  large,
}

/// A modern, shadcn-style chip component
class BaseChip extends ConsumerWidget {
  /// The label text displayed on the chip
  final String label;

  /// Optional icon displayed before the label
  final IconData? leadingIcon;

  /// Optional icon displayed after the label
  final IconData? trailingIcon;

  /// Callback when the chip is pressed
  final VoidCallback? onPressed;

  /// Callback when the dismiss icon is pressed
  final VoidCallback? onDismissed;

  /// Visual variant of the chip
  final ChipVariant variant;

  /// Size variant of the chip
  final ChipSize size;

  /// Whether the chip is selected
  final bool selected;

  /// Whether the chip is disabled
  final bool disabled;

  /// Custom background color (overrides variant)
  final Color? backgroundColor;

  /// Custom text color (overrides variant)
  final Color? textColor;

  const BaseChip({
    super.key,
    required this.label,
    this.leadingIcon,
    this.trailingIcon,
    this.onPressed,
    this.onDismissed,
    this.variant = ChipVariant.default_,
    this.size = ChipSize.medium,
    this.selected = false,
    this.disabled = false,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeProvider);
    final isDarkMode = theme.isDarkMode;

    // Size mappings
    final double height = switch (size) {
      ChipSize.small => 26.0,
      ChipSize.medium => 32.0,
      ChipSize.large => 40.0,
    };

    final double fontSize = switch (size) {
      ChipSize.small => Foundations.typography.xs,
      ChipSize.medium => Foundations.typography.sm,
      ChipSize.large => Foundations.typography.base,
    };

    final double iconSize = switch (size) {
      ChipSize.small => 14.0,
      ChipSize.medium => 16.0,
      ChipSize.large => 18.0,
    };

    final double horizontalPadding = switch (size) {
      ChipSize.small => Foundations.spacing.sm,
      ChipSize.medium => Foundations.spacing.md,
      ChipSize.large => Foundations.spacing.lg,
    };

    final double iconSpacing = switch (size) {
      ChipSize.small => Foundations.spacing.xs,
      ChipSize.medium => Foundations.spacing.sm,
      ChipSize.large => Foundations.spacing.sm,
    };

    final BorderRadius borderRadius = Foundations.borders.md;

    // Color variations based on variant
    Color effectiveBackgroundColor;
    Color effectiveTextColor;
    Color effectiveBorderColor;

    if (disabled) {
      // Disabled state overrides other states
      effectiveBackgroundColor = isDarkMode
          ? Foundations.darkColors.backgroundSubtle.withValues(alpha: 0.5)
          : Foundations.colors.backgroundSubtle.withValues(alpha: 0.5);
      effectiveTextColor = isDarkMode
          ? Foundations.darkColors.textDisabled
          : Foundations.colors.textDisabled;
      effectiveBorderColor = isDarkMode
          ? Foundations.darkColors.border.withValues(alpha: 0.5)
          : Foundations.colors.border.withValues(alpha: 0.5);
    } else {
      // Base colors determined by variant
      switch (variant) {
        case ChipVariant.default_:
          effectiveBackgroundColor = isDarkMode
              ? Foundations.darkColors.backgroundSubtle
              : Foundations.colors.backgroundSubtle;
          effectiveTextColor = isDarkMode
              ? Foundations.darkColors.textPrimary
              : Foundations.colors.textPrimary;
          effectiveBorderColor = isDarkMode
              ? Foundations.darkColors.border
              : Foundations.colors.border;
          break;

        case ChipVariant.primary:
          effectiveBackgroundColor = theme.primaryColor.withValues(alpha: 0.15);
          effectiveTextColor = theme.isDarkMode
              ? Foundations.darkColors.textPrimary
              : Foundations.colors.textPrimary;
          effectiveBorderColor = theme.primaryColor.withValues(alpha: 0.25);
          break;

        case ChipVariant.secondary:
          effectiveBackgroundColor =
              theme.secondaryColor.withValues(alpha: 0.15);
          effectiveTextColor = theme.isDarkMode
              ? Foundations.darkColors.textPrimary
              : Foundations.colors.textPrimary;
          effectiveBorderColor = theme.secondaryColor.withValues(alpha: 0.25);
          break;

        case ChipVariant.outlined:
          effectiveBackgroundColor = Colors.transparent;
          effectiveTextColor = isDarkMode
              ? Foundations.darkColors.textPrimary
              : Foundations.colors.textPrimary;
          effectiveBorderColor = isDarkMode
              ? Foundations.darkColors.border
              : Foundations.colors.border;
          break;

        case ChipVariant.ghost:
          effectiveBackgroundColor = Colors.transparent;
          effectiveTextColor = isDarkMode
              ? Foundations.darkColors.textPrimary
              : Foundations.colors.textPrimary;
          effectiveBorderColor = Colors.transparent;
          break;
      }

      // Selected state modifies colors
      if (selected) {
        switch (variant) {
          case ChipVariant.default_:
          case ChipVariant.ghost:
          case ChipVariant.outlined:
            effectiveBackgroundColor =
                theme.primaryColor.withValues(alpha: 0.15);
            effectiveTextColor = theme.isDarkMode
                ? Foundations.darkColors.textPrimary
                : Foundations.colors.textPrimary;
            ;
            effectiveBorderColor = theme.primaryColor.withValues(alpha: 0.25);
            break;

          case ChipVariant.primary:
            effectiveBackgroundColor = theme.primaryColor;
            effectiveTextColor = Colors.white;
            effectiveBorderColor = Colors.transparent;
            break;

          case ChipVariant.secondary:
            effectiveBackgroundColor = theme.secondaryColor;
            effectiveTextColor = Colors.white;
            effectiveBorderColor = Colors.transparent;
            break;
        }
      }
    }

    // Override with custom colors if provided
    if (backgroundColor != null) {
      effectiveBackgroundColor = backgroundColor!;
    }

    if (textColor != null) {
      effectiveTextColor = textColor!;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: disabled ? null : onPressed,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: onPressed != null
            ? effectiveBackgroundColor.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: borderRadius,
        child: Container(
          height: height,
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          decoration: BoxDecoration(
            color: effectiveBackgroundColor,
            borderRadius: borderRadius,
            border: Border.all(
              color: effectiveBorderColor,
              width: Foundations.borders.normal,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Leading icon
              if (leadingIcon != null) ...[
                Icon(
                  leadingIcon,
                  size: iconSize,
                  color: effectiveTextColor,
                ),
                SizedBox(width: iconSpacing),
              ],

              // Label
              Text(
                label,
                style: TextStyle(
                  fontSize: fontSize,
                  color: effectiveTextColor,
                  fontWeight: selected
                      ? Foundations.typography.medium
                      : Foundations.typography.regular,
                ),
              ),

              // Trailing icon (dismiss icon or custom)
              if (trailingIcon != null || onDismissed != null) ...[
                SizedBox(width: iconSpacing),
                InkWell(
                  borderRadius: Foundations.borders.md,
                  hoverColor: isDarkMode
                      ? Foundations.darkColors.backgroundSubtle
                          .withValues(alpha: 0.4)
                      : theme.accentLight.withValues(alpha: 0.4),
                  splashColor: isDarkMode
                      ? Foundations.darkColors.backgroundSubtle
                          .withValues(alpha: 0.5)
                      : theme.accentLight.withValues(alpha: 0.2),
                  onTap: disabled ? null : onDismissed ?? onPressed,
                  child: Icon(
                    trailingIcon ?? Icons.close,
                    size: iconSize,
                    color: effectiveTextColor,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// A selectable chip that toggles its selected state
class ToggleChip extends ConsumerStatefulWidget {
  final String label;
  final IconData? leadingIcon;
  final bool initialValue;
  final ValueChanged<bool>? onChanged;
  final ChipVariant variant;
  final ChipSize size;
  final bool disabled;
  final Color? selectedColor;
  final Color? unselectedColor;

  const ToggleChip({
    super.key,
    required this.label,
    this.leadingIcon,
    this.initialValue = false,
    this.onChanged,
    this.variant = ChipVariant.default_,
    this.size = ChipSize.medium,
    this.disabled = false,
    this.selectedColor,
    this.unselectedColor,
  });

  @override
  ConsumerState<ToggleChip> createState() => _ToggleChipState();
}

class _ToggleChipState extends ConsumerState<ToggleChip> {
  late bool _isSelected;

  @override
  void initState() {
    super.initState();
    _isSelected = widget.initialValue;
  }

  @override
  void didUpdateWidget(ToggleChip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue) {
      _isSelected = widget.initialValue;
    }
  }

  void _toggleSelected() {
    if (widget.disabled) return;

    setState(() {
      _isSelected = !_isSelected;
    });

    widget.onChanged?.call(_isSelected);
  }

  @override
  Widget build(BuildContext context) {
    return BaseChip(
      label: widget.label,
      leadingIcon: widget.leadingIcon,
      variant: widget.variant,
      size: widget.size,
      selected: _isSelected,
      disabled: widget.disabled,
      backgroundColor:
          _isSelected ? widget.selectedColor : widget.unselectedColor,
      onPressed: _toggleSelected,
    );
  }
}

/// A group of filter chips that allows selecting one or more options
class FilterChipGroup extends ConsumerStatefulWidget {
  final List<String> options;
  final List<String> initialSelected;
  final ValueChanged<List<String>>? onSelectionChanged;
  final ChipVariant variant;
  final ChipSize size;
  final bool allowMultiple;

  const FilterChipGroup({
    super.key,
    required this.options,
    this.initialSelected = const [],
    this.onSelectionChanged,
    this.variant = ChipVariant.default_,
    this.size = ChipSize.medium,
    this.allowMultiple = true,
  });

  @override
  ConsumerState<FilterChipGroup> createState() => _FilterChipGroupState();
}

class _FilterChipGroupState extends ConsumerState<FilterChipGroup> {
  late Set<String> _selectedItems;

  @override
  void initState() {
    super.initState();
    _selectedItems = Set.from(widget.initialSelected);
  }

  @override
  void didUpdateWidget(FilterChipGroup oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialSelected != widget.initialSelected) {
      _selectedItems = Set.from(widget.initialSelected);
    }
  }

  void _toggleItem(String item) {
    setState(() {
      if (_selectedItems.contains(item)) {
        _selectedItems.remove(item);
      } else {
        if (widget.allowMultiple) {
          _selectedItems.add(item);
        } else {
          _selectedItems = {item};
        }
      }
    });

    widget.onSelectionChanged?.call(_selectedItems.toList());
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: Foundations.spacing.sm,
      runSpacing: Foundations.spacing.sm,
      children: widget.options.map((item) {
        return BaseChip(
          label: item,
          variant: widget.variant,
          size: widget.size,
          selected: _selectedItems.contains(item),
          onPressed: () => _toggleItem(item),
        );
      }).toList(),
    );
  }
}
