import 'package:edconnect_admin/l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;
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
                    l10n.sortingModuleParameters,
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
                  label: l10n.globalAdd,
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
                label: l10n.sortingModuleAskForBiologicalSex,
                size: CheckboxSize.medium,
                onChanged: (value) =>
                    onAskBiologicalSexChanged(value ?? false)),
            BaseCheckbox(
              value: allowPreferences,
              label: l10n.sortingModuleAskForPreferences,
              size: CheckboxSize.medium,
              onChanged: (value) => onAllowPreferencesChanged(value ?? false),
            ),
            if (allowPreferences) ...[
              SizedBox(height: Foundations.spacing.sm),
              NumberInput(
                label: l10n.sortingModuleMaximumPreferencesLabel,
                description: l10n.sortingModuleMaximumPreferencesDescription,
                controller: maxPreferencesController,
                min: 1,
                max: 10,
                showStepper: true,
              ),
            ],
            SizedBox(height: Foundations.spacing.lg),
            ...parameters.map((param) => _buildParameterItem(param, l10n)),
          ],
        ),
      ),
    );
  }

  Widget _buildParameterItem(
      Map<String, dynamic> parameter, AppLocalizations l10n) {
    return Card(
      margin: EdgeInsets.only(bottom: Foundations.spacing.md),
      child: Padding(
        padding: EdgeInsets.all(Foundations.spacing.md),
        child: Column(
          children: [
            BaseInput(
              label: l10n.sortingModuleParameterName,
              controller: parameter['name'],
            ),
            SizedBox(height: Foundations.spacing.sm),
            Row(
              children: [
                Expanded(
                  child: BaseSelect<String>(
                    label: l10n.globalTypeLabel,
                    value: parameter['type'],
                    options: [
                      SelectOption(
                          value: 'binary', label: l10n.sortingModuleTypeBinary),
                      SelectOption(
                          value: 'categorical',
                          label: l10n.sortingModuleTypeCategorical),
                    ],
                    onChanged: (value) =>
                        onUpdateParameter(parameter, 'type', value),
                  ),
                ),
                SizedBox(width: Foundations.spacing.md),
                Expanded(
                  child: BaseSelect<String>(
                    label: l10n.sortingModuleStrategy,
                    value: parameter['strategy'],
                    options: [
                      SelectOption(
                          value: 'distribute',
                          label: l10n.sortingModuleStrategyDistribute),
                      SelectOption(
                          value: 'concentrate',
                          label: l10n.sortingModuleStrategyConcentrate),
                    ],
                    onChanged: (value) =>
                        onUpdateParameter(parameter, 'strategy', value),
                  ),
                ),
              ],
            ),
            SizedBox(height: Foundations.spacing.sm),
            NumberInput(
              label: l10n.sortingModulePriorityLabel,
              description: l10n.sortingModulePriorityDescription,
              controller: parameter['priority'],
              min: 1,
              max: 10,
              showStepper: true,
            ),
            SizedBox(height: Foundations.spacing.sm),
            Align(
              alignment: Alignment.centerRight,
              child: BaseButton(
                label: l10n.globalDelete,
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
