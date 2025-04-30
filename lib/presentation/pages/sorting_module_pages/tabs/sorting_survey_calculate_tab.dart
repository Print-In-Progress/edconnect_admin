import 'package:edconnect_admin/core/design_system/foundations.dart';
import 'package:edconnect_admin/core/errors/error_handler.dart';
import 'package:edconnect_admin/core/errors/error_messages.dart';
import 'package:edconnect_admin/domain/entities/sorting_survey.dart';
import 'package:edconnect_admin/presentation/providers/state_providers.dart';
import 'package:edconnect_admin/presentation/providers/theme_provider.dart';
import 'package:edconnect_admin/presentation/widgets/common/buttons/base_button.dart';
import 'package:edconnect_admin/presentation/widgets/common/buttons/base_icon_button.dart';
import 'package:edconnect_admin/presentation/widgets/common/cards/base_card.dart';
import 'package:edconnect_admin/presentation/widgets/common/checkbox.dart';
import 'package:edconnect_admin/presentation/widgets/common/dialogs/dialogs.dart';
import 'package:edconnect_admin/presentation/widgets/common/dropdown/single_select_dropdown.dart';
import 'package:edconnect_admin/presentation/widgets/common/input/base_input.dart';
import 'package:edconnect_admin/presentation/widgets/common/input/number_input.dart';
import 'package:edconnect_admin/presentation/widgets/common/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;

class ClassConfig {
  final TextEditingController nameController;
  final NumberInputController sizeController;

  ClassConfig({
    required String name,
    required this.sizeController,
  }) : nameController = TextEditingController(text: name);

  void dispose() {
    nameController.dispose();
    sizeController.dispose();
  }
}

class CalculateTab extends ConsumerStatefulWidget {
  final SortingSurvey survey;

  const CalculateTab({super.key, required this.survey});

  @override
  ConsumerState<CalculateTab> createState() => _CalculateTabState();
}

class _CalculateTabState extends ConsumerState<CalculateTab> {
  bool distributeBySex = true;
  int timeLimit = 120;
  late List<Map<String, dynamic>> allParameters;
  late List<Map<String, dynamic>> selectedParameters;
  late NumberInputController numberOfClassesController;
  late Map<String, NumberInputController> priorityControllers;
  int studentsPerClass = 0;
  late List<ClassConfig> classes;
  late TextEditingController newClassNameController;
  int get totalCapacity =>
      classes.fold(0, (sum, c) => sum + (c.sizeController.value?.toInt() ?? 0));
  int get minimumRequired => widget.survey.responses.length;

  @override
  void initState() {
    super.initState();
    allParameters = List.from(widget.survey.parameters);
    selectedParameters = List.from(widget.survey.parameters);

    // Initialize controller with default value
    numberOfClassesController = NumberInputController(initialValue: 1);

    // Calculate initial students per class
    final totalStudents = widget.survey.responses.length;
    studentsPerClass =
        (totalStudents / numberOfClassesController.value!).ceil();
    priorityControllers = {
      for (var param in allParameters)
        param['name']: NumberInputController(initialValue: param['priority'])
    };

    classes = [
      ClassConfig(
        name: '1',
        sizeController: NumberInputController(
          initialValue: (widget.survey.responses.length / 1).ceil(),
        ),
      )
    ];
    newClassNameController = TextEditingController();
  }

  @override
  void dispose() {
    numberOfClassesController.dispose();
    for (var controller in priorityControllers.values) {
      controller.dispose();
    }
    for (var classConfig in classes) {
      classConfig.dispose(); // Now uses the ClassConfig dispose method
    }
    newClassNameController.dispose();
    super.dispose();
  }

// Update addClass
  void addClass() {
    final name = newClassNameController.text.isEmpty
        ? '${classes.length + 1}'
        : newClassNameController.text;

    setState(() {
      classes.add(ClassConfig(
        name: name,
        sizeController: NumberInputController(
          initialValue:
              (widget.survey.responses.length / (classes.length + 1)).ceil(),
        ),
      ));
      newClassNameController.clear();
    });
  }

  void removeClass(int index) {
    if (index < 0 || index >= classes.length) return;

    final classConfig = classes[index];
    setState(() {
      classes.removeAt(index);
    });

    // Dispose the controllers to prevent memory leaks
    classConfig.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.survey.status != SortingSurveyStatus.closed) {
      return Center(
        child: Text(
          'Please close the survey before starting the calculation process.',
          style: TextStyle(
            color: Foundations.colors.textMuted,
            fontSize: Foundations.typography.lg,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(Foundations.spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildClassConfiguration(),
            SizedBox(height: Foundations.spacing.xl),
            _buildParametersSection(),
            SizedBox(height: Foundations.spacing.xl),
            _buildCalculateSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildClassConfiguration() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth > 900;
        final hasEnoughCapacity = totalCapacity >= minimumRequired;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              context,
              'Class Configuration',
              Icons.school_outlined,
              ref.watch(appThemeProvider).isDarkMode,
            ),
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
                                  ...classes.asMap().entries.map((entry) {
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
                              if (classes.isNotEmpty)
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
                                  value: distributeBySex,
                                  label: 'Distribute by Biological Sex',
                                  description:
                                      'Attempt to achieve an even male/female ratio in each class',
                                  onChanged: (value) {
                                    setState(() {
                                      distributeBySex = value ?? false;
                                    });
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
                      ...classes.asMap().entries.map((entry) {
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
                      if (classes.isNotEmpty) ...[
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
                            value: distributeBySex,
                            label: 'Distribute by Biological Sex',
                            description:
                                'Attempt to achieve an even male/female ratio in each class',
                            onChanged: (value) {
                              setState(() {
                                distributeBySex = value ?? false;
                              });
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

  Widget _buildSectionHeader(
      BuildContext context, String title, IconData icon, bool isDarkMode) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: isDarkMode
              ? Foundations.darkColors.textMuted
              : Foundations.colors.textMuted,
        ),
        SizedBox(width: Foundations.spacing.sm),
        Text(
          title,
          style: TextStyle(
            fontSize: Foundations.typography.lg,
            fontWeight: Foundations.typography.semibold,
            color: isDarkMode
                ? Foundations.darkColors.textPrimary
                : Foundations.colors.textPrimary,
          ),
        ),
      ],
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
        if (classes.length > 1) ...[
          SizedBox(width: Foundations.spacing.md),
          BaseIconButton(
            icon: Icons.remove_circle_outline,
            onPressed: () => removeClass(index),
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
            if (classes.length > 1) ...[
              SizedBox(width: Foundations.spacing.sm),
              BaseIconButton(
                icon: Icons.remove_circle_outline,
                onPressed: () => removeClass(index),
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
            controller: newClassNameController,
            label: 'New Class Name',
            hint: 'Leave empty for automatic naming',
            button: BaseButton(
              onPressed: addClass,
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
          controller: newClassNameController,
          label: 'New Class Name',
          hint: 'Leave empty for automatic naming',
        ),
        SizedBox(height: Foundations.spacing.md),
        BaseButton(
          onPressed: addClass,
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

  Widget _buildParametersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          context,
          'Parameters Configuration',
          Icons.tune_outlined,
          ref.watch(appThemeProvider).isDarkMode,
        ),
        SizedBox(height: Foundations.spacing.md),
        Wrap(
          spacing: Foundations.spacing.md,
          runSpacing: Foundations.spacing.md,
          children:
              allParameters.map((param) => _buildParameterCard(param)).toList(),
        ),
      ],
    );
  }

  Widget _buildParameterCard(Map<String, dynamic> param) {
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
                          _formatParameterName(name),
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
                      setState(() {
                        if (value == true) {
                          selectedParameters.add(param);
                        } else {
                          selectedParameters.remove(param);
                        }
                      });
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
                      if (value != null) {
                        setState(() => param['strategy'] = value);
                      }
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

  String _formatParameterName(String name) {
    return name
        .split('_')
        .map((word) => word.isNotEmpty
            ? '${word[0].toUpperCase()}${word.substring(1)}'
            : '')
        .join(' ');
  }

  Widget _buildDetailChip(String label, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Foundations.spacing.sm,
        vertical: Foundations.spacing.xs,
      ),
      decoration: BoxDecoration(
        color: Foundations.colors.surfaceActive.withValues(alpha: 0.2),
        borderRadius: Foundations.borders.sm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Foundations.colors.textMuted),
          SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: Foundations.typography.xs,
              color: Foundations.colors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalculateSection() {
    // Check if calculation results are available
    final hasResults = widget.survey.calculationResults != null &&
        widget.survey.calculationResults!.isNotEmpty;

    final complexityReport = generateComplexityReport(
      students: widget.survey.responses,
      classes: {
        for (var clazz in classes)
          clazz.nameController.text: clazz.sizeController.value?.toInt() ?? 0
      },
      parameters: selectedParameters
          .map((p) => {
                'name': p['name'],
                'type': p['type'],
                'strategy': p['strategy'],
                'priority': priorityControllers[p['name']]?.value?.toInt() ?? 1,
              })
          .toList(),
      factorGender: distributeBySex && widget.survey.askBiologicalSex,
    );

    // Get values from report
    final varCounts = complexityReport['variables'] as Map<String, int>;
    final complexityColor = Foundations.colors.backgroundSubtle;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          context,
          'Calculate',
          Icons.calculate_outlined,
          ref.watch(appThemeProvider).isDarkMode,
        ),
        SizedBox(height: Foundations.spacing.md),
        LayoutBuilder(
          builder: (context, constraints) {
            final isWideScreen = constraints.maxWidth > 900;

            return BaseCard(
              variant: CardVariant.outlined,
              margin: EdgeInsets.zero,
              padding: EdgeInsets.all(Foundations.spacing.md),
              child: hasResults
                  ? _buildExistingResultsSection(isWideScreen)
                  : _buildNewCalculationSection(
                      complexityReport,
                      varCounts,
                      complexityColor,
                      isWideScreen,
                    ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildNewCalculationSection(
    Map<String, dynamic> complexityReport,
    Map<String, int> varCounts,
    Color complexityColor,
    bool isWideScreen,
  ) {
    return Column(children: [
      Container(
        padding: EdgeInsets.all(Foundations.spacing.md),
        decoration: BoxDecoration(
          color: complexityColor.withValues(alpha: 0.1),
          borderRadius: Foundations.borders.md,
          border: Border.all(color: complexityColor.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildComplexityItem(
                    'Variables',
                    varCounts['totalVariables'].toString(),
                    Icons.data_object,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Problem Size',
                  style: TextStyle(
                    fontSize: Foundations.typography.sm,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: Foundations.spacing.xs),
                Wrap(
                  spacing: Foundations.spacing.md,
                  runSpacing: Foundations.spacing.xs,
                  children: [
                    _buildDetailChip(
                      'Students: ${complexityReport['problemSize']['students']}',
                      Icons.person_outline,
                    ),
                    _buildDetailChip(
                      'Classes: ${complexityReport['problemSize']['classes']}',
                      Icons.category_outlined,
                    ),
                    _buildDetailChip(
                      'Parameters: ${complexityReport['problemSize']['parameters']}',
                      Icons.tune_outlined,
                    ),
                    _buildDetailChip(
                      'Preferences: ${complexityReport['problemSize']['totalPreferences']}',
                      Icons.favorite_outline,
                    ),
                  ],
                ),
                SizedBox(height: Foundations.spacing.md),
              ],
            ),
          ],
        ),
      ),
      SizedBox(height: Foundations.spacing.lg),
      SizedBox(
          width: isWideScreen ? 800 : double.infinity,
          child: Column(
            children: [
              // Time limit selection
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Maximum Calculation Time',
                          style: TextStyle(
                            fontSize: Foundations.typography.base,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: Foundations.spacing.xs),
                        Text(
                          'The algorithm will attempt to find the best solution within this time limit. In most cases, it will find a solution faster.',
                          style: TextStyle(
                            fontSize: Foundations.typography.sm,
                            color: Foundations.colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: Foundations.spacing.md),
                  SizedBox(
                    width: 160,
                    child: BaseSelect<int>(
                      value: timeLimit,
                      label: 'Time Limit',
                      options: [
                        SelectOption(value: 30, label: '30 seconds'),
                        SelectOption(value: 60, label: '1 minute'),
                        SelectOption(value: 120, label: '2 minutes'),
                        SelectOption(value: 300, label: '5 minutes'),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => timeLimit = value);
                        }
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: Foundations.spacing.xl),
              // Calculate button
              if (ref.watch(calculationStateProvider).isCalculating)
                Padding(
                  padding: EdgeInsets.only(top: Foundations.spacing.md),
                  child: Text(
                    'Calculating... This may take a  moment depending on the complexity of your parameters. Please do not close the app.',
                    style: TextStyle(
                      fontSize: Foundations.typography.sm,
                      color: Foundations.colors.textSecondary,
                    ),
                  ),
                ),

              Center(
                child: BaseButton(
                  variant: ButtonVariant.filled,
                  size: ButtonSize.large,
                  prefixIcon: Icons.calculate_outlined,
                  label: 'Calculate Classes',
                  isLoading: ref.watch(calculationStateProvider).isCalculating,
                  onPressed: () async {
                    // Get class sizes

                    final Map<String, int> formattedClasses = {
                      for (var clazz in classes)
                        clazz.nameController.text:
                            clazz.sizeController.value?.toInt() ?? 0
                    };
                    // Filter and format selected parameters
                    final parameters = selectedParameters
                        .map((p) => {
                              'name': p['name'],
                              'type': p['type'],
                              'strategy': p['strategy'],
                              'priority': priorityControllers[p['name']]
                                      ?.value
                                      ?.toInt() ??
                                  1,
                            })
                        .toList();

                    try {
                      await ref
                          .read(calculationStateProvider.notifier)
                          .calculate(
                            responses: widget.survey.responses,
                            classes: formattedClasses,
                            parameters: parameters,
                            distributeBiologicalSex: distributeBySex,
                            timeLimit: timeLimit,
                            surveyId: widget.survey.id,
                          );

                      // Handle successful calculation

                      ref.read(calculationStateProvider).result;
                      final state = ref.read(calculationStateProvider);

                      if (state.error != null) {
                        if (context.mounted) {
                          final exception = ErrorHandler.handle(state.error);
                          Toaster.error(
                            context,
                            'Calculation Error',
                            description: exception.getLocalizedMessage(context),
                          );
                        }
                      } else if (state.result != null && context.mounted) {
                        Toaster.success(
                          context,
                          'Success',
                          description:
                              'Classes calculated successfully! Navigate to the results page to view them.',
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        final exception = ErrorHandler.handle(e);
                        Toaster.error(
                          context,
                          'Calculation Error',
                          description: exception.getLocalizedMessage(context),
                        );
                      }
                    }
                  },
                ),
              ),
            ],
          ))
    ]);
  }

  Widget _buildExistingResultsSection(bool isWideScreen) {
    final metrics = widget.survey.calculationMetrics;
    final results = widget.survey.calculationResults;

    // Count students per class
    final classDistribution = <String, int>{};
    results!.forEach((className, studentList) {
      classDistribution[className] = (studentList as List).length;
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(Foundations.spacing.md),
          decoration: BoxDecoration(
            color: Foundations.colors.success.withOpacity(0.1),
            borderRadius: Foundations.borders.md,
            border: Border.all(
              color: Foundations.colors.success.withOpacity(0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: Foundations.colors.success,
                    size: 20,
                  ),
                  SizedBox(width: Foundations.spacing.sm),
                  Text(
                    'Calculation Completed',
                    style: TextStyle(
                      fontSize: Foundations.typography.base,
                      fontWeight: Foundations.typography.semibold,
                      color: Foundations.colors.success,
                    ),
                  ),
                ],
              ),
              SizedBox(height: Foundations.spacing.md),

              // Calculation metrics
              Wrap(
                spacing: Foundations.spacing.xl,
                runSpacing: Foundations.spacing.md,
                children: [
                  _buildResultsMetric(
                    'Runtime',
                    '${metrics?['runtime_seconds']?.toStringAsFixed(2) ?? "N/A"} sec',
                    Icons.timer_outlined,
                  ),
                  _buildResultsMetric(
                    'Classes',
                    '${results.length}',
                    Icons.category_outlined,
                  ),
                  _buildResultsMetric(
                    'Students',
                    '${metrics?['num_students'] ?? widget.survey.responses.length}',
                    Icons.people_outline,
                  ),
                  _buildResultsMetric(
                    'Parameters',
                    '${(metrics?['parameters_used'] as List?)?.length ?? "N/A"}',
                    Icons.tune_outlined,
                  ),
                ],
              ),

              SizedBox(height: Foundations.spacing.md),

              // Class distribution
              Text(
                'Class Distribution',
                style: TextStyle(
                  fontSize: Foundations.typography.sm,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: Foundations.spacing.xs),
              Wrap(
                spacing: Foundations.spacing.md,
                runSpacing: Foundations.spacing.xs,
                children: classDistribution.entries
                    .map(
                      (entry) => _buildDetailChip(
                        '${entry.key}: ${entry.value} students',
                        Icons.groups_outlined,
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
        SizedBox(height: Foundations.spacing.xl),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            BaseButton(
              label: 'See Results',
              variant: ButtonVariant.filled,
              prefixIcon: Icons.visibility_outlined,
              size: ButtonSize.large,
              onPressed: () {
                // Navigate to results tab
                ref
                    .read(surveyTabIndexProvider(widget.survey.id).notifier)
                    .state = 3;
              },
            ),
            SizedBox(width: Foundations.spacing.lg),
            BaseButton(
              label: 'Recalculate',
              variant: ButtonVariant.outlined,
              prefixIcon: Icons.refresh_outlined,
              size: ButtonSize.large,
              onPressed: () async {
                // Confirm recalculation
                final confirmed = await Dialogs.confirm(
                  context: context,
                  title: 'Recalculate Classes?',
                  message:
                      'This will overwrite your current calculation results. Are you sure you want to proceed?',
                  confirmText: 'Recalculate',
                );

                if (confirmed == true) {
                  // Proceed with calculation
                  _calculateClasses();
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildResultsMetric(String label, String value, IconData icon) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: Foundations.colors.textMuted),
            SizedBox(width: Foundations.spacing.xs),
            Text(
              label,
              style: TextStyle(
                fontSize: Foundations.typography.sm,
                color: Foundations.colors.textMuted,
              ),
            ),
          ],
        ),
        SizedBox(height: Foundations.spacing.xs),
        Text(
          value,
          style: TextStyle(
            fontSize: Foundations.typography.base,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  void _calculateClasses() async {
    final Map<String, int> formattedClasses = {
      for (var clazz in classes)
        clazz.nameController.text: clazz.sizeController.value?.toInt() ?? 0
    };

    // Filter and format selected parameters
    final parameters = selectedParameters
        .map((p) => {
              'name': p['name'],
              'type': p['type'],
              'strategy': p['strategy'],
              'priority': priorityControllers[p['name']]?.value?.toInt() ?? 1,
            })
        .toList();

    try {
      await ref.read(calculationStateProvider.notifier).calculate(
            responses: widget.survey.responses,
            classes: formattedClasses,
            parameters: parameters,
            distributeBiologicalSex: distributeBySex,
            timeLimit: timeLimit,
            surveyId: widget.survey.id,
          );

      // Handle successful calculation
      ref.read(calculationStateProvider).result;
      final state = ref.read(calculationStateProvider);

      if (state.error != null) {
        if (context.mounted) {
          final exception = ErrorHandler.handle(state.error);
          Toaster.error(
            context,
            'Calculation Error',
            description: exception.getLocalizedMessage(context),
          );
        }
      } else if (state.result != null && context.mounted) {
        Toaster.success(
          context,
          'Success',
          description:
              'Classes calculated successfully! Navigate to the results page to view them.',
        );
      }
    } catch (e) {
      if (context.mounted) {
        final exception = ErrorHandler.handle(e);
        Toaster.error(
          context,
          'Calculation Error',
          description: exception.getLocalizedMessage(context),
        );
      }
    }
  }

  Widget _buildComplexityItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: Foundations.colors.textMuted),
            SizedBox(width: Foundations.spacing.xs),
            Text(
              label,
              style: TextStyle(
                fontSize: Foundations.typography.sm,
                color: Foundations.colors.textMuted,
              ),
            ),
          ],
        ),
        SizedBox(height: Foundations.spacing.xs),
        Text(
          value,
          style: TextStyle(
            fontSize: Foundations.typography.base,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

Map<String, int> countVariables({
  required Map<String, dynamic> students,
  required Map<String, int> classes,
  required List<Map<String, dynamic>> parameters,
  required bool factorGender,
}) {
  final result = <String, int>{};

  // 1. Base assignment variables (one per student-class pair)
  final assignmentVars = students.length * classes.length;
  result['assignmentVariables'] = assignmentVars;

  // 2. Parameter variables
  int parameterVars = 0;
  int binaryParamVars = 0;
  int categoricalParamVars = 0;

  for (var param in parameters) {
    String paramName = param['name'];
    String paramType = param['type'] ?? 'binary';
    String strategy = param['strategy'] ?? 'distribute';

    if (paramType == 'binary') {
      // Count students with "yes" value
      final yesStudents = students.entries
          .where((entry) => entry.value[paramName] == 'yes')
          .length;

      if (strategy == 'concentrate') {
        // Objective function variables (affected by number of students with "yes")
        binaryParamVars += 5 + (yesStudents > 0 ? 2 : 0);
      } else {
        // 'distribute'
        // Create constraints based on count of "yes" students
        if (yesStudents > 0) {
          // More yes students = more complex constraints
          int distributionComplexity = math.min(yesStudents, classes.length);
          binaryParamVars += classes.length * 2 + distributionComplexity;
        } else {
          // No yes students = simpler constraints
          binaryParamVars += classes.length;
        }
      }
    } else {
      // 'categorical'
      // Count unique values for this parameter
      final uniqueValues = <String>{};
      students.forEach((_, studentData) {
        if (studentData[paramName] != null) {
          uniqueValues.add(studentData[paramName].toString());
        }
      });

      if (strategy == 'concentrate') {
        // Creates boolean variable for each value-class pair
        categoricalParamVars += uniqueValues.length * classes.length;

        // Additional variables for minimization objective
        categoricalParamVars += uniqueValues.length * classes.length;
      } else {
        // 'distribute'
        // Creates constraints for each value-class pair (2 vars per constraint)
        categoricalParamVars += uniqueValues.length * classes.length * 2;
      }
    }
  }

  result['binaryParamVariables'] = binaryParamVars;
  result['categoricalParamVariables'] = categoricalParamVars;
  parameterVars = binaryParamVars + categoricalParamVars;
  result['parameterVariables'] = parameterVars;

  // 3. Preference pair variables
  int prefPairVars = 0;
  int totalPreferences = 0;

  // First count valid preferences
  students.forEach((studentId, studentData) {
    final prefs = studentData['prefs'] as List? ?? [];

    for (final friendId in prefs) {
      // Only count if friend exists in students
      if (students.containsKey(friendId)) {
        totalPreferences++;

        // For each class, we create a pair_in_class variable
        prefPairVars += classes.length;

        // Each constraint adds approximately 2 more variables
        prefPairVars += classes.length * 2;
      }
    }
  });

  result['preferenceVariables'] = prefPairVars;
  result['totalPreferences'] = totalPreferences;

  // 4. Gender constraint variables
  int genderVars = 0;
  if (factorGender) {
    // Count unique genders
    final genders = <String>{};
    students.forEach((_, s) => genders.add(s['sex'] ?? 'unknown'));

    // Each gender constraint adds approximately 2 variables
    genderVars = genders.length * classes.length * 2;
  }
  result['genderVariables'] = genderVars;

  // 5. Class balancing (when no preferences)
  int balancingVars = 0;
  if (totalPreferences == 0) {
    // Class size balancing constraints add 2 variables per class
    balancingVars = classes.length * 2;
  }
  result['balancingVariables'] = balancingVars;

  // Total variables
  final totalVars = assignmentVars +
      parameterVars +
      prefPairVars +
      genderVars +
      balancingVars;
  result['totalVariables'] = totalVars;

  return result;
}

/// Estimates solver runtime in seconds based on problem complexity
/// Provides a comprehensive complexity report for the given problem
Map<String, dynamic> generateComplexityReport({
  required Map<String, dynamic> students,
  required Map<String, int> classes,
  required List<Map<String, dynamic>> parameters,
  required bool factorGender,
}) {
  final varCounts = countVariables(
    students: students,
    classes: classes,
    parameters: parameters,
    factorGender: factorGender,
  );

  // Calculate preference density
  int totalPrefs = varCounts['totalPreferences']!;
  double prefDensity =
      students.isEmpty ? 0 : totalPrefs / (students.length * students.length);

  // Determine complexity rating

  return {
    'variables': varCounts,
    'problemSize': {
      'students': students.length,
      'classes': classes.length,
      'parameters': parameters.length,
      'totalPreferences': totalPrefs,
      'preferenceDensity': prefDensity,
    },
  };
}
