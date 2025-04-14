import 'package:edconnect_admin/core/design_system/foundations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edconnect_admin/presentation/providers/theme_provider.dart';

enum CardVariant {
  /// Standard card with solid background
  standard,

  /// Card with subtle border and drop shadow
  elevated,

  /// Card with highlighted border
  outlined
}

class BaseCard extends ConsumerWidget {
  /// The child widget to be displayed inside the card
  final Widget child;

  /// Visual style variant of the card
  final CardVariant variant;

  /// Whether the card should take the full width of its parent
  final bool fullWidth;

  /// Custom padding for the card content
  final EdgeInsetsGeometry? padding;

  /// Optional custom background color
  final Color? backgroundColor;

  /// Optional border color (used for outlined variant)
  final Color? borderColor;

  /// Custom border radius
  final BorderRadius? borderRadius;

  /// Margin around the card
  final EdgeInsetsGeometry? margin;

  /// Whether the card should clip its content to its rounded corners
  final Clip? clipBehavior;

  /// Optional header widget above the main content
  final Widget? header;

  /// Optional footer widget below the main content
  final Widget? footer;

  final VoidCallback? onTap;

  const BaseCard({
    super.key,
    required this.child,
    this.variant = CardVariant.standard,
    this.fullWidth = false,
    this.padding,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius,
    this.margin,
    this.clipBehavior,
    this.header,
    this.footer,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeProvider);
    final isDarkMode = theme.isDarkMode;

    // Determine style properties based on variant
    final BorderRadius effectiveBorderRadius =
        borderRadius ?? Foundations.borders.md;

    final EdgeInsetsGeometry effectivePadding =
        padding ?? EdgeInsets.all(Foundations.spacing.xl);

    final EdgeInsetsGeometry effectiveMargin =
        margin ?? EdgeInsets.all(Foundations.spacing.md);

    // Determine background color based on variant and theme
    Color effectiveBackgroundColor;
    Color effectiveBorderColor;
    List<BoxShadow>? effectiveShadow;

    switch (variant) {
      case CardVariant.standard:
        effectiveBackgroundColor = backgroundColor ??
            (isDarkMode
                ? Foundations.darkColors.backgroundMuted
                : Foundations.colors.backgroundMuted);
        effectiveBorderColor = borderColor ?? Colors.transparent;
        effectiveShadow = null;
        break;

      case CardVariant.elevated:
        effectiveBackgroundColor = backgroundColor ??
            (isDarkMode
                ? Foundations.darkColors.surface
                : Foundations.colors.surface);
        effectiveBorderColor = borderColor ??
            (isDarkMode
                ? Foundations.darkColors.border
                : Foundations.colors.border);
        effectiveShadow = isDarkMode
            ? Foundations.effects.shadowMd
            : Foundations.effects.shadowMd;
        break;

      case CardVariant.outlined:
        effectiveBackgroundColor = backgroundColor ??
            (isDarkMode
                ? Foundations.darkColors.surface
                : Foundations.colors.surface);
        effectiveBorderColor = borderColor ??
            (isDarkMode
                ? Foundations.darkColors.border
                : Foundations.colors.border);
        effectiveShadow = null;
        break;
    }

    // Build the card content
    Widget cardContent = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (header != null) header!,
        Padding(
          padding: effectivePadding,
          child: child,
        ),
        if (footer != null) footer!,
      ],
    );

    // Apply full width if needed
    if (fullWidth) {
      cardContent = SizedBox(
        width: double.infinity,
        child: cardContent,
      );
    }

    // Create the card with the appropriate decoration
    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          onTap!();
        }
      },
      child: Container(
        margin: effectiveMargin,
        clipBehavior: clipBehavior ?? Clip.antiAlias,
        decoration: BoxDecoration(
          color: effectiveBackgroundColor,
          borderRadius: effectiveBorderRadius,
          border: Border.all(
            color: effectiveBorderColor,
            width: variant == CardVariant.outlined
                ? Foundations.borders.normal
                : 0,
          ),
          boxShadow: effectiveShadow,
        ),
        child: cardContent,
      ),
    );
  }
}
