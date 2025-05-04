import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edconnect_admin/core/design_system/foundations.dart';
import 'package:edconnect_admin/presentation/providers/theme_provider.dart';
import 'package:edconnect_admin/presentation/widgets/common/buttons/base_button.dart';
import 'package:edconnect_admin/presentation/widgets/common/cards/base_card.dart';
import 'package:edconnect_admin/presentation/widgets/common/checkbox.dart';
import 'package:edconnect_admin/presentation/widgets/common/dropdown/single_select_dropdown.dart';
import 'package:edconnect_admin/presentation/widgets/common/input/base_input.dart';
import 'package:edconnect_admin/presentation/widgets/common/input/number_input.dart';

class ParametersCard extends ConsumerWidget {
  final List<Map<String, dynamic>> parameters;
  final bool askBiologicalSex;
  final bool allowPreferences;
  final NumberInputController maxPreferencesController;
  final VoidCallback onAddParameter;
  final Function(Map<String, dynamic>) onRemoveParameter;
  final Function(Map<String, dynamic>, String, dynamic) onUpdateParameter;
  final Function(bool) onAskBiologicalSexChanged;
  final Function(bool) onAllowPreferencesChanged;

  const ParametersCard({
    required this.parameters,
    required this.askBiologicalSex,
    required this.allowPreferences,
    required this.maxPreferencesController,
    required this.onAddParameter,
    required this.onRemoveParameter,
    required this.onUpdateParameter,
    required this.onAskBiologicalSexChanged,
    required this.onAllowPreferencesChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeProvider);

    return BaseCard(
      variant: CardVariant.elevated,
      child: Padding(
        padding: EdgeInsets.all(Foundations.spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Parameters',
                    style: TextStyle(
                      fontSize: Foundations.typography.lg,
                      fontWeight: Foundations.typography.semibold,
                      color: theme.isDarkMode
                          ? Foundations.darkColors.textPrimary
                          : Foundations.colors.textPrimary,
                    ),
                  ),
                ),
                BaseButton(
                  label: 'Add Parameter',
                  prefixIcon: Icons.add,
                  variant: ButtonVariant.outlined,
                  size: ButtonSize.medium,
                  onPressed: onAddParameter,
                ),
              ],
            ),
            SizedBox(height: Foundations.spacing.lg),
            BaseCheckbox(
                value: askBiologicalSex,
                label: 'Ask respondents their biological sex',
                size: CheckboxSize.medium,
                onChanged: (value) =>
                    onAskBiologicalSexChanged(value ?? false)),
            BaseCheckbox(
              value: allowPreferences,
              label: 'Allow respondents to select preferred people',
              size: CheckboxSize.medium,
              onChanged: (value) => onAllowPreferencesChanged(value ?? false),
            ),
            if (allowPreferences) ...[
              SizedBox(height: Foundations.spacing.sm),
              NumberInput(
                label: 'Maximum Preferences',
                description: 'Maximum number of people that can be selected',
                controller: maxPreferencesController,
                min: 1,
                max: 5,
                showStepper: true,
              ),
            ],
            SizedBox(height: Foundations.spacing.lg),
            ...parameters.map((param) => _buildParameterItem(param)),
          ],
        ),
      ),
    );
  }

  Widget _buildParameterItem(Map<String, dynamic> parameter) {
    return Card(
      margin: EdgeInsets.only(bottom: Foundations.spacing.md),
      child: Padding(
        padding: EdgeInsets.all(Foundations.spacing.md),
        child: Column(
          children: [
            BaseInput(
              label: 'Parameter Name',
              controller: parameter['name'],
            ),
            SizedBox(height: Foundations.spacing.sm),
            Row(
              children: [
                Expanded(
                  child: BaseSelect<String>(
                    label: 'Type',
                    value: parameter['type'],
                    options: [
                      SelectOption(value: 'binary', label: 'Binary (Yes/No)'),
                      SelectOption(
                          value: 'categorical', label: 'Categorical (Text)'),
                    ],
                    onChanged: (value) =>
                        onUpdateParameter(parameter, 'type', value),
                  ),
                ),
                SizedBox(width: Foundations.spacing.md),
                Expanded(
                  child: BaseSelect<String>(
                    label: 'Strategy',
                    value: parameter['strategy'],
                    options: [
                      SelectOption(value: 'distribute', label: 'Distribute'),
                      SelectOption(value: 'concentrate', label: 'Concentrate'),
                    ],
                    onChanged: (value) =>
                        onUpdateParameter(parameter, 'strategy', value),
                  ),
                ),
              ],
            ),
            SizedBox(height: Foundations.spacing.sm),
            NumberInput(
              label: 'Priority',
              description: 'Lower numbers indicates higher priority (1-5)',
              controller: parameter['priority'],
              min: 1,
              max: 5,
              showStepper: true,
            ),
            SizedBox(height: Foundations.spacing.sm),
            Align(
              alignment: Alignment.centerRight,
              child: BaseButton(
                label: 'Remove',
                prefixIcon: Icons.delete_outline,
                backgroundColor: Foundations.colors.error,
                size: ButtonSize.small,
                onPressed: () => onRemoveParameter(parameter),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
