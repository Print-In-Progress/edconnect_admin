import 'package:edconnect_admin/core/design_system/color_generator.dart';
import 'package:edconnect_admin/core/design_system/foundations.dart';
import 'package:edconnect_admin/core/models/app_user.dart';
import 'package:edconnect_admin/domain/entities/sorting_survey.dart';
import 'package:edconnect_admin/l10n/app_localizations.dart';
import 'package:edconnect_admin/presentation/pages/sorting_module_pages/dialogs/export_responses_dialog.dart';
import 'package:edconnect_admin/presentation/pages/sorting_module_pages/dialogs/import_responses_dialog.dart';
import 'package:edconnect_admin/presentation/providers/action_providers.dart';
import 'package:edconnect_admin/presentation/providers/state_providers.dart';
import 'package:edconnect_admin/presentation/providers/theme_provider.dart';
import 'package:edconnect_admin/presentation/widgets/common/buttons/base_button.dart';
import 'package:edconnect_admin/presentation/widgets/common/buttons/base_icon_button.dart';
import 'package:edconnect_admin/presentation/widgets/common/cards/base_card.dart';
import 'package:edconnect_admin/presentation/widgets/common/dialogs/dialogs.dart';
import 'package:edconnect_admin/presentation/widgets/common/dropdown/multi_select_dropdown.dart';
import 'package:edconnect_admin/presentation/widgets/common/dropdown/single_select_dropdown.dart';
import 'package:edconnect_admin/presentation/widgets/common/input/base_input.dart';
import 'package:edconnect_admin/presentation/widgets/common/loading_indicators/async_value_widget.dart';
import 'package:edconnect_admin/presentation/widgets/common/navigation/pagination.dart';
import 'package:edconnect_admin/presentation/widgets/common/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';

class ResponsesTab extends ConsumerWidget {
  final SortingSurvey survey;

  const ResponsesTab({super.key, required this.survey});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeProvider);
    final isDarkMode = theme.isDarkMode;

    final surveyAsync = ref.watch(selectedSortingSurveyProvider(survey.id));

    // Watch the filtered responses provider directly - it reacts to survey changes automatically

    return AsyncValueWidget(
      value: surveyAsync,
      skipLoadingOnRefresh: true,
      data: (latestSurvey) {
        if (latestSurvey == null) {
          return const Center(child: CircularProgressIndicator());
        }
        final filteredResponses =
            ref.watch(filteredResponsesProvider(survey.id));

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
                _buildStatisticsGrid(context, isDarkMode, latestSurvey),

                SizedBox(height: Foundations.spacing.xl),

                // Parameter Statistics Section
                _buildSectionHeader(context, 'Parameter Distribution',
                    Icons.bar_chart, isDarkMode),
                SizedBox(height: Foundations.spacing.md),
                _buildParameterStats(context, isDarkMode, latestSurvey),

                SizedBox(height: Foundations.spacing.xl),

                // Responses Table Section
                _buildSectionHeader(context, 'Individual Responses',
                    Icons.table_chart, isDarkMode),
                SizedBox(height: Foundations.spacing.md),
                Wrap(
                  runSpacing: Foundations.spacing.xs,
                  children: [
                    BaseButton(
                      label: 'Add Manually',
                      prefixIcon: Icons.person_add_outlined,
                      variant: ButtonVariant.outlined,
                      size: ButtonSize.medium,
                      onPressed: () {
                        _addUserManually(context, ref, isDarkMode,
                            theme.accentLight, latestSurvey);
                      },
                    ),
                    SizedBox(width: Foundations.spacing.md),
                    BaseButton(
                      label: 'Import Responses',
                      prefixIcon: Icons.upload_file_outlined,
                      variant: ButtonVariant.outlined,
                      size: ButtonSize.medium,
                      onPressed: () =>
                          _showImportDialog(context, ref, latestSurvey),
                    ),
                    SizedBox(width: Foundations.spacing.md),
                    BaseButton(
                      label: 'Export',
                      prefixIcon: Icons.download_outlined,
                      variant: ButtonVariant.outlined,
                      size: ButtonSize.medium,
                      onPressed: () {
                        Dialogs.show(
                          context: context,
                          title: 'Export Responses',
                          content: const ExportResponsesDialog(),
                          showCancelButton: true,
                        );
                      },
                    ),
                    SizedBox(width: Foundations.spacing.md),
                    BaseButton(
                      label: 'Delete All',
                      prefixIcon: Icons.delete_sweep_outlined,
                      variant: ButtonVariant.filled,
                      size: ButtonSize.medium,
                      backgroundColor: Foundations.colors.error,
                      onPressed: () =>
                          _deleteAllResponses(context, ref, latestSurvey),
                    ),
                  ],
                ),
                SizedBox(height: Foundations.spacing.md),
                _buildResponsesTable(
                    context, ref, isDarkMode, latestSurvey, filteredResponses),
              ],
            ),
          ),
        );
      },
      loading: () => _buildLoadingState(),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline,
                size: 48, color: Foundations.colors.error),
            SizedBox(height: Foundations.spacing.md),
            Text('Error loading survey: $error'),
            SizedBox(height: Foundations.spacing.md),
            BaseButton(
              label: 'Retry',
              variant: ButtonVariant.outlined,
              onPressed: () =>
                  ref.invalidate(selectedSortingSurveyProvider(survey.id)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: EdgeInsets.all(Foundations.spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Statistics section skeleton
          Container(
              height: 24, width: 200, color: Foundations.colors.surfaceActive),
          SizedBox(height: Foundations.spacing.md),
          Row(
            children: List.generate(
                3,
                (_) => Expanded(
                      child: Container(
                        height: 100,
                        margin: EdgeInsets.only(right: Foundations.spacing.md),
                        color: Foundations.colors.surfaceActive,
                      ),
                    )),
          ),

          SizedBox(height: Foundations.spacing.xl),

          // Parameter section skeleton
          Container(
              height: 24, width: 200, color: Foundations.colors.surfaceActive),
          SizedBox(height: Foundations.spacing.md),
          Wrap(
            spacing: Foundations.spacing.md,
            runSpacing: Foundations.spacing.md,
            children: List.generate(
                4,
                (_) => Container(
                      width: 400,
                      height: 240,
                      color: Foundations.colors.surfaceActive,
                    )),
          ),

          SizedBox(height: Foundations.spacing.xl),

          // Responses table skeleton
          Container(
              height: 24, width: 200, color: Foundations.colors.surfaceActive),
          SizedBox(height: Foundations.spacing.md),
          Container(
            height: 300,
            color: Foundations.colors.surfaceActive,
          ),
        ],
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

  Widget _buildStatisticsGrid(
      BuildContext context, bool isDarkMode, SortingSurvey survey) {
    final totalResponses = survey.responses.length;
    final totalPreferences = survey.responses.values
        .map((r) => (r['prefs'] as List?)?.length ?? 0)
        .fold(0, (sum, count) => sum + count);

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
              'Total Number of Preferences',
              survey.maxPreferences != null
                  ? '$totalPreferences (max ${survey.maxPreferences} per user)'
                  : 'Disabled',
              Icons.favorite_outline,
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
                mainAxisSize: MainAxisSize.min, // Use minimum height
                crossAxisAlignment: CrossAxisAlignment.start,
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
                  SizedBox(height: Foundations.spacing.xs),
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
  Widget _buildParameterStats(
      BuildContext context, bool isDarkMode, SortingSurvey survey) {
    return Wrap(
      spacing: Foundations.spacing.md,
      runSpacing: Foundations.spacing.md,
      children: [
        // Biological Sex Card
        if (survey.askBiologicalSex)
          _buildParameterCard(
              _buildBiologicalSexStats(context, isDarkMode), isDarkMode, 0),

        // Parameter Cards
        ...survey.parameters.asMap().entries.map(
              (entry) => _buildParameterCard(
                _buildParameterStat(context, entry.value, isDarkMode),
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
    BuildContext context,
    String paramName,
    Map<String, int> distribution,
    bool isDarkMode, {
    bool limitEntries = false,
    bool isSexParameter = false,
  }) {
    final total = distribution.values.fold(0, (sum, count) => sum + count);

    var sortedEntries = distribution.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final originalLength = sortedEntries.length;

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
              Expanded(
                child: Tooltip(
                  message: _formatParameterName(paramName),
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
                    _formatParameterName(paramName),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: Foundations.typography.base,
                      fontWeight: Foundations.typography.semibold,
                      color: isDarkMode
                          ? Foundations.darkColors.textPrimary
                          : Foundations.colors.textPrimary,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              if (originalLength > 3)
                BaseButton(
                    label: 'View All',
                    onPressed: () {
                      _viewAllDialog(context, paramName, isDarkMode);
                    },
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
                      child: Tooltip(
                        message: _formatDisplayValue(displayValue),
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
                          _formatDisplayValue(displayValue),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: Foundations.typography.sm,
                            color: color,
                            fontWeight: Foundations.typography.medium,
                          ),
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

  Widget _buildBiologicalSexStats(BuildContext context, bool isDarkMode) {
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
      context,
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

  Widget _buildParameterStat(
      BuildContext context, Map<String, dynamic> param, bool isDarkMode) {
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
        context,
        name,
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
        context,
        name,
        distribution,
        isDarkMode,
        limitEntries: true,
      );
    }
  }

  Widget _buildResponsesTable(
      BuildContext context,
      WidgetRef ref,
      bool isDarkMode,
      SortingSurvey survey,
      AsyncValue<Map<String, Map<String, dynamic>>> filteredResponses) {
    return filteredResponses.when(
      data: (responses) {
        final paginationState =
            ref.watch(paginationStateProvider('responses_${survey.id}'));
        final accentColor = ref.watch(appThemeProvider).accentLight;
        final allEntries = responses.entries.toList();
        final hasAnyResponses = survey.responses.isNotEmpty;
        final filterRowScrollController = ScrollController();
        // Set pagination after build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref
              .read(paginationStateProvider('responses_${survey.id}').notifier)
              .setTotalItems(responses.length);
        });

        final start =
            paginationState.currentPage * paginationState.itemsPerPage;
        final end =
            min(start + paginationState.itemsPerPage, allEntries.length);
        final List<MapEntry<String, Map<String, dynamic>>> paginatedResponses =
            allEntries.isEmpty
                ? []
                : allEntries.sublist(start, min(end, allEntries.length));

        return BaseCard(
          variant: CardVariant.outlined,
          margin: EdgeInsets.zero,
          child: Column(
            children: [
              // Always show filters
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
                              ref
                                  .read(responsesFilterProvider(survey.id))
                                  .copyWith(
                                    searchQuery: value,
                                  );
                        },
                      ),
                    ),
                    SizedBox(width: Foundations.spacing.md),
                    SizedBox(
                      width: 160,
                      child: BaseSelect<SortOrder>(
                        value: ref
                            .watch(responsesFilterProvider(survey.id))
                            .sortOrder,
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
                                    .read(responsesFilterProvider(survey.id)
                                        .notifier)
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
                  controller: filterRowScrollController,
                  child: Column(children: [
                    // Parameter filters row
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: Foundations.spacing.md,
                        vertical: Foundations.spacing.sm,
                      ),
                      child: Wrap(
                        children: [
                          if (survey.askBiologicalSex)
                            Padding(
                              padding: EdgeInsets.only(
                                  right: Foundations.spacing.sm),
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
                                    SelectOption(
                                        value: 'nb', label: 'Non-Binary'),
                                  ],
                                  onChanged: (value) {
                                    final currentFilters =
                                        Map<String, String?>.from(
                                      ref
                                          .read(responsesFilterProvider(
                                              survey.id))
                                          .parameterFilters,
                                    );
                                    currentFilters['sex'] = value;
                                    ref
                                            .read(responsesFilterProvider(
                                                    survey.id)
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
                            ),
                          ...survey.parameters.map((param) {
                            if (param['type'] == 'binary') {
                              return Padding(
                                padding: EdgeInsets.only(
                                    right: Foundations.spacing.sm),
                                child: SizedBox(
                                  width: 140,
                                  child: BaseSelect<String?>(
                                    hint: _formatParameterName(param['name']),
                                    size: SelectSize.small,
                                    value: ref
                                        .watch(
                                            responsesFilterProvider(survey.id))
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
                                            .read(responsesFilterProvider(
                                                survey.id))
                                            .parameterFilters,
                                      );
                                      currentFilters[param['name']] = value;
                                      ref
                                              .read(responsesFilterProvider(
                                                      survey.id)
                                                  .notifier)
                                              .state =
                                          ref
                                              .read(responsesFilterProvider(
                                                  survey.id))
                                              .copyWith(
                                                parameterFilters:
                                                    currentFilters,
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
                              padding: EdgeInsets.only(
                                  right: Foundations.spacing.sm),
                              child: SizedBox(
                                width: 140,
                                child: BaseSelect<String?>(
                                  hint: _formatParameterName(param['name']),
                                  size: SelectSize.small,
                                  searchable: true,
                                  value: ref
                                      .watch(responsesFilterProvider(survey.id))
                                      .parameterFilters[param['name']],
                                  options: [
                                    SelectOption(value: null, label: 'All'),
                                    ...uniqueValues.map((v) => SelectOption(
                                        value: v,
                                        label: _formatParameterName(v!))),
                                  ],
                                  onChanged: (value) {
                                    final currentFilters =
                                        Map<String, String?>.from(
                                      ref
                                          .read(responsesFilterProvider(
                                              survey.id))
                                          .parameterFilters,
                                    );
                                    currentFilters[param['name']] = value;
                                    ref
                                            .read(responsesFilterProvider(
                                                    survey.id)
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
                          }),
                          BaseIconButton(
                            icon: Icons.clear_all,
                            onPressed: () {
                              ref
                                  .read(responsesFilterProvider(survey.id)
                                      .notifier)
                                  .state = const ResponsesFilterState();
                            },
                            tooltip: 'Clear filters',
                            variant: IconButtonVariant.outlined,
                            size: IconButtonSize.small,
                          ),
                        ],
                      ),
                    ),
                  ])),
              // Conditional content based on responses
              if (responses.isEmpty)
                _buildEmptyResponsesContent(context, isDarkMode,
                    hasAnyResponses, accentColor, survey, ref)
              else
                _buildResponsesTableContent(
                    context, ref, isDarkMode, survey, paginatedResponses)
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }

  Widget _buildEmptyResponsesContent(
      BuildContext context,
      bool isDarkMode,
      bool hasAnyResponses,
      Color accentColor,
      SortingSurvey survey,
      WidgetRef ref) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(Foundations.spacing.xl2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: isDarkMode
                  ? Foundations.darkColors.textMuted
                  : Foundations.colors.textMuted,
            ),
            SizedBox(height: Foundations.spacing.lg),
            Text(
              hasAnyResponses
                  ? 'No responses match the current filters'
                  : 'No responses yet',
              style: TextStyle(
                fontSize: Foundations.typography.xl,
                fontWeight: Foundations.typography.semibold,
                color: isDarkMode
                    ? Foundations.darkColors.textPrimary
                    : Foundations.colors.textPrimary,
              ),
            ),
            SizedBox(height: Foundations.spacing.md),
            Text(
              hasAnyResponses
                  ? 'Try adjusting your filters to see more responses'
                  : (survey.status == SortingSurveyStatus.draft
                      ? 'Publish the survey to start collecting responses'
                      : 'Start by adding responses manually or importing from a file'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: Foundations.typography.base,
                color: isDarkMode
                    ? Foundations.darkColors.textMuted
                    : Foundations.colors.textMuted,
              ),
            ),
            SizedBox(height: Foundations.spacing.xl),
            if (hasAnyResponses)
              BaseButton(
                label: 'Clear Filters',
                prefixIcon: Icons.clear_all,
                variant: ButtonVariant.outlined,
                onPressed: () {
                  ref.read(responsesFilterProvider(survey.id).notifier).state =
                      const ResponsesFilterState();
                },
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (survey.status == SortingSurveyStatus.draft) ...[
                    BaseButton(
                      label: 'Publish Survey',
                      prefixIcon: Icons.publish_outlined,
                      variant: ButtonVariant.filled,
                      onPressed: () async {
                        await ref
                            .read(sortingSurveyNotifierProvider.notifier)
                            .publishSortingSurvey(survey.id);

                        // Invalidate providers to force refresh
                        ref.invalidate(
                            selectedSortingSurveyProvider(survey.id));
                        ref.invalidate(getSortingSurveyByIdProvider);

                        if (context.mounted) {
                          Toaster.success(
                              context, 'Survey published successfully');
                        }
                      },
                    ),
                  ] else ...[
                    BaseButton(
                      label: 'Add Manually',
                      prefixIcon: Icons.person_add_outlined,
                      variant: ButtonVariant.outlined,
                      onPressed: () => _addUserManually(
                        context,
                        ref,
                        isDarkMode,
                        accentColor,
                        survey,
                      ),
                    ),
                    SizedBox(width: Foundations.spacing.md),
                    BaseButton(
                      label: 'Import Responses',
                      prefixIcon: Icons.upload_file_outlined,
                      variant: ButtonVariant.outlined,
                      onPressed: () => _showImportDialog(context, ref, survey),
                    ),
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildResponsesTableContent(
      BuildContext context,
      WidgetRef ref,
      bool isDarkMode,
      SortingSurvey survey,
      List<MapEntry<String, Map<String, dynamic>>> paginatedResponses) {
    final accentColor = ref.watch(appThemeProvider).accentLight;
    final horizontalScrollController = ScrollController();

    return Column(
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(
            maxHeight: 600,
            minHeight: 200,
          ),
          child: Scrollbar(
            thumbVisibility: true,
            controller: horizontalScrollController,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              controller: horizontalScrollController,
              child: DataTable(
                columns: [
                  DataColumn(label: Text('Name')),
                  if (survey.askBiologicalSex) DataColumn(label: Text('Sex')),
                  ...survey.parameters.map(
                    (param) => DataColumn(
                      label: Text(_formatParameterName(param['name'])),
                    ),
                  ),
                  if (survey.maxPreferences != null)
                    DataColumn(label: Text('Preferences')),
                  DataColumn(label: Text('Actions')), // Add actions column
                ],
                rows: paginatedResponses.map((entry) {
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
                      if (survey.maxPreferences != null)
                        _buildPreferencesCell(
                          context,
                          (response['prefs'] as List?)?.cast<String>() ?? [],
                          isDarkMode,
                          accentColor,
                        ),
                      DataCell(Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          BaseIconButton(
                            icon: Icons.edit_outlined,
                            onPressed: () => _editResponse(
                              context,
                              ref,
                              isDarkMode,
                              accentColor,
                              entry.key,
                              survey,
                              entry.value,
                            ),
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
                                dangerous: true,
                                confirmText:
                                    AppLocalizations.of(context)!.globalDelete,
                              );
                              if (confirmed != null && confirmed) {
                                ref
                                    .read(
                                        sortingSurveyNotifierProvider.notifier)
                                    .deleteResponse(survey.id, entry.key);
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
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(Foundations.spacing.md),
          child: Pagination(
            paginationKey: 'responses_${survey.id}',
            isDarkMode: isDarkMode,
            itemsPerPageOptions: const [10, 25, 50, 100],
          ),
        ),
      ],
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
    final displayValue =
        isSexParameter ? _formatSex(value) : _formatParameterName(value);

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
          displayValue,
          style: TextStyle(color: color),
        ),
      ),
    );
  }

  DataCell _buildPreferencesCell(BuildContext context, List<String> prefs,
      bool isDarkMode, Color accentColor) {
    if (prefs.isEmpty) {
      return const DataCell(Text('-'));
    }

    return DataCell(
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('${prefs.length} selected'),
          SizedBox(width: Foundations.spacing.xs),
          Consumer(builder: (context, ref, _) {
            final allUsers = ref.watch(allUsersStreamProvider).value ?? [];

            return BaseIconButton(
              icon: Icons.visibility_outlined,
              variant: IconButtonVariant.ghost,
              size: IconButtonSize.small,
              tooltip: 'View preferences',
              onPressed: () {
                Dialogs.show(
                  context: context,
                  title: 'Preferences',
                  width: 400,
                  variant: DialogVariant.info,
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...prefs.asMap().entries.map((entry) {
                        final index = entry.key + 1;
                        final prefId = entry.value;
                        // Get user name from response or users list
                        final prefResponse = survey.responses[prefId];

                        // Get name either from manual entry or users stream
                        String userName;
                        if (prefResponse?['_manual_entry'] == true) {
                          userName =
                              '${prefResponse['_first_name']} ${prefResponse['_last_name']}';
                        } else {
                          final user = allUsers.firstWhere(
                            (u) => u.id == prefId,
                            orElse: () => AppUser(
                              id: prefId,
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
                          userName = '${user.firstName} ${user.lastName}';
                        }

                        return Padding(
                          padding:
                              EdgeInsets.only(bottom: Foundations.spacing.sm),
                          child: Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: accentColor.withValues(alpha: 0.1),
                                  borderRadius: Foundations.borders.full,
                                ),
                                child: Center(
                                  child: Text(
                                    '$index',
                                    style: TextStyle(
                                      color: accentColor,
                                      fontSize: Foundations.typography.sm,
                                      fontWeight: Foundations.typography.medium,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: Foundations.spacing.sm),
                              Text(
                                userName,
                                style: TextStyle(
                                  color: isDarkMode
                                      ? Foundations.darkColors.textPrimary
                                      : Foundations.colors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                );
              },
            );
          }),
        ],
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

  void _viewAllDialog(BuildContext context, String paramName, bool isDarkMode) {
    final responses = survey.responses;
    final isBinary = survey.parameters
        .any((p) => p['name'] == paramName && p['type'] == 'binary');
    final isSexParameter = paramName == 'sex';

    // Build distribution map
    Map<String, int> distribution = {};
    for (final response in responses.values) {
      final rawValue = response[paramName]?.toString() ?? 'Unknown';

      // Format value based on parameter type
      final formattedValue = switch (true) {
        _ when isSexParameter => _formatSex(rawValue),
        _ when isBinary => rawValue.toLowerCase() == 'yes' ? 'Yes' : 'No',
        _ => _formatDisplayValue(rawValue),
      };

      distribution[formattedValue] = (distribution[formattedValue] ?? 0) + 1;
    }

    // Sort entries by count
    final sortedEntries = distribution.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final total = distribution.values.fold(0, (sum, count) => sum + count);
    final uniqueCount = distribution.length;

    Dialogs.show(
      context: context,
      title: _formatDisplayValue(paramName),
      width: 400,
      variant: DialogVariant.info,
      scrollable: true,
      content: Column(
        children: [
          // Header
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  'Value',
                  style: TextStyle(
                    fontWeight: Foundations.typography.semibold,
                    color: isDarkMode
                        ? Foundations.darkColors.textPrimary
                        : Foundations.colors.textPrimary,
                  ),
                ),
              ),
              Text(
                'Count',
                style: TextStyle(
                  fontWeight: Foundations.typography.semibold,
                  color: isDarkMode
                      ? Foundations.darkColors.textPrimary
                      : Foundations.colors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: Foundations.spacing.md),

          // Distribution bars
          ...sortedEntries.map((entry) {
            final percentage = total > 0 ? (entry.value / total * 100) : 0;
            final color = ColorGenerator.getColor(
              paramName,
              entry.key,
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
                        entry.key,
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

          // Total count
          Divider(
            color: isDarkMode
                ? Foundations.darkColors.border
                : Foundations.colors.border,
          ),
          SizedBox(height: Foundations.spacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Unique Values: $uniqueCount',
                style: TextStyle(
                  fontWeight: Foundations.typography.medium,
                  color: isDarkMode
                      ? Foundations.darkColors.textPrimary
                      : Foundations.colors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAllResponses(
      BuildContext context, WidgetRef ref, SortingSurvey survey) async {
    // Show confirmation dialog
    final bool? confirmed = await Dialogs.confirm(
      context: context,
      title: 'Delete All Responses',
      message:
          'Are you sure you want to delete all responses? This action cannot be undone.',
      variant: DialogVariant.danger,
      dangerous: true,
      confirmText: 'Delete All',
    );

    if (confirmed == true) {
      // Update survey with empty responses
      await ref
          .read(sortingSurveyNotifierProvider.notifier)
          .deleteAllResponses(survey.id);
      if (context.mounted) {
        Toaster.success(context, 'All responses deleted successfully');
      }
    }
  }

  void _addUserManually(BuildContext context, WidgetRef ref, bool isDarkMode,
      Color accentColor, SortingSurvey survey) {
    final users = ref.watch(allUsersStreamProvider).value ?? [];
    final responses = ref.watch(filteredResponsesProvider(survey.id));

    // States for the form
    bool isManualEntry = true;
    String? selectedUserId;
    final manualFirstNameController = TextEditingController();
    final manualLastNameController = TextEditingController();
    Map<String, dynamic> parameterResponses = {};
    String? selectedSex;
    List<String> selectedPreferences = [];

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
      form: responses.when(
        data: (responses) {
          return StatefulBuilder(
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
                  if (survey.maxPreferences != null) ...[
                    SizedBox(height: Foundations.spacing.lg),
                    BaseMultiSelect<String>(
                      label: 'Preferences',
                      hint: 'Select preferences',
                      description:
                          'Select up to ${survey.maxPreferences} preferred users',
                      searchable: true,
                      values: selectedPreferences,
                      options: survey.responses.entries.map((e) {
                        // Get name either from manual entry or users stream
                        if (e.value['_manual_entry'] == true) {
                          return SelectOption(
                            value: e.key,
                            label:
                                '${e.value['_first_name']} ${e.value['_last_name']}',
                          );
                        } else {
                          // Find user from stream
                          final allUsers =
                              ref.watch(allUsersStreamProvider).value ?? [];
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
                        if (values.length <= survey.maxPreferences!) {
                          setState(() => selectedPreferences = values);
                        }
                      },
                      maxChipsVisible: 2,
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
                        padding:
                            EdgeInsets.only(bottom: Foundations.spacing.md),
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
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Center(
          child: Text('Error: $error'),
        ),
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
              'prefs': selectedPreferences,
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

            // Update survey
            ref
                .read(sortingSurveyNotifierProvider.notifier)
                .addResponse(survey.id, responseId, response);
            dispose();
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  void _editResponse(
    BuildContext context,
    WidgetRef ref,
    bool isDarkMode,
    Color accentColor,
    String responseId,
    SortingSurvey survey,
    Map<String, dynamic> response,
  ) {
    // Initialize controllers with existing data
    final manualFirstNameController = TextEditingController(
      text: response['_first_name'] ?? '',
    );
    final manualLastNameController = TextEditingController(
      text: response['_last_name'] ?? '',
    );
    final isManualEntry = response['_manual_entry'] == true;
    String? selectedSex = response['sex'];
    List<String> selectedPreferences =
        (response['prefs'] as List?)?.cast<String>() ?? [];

    final parameterControllers = {
      for (var param in survey.parameters)
        if (param['type'] != 'binary')
          param['name']: TextEditingController(
            text:
                _formatParameterName(response[param['name']]?.toString() ?? ''),
          )
    };

    Map<String, dynamic> parameterResponses = {
      for (var param in survey.parameters)
        param['name']: param['type'] == 'binary'
            ? response[param['name']]?.toString() ?? ''
            : response[param['name']]?.toString() ?? '',
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
      title: 'Edit Response',
      width: 600,
      variant: DialogVariant.default_,
      form: StatefulBuilder(
        builder: (context, setState) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name fields
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

              // Preferences selection
              if (survey.maxPreferences != null) ...[
                SizedBox(height: Foundations.spacing.lg),
                BaseMultiSelect<String>(
                  label: 'Preferences',
                  hint: 'Select preferences',
                  description:
                      'Select up to ${survey.maxPreferences} preferred users',
                  searchable: true,
                  values: selectedPreferences,
                  options: survey.responses.entries
                      .where((e) =>
                          e.key != responseId) // Exclude current response
                      .map((e) {
                    if (e.value['_manual_entry'] == true) {
                      return SelectOption(
                        value: e.key,
                        label:
                            '${e.value['_first_name']} ${e.value['_last_name']}',
                      );
                    } else {
                      final allUsers =
                          ref.watch(allUsersStreamProvider).value ?? [];
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
                    if (values.length <= survey.maxPreferences!) {
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
          label: 'Save Changes',
          variant: ButtonVariant.filled,
          onPressed: () {
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

            // Format categorical values
            final formattedResponses =
                Map<String, dynamic>.from(parameterResponses);
            for (var param in survey.parameters) {
              if (param['type'] != 'binary') {
                final value = parameterControllers[param['name']]?.text ?? '';
                formattedResponses[param['name']] =
                    _formatCategoricalValue(value);
              }
            }

            // Create updated response data
            final updatedResponse = {
              ...response, // Keep existing data
              ...formattedResponses,
              if (survey.askBiologicalSex) 'sex': selectedSex,
              if (survey.maxPreferences != null) 'prefs': selectedPreferences,
            };

            // Update manual entry fields if applicable
            if (isManualEntry) {
              updatedResponse['_first_name'] = manualFirstNameController.text;
              updatedResponse['_last_name'] = manualLastNameController.text;
            }

            ref
                .read(sortingSurveyNotifierProvider.notifier)
                .updateResponse(survey.id, responseId, updatedResponse);
            dispose();
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  void _showImportDialog(
      BuildContext context, WidgetRef ref, SortingSurvey survey) {
    Dialogs.show(
      context: context,
      title: 'Import Responses',
      scrollable: true,
      width: 800,
      variant: DialogVariant.default_,
      content: ImportResponsesDialog(survey: survey),
      actions: [
        Consumer(builder: (context, ref, _) {
          return BaseButton(
            label: 'Cancel',
            variant: ButtonVariant.text,
            onPressed: () {
              Navigator.of(context).pop();
            },
          );
        }),
        Consumer(
          builder: (context, ref, _) {
            final importState = ref.watch(responseImportProvider);

            return BaseButton(
              label: 'Import',
              variant: ButtonVariant.filled,
              isLoading: importState.isLoading,
              onPressed: importState.previewData == null
                  ? null
                  : () async {
                      await ref
                          .read(responseImportProvider.notifier)
                          .confirmImport(survey);
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
            );
          },
        ),
      ],
    ).then((_) {
      ref.read(responseImportProvider.notifier).reset();
    });
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
