import 'package:edconnect_admin/presentation/pages/sorting_module/utils/parameter_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edconnect_admin/core/design_system/foundations.dart';
import 'package:edconnect_admin/presentation/pages/sorting_module/components/section_header.dart';
import 'package:edconnect_admin/presentation/providers/theme_provider.dart';
import 'package:edconnect_admin/presentation/widgets/common/cards/base_card.dart';
import 'package:edconnect_admin/presentation/widgets/common/checkbox.dart';
import 'package:edconnect_admin/presentation/widgets/common/dropdown/single_select_dropdown.dart';
import 'package:edconnect_admin/presentation/widgets/common/input/number_input.dart';

class ParametersSection extends ConsumerWidget {
  final List<Map<String, dynamic>> allParameters;
  final List<Map<String, dynamic>> selectedParameters;
  final Map<String, NumberInputController> priorityControllers;
  final Function(Map<String, dynamic>, bool) onParameterSelectionChanged;
  final Function(Map<String, dynamic>, String, String?) onParameterValueChanged;

  const ParametersSection({
    required this.allParameters,
    required this.selectedParameters,
    required this.priorityControllers,
    required this.onParameterSelectionChanged,
    required this.onParameterValueChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
            title: 'Parameters Configuration', icon: Icons.tune_outlined),
        SizedBox(height: Foundations.spacing.md),
        Wrap(
          spacing: Foundations.spacing.md,
          runSpacing: Foundations.spacing.md,
          children: allParameters
              .map((param) => _buildParameterCard(context, ref, param))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildParameterCard(
      BuildContext context, WidgetRef ref, Map<String, dynamic> param) {
    final isDarkMode = ref.watch(appThemeProvider).isDarkMode;
    final name = param['name'] as String;
    final type = param['type'] as String;
    final isSelected = selectedParameters.contains(param);

    return SizedBox(
      width: 400,
      child: BaseCard(
        margin: EdgeInsets.zero,
        variant: CardVariant.outlined,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with name, type and checkbox
            Padding(
              padding: EdgeInsets.all(Foundations.spacing.md),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ParameterFormatter.formatParameterNameForDisplay(
                              name),
                          style: TextStyle(
                            fontSize: Foundations.typography.base,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode
                                ? Foundations.darkColors.textPrimary
                                : Foundations.colors.textPrimary,
                          ),
                        ),
                        Text(
                          'Type: ${type == 'binary' ? 'Binary (Yes/No)' : 'Categorical (Text)'}',
                          style: TextStyle(
                            fontSize: Foundations.typography.sm,
                            color: isDarkMode
                                ? Foundations.darkColors.textSecondary
                                : Foundations.colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  BaseCheckbox(
                    value: isSelected,
                    onChanged: (value) {
                      onParameterSelectionChanged(param, value ?? false);
                    },
                  ),
                ],
              ),
            ),
            Divider(height: 1),
            // Controls section
            Padding(
              padding: EdgeInsets.all(Foundations.spacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BaseSelect<String>(
                    label: 'Strategy',
                    value: param['strategy'],
                    options: [
                      SelectOption(
                          value: 'distribute', label: 'Distribute Evenly'),
                      SelectOption(
                          value: 'concentrate', label: 'Concentrate Together'),
                    ],
                    onChanged: (value) {
                      onParameterValueChanged(param, 'strategy', value);
                    },
                  ),
                  SizedBox(height: Foundations.spacing.md),
                  NumberInput(
                    controller: priorityControllers[name]!,
                    label: 'Priority',
                    type: NumberFormatType.integer,
                    min: 1,
                    max: allParameters.length,
                    showStepper: true,
                    description: 'Lower numbers indicate higher priority',
                  ),
                  if (!isSelected) ...[
                    SizedBox(height: Foundations.spacing.md),
                    Container(
                      padding: EdgeInsets.all(Foundations.spacing.sm),
                      decoration: BoxDecoration(
                        color:
                            Foundations.colors.warning.withValues(alpha: 0.1),
                        borderRadius: Foundations.borders.sm,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 16,
                            color: Foundations.colors.warning,
                          ),
                          SizedBox(width: Foundations.spacing.xs),
                          Expanded(
                            child: Text(
                              'This parameter is disabled and will not be used in calculations',
                              style: TextStyle(
                                fontSize: Foundations.typography.sm,
                                color: Foundations.colors.warning,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
