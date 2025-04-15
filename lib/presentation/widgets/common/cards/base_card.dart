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

class BaseCard extends ConsumerStatefulWidget {
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

  /// Whether the card is selectable (used for hover effects)
  final bool isSelectable;

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
    this.isSelectable = false,
  });

  @override
  ConsumerState<BaseCard> createState() => _BaseCardState();
}

class _BaseCardState extends ConsumerState<BaseCard> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(appThemeProvider);
    final isDarkMode = theme.isDarkMode;

    // Determine style properties based on variant
    final BorderRadius effectiveBorderRadius =
        widget.borderRadius ?? Foundations.borders.md;

    final EdgeInsetsGeometry effectivePadding =
        widget.padding ?? EdgeInsets.all(Foundations.spacing.xl);

    final EdgeInsetsGeometry effectiveMargin =
        widget.margin ?? EdgeInsets.all(Foundations.spacing.md);

    // Determine background color based on variant and theme
    Color effectiveBackgroundColor;
    Color effectiveBorderColor;
    List<BoxShadow>? effectiveShadow;

    final bool isInteractive = widget.isSelectable && widget.onTap != null;

    switch (widget.variant) {
      case CardVariant.standard:
        effectiveBackgroundColor = widget.backgroundColor ??
            (isDarkMode
                ? Foundations.darkColors.backgroundMuted
                : Foundations.colors.backgroundMuted);
        effectiveBorderColor = widget.borderColor ?? Colors.transparent;
        effectiveShadow = null;
        break;

      case CardVariant.elevated:
        effectiveBackgroundColor = widget.backgroundColor ??
            (isDarkMode
                ? Foundations.darkColors.surface
                : Foundations.colors.surface);
        effectiveBorderColor = widget.borderColor ??
            (isDarkMode
                ? Foundations.darkColors.border
                : Foundations.colors.border);
        effectiveShadow = isDarkMode
            ? Foundations.effects.shadowMd
            : Foundations.effects.shadowMd;

        // Enhanced shadow on hover for elevated cards
        if (isInteractive && _isHovering) {
          effectiveShadow = isDarkMode
              ? Foundations.effects.shadowLg
              : Foundations.effects.shadowLg;
        }
        break;

      case CardVariant.outlined:
        effectiveBackgroundColor = widget.backgroundColor ??
            (isDarkMode
                ? Foundations.darkColors.surface
                : Foundations.colors.surface);
        effectiveBorderColor = widget.borderColor ??
            (isDarkMode
                ? Foundations.darkColors.border
                : Foundations.colors.border);
        effectiveShadow = null;

        // Add subtle shadow on hover for outlined cards
        if (isInteractive && _isHovering) {
          effectiveShadow = isDarkMode
              ? Foundations.effects.shadowSm
              : Foundations.effects.shadowSm;
          effectiveBorderColor =
              theme.isDarkMode ? theme.accentLight : theme.accentLight;
        }
        break;
    }

    // Apply slight background tint on hover for standard cards
    if (isInteractive &&
        _isHovering &&
        widget.variant == CardVariant.standard) {
      effectiveBackgroundColor = isDarkMode
          ? Foundations.darkColors.backgroundMuted.withValues(alpha: 0.8)
          : Foundations.colors.backgroundMuted.withValues(alpha: 0.8);
    }

    // Build the card content
    Widget cardContent = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.header != null) widget.header!,
        Padding(
          padding: effectivePadding,
          child: widget.child,
        ),
        if (widget.footer != null) widget..footer!,
      ],
    );

    // Apply full width if needed
    if (widget.fullWidth) {
      cardContent = SizedBox(
        width: double.infinity,
        child: cardContent,
      );
    }

    // Create the card with the appropriate decoration
    return MouseRegion(
      cursor:
          isInteractive ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => isInteractive ? setState(() => _isHovering = true) : null,
      onExit: (_) => isInteractive ? setState(() => _isHovering = false) : null,
      child: GestureDetector(
        onTap: () {
          if (widget.onTap != null) {
            widget.onTap!();
          }
        },
        child: AnimatedContainer(
          duration: Foundations.effects.shortAnimation,
          margin: effectiveMargin,
          clipBehavior: widget.clipBehavior ?? Clip.antiAlias,
          decoration: BoxDecoration(
            color: effectiveBackgroundColor,
            borderRadius: effectiveBorderRadius,
            border: Border.all(
              color: effectiveBorderColor,
              width: widget.variant == CardVariant.outlined
                  ? Foundations.borders.normal
                  : 0,
            ),
            boxShadow: effectiveShadow,
          ),
          child: cardContent,
        ),
      ),
    );
  }
}
