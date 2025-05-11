import 'package:edconnect_admin/presentation/pages/sorting_module/components/build_info_row.dart';
import 'package:edconnect_admin/presentation/pages/sorting_module/components/status_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edconnect_admin/domain/entities/sorting_survey.dart';
import 'package:edconnect_admin/presentation/pages/sorting_module/components/info_card.dart';
import 'package:intl/intl.dart';

class BasicInfoSection extends ConsumerWidget {
  final SortingSurvey survey;

  const BasicInfoSection({
    required this.survey,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InfoCard(
      children: [
        InfoRow(
          label: 'Title',
          value: survey.title,
        ),
        if (survey.description.isNotEmpty)
          InfoRow(
            label: 'Description',
            value: survey.description,
          ),
        InfoRow(
          label: 'Status',
          value: _getStatusText(survey.status),
          trailing: StatusChip(status: survey.status),
        ),
        InfoRow(
          label: 'Created',
          value: _formatDate(survey.createdAt),
        ),
        InfoRow(
          label: 'Created By',
          value: survey.creatorName,
        ),
        InfoRow(
          label: 'Ask Biological Sex',
          value: survey.askBiologicalSex ? 'Yes' : 'No',
        ),
      ],
    );
  }

  String _getStatusText(SortingSurveyStatus status) {
    switch (status) {
      case SortingSurveyStatus.draft:
        return 'Draft';
      case SortingSurveyStatus.published:
        return 'Published';
      case SortingSurveyStatus.closed:
        return 'Closed';
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat.yMEd().format(date);
  }
}
