import 'package:edconnect_admin/core/design_system/foundations.dart';
import 'package:edconnect_admin/domain/entities/sorting_survey.dart';
import 'package:edconnect_admin/l10n/app_localizations.dart';
import 'package:edconnect_admin/presentation/pages/sorting_module/components/section_header.dart';
import 'package:edconnect_admin/presentation/pages/sorting_module/tabs/results/components/dialogs/export_results_dialog.dart';
import 'package:edconnect_admin/presentation/pages/sorting_module/tabs/results/utils/result_statistics.dart';
import 'package:edconnect_admin/presentation/providers/theme_provider.dart';
import 'package:edconnect_admin/presentation/widgets/common/buttons/base_button.dart';
import 'package:edconnect_admin/presentation/widgets/common/cards/base_card.dart';
import 'package:edconnect_admin/presentation/widgets/common/dialogs/dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SortingSurveyResultsHeader extends ConsumerStatefulWidget {
  final Map<String, List<String>> currentResults;
  final SortingSurvey survey;
  const SortingSurveyResultsHeader({
    super.key,
    required this.currentResults,
    required this.survey,
  });

  @override
  ConsumerState<SortingSurveyResultsHeader> createState() =>
      _SortingSurveyResultsHeaderState();
}

class _SortingSurveyResultsHeaderState
    extends ConsumerState<SortingSurveyResultsHeader> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = ref.watch(appThemeProvider);
    return Column(
      children: [
        SectionHeader(
          title: l10n.sortingModuleClassDistributionResultsLabel,
          icon: Icons.pie_chart_outline,
          actionButton: BaseButton(
            label: l10n.globalExportX(''),
            prefixIcon: Icons.download_outlined,
            variant: ButtonVariant.outlined,
            size: ButtonSize.medium,
            onPressed: () => _exportResults(l10n),
          ),
        ),
        SizedBox(height: Foundations.spacing.xs),
        _buildStatistics(theme.isDarkMode, l10n),
      ],
    );
  }

  Widget _buildStatistics(bool isDarkMode, AppLocalizations l10n) {
    final totalClasses = widget.currentResults.length;
    final totalStudents = widget.currentResults.values
        .fold(0, (sum, students) => sum + students.length);
    final averagePerClass = totalClasses > 0
        ? (totalStudents / totalClasses).toStringAsFixed(1)
        : '0';

    final preferenceSatisfactionData = calculatePreferenceSatisfaction(
        widget.currentResults, widget.survey.responses);
    final satisfiedPrefs =
        preferenceSatisfactionData['satisfiedPreferences'] as int;
    final totalPrefs = preferenceSatisfactionData['totalPreferences'] as int;
    final studentsWithSatisfiedPrefs =
        preferenceSatisfactionData['studentsWithSatisfiedPrefs'] as int;
    final studentsWithPreferences =
        preferenceSatisfactionData['studentsWithPreferences'] as int;

    final satisfactionRate = totalPrefs > 0
        ? '${(satisfiedPrefs / totalPrefs * 100).toStringAsFixed(1)}%'
        : '0%';

    final studentSatisfactionRate = studentsWithPreferences > 0
        ? '${(studentsWithSatisfiedPrefs / studentsWithPreferences * 100).toStringAsFixed(1)}%'
        : '0%';

    return Row(
      children: [
        _buildCompactStatItem(
          l10n.sortingModuleTotalStudentsLabel,
          totalStudents.toString(),
          Icons.people_outline,
          isDarkMode,
          subtitle: '$totalClasses classes, ~$averagePerClass per class',
        ),
        SizedBox(width: Foundations.spacing.md),
        _buildCompactStatItem(
          l10n.sortingModulePreferencesSatisfiedLabel,
          '$satisfiedPrefs / $totalPrefs',
          Icons.favorite_outline,
          isDarkMode,
          subtitle: satisfactionRate,
        ),
        SizedBox(width: Foundations.spacing.md),
        _buildCompactStatItem(
          l10n.sortingModuleStudentsWithAtLeastOnePreferenceSatisfiedLabel,
          '$studentsWithSatisfiedPrefs / $studentsWithPreferences',
          Icons.check_circle_outline,
          isDarkMode,
          subtitle: studentSatisfactionRate,
        ),
      ],
    );
  }

  Widget _buildCompactStatItem(
      String label, String value, IconData icon, bool isDarkMode,
      {String? subtitle}) {
    return Expanded(
      child: BaseCard(
        variant: CardVariant.outlined,
        margin: EdgeInsets.zero,
        padding: EdgeInsets.symmetric(
          horizontal: Foundations.spacing.sm,
          vertical: Foundations.spacing.xs,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isDarkMode
                  ? Foundations.darkColors.textSecondary
                  : Foundations.colors.textSecondary,
            ),
            SizedBox(width: Foundations.spacing.xs),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: Foundations.typography.xs,
                      color: isDarkMode
                          ? Foundations.darkColors.textMuted
                          : Foundations.colors.textMuted,
                    ),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: Foundations.typography.sm,
                      fontWeight: Foundations.typography.medium,
                      color: isDarkMode
                          ? Foundations.darkColors.textPrimary
                          : Foundations.colors.textPrimary,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: Foundations.typography.xs,
                        color: isDarkMode
                            ? Foundations.darkColors.textMuted
                            : Foundations.colors.textMuted,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportResults(AppLocalizations l10n) async {
    final dialogKey = GlobalKey<ExportResultsDialogState>();
    bool isExporting = false;

    Dialogs.show(
      context: context,
      title:
          l10n.globalExportX(l10n.sortingModuleClassDistributionResultsLabel),
      width: 600,
      scrollable: true,
      content: StatefulBuilder(
        builder: (context, setState) {
          return ExportResultsDialog(
            key: dialogKey,
            survey: widget.survey,
            currentResults: widget.currentResults,
            onExportStatusChanged: (exporting) {
              setState(() => isExporting = exporting);
            },
          );
        },
      ),
      actions: [
        BaseButton(
          label: l10n.globalExportX(''),
          prefixIcon: Icons.picture_as_pdf_outlined,
          variant: ButtonVariant.filled,
          isLoading: isExporting,
          onPressed: () {
            dialogKey.currentState?.exportPdf();
          },
        ),
      ],
      showCancelButton: true,
      showCloseIcon: true,
    );
  }
}
