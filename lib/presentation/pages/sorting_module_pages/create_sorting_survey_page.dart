import 'package:edconnect_admin/core/design_system/foundations.dart';
import 'package:edconnect_admin/core/models/app_user.dart';
import 'package:edconnect_admin/domain/entities/group.dart';
import 'package:edconnect_admin/domain/entities/sorting_survey.dart';
import 'package:edconnect_admin/presentation/providers/action_providers.dart';
import 'package:edconnect_admin/presentation/providers/state_providers.dart';
import 'package:edconnect_admin/presentation/providers/theme_provider.dart';
import 'package:edconnect_admin/presentation/widgets/common/buttons/base_button.dart';
import 'package:edconnect_admin/presentation/widgets/common/cards/base_card.dart';
import 'package:edconnect_admin/presentation/widgets/common/checkbox.dart';
import 'package:edconnect_admin/presentation/widgets/common/dropdown/multi_select_dropdown.dart';
import 'package:edconnect_admin/presentation/widgets/common/dropdown/single_select_dropdown.dart';
import 'package:edconnect_admin/presentation/widgets/common/input/base_input.dart';
import 'package:edconnect_admin/presentation/widgets/common/input/number_input.dart';
import 'package:edconnect_admin/presentation/widgets/common/navigation/app_bar.dart';
import 'package:edconnect_admin/presentation/widgets/common/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SortingSurveyCreatePage extends ConsumerStatefulWidget {
  const SortingSurveyCreatePage({super.key});

  @override
  ConsumerState<SortingSurveyCreatePage> createState() =>
      _SortingSurveyCreatePageState();
}

class _SortingSurveyCreatePageState
    extends ConsumerState<SortingSurveyCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _askBiologicalSex = true;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();

    for (final param in _parameters) {
      (param['name'] as TextEditingController).dispose();
      (param['priority'] as NumberInputController).dispose();
    }
    super.dispose();
  }

  final List<Map<String, dynamic>> _parameters = [];
  List<String> _selectedEditorGroups = [];
  List<String> _selectedRespondentGroups = [];
  List<String> _selectedEditorUsers = [];
  List<String> _selectedRespondentUsers = [];

  void _addParameter() {
    final priorityController = NumberInputController(initialValue: 1);
    setState(() {
      _parameters.add({
        'name': TextEditingController(),
        'type': 'binary',
        'strategy': 'distribute',
        'priority': priorityController,
      });
    });
  }

  void _updateParameter(
      Map<String, dynamic> parameter, String key, dynamic value) {
    setState(() {
      parameter[key] = value;
    });
  }

  void _removeParameter(Map<String, dynamic> parameter) {
    setState(() {
      _parameters.remove(parameter);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(appThemeProvider);
    final notifierState = ref.watch(sortingSurveyNotifierProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 1200;

    ref.listen<AsyncValue<void>>(sortingSurveyNotifierProvider, (_, state) {
      state.whenOrNull(
        error: (error, _) {
          Toaster.error(context, 'Failed to create survey',
              description: error.toString());
        },
        data: (_) {
          Navigator.pop(context);
          Toaster.success(context, 'Survey created successfully');
        },
      );
    });

    return Scaffold(
      backgroundColor: theme.isDarkMode
          ? Foundations.darkColors.background
          : Foundations.colors.background,
      body: Column(
        children: [
          BaseAppBar(
            title: 'Create Sorting Survey',
            showLeading: true,
            actions: [
              BaseButton(
                label: 'Save',
                prefixIcon: Icons.save_outlined,
                variant: ButtonVariant.filled,
                isLoading: notifierState.isLoading,
                onPressed: _saveSurvey,
              ),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(Foundations.spacing.lg),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isWideScreen)
                      // Wide screen layout - cards side by side
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Column(
                                children: [
                                  _buildBasicInfoCard(),
                                  SizedBox(height: Foundations.spacing.lg),
                                  _buildAccessControlCard(),
                                ],
                              ),
                            ),
                            SizedBox(width: Foundations.spacing.lg),
                            Expanded(
                              flex: 2,
                              child: _buildParametersCard(),
                            ),
                          ],
                        ),
                      )
                    else
                      // Mobile/narrow layout - cards stacked
                      Column(
                        children: [
                          _buildBasicInfoCard(),
                          SizedBox(height: Foundations.spacing.lg),
                          _buildAccessControlCard(),
                          SizedBox(height: Foundations.spacing.lg),
                          _buildParametersCard(),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoCard() {
    final theme = ref.watch(appThemeProvider);

    return BaseCard(
      variant: CardVariant.elevated,
      child: Padding(
        padding: EdgeInsets.all(Foundations.spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Basic Information',
              style: TextStyle(
                fontSize: Foundations.typography.lg,
                fontWeight: Foundations.typography.semibold,
                color: theme.isDarkMode
                    ? Foundations.darkColors.textPrimary
                    : Foundations.colors.textPrimary,
              ),
            ),
            SizedBox(height: Foundations.spacing.lg),
            BaseInput(
              controller: _titleController,
              label: 'Title',
              hint: 'Enter survey title',
              isRequired: true,
            ),
            SizedBox(height: Foundations.spacing.md),
            BaseInput(
              controller: _descriptionController,
              label: 'Description',
              hint: 'Enter survey description',
              maxLines: 3,
            ),
            SizedBox(height: Foundations.spacing.md),
          ],
        ),
      ),
    );
  }

  Widget _buildAccessControlCard() {
    final theme = ref.watch(appThemeProvider);
    final groups = ref.watch(allGroupsStreamProvider).value ?? [];
    final users = ref.watch(allUsersStreamProvider).value ?? [];
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 800;

    return BaseCard(
      variant: CardVariant.elevated,
      child: Padding(
        padding: EdgeInsets.all(Foundations.spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Access Control',
              style: TextStyle(
                fontSize: Foundations.typography.lg,
                fontWeight: Foundations.typography.semibold,
                color: theme.isDarkMode
                    ? Foundations.darkColors.textPrimary
                    : Foundations.colors.textPrimary,
              ),
            ),
            SizedBox(height: Foundations.spacing.lg),
            if (isWideScreen)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildEditorsSection(groups, users),
                  ),
                  SizedBox(width: Foundations.spacing.lg),
                  Expanded(
                    child: _buildRespondentsSection(groups, users),
                  ),
                ],
              )
            else
              Column(
                children: [
                  _buildEditorsSection(groups, users),
                  SizedBox(height: Foundations.spacing.lg),
                  _buildRespondentsSection(groups, users),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditorsSection(List<Group> groups, List<AppUser> users) {
    final theme = ref.watch(appThemeProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Editors',
          style: TextStyle(
            fontSize: Foundations.typography.base,
            fontWeight: Foundations.typography.semibold,
            color: theme.isDarkMode
                ? Foundations.darkColors.textSecondary
                : Foundations.colors.textSecondary,
          ),
        ),
        Text(
          'Users and groups that can edit this survey',
          style: TextStyle(
            fontSize: Foundations.typography.sm,
            color: theme.isDarkMode
                ? Foundations.darkColors.textMuted
                : Foundations.colors.textMuted,
          ),
        ),
        SizedBox(height: Foundations.spacing.md),
        BaseMultiSelect<String>(
          label: 'Editor Groups',
          searchable: true,
          values: _selectedEditorGroups,
          options: groups
              .map((group) => SelectOption(
                    value: group.id,
                    label: group.name,
                    icon: Icons.group_outlined,
                  ))
              .toList(),
          onChanged: (values) {
            setState(() {
              _selectedEditorGroups = values;
            });
          },
        ),
        SizedBox(height: Foundations.spacing.md),
        BaseMultiSelect<String>(
          label: 'Editor Users',
          values: _selectedEditorUsers,
          searchable: true,
          options: users
              .map((user) => SelectOption(
                    value: user.id,
                    label: user.fullName,
                    icon: Icons.person_outline,
                  ))
              .toList(),
          onChanged: (values) {
            setState(() {
              _selectedEditorUsers = values;
            });
          },
        ),
      ],
    );
  }

  Widget _buildRespondentsSection(List<Group> groups, List<AppUser> users) {
    final theme = ref.watch(appThemeProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Respondents',
          style: TextStyle(
            fontSize: Foundations.typography.base,
            fontWeight: Foundations.typography.semibold,
            color: theme.isDarkMode
                ? Foundations.darkColors.textSecondary
                : Foundations.colors.textSecondary,
          ),
        ),
        Text(
          'Users and groups that can respond to this survey',
          style: TextStyle(
            fontSize: Foundations.typography.sm,
            color: theme.isDarkMode
                ? Foundations.darkColors.textMuted
                : Foundations.colors.textMuted,
          ),
        ),
        SizedBox(height: Foundations.spacing.md),
        BaseMultiSelect<String>(
          label: 'Respondent Groups',
          searchable: true,
          values: _selectedRespondentGroups,
          options: groups
              .map((group) => SelectOption(
                    value: group.id,
                    label: group.name,
                    icon: Icons.group_outlined,
                  ))
              .toList(),
          onChanged: (values) {
            setState(() {
              _selectedRespondentGroups = values;
            });
          },
        ),
        SizedBox(height: Foundations.spacing.md),
        BaseMultiSelect<String>(
          label: 'Respondent Users',
          values: _selectedRespondentUsers,
          searchable: true,
          options: users
              .map((user) => SelectOption(
                    value: user.id,
                    label: user.fullName,
                    icon: Icons.person_outline,
                  ))
              .toList(),
          onChanged: (values) {
            setState(() {
              _selectedRespondentUsers = values;
            });
          },
        ),
      ],
    );
  }

  Widget _buildParametersCard() {
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
                  onPressed: _addParameter,
                ),
              ],
            ),
            SizedBox(height: Foundations.spacing.lg),
            BaseCheckbox(
                value: _askBiologicalSex,
                label: 'Ask respondents their biological sex',
                size: CheckboxSize.medium,
                onChanged: (value) {
                  setState(() {
                    _askBiologicalSex = value ?? false;
                  });
                }),
            SizedBox(height: Foundations.spacing.lg),
            ..._parameters.map((param) => _buildParameterItem(param)),
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
                        _updateParameter(parameter, 'type', value),
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
                        _updateParameter(parameter, 'strategy', value),
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
                onPressed: () => _removeParameter(parameter),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveSurvey() {
    if (_formKey.currentState!.validate()) {
      // TODO: Replace underscores with underscore in the title
      final transformedParameters = _parameters.map((param) {
        return {
          'name': (param['name'] as TextEditingController).text.trim(),
          'type': param['type'],
          'strategy': param['strategy'],
          'priority': (param['priority'] as NumberInputController).value,
        };
      }).toList();

      final survey = SortingSurvey(
        id: '',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        createdAt: DateTime.now(),
        status: SortingSurveyStatus.draft,
        creatorId: '',
        creatorName: '',
        respondentsUsers: _selectedRespondentUsers,
        respondentsGroups: _selectedRespondentGroups,
        editorUsers: _selectedEditorUsers,
        editorGroups: _selectedEditorGroups,
        parameters: transformedParameters,
        responses: [],
        askBiologicalSex: _askBiologicalSex,
      );

      ref
          .read(sortingSurveyNotifierProvider.notifier)
          .createSortingSurvey(survey);
    }
  }
}
