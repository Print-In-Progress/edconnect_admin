import 'package:edconnect_admin/l10n/app_localizations.dart';
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

class AddResponseDialogContent extends ConsumerStatefulWidget {
  final SortingSurvey survey;
  final Function(
    Map<String, dynamic> responses,
  ) onValidate;
  const AddResponseDialogContent({
    required this.survey,
    required this.onValidate,
    super.key,
  });

  static void show(BuildContext context, SortingSurvey survey,
      Function(Map<String, dynamic> response, String respondentId) onSubmit) {
    final contentKey = GlobalKey<_AddResponseDialogContentState>();
    final l10n = AppLocalizations.of(context)!;

    Dialogs.form(
      context: context,
      title: l10n.sortingModuleAddManuallyLabel,
      width: 600,
      variant: DialogVariant.default_,
      form: AddResponseDialogContent(
        key: contentKey,
        survey: survey,
        onValidate: (formData) {
          final response = formData['response'] as Map<String, dynamic>;
          final respondentId = formData['respondentId'] as String;
          onSubmit(response, respondentId);
        },
      ),
      actions: [
        BaseButton(
            label: l10n.globalAddX(l10n.sortingModuleResponses(1)),
            onPressed: () {
              final state = contentKey.currentState;
              if (state != null && state.validate(l10n)) {
                Navigator.of(context).pop();
              }
            })
      ],
    );
  }

  @override
  ConsumerState<AddResponseDialogContent> createState() =>
      _AddResponseDialogContentState();
}

class _AddResponseDialogContentState
    extends ConsumerState<AddResponseDialogContent> {
  bool isManualEntry = true;
  String? selectedUserId;
  final manualFirstNameController = TextEditingController();
  final manualLastNameController = TextEditingController();
  Map<String, dynamic> parameterResponses = {};
  String? selectedSex;
  List<String> selectedPreferences = [];
  late Map<String, TextEditingController> parameterControllers;

  @override
  void initState() {
    super.initState();
    parameterControllers = {
      for (var param in widget.survey.parameters)
        if (param['type'] != 'binary') param['name']: TextEditingController()
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
    final accentColor = theme.accentLight;
    final users = ref.watch(allUsersStreamProvider).value ?? [];
    final responses = ref.watch(filteredResponsesProvider(widget.survey.id));
    final l10n = AppLocalizations.of(context)!;

    return responses.when(
      data: (responseData) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildEntryTypeSelector(isDarkMode, accentColor, l10n),
            SizedBox(height: Foundations.spacing.lg),
            _buildUserSelection(isDarkMode, users, responseData, l10n),
            if (widget.survey.askBiologicalSex) ...[
              SizedBox(height: Foundations.spacing.lg),
              _buildSexSelection(isDarkMode, l10n),
            ],
            if (widget.survey.maxPreferences != null) ...[
              SizedBox(height: Foundations.spacing.lg),
              _buildPreferencesSelection(responseData, l10n),
            ],
            SizedBox(height: Foundations.spacing.lg),
            _buildParametersSection(isDarkMode, l10n),
          ],
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stackTrace) => Center(
        child: Text(l10n.errorUnexpectedWithError(error.toString())),
      ),
    );
  }

  Widget _buildEntryTypeSelector(
      bool isDarkMode, Color accentColor, AppLocalizations l10n) {
    return Wrap(
      spacing: Foundations.spacing.xs,
      children: [
        FilterChip(
          label: Text(l10n.sortingModuleAddManuallyLabel),
          selected: isManualEntry,
          onSelected: (_) => setState(() {
            isManualEntry = true;
            selectedUserId = null;
            manualFirstNameController.clear();
            manualLastNameController.clear();
          }),
          showCheckmark: false,
          backgroundColor: isDarkMode
              ? Foundations.darkColors.backgroundMuted
              : Foundations.colors.backgroundMuted,
          selectedColor: accentColor.withValues(alpha: 0.1),
          labelStyle: TextStyle(
            color: isManualEntry
                ? accentColor
                : isDarkMode
                    ? Foundations.darkColors.textPrimary
                    : Foundations.colors.textPrimary,
            fontWeight: isManualEntry
                ? Foundations.typography.medium
                : Foundations.typography.regular,
          ),
        ),
        FilterChip(
          label: Text(l10n.globalSelectUser),
          selected: !isManualEntry,
          onSelected: (_) => setState(() {
            isManualEntry = false;
            manualFirstNameController.clear();
            manualLastNameController.clear();
          }),
          showCheckmark: false,
          backgroundColor: isDarkMode
              ? Foundations.darkColors.backgroundMuted
              : Foundations.colors.backgroundMuted,
          selectedColor: accentColor.withValues(alpha: 0.1),
          labelStyle: TextStyle(
            color: !isManualEntry
                ? accentColor
                : isDarkMode
                    ? Foundations.darkColors.textPrimary
                    : Foundations.colors.textPrimary,
            fontWeight: !isManualEntry
                ? Foundations.typography.medium
                : Foundations.typography.regular,
          ),
        ),
      ],
    );
  }

  Widget _buildUserSelection(bool isDarkMode, List<AppUser> users,
      Map<String, Map<String, dynamic>> responses, AppLocalizations l10n) {
    if (isManualEntry) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.globalName,
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
                  label: l10n.globalFirstNameTextFieldHintText,
                  controller: manualFirstNameController,
                ),
              ),
              SizedBox(width: Foundations.spacing.md),
              Expanded(
                child: BaseInput(
                  label: l10n.globalLastNameTextFieldHintText,
                  controller: manualLastNameController,
                ),
              ),
            ],
          ),
        ],
      );
    } else {
      return BaseSelect<String>(
        label: l10n.globalSelectUser,
        value: selectedUserId,
        searchable: true,
        options: users
            .where((u) => !responses.containsKey(u.id))
            .map((u) => SelectOption(
                  value: u.id,
                  label: '${u.firstName} ${u.lastName}',
                ))
            .toList(),
        onChanged: (value) {
          setState(() {
            selectedUserId = value;
            if (value != null) {
              final user = users.firstWhere((u) => u.id == value);
              manualFirstNameController.text = user.firstName;
              manualLastNameController.text = user.lastName;
            }
          });
        },
      );
    }
  }

  Widget _buildSexSelection(bool isDarkMode, AppLocalizations l10n) {
    return ToggleChipGroup<String>(
      label: l10n.globalBiologicalSexLabel,
      options: [
        (
          'm',
          l10n.globalMaleLabel,
          ColorGenerator.getColor('sex', 'm', isDarkMode: isDarkMode)
        ),
        (
          'f',
          l10n.globalFemaleLabel,
          ColorGenerator.getColor('sex', 'f', isDarkMode: isDarkMode)
        ),
        (
          'nb',
          l10n.globalNonBinaryLabel,
          ColorGenerator.getColor('sex', 'nb', isDarkMode: isDarkMode)
        ),
      ],
      selectedValue: selectedSex,
      onChanged: (value) => setState(() => selectedSex = value),
    );
  }

  Widget _buildPreferencesSelection(
      Map<String, Map<String, dynamic>> responses, AppLocalizations l10n) {
    return BaseMultiSelect<String>(
      label: l10n.sortingModulePreferences(0),
      hint: l10n.globalSelectX(l10n.sortingModulePreferences(0)),
      description: l10n.sortingModuleSelectUpToXPreferencesLabel(
          widget.survey.maxPreferences!),
      searchable: true,
      values: selectedPreferences,
      options: widget.survey.responses.entries.map((e) {
        if (e.value['_manual_entry'] == true) {
          return SelectOption(
            value: e.key,
            label: '${e.value['_first_name']} ${e.value['_last_name']}',
          );
        } else {
          final allUsers = ref.watch(allUsersStreamProvider).value ?? [];
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
    );
  }

  Widget _buildParametersSection(bool isDarkMode, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.sortingModuleParameters,
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
                  ('yes', l10n.globalYes, ColorGenerator.yesColor),
                  ('no', l10n.globalNo, ColorGenerator.noColor),
                ],
                selectedValue: parameterResponses[name],
                onChanged: (value) =>
                    setState(() => parameterResponses[name] = value ?? ''),
              ),
            );
          }

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

  bool validate(AppLocalizations l10n) {
    if (selectedUserId == null &&
        (manualFirstNameController.text.isEmpty ||
            manualLastNameController.text.isEmpty)) {
      Dialogs.alert(
        context: context,
        title: l10n.validationError,
        message: l10n.validationRequiredSnackbar,
        variant: DialogVariant.danger,
      );
      return false;
    }

    if (widget.survey.askBiologicalSex && selectedSex == null) {
      Dialogs.alert(
        context: context,
        title: l10n.validationError,
        message: l10n.validationRequiredSnackbar,
        variant: DialogVariant.danger,
      );
      return false;
    }

    if (parameterResponses.length != widget.survey.parameters.length) {
      Dialogs.alert(
        context: context,
        title: l10n.validationError,
        message: l10n.validationRequiredSnackbar,
        variant: DialogVariant.danger,
      );
      return false;
    }

    final formattedResponses = Map<String, dynamic>.from(parameterResponses);
    for (var param in widget.survey.parameters) {
      if (param['type'] != 'binary') {
        final value = parameterControllers[param['name']]?.text ?? '';
        formattedResponses[param['name']] =
            ParameterFormatter.formatParameterName(value);
      }
    }

    final response = {
      ...formattedResponses,
      if (widget.survey.askBiologicalSex) 'sex': selectedSex,
      'prefs': selectedPreferences,
    };

    if (selectedUserId == null) {
      response['_manual_entry'] = true;
      response['_first_name'] = manualFirstNameController.text;
      response['_last_name'] = manualLastNameController.text;
    }

    final responseId =
        selectedUserId ?? 'manual_${DateTime.now().millisecondsSinceEpoch}';
    widget.onValidate({
      'response': response,
      'respondentId': responseId,
    });

    return true;
  }
}
