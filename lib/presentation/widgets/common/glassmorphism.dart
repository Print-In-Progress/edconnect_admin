import 'dart:ui';
import 'package:flutter/material.dart';

class GlassMorphismCard extends StatelessWidget {
  final Widget child;
  final double start;
  final double end;
  final Color color;
  final BorderRadius? borderRadius;
  final double? borderWidth;
  final double blurSigma;
  final Color? shadowColor;
  final double? elevation;
  final ShapeBorder? shape;
  final EdgeInsetsGeometry? margin;
  final Clip? clipBehavior;
  final bool borderOnForeground;
  final bool semanticContainer;

  const GlassMorphismCard({
    Key? key,
    required this.child,
    required this.start,
    required this.end,
    required this.color,
    this.borderRadius,
    this.borderWidth,
    this.blurSigma = 3,
    this.shadowColor,
    this.elevation,
    this.shape,
    this.margin,
    this.clipBehavior,
    this.borderOnForeground = true,
    this.semanticContainer = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final BorderRadius effectiveBorderRadius =
        borderRadius ?? BorderRadius.circular(15);
    final BorderSide effectiveBorderSide = BorderSide(
      color: color.withOpacity(0.2),
      width: borderWidth ?? 1.5,
    );

    return Semantics(
      container: semanticContainer,
      child: Container(
        margin: margin ?? const EdgeInsets.all(4.0),
        child: Material(
          type: MaterialType.card,
          color: Colors.transparent,
          shadowColor: shadowColor ?? Colors.black,
          elevation: elevation ?? 1.0,
          shape: shape ??
              RoundedRectangleBorder(
                borderRadius: effectiveBorderRadius,
                side: effectiveBorderSide,
              ),
          borderOnForeground: borderOnForeground,
          clipBehavior: clipBehavior ?? Clip.antiAliasWithSaveLayer,
          child: ClipRRect(
            borderRadius: effectiveBorderRadius,
            child: RepaintBoundary(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        color.withOpacity(start),
                        color.withOpacity(end),
                      ],
                      begin: AlignmentDirectional.topStart,
                      end: AlignmentDirectional.bottomEnd,
                    ),
                    borderRadius: effectiveBorderRadius,
                    border: Border.all(
                      color: color.withOpacity(0.2),
                      width: borderWidth ?? 1.5,
                    ),
                  ),
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
