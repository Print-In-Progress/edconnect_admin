import 'package:edconnect_admin/core/design_system/foundations.dart';
import 'package:edconnect_admin/core/models/app_theme.dart';
import 'package:edconnect_admin/presentation/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ButtonSize { small, medium, large }

enum ButtonVariant { filled, outlined, text }

class BaseButton extends ConsumerStatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final ButtonSize size;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final bool isLoading;
  final bool fullWidth;
  final bool disabled;
  final Color? foregroundColor;
  final Color? backgroundColor;

  const BaseButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = ButtonVariant.filled,
    this.size = ButtonSize.medium,
    this.prefixIcon,
    this.suffixIcon,
    this.isLoading = false,
    this.fullWidth = false,
    this.disabled = false,
    this.foregroundColor,
    this.backgroundColor,
  });

  @override
  ConsumerState<BaseButton> createState() => _BaseButtonState();
}

class _BaseButtonState extends ConsumerState<BaseButton> {
  double get _height {
    return switch (widget.size) {
      ButtonSize.small => 32.0,
      ButtonSize.medium => 40.0,
      ButtonSize.large => 48.0,
    };
  }

  double get _fontSize {
    return switch (widget.size) {
      ButtonSize.small => 12.0,
      ButtonSize.medium => 14.0,
      ButtonSize.large => 16.0,
    };
  }

  EdgeInsets get _padding {
    return switch (widget.size) {
      ButtonSize.small => const EdgeInsets.all(12),
      ButtonSize.medium => const EdgeInsets.all(16),
      ButtonSize.large => const EdgeInsets.all(20),
    };
  }

  Widget _buildLoadingIndicator(BuildContext context, AppTheme appTheme) {
    final Color color = switch (widget.variant) {
      ButtonVariant.filled => appTheme.primaryColor,
      ButtonVariant.outlined || ButtonVariant.text => appTheme.isDarkMode
          ? Foundations.darkColors.textPrimary
          : appTheme.primaryColor,
    };

    return SizedBox(
      height: _fontSize * 1.2,
      width: _fontSize * 1.2,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = ref.watch(appThemeProvider);
    final ButtonStyle style = switch (widget.variant) {
      ButtonVariant.filled => FilledButton.styleFrom(
          minimumSize: Size(0, _height),
          padding: _padding,
          textStyle: TextStyle(fontSize: _fontSize),
          shape: RoundedRectangleBorder(
            borderRadius: Foundations.borders.md,
          ),
          overlayColor: appTheme.isDarkMode
              ? HSLColor.fromColor(
                      widget.backgroundColor ?? appTheme.primaryColor)
                  .withLightness((HSLColor.fromColor(widget.backgroundColor ??
                                  appTheme.primaryColor)
                              .lightness -
                          0.05)
                      .clamp(0.0, 1.0))
                  .toColor()
              : appTheme.accentDark,
          backgroundColor: WidgetStateColor.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return appTheme.isDarkMode
                  ? Foundations.darkColors.textDisabled
                  : Foundations.colors.textDisabled;
            }
            return widget.backgroundColor ?? appTheme.primaryColor;
          }),
        ),
      ButtonVariant.outlined => OutlinedButton.styleFrom(
          minimumSize: Size(0, _height),
          padding: _padding,
          textStyle: TextStyle(fontSize: _fontSize),
          foregroundColor: widget.disabled
              ? appTheme.isDarkMode
                  ? Foundations.darkColors.textDisabled
                  : Foundations.colors.textDisabled
              : widget.foregroundColor ??
                  (appTheme.isDarkMode
                      ? Foundations.darkColors.textPrimary
                      : appTheme.primaryColor),
          shape: RoundedRectangleBorder(
            borderRadius: Foundations.borders.md,
          ),
          overlayColor: appTheme.isDarkMode
              ? Foundations.darkColors.backgroundSubtle.withValues(alpha: 0.5)
              : appTheme.accentLight.withValues(alpha: 0.1),
          backgroundColor: Colors.transparent,
        ).copyWith(side: WidgetStateBorderSide.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return BorderSide(
              color: appTheme.isDarkMode
                  ? Foundations.darkColors.textDisabled
                  : Foundations.colors.textDisabled,
              width: Foundations.borders.normal,
            );
          }
          return BorderSide(
            color: Foundations.colors.glassBorder,
            width: Foundations.borders.normal,
          );
        })),
      ButtonVariant.text => TextButton.styleFrom(
          minimumSize: Size(0, _height),
          padding: _padding,
          textStyle:
              TextStyle(fontSize: _fontSize, overflow: TextOverflow.ellipsis),
          shape: RoundedRectangleBorder(
            borderRadius: Foundations.borders.md,
          ),
          iconColor: widget.disabled
              ? appTheme.isDarkMode
                  ? Foundations.darkColors.textDisabled
                  : Foundations.colors.textDisabled
              : (widget.foregroundColor ??
                  (appTheme.isDarkMode
                      ? Foundations.darkColors.textPrimary
                      : appTheme.primaryColor)),
          foregroundColor: widget.disabled
              ? appTheme.isDarkMode
                  ? Foundations.darkColors.textDisabled
                  : Foundations.colors.textDisabled
              : (widget.foregroundColor ??
                  (appTheme.isDarkMode
                      ? Foundations.darkColors.textPrimary
                      : appTheme.primaryColor)),
          overlayColor: appTheme.isDarkMode
              ? Foundations.darkColors.backgroundSubtle.withValues(alpha: 0.5)
              : appTheme.accentLight.withValues(alpha: 0.1),
          disabledBackgroundColor: appTheme.isDarkMode
              ? Foundations.darkColors.textDisabled
              : Foundations.colors.textDisabled,
          backgroundColor: Colors.transparent,
        ),
    };

    Widget buttonChild = Row(
      mainAxisSize: widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.prefixIcon != null && !widget.isLoading) ...[
          Icon(widget.prefixIcon),
          SizedBox(width: Foundations.spacing.sm),
        ],
        if (widget.isLoading) ...[
          _buildLoadingIndicator(context, appTheme),
          SizedBox(width: Foundations.spacing.sm),
        ],
        Text(widget.label),
        if (widget.suffixIcon != null && !widget.isLoading) ...[
          SizedBox(width: Foundations.spacing.sm),
          Icon(widget.suffixIcon),
        ],
      ],
    );

    if (widget.fullWidth) {
      buttonChild = SizedBox(
        width: double.infinity,
        child: buttonChild,
      );
    }

    return switch (widget.variant) {
      ButtonVariant.filled => FilledButton(
          onPressed:
              (widget.isLoading || widget.disabled) ? null : widget.onPressed,
          style: style,
          child: buttonChild,
        ),
      ButtonVariant.outlined => OutlinedButton(
          onPressed:
              (widget.isLoading || widget.disabled) ? null : widget.onPressed,
          style: style,
          child: buttonChild,
        ),
      ButtonVariant.text => TextButton(
          onPressed:
              (widget.isLoading || widget.disabled) ? null : widget.onPressed,
          style: style,
          child: buttonChild,
        ),
    };
  }
}
