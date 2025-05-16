import 'package:edconnect_admin/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edconnect_admin/core/design_system/foundations.dart';
import 'package:edconnect_admin/domain/entities/sorting_survey.dart';
import 'package:edconnect_admin/presentation/pages/sorting_module/pages/create/components/basic_info_card.dart';
import 'package:edconnect_admin/presentation/pages/sorting_module/pages/create/components/access_control_card.dart';
import 'package:edconnect_admin/presentation/pages/sorting_module/pages/create/components/parameters_card.dart';
import 'package:edconnect_admin/presentation/pages/sorting_module/utils/parameter_formatter.dart';
import 'package:edconnect_admin/presentation/providers/action_providers.dart';
import 'package:edconnect_admin/presentation/providers/theme_provider.dart';
import 'package:edconnect_admin/presentation/widgets/common/buttons/base_button.dart';
import 'package:edconnect_admin/presentation/widgets/common/input/number_input.dart';
import 'package:edconnect_admin/presentation/widgets/common/navigation/app_bar.dart';
import 'package:edconnect_admin/presentation/widgets/common/toast.dart';

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
  bool _allowPreferences = true;
  final _maxPreferencesController = NumberInputController(initialValue: 3);

  final List<Map<String, dynamic>> _parameters = [];
  List<String> _selectedEditorGroups = [];
  List<String> _selectedRespondentGroups = [];
  List<String> _selectedEditorUsers = [];
  List<String> _selectedRespondentUsers = [];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();

    for (final param in _parameters) {
      (param['name'] as TextEditingController).dispose();
      (param['priority'] as NumberInputController).dispose();
    }

    _maxPreferencesController.dispose();
    super.dispose();
  }

  void _addParameter() {
    final priorityController = NumberInputController(initialValue: 5);
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

  void _saveSurvey() {
    if (_formKey.currentState!.validate()) {
      final transformedParameters = _parameters.map((param) {
        return {
          'name': ParameterFormatter.formatParameterName(
              (param['name'] as TextEditingController).text.trim()),
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
        responses: {},
        maxPreferences:
            _allowPreferences ? _maxPreferencesController.value!.toInt() : null,
        askBiologicalSex: _askBiologicalSex,
      );

      ref
          .read(sortingSurveyNotifierProvider.notifier)
          .createSortingSurvey(survey);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(appThemeProvider);
    final notifierState = ref.watch(sortingSurveyNotifierProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 1200;
    final l10n = AppLocalizations.of(context)!;

    ref.listen<AsyncValue<void>>(sortingSurveyNotifierProvider, (_, state) {
      state.whenOrNull(
        error: (error, _) {
          Toaster.error(context, l10n.errorCreateFailed(l10n.sortingSurvey(1)),
              description: error.toString());
        },
        data: (_) {
          Navigator.pop(context);
          Toaster.success(
              context, l10n.successCreatedWithPrefix(l10n.sortingSurvey(1)));
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
            title: l10n.globalCreateButtonLabel(l10n.sortingSurvey(1)),
            showLeading: true,
            actions: [
              BaseButton(
                label: l10n.globalSave,
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
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Column(
                                children: [
                                  BasicInfoCard(
                                    titleController: _titleController,
                                    descriptionController:
                                        _descriptionController,
                                  ),
                                  SizedBox(height: Foundations.spacing.lg),
                                  AccessControlCard(
                                    selectedEditorGroups: _selectedEditorGroups,
                                    selectedRespondentGroups:
                                        _selectedRespondentGroups,
                                    selectedEditorUsers: _selectedEditorUsers,
                                    selectedRespondentUsers:
                                        _selectedRespondentUsers,
                                    onEditorGroupsChanged: (values) => setState(
                                        () => _selectedEditorGroups = values),
                                    onRespondentGroupsChanged: (values) =>
                                        setState(() =>
                                            _selectedRespondentGroups = values),
                                    onEditorUsersChanged: (values) => setState(
                                        () => _selectedEditorUsers = values),
                                    onRespondentUsersChanged: (values) =>
                                        setState(() =>
                                            _selectedRespondentUsers = values),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: Foundations.spacing.lg),
                            Expanded(
                              flex: 2,
                              child: ParametersCard(
                                parameters: _parameters,
                                askBiologicalSex: _askBiologicalSex,
                                allowPreferences: _allowPreferences,
                                maxPreferencesController:
                                    _maxPreferencesController,
                                onAddParameter: _addParameter,
                                onRemoveParameter: _removeParameter,
                                onUpdateParameter: _updateParameter,
                                onAskBiologicalSexChanged: (value) =>
                                    setState(() => _askBiologicalSex = value),
                                onAllowPreferencesChanged: (value) =>
                                    setState(() => _allowPreferences = value),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Column(
                        children: [
                          BasicInfoCard(
                            titleController: _titleController,
                            descriptionController: _descriptionController,
                          ),
                          SizedBox(height: Foundations.spacing.lg),
                          AccessControlCard(
                            selectedEditorGroups: _selectedEditorGroups,
                            selectedRespondentGroups: _selectedRespondentGroups,
                            selectedEditorUsers: _selectedEditorUsers,
                            selectedRespondentUsers: _selectedRespondentUsers,
                            onEditorGroupsChanged: (values) =>
                                setState(() => _selectedEditorGroups = values),
                            onRespondentGroupsChanged: (values) => setState(
                                () => _selectedRespondentGroups = values),
                            onEditorUsersChanged: (values) =>
                                setState(() => _selectedEditorUsers = values),
                            onRespondentUsersChanged: (values) => setState(
                                () => _selectedRespondentUsers = values),
                          ),
                          SizedBox(height: Foundations.spacing.lg),
                          ParametersCard(
                            parameters: _parameters,
                            askBiologicalSex: _askBiologicalSex,
                            allowPreferences: _allowPreferences,
                            maxPreferencesController: _maxPreferencesController,
                            onAddParameter: _addParameter,
                            onRemoveParameter: _removeParameter,
                            onUpdateParameter: _updateParameter,
                            onAskBiologicalSexChanged: (value) =>
                                setState(() => _askBiologicalSex = value),
                            onAllowPreferencesChanged: (value) =>
                                setState(() => _allowPreferences = value),
                          ),
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
}
