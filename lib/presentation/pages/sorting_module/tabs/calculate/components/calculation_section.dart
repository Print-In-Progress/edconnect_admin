import 'package:edconnect_admin/core/design_system/foundations.dart';
import 'package:edconnect_admin/domain/entities/sorting_survey.dart';
import 'package:edconnect_admin/l10n/app_localizations.dart';
import 'package:edconnect_admin/presentation/pages/sorting_module/components/section_header.dart';
import 'package:edconnect_admin/presentation/providers/state_providers.dart';
import 'package:edconnect_admin/presentation/widgets/common/buttons/base_button.dart';
import 'package:edconnect_admin/presentation/widgets/common/cards/base_card.dart';
import 'package:edconnect_admin/presentation/widgets/common/dialogs/dialogs.dart';
import 'package:edconnect_admin/presentation/widgets/common/dropdown/single_select_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CalculationSection extends ConsumerStatefulWidget {
  final SortingSurvey survey;
  final Map<String, dynamic> complexityReport;
  final int timeLimit;
  final bool isCalculating;
  final Function(int) onTimeLimitChanged;
  final VoidCallback onCalculate;
  const CalculationSection({
    super.key,
    required this.survey,
    required this.complexityReport,
    required this.timeLimit,
    required this.isCalculating,
    required this.onTimeLimitChanged,
    required this.onCalculate,
  });

  @override
  ConsumerState<CalculationSection> createState() => _CalculationSectionState();
}

class _CalculationSectionState extends ConsumerState<CalculationSection> {
  @override
  Widget build(BuildContext context) {
    final hasResults = widget.survey.calculationResults != null &&
        widget.survey.calculationResults!.isNotEmpty;

    final varCounts = widget.complexityReport['variables'] as Map<String, int>;
    final complexityColor = Foundations.colors.backgroundSubtle;
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
            title: l10n.sortingModuleCalculate, icon: Icons.calculate_outlined),
        SizedBox(height: Foundations.spacing.md),
        LayoutBuilder(
          builder: (context, constraints) {
            final isWideScreen = constraints.maxWidth > 900;

            return BaseCard(
              variant: CardVariant.outlined,
              margin: EdgeInsets.zero,
              padding: EdgeInsets.all(Foundations.spacing.md),
              child: hasResults
                  ? _buildExistingResultsSection(context, ref, isWideScreen)
                  : _buildNewCalculationSection(
                      context,
                      ref,
                      varCounts,
                      complexityColor,
                      isWideScreen,
                      l10n,
                    ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildNewCalculationSection(
    BuildContext context,
    WidgetRef ref,
    Map<String, int> varCounts,
    Color complexityColor,
    bool isWideScreen,
    AppLocalizations l10n,
  ) {
    return Column(children: [
      Container(
        padding: EdgeInsets.all(Foundations.spacing.md),
        decoration: BoxDecoration(
          color: complexityColor.withValues(alpha: 0.1),
          borderRadius: Foundations.borders.md,
          border: Border.all(color: complexityColor.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildComplexityItem(
                    l10n.sortingModuleVariables,
                    varCounts['totalVariables'].toString(),
                    Icons.data_object,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.sortingModuleProblemSize,
                  style: TextStyle(
                    fontSize: Foundations.typography.sm,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: Foundations.spacing.xs),
                Wrap(
                  spacing: Foundations.spacing.md,
                  runSpacing: Foundations.spacing.xs,
                  children: [
                    _buildDetailChip(
                      l10n.sortingModuleNumOfStudents(
                          widget.complexityReport['problemSize']['students']),
                      Icons.person_outline,
                    ),
                    _buildDetailChip(
                      l10n.sortingModuleNumOfClasses(
                          widget.complexityReport['problemSize']['classes']),
                      Icons.category_outlined,
                    ),
                    _buildDetailChip(
                      l10n.sortingModuleNumOfParams(
                          widget.complexityReport['problemSize']['parameters']),
                      Icons.tune_outlined,
                    ),
                    _buildDetailChip(
                      l10n.sortingModuleNumOfPreferences(widget
                          .complexityReport['problemSize']['totalPreferences']),
                      Icons.favorite_outline,
                    ),
                  ],
                ),
                SizedBox(height: Foundations.spacing.md),
              ],
            ),
          ],
        ),
      ),
      SizedBox(height: Foundations.spacing.lg),
      SizedBox(
          width: isWideScreen ? 800 : double.infinity,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.sortingModuleMaxCalcTimeLabel,
                          style: TextStyle(
                            fontSize: Foundations.typography.base,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: Foundations.spacing.xs),
                        Text(
                          l10n.sortingModuleMaxCalcTimeDescription,
                          style: TextStyle(
                            fontSize: Foundations.typography.sm,
                            color: Foundations.colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: Foundations.spacing.md),
                  SizedBox(
                    width: 160,
                    child: BaseSelect<int>(
                      value: widget.timeLimit,
                      label: l10n.sortingModuleTimeLimitLabel,
                      options: [
                        SelectOption(
                            value: 30, label: l10n.globalSecondsWithNumber(30)),
                        SelectOption(
                            value: 60, label: l10n.globalMintuesWithNumber(1)),
                        SelectOption(
                            value: 120, label: l10n.globalMintuesWithNumber(2)),
                        SelectOption(
                            value: 300, label: l10n.globalMintuesWithNumber(5)),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          widget.onTimeLimitChanged(value);
                        }
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: Foundations.spacing.xl),
              // Calculate button
              if (widget.isCalculating)
                Padding(
                  padding: EdgeInsets.only(top: Foundations.spacing.md),
                  child: Text(
                    l10n.sortingModuleCalculateLoadingLabel,
                    style: TextStyle(
                      fontSize: Foundations.typography.sm,
                      color: Foundations.colors.textSecondary,
                    ),
                  ),
                ),

              Center(
                child: BaseButton(
                  variant: ButtonVariant.filled,
                  size: ButtonSize.large,
                  prefixIcon: Icons.calculate_outlined,
                  label: l10n.sortingModuleCalculate,
                  isLoading: widget.isCalculating,
                  onPressed: widget.onCalculate,
                ),
              ),
            ],
          ))
    ]);
  }

  Widget _buildExistingResultsSection(
      BuildContext context, WidgetRef ref, bool isWideScreen) {
    final metrics = widget.survey.calculationMetrics;
    final results = widget.survey.calculationResults;

    // Count students per class
    final classDistribution = <String, int>{};
    results!.forEach((className, studentList) {
      classDistribution[className] = (studentList as List).length;
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(Foundations.spacing.md),
          decoration: BoxDecoration(
            color: Foundations.colors.success.withValues(alpha: 0.1),
            borderRadius: Foundations.borders.md,
            border: Border.all(
              color: Foundations.colors.success.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: Foundations.colors.success,
                    size: 20,
                  ),
                  SizedBox(width: Foundations.spacing.sm),
                  Text(
                    'Calculation Completed',
                    style: TextStyle(
                      fontSize: Foundations.typography.base,
                      fontWeight: Foundations.typography.semibold,
                      color: Foundations.colors.success,
                    ),
                  ),
                ],
              ),
              SizedBox(height: Foundations.spacing.md),

              // Calculation metrics
              Wrap(
                spacing: Foundations.spacing.xl,
                runSpacing: Foundations.spacing.md,
                children: [
                  _buildResultsMetric(
                    'Runtime',
                    '${metrics?['runtime_seconds']?.toStringAsFixed(2) ?? "N/A"} sec',
                    Icons.timer_outlined,
                  ),
                  _buildResultsMetric(
                    'Classes',
                    '${results.length}',
                    Icons.category_outlined,
                  ),
                  _buildResultsMetric(
                    'Students',
                    '${metrics?['num_students'] ?? widget.survey.responses.length}',
                    Icons.people_outline,
                  ),
                  _buildResultsMetric(
                    'Parameters',
                    '${(metrics?['parameters_used'] as List?)?.length ?? "N/A"}',
                    Icons.tune_outlined,
                  ),
                ],
              ),

              SizedBox(height: Foundations.spacing.md),

              // Class distribution
              Text(
                'Class Distribution',
                style: TextStyle(
                  fontSize: Foundations.typography.sm,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: Foundations.spacing.xs),
              Wrap(
                spacing: Foundations.spacing.md,
                runSpacing: Foundations.spacing.xs,
                children: classDistribution.entries
                    .map(
                      (entry) => _buildDetailChip(
                        '${entry.key}: ${entry.value} students',
                        Icons.groups_outlined,
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
        SizedBox(height: Foundations.spacing.xl),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            BaseButton(
              label: 'See Results',
              variant: ButtonVariant.filled,
              prefixIcon: Icons.visibility_outlined,
              size: ButtonSize.large,
              onPressed: () {
                // Navigate to results tab
                ref
                    .read(surveyTabIndexProvider(widget.survey.id).notifier)
                    .state = 3;
              },
            ),
            SizedBox(width: Foundations.spacing.lg),
            BaseButton(
              label: 'Recalculate',
              variant: ButtonVariant.outlined,
              prefixIcon: Icons.refresh_outlined,
              size: ButtonSize.large,
              onPressed: () async {
                // Confirm recalculation
                final confirmed = await Dialogs.confirm(
                  context: context,
                  title: 'Recalculate Classes?',
                  message:
                      'This will overwrite your current calculation results. Are you sure you want to proceed?',
                  confirmText: 'Recalculate',
                );

                if (confirmed == true) {
                  // Proceed with calculation
                  widget.onCalculate();
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailChip(String label, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Foundations.spacing.sm,
        vertical: Foundations.spacing.xs,
      ),
      decoration: BoxDecoration(
        color: Foundations.colors.surfaceActive.withValues(alpha: 0.2),
        borderRadius: Foundations.borders.sm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Foundations.colors.textMuted),
          SizedBox(width: Foundations.spacing.xs),
          Text(
            label,
            style: TextStyle(
              fontSize: Foundations.typography.xs,
              color: Foundations.colors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsMetric(String label, String value, IconData icon) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: Foundations.colors.textMuted),
            SizedBox(width: Foundations.spacing.xs),
            Text(
              label,
              style: TextStyle(
                fontSize: Foundations.typography.sm,
                color: Foundations.colors.textMuted,
              ),
            ),
          ],
        ),
        SizedBox(height: Foundations.spacing.xs),
        Text(
          value,
          style: TextStyle(
            fontSize: Foundations.typography.base,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildComplexityItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: Foundations.colors.textMuted),
            SizedBox(width: Foundations.spacing.xs),
            Text(
              label,
              style: TextStyle(
                fontSize: Foundations.typography.sm,
                color: Foundations.colors.textMuted,
              ),
            ),
          ],
        ),
        SizedBox(height: Foundations.spacing.xs),
        Text(
          value,
          style: TextStyle(
            fontSize: Foundations.typography.base,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
