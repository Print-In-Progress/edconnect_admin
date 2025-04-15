import 'package:edconnect_admin/core/design_system/foundations.dart';
import 'package:edconnect_admin/core/models/app_user.dart';
import 'package:edconnect_admin/domain/entities/group.dart';
import 'package:edconnect_admin/domain/entities/sorting_survey.dart';
import 'package:edconnect_admin/l10n/app_localizations.dart';
import 'package:edconnect_admin/presentation/providers/action_providers.dart';
import 'package:edconnect_admin/presentation/providers/state_providers.dart';
import 'package:edconnect_admin/presentation/providers/theme_provider.dart';
import 'package:edconnect_admin/presentation/widgets/common/buttons/base_button.dart';
import 'package:edconnect_admin/presentation/widgets/common/cards/base_card.dart';
import 'package:edconnect_admin/presentation/widgets/common/chips.dart';
import 'package:edconnect_admin/presentation/widgets/common/dialogs/dialogs.dart';
import 'package:edconnect_admin/presentation/widgets/common/dropdown/multi_select_dropdown.dart';
import 'package:edconnect_admin/presentation/widgets/common/dropdown/single_select_dropdown.dart';
import 'package:edconnect_admin/presentation/widgets/common/navigation/app_bar.dart';
import 'package:edconnect_admin/presentation/widgets/common/navigation/tabs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

// TODO: Display Toasts after action is completed

class SortingSurveyDetailsPage extends ConsumerWidget {
  final SortingSurvey survey;
  const SortingSurveyDetailsPage({super.key, required this.survey});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeProvider);
    final notifierState = ref.watch(sortingSurveyNotifierProvider);

    return Scaffold(
        backgroundColor: theme.isDarkMode
            ? Foundations.darkColors.background
            : Foundations.colors.background,
        appBar: BaseAppBar(
          title: survey.title,
          showLeading: true,
          actions: [
            if (survey.status == SortingSurveyStatus.draft) ...[
              BaseButton(
                label: 'Publish',
                prefixIcon: Icons.publish_outlined,
                variant: ButtonVariant.filled,
                isLoading: notifierState.isLoading,
                onPressed: () => _publishSurvey(context, ref, survey.id),
              ),
              SizedBox(width: Foundations.spacing.md),
            ],
            if (survey.status == SortingSurveyStatus.published) ...[
              BaseButton(
                label: 'Close',
                prefixIcon: Icons.close,
                variant: ButtonVariant.outlined,
                isLoading: notifierState.isLoading,
                onPressed: () => _closeSurvey(context, ref, survey.id),
              ),
              SizedBox(width: Foundations.spacing.md),
            ],
            BaseButton(
              label: 'Delete',
              prefixIcon: Icons.delete_outline,
              backgroundColor: Foundations.colors.error,
              variant: ButtonVariant.filled,
              isLoading: notifierState.isLoading,
              onPressed: () => _deleteSurvey(context, ref, survey.id),
            ),
          ],
        ),
        body: _buildContent(context, ref, survey));
  }

  Widget _buildContent(
      BuildContext context, WidgetRef ref, SortingSurvey survey) {
    return Padding(
      padding: EdgeInsets.all(Foundations.spacing.lg),
      child: Tabs(tabs: [
        TabItem(
          label: 'Overview',
          icon: Icons.info_outline,
          content: _OverviewTab(survey: survey),
        ),
        TabItem(
          label: 'Responses',
          icon: Icons.list_alt_outlined,
          content: _ResponsesTab(survey: survey),
        ),
        TabItem(
          label: 'Calculate',
          icon: Icons.calculate_outlined,
          content: _CalculateTab(survey: survey),
        ),
        TabItem(
          label: 'Results',
          icon: Icons.pie_chart_outline,
          content: _ResultsTab(survey: survey),
        ),
      ]),
    );
  }

  Future<void> _publishSurvey(
      BuildContext context, WidgetRef ref, String id) async {
    await ref
        .read(sortingSurveyNotifierProvider.notifier)
        .publishSortingSurvey(id);
  }

  Future<void> _closeSurvey(
      BuildContext context, WidgetRef ref, String id) async {
    await ref
        .read(sortingSurveyNotifierProvider.notifier)
        .closeSortingSurvey(id);
  }

  Future<void> _deleteSurvey(
      BuildContext context, WidgetRef ref, String id) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Survey'),
        content: const Text('Are you sure you want to delete this survey?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref
          .read(sortingSurveyNotifierProvider.notifier)
          .deleteSortingSurvey(id);
      Navigator.pop(context);
    }
  }
}

class _OverviewTab extends ConsumerWidget {
  final SortingSurvey survey;

  const _OverviewTab({required this.survey});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeProvider);
    final notifierState = ref.watch(sortingSurveyNotifierProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 1100;

    return SingleChildScrollView(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(context, 'Basic Information', Icons.info_outline,
              theme.isDarkMode),
          SizedBox(height: Foundations.spacing.md),
          if (isWideScreen)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: _buildInfoCard(
                    context,
                    theme.isDarkMode,
                    children: [
                      _buildInfoRow(
                          context, 'Title', survey.title, theme.isDarkMode),
                      if (survey.description.isNotEmpty)
                        _buildInfoRow(context, 'Description',
                            survey.description, theme.isDarkMode),
                      _buildInfoRow(
                        context,
                        'Status',
                        _getStatusText(survey.status),
                        theme.isDarkMode,
                        chip: _buildStatusChip(survey.status),
                      ),
                      _buildInfoRow(
                        context,
                        'Created',
                        _formatDate(survey.createdAt),
                        theme.isDarkMode,
                      ),
                      _buildInfoRow(context, 'Created By', survey.creatorName,
                          theme.isDarkMode),
                      _buildInfoRow(
                        context,
                        'Ask Biological Sex',
                        survey.askBiologicalSex ? 'Yes' : 'No',
                        theme.isDarkMode,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: Foundations.spacing.lg),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader(context, 'Statistics',
                          Icons.bar_chart, theme.isDarkMode),
                      SizedBox(height: Foundations.spacing.md),
                      _buildInfoCard(
                        context,
                        theme.isDarkMode,
                        children: [
                          _buildInfoRow(
                            context,
                            'Parameters',
                            '${survey.parameters.length}',
                            theme.isDarkMode,
                            onTap: () => _showParametersDialog(
                                context, survey.parameters),
                          ),
                          _buildInfoRow(
                            context,
                            'Responses',
                            '${survey.responses.length}',
                            theme.isDarkMode,
                          ),
                        ],
                      ),
                      SizedBox(height: Foundations.spacing.lg),
                      _buildSectionHeader(
                        context,
                        'Access Control',
                        Icons.people_outline,
                        theme.isDarkMode,
                        actionButton: survey.status == SortingSurveyStatus.draft
                            ? BaseButton(
                                label: 'Edit Access',
                                prefixIcon: Icons.edit,
                                variant: ButtonVariant.outlined,
                                size: ButtonSize.small,
                                isLoading: notifierState.isLoading,
                                onPressed: () =>
                                    _showEditAccessDialog(context, ref, survey),
                              )
                            : null,
                      ),
                      SizedBox(height: Foundations.spacing.md),
                      _buildInfoCard(
                        context,
                        theme.isDarkMode,
                        children: [
                          _buildMultiValueRow(
                            context,
                            'Editor Groups',
                            survey.editorGroups.isEmpty
                                ? ['No editor groups']
                                : survey.editorGroups,
                            theme.isDarkMode,
                            ref,
                            isUserIds: false,
                            icon: Icons.group_outlined,
                          ),
                          _buildMultiValueRow(
                            context,
                            'Editor Users',
                            survey.editorUsers.isEmpty
                                ? ['No editor users']
                                : survey.editorUsers,
                            theme.isDarkMode,
                            ref,
                            isUserIds: true,
                            icon: Icons.person_outlined,
                          ),
                          _buildMultiValueRow(
                            context,
                            'Respondent Groups',
                            survey.respondentsGroups.isEmpty
                                ? ['No respondent groups']
                                : survey.respondentsGroups,
                            theme.isDarkMode,
                            ref,
                            isUserIds: false,
                            icon: Icons.groups_outlined,
                          ),
                          _buildMultiValueRow(
                            context,
                            'Respondent Users',
                            survey.respondentsUsers.isEmpty
                                ? ['No respondent users']
                                : survey.respondentsUsers,
                            theme.isDarkMode,
                            ref,
                            isUserIds: true,
                            icon: Icons.person_outlined,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          if (!isWideScreen)
            Column(children: [
              _buildInfoCard(
                context,
                theme.isDarkMode,
                children: [
                  _buildInfoRow(
                      context, 'Title', survey.title, theme.isDarkMode),
                  if (survey.description.isNotEmpty)
                    _buildInfoRow(context, 'Description', survey.description,
                        theme.isDarkMode),
                  _buildInfoRow(
                    context,
                    'Status',
                    _getStatusText(survey.status),
                    theme.isDarkMode,
                    chip: _buildStatusChip(survey.status),
                  ),
                  _buildInfoRow(
                    context,
                    'Created',
                    _formatDate(survey.createdAt),
                    theme.isDarkMode,
                  ),
                  _buildInfoRow(context, 'Created By', survey.creatorName,
                      theme.isDarkMode),
                  _buildInfoRow(
                    context,
                    'Ask Biological Sex',
                    survey.askBiologicalSex ? 'Yes' : 'No',
                    theme.isDarkMode,
                  ),
                ],
              ),

              SizedBox(height: Foundations.spacing.xl),

              // Statistics Section
              _buildSectionHeader(
                  context, 'Statistics', Icons.bar_chart, theme.isDarkMode),
              SizedBox(height: Foundations.spacing.md),
              _buildInfoCard(
                context,
                theme.isDarkMode,
                children: [
                  _buildInfoRow(
                    context,
                    'Parameters',
                    '${survey.parameters.length}',
                    theme.isDarkMode,
                    onTap: () =>
                        _showParametersDialog(context, survey.parameters),
                  ),
                  _buildInfoRow(
                    context,
                    'Responses',
                    '${survey.responses.length}',
                    theme.isDarkMode,
                  ),
                ],
              ),

              SizedBox(height: Foundations.spacing.xl),

              // Access Control Section - Editable
              _buildSectionHeader(
                context,
                'Access Control',
                Icons.people_outline,
                theme.isDarkMode,
                actionButton: survey.status == SortingSurveyStatus.draft
                    ? BaseButton(
                        label: 'Edit Access',
                        prefixIcon: Icons.edit,
                        variant: ButtonVariant.outlined,
                        size: ButtonSize.small,
                        isLoading: notifierState.isLoading,
                        onPressed: () =>
                            _showEditAccessDialog(context, ref, survey),
                      )
                    : null,
              ),
              SizedBox(height: Foundations.spacing.md),
              _buildInfoCard(
                context,
                theme.isDarkMode,
                children: [
                  _buildMultiValueRow(
                    context,
                    'Editor Groups',
                    survey.editorGroups.isEmpty
                        ? ['No editor groups']
                        : survey.editorGroups,
                    theme.isDarkMode,
                    ref,
                    isUserIds: false,
                    icon: Icons.group_outlined,
                  ),
                  _buildMultiValueRow(
                    context,
                    'Editor Users',
                    survey.editorUsers.isEmpty
                        ? ['No editor users']
                        : survey.editorUsers,
                    theme.isDarkMode,
                    ref,
                    isUserIds: true,
                    icon: Icons.person_outlined,
                  ),
                  _buildMultiValueRow(
                    context,
                    'Respondent Groups',
                    survey.respondentsGroups.isEmpty
                        ? ['No respondent groups']
                        : survey.respondentsGroups,
                    theme.isDarkMode,
                    ref,
                    isUserIds: false,
                    icon: Icons.groups_outlined,
                  ),
                  _buildMultiValueRow(
                    context,
                    'Respondent Users',
                    survey.respondentsUsers.isEmpty
                        ? ['No respondent users']
                        : survey.respondentsUsers,
                    theme.isDarkMode,
                    ref,
                    isUserIds: true,
                    icon: Icons.person_outlined,
                  ),
                ],
              ),
            ])
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
      BuildContext context, String title, IconData icon, bool isDarkMode,
      {Widget? actionButton}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Foundations.spacing.lg),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: isDarkMode
                ? Foundations.darkColors.textMuted
                : Foundations.colors.textMuted,
          ),
          SizedBox(width: Foundations.spacing.sm),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: Foundations.typography.lg,
                fontWeight: Foundations.typography.semibold,
                color: isDarkMode
                    ? Foundations.darkColors.textPrimary
                    : Foundations.colors.textPrimary,
              ),
            ),
          ),
          if (actionButton != null) actionButton,
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, bool isDarkMode,
      {required List<Widget> children}) {
    return BaseCard(
      variant: CardVariant.outlined,
      child: Padding(
        padding: EdgeInsets.all(Foundations.spacing.lg),
        child: Column(
          children: [
            ...children.asMap().entries.map((entry) {
              // Add divider between items, but not after the last one
              return Column(
                children: [
                  entry.value,
                  if (entry.key < children.length - 1)
                    Divider(
                      height: Foundations.spacing.xl,
                      color: isDarkMode
                          ? Foundations.darkColors.border
                          : Foundations.colors.border,
                    ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
      BuildContext context, String label, String value, bool isDarkMode,
      {Widget? chip, VoidCallback? onTap}) {
    Widget content = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 160, // Fixed width for labels
          child: Text(
            label,
            style: TextStyle(
              fontSize: Foundations.typography.base,
              fontWeight: Foundations.typography.medium,
              color: isDarkMode
                  ? Foundations.darkColors.textSecondary
                  : Foundations.colors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: Foundations.typography.base,
                    color: isDarkMode
                        ? Foundations.darkColors.textPrimary
                        : Foundations.colors.textPrimary,
                  ),
                ),
              ),
              if (chip != null) chip,
              if (onTap != null)
                Icon(
                  Icons.chevron_right,
                  color: isDarkMode
                      ? Foundations.darkColors.textMuted
                      : Foundations.colors.textMuted,
                ),
            ],
          ),
        ),
      ],
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: Foundations.borders.md,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: Foundations.spacing.xs),
          child: content,
        ),
      );
    }

    return content;
  }

  Widget _buildMultiValueRow(BuildContext context, String label,
      List<String> ids, bool isDarkMode, WidgetRef ref,
      {IconData? icon, bool isUserIds = false}) {
    final groups = ref.watch(allGroupsStreamProvider).value ?? [];
    final users = ref.watch(allUsersStreamProvider).value ?? [];

    // Transform IDs to display names
    final List<NamedItem> items = ids.map((id) {
      if (ids.isEmpty || ids[0].startsWith('No ')) {
        return NamedItem(id: id, name: id);
      }

      if (isUserIds) {
        // Find matching user
        final user = users.firstWhere((u) => u.id == id,
            orElse: () => AppUser(
                id: id,
                firstName: 'Unknown',
                lastName: 'User',
                email: '',
                fcmTokens: [],
                groupIds: [],
                permissions: [],
                deviceIds: {},
                accountType: ''));
        return NamedItem(id: id, name: user.fullName);
      } else {
        // Find matching group
        final group = groups.firstWhere((g) => g.id == id,
            orElse: () => Group(
                  id: id,
                  name: 'Unknown Group',
                  memberIds: [],
                  permissions: [],
                ));
        return NamedItem(id: id, name: group.name);
      }
    }).toList();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 160, // Fixed width for labels
          child: Text(
            label,
            style: TextStyle(
              fontSize: Foundations.typography.base,
              fontWeight: Foundations.typography.medium,
              color: isDarkMode
                  ? Foundations.darkColors.textSecondary
                  : Foundations.colors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Wrap(
            spacing: Foundations.spacing.sm,
            runSpacing: Foundations.spacing.sm,
            children: items.map((item) {
              return Tooltip(
                message: item.name,
                textStyle: TextStyle(
                  color: isDarkMode
                      ? Foundations.darkColors.textPrimary
                      : Foundations.colors.textPrimary,
                ),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? Foundations.darkColors.backgroundMuted
                      : Foundations.colors.backgroundMuted,
                  borderRadius: Foundations.borders.md,
                ),
                child: BaseChip(
                  label: item.name,
                  variant: ChipVariant.default_,
                  size: ChipSize.medium,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(SortingSurveyStatus status) {
    ChipVariant variant;
    String label;

    switch (status) {
      case SortingSurveyStatus.draft:
        variant = ChipVariant.default_;
        label = 'Draft';
        break;
      case SortingSurveyStatus.published:
        variant = ChipVariant.primary;
        label = 'Published';
        break;
      case SortingSurveyStatus.closed:
        variant = ChipVariant.secondary;
        label = 'Closed';
        break;
    }

    return BaseChip(
      label: label,
      variant: variant,
      size: ChipSize.small,
    );
  }

  String _getStatusText(SortingSurveyStatus status) {
    switch (status) {
      case SortingSurveyStatus.draft:
        return 'Draft';
      case SortingSurveyStatus.published:
        return 'Published';
      case SortingSurveyStatus.closed:
        return 'Closed';
    }
  }

  void _showParametersDialog(BuildContext context, List<dynamic> parameters) {
    Dialogs.show(
      context: context,
      variant: DialogVariant.info,
      title: 'Survey Parameters',
      actions: [
        BaseButton(
          label: AppLocalizations.of(context)!.globalOk,
          variant: ButtonVariant.filled,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: survey.parameters.isEmpty
            ? [Text('No parameters defined')]
            : survey.parameters.map((param) {
                String displayName =
                    param['name']?.toString() ?? 'Unnamed Parameter';
                // Convert snake_case to readable format
                displayName = displayName.replaceAll('_', ' ');
                // Capitalize first letter of each word
                displayName = displayName
                    .split(' ')
                    .map((word) => word.isNotEmpty
                        ? '${word[0].toUpperCase()}${word.substring(1)}'
                        : '')
                    .join(' ');

                return ListTile(
                  title: Text(displayName),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Type: ${_formatParameterType(param['type'])}'),
                      Text(
                          'Strategy: ${_formatParameterStrategy(param['strategy'])}'),
                      Text('Priority: ${param['priority']} '),
                    ],
                  ),
                  leading: Icon(
                    param['type'] == 'binary'
                        ? Icons.toggle_on_outlined
                        : Icons.format_list_bulleted,
                  ),
                );
              }).toList(),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat.yMEd().format(date);
  }

  String _formatParameterType(String? type) {
    switch (type) {
      case 'binary':
        return 'Binary (Yes/No)';
      case 'categorical':
        return 'Categorical (Text)';
      default:
        return type ?? 'Unknown';
    }
  }

  String _formatParameterStrategy(String? strategy) {
    switch (strategy) {
      case 'distribute':
        return 'Distribute Evenly';
      case 'concentrate':
        return 'Concentrate Together';
      default:
        return strategy ?? 'Unknown';
    }
  }

  void _showEditAccessDialog(
      BuildContext context, WidgetRef ref, SortingSurvey survey) {
    // Implement editing of access control
    // This would show a modal dialog with multi-select dropdowns to update
    // editor and respondent groups/users

    // This is a placeholder for the full implementation
    final groups = ref.watch(allGroupsStreamProvider).value ?? [];
    final users = ref.watch(allUsersStreamProvider).value ?? [];

    List<String> editorGroups = List.from(survey.editorGroups);
    List<String> editorUsers = List.from(survey.editorUsers);
    List<String> respondentGroups = List.from(survey.respondentsGroups);
    List<String> respondentUsers = List.from(survey.respondentsUsers);
    Dialogs.show(
        context: context,
        title: 'Edit Access Control',
        content: StatefulBuilder(builder: (context, setState) {
          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Editor Groups
                BaseMultiSelect<String>(
                  label: 'Editor Groups',
                  searchable: true,
                  values: editorGroups,
                  options: groups
                      .map((group) => SelectOption(
                            value: group.id,
                            label: group.name,
                            icon: Icons.group_outlined,
                          ))
                      .toList(),
                  onChanged: (values) {
                    setState(() {
                      editorGroups = values;
                    });
                  },
                ),
                SizedBox(height: Foundations.spacing.md),

                // Editor Users
                BaseMultiSelect<String>(
                  label: 'Editor Users',
                  searchable: true,
                  values: editorUsers,
                  options: users
                      .map((user) => SelectOption(
                            value: user.id,
                            label: user.fullName,
                            icon: Icons.person_outlined,
                          ))
                      .toList(),
                  onChanged: (values) {
                    setState(() {
                      editorUsers = values;
                    });
                  },
                ),

                SizedBox(height: Foundations.spacing.lg),

                // Respondent Groups
                BaseMultiSelect<String>(
                  label: 'Respondent Groups',
                  searchable: true,
                  values: respondentGroups,
                  options: groups
                      .map((group) => SelectOption(
                            value: group.id,
                            label: group.name,
                            icon: Icons.group_outlined,
                          ))
                      .toList(),
                  onChanged: (values) {
                    setState(() {
                      respondentGroups = values;
                    });
                  },
                ),
                SizedBox(height: Foundations.spacing.md),

                // Respondent Users
                BaseMultiSelect<String>(
                  label: 'Respondent Users',
                  searchable: true,
                  values: respondentUsers,
                  options: users
                      .map((user) => SelectOption(
                            value: user.id,
                            label: user.fullName,
                            icon: Icons.person_outlined,
                          ))
                      .toList(),
                  onChanged: (values) {
                    setState(() {
                      respondentUsers = values;
                    });
                  },
                ),
              ],
            ),
          );
        }),
        showCancelButton: true,
        actions: [
          BaseButton(
            label: 'Save',
            onPressed: () {
              final updatedSurvey = survey.copyWith(
                editorGroups: editorGroups,
                editorUsers: editorUsers,
                respondentsGroups: respondentGroups,
                respondentsUsers: respondentUsers,
              );

              ref
                  .read(sortingSurveyNotifierProvider.notifier)
                  .updateSortingSurvey(updatedSurvey);

              Navigator.of(context).pop();
            },
            variant: ButtonVariant.filled,
          )
        ]);
  }
}

class _ResponsesTab extends ConsumerWidget {
  final SortingSurvey survey;

  const _ResponsesTab({required this.survey});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Implement responses tab content
    return const Center(child: Text('Responses Content'));
  }
}

class _CalculateTab extends ConsumerWidget {
  final SortingSurvey survey;

  const _CalculateTab({required this.survey});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Implement parameters tab content
    return const Center(child: Text('Parameters Content'));
  }
}

class _ResultsTab extends ConsumerWidget {
  final SortingSurvey survey;

  const _ResultsTab({required this.survey});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Implement parameters tab content
    return const Center(child: Text('Parameters Content'));
  }
}

class NamedItem {
  final String id;
  final String name;

  NamedItem({required this.id, required this.name});
}
// students_data = {
//     "s1": {
//         "sex": "m",
//         "prefs": ["s2", "s3"],
//         "special_needs": "no", 
//         "elementary_school": "Washington"
//     },
//     "s2": {
//         "sex": "f",
//         "prefs": ["s1", "s4"],
//         "special_needs": "yes",
//         "elementary_school": "Lincoln"
//     },
//     "s3": {
//         "sex": "nb",
//         "prefs": ["s1", "s5"],
//         "special_needs": "no",
//         "elementary_school": "Washington"
//     }
//     # ... more students
// }


// parameters = [
//     {
//         'name': 'special_needs',  # Parameter name in student data
//         'type': 'binary',         # 'binary' for yes/no or 'categorical' for text
//         'strategy': 'distribute', # 'distribute' or 'concentrate'
//         'priority': 1             # Lower number = higher priority
//     },
//     {
//         'name': 'elementary_school',
//         'type': 'categorical',
//         'strategy': 'distribute',
//         'priority': 2
//     }
// ]

// class_sizes = {
//     "Class_1A": 25,
//     "Class_1B": 26,
//     "Class_1C": 25,
//     "Class_1D": 24
// }

// result = {
//     "Class_1A": ["student1", "student5", "student8", ...],
//     "Class_1B": ["student2", "student6", "student9", ...],
//     "Class_1C": ["student3", "student7", "student10", ...],
//     "Class_1D": ["student4", "student11", "student12", ...]
// }

// {'m': 0.5, 'f': 0.5, 'nb': 0.05}