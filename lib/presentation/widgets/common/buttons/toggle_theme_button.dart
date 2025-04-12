import 'package:edconnect_admin/core/design_system/foundations.dart';
import 'package:edconnect_admin/presentation/providers/theme_provider.dart';
import 'package:edconnect_admin/presentation/widgets/common/buttons/base_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ToggleThemeButton extends ConsumerWidget {
  /// Size of the icon button
  final IconButtonSize size;

  /// Variant style for the button
  final IconButtonVariant variant;

  /// Custom tooltip text (defaults to "Toggle theme")
  final String? tooltip;

  /// Custom color for the button (uses accent color if not provided)
  final Color? color;

  const ToggleThemeButton({
    super.key,
    this.size = IconButtonSize.large,
    this.variant = IconButtonVariant.ghost,
    this.tooltip,
    this.color,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeProvider);
    final isDarkMode = theme.isDarkMode;

    return BaseIconButton(
      icon: isDarkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
      onPressed: () =>
          ref.read(appThemeProvider.notifier).setDarkMode(!isDarkMode),
      size: size,
      variant: variant,
      tooltip: tooltip ??
          (isDarkMode ? "Switch to light mode" : "Switch to dark mode"),
      color: color ?? Foundations.colors.surface,
    );
  }
}
