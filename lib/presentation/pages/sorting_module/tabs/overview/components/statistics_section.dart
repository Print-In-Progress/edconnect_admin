import 'package:edconnect_admin/core/design_system/foundations.dart';
import 'package:edconnect_admin/domain/entities/sorting_survey.dart';
import 'package:edconnect_admin/l10n/app_localizations.dart';
import 'package:edconnect_admin/presentation/pages/sorting_module/components/build_info_row.dart';
import 'package:edconnect_admin/presentation/pages/sorting_module/components/info_card.dart';
import 'package:edconnect_admin/presentation/pages/sorting_module/components/section_header.dart';
import 'package:edconnect_admin/presentation/pages/sorting_module/utils/parameter_formatter.dart';
import 'package:edconnect_admin/presentation/widgets/common/buttons/base_button.dart';
import 'package:edconnect_admin/presentation/widgets/common/dialogs/dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StatisticsSection extends ConsumerWidget {
  final SortingSurvey survey;
  const StatisticsSection({super.key, required this.survey});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        const SectionHeader(
            title: 'Statistics', icon: Icons.bar_chart_outlined),
        SizedBox(height: Foundations.spacing.md),
        InfoCard(children: [
          InfoRow(
            label: 'Parameters',
            value: survey.parameters.length.toString(),
            onTap: () => _showParametersDialog(context, survey.parameters),
          ),
          InfoRow(
              label: 'Responses', value: survey.responses.length.toString()),
        ])
      ],
    );
  }

  void _showParametersDialog(BuildContext context, List<dynamic> parameters) {
    Dialogs.show(
      context: context,
      variant: DialogVariant.info,
      title: 'Survey Parameters',
      actions: [
        BaseButton(
          label: AppLocalizations.of(context)!.globalOk,
          variant: ButtonVariant.filled,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: survey.parameters.isEmpty
            ? [Text('No parameters defined')]
            : survey.parameters.map((param) {
                String displayName =
                    param['name']?.toString() ?? 'Unnamed Parameter';
                // Convert snake_case to readable format
                displayName = displayName.replaceAll('_', ' ');
                // Capitalize first letter of each word
                displayName = displayName
                    .split(' ')
                    .map((word) => word.isNotEmpty
                        ? '${word[0].toUpperCase()}${word.substring(1)}'
                        : '')
                    .join(' ');

                return ListTile(
                  title: Text(displayName),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          'Type: ${ParameterFormatter.formatParameterType(param['type'])}'),
                      Text(
                          'Strategy: ${ParameterFormatter.formatParameterStrategy(param['strategy'])}'),
                      Text('Priority: ${param['priority']} '),
                    ],
                  ),
                  leading: Icon(
                    param['type'] == 'binary'
                        ? Icons.toggle_on_outlined
                        : Icons.format_list_bulleted,
                  ),
                );
              }).toList(),
      ),
    );
  }
}
