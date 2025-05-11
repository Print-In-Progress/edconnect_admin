import 'package:edconnect_admin/core/design_system/foundations.dart';
import 'package:edconnect_admin/core/routing/app_router.dart';
import 'package:edconnect_admin/domain/entities/sorting_survey.dart';
import 'package:edconnect_admin/presentation/providers/state_providers.dart';
import 'package:edconnect_admin/presentation/providers/theme_provider.dart';
import 'package:edconnect_admin/presentation/widgets/common/cards/base_card.dart';
import 'package:edconnect_admin/presentation/widgets/common/chips.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class SurveyCard extends ConsumerWidget {
  final SortingSurvey survey;

  const SurveyCard({super.key, required this.survey});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeProvider);

    final isCalculating = ref.watch(calculationStateProvider).isCalculating &&
        ref.read(selectedSortingSurveyIdProvider) == survey.id;
    // Check if results are available
    final hasResults = survey.calculationResults != null &&
        survey.calculationResults!.isNotEmpty;

    return BaseCard(
      variant: CardVariant.outlined,
      isSelectable: true,
      onTap: () {
        ref.read(selectedSortingSurveyIdProvider.notifier).state = survey.id;

        // Navigate to details
        AppRouter.toSortingSurveyDetails(context, surveyId: survey.id);
      },
      child: Padding(
        padding: EdgeInsets.all(Foundations.spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    survey.title,
                    style: TextStyle(
                      fontSize: Foundations.typography.lg,
                      fontWeight: Foundations.typography.semibold,
                      color: theme.isDarkMode
                          ? Foundations.darkColors.textPrimary
                          : Foundations.colors.textPrimary,
                    ),
                  ),
                ),
                if (isCalculating)
                  _buildCalculatingIndicator()
                else if (hasResults)
                  _buildResultsAvailableChip()
                else
                  _buildStatusChip(survey.status),
              ],
            ),
            if (survey.description.isNotEmpty) ...[
              SizedBox(height: Foundations.spacing.sm),
              Text(
                survey.description,
                style: TextStyle(
                  color: theme.isDarkMode
                      ? Foundations.darkColors.textSecondary
                      : Foundations.colors.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            SizedBox(height: Foundations.spacing.lg),
            Row(
              children: [
                Icon(
                  Icons.person_outline,
                  size: 16,
                  color: Foundations.colors.textMuted,
                ),
                SizedBox(width: Foundations.spacing.xs),
                Text(
                  survey.creatorName,
                  style: TextStyle(
                    color: Foundations.colors.textMuted,
                    fontSize: Foundations.typography.sm,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: Foundations.colors.textMuted,
                ),
                SizedBox(width: Foundations.spacing.xs),
                Text(
                  DateFormat('MMM d, yyyy').format(survey.createdAt),
                  style: TextStyle(
                    color: Foundations.colors.textMuted,
                    fontSize: Foundations.typography.sm,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculatingIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 16,
          width: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
          ),
        ),
        SizedBox(width: Foundations.spacing.xs),
        BaseChip(
          label: 'Calculating',
          variant: ChipVariant.secondary,
          size: ChipSize.small,
        ),
      ],
    );
  }

  Widget _buildResultsAvailableChip() {
    return BaseChip(
      label: 'Results Available',
      variant: ChipVariant.secondary,
      size: ChipSize.small,
      leadingIcon: Icons.check_circle,
    );
  }

  Widget _buildStatusChip(SortingSurveyStatus status) {
    ChipVariant variant;
    String label;

    switch (status) {
      case SortingSurveyStatus.draft:
        variant = ChipVariant.default_;
        label = 'Draft';
        break;
      case SortingSurveyStatus.published:
        variant = ChipVariant.primary;
        label = 'Published';
        break;
      case SortingSurveyStatus.closed:
        variant = ChipVariant.secondary;
        label = 'Closed';
        break;
    }

    return BaseChip(
      label: label,
      variant: variant,
      size: ChipSize.small,
    );
  }
}
