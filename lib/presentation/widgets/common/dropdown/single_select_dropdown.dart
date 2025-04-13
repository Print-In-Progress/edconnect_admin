import 'package:edconnect_admin/core/design_system/foundations.dart';
import 'package:edconnect_admin/l10n/app_localizations.dart';
import 'package:edconnect_admin/presentation/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A single option in a select menu
class SelectOption<T> {
  /// The value that will be returned when this option is selected
  final T value;

  /// The text displayed for this option
  final String label;

  /// Optional icon to display alongside the label
  final IconData? icon;

  /// Optional description to display below the label
  final String? description;

  /// Whether this option is disabled
  final bool disabled;

  const SelectOption({
    required this.value,
    required this.label,
    this.icon,
    this.description,
    this.disabled = false,
  });
}

/// Size variants for the select component
enum SelectSize {
  small,
  medium,
  large,
}

/// Style variants for the select component
enum SelectVariant {
  default_,
  outlined,
  filled,
  glass,
}

/// A dropdown component with searchable and non-searchable options
class BaseSelect<T> extends ConsumerStatefulWidget {
  /// Label displayed above the select
  final String? label;

  /// Hint text displayed when no option is selected
  final String? hint;

  /// Description text displayed below the select
  final String? description;

  /// Available options to choose from
  final List<SelectOption<T>> options;

  /// Currently selected value
  final T? value;

  /// Callback when selection changes
  final ValueChanged<T?> onChanged;

  /// Size variant
  final SelectSize size;

  /// Style variant
  final SelectVariant variant;

  /// Whether the select field is disabled
  final bool isDisabled;

  /// Whether the select field is required
  final bool isRequired;

  /// Whether the select should be searchable
  final bool searchable;

  /// Width of the select - null means take parent width
  final double? width;

  /// Whether the select should take full width of parent
  final bool fullWidth;

  /// Error message to display
  final String? errorText;

  /// Icon to display before the selected value
  final IconData? leadingIcon;

  /// Custom filter function for searchable select
  final bool Function(SelectOption<T> option, String query)? customFilter;

  /// Placeholder text for search input
  final String? searchPlaceholder;

  const BaseSelect({
    super.key,
    required this.options,
    required this.onChanged,
    this.value,
    this.label,
    this.hint,
    this.description,
    this.size = SelectSize.medium,
    this.variant = SelectVariant.default_,
    this.isDisabled = false,
    this.isRequired = false,
    this.searchable = false,
    this.width,
    this.fullWidth = true,
    this.errorText,
    this.leadingIcon,
    this.customFilter,
    this.searchPlaceholder,
  });

  @override
  ConsumerState<BaseSelect<T>> createState() => _BaseSelectState<T>();
}

class _BaseSelectState<T> extends ConsumerState<BaseSelect<T>> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  final FocusNode _focusNode = FocusNode();
  bool _isOpen = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isHovering = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _searchController.dispose();
    _removeOverlay();
    super.dispose();
  }

  SelectOption<T>? get _selectedOption {
    if (widget.value == null) return null;
    try {
      return widget.options
          .firstWhere((option) => option.value == widget.value);
    } catch (_) {
      return null;
    }
  }

  void _onFocusChange() {
    // When focus is lost, close the dropdown
    if (!_focusNode.hasFocus && _isOpen) {
      // Use a slight delay to allow for complete focus transition
      Future.delayed(Duration.zero, () {
        _removeOverlay();
      });
    }
  }

  void _removeOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry?.remove();
      _overlayEntry = null;
      setState(() {
        _isOpen = false;
        _searchQuery = '';
        _searchController.clear();
      });
    }
  }

  void _toggleDropdown() {
    if (widget.isDisabled) return;

    if (_isOpen) {
      _removeOverlay();
      _focusNode.unfocus(); // Ensure focus is released when manually closing
    } else {
      // Request focus when opening
      _focusNode.requestFocus();
      _showOverlay();
      setState(() {
        _isOpen = true;
      });
    }
  }

  List<SelectOption<T>> _getFilteredOptions() {
    if (_searchQuery.isEmpty) {
      return widget.options;
    }

    if (widget.customFilter != null) {
      return widget.options
          .where((option) => widget.customFilter!(option, _searchQuery))
          .toList();
    }

    return widget.options
        .where((option) =>
            option.label.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (option.description
                    ?.toLowerCase()
                    .contains(_searchQuery.toLowerCase()) ??
                false))
        .toList();
  }

  void _showOverlay() {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    // Use the actual height based on the size variant
    final double offsetHeight = switch (widget.size) {
      SelectSize.small => 36.0,
      SelectSize.medium => 40.0,
      SelectSize.large => 48.0,
    };

    _overlayEntry = OverlayEntry(
      builder: (context) {
        final theme = ref.watch(appThemeProvider);
        final isDarkMode = theme.isDarkMode;
        final l10n = AppLocalizations.of(context)!;

        // Always use fully rounded borders for more shadcn-like appearance
        final borderRadius = Foundations.borders.md;

        return Stack(
          children: [
            // Invisible overlay for detecting outside taps
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  _removeOverlay();
                  _focusNode.unfocus();
                },
                child: Container(color: Colors.transparent),
              ),
            ),

            // Dropdown content
            Positioned(
              width: size.width,
              child: CompositedTransformFollower(
                link: _layerLink,
                showWhenUnlinked: false,
                offset: Offset(0, offsetHeight),
                child: Material(
                  color: Colors.transparent,
                  child: AnimatedOpacity(
                    duration: Foundations.effects.shortAnimation,
                    opacity: 1.0,
                    child: Container(
                      // Set constraints with a maximum height
                      constraints: BoxConstraints(
                        // Maximum height limit
                        maxHeight: 320,
                        minWidth: size.width,
                      ),
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? Foundations.darkColors.surface
                            : Foundations.colors.surface,
                        borderRadius: borderRadius,
                        boxShadow: [
                          BoxShadow(
                            color: isDarkMode
                                ? Colors.black.withValues(alpha: 0.18)
                                : Colors.black.withValues(alpha: 0.08),
                            blurRadius: 10,
                            spreadRadius: 2,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: borderRadius,
                        // Use IntrinsicHeight to adjust to content size
                        child: LayoutBuilder(builder: (context, constraints) {
                          // Get the filtered options
                          final filteredOptions = _getFilteredOptions();

                          // Calculate content height
                          final bool hasSearch = widget.searchable;
                          final double searchHeight = hasSearch
                              ? 56.0
                              : 0.0; // Height of search box + divider
                          final double itemHeight =
                              44.0; // Approximate height of each item
                          final double totalItemsHeight =
                              filteredOptions.length * itemHeight;

                          // Check if we need to scroll
                          final bool needsScroll =
                              (totalItemsHeight + searchHeight) >
                                  constraints.maxHeight;

                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Search field if searchable is enabled
                              if (widget.searchable) ...[
                                Padding(
                                  padding:
                                      EdgeInsets.all(Foundations.spacing.sm),
                                  child: TextFormField(
                                    controller: _searchController,
                                    autofocus: true,
                                    // Search field styling remains the same
                                    decoration: InputDecoration(
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: Foundations.spacing.md,
                                        vertical: Foundations.spacing.sm,
                                      ),
                                      hintText: widget.searchPlaceholder ??
                                          l10n.globalSearch,
                                      prefixIcon: Icon(
                                        Icons.search,
                                        color: isDarkMode
                                            ? Foundations.darkColors.textMuted
                                            : Foundations.colors.textMuted,
                                        size: 18,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: Foundations.borders.md,
                                        borderSide: BorderSide(
                                          color: isDarkMode
                                              ? Foundations.darkColors.border
                                              : Foundations.colors.border,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: Foundations.borders.md,
                                        borderSide: BorderSide(
                                          color: isDarkMode
                                              ? Foundations.darkColors.border
                                              : Foundations.colors.border,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: Foundations.borders.md,
                                        borderSide: BorderSide(
                                          color: theme.primaryColor,
                                          width: 1.5,
                                        ),
                                      ),
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        _searchQuery = value;
                                        _overlayEntry?.markNeedsBuild();
                                      });
                                    },
                                  ),
                                ),
                                Divider(
                                  height: 1,
                                  thickness: 1,
                                  color: isDarkMode
                                      ? Foundations.darkColors.border
                                      : Foundations.colors.border,
                                ),
                              ],

                              if (filteredOptions.isEmpty)
                                // No results message
                                Padding(
                                  padding:
                                      EdgeInsets.all(Foundations.spacing.md),
                                  child: Center(
                                    child: Text(
                                      l10n.globalNoResults,
                                      style: TextStyle(
                                        color: isDarkMode
                                            ? Foundations.darkColors.textMuted
                                            : Foundations.colors.textMuted,
                                        fontSize: Foundations.typography.sm,
                                      ),
                                    ),
                                  ),
                                )
                              else
                                // List of options - this is where the key changes are
                                Container(
                                  // If we need to scroll, use the max height, otherwise use the content height
                                  height: needsScroll
                                      ? constraints.maxHeight - searchHeight
                                      : totalItemsHeight,
                                  child: ListView.builder(
                                    padding: EdgeInsets.symmetric(
                                        vertical: Foundations.spacing.sm),
                                    // Always allow scrolling for consistency
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    // Don't use shrinkWrap when scrollable
                                    shrinkWrap: !needsScroll,
                                    itemCount: filteredOptions.length,
                                    itemBuilder: (context, index) {
                                      final option = filteredOptions[index];
                                      final isSelected =
                                          widget.value == option.value;
                                      return _buildOptionItem(
                                          option, isSelected, isDarkMode);
                                    },
                                  ),
                                ),
                            ],
                          );
                        }),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  Widget _buildOptionItem(
      SelectOption<T> option, bool isSelected, bool isDarkMode) {
    final textColor = option.disabled
        ? (isDarkMode
            ? Foundations.darkColors.textDisabled
            : Foundations.colors.textDisabled)
        : isSelected
            ? ref.watch(appThemeProvider).primaryColor
            : (isDarkMode
                ? Foundations.darkColors.textPrimary
                : Foundations.colors.textPrimary);

    final bgColor = isSelected
        ? (isDarkMode
            ? ref.watch(appThemeProvider).primaryColor.withValues(alpha: 0.1)
            : ref.watch(appThemeProvider).primaryColor.withValues(alpha: 0.05))
        : Colors.transparent;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: option.disabled
            ? null
            : () {
                widget.onChanged(option.value);
                _removeOverlay();
              },
        hoverColor: isDarkMode
            ? Foundations.darkColors.backgroundSubtle.withValues(alpha: 0.2)
            : Foundations.colors.backgroundSubtle.withValues(alpha: 0.2),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: Foundations.spacing.md,
            vertical: Foundations.spacing.sm,
          ),
          decoration: BoxDecoration(
            color: bgColor,
          ),
          child: Row(
            children: [
              if (option.icon != null) ...[
                Icon(option.icon, size: 18, color: textColor),
                SizedBox(width: Foundations.spacing.sm),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      option.label,
                      style: TextStyle(
                        color: textColor,
                        fontWeight: isSelected
                            ? Foundations.typography.semibold
                            : Foundations.typography.regular,
                        fontSize: Foundations.typography.base,
                      ),
                    ),
                    if (option.description != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        option.description!,
                        style: TextStyle(
                          color: isDarkMode
                              ? Foundations.darkColors.textMuted
                              : Foundations.colors.textMuted,
                          fontSize: Foundations.typography.sm,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check,
                  size: 18,
                  color: ref.watch(appThemeProvider).primaryColor,
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(appThemeProvider);
    final isDarkMode = theme.isDarkMode;
    // Size mappings
    final double height = switch (widget.size) {
      SelectSize.small => 36.0,
      SelectSize.medium => 40.0,
      SelectSize.large => 48.0,
    };

    final double fontSize = switch (widget.size) {
      SelectSize.small => Foundations.typography.sm,
      SelectSize.medium => Foundations.typography.base,
      SelectSize.large => Foundations.typography.base,
    };

    final EdgeInsetsGeometry contentPadding = switch (widget.size) {
      SelectSize.small => EdgeInsets.symmetric(
          horizontal: Foundations.spacing.md,
          vertical: Foundations.spacing.xs,
        ),
      SelectSize.medium => EdgeInsets.symmetric(
          horizontal: Foundations.spacing.lg,
          vertical: Foundations.spacing.sm,
        ),
      SelectSize.large => EdgeInsets.symmetric(
          horizontal: Foundations.spacing.lg,
          vertical: Foundations.spacing.md,
        ),
    };

    // Colors
    final Color textColor = widget.isDisabled
        ? (isDarkMode
            ? Foundations.darkColors.textDisabled
            : Foundations.colors.textDisabled)
        : (isDarkMode
            ? Foundations.darkColors.textPrimary
            : Foundations.colors.textPrimary);

    final Color labelColor = widget.isDisabled
        ? (isDarkMode
            ? Foundations.darkColors.textDisabled
            : Foundations.colors.textDisabled)
        : (isDarkMode
            ? Foundations.darkColors.textSecondary
            : Foundations.colors.textSecondary);

    final Color descriptionColor = widget.isDisabled
        ? (isDarkMode
            ? Foundations.darkColors.textDisabled
            : Foundations.colors.textDisabled)
        : (isDarkMode
            ? Foundations.darkColors.textMuted
            : Foundations.colors.textMuted);

    // Determine background color based on variant
    final Color fillColor = switch (widget.variant) {
      SelectVariant.filled => isDarkMode
          ? Foundations.darkColors.inputBg
          : Foundations.colors.inputBg,
      SelectVariant.glass =>
        isDarkMode ? Foundations.darkColors.glass : Foundations.colors.glass,
      _ => Colors.transparent,
    };

    // Border styling
    final Color borderColor = widget.errorText != null
        ? Foundations.colors.error
        : _isOpen
            ? theme.accentDark
            : (isDarkMode
                ? Foundations.darkColors.border
                : Foundations.colors.border);

    // Selected option information
    final SelectOption<T>? selectedOption = _selectedOption;
    final String displayText = selectedOption?.label ?? widget.hint ?? '';

    // Build the component
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label
        if (widget.label != null) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                Text(
                  widget.isRequired ? '${widget.label} *' : widget.label!,
                  style: TextStyle(
                    fontSize: Foundations.typography.sm,
                    fontWeight: Foundations.typography.medium,
                    color: labelColor,
                  ),
                ),
              ],
            ),
          ),
        ],

        // Select field
        CompositedTransformTarget(
          link: _layerLink,
          child: MouseRegion(
            cursor: widget.isDisabled
                ? SystemMouseCursors.forbidden
                : SystemMouseCursors.click,
            onEnter: (_) {
              if (!widget.isDisabled && !_isOpen) {
                setState(() {
                  // Trigger hover state
                  _isHovering = true;
                });
              }
            },
            onExit: (_) {
              if (_isHovering) {
                setState(() {
                  _isHovering = false;
                });
              }
            },
            child: Focus(
              focusNode: _focusNode,
              child: GestureDetector(
                onTap: _toggleDropdown,
                child: Container(
                  height: height,
                  width: widget.fullWidth ? null : widget.width,
                  decoration: BoxDecoration(
                    color: fillColor,
                    borderRadius: Foundations.borders.sm,
                    border: Border.all(
                      color: borderColor,
                      width: _isOpen
                          ? Foundations
                              .borders.thick // Thicker border when focused/open
                          : Foundations
                              .borders.normal, // Normal border when unfocused
                    ),
                    // Add hover effect similar to BaseInput
                    boxShadow: _isHovering && !_isOpen
                        ? [
                            BoxShadow(
                              color: isDarkMode
                                  ? Foundations.darkColors.backgroundSubtle
                                      .withValues(alpha: 0.2)
                                  : theme.accentLight.withValues(alpha: 0.05),
                              blurRadius: 0,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                  child: Padding(
                    padding: contentPadding,
                    child: Row(
                      children: [
                        // Leading icon
                        if (widget.leadingIcon != null) ...[
                          Icon(
                            widget.leadingIcon,
                            size: 18,
                            color: textColor.withValues(alpha: 0.7),
                          ),
                          SizedBox(width: Foundations.spacing.sm),
                        ],

                        // Label text
                        Expanded(
                          child: Text(
                            displayText,
                            style: TextStyle(
                              color: selectedOption != null
                                  ? textColor
                                  : textColor.withValues(alpha: 0.6),
                              fontSize: fontSize,
                              fontWeight: selectedOption != null
                                  ? Foundations.typography.regular
                                  : Foundations.typography.regular,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        // Dropdown icon
                        Icon(
                          _isOpen
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: textColor.withValues(alpha: 0.7),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        // Error text
        if (widget.errorText != null) ...[
          SizedBox(height: Foundations.spacing.xs),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: Foundations.spacing.sm),
            child: Text(
              widget.errorText!,
              style: TextStyle(
                color: Foundations.colors.error,
                fontSize: Foundations.typography.xs,
              ),
            ),
          ),
        ],

        // Description
        if (widget.description != null && widget.errorText == null) ...[
          SizedBox(height: Foundations.spacing.xs),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: Foundations.spacing.sm),
            child: Text(
              widget.description!,
              style: TextStyle(
                color: descriptionColor,
                fontSize: Foundations.typography.xs,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
