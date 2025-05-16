import 'package:edconnect_admin/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edconnect_admin/core/design_system/foundations.dart';
import 'package:edconnect_admin/domain/entities/sorting_survey.dart';
import 'package:edconnect_admin/presentation/pages/sorting_module/components/section_header.dart';
import 'package:edconnect_admin/presentation/pages/sorting_module/tabs/calculate/utils/class_config.dart';
import 'package:edconnect_admin/presentation/widgets/common/buttons/base_button.dart';
import 'package:edconnect_admin/presentation/widgets/common/buttons/base_icon_button.dart';
import 'package:edconnect_admin/presentation/widgets/common/cards/base_card.dart';
import 'package:edconnect_admin/presentation/widgets/common/checkbox.dart';
import 'package:edconnect_admin/presentation/widgets/common/input/base_input.dart';
import 'package:edconnect_admin/presentation/widgets/common/input/number_input.dart';

class ClassConfigurationSection extends ConsumerStatefulWidget {
  final SortingSurvey survey;
  final List<ClassConfig> classes;
  final bool distributeBySex;
  final Function(bool) onDistributeBySexChanged;
  final Function(int) onRemoveClass;
  final Function() onAddClass;
  final TextEditingController newClassNameController;

  const ClassConfigurationSection(
      {super.key,
      required this.survey,
      required this.classes,
      required this.distributeBySex,
      required this.onDistributeBySexChanged,
      required this.onRemoveClass,
      required this.onAddClass,
      required this.newClassNameController});

  @override
  ConsumerState<ClassConfigurationSection> createState() =>
      _ClassConfigurationSectionState();
}

class _ClassConfigurationSectionState
    extends ConsumerState<ClassConfigurationSection> {
  int get totalCapacity => widget.classes
      .fold(0, (sum, c) => sum + (c.sizeController.value?.toInt() ?? 0));

  int get minimumRequired => widget.survey.responses.length;

  @override
  Widget build(
    BuildContext context,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return _buildClassConfiguration(l10n);
  }

  Widget _buildClassConfiguration(AppLocalizations l10n) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth > 900;
        final hasEnoughCapacity = totalCapacity >= minimumRequired;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
                title: l10n.sortingModuleClassConfigLabel,
                icon: Icons.school_outlined),
            SizedBox(height: Foundations.spacing.md),
            if (isWideScreen)
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 3,
                      child: BaseCard(
                        variant: CardVariant.outlined,
                        margin: EdgeInsets.zero,
                        child: Padding(
                          padding: EdgeInsets.all(Foundations.spacing.md),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.sortingModuleClassesLabel,
                                style: TextStyle(
                                  fontSize: Foundations.typography.base,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: Foundations.spacing.md),
                              Wrap(
                                spacing: Foundations.spacing.md,
                                runSpacing: Foundations.spacing.md,
                                children: [
                                  ...widget.classes
                                      .asMap()
                                      .entries
                                      .map((entry) {
                                    final index = entry.key;
                                    final classConfig = entry.value;
                                    return SizedBox(
                                      width: 400,
                                      child: _buildWideClassRow(
                                          index, classConfig, l10n),
                                    );
                                  }),
                                ],
                              ),
                              if (widget.classes.isNotEmpty)
                                Divider(height: Foundations.spacing.xl),
                              _buildWideAddClass(l10n),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: Foundations.spacing.lg),
                    // Right card - Capacity info
                    Expanded(
                      flex: 2,
                      child: BaseCard(
                        variant: CardVariant.outlined,
                        margin: EdgeInsets.zero,
                        child: Padding(
                          padding: EdgeInsets.all(Foundations.spacing.md),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (widget.survey.askBiologicalSex) ...[
                                Text(
                                  l10n.sortingModuleDistributionSettingsLabel,
                                  style: TextStyle(
                                    fontSize: Foundations.typography.base,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: Foundations.spacing.md),
                                BaseCheckbox(
                                  value: widget.distributeBySex,
                                  label: l10n
                                      .sortingModuleDistributeByBiologicalSexLabel,
                                  description: l10n
                                      .sortingModuleDistributeByBiologicalSexDescription,
                                  onChanged: (value) {
                                    widget.onDistributeBySexChanged(
                                        value ?? false);
                                  },
                                ),
                                Divider(height: Foundations.spacing.xl),
                              ],
                              Text(
                                l10n.sortingModuleCapacityInfoLabel,
                                style: TextStyle(
                                  fontSize: Foundations.typography.base,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: Foundations.spacing.md),
                              _buildCapacityInfo(hasEnoughCapacity, l10n),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              BaseCard(
                variant: CardVariant.outlined,
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: EdgeInsets.all(Foundations.spacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...widget.classes.asMap().entries.map((entry) {
                        final index = entry.key;
                        final classConfig = entry.value;
                        return Padding(
                          padding:
                              EdgeInsets.only(bottom: Foundations.spacing.md),
                          child: _buildNarrowClassRow(index, classConfig, l10n),
                        );
                      }),
                      SizedBox(height: Foundations.spacing.md),
                      _buildNarrowAddClass(l10n),
                      if (widget.classes.isNotEmpty) ...[
                        SizedBox(height: Foundations.spacing.lg),
                        const Divider(),
                        SizedBox(height: Foundations.spacing.md),
                        if (widget.survey.askBiologicalSex) ...[
                          Text(
                            l10n.sortingModuleDistributionSettingsLabel,
                            style: TextStyle(
                              fontSize: Foundations.typography.base,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: Foundations.spacing.md),
                          BaseCheckbox(
                            value: widget.distributeBySex,
                            label: l10n
                                .sortingModuleDistributeByBiologicalSexLabel,
                            description: l10n
                                .sortingModuleDistributeByBiologicalSexDescription,
                            onChanged: (value) {
                              widget.onDistributeBySexChanged(value ?? false);
                            },
                          ),
                          SizedBox(height: Foundations.spacing.lg),
                        ],
                        _buildCapacityInfo(hasEnoughCapacity, l10n),
                      ],
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildWideClassRow(
      int index, ClassConfig classConfig, AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: BaseInput(
            controller: classConfig.nameController,
            label: l10n.sortingModuleClassNameLabel,
            isRequired: true,
          ),
        ),
        SizedBox(width: Foundations.spacing.md),
        SizedBox(
          width: 200,
          child: NumberInput(
            controller: classConfig.sizeController,
            label: l10n.sortingModuleClassSizeLabel,
            type: NumberFormatType.integer,
            min: 1,
            isRequired: true,
            showStepper: true,
            step: 1,
            onChanged: (value) => setState(() {}),
          ),
        ),
        if (widget.classes.length > 1) ...[
          SizedBox(width: Foundations.spacing.md),
          BaseIconButton(
            icon: Icons.remove_circle_outline,
            onPressed: () => widget.onRemoveClass(index),
            color: Foundations.colors.error,
          ),
        ],
      ],
    );
  }

  Widget _buildNarrowClassRow(
      int index, ClassConfig classConfig, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        BaseInput(
          controller: classConfig.nameController,
          label: l10n.sortingModuleClassNameLabel,
          isRequired: true,
        ),
        SizedBox(height: Foundations.spacing.sm),
        Row(
          children: [
            Expanded(
              child: NumberInput(
                controller: classConfig.sizeController,
                label: l10n.sortingModuleClassSizeLabel,
                type: NumberFormatType.integer,
                min: 1,
                isRequired: true,
                showStepper: true,
                step: 1,
                onChanged: (value) => setState(() {}),
              ),
            ),
            if (widget.classes.length > 1) ...[
              SizedBox(width: Foundations.spacing.sm),
              BaseIconButton(
                icon: Icons.remove_circle_outline,
                onPressed: () => widget.onRemoveClass(index),
                color: Foundations.colors.error,
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildWideAddClass(AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: BaseInput(
            controller: widget.newClassNameController,
            label: l10n.sortingModuleNewClassNameLabel,
            hint: l10n.sortingModuleNewClassNameHint,
            button: BaseButton(
              onPressed: widget.onAddClass,
              prefixIcon: Icons.add,
              label: l10n.globalAdd,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNarrowAddClass(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        BaseInput(
          controller: widget.newClassNameController,
          label: l10n.sortingModuleNewClassNameLabel,
          hint: l10n.sortingModuleNewClassNameHint,
        ),
        SizedBox(height: Foundations.spacing.md),
        BaseButton(
          onPressed: widget.onAddClass,
          prefixIcon: Icons.add,
          label: l10n.globalAdd,
          fullWidth: true,
        ),
      ],
    );
  }

  Widget _buildCapacityInfo(bool hasEnoughCapacity, AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.all(Foundations.spacing.md),
      decoration: BoxDecoration(
        color: hasEnoughCapacity
            ? Foundations.colors.success.withValues(alpha: 0.1)
            : Foundations.colors.error.withValues(alpha: 0.1),
        borderRadius: Foundations.borders.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.sortingModuleTotalCapacity(totalCapacity),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: hasEnoughCapacity
                  ? Foundations.colors.success
                  : Foundations.colors.error,
            ),
          ),
          Text(
            l10n.sortingModuleMinimumRequiredCapacity(totalCapacity),
            style: TextStyle(
              color: Foundations.colors.textSecondary,
            ),
          ),
          if (!hasEnoughCapacity)
            Text(
              l10n.sortingModuleWarningMinimumRequiredCapacity,
              style: TextStyle(
                color: Foundations.colors.error,
                fontSize: Foundations.typography.sm,
              ),
            ),
          SizedBox(height: Foundations.spacing.sm),
          Text(
            l10n.sortingModuleCapacityRecommendation,
            style: TextStyle(
              color: Foundations.colors.warning,
              fontSize: Foundations.typography.sm,
            ),
          ),
        ],
      ),
    );
  }
}
