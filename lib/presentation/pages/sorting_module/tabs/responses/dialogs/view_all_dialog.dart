import 'package:edconnect_admin/core/design_system/color_generator.dart';
import 'package:edconnect_admin/core/design_system/foundations.dart';
import 'package:edconnect_admin/domain/entities/sorting_survey.dart';
import 'package:edconnect_admin/presentation/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edconnect_admin/presentation/pages/sorting_module/utils/parameter_formatter.dart';

class ViewAllDialog extends ConsumerWidget {
  final String paramName;
  final SortingSurvey survey;
  const ViewAllDialog({
    super.key,
    required this.paramName,
    required this.survey,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeProvider);

    final responses = survey.responses;
    final isBinary = survey.parameters
        .any((p) => p['name'] == paramName && p['type'] == 'binary');
    final isSexParameter = paramName == 'sex';

    // Build distribution map
    Map<String, int> distribution = {};
    for (final response in responses.values) {
      final rawValue = response[paramName]?.toString() ?? 'Unknown';

      // Format value based on parameter type
      final formattedValue = switch (true) {
        _ when isSexParameter =>
          ParameterFormatter.formatSexForDisplay(rawValue),
        _ when isBinary => rawValue.toLowerCase() == 'yes' ? 'Yes' : 'No',
        _ => ParameterFormatter.formatParameterNameForDisplay(rawValue),
      };

      distribution[formattedValue] = (distribution[formattedValue] ?? 0) + 1;
    }

    // Sort entries by count
    final sortedEntries = distribution.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final total = distribution.values.fold(0, (sum, count) => sum + count);
    final uniqueCount = distribution.length;

    return Column(
      children: [
        // Header
        Row(
          children: [
            Expanded(
              flex: 3,
              child: Text(
                'Value',
                style: TextStyle(
                  fontWeight: Foundations.typography.semibold,
                  color: theme.isDarkMode
                      ? Foundations.darkColors.textPrimary
                      : Foundations.colors.textPrimary,
                ),
              ),
            ),
            Text(
              'Count',
              style: TextStyle(
                fontWeight: Foundations.typography.semibold,
                color: theme.isDarkMode
                    ? Foundations.darkColors.textPrimary
                    : Foundations.colors.textPrimary,
              ),
            ),
          ],
        ),
        SizedBox(height: Foundations.spacing.md),

        // Distribution bars
        ...sortedEntries.map((entry) {
          final percentage = total > 0 ? (entry.value / total * 100) : 0;
          final color = ColorGenerator.getColor(
            paramName,
            entry.key,
            isDarkMode: theme.isDarkMode,
            isBinary: isBinary,
          );

          return Column(
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      entry.key,
                      style: TextStyle(
                        fontSize: Foundations.typography.sm,
                        color: color,
                        fontWeight: Foundations.typography.medium,
                      ),
                    ),
                  ),
                  Text(
                    '${entry.value} (${percentage.toStringAsFixed(1)}%)',
                    style: TextStyle(
                      fontSize: Foundations.typography.sm,
                      color: color,
                      fontWeight: Foundations.typography.medium,
                    ),
                  ),
                ],
              ),
              SizedBox(height: Foundations.spacing.xs),
              LinearProgressIndicator(
                value: percentage / 100,
                backgroundColor: color.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 8,
                borderRadius: Foundations.borders.full,
              ),
              SizedBox(height: Foundations.spacing.md),
            ],
          );
        }),

        // Total count
        Divider(
          color: theme.isDarkMode
              ? Foundations.darkColors.border
              : Foundations.colors.border,
        ),
        SizedBox(height: Foundations.spacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Unique Values: $uniqueCount',
              style: TextStyle(
                fontWeight: Foundations.typography.medium,
                color: theme.isDarkMode
                    ? Foundations.darkColors.textPrimary
                    : Foundations.colors.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
