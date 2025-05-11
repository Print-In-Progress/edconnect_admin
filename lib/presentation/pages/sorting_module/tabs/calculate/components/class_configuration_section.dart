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
    return _buildClassConfiguration();
  }

  Widget _buildClassConfiguration() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth > 900;
        final hasEnoughCapacity = totalCapacity >= minimumRequired;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
                title: 'Class  Configuration', icon: Icons.school_outlined),
            SizedBox(height: Foundations.spacing.md),
            if (isWideScreen)
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Left card - Class controls
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
                                'Classes',
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
                                          index, classConfig),
                                    );
                                  }),
                                ],
                              ),
                              if (widget.classes.isNotEmpty)
                                Divider(height: Foundations.spacing.xl),
                              _buildWideAddClass(),
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
                                  'Distribution Settings',
                                  style: TextStyle(
                                    fontSize: Foundations.typography.base,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: Foundations.spacing.md),
                                BaseCheckbox(
                                  value: widget.distributeBySex,
                                  label: 'Distribute by Biological Sex',
                                  description:
                                      'Attempt to achieve an even male/female ratio in each class',
                                  onChanged: (value) {
                                    widget.onDistributeBySexChanged(
                                        value ?? false);
                                  },
                                ),
                                Divider(height: Foundations.spacing.xl),
                              ],
                              Text(
                                'Capacity Information',
                                style: TextStyle(
                                  fontSize: Foundations.typography.base,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: Foundations.spacing.md),
                              _buildCapacityInfo(hasEnoughCapacity),
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
                          child: _buildNarrowClassRow(index, classConfig),
                        );
                      }),
                      SizedBox(height: Foundations.spacing.md),
                      _buildNarrowAddClass(),
                      if (widget.classes.isNotEmpty) ...[
                        SizedBox(height: Foundations.spacing.lg),
                        const Divider(),
                        SizedBox(height: Foundations.spacing.md),
                        if (widget.survey.askBiologicalSex) ...[
                          Text(
                            'Distribution Settings',
                            style: TextStyle(
                              fontSize: Foundations.typography.base,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: Foundations.spacing.md),
                          BaseCheckbox(
                            value: widget.distributeBySex,
                            label: 'Distribute by Biological Sex',
                            description:
                                'Attempt to achieve an even male/female ratio in each class',
                            onChanged: (value) {
                              widget.onDistributeBySexChanged(value ?? false);
                            },
                          ),
                          SizedBox(height: Foundations.spacing.lg),
                        ],
                        _buildCapacityInfo(hasEnoughCapacity),
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

  Widget _buildWideClassRow(int index, ClassConfig classConfig) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: BaseInput(
            controller: classConfig.nameController,
            label: 'Class Name',
            isRequired: true,
          ),
        ),
        SizedBox(width: Foundations.spacing.md),
        SizedBox(
          width: 200,
          child: NumberInput(
            controller: classConfig.sizeController,
            label: 'Class Size',
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

  Widget _buildNarrowClassRow(int index, ClassConfig classConfig) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        BaseInput(
          controller: classConfig.nameController,
          label: 'Class Name',
          isRequired: true,
        ),
        SizedBox(height: Foundations.spacing.sm),
        Row(
          children: [
            Expanded(
              child: NumberInput(
                controller: classConfig.sizeController,
                label: 'Class Size',
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

  Widget _buildWideAddClass() {
    return Row(
      children: [
        Expanded(
          child: BaseInput(
            controller: widget.newClassNameController,
            label: 'New Class Name',
            hint: 'Leave empty for automatic naming',
            button: BaseButton(
              onPressed: widget.onAddClass,
              prefixIcon: Icons.add,
              label: 'Add Class',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNarrowAddClass() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        BaseInput(
          controller: widget.newClassNameController,
          label: 'New Class Name',
          hint: 'Leave empty for automatic naming',
        ),
        SizedBox(height: Foundations.spacing.md),
        BaseButton(
          onPressed: widget.onAddClass,
          prefixIcon: Icons.add,
          label: 'Add Class',
          fullWidth: true,
        ),
      ],
    );
  }

  Widget _buildCapacityInfo(bool hasEnoughCapacity) {
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
            'Total Capacity: $totalCapacity students',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: hasEnoughCapacity
                  ? Foundations.colors.success
                  : Foundations.colors.error,
            ),
          ),
          Text(
            'Minimum Required: $minimumRequired students',
            style: TextStyle(
              color: Foundations.colors.textSecondary,
            ),
          ),
          if (!hasEnoughCapacity)
            Text(
              'Warning: Total capacity must be at least equal to the number of students',
              style: TextStyle(
                color: Foundations.colors.error,
                fontSize: Foundations.typography.sm,
              ),
            ),
          SizedBox(height: Foundations.spacing.sm),
          Text(
            'Recommendation: Consider leaving space for at least one additional student per class for better algorithm flexibility.',
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
