import 'package:edconnect_admin/core/design_system/foundations.dart';
import 'package:edconnect_admin/core/routing/app_router.dart';
import 'package:edconnect_admin/domain/entities/sorting_survey.dart';
import 'package:edconnect_admin/l10n/app_localizations.dart';
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
    final hasResults = survey.calculationResults != null &&
        survey.calculationResults!.isNotEmpty;
    final l10n = AppLocalizations.of(context)!;

    return BaseCard(
      variant: CardVariant.outlined,
      padding: EdgeInsets.all(Foundations.spacing.xl),
      margin: EdgeInsets.zero,
      isSelectable: true,
      onTap: () {
        ref.read(selectedSortingSurveyIdProvider.notifier).state = survey.id;

        AppRouter.toSortingSurveyDetails(context, surveyId: survey.id);
      },
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
                _buildCalculatingIndicator(l10n)
              else if (hasResults)
                _buildResultsAvailableChip(l10n)
              else
                _buildStatusChip(survey.status, l10n),
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
                DateFormat.yMd(l10n.localeName).format(survey.createdAt),
                style: TextStyle(
                  color: Foundations.colors.textMuted,
                  fontSize: Foundations.typography.sm,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalculatingIndicator(AppLocalizations l10n) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          height: 16,
          width: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
          ),
        ),
        SizedBox(width: Foundations.spacing.xs),
        BaseChip(
          label: l10n.sortingModuleCalculating,
          variant: ChipVariant.secondary,
          size: ChipSize.small,
        ),
      ],
    );
  }

  Widget _buildResultsAvailableChip(AppLocalizations l10n) {
    return BaseChip(
      label: l10n.sortingModuleResultsAvailable,
      variant: ChipVariant.secondary,
      size: ChipSize.small,
      leadingIcon: Icons.check_circle,
    );
  }

  Widget _buildStatusChip(SortingSurveyStatus status, AppLocalizations l10n) {
    ChipVariant variant;
    String label;

    switch (status) {
      case SortingSurveyStatus.draft:
        variant = ChipVariant.default_;
        label = l10n.globalDraft;
        break;
      case SortingSurveyStatus.published:
        variant = ChipVariant.primary;
        label = l10n.globalPublished;
        break;
      case SortingSurveyStatus.closed:
        variant = ChipVariant.secondary;
        label = l10n.globalClosed;
        break;
    }

    return BaseChip(
      label: label,
      variant: variant,
      size: ChipSize.small,
    );
  }
}
