import 'package:edconnect_admin/domain/entities/sorting_survey.dart';
import 'package:edconnect_admin/presentation/widgets/common/chips.dart';
import 'package:flutter/material.dart';

class StatusChip extends StatelessWidget {
  final SortingSurveyStatus status;
  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case SortingSurveyStatus.draft:
        return BaseChip(
          label: 'Draft',
          variant: ChipVariant.default_,
          size: ChipSize.small,
        );

      case SortingSurveyStatus.published:
        return BaseChip(
          label: 'Published',
          variant: ChipVariant.primary,
          size: ChipSize.small,
        );

      case SortingSurveyStatus.closed:
        return BaseChip(
          label: 'Closed',
          variant: ChipVariant.secondary,
          size: ChipSize.small,
        );
    }
  }
}
