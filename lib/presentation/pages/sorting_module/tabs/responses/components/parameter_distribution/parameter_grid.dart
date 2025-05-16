import 'package:edconnect_admin/core/design_system/foundations.dart';
import 'package:edconnect_admin/domain/entities/sorting_survey.dart';
import 'package:edconnect_admin/l10n/app_localizations.dart';
import 'package:edconnect_admin/presentation/pages/sorting_module/tabs/responses/components/parameter_distribution/distribution_row.dart';
import 'package:edconnect_admin/presentation/widgets/common/cards/base_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ParameterGrid extends ConsumerWidget {
  final SortingSurvey survey;
  const ParameterGrid({super.key, required this.survey});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Wrap(
      spacing: Foundations.spacing.md,
      runSpacing: Foundations.spacing.md,
      children: [
        if (survey.askBiologicalSex)
          SizedBox(
            width: 400,
            height: 240,
            child: BaseCard(
              padding: EdgeInsets.all(Foundations.spacing.md),
              margin: EdgeInsets.zero,
              variant: CardVariant.outlined,
              child: _buildBiologicalSexStats(context, l10n),
            ),
          ),
        ...survey.parameters.asMap().entries.map((entry) => SizedBox(
              width: 400,
              height: 240,
              child: BaseCard(
                padding: EdgeInsets.all(Foundations.spacing.md),
                margin: EdgeInsets.zero,
                variant: CardVariant.outlined,
                child: _buildParameterStat(context, entry.value, l10n),
              ),
            )),
      ],
    );
  }

  Widget _buildBiologicalSexStats(BuildContext context, AppLocalizations l10n) {
    final responses = survey.responses;
    int males = 0, females = 0, nonBinary = 0;

    for (final response in responses.values) {
      switch (response['sex']) {
        case 'm':
          males++;
          break;
        case 'f':
          females++;
          break;
        case 'nb':
          nonBinary++;
          break;
      }
    }
    return DistributionRow(
      paramName: l10n.globalBiologicalSexLabel,
      distribution: {
        'm': males,
        'f': females,
        'nb': nonBinary,
      },
      survey: survey,
      limitEntries: false,
      isSexParameter: true,
    );
  }

  Widget _buildParameterStat(
      BuildContext context, Map<String, dynamic> param, AppLocalizations l10n) {
    final responses = survey.responses;
    final name = param['name'];
    final type = param['type'];

    if (type == 'binary') {
      int yes = 0, no = 0;
      for (final response in responses.values) {
        if (response[name] == 'yes') {
          yes++;
        } else if (response[name] == 'no') {
          no++;
        }
      }

      return DistributionRow(
        paramName: name,
        distribution: {l10n.globalYes: yes, l10n.globalNo: no},
        survey: survey,
        limitEntries: false,
      );
    } else {
      Map<String, int> distribution = {};
      for (final response in responses.values) {
        final value = response[name]?.toString() ?? 'Unknown';
        distribution[value] = (distribution[value] ?? 0) + 1;
      }

      return DistributionRow(
        paramName: name,
        distribution: distribution,
        survey: survey,
        limitEntries: true,
      );
    }
  }
}
