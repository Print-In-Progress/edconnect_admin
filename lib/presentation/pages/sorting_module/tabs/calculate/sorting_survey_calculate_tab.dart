import 'package:edconnect_admin/core/design_system/foundations.dart';
import 'package:edconnect_admin/core/errors/error_handler.dart';
import 'package:edconnect_admin/core/errors/error_messages.dart';
import 'package:edconnect_admin/domain/entities/sorting_survey.dart';
import 'package:edconnect_admin/presentation/pages/sorting_module/tabs/calculate/components/calculation_section.dart';
import 'package:edconnect_admin/presentation/pages/sorting_module/tabs/calculate/components/class_configuration_section.dart';
import 'package:edconnect_admin/presentation/pages/sorting_module/tabs/calculate/components/parameters_section.dart';
import 'package:edconnect_admin/presentation/pages/sorting_module/tabs/calculate/utils/class_config.dart';
import 'package:edconnect_admin/presentation/pages/sorting_module/tabs/calculate/utils/complexity_calculator.dart';
import 'package:edconnect_admin/presentation/providers/state_providers.dart';
import 'package:edconnect_admin/presentation/widgets/common/input/number_input.dart';
import 'package:edconnect_admin/presentation/widgets/common/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

    numberOfClassesController = NumberInputController(initialValue: 1);

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
      classConfig.dispose();
    }
    newClassNameController.dispose();
    super.dispose();
  }

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

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(Foundations.spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClassConfigurationSection(
              survey: widget.survey,
              classes: classes,
              distributeBySex: distributeBySex,
              onDistributeBySexChanged: (value) {
                setState(() => distributeBySex = value);
              },
              onRemoveClass: removeClass,
              onAddClass: addClass,
              newClassNameController: newClassNameController,
            ),
            SizedBox(height: Foundations.spacing.xl),
            ParametersSection(
              allParameters: allParameters,
              selectedParameters: selectedParameters,
              priorityControllers: priorityControllers,
              onParameterSelectionChanged: (param, isSelected) {
                setState(() {
                  if (isSelected) {
                    selectedParameters.add(param);
                  } else {
                    selectedParameters.remove(param);
                  }
                });
              },
              onParameterValueChanged: (param, key, value) {
                if (value != null) {
                  setState(() => param[key] = value);
                }
              },
            ),
            SizedBox(height: Foundations.spacing.xl),
            CalculationSection(
              survey: widget.survey,
              complexityReport: complexityReport,
              timeLimit: timeLimit,
              isCalculating: ref.watch(calculationStateProvider).isCalculating,
              onTimeLimitChanged: (value) {
                setState(() => timeLimit = value);
              },
              onCalculate: _calculateClasses,
            ),
          ],
        ),
      ),
    );
  }

  void _calculateClasses() async {
    final Map<String, int> formattedClasses = {
      for (var clazz in classes)
        clazz.nameController.text: clazz.sizeController.value?.toInt() ?? 0
    };

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
}
