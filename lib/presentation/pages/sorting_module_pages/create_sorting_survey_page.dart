import 'package:edconnect_admin/core/design_system/foundations.dart';
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
    super.dispose();
  }

  final List<Map<String, dynamic>> _parameters = [];
  List<String> _selectedEditorGroups = [];
  List<String> _selectedRespondentGroups = [];

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
            BaseMultiSelect<String>(
              label: 'Editor Groups',
              searchable: true,
              values: _selectedEditorGroups,
              options: groups
                  .map((group) => SelectOption(
                        value: group.id,
                        label: group.name,
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
              label: 'Respondent Groups',
              values: _selectedRespondentGroups,
              searchable: true,
              options: groups
                  .map((group) => SelectOption(
                        value: group.id,
                        label: group.name,
                      ))
                  .toList(),
              onChanged: (values) {
                setState(() {
                  _selectedRespondentGroups = values;
                });
              },
            ),

            //TODO: Addd Editor User and Respondent User dropdowns
          ],
        ),
      ),
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
      final survey = SortingSurvey(
        id: '',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        createdAt: DateTime.now(),
        status: SortingSurveyStatus.draft,
        creatorId: '',
        creatorName: '',
        respondentsGroups: [],
        editorUsers: [],
        editorGroups: [],
        parameters: [],
        responses: [],
        askBiologicalSex: _askBiologicalSex,
      );

      ref
          .read(sortingSurveyNotifierProvider.notifier)
          .createSortingSurvey(survey);
    }
  }
}
