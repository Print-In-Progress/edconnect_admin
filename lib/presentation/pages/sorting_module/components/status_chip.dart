import 'package:edconnect_admin/domain/entities/sorting_survey.dart';
import 'package:edconnect_admin/l10n/app_localizations.dart';
import 'package:edconnect_admin/presentation/widgets/common/chips.dart';
import 'package:flutter/material.dart';

class StatusChip extends StatelessWidget {
  final SortingSurveyStatus status;
  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (status) {
      case SortingSurveyStatus.draft:
        return BaseChip(
          label: l10n.globalDraft,
          variant: ChipVariant.default_,
          size: ChipSize.small,
        );

      case SortingSurveyStatus.published:
        return BaseChip(
          label: l10n.globalPublished,
          variant: ChipVariant.primary,
          size: ChipSize.small,
        );

      case SortingSurveyStatus.closed:
        return BaseChip(
          label: l10n.globalClosed,
          variant: ChipVariant.secondary,
          size: ChipSize.small,
        );
    }
  }
}
