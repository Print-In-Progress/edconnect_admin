import 'package:edconnect_admin/core/design_system/color_generator.dart';
import 'package:edconnect_admin/core/design_system/foundations.dart';
import 'package:edconnect_admin/domain/entities/sorting_survey.dart';
import 'package:edconnect_admin/presentation/pages/sorting_module/tabs/responses/dialogs/view_all_dialog.dart';
import 'package:edconnect_admin/presentation/pages/sorting_module/utils/parameter_formatter.dart';
import 'package:edconnect_admin/presentation/providers/theme_provider.dart';
import 'package:edconnect_admin/presentation/widgets/common/buttons/base_button.dart';
import 'package:edconnect_admin/presentation/widgets/common/dialogs/dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DistributionRow extends ConsumerWidget {
  final String paramName;
  final Map<String, int> distribution;
  final bool isSexParameter;
  final bool limitEntries;
  final SortingSurvey survey;

  const DistributionRow({
    super.key,
    required this.paramName,
    required this.distribution,
    this.isSexParameter = false,
    this.limitEntries = false,
    required this.survey,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeProvider);
    final total = distribution.values.fold(0, (sum, count) => sum + count);

    var sortedEntries = distribution.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final originalLength = sortedEntries.length;

    if (limitEntries && sortedEntries.length > 3) {
      int othersCount =
          sortedEntries.skip(3).fold(0, (sum, e) => sum + e.value);
      sortedEntries = sortedEntries.take(2).toList();
      if (othersCount > 0) {
        sortedEntries.add(MapEntry('Other', othersCount));
      }
    }

    return Padding(
      padding: EdgeInsets.all(Foundations.spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Tooltip(
                  message: ParameterFormatter.foratParameterNameForDisplay(
                      paramName),
                  textStyle: TextStyle(
                    color: theme.isDarkMode
                        ? Foundations.darkColors.textPrimary
                        : Foundations.colors.textPrimary,
                  ),
                  decoration: BoxDecoration(
                    color: theme.isDarkMode
                        ? Foundations.darkColors.backgroundMuted
                        : Foundations.colors.backgroundMuted,
                    borderRadius: Foundations.borders.md,
                  ),
                  child: Text(
                    ParameterFormatter.foratParameterNameForDisplay(paramName),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: Foundations.typography.base,
                      fontWeight: Foundations.typography.semibold,
                      color: theme.isDarkMode
                          ? Foundations.darkColors.textPrimary
                          : Foundations.colors.textPrimary,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              if (originalLength > 3)
                BaseButton(
                    label: 'View All',
                    onPressed: () {
                      _viewAllDialog(context, paramName);
                    },
                    variant: ButtonVariant.text,
                    size: ButtonSize.small),
            ],
          ),
          SizedBox(height: Foundations.spacing.lg),
          ...sortedEntries.map((entry) {
            final percentage = total > 0 ? (entry.value / total * 100) : 0;
            final isBinary = sortedEntries.length == 2 &&
                sortedEntries.every((e) =>
                    e.key.toLowerCase() == 'yes' ||
                    e.key.toLowerCase() == 'no');

            final displayValue = isSexParameter
                ? ParameterFormatter.formatSexForDisplay(entry.key)
                : entry.key;

            final color = ColorGenerator.getColor(
              paramName,
              displayValue,
              isDarkMode: theme.isDarkMode,
              isBinary: isBinary,
            );

            return Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Tooltip(
                        message:
                            ParameterFormatter.foratParameterNameForDisplay(
                                displayValue),
                        textStyle: TextStyle(
                          color: theme.isDarkMode
                              ? Foundations.darkColors.textPrimary
                              : Foundations.colors.textPrimary,
                        ),
                        decoration: BoxDecoration(
                          color: theme.isDarkMode
                              ? Foundations.darkColors.backgroundMuted
                              : Foundations.colors.backgroundMuted,
                          borderRadius: Foundations.borders.md,
                        ),
                        child: Text(
                          ParameterFormatter.foratParameterNameForDisplay(
                              displayValue),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: Foundations.typography.sm,
                            color: color,
                            fontWeight: Foundations.typography.medium,
                          ),
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
        ],
      ),
    );
  }

  void _viewAllDialog(
    BuildContext context,
    String paramName,
  ) {
    Dialogs.show(
      context: context,
      title: ParameterFormatter.foratParameterNameForDisplay(paramName),
      width: 400,
      variant: DialogVariant.info,
      scrollable: true,
      content: ViewAllDialog(paramName: paramName, survey: survey),
    );
  }
}
