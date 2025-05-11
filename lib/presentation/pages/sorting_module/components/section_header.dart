import 'package:flutter/material.dart';
import 'package:edconnect_admin/core/design_system/foundations.dart';
import 'package:edconnect_admin/presentation/providers/theme_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SectionHeader extends ConsumerWidget {
  final String title;
  final IconData icon;
  final Widget? actionButton;

  const SectionHeader({
    required this.title,
    required this.icon,
    this.actionButton,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeProvider);
    final isDarkMode = theme.isDarkMode;

    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: isDarkMode
              ? Foundations.darkColors.textMuted
              : Foundations.colors.textMuted,
        ),
        SizedBox(width: Foundations.spacing.sm),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: Foundations.typography.lg,
              fontWeight: Foundations.typography.semibold,
              color: isDarkMode
                  ? Foundations.darkColors.textPrimary
                  : Foundations.colors.textPrimary,
            ),
          ),
        ),
        if (actionButton != null) actionButton!,
      ],
    );
  }
}
