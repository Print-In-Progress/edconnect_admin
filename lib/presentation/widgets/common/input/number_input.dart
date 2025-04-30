import 'package:edconnect_admin/core/design_system/foundations.dart';
import 'package:edconnect_admin/presentation/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'base_input.dart';

enum NumberFormatType {
  integer,
  decimal,
}

class NumberInputController {
  num? _value;

  /// Creates a controller with an optional initial value
  NumberInputController({num? initialValue}) : _value = initialValue;

  num? get value => _value;

  /// Set new value
  set value(num? newValue) {
    _value = newValue;
  }

  void dispose() {
    _value = null;
  }
}

class NumberInput extends ConsumerStatefulWidget {
  /// Number input controller
  final NumberInputController? controller;

  /// Label text
  final String? label;

  /// Hint text
  final String? hint;

  /// Description text
  final String? description;

  /// Whether the field is required
  final bool isRequired;

  /// Whether the field is disabled
  final bool isDisabled;

  /// Initial value
  final num? initialValue;

  /// Callback when value changes
  final ValueChanged<num?>? onChanged;

  /// Min allowed value
  final num? min;

  /// Max allowed value
  final num? max;

  /// Number of decimal places (if decimal type)
  final int decimalPlaces;

  /// Whether to show stepper buttons
  final bool showStepper;

  /// Step value for increment/decrement
  final num step;

  /// Text or symbol to show before the number (e.g., "$")
  final String? prefix;

  /// Text to show after the number (e.g., "USD")
  final String? suffix;

  /// Whether to format with thousands separator
  final bool useThousandsSeparator;

  /// Type of number format
  final NumberFormatType type;

  /// Input size variant
  final InputSize size;

  /// Input style variant
  final InputVariant variant;

  /// Whether to take full width
  final bool fullWidth;

  /// Custom width
  final double? width;

  const NumberInput({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.description,
    this.isRequired = false,
    this.isDisabled = false,
    this.initialValue,
    this.onChanged,
    this.min,
    this.max,
    this.decimalPlaces = 2,
    this.showStepper = false,
    this.step = 1,
    this.prefix,
    this.suffix,
    this.useThousandsSeparator = true,
    this.type = NumberFormatType.integer,
    this.size = InputSize.medium,
    this.variant = InputVariant.default_,
    this.fullWidth = true,
    this.width,
  });

  @override
  ConsumerState<NumberInput> createState() => _NumberInputState();
}

class _NumberInputState extends ConsumerState<NumberInput> {
  late final TextEditingController _controller;
  num? _value;

  @override
  void initState() {
    super.initState();
    _value = widget.controller?._value ?? widget.initialValue;
    _controller = TextEditingController(text: _formatValue(_value));
  }

  void _updateValue(num? newValue) {
    if (newValue == _value) return;

    if (newValue != null) {
      if (widget.min != null && newValue < widget.min!) {
        newValue = widget.min;
      }
      if (widget.max != null && newValue! > widget.max!) {
        newValue = widget.max;
      }
    }

    setState(() {
      _value = newValue;
      if (widget.controller != null) {
        widget.controller!._value = newValue;
      }
      _controller.text = _formatValue(newValue);
    });

    widget.onChanged?.call(newValue);
  }

  String _formatValue(num? value) {
    if (value == null) return '';

    final pattern = widget.type == NumberFormatType.decimal
        ? widget.useThousandsSeparator
            ? '#,##0.${'0' * widget.decimalPlaces}'
            : '#0.${'0' * widget.decimalPlaces}'
        : widget.useThousandsSeparator
            ? '#,##0'
            : '#0';

    return NumberFormat(pattern).format(value);
  }

  num? _parseValue(String text) {
    if (text.isEmpty) return null;

    try {
      final cleanText = text.replaceAll(',', '');
      return widget.type == NumberFormatType.decimal
          ? double.parse(cleanText)
          : int.parse(cleanText);
    } catch (e) {
      return null;
    }
  }

  void _increment() {
    final currentValue = _value ?? 0;
    _updateValue(currentValue + widget.step);
  }

  void _decrement() {
    final currentValue = _value ?? 0;
    _updateValue(currentValue - widget.step);
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(appThemeProvider);
    final isDarkMode = theme.isDarkMode;

    final borderRadius = Foundations.borders.sm;
    final height = switch (widget.size) {
      InputSize.small => 32.0,
      InputSize.medium => 40.0,
      InputSize.large => 48.0,
    };

    final Color descriptionColor = widget.isDisabled
        ? (isDarkMode
            ? Foundations.darkColors.textDisabled
            : Foundations.colors.textDisabled)
        : (isDarkMode
            ? Foundations.darkColors.textMuted
            : Foundations.colors.textMuted);

    final Color fillColor = switch (widget.variant) {
      InputVariant.filled => isDarkMode
          ? Foundations.darkColors.inputBg
          : Foundations.colors.inputBg,
      _ => Colors.transparent,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Row(
            children: [
              Text(
                widget.label!,
                style: TextStyle(
                  fontSize: Foundations.typography.sm,
                  fontWeight: Foundations.typography.medium,
                  color: widget.isDisabled
                      ? isDarkMode
                          ? Foundations.darkColors.textDisabled
                          : Foundations.colors.textDisabled
                      : isDarkMode
                          ? Foundations.darkColors.textSecondary
                          : Foundations.colors.textSecondary,
                ),
              ),
              if (widget.isRequired)
                Text(
                  ' *',
                  style: TextStyle(
                    color: Foundations.colors.warning,
                    fontSize: Foundations.typography.sm,
                  ),
                ),
            ],
          ),
          SizedBox(height: Foundations.spacing.xs),
        ],
        SizedBox(
          height: height,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  enabled: !widget.isDisabled,
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                    fontSize: Foundations.typography.base,
                    color: widget.isDisabled
                        ? isDarkMode
                            ? Foundations.darkColors.textDisabled
                            : Foundations.colors.textDisabled
                        : isDarkMode
                            ? Foundations.darkColors.textPrimary
                            : Foundations.colors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: Foundations.spacing.md,
                    ),
                    hintText: widget.hint,
                    prefixText: widget.prefix,
                    suffixText: widget.suffix,
                    border: OutlineInputBorder(
                      borderRadius: borderRadius,
                      borderSide: BorderSide(
                        color: isDarkMode
                            ? Foundations.darkColors.border
                            : Foundations.colors.border,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: borderRadius,
                      borderSide: BorderSide(
                        color: isDarkMode
                            ? Foundations.darkColors.border
                            : Foundations.colors.border,
                      ),
                    ),
                    hoverColor: isDarkMode
                        ? Foundations.darkColors.backgroundSubtle
                            .withValues(alpha: 0.3)
                        : theme.accentLight.withValues(alpha: 0.05),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: borderRadius,
                      borderSide: BorderSide(
                        color: theme.primaryColor,
                        width: Foundations.borders.thick,
                      ),
                    ),
                    filled: true,
                    fillColor: fillColor,
                  ),
                  inputFormatters: [
                    TextInputFormatter.withFunction((oldValue, newValue) {
                      if (newValue.text.isEmpty) return newValue;
                      try {
                        final parsed = _parseValue(newValue.text);
                        if (parsed == null) return oldValue;
                        if (widget.min != null && parsed < widget.min!) {
                          return oldValue;
                        }
                        if (widget.max != null && parsed > widget.max!) {
                          return oldValue;
                        }
                        return newValue;
                      } catch (e) {
                        return oldValue;
                      }
                    }),
                  ],
                  onChanged: (value) {
                    _updateValue(_parseValue(value));
                    // Maintain cursor position at the end of input
                    _controller.selection = TextSelection.fromPosition(
                      TextPosition(offset: _controller.text.length),
                    );
                  },
                ),
              ),
              if (widget.showStepper) ...[
                SizedBox(width: Foundations.spacing.px),
                Column(
                  children: [
                    SizedBox(
                      height: height / 2,
                      width: 32,
                      child: Material(
                        color: isDarkMode
                            ? Foundations.darkColors.backgroundSubtle
                            : Foundations.colors.backgroundSubtle,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(borderRadius.topRight.x),
                        ),
                        child: InkWell(
                          onTap: widget.isDisabled ? null : _increment,
                          child: Icon(
                            Icons.keyboard_arrow_up,
                            size: 16,
                            color: widget.isDisabled
                                ? isDarkMode
                                    ? Foundations.darkColors.textDisabled
                                    : Foundations.colors.textDisabled
                                : isDarkMode
                                    ? Foundations.darkColors.textSecondary
                                    : Foundations.colors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: height / 2,
                      width: 32,
                      child: Material(
                        color: isDarkMode
                            ? Foundations.darkColors.backgroundSubtle
                            : Foundations.colors.backgroundSubtle,
                        borderRadius: BorderRadius.only(
                          bottomRight:
                              Radius.circular(borderRadius.bottomRight.x),
                        ),
                        child: InkWell(
                          onTap: widget.isDisabled ? null : _decrement,
                          child: Icon(
                            Icons.keyboard_arrow_down,
                            size: 16,
                            color: widget.isDisabled
                                ? isDarkMode
                                    ? Foundations.darkColors.textDisabled
                                    : Foundations.colors.textDisabled
                                : isDarkMode
                                    ? Foundations.darkColors.textSecondary
                                    : Foundations.colors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        if (widget.description != null) ...[
          SizedBox(height: Foundations.spacing.xs),
          Text(
            widget.description!,
            style: TextStyle(
              fontSize: Foundations.typography.sm,
              color: descriptionColor,
            ),
          ),
        ],
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
