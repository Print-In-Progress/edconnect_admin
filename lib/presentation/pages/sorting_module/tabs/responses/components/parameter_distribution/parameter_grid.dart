import 'package:edconnect_admin/core/design_system/foundations.dart';
import 'package:edconnect_admin/domain/entities/sorting_survey.dart';
import 'package:edconnect_admin/presentation/pages/sorting_module/tabs/responses/components/parameter_distribution/distribution_row.dart';
import 'package:edconnect_admin/presentation/widgets/common/cards/base_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ParameterGrid extends ConsumerWidget {
  final SortingSurvey survey;
  const ParameterGrid({super.key, required this.survey});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Wrap(
      spacing: Foundations.spacing.md,
      runSpacing: Foundations.spacing.md,
      children: [
        // Biological Sex Card
        if (survey.askBiologicalSex)
          SizedBox(
            width: 400,
            height: 240, // Fixed height for all cards
            child: BaseCard(
              padding: EdgeInsets.all(Foundations.spacing.md),
              margin: EdgeInsets.zero,
              variant: CardVariant.outlined,
              child: _buildBiologicalSexStats(context),
            ),
          ),

        // Parameter Cards
        ...survey.parameters.asMap().entries.map((entry) => SizedBox(
              width: 400,
              height: 240, // Fixed height for all cards
              child: BaseCard(
                padding: EdgeInsets.all(Foundations.spacing.md),
                margin: EdgeInsets.zero,
                variant: CardVariant.outlined,
                child: _buildParameterStat(context, entry.value),
              ),
            )),
      ],
    );
  }

  Widget _buildBiologicalSexStats(BuildContext context) {
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
      paramName: 'Biological Sex',
      distribution: {
        'm': males, // Use raw values instead of formatted ones
        'f': females,
        'nb': nonBinary,
      },
      survey: survey,
      limitEntries: false,
      isSexParameter: true,
    );
  }

  Widget _buildParameterStat(BuildContext context, Map<String, dynamic> param) {
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
        distribution: {'Yes': yes, 'No': no},
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
