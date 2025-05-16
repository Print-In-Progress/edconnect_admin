import 'package:edconnect_admin/l10n/app_localizations.dart';
import 'package:edconnect_admin/presentation/pages/sorting_module/utils/parameter_formatter.dart';
import 'package:edconnect_admin/presentation/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:edconnect_admin/core/design_system/color_generator.dart';
import 'package:edconnect_admin/core/design_system/foundations.dart';
import 'package:edconnect_admin/domain/entities/sorting_survey.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ClassColumnHeader extends ConsumerWidget {
  final String className;
  final List<String> studentIds;
  final SortingSurvey survey;

  const ClassColumnHeader({
    required this.className,
    required this.studentIds,
    required this.survey,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final stats = _calculateClassStats();
    final genderStats = stats['gender'] as Map<String, int>;
    final binaryParams =
        stats['binary_params'] as Map<String, Map<String, int>>;
    final isDarkMode = ref.watch(appThemeProvider).isDarkMode;
    return Padding(
      padding: EdgeInsets.all(Foundations.spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            className,
            style: TextStyle(
              fontSize: Foundations.typography.base,
              fontWeight: Foundations.typography.semibold,
              color: isDarkMode
                  ? Foundations.darkColors.textPrimary
                  : Foundations.colors.textPrimary,
            ),
          ),
          Text(
            l10n.sortingModuleNumOfClasses(
              studentIds.length,
            ),
            style: TextStyle(
              fontSize: Foundations.typography.sm,
              color: isDarkMode
                  ? Foundations.darkColors.textMuted
                  : Foundations.colors.textMuted,
            ),
          ),
          SizedBox(height: Foundations.spacing.sm),
          ExpansionTile(
              title: Text(l10n.sortingModuleShowClassStatisticssLabel),
              shape: const Border(),
              children: [
                if (survey.askBiologicalSex)
                  _buildDistributionBar(genderStats, isDarkMode, l10n),
                ...binaryParams.entries.map((entry) {
                  return _buildBinaryParamBar(
                      ParameterFormatter.formatParameterNameForDisplay(
                          entry.key),
                      entry.value,
                      isDarkMode,
                      l10n);
                }),
              ])
        ],
      ),
    );
  }

  Map<String, dynamic> _calculateClassStats() {
    Map<String, int> genderCounts = {'m': 0, 'f': 0, 'nb': 0, 'unknown': 0};

    Map<String, Map<String, int>> binaryParams = {};

    for (var param in survey.parameters) {
      if (param['type'] == 'binary') {
        String paramName = param['name'];
        binaryParams[paramName] = {'yes': 0, 'no': 0};
      }
    }

    for (String studentId in studentIds) {
      final response = survey.responses[studentId];

      if (response != null) {
        String sex = response['sex'] as String? ?? 'unknown';
        if (genderCounts.containsKey(sex)) {
          genderCounts[sex] = genderCounts[sex]! + 1;
        } else {
          genderCounts['unknown'] = genderCounts['unknown']! + 1;
        }

        for (String paramName in binaryParams.keys) {
          String value =
              (response[paramName] ?? 'unknown').toString().toLowerCase();
          if (value == 'yes' || value == 'true' || value == '1') {
            binaryParams[paramName]!['yes'] =
                binaryParams[paramName]!['yes']! + 1;
          } else if (value == 'no' || value == 'false' || value == '0') {
            binaryParams[paramName]!['no'] =
                binaryParams[paramName]!['no']! + 1;
          }
        }
      }
    }

    return {
      'gender': genderCounts,
      'binary_params': binaryParams,
      'total': studentIds.length,
    };
  }

  Widget _buildDistributionBar(
      Map<String, int> counts, bool isDarkMode, AppLocalizations l10n) {
    final total = counts.values.fold(0, (sum, count) => sum + count);
    if (total == 0) return const SizedBox();

    final maleCount = counts['m'] ?? 0;
    final femaleCount = counts['f'] ?? 0;
    final nbCount = counts['nb'] ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.globalBiologicalSexLabel,
          style: TextStyle(
            fontSize: Foundations.typography.xs,
            fontWeight: Foundations.typography.medium,
            color: isDarkMode
                ? Foundations.darkColors.textSecondary
                : Foundations.colors.textSecondary,
          ),
        ),
        SizedBox(height: Foundations.spacing.xs),
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: Foundations.borders.sm,
                child: Row(
                  children: [
                    if (maleCount > 0)
                      Expanded(
                        flex: maleCount,
                        child: Container(
                          height: 8,
                          color: ColorGenerator.getColor('sex', 'm',
                              isDarkMode: isDarkMode),
                        ),
                      ),
                    if (femaleCount > 0)
                      Expanded(
                        flex: femaleCount,
                        child: Container(
                          height: 8,
                          color: ColorGenerator.getColor('sex', 'f',
                              isDarkMode: isDarkMode),
                        ),
                      ),
                    if (nbCount > 0)
                      Expanded(
                        flex: nbCount,
                        child: Container(
                          height: 8,
                          color: ColorGenerator.getColor('sex', 'nb',
                              isDarkMode: isDarkMode),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: Foundations.spacing.xs),
        Row(
          children: [
            if (maleCount > 0)
              _buildLegendItem(
                  l10n.globalMaleLegend,
                  maleCount,
                  ColorGenerator.getColor('sex', 'm', isDarkMode: isDarkMode),
                  isDarkMode),
            if (maleCount > 0 && femaleCount > 0)
              SizedBox(width: Foundations.spacing.xs),
            if (femaleCount > 0)
              _buildLegendItem(
                  l10n.globalFemaleLegend,
                  femaleCount,
                  ColorGenerator.getColor('sex', 'f', isDarkMode: isDarkMode),
                  isDarkMode),
            if ((maleCount > 0 || femaleCount > 0) && nbCount > 0)
              SizedBox(width: Foundations.spacing.xs),
            if (nbCount > 0)
              _buildLegendItem(
                  l10n.globalNonBinaryLegend,
                  nbCount,
                  ColorGenerator.getColor('sex', 'nb', isDarkMode: isDarkMode),
                  isDarkMode),
          ],
        ),
      ],
    );
  }

  Widget _buildBinaryParamBar(String title, Map<String, int> counts,
      bool isDarkMode, AppLocalizations l10n) {
    final yesCount = counts['yes'] ?? 0;
    final noCount = counts['no'] ?? 0;
    final total = yesCount + noCount;

    if (total == 0) return const SizedBox();

    return Padding(
      padding: EdgeInsets.only(top: Foundations.spacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: Foundations.typography.xs,
              fontWeight: Foundations.typography.medium,
              color: isDarkMode
                  ? Foundations.darkColors.textSecondary
                  : Foundations.colors.textSecondary,
            ),
          ),
          SizedBox(height: Foundations.spacing.xs),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: Foundations.borders.sm,
                  child: Row(
                    children: [
                      if (yesCount > 0)
                        Expanded(
                          flex: yesCount,
                          child: Container(
                            height: 8,
                            color: Foundations.colors.success.withOpacity(0.8),
                          ),
                        ),
                      if (noCount > 0)
                        Expanded(
                          flex: noCount,
                          child: Container(
                            height: 8,
                            color: Foundations.colors.error.withOpacity(0.6),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: Foundations.spacing.xs),
          Row(
            children: [
              if (yesCount > 0)
                _buildLegendItem(l10n.globalYes, yesCount,
                    Foundations.colors.success.withOpacity(0.8), isDarkMode),
              if (yesCount > 0 && noCount > 0)
                SizedBox(width: Foundations.spacing.sm),
              if (noCount > 0)
                _buildLegendItem(l10n.globalNo, noCount,
                    Foundations.colors.error.withOpacity(0.6), isDarkMode),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(
      String label, int count, Color color, bool isDarkMode) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: Foundations.borders.full,
          ),
        ),
        SizedBox(width: Foundations.spacing.xs),
        Text(
          '$label: $count',
          style: TextStyle(
            fontSize: 10,
            color: isDarkMode
                ? Foundations.darkColors.textMuted
                : Foundations.colors.textMuted,
          ),
        ),
      ],
    );
  }
}
