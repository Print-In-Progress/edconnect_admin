import 'package:edconnect_admin/l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;

    return InfoCard(
      children: [
        InfoRow(
          label: l10n.globalTitle,
          value: survey.title,
        ),
        if (survey.description.isNotEmpty)
          InfoRow(
            label: l10n.globalDescription,
            value: survey.description,
          ),
        InfoRow(
          label: l10n.globalStatusLabel,
          value: _getStatusText(survey.status, l10n),
          trailing: StatusChip(status: survey.status),
        ),
        InfoRow(
          label: l10n.globalCreatedAtLabel,
          value: _formatDate(survey.createdAt),
        ),
        InfoRow(
          label: l10n.globalCreatedByLabel,
          value: survey.creatorName,
        ),
        InfoRow(
          label: l10n.sortingModuleAskForBiologicalSex,
          value: survey.askBiologicalSex ? l10n.globalYes : l10n.globalNo,
        ),
      ],
    );
  }

  String _getStatusText(SortingSurveyStatus status, AppLocalizations l10n) {
    switch (status) {
      case SortingSurveyStatus.draft:
        return l10n.globalDraft;
      case SortingSurveyStatus.published:
        return l10n.globalPublished;
      case SortingSurveyStatus.closed:
        return l10n.globalClosed;
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat.yMEd().format(date);
  }
}
