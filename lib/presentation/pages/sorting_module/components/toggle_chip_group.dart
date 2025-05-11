import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edconnect_admin/core/design_system/foundations.dart';
import 'package:edconnect_admin/presentation/providers/theme_provider.dart';

class ToggleChipGroup<T> extends ConsumerWidget {
  final String label;
  final List<(T value, String label, Color? color)> options;
  final T? selectedValue;
  final ValueChanged<T?> onChanged;

  const ToggleChipGroup({
    required this.label,
    required this.options,
    required this.selectedValue,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: Foundations.typography.base,
            fontWeight: Foundations.typography.medium,
            color: theme.isDarkMode
                ? Foundations.darkColors.textPrimary
                : Foundations.colors.textPrimary,
          ),
        ),
        SizedBox(height: Foundations.spacing.sm),
        Wrap(
          spacing: Foundations.spacing.xs,
          children: options.map((option) {
            final isSelected = selectedValue == option.$1;
            return FilterChip(
              label: Text(option.$2),
              selected: isSelected,
              showCheckmark: false,
              backgroundColor: theme.isDarkMode
                  ? Foundations.darkColors.backgroundMuted
                  : Foundations.colors.backgroundMuted,
              selectedColor: option.$3?.withValues(alpha: 0.1) ??
                  (theme.isDarkMode
                      ? theme.accentLight.withValues(alpha: 0.1)
                      : theme.accentLight.withValues(alpha: 0.1)),
              labelStyle: TextStyle(
                color: isSelected
                    ? option.$3 ??
                        (theme.isDarkMode
                            ? theme.accentLight
                            : theme.accentLight)
                    : theme.isDarkMode
                        ? Foundations.darkColors.textPrimary
                        : Foundations.colors.textPrimary,
                fontWeight: isSelected
                    ? Foundations.typography.medium
                    : Foundations.typography.regular,
              ),
              onSelected: (_) => onChanged(isSelected ? null : option.$1),
            );
          }).toList(),
        ),
      ],
    );
  }
}
