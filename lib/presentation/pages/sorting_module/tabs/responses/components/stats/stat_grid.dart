import 'package:edconnect_admin/core/design_system/foundations.dart';
import 'package:edconnect_admin/domain/entities/sorting_survey.dart';
import 'package:edconnect_admin/l10n/app_localizations.dart';
import 'package:edconnect_admin/presentation/pages/sorting_module/tabs/responses/components/stats/stat_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StatGrid extends ConsumerWidget {
  final SortingSurvey survey;
  const StatGrid({
    super.key,
    required this.survey,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalPreferences = survey.responses.values
        .map((r) => (r['prefs'] as List?)?.length ?? 0)
        .fold(0, (sum, count) => sum + count);
    final l10n = AppLocalizations.of(context)!;

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth =
            (constraints.maxWidth - Foundations.spacing.lg * 2) / 3;
        return Row(
          children: [
            StatCard(
                label: l10n.sortingModuleTotalResponsesLabel,
                value: survey.responses.length.toString(),
                icon: Icons.people_outline,
                width: cardWidth),
            SizedBox(width: Foundations.spacing.lg),
            StatCard(
                label: l10n.sortingModuleParameters,
                value: survey.parameters.length.toString(),
                icon: Icons.tune_outlined,
                width: cardWidth),
            SizedBox(width: Foundations.spacing.lg),
            StatCard(
                label: l10n.sortingModuleTotalNumOfPreferences,
                value: survey.maxPreferences != null
                    ? '$totalPreferences ${l10n.sortingModuleMaxPreferencesPerUser(survey.maxPreferences!)}'
                    : l10n.globalDisabledLabel,
                icon: Icons.favorite_outline_outlined,
                width: cardWidth),
          ],
        );
      },
    );
  }
}
