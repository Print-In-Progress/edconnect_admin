import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edconnect_admin/core/design_system/foundations.dart';
import 'package:edconnect_admin/presentation/providers/theme_provider.dart';
import 'package:edconnect_admin/presentation/widgets/common/cards/base_card.dart';

class InfoCard extends ConsumerWidget {
  final List<Widget> children;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const InfoCard({
    required this.children,
    this.padding,
    this.margin,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeProvider);
    final isDarkMode = theme.isDarkMode;

    return BaseCard(
      variant: CardVariant.outlined,
      margin: margin ?? EdgeInsets.zero,
      child: Padding(
        padding: padding ?? EdgeInsets.all(Foundations.spacing.lg),
        child: Column(
          children: [
            ...children.asMap().entries.map((entry) {
              // Add divider between items, but not after the last one
              return Column(
                children: [
                  entry.value,
                  if (entry.key < children.length - 1)
                    Divider(
                      height: Foundations.spacing.xl,
                      color: isDarkMode
                          ? Foundations.darkColors.border
                          : Foundations.colors.border,
                    ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
