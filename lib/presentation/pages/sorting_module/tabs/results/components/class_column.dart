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
          // Class name and count
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
            '${studentIds.length} students',
            style: TextStyle(
              fontSize: Foundations.typography.sm,
              color: isDarkMode
                  ? Foundations.darkColors.textMuted
                  : Foundations.colors.textMuted,
            ),
          ),

          SizedBox(height: Foundations.spacing.sm),

          // Statistics expansion
          ExpansionTile(
              title: Text('Show class statistics'),
              shape: const Border(),
              children: [
                if (survey.askBiologicalSex)
                  _buildDistributionBar(genderStats, isDarkMode),

                // Binary parameters
                ...binaryParams.entries.map((entry) {
                  return _buildBinaryParamBar(
                      ParameterFormatter.formatParameterNameForDisplay(
                          entry.key),
                      entry.value,
                      isDarkMode);
                }),
              ])
        ],
      ),
    );
  }

  // Calculate statistics for a class
  Map<String, dynamic> _calculateClassStats() {
    // Gender distribution
    Map<String, int> genderCounts = {'m': 0, 'f': 0, 'nb': 0, 'unknown': 0};

    // Binary parameters (yes/no questions)
    Map<String, Map<String, int>> binaryParams = {};

    // Initialize binary parameter counters from survey parameters
    for (var param in survey.parameters) {
      if (param['type'] == 'binary') {
        String paramName = param['name'];
        binaryParams[paramName] = {'yes': 0, 'no': 0};
      }
    }

    // Count responses for each student
    for (String studentId in studentIds) {
      final response = survey.responses[studentId];

      if (response != null) {
        // Count gender
        String sex = response['sex'] as String? ?? 'unknown';
        if (genderCounts.containsKey(sex)) {
          genderCounts[sex] = genderCounts[sex]! + 1;
        } else {
          genderCounts['unknown'] = genderCounts['unknown']! + 1;
        }

        // Count binary parameters
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

  Widget _buildDistributionBar(Map<String, int> counts, bool isDarkMode) {
    final total = counts.values.fold(0, (sum, count) => sum + count);
    if (total == 0) return const SizedBox();

    final maleCount = counts['m'] ?? 0;
    final femaleCount = counts['f'] ?? 0;
    final nbCount = counts['nb'] ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gender',
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
                    // Male proportion
                    if (maleCount > 0)
                      Expanded(
                        flex: maleCount,
                        child: Container(
                          height: 8,
                          color: ColorGenerator.getColor('sex', 'm',
                              isDarkMode: isDarkMode),
                        ),
                      ),
                    // Female proportion
                    if (femaleCount > 0)
                      Expanded(
                        flex: femaleCount,
                        child: Container(
                          height: 8,
                          color: ColorGenerator.getColor('sex', 'f',
                              isDarkMode: isDarkMode),
                        ),
                      ),
                    // Non-binary proportion
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
                  'M',
                  maleCount,
                  ColorGenerator.getColor('sex', 'm', isDarkMode: isDarkMode),
                  isDarkMode),
            if (maleCount > 0 && femaleCount > 0)
              SizedBox(width: Foundations.spacing.xs),
            if (femaleCount > 0)
              _buildLegendItem(
                  'F',
                  femaleCount,
                  ColorGenerator.getColor('sex', 'f', isDarkMode: isDarkMode),
                  isDarkMode),
            if ((maleCount > 0 || femaleCount > 0) && nbCount > 0)
              SizedBox(width: Foundations.spacing.xs),
            if (nbCount > 0)
              _buildLegendItem(
                  'NB',
                  nbCount,
                  ColorGenerator.getColor('sex', 'nb', isDarkMode: isDarkMode),
                  isDarkMode),
          ],
        ),
      ],
    );
  }

  // Display binary parameter (yes/no) as a bar
  Widget _buildBinaryParamBar(
      String title, Map<String, int> counts, bool isDarkMode) {
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
                      // Yes proportion
                      if (yesCount > 0)
                        Expanded(
                          flex: yesCount,
                          child: Container(
                            height: 8,
                            color: Foundations.colors.success.withOpacity(0.8),
                          ),
                        ),
                      // No proportion
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
                _buildLegendItem('Yes', yesCount,
                    Foundations.colors.success.withOpacity(0.8), isDarkMode),
              if (yesCount > 0 && noCount > 0)
                SizedBox(width: Foundations.spacing.sm),
              if (noCount > 0)
                _buildLegendItem('No', noCount,
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
