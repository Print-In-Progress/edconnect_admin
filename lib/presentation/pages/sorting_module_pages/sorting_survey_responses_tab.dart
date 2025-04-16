import 'package:edconnect_admin/core/design_system/color_generator.dart';
import 'package:edconnect_admin/core/design_system/foundations.dart';
import 'package:edconnect_admin/domain/entities/sorting_survey.dart';
import 'package:edconnect_admin/presentation/providers/action_providers.dart';
import 'package:edconnect_admin/presentation/providers/state_providers.dart';
import 'package:edconnect_admin/presentation/providers/theme_provider.dart';
import 'package:edconnect_admin/presentation/widgets/common/buttons/base_button.dart';
import 'package:edconnect_admin/presentation/widgets/common/buttons/base_icon_button.dart';
import 'package:edconnect_admin/presentation/widgets/common/cards/base_card.dart';
import 'package:edconnect_admin/presentation/widgets/common/dialogs/dialogs.dart';
import 'package:edconnect_admin/presentation/widgets/common/dropdown/single_select_dropdown.dart';
import 'package:edconnect_admin/presentation/widgets/common/input/base_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ResponsesTab extends ConsumerWidget {
  final SortingSurvey survey;

  const ResponsesTab({super.key, required this.survey});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeProvider);
    final isDarkMode = theme.isDarkMode;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(Foundations.spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overview Statistics Section
            _buildSectionHeader(context, 'Response Statistics',
                Icons.analytics_outlined, isDarkMode),
            SizedBox(height: Foundations.spacing.md),
            _buildStatisticsGrid(context, isDarkMode),

            SizedBox(height: Foundations.spacing.xl),

            // Parameter Statistics Section
            _buildSectionHeader(
                context, 'Parameter Distribution', Icons.bar_chart, isDarkMode),
            SizedBox(height: Foundations.spacing.md),
            _buildParameterStats(context, isDarkMode),

            SizedBox(height: Foundations.spacing.xl),

            // Responses Table Section
            _buildSectionHeader(
                context, 'Individual Responses', Icons.table_chart, isDarkMode),
            SizedBox(height: Foundations.spacing.md),
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      BaseButton(
                        label: 'Add Manually',
                        prefixIcon: Icons.person_add_outlined,
                        variant: ButtonVariant.outlined,
                        size: ButtonSize.medium,
                        onPressed: () {
                          _addUserManually(
                              context, ref, isDarkMode, theme.accentLight);
                        },
                      ),
                      SizedBox(width: Foundations.spacing.md),
                      BaseButton(
                        label: 'Import',
                        prefixIcon: Icons.upload_file_outlined,
                        variant: ButtonVariant.outlined,
                        size: ButtonSize.medium,
                        onPressed: () {
                          // TODO: Implement import
                        },
                      ),
                      SizedBox(width: Foundations.spacing.md),
                      BaseButton(
                        label: 'Export',
                        prefixIcon: Icons.download_outlined,
                        variant: ButtonVariant.outlined,
                        size: ButtonSize.medium,
                        onPressed: () {
                          // TODO: Implement export
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: Foundations.spacing.md),
            _buildResponsesTable(context, ref, isDarkMode),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
    bool isDarkMode,
  ) {
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

  Widget _buildStatisticsGrid(BuildContext context, bool isDarkMode) {
    final totalResponses = survey.responses.length;
    final manualEntries = survey.responses.values
        .where((response) => response['_manual_entry'] == true)
        .length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth =
            (constraints.maxWidth - Foundations.spacing.lg * 2) / 3;
        return Row(
          children: [
            _buildStatCard(
              context,
              'Total Responses',
              totalResponses.toString(),
              Icons.people_outline,
              isDarkMode,
              cardWidth,
            ),
            SizedBox(width: Foundations.spacing.lg),
            _buildStatCard(
              context,
              'Parameters',
              survey.parameters.length.toString(),
              Icons.tune,
              isDarkMode,
              cardWidth,
            ),
            SizedBox(width: Foundations.spacing.lg),
            _buildStatCard(
              context,
              'Manual Entries',
              manualEntries.toString(),
              Icons.edit_outlined,
              isDarkMode,
              cardWidth,
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    bool isDarkMode,
    double width,
  ) {
    return SizedBox(
      width: width,
      height: 100, // Keep fixed height
      child: BaseCard(
        variant: CardVariant.outlined,
        margin: EdgeInsets.zero,
        padding: EdgeInsets.all(Foundations.spacing.md),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: isDarkMode
                  ? Foundations.darkColors.textMuted
                  : Foundations.colors.textMuted,
            ),
            SizedBox(width: Foundations.spacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: Foundations.typography.sm,
                      color: isDarkMode
                          ? Foundations.darkColors.textMuted
                          : Foundations.colors.textMuted,
                    ),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: Foundations.typography.lg,
                      fontWeight: Foundations.typography.semibold,
                      color: isDarkMode
                          ? Foundations.darkColors.textPrimary
                          : Foundations.colors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Replace existing _buildParameterStats with this:
  Widget _buildParameterStats(BuildContext context, bool isDarkMode) {
    return Wrap(
      spacing: Foundations.spacing.md,
      runSpacing: Foundations.spacing.md,
      children: [
        // Biological Sex Card
        if (survey.askBiologicalSex)
          _buildParameterCard(
              _buildBiologicalSexStats(isDarkMode), isDarkMode, 0),

        // Parameter Cards
        ...survey.parameters.asMap().entries.map(
              (entry) => _buildParameterCard(
                _buildParameterStat(entry.value, isDarkMode),
                isDarkMode,
                entry.key + (survey.askBiologicalSex ? 1 : 0),
              ),
            ),
      ],
    );
  }

  Widget _buildParameterCard(Widget content, bool isDarkMode, int colorIndex) {
    return SizedBox(
      width: 400,
      height: 240, // Fixed height for all cards
      child: BaseCard(
        padding: EdgeInsets.all(Foundations.spacing.md),
        margin: EdgeInsets.zero,
        variant: CardVariant.outlined,
        child: content,
      ),
    );
  }

  Widget _buildDistributionRow(
    String paramName,
    Map<String, int> distribution,
    bool isDarkMode, {
    bool limitEntries = false,
    bool isSexParameter = false,
  }) {
    final total = distribution.values.fold(0, (sum, count) => sum + count);

    var sortedEntries = distribution.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (limitEntries && sortedEntries.length > 3) {
      int othersCount =
          sortedEntries.skip(3).fold(0, (sum, e) => sum + e.value);
      sortedEntries = sortedEntries.take(2).toList();
      if (othersCount > 0) {
        sortedEntries.add(MapEntry('Other', othersCount));
      }
    }

    return Padding(
      padding: EdgeInsets.all(Foundations.spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                paramName,
                style: TextStyle(
                  fontSize: Foundations.typography.base,
                  fontWeight: Foundations.typography.semibold,
                  color: isDarkMode
                      ? Foundations.darkColors.textPrimary
                      : Foundations.colors.textPrimary,
                ),
              ),
              const Spacer(),
              if (sortedEntries.length > 3)
                BaseButton(
                    label: 'View All',
                    onPressed: () {},
                    variant: ButtonVariant.text,
                    size: ButtonSize.small),
            ],
          ),
          SizedBox(height: Foundations.spacing.lg),
          ...sortedEntries.map((entry) {
            final percentage = total > 0 ? (entry.value / total * 100) : 0;
            final isBinary = sortedEntries.length == 2 &&
                sortedEntries.every((e) =>
                    e.key.toLowerCase() == 'yes' ||
                    e.key.toLowerCase() == 'no');

            final displayValue =
                isSexParameter ? _formatSex(entry.key) : entry.key;

            final color = ColorGenerator.getColor(
              paramName,
              displayValue,
              isDarkMode: isDarkMode,
              isBinary: isBinary,
            );

            return Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        displayValue,
                        style: TextStyle(
                          fontSize: Foundations.typography.sm,
                          color: color,
                          fontWeight: Foundations.typography.medium,
                        ),
                      ),
                    ),
                    Text(
                      '${entry.value} (${percentage.toStringAsFixed(1)}%)',
                      style: TextStyle(
                        fontSize: Foundations.typography.sm,
                        color: color,
                        fontWeight: Foundations.typography.medium,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: Foundations.spacing.xs),
                LinearProgressIndicator(
                  value: percentage / 100,
                  backgroundColor: color.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 8,
                  borderRadius: Foundations.borders.full,
                ),
                SizedBox(height: Foundations.spacing.md),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBiologicalSexStats(bool isDarkMode) {
    final responses = survey.responses;
    int males = 0, females = 0, nonBinary = 0;

    for (final response in responses.values) {
      switch (response['sex']) {
        case 'm':
          males++;
          break;
        case 'f':
          females++;
          break;
        case 'nb':
          nonBinary++;
          break;
      }
    }

    return _buildDistributionRow(
      'Biological Sex',
      {
        'm': males, // Use raw values instead of formatted ones
        'f': females,
        'nb': nonBinary,
      },
      isDarkMode,
      limitEntries: false,
      isSexParameter: true, // Add this flag
    );
  }

  Widget _buildParameterStat(Map<String, dynamic> param, bool isDarkMode) {
    final responses = survey.responses;
    final name = param['name'];
    final type = param['type'];

    if (type == 'binary') {
      int yes = 0, no = 0;
      for (final response in responses.values) {
        if (response[name] == 'yes') {
          yes++;
        } else if (response[name] == 'no') {
          no++;
        }
      }

      return _buildDistributionRow(
        _formatParameterName(name),
        {'Yes': yes, 'No': no},
        isDarkMode,
        limitEntries: false,
      );
    } else {
      Map<String, int> distribution = {};
      for (final response in responses.values) {
        final value = response[name]?.toString() ?? 'Unknown';
        distribution[value] = (distribution[value] ?? 0) + 1;
      }

      return _buildDistributionRow(
        _formatParameterName(name),
        distribution,
        isDarkMode,
        limitEntries: true,
      );
    }
  }

  Widget _buildResponsesTable(
      BuildContext context, WidgetRef ref, bool isDarkMode) {
    final responses = ref.watch(filteredResponsesProvider(survey.id));

    return BaseCard(
      variant: CardVariant.outlined,
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(Foundations.spacing.md),
            child: Row(
              children: [
                Expanded(
                  child: BaseInput(
                    leadingIcon: Icons.search,
                    hint: 'Search by name...',
                    size: InputSize.small,
                    onChanged: (value) {
                      ref
                              .read(responsesFilterProvider(survey.id).notifier)
                              .state =
                          ref.read(responsesFilterProvider(survey.id)).copyWith(
                                searchQuery: value,
                              );
                    },
                  ),
                ),
                SizedBox(width: Foundations.spacing.md),
                SizedBox(
                  width: 160,
                  child: BaseSelect<SortOrder>(
                    value:
                        ref.watch(responsesFilterProvider(survey.id)).sortOrder,
                    options: [
                      SelectOption(
                        value: SortOrder.asc,
                        label: 'Name A-Z',
                        icon: Icons.arrow_upward,
                      ),
                      SelectOption(
                        value: SortOrder.desc,
                        label: 'Name Z-A',
                        icon: Icons.arrow_downward,
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        ref
                                .read(responsesFilterProvider(survey.id).notifier)
                                .state =
                            ref
                                .read(responsesFilterProvider(survey.id))
                                .copyWith(
                                  sortOrder: value,
                                );
                      }
                    },
                    size: SelectSize.small,
                  ),
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(
              children: [
                // Parameter filters row
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: Foundations.spacing.md,
                    vertical: Foundations.spacing.sm,
                  ),
                  child: Row(
                    children: [
                      if (survey.askBiologicalSex)
                        Padding(
                          padding:
                              EdgeInsets.only(right: Foundations.spacing.sm),
                          child: SizedBox(
                            width: 140,
                            child: BaseSelect<String?>(
                              hint: 'Sex',
                              size: SelectSize.small,
                              value: ref
                                  .watch(responsesFilterProvider(survey.id))
                                  .parameterFilters['sex'],
                              options: [
                                SelectOption(value: null, label: 'All'),
                                SelectOption(value: 'm', label: 'Male'),
                                SelectOption(value: 'f', label: 'Female'),
                                SelectOption(value: 'nb', label: 'Non-Binary'),
                              ],
                              onChanged: (value) {
                                final currentFilters =
                                    Map<String, String?>.from(
                                  ref
                                      .read(responsesFilterProvider(survey.id))
                                      .parameterFilters,
                                );
                                currentFilters['sex'] = value;
                                ref
                                        .read(responsesFilterProvider(survey.id)
                                            .notifier)
                                        .state =
                                    ref
                                        .read(
                                            responsesFilterProvider(survey.id))
                                        .copyWith(
                                          parameterFilters: currentFilters,
                                        );
                              },
                            ),
                          ),
                        ),
                      ...survey.parameters.map((param) {
                        if (param['type'] == 'binary') {
                          return Padding(
                            padding:
                                EdgeInsets.only(right: Foundations.spacing.sm),
                            child: SizedBox(
                              width: 140,
                              child: BaseSelect<String?>(
                                hint: _formatParameterName(param['name']),
                                size: SelectSize.small,
                                value: ref
                                    .watch(responsesFilterProvider(survey.id))
                                    .parameterFilters[param['name']],
                                options: [
                                  SelectOption(value: null, label: 'All'),
                                  SelectOption(value: 'yes', label: 'Yes'),
                                  SelectOption(value: 'no', label: 'No'),
                                ],
                                onChanged: (value) {
                                  final currentFilters =
                                      Map<String, String?>.from(
                                    ref
                                        .read(
                                            responsesFilterProvider(survey.id))
                                        .parameterFilters,
                                  );
                                  currentFilters[param['name']] = value;
                                  ref
                                          .read(
                                              responsesFilterProvider(survey.id)
                                                  .notifier)
                                          .state =
                                      ref
                                          .read(responsesFilterProvider(
                                              survey.id))
                                          .copyWith(
                                            parameterFilters: currentFilters,
                                          );
                                },
                              ),
                            ),
                          );
                        }
                        // For categorical parameters
                        final uniqueValues = survey.responses.values
                            .map((r) => r[param['name']]?.toString())
                            .where((v) => v != null)
                            .toSet()
                            .toList()
                          ..sort();

                        return Padding(
                          padding:
                              EdgeInsets.only(right: Foundations.spacing.sm),
                          child: SizedBox(
                            width: 140,
                            child: BaseSelect<String?>(
                              hint: _formatParameterName(param['name']),
                              size: SelectSize.small,
                              value: ref
                                  .watch(responsesFilterProvider(survey.id))
                                  .parameterFilters[param['name']],
                              options: [
                                SelectOption(value: null, label: 'All'),
                                ...uniqueValues.map(
                                    (v) => SelectOption(value: v, label: v!)),
                              ],
                              onChanged: (value) {
                                final currentFilters =
                                    Map<String, String?>.from(
                                  ref
                                      .read(responsesFilterProvider(survey.id))
                                      .parameterFilters,
                                );
                                currentFilters[param['name']] = value;
                                ref
                                        .read(responsesFilterProvider(survey.id)
                                            .notifier)
                                        .state =
                                    ref
                                        .read(
                                            responsesFilterProvider(survey.id))
                                        .copyWith(
                                          parameterFilters: currentFilters,
                                        );
                              },
                            ),
                          ),
                        );
                      }),
                      BaseIconButton(
                        icon: Icons.clear_all,
                        onPressed: () {
                          ref
                              .read(responsesFilterProvider(survey.id).notifier)
                              .state = const ResponsesFilterState();
                        },
                        tooltip: 'Clear filters',
                        variant: IconButtonVariant.outlined,
                        size: IconButtonSize.small,
                      ),
                    ],
                  ),
                ),
                // Table
                DataTable(
                  columns: [
                    DataColumn(label: Text('Name')),
                    if (survey.askBiologicalSex) DataColumn(label: Text('Sex')),
                    ...survey.parameters.map(
                      (param) => DataColumn(
                        label: Text(_formatParameterName(param['name'])),
                      ),
                    ),
                    DataColumn(label: Text('Actions')), // Add actions column
                  ],
                  rows: responses.entries.map((entry) {
                    final response = entry.value;
                    return DataRow(
                      cells: [
                        DataCell(Text(
                            '${response['_first_name']} ${response['_last_name']}')),
                        if (survey.askBiologicalSex)
                          _buildColoredDataCell(
                              'sex', response['sex'], isDarkMode),
                        ...survey.parameters.map(
                          (param) => _buildColoredDataCell(
                            param['name'],
                            response[param['name']]?.toString() ?? '',
                            isDarkMode,
                          ),
                        ),
                        DataCell(Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            BaseIconButton(
                              icon: Icons.edit_outlined,
                              onPressed: () {},
                              variant: IconButtonVariant.ghost,
                              size: IconButtonSize.small,
                              tooltip: 'Edit response',
                            ),
                            SizedBox(width: Foundations.spacing.xs),
                            BaseIconButton(
                              icon: Icons.delete_outline,
                              onPressed: () async {
                                final bool? confirmed = await Dialogs.confirm(
                                  context: context,
                                  title: 'Delete Response',
                                  message:
                                      'Are you sure you want to delete this response?',
                                  variant: DialogVariant.danger,
                                );
                                if (confirmed != null && confirmed) {
                                  final updatedResponses =
                                      Map<String, Map<String, dynamic>>.from(
                                          survey.responses);
                                  updatedResponses.remove(entry.key);

                                  ref
                                      .read(sortingSurveyNotifierProvider
                                          .notifier)
                                      .updateSortingSurvey(
                                        survey.copyWith(
                                            responses: updatedResponses),
                                      );
                                }
                              },
                              variant: IconButtonVariant.ghost,
                              size: IconButtonSize.small,
                              tooltip: 'Delete response',
                              color: Foundations.colors.error,
                            ),
                          ],
                        )),
                      ],
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  DataCell _buildColoredDataCell(
      String paramName, String value, bool isDarkMode) {
    final isSexParameter = paramName == 'sex';
    final isBinary = !isSexParameter &&
        (survey.parameters.firstWhere((p) => p['name'] == paramName)['type'] ==
            'binary');

    // Get color using raw value
    final color = ColorGenerator.getColor(
      paramName,
      value, // Use raw value for color
      isDarkMode: isDarkMode,
      isBinary: isBinary,
    );

    // Format display value
    final displayValue = isSexParameter ? _formatSex(value) : value;

    return DataCell(
      Tooltip(
        message: displayValue,
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
        child: Text(
          isSexParameter ? displayValue : _formatDisplayValue(displayValue),
          style: TextStyle(color: color),
        ),
      ),
    );
  }

  String _formatParameterName(String name) {
    return name
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.isNotEmpty
            ? '${word[0].toUpperCase()}${word.substring(1)}'
            : '')
        .join(' ');
  }

  String _formatSex(String? sex) {
    switch (sex) {
      case 'm':
        return 'Male';
      case 'f':
        return 'Female';
      case 'nb':
        return 'Non-Binary';
      default:
        return 'Unknown';
    }
  }

  void _addUserManually(
      BuildContext context, WidgetRef ref, bool isDarkMode, Color accentColor) {
    final users = ref.watch(allUsersStreamProvider).value ?? [];
    final responses = ref.watch(filteredResponsesProvider(survey.id));

    // States for the form
    bool isManualEntry = true;
    String? selectedUserId;
    final manualFirstNameController = TextEditingController();
    final manualLastNameController = TextEditingController();
    Map<String, dynamic> parameterResponses = {};
    String? selectedSex;

    final parameterControllers = {
      for (var param in survey.parameters)
        if (param['type'] != 'binary') param['name']: TextEditingController()
    };

    // Cleanup controllers on dialog close
    void dispose() {
      manualFirstNameController.dispose();
      manualLastNameController.dispose();
      for (var controller in parameterControllers.values) {
        controller.dispose();
      }
    }

    Dialogs.form(
      context: context,
      title: 'Add Response Manually',
      width: 600,
      variant: DialogVariant.default_,
      form: StatefulBuilder(
        builder: (context, setState) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: Foundations.spacing.xs,
                children: [
                  FilterChip(
                    label: const Text('Manual Entry'),
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
                    label: const Text('Select User'),
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
              ),
              SizedBox(height: Foundations.spacing.lg),

              // Either show manual entry fields or user dropdown
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
              ] else ...[
                BaseSelect<String>(
                  label: 'Select User',
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
                ),
              ],

              // Sex selection with toggle chips
              if (survey.askBiologicalSex) ...[
                SizedBox(height: Foundations.spacing.lg),
                _ToggleChipGroup<String>(
                  label: 'Biological Sex',
                  options: [
                    (
                      'm',
                      'Male',
                      ColorGenerator.getColor('sex', 'm',
                          isDarkMode: isDarkMode)
                    ),
                    (
                      'f',
                      'Female',
                      ColorGenerator.getColor('sex', 'f',
                          isDarkMode: isDarkMode)
                    ),
                    (
                      'nb',
                      'Non-Binary',
                      ColorGenerator.getColor('sex', 'nb',
                          isDarkMode: isDarkMode)
                    ),
                  ],
                  selectedValue: selectedSex,
                  onChanged: (value) => setState(() => selectedSex = value),
                ),
              ],

              // Parameters with toggle chips for binary parameters
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
              ...survey.parameters.map((param) {
                final name = param['name'] as String;
                final type = param['type'] as String;

                if (type == 'binary') {
                  return Padding(
                    padding: EdgeInsets.only(bottom: Foundations.spacing.md),
                    child: _ToggleChipGroup<String>(
                      label: _formatParameterName(name),
                      options: [
                        ('yes', 'Yes', ColorGenerator.yesColor),
                        ('no', 'No', ColorGenerator.noColor),
                      ],
                      selectedValue: parameterResponses[name],
                      onChanged: (value) => setState(
                          () => parameterResponses[name] = value ?? ''),
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
                        _formatParameterName(name),
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
        },
      ),
      actions: [
        BaseButton(
          label: 'Add Response',
          variant: ButtonVariant.filled,
          onPressed: () {
            // Validate form
            if (selectedUserId == null &&
                (manualFirstNameController.text.isEmpty ||
                    manualLastNameController.text.isEmpty)) {
              Dialogs.alert(
                context: context,
                title: 'Validation Error',
                message: 'Please enter first and last name',
                variant: DialogVariant.danger,
              );
              return;
            }

            if (survey.askBiologicalSex && selectedSex == null) {
              Dialogs.alert(
                context: context,
                title: 'Validation Error',
                message: 'Please select biological sex',
                variant: DialogVariant.danger,
              );
              return;
            }

            if (parameterResponses.length != survey.parameters.length) {
              Dialogs.alert(
                context: context,
                title: 'Validation Error',
                message: 'Please answer all parameters',
                variant: DialogVariant.danger,
              );
              return;
            }

            final formattedResponses =
                Map<String, dynamic>.from(parameterResponses);
            for (var param in survey.parameters) {
              if (param['type'] != 'binary') {
                final value = parameterControllers[param['name']]?.text ?? '';
                formattedResponses[param['name']] =
                    _formatCategoricalValue(value);
              }
            }

            // Create response data
            final response = {
              ...formattedResponses,
              if (survey.askBiologicalSex) 'sex': selectedSex,
            };

            // Add metadata for manual entries
            if (selectedUserId == null) {
              response['_manual_entry'] = true; // Now this is a bool
              response['_first_name'] = manualFirstNameController.text;
              response['_last_name'] = manualLastNameController.text;
            }

            // Generate response ID
            final responseId = selectedUserId ??
                'manual_${DateTime.now().millisecondsSinceEpoch}';

            // Update survey with new response
            final updatedResponses = {
              ...survey.responses,
              responseId: response,
            };

            // Update survey
            ref
                .read(sortingSurveyNotifierProvider.notifier)
                .updateSortingSurvey(
                  survey.copyWith(responses: updatedResponses),
                );
            dispose();
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

String _formatCategoricalValue(String value) {
  return value
      .trim() // Remove leading/trailing spaces
      .toLowerCase() // Make case insensitive
      .replaceAll(
          RegExp(r'\s+'), '_') // Replace multiple spaces with single underscore
      .replaceAll(RegExp(r'[^a-z0-9_]'),
          '') // Remove special characters except underscore
      .replaceAll(
          RegExp(r'_+'), '_') // Replace multiple underscores with single
      .replaceAll(RegExp(r'^_|_$'), ''); // Remove leading/trailing underscores
}

String _formatDisplayValue(String value) {
  return value
      .split('_')
      .map((word) =>
          word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : '')
      .join(' ');
}

// Add this helper widget for the toggle chips
class _ToggleChipGroup<T> extends ConsumerWidget {
  final String label;
  final List<(T value, String label, Color? color)> options;
  final T? selectedValue;
  final ValueChanged<T?> onChanged;

  const _ToggleChipGroup({
    required this.label,
    required this.options,
    required this.selectedValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: Foundations.typography.base,
            fontWeight: Foundations.typography.medium,
            color: theme.isDarkMode
                ? Foundations.darkColors.textPrimary
                : Foundations.colors.textPrimary,
          ),
        ),
        SizedBox(height: Foundations.spacing.sm),
        Wrap(
          spacing: Foundations.spacing.xs,
          children: options.map((option) {
            final isSelected = selectedValue == option.$1;
            return FilterChip(
              label: Text(option.$2),
              selected: isSelected,
              showCheckmark: false,
              backgroundColor: theme.isDarkMode
                  ? Foundations.darkColors.backgroundMuted
                  : Foundations.colors.backgroundMuted,
              selectedColor: option.$3?.withValues(alpha: 0.1) ??
                  (theme.isDarkMode
                      ? theme.accentLight.withValues(alpha: 0.1)
                      : theme.accentLight.withValues(alpha: 0.1)),
              labelStyle: TextStyle(
                color: isSelected
                    ? option.$3 ??
                        (theme.isDarkMode
                            ? theme.accentLight
                            : theme.accentLight)
                    : theme.isDarkMode
                        ? Foundations.darkColors.textPrimary
                        : Foundations.colors.textPrimary,
                fontWeight: isSelected
                    ? Foundations.typography.medium
                    : Foundations.typography.regular,
              ),
              onSelected: (_) => onChanged(isSelected ? null : option.$1),
            );
          }).toList(),
        ),
      ],
    );
  }
}
