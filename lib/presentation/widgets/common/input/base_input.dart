import 'package:edconnect_admin/core/design_system/foundations.dart';
import 'package:edconnect_admin/presentation/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edconnect_admin/l10n/app_localizations.dart';
import 'package:edconnect_admin/core/errors/domain_exception.dart';
import 'package:edconnect_admin/core/validation/validators/text_field_validator.dart';

enum InputSize { small, medium, large }

enum InputVariant { default_, outlined, filled }

class BaseInput extends ConsumerWidget {
  /// Text editing controller
  final TextEditingController? controller;

  /// Input label text
  final String? label;

  /// Hint/placeholder text shown when input is empty
  final String? hint;

  /// Description text shown below the input
  final String? description;

  /// Whether this field is required
  final bool isRequired;

  /// Whether the input is disabled
  final bool isDisabled;

  /// Type of validation to perform
  final TextFieldType type;

  /// Minimum text length for validation
  final int? minLength;

  /// Maximum text length for validation
  final int? maxLength;

  /// Callback for when text changes
  final ValueChanged<String>? onChanged;

  /// Callback for when the input is tapped
  final VoidCallback? onTap;

  /// Whether the field is read-only
  final bool readOnly;

  /// Maximum number of lines
  final int? maxLines;

  /// Minimum number of lines
  final int? minLines;

  /// Focus node
  final FocusNode? focusNode;

  /// Leading icon
  final IconData? leadingIcon;

  /// Custom trailing widget (e.g., icon button)
  final Widget? trailingIcon;

  /// Optional button displayed next to the input
  final Widget? button;

  /// Whether to show the label
  final bool showLabel;

  /// Initial value (use either this or controller)
  final String? initialValue;

  /// Whether to obscure text (for passwords)
  final bool obscureText;

  /// Keyboard type for the field
  final TextInputType keyboardType;

  /// Visual size variant
  final InputSize size;

  /// Style variant
  final InputVariant variant;

  /// Whether the input should take full width
  final bool fullWidth;

  /// Custom width
  final double? width;

  /// Controls when validation is triggered
  final AutovalidateMode? autovalidateMode;

  /// Additional child widget to display (for complex inputs)
  final Widget? child;

  /// Spacing between input and button (if present)
  final double spacing;

  const BaseInput({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.description,
    this.isRequired = false,
    this.isDisabled = false,
    this.type = TextFieldType.text,
    this.minLength,
    this.maxLength,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.maxLines = 1,
    this.minLines,
    this.focusNode,
    this.leadingIcon,
    this.trailingIcon,
    this.button,
    this.showLabel = true,
    this.initialValue,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.size = InputSize.medium,
    this.variant = InputVariant.default_,
    this.fullWidth = true,
    this.width,
    this.autovalidateMode,
    this.child,
    this.spacing = 8.0,
  }) : assert(!(controller != null && initialValue != null),
            'You can only provide either a controller or an initial value, not both.');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeProvider);
    final isDarkMode = theme.isDarkMode;
    final l10n = AppLocalizations.of(context)!;
    final Color accentForFocus = theme.accentDark;
    // Height based on size - matching Shadcn's common sizes
    final double inputHeight = switch (size) {
      InputSize.small => 32.0,
      InputSize.medium => 40.0,
      InputSize.large => 48.0,
    };

    // Padding for inside the input field
    final EdgeInsets contentPadding = switch (size) {
      InputSize.small => EdgeInsets.symmetric(
          horizontal: Foundations.spacing.lg,
          vertical: Foundations.spacing.xs,
        ),
      InputSize.medium => EdgeInsets.symmetric(
          horizontal: Foundations.spacing.lg,
          vertical: Foundations.spacing.sm,
        ),
      InputSize.large => EdgeInsets.symmetric(
          horizontal: Foundations.spacing.lg,
          vertical: Foundations.spacing.md,
        ),
    };

    // Font sizes
    final double fontSize = switch (size) {
      InputSize.small => Foundations.typography.sm,
      InputSize.medium => Foundations.typography.base,
      InputSize.large => Foundations.typography.base,
    };

    final double labelFontSize = Foundations.typography.sm;
    final double descriptionFontSize = Foundations.typography.xs;

    // Colors
    final Color textColor = isDisabled
        ? (isDarkMode
            ? Foundations.darkColors.textDisabled
            : Foundations.colors.textDisabled)
        : (isDarkMode
            ? Foundations.darkColors.textPrimary
            : Foundations.colors.textPrimary);

    final Color labelColor = isDisabled
        ? (isDarkMode
            ? Foundations.darkColors.textDisabled
            : Foundations.colors.textDisabled)
        : (isDarkMode
            ? Foundations.darkColors.textSecondary
            : Foundations.colors.textSecondary);

    final Color descriptionColor = isDisabled
        ? (isDarkMode
            ? Foundations.darkColors.textDisabled
            : Foundations.colors.textDisabled)
        : (isDarkMode
            ? Foundations.darkColors.textMuted
            : Foundations.colors.textMuted);

    final Color fillColor = switch (variant) {
      InputVariant.filled => isDarkMode
          ? Foundations.darkColors.inputBg
          : Foundations.colors.inputBg,
      _ => Colors.transparent,
    };

    // Build the label above the input
    Widget buildLabel() {
      if (!showLabel || label == null) return const SizedBox.shrink();

      return Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          children: [
            Text(
              isRequired ? '$label *' : label!,
              style: TextStyle(
                fontSize: labelFontSize,
                fontWeight: Foundations.typography.medium,
                color: labelColor,
              ),
            ),
          ],
        ),
      );
    }

    // Build description text below the input
    Widget buildDescription() {
      if (description == null) return const SizedBox.shrink();

      return Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Text(
          description!,
          style: TextStyle(
            fontSize: descriptionFontSize,
            color: descriptionColor,
          ),
        ),
      );
    }

    // Build the TextFormField with proper Shadcn-style borders
    Widget buildInput() {
      return TextFormField(
        controller: controller,
        initialValue: initialValue,
        focusNode: focusNode,
        onTap: onTap,
        readOnly: readOnly,
        enabled: !isDisabled,
        maxLines: obscureText ? 1 : maxLines,
        minLines: minLines,
        keyboardType: keyboardType,
        obscureText: obscureText,
        onChanged: onChanged,
        autovalidateMode: autovalidateMode ?? AutovalidateMode.disabled,
        validator: (value) {
          try {
            final validator = TextFieldValidator(
              type: type,
              required: isRequired,
              minLength: minLength,
              maxLength: maxLength,
            );
            validator.validate(value ?? '');
            return null;
          } on DomainException catch (e) {
            return switch (e.code) {
              ErrorCode.fieldRequired => l10n.validationRequired,
              ErrorCode.fieldTooShort => l10n.validationTextTooShort,
              ErrorCode.fieldTooLong => l10n.validationTextTooLong,
              ErrorCode.invalidEmail => l10n.validationEmail,
              _ => l10n.errorUnexpected,
            };
          }
        },
        style: TextStyle(
          fontSize: fontSize,
          color: textColor,
        ),
        decoration: InputDecoration(
          constraints: BoxConstraints(
            minHeight: inputHeight,
          ),
          hintText: hint,
          hoverColor: isDarkMode
              ? Foundations.darkColors.backgroundSubtle.withValues(alpha: 0.3)
              : theme.accentLight.withValues(alpha: 0.05),

          hintStyle: TextStyle(
            fontSize: fontSize,
            color: isDarkMode
                ? Foundations.darkColors.textMuted
                : Foundations.colors.textMuted.withValues(alpha: 0.8),
          ),
          contentPadding: contentPadding,
          filled: true,
          fillColor: fillColor,

          // Icons
          prefixIcon: leadingIcon != null
              ? Icon(leadingIcon,
                  color: isDisabled
                      ? (isDarkMode
                          ? Foundations.darkColors.textDisabled
                          : Foundations.colors.textDisabled)
                      : null)
              : null,
          suffixIcon: trailingIcon,

          // Border styling - true to Shadcn's design
          border: _buildBorder(isDarkMode, false, false, accentForFocus),
          enabledBorder: _buildBorder(isDarkMode, false, false, accentForFocus),
          focusedBorder: _buildBorder(isDarkMode, true, false, accentForFocus),
          errorBorder: _buildBorder(isDarkMode, false, true, accentForFocus),
          focusedErrorBorder:
              _buildBorder(isDarkMode, true, true, accentForFocus),
          disabledBorder: _buildBorder(isDarkMode, false, false, accentForFocus,
              isDisabled: true),
        ),
      );
    }

    // Assemble the complete component
    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label above the input (Shadcn style)
        buildLabel(),

        // Input field with optional button alongside
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            fullWidth
                ? Expanded(child: buildInput())
                : SizedBox(width: width, child: buildInput()),
            if (button != null) ...[
              SizedBox(width: spacing),
              button!,
            ],
          ],
        ),

        // Optional child widget (for complex inputs)
        if (child != null) child!,

        // Description text below the input
        buildDescription(),
      ],
    );

    return content;
  }

  // Helper to build the correct border type according to Shadcn guidelines
  InputBorder _buildBorder(
      bool isDarkMode, bool isFocused, bool hasError, Color accentForFocus,
      {bool isDisabled = false}) {
    // Determine border color based on state
    final Color borderColor;

    if (hasError) {
      borderColor = Foundations.colors.error;
    } else if (isFocused) {
      borderColor = accentForFocus; // Use accent color for focus state
    } else if (isDisabled) {
      borderColor = isDarkMode
          ? Foundations.darkColors.border.withValues(alpha: 0.4)
          : Foundations.colors.border.withValues(alpha: 0.4);
    } else {
      borderColor = isDarkMode
          ? Foundations.darkColors.border
          : Foundations.colors.border;
    }

    // The rest of the method remains the same
    final double borderWidth =
        isFocused ? Foundations.borders.thick : Foundations.borders.normal;

    return switch (variant) {
      InputVariant.default_ || InputVariant.filled => OutlineInputBorder(
          borderRadius: Foundations.borders.sm,
          borderSide: BorderSide(
            color: borderColor,
            width: borderWidth,
          ),
        ),
      InputVariant.outlined => OutlineInputBorder(
          borderRadius: Foundations.borders.sm,
          borderSide: BorderSide(
            color: borderColor,
            width: borderWidth,
          ),
        ),
    };
  }
}
