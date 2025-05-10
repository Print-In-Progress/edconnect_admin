import 'package:edconnect_admin/presentation/pages/sorting_module/components/toggle_chip_group.dart';
import 'package:edconnect_admin/presentation/pages/sorting_module/utils/parameter_formatter.dart';
import 'package:edconnect_admin/presentation/widgets/common/dropdown/single_select_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edconnect_admin/core/design_system/color_generator.dart';
import 'package:edconnect_admin/core/design_system/foundations.dart';
import 'package:edconnect_admin/core/models/app_user.dart';
import 'package:edconnect_admin/domain/entities/sorting_survey.dart';
import 'package:edconnect_admin/presentation/providers/state_providers.dart';
import 'package:edconnect_admin/presentation/providers/theme_provider.dart';
import 'package:edconnect_admin/presentation/widgets/common/buttons/base_button.dart';
import 'package:edconnect_admin/presentation/widgets/common/dialogs/dialogs.dart';
import 'package:edconnect_admin/presentation/widgets/common/dropdown/multi_select_dropdown.dart';
import 'package:edconnect_admin/presentation/widgets/common/input/base_input.dart';

class EditResponseDialogContent extends ConsumerStatefulWidget {
  final SortingSurvey survey;
  final String responseId;
  final Map<String, dynamic> response;
  final Function(Map<String, dynamic> formData) onValidate;

  const EditResponseDialogContent({
    required this.survey,
    required this.responseId,
    required this.response,
    required this.onValidate,
    super.key,
  });

  static void show(
    BuildContext context,
    SortingSurvey survey,
    String responseId,
    Map<String, dynamic> response,
    Function(Map<String, dynamic> updatedResponse, String responseId) onSubmit,
  ) {
    final contentKey = GlobalKey<_EditResponseDialogContentState>();

    Dialogs.form(
      context: context,
      title: 'Edit Response',
      width: 600,
      variant: DialogVariant.default_,
      form: EditResponseDialogContent(
        key: contentKey,
        survey: survey,
        responseId: responseId,
        response: response,
        onValidate: (formData) {
          final updatedResponse = formData['response'] as Map<String, dynamic>;
          onSubmit(updatedResponse, responseId);
        },
      ),
      actions: [
        BaseButton(
          label: 'Save Changes',
          variant: ButtonVariant.filled,
          onPressed: () {
            final state = contentKey.currentState;
            if (state != null && state.validate()) {
              Navigator.of(context).pop();
            }
          },
        ),
      ],
    );
  }

  @override
  ConsumerState<EditResponseDialogContent> createState() =>
      _EditResponseDialogContentState();
}

class _EditResponseDialogContentState
    extends ConsumerState<EditResponseDialogContent> {
  late bool isManualEntry;
  String? selectedUserId;
  late final TextEditingController manualFirstNameController;
  late final TextEditingController manualLastNameController;
  late Map<String, dynamic> parameterResponses;
  String? selectedSex;
  late List<String> selectedPreferences;
  late Map<String, TextEditingController> parameterControllers;

  @override
  void initState() {
    super.initState();

    // Initialize state from existing response
    isManualEntry = widget.response['_manual_entry'] == true;
    selectedUserId = isManualEntry ? null : widget.responseId;
    manualFirstNameController = TextEditingController(
      text: widget.response['_first_name'] ?? '',
    );
    manualLastNameController = TextEditingController(
      text: widget.response['_last_name'] ?? '',
    );
    selectedSex = widget.response['sex'];
    selectedPreferences =
        (widget.response['prefs'] as List?)?.cast<String>() ?? [];

    // Initialize parameter responses and controllers
    parameterResponses = {
      for (var param in widget.survey.parameters)
        param['name']: param['type'] == 'binary'
            ? widget.response[param['name']]?.toString() ?? ''
            : widget.response[param['name']]?.toString() ?? '',
    };

    parameterControllers = {
      for (var param in widget.survey.parameters)
        if (param['type'] != 'binary')
          param['name']: TextEditingController(
            text: ParameterFormatter.formatParameterNameForDisplay(
                widget.response[param['name']]?.toString() ?? ''),
          )
    };
  }

  @override
  void dispose() {
    manualFirstNameController.dispose();
    manualLastNameController.dispose();
    for (var controller in parameterControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(appThemeProvider);
    final isDarkMode = theme.isDarkMode;
    final allUsers = ref.watch(allUsersStreamProvider).value ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Name fields for manual entry
        if (isManualEntry) ...[
          Text(
            'Name',
            style: TextStyle(
              fontSize: Foundations.typography.base,
              fontWeight: Foundations.typography.medium,
              color: isDarkMode
                  ? Foundations.darkColors.textPrimary
                  : Foundations.colors.textPrimary,
            ),
          ),
          SizedBox(height: Foundations.spacing.sm),
          Row(
            children: [
              Expanded(
                child: BaseInput(
                  label: 'First Name',
                  controller: manualFirstNameController,
                ),
              ),
              SizedBox(width: Foundations.spacing.md),
              Expanded(
                child: BaseInput(
                  label: 'Last Name',
                  controller: manualLastNameController,
                ),
              ),
            ],
          ),
        ],

        // Sex selection
        if (widget.survey.askBiologicalSex) ...[
          SizedBox(height: Foundations.spacing.lg),
          ToggleChipGroup<String>(
            label: 'Biological Sex',
            options: [
              (
                'm',
                'Male',
                ColorGenerator.getColor('sex', 'm', isDarkMode: isDarkMode)
              ),
              (
                'f',
                'Female',
                ColorGenerator.getColor('sex', 'f', isDarkMode: isDarkMode)
              ),
              (
                'nb',
                'Non-Binary',
                ColorGenerator.getColor('sex', 'nb', isDarkMode: isDarkMode)
              ),
            ],
            selectedValue: selectedSex,
            onChanged: (value) => setState(() => selectedSex = value),
          ),
        ],

        // Preferences selection
        if (widget.survey.maxPreferences != null) ...[
          SizedBox(height: Foundations.spacing.lg),
          BaseMultiSelect<String>(
            label: 'Preferences',
            hint: 'Select preferences',
            description:
                'Select up to ${widget.survey.maxPreferences} preferred users',
            searchable: true,
            values: selectedPreferences,
            options: widget.survey.responses.entries
                .where((e) => e.key != widget.responseId)
                .map((e) {
              if (e.value['_manual_entry'] == true) {
                return SelectOption(
                  value: e.key,
                  label: '${e.value['_first_name']} ${e.value['_last_name']}',
                );
              } else {
                final user = allUsers.firstWhere(
                  (u) => u.id == e.key,
                  orElse: () => AppUser(
                    id: e.key,
                    firstName: 'Unknown',
                    lastName: 'User',
                    email: '',
                    fcmTokens: [],
                    groupIds: [],
                    permissions: [],
                    deviceIds: {},
                    accountType: '',
                  ),
                );
                return SelectOption(
                  value: e.key,
                  label: '${user.firstName} ${user.lastName}',
                );
              }
            }).toList(),
            onChanged: (values) {
              if (values.length <= widget.survey.maxPreferences!) {
                setState(() => selectedPreferences = values);
              }
            },
            maxChipsVisible: 2,
          ),
        ],

        // Parameters
        SizedBox(height: Foundations.spacing.lg),
        Text(
          'Parameters',
          style: TextStyle(
            fontSize: Foundations.typography.base,
            fontWeight: Foundations.typography.medium,
            color: isDarkMode
                ? Foundations.darkColors.textPrimary
                : Foundations.colors.textPrimary,
          ),
        ),
        SizedBox(height: Foundations.spacing.md),
        ...widget.survey.parameters.map((param) {
          final name = param['name'] as String;
          final type = param['type'] as String;

          if (type == 'binary') {
            return Padding(
              padding: EdgeInsets.only(bottom: Foundations.spacing.md),
              child: ToggleChipGroup<String>(
                label: ParameterFormatter.formatParameterNameForDisplay(name),
                options: [
                  ('yes', 'Yes', ColorGenerator.yesColor),
                  ('no', 'No', ColorGenerator.noColor),
                ],
                selectedValue: parameterResponses[name],
                onChanged: (value) =>
                    setState(() => parameterResponses[name] = value ?? ''),
              ),
            );
          }

          // Regular input for categorical parameters
          return Padding(
            padding: EdgeInsets.only(bottom: Foundations.spacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ParameterFormatter.formatParameterNameForDisplay(name),
                  style: TextStyle(
                    fontSize: Foundations.typography.sm,
                    color: isDarkMode
                        ? Foundations.darkColors.textMuted
                        : Foundations.colors.textMuted,
                  ),
                ),
                SizedBox(height: Foundations.spacing.xs),
                BaseInput(
                  hint: 'Enter answer',
                  controller: parameterControllers[name],
                  onChanged: (value) {
                    setState(() => parameterResponses[name] = value);
                  },
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  bool validate() {
    // Validate form
    if (isManualEntry &&
        (manualFirstNameController.text.isEmpty ||
            manualLastNameController.text.isEmpty)) {
      Dialogs.alert(
        context: context,
        title: 'Validation Error',
        message: 'Please enter first and last name',
        variant: DialogVariant.danger,
      );
      return false;
    }

    if (widget.survey.askBiologicalSex && selectedSex == null) {
      Dialogs.alert(
        context: context,
        title: 'Validation Error',
        message: 'Please select biological sex',
        variant: DialogVariant.danger,
      );
      return false;
    }

    if (parameterResponses.length != widget.survey.parameters.length) {
      Dialogs.alert(
        context: context,
        title: 'Validation Error',
        message: 'Please answer all parameters',
        variant: DialogVariant.danger,
      );
      return false;
    }

    // Format categorical values
    final formattedResponses = Map<String, dynamic>.from(parameterResponses);
    for (var param in widget.survey.parameters) {
      if (param['type'] != 'binary') {
        final value = parameterControllers[param['name']]?.text ?? '';
        formattedResponses[param['name']] =
            ParameterFormatter.formatParameterName(value);
      }
    }

    // Create updated response data
    final updatedResponse = {
      ...widget.response, // Keep existing data
      ...formattedResponses, // Update with new parameters
      if (widget.survey.askBiologicalSex) 'sex': selectedSex,
      'prefs': selectedPreferences,
    };

    // Update manual entry fields if applicable
    if (isManualEntry) {
      updatedResponse['_first_name'] = manualFirstNameController.text;
      updatedResponse['_last_name'] = manualLastNameController.text;
    }

    // Call the validation callback
    widget.onValidate({
      'response': updatedResponse,
    });

    return true;
  }
}
