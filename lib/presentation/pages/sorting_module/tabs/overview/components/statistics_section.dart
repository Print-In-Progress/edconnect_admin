import 'package:edconnect_admin/core/design_system/foundations.dart';
import 'package:edconnect_admin/core/interfaces/localization_repository.dart';
import 'package:edconnect_admin/core/providers/interface_providers.dart';
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
    final l10n = AppLocalizations.of(context)!;
    final LocalizationRepository localizations =
        ref.watch(localizationRepositoryProvider);

    return Column(
      children: [
        SectionHeader(
            title: l10n.globalStatisticsLabel, icon: Icons.bar_chart_outlined),
        SizedBox(height: Foundations.spacing.md),
        InfoCard(children: [
          InfoRow(
            label: l10n.sortingModuleParameters,
            value: survey.parameters.length.toString(),
            onTap: () => _showParametersDialog(
                context, survey.parameters, l10n, localizations),
          ),
          InfoRow(
              label: l10n.sortingModuleResponses(survey.responses.length),
              value: survey.responses.length.toString()),
        ])
      ],
    );
  }

  void _showParametersDialog(
    BuildContext context,
    List<dynamic> parameters,
    AppLocalizations l10n,
    LocalizationRepository localizations,
  ) {
    Dialogs.show(
      context: context,
      variant: DialogVariant.info,
      title: l10n.sortingModuleParameters,
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
            ? [Text(l10n.sortingModuleNoParamsDefined)]
            : survey.parameters.map((param) {
                String displayName =
                    param['name']?.toString() ?? 'Unnamed Parameter';
                displayName = displayName.replaceAll('_', ' ');
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
                          '${l10n.globalTypeLabel}: ${ParameterFormatter.formatParameterType(param['type'], localizations)}'),
                      Text(
                          '${l10n.sortingModuleStrategy}: ${ParameterFormatter.formatParameterStrategy(param['strategy'], localizations)}'),
                      Text(
                          '${l10n.sortingModulePriorityLabel}: ${param['priority']} '),
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
