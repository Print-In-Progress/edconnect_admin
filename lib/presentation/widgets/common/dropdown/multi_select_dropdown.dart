import 'package:edconnect_admin/core/design_system/foundations.dart';
import 'package:edconnect_admin/l10n/app_localizations.dart';
import 'package:edconnect_admin/presentation/providers/theme_provider.dart';
import 'package:edconnect_admin/presentation/widgets/common/buttons/base_button.dart';
import 'package:edconnect_admin/presentation/widgets/common/chips.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'single_select_dropdown.dart';

/// A multi-select dropdown component with searchable and non-searchable options
class BaseMultiSelect<T> extends ConsumerStatefulWidget {
  /// Label displayed above the select
  final String? label;

  /// Hint text displayed when no options are selected
  final String? hint;

  /// Description text displayed below the select
  final String? description;

  /// Available options to choose from
  final List<SelectOption<T>> options;

  /// Currently selected values
  final List<T> values;

  /// Callback when selection changes
  final ValueChanged<List<T>> onChanged;

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

  /// Text to display when showing selected count
  final String Function(int count)? selectedCountBuilder;

  /// Maximum number of chips to display in closed state
  final int maxChipsVisible;

  const BaseMultiSelect({
    super.key,
    required this.options,
    required this.onChanged,
    this.values = const [],
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
    this.selectedCountBuilder,
    this.maxChipsVisible = 2,
  });

  @override
  ConsumerState<BaseMultiSelect<T>> createState() => _BaseMultiSelectState<T>();
}

class _BaseMultiSelectState<T> extends ConsumerState<BaseMultiSelect<T>> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  final FocusNode _focusNode = FocusNode();
  bool _isOpen = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isHovering = false;
  bool _isInteracting = false;

  late List<T> _currentValues;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
    _currentValues = List.from(widget.values);
  }

  @override
  void didUpdateWidget(BaseMultiSelect<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.values != widget.values) {
      _currentValues = List.from(widget.values);

      // Use post-frame callback
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_overlayEntry != null && _isOpen) {
          _overlayEntry!.markNeedsBuild();
        }
      });
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _searchController.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _toggleOption(T value) {
    setState(() {
      if (_currentValues.contains(value)) {
        _currentValues.remove(value);
      } else {
        _currentValues.add(value);
      }
    });

    widget.onChanged(_currentValues);

    if (_overlayEntry != null && _isOpen) {
      _overlayEntry!.markNeedsBuild();
    }
  }

  List<SelectOption<T>> get _selectedOptions {
    return widget.options
        .where((option) => widget.values.contains(option.value))
        .toList();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus && _isOpen && !_isInteracting) {
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
      _focusNode.unfocus();
    } else {
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

  void _removeValue(T value) {
    final List<T> updatedValues = List.from(_currentValues);
    updatedValues.remove(value);
    _currentValues = updatedValues;
    widget.onChanged(updatedValues);

    // Use post-frame callback
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_overlayEntry != null && _isOpen) {
        _overlayEntry!.markNeedsBuild();
      }
    });
  }

  void _clearSelection() {
    _currentValues = [];
    widget.onChanged([]);

    // Use post-frame callback
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_overlayEntry != null && _isOpen) {
        _overlayEntry!.markNeedsBuild();
      }
    });
  }

  void _showOverlay() {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    // Calculate available space below and above
    final double screenHeight = MediaQuery.of(context).size.height;
    final double bottomSpace = screenHeight - offset.dy - size.height;
    final double topSpace = offset.dy;

    // Calculate content height
    final double searchHeight = widget.searchable ? 48.0 : 0.0;
    final double headerHeight = _currentValues.isNotEmpty ? 40.0 : 0.0;
    const double itemHeight = 44.0;
    final double totalItemsHeight = _getFilteredOptions().length * itemHeight;

    // Calculate actual content height (with padding and dividers)
    final double contentHeight = searchHeight +
        headerHeight +
        totalItemsHeight +
        (widget.searchable ? 1.0 : 0.0) + // Divider
        (headerHeight > 0 ? 1.0 : 0.0) + // Divider
        8.0; // Padding

    const double verticalGap = 4.0;

    // Constrain to max height of 320
    final double overlayHeight = contentHeight.clamp(0.0, 320.0);

    // Determine if overlay should show above or below
    final bool showAbove =
        bottomSpace < overlayHeight && topSpace > bottomSpace;

    final double fieldHeight = switch (widget.size) {
      SelectSize.small => 36.0,
      SelectSize.medium => 40.0,
      SelectSize.large => 48.0,
    };

    final double overlayOffset =
        showAbove ? -(overlayHeight + verticalGap) : fieldHeight + verticalGap;

    _overlayEntry = OverlayEntry(
      builder: (context) {
        final theme = ref.watch(appThemeProvider);
        final isDarkMode = theme.isDarkMode;
        final l10n = AppLocalizations.of(context)!;
        final borderRadius = Foundations.borders.md;

        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  _removeOverlay();
                  _focusNode.unfocus();
                },
                child: Container(color: Colors.transparent),
              ),
            ),
            Positioned(
              width: size.width,
              child: CompositedTransformFollower(
                link: _layerLink,
                showWhenUnlinked: false,
                offset: Offset(0, overlayOffset),
                child: Material(
                  color: Colors.transparent,
                  child: AnimatedOpacity(
                    duration: Foundations.effects.shortAnimation,
                    opacity: 1.0,
                    child: Container(
                      constraints: BoxConstraints(
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
                        child: LayoutBuilder(builder: (context, constraints) {
                          final filteredOptions = _getFilteredOptions();
                          final bool hasSearch = widget.searchable;
                          final double searchHeight = hasSearch ? 56.0 : 0.0;
                          const double itemHeight = 44.0;
                          final double totalItemsHeight =
                              filteredOptions.length * itemHeight;
                          final bool needsScroll =
                              (totalItemsHeight + searchHeight) >
                                  constraints.maxHeight;

                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Selected options action row
                              if (_currentValues.isNotEmpty) ...[
                                Padding(
                                  padding:
                                      EdgeInsets.all(Foundations.spacing.sm),
                                  child: Row(
                                    children: [
                                      Text(
                                        widget.selectedCountBuilder
                                                ?.call(_currentValues.length) ??
                                            '${_currentValues.length} selected',
                                        style: TextStyle(
                                          fontSize: Foundations.typography.sm,
                                          fontWeight:
                                              Foundations.typography.medium,
                                          color: isDarkMode
                                              ? Foundations
                                                  .darkColors.textSecondary
                                              : Foundations
                                                  .colors.textSecondary,
                                        ),
                                      ),
                                      const Spacer(),
                                      BaseButton(
                                        label: l10n.globalClear,
                                        onPressed: _clearSelection,
                                        variant: ButtonVariant.text,
                                        size: ButtonSize.small,
                                      ),
                                    ],
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

                              // Search field
                              if (widget.searchable) ...[
                                Padding(
                                  padding:
                                      EdgeInsets.all(Foundations.spacing.sm),
                                  child: Focus(
                                    canRequestFocus: true,
                                    onFocusChange: (hasFocus) {
                                      if (hasFocus) {
                                        _isInteracting = true;
                                      } else {
                                        Future.delayed(
                                            const Duration(milliseconds: 100),
                                            () {
                                          _isInteracting = false;
                                        });
                                      }
                                    },
                                    child: TextFormField(
                                      controller: _searchController,
                                      autofocus: true,
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
                                          borderRadius: Foundations.borders.sm,
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
                                      onTap: () {
                                        _isInteracting = true;
                                      },
                                      onChanged: (value) {
                                        _searchQuery = value;

                                        WidgetsBinding.instance
                                            .addPostFrameCallback((_) {
                                          if (_overlayEntry != null &&
                                              _isOpen) {
                                            _overlayEntry!.markNeedsBuild();
                                          }
                                        });
                                      },
                                    ),
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

                              // Options list
                              if (filteredOptions.isEmpty)
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
                                Flexible(
                                  // Use Flexible instead of Container with fixed height
                                  child: ListView.builder(
                                    padding: EdgeInsets.symmetric(
                                        vertical: Foundations.spacing.sm),
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    shrinkWrap: !needsScroll,
                                    itemCount: filteredOptions.length,
                                    itemBuilder: (context, index) {
                                      final option = filteredOptions[index];
                                      return _buildOptionItem(
                                          option, isDarkMode);
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

  Widget _buildOptionItem(SelectOption<T> option, bool isDarkMode) {
    final isSelected = _currentValues.contains(option.value);

    final textColor = option.disabled
        ? (isDarkMode
            ? Foundations.darkColors.textDisabled
            : Foundations.colors.textDisabled)
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
        onTap: option.disabled ? null : () => _toggleOption(option.value),
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
              // Checkbox
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: isSelected
                        ? ref.watch(appThemeProvider).primaryColor
                        : isDarkMode
                            ? Foundations.darkColors.border
                            : Foundations.colors.border,
                    width: 2,
                  ),
                  color: isSelected
                      ? ref.watch(appThemeProvider).primaryColor
                      : Colors.transparent,
                ),
                child: isSelected
                    ? const Center(
                        child: Icon(
                          Icons.check,
                          size: 14,
                          color: Colors.white,
                        ),
                      )
                    : null,
              ),
              SizedBox(width: Foundations.spacing.sm),

              // Option icon
              if (option.icon != null) ...[
                Icon(option.icon, size: 18, color: textColor),
                SizedBox(width: Foundations.spacing.sm),
              ],

              // Option label & description
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
                            ? Foundations.typography.medium
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
      SelectSize.medium => 40,
      SelectSize.large => 48,
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
          horizontal: Foundations.spacing.md,
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

    // Background and border colors
    final Color fillColor = switch (widget.variant) {
      SelectVariant.filled => isDarkMode
          ? Foundations.darkColors.inputBg
          : Foundations.colors.inputBg,
      SelectVariant.glass =>
        isDarkMode ? Foundations.darkColors.glass : Foundations.colors.glass,
      _ => Colors.transparent,
    };

    final Color borderColor = widget.errorText != null
        ? Foundations.colors.error
        : _isOpen
            ? theme.accentDark
            : (isDarkMode
                ? Foundations.darkColors.border
                : Foundations.colors.border);

    final selectedOptions = _selectedOptions;
    final bool showChips = selectedOptions.isNotEmpty;
    final String displayText = showChips ? '' : (widget.hint ?? '');

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
                          ? Foundations.borders.thick
                          : Foundations.borders.normal,
                    ),
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
                      crossAxisAlignment: showChips
                          ? CrossAxisAlignment.start
                          : CrossAxisAlignment.center,
                      children: [
                        // Leading icon
                        if (widget.leadingIcon != null && !showChips) ...[
                          Icon(
                            widget.leadingIcon,
                            size: 18,
                            color: textColor.withValues(alpha: 0.7),
                          ),
                          SizedBox(width: Foundations.spacing.sm),
                        ],

                        // Show either selected chips or placeholder text
                        if (showChips)
                          Expanded(
                            child:
                                _buildSelectedChips(context, selectedOptions),
                          )
                        else
                          Expanded(
                            child: Text(
                              displayText,
                              style: TextStyle(
                                color: textColor.withValues(alpha: 0.6),
                                fontSize: fontSize,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                        // Dropdown indicator
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

        // Error message
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

        // Description text
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

  Widget _buildSelectedChips(
      BuildContext context, List<SelectOption<T>> selectedOptions) {
    final theme = ref.watch(appThemeProvider);
    final isDarkMode = theme.isDarkMode;

    final List<Widget> chips = [];

    // Determine how many chips to show
    final int totalSelected = selectedOptions.length;
    final int visibleCount = totalSelected > widget.maxChipsVisible
        ? widget.maxChipsVisible
        : totalSelected;

    // Add visible chips
    for (int i = 0; i < visibleCount; i++) {
      chips.add(_buildChip(selectedOptions[i], isDarkMode));
    }

    // Add count chip if there are more selections
    if (totalSelected > widget.maxChipsVisible) {
      chips.add(
        Container(
          margin: EdgeInsets.only(
              right: Foundations.spacing.xs, bottom: Foundations.spacing.xs),
          padding: EdgeInsets.symmetric(
            horizontal: Foundations.spacing.sm,
            vertical: Foundations.spacing.xs,
          ),
          decoration: BoxDecoration(
            color: theme.primaryColor.withValues(alpha: 0.1),
            borderRadius: Foundations.borders.full,
          ),
          child: Text(
            '+${totalSelected - widget.maxChipsVisible}',
            style: TextStyle(
              fontSize: Foundations.typography.sm,
              color: theme.primaryColor,
            ),
          ),
        ),
      );
    }

    return Wrap(
      spacing: Foundations.spacing.xs,
      runSpacing: 0,
      children: chips,
    );
  }

  Widget _buildChip(SelectOption<T> option, bool isDarkMode) {
    return BaseChip(
      label: option.label,
      variant: ChipVariant.primary,
      size: ChipSize.small,
      onDismissed: widget.isDisabled ? null : () => _removeValue(option.value),
      backgroundColor:
          ref.watch(appThemeProvider).primaryColor.withValues(alpha: 0.1),
      textColor: ref.watch(appThemeProvider).primaryColor,
    );
  }
}
