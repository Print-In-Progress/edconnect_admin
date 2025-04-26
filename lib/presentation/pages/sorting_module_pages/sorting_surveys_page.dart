import 'package:edconnect_admin/core/design_system/foundations.dart';
import 'package:edconnect_admin/core/errors/domain_exception.dart';
import 'package:edconnect_admin/core/routing/app_router.dart';
import 'package:edconnect_admin/domain/entities/sorting_survey.dart';
import 'package:edconnect_admin/presentation/providers/state_providers.dart';
import 'package:edconnect_admin/presentation/providers/theme_provider.dart';
import 'package:edconnect_admin/presentation/widgets/common/buttons/base_button.dart';
import 'package:edconnect_admin/presentation/widgets/common/cards/base_card.dart';
import 'package:edconnect_admin/presentation/widgets/common/chips.dart';
import 'package:edconnect_admin/presentation/widgets/common/dropdown/single_select_dropdown.dart';
import 'package:edconnect_admin/presentation/widgets/common/input/base_input.dart';
import 'package:edconnect_admin/presentation/widgets/common/navigation/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class SortingSurveysPage extends ConsumerWidget {
  const SortingSurveysPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterState = ref.watch(surveyFilterProvider);
    final surveysAsync = ref.watch(filteredSortingSurveysProvider);
    final theme = ref.watch(appThemeProvider);

    return Scaffold(
      backgroundColor: theme.isDarkMode
          ? Foundations.darkColors.background
          : Foundations.colors.background,
      body: Column(
        children: [
          BaseAppBar(
            title: 'Sorting Surveys',
            actions: [
              BaseButton(
                label: 'Create Survey',
                prefixIcon: Icons.add,
                variant: ButtonVariant.filled,
                onPressed: () => AppRouter.toCreateSortingSurvey(context),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.all(Foundations.spacing.lg),
            child: Row(
              children: [
                Expanded(
                  child: BaseInput(
                    leadingIcon: Icons.search,
                    hint: 'Search surveys...',
                    onChanged: (value) {
                      ref.read(surveyFilterProvider.notifier).state =
                          filterState.copyWith(searchQuery: value);
                    },
                  ),
                ),
                SizedBox(width: Foundations.spacing.md),
                SizedBox(
                  width: 160,
                  child: BaseSelect<SortingSurveyStatus?>(
                    value: filterState.statusFilter,
                    options: _buildStatusOptions(),
                    hint: 'Filter Status',
                    leadingIcon: Icons.filter_list,
                    size: SelectSize.medium,
                    variant: SelectVariant.outlined,
                    onChanged: (value) {
                      ref.read(surveyFilterProvider.notifier).state =
                          filterState.copyWith(
                              statusFilter: value,
                              clearStatusFilter: value == null);
                    },
                  ),
                ),
                SizedBox(width: Foundations.spacing.md),
                SizedBox(
                  width: 160,
                  child: BaseSelect<SurveySortOrder>(
                    value: filterState.sortOrder,
                    options: _buildSortOptions(),
                    hint: 'Sort By',
                    leadingIcon: Icons.sort,
                    size: SelectSize.medium,
                    variant: SelectVariant.outlined,
                    onChanged: (value) {
                      if (value != null) {
                        ref.read(surveyFilterProvider.notifier).state =
                            filterState.copyWith(sortOrder: value);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: surveysAsync.when(
              data: (surveys) => surveys.isEmpty
                  ? _buildEmptyState()
                  : _buildSurveyList(surveys, ref),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Foundations.colors.error,
                      ),
                      SizedBox(height: Foundations.spacing.md),
                      if (error is DomainException) ...[
                        Text(
                          _getErrorMessage(error),
                          style: TextStyle(
                            fontSize: Foundations.typography.lg,
                            fontWeight: Foundations.typography.semibold,
                            color: theme.isDarkMode
                                ? Foundations.darkColors.textPrimary
                                : Foundations.colors.textPrimary,
                          ),
                        ),
                        if (error.originalError != null) ...[
                          SizedBox(height: Foundations.spacing.sm),
                          Text(
                            error.originalError.toString(),
                            style: TextStyle(
                              fontSize: Foundations.typography.sm,
                              color: theme.isDarkMode
                                  ? Foundations.darkColors.textSecondary
                                  : Foundations.colors.textSecondary,
                            ),
                          ),
                        ],
                      ] else ...[
                        Text(
                          'An unexpected error occurred',
                          style: TextStyle(
                            fontSize: Foundations.typography.lg,
                            fontWeight: Foundations.typography.semibold,
                            color: theme.isDarkMode
                                ? Foundations.darkColors.textPrimary
                                : Foundations.colors.textPrimary,
                          ),
                        ),
                        SizedBox(height: Foundations.spacing.sm),
                        Text(
                          error.toString(),
                          style: TextStyle(
                            fontSize: Foundations.typography.sm,
                            color: theme.isDarkMode
                                ? Foundations.darkColors.textSecondary
                                : Foundations.colors.textSecondary,
                          ),
                        ),
                      ],
                      SizedBox(height: Foundations.spacing.lg),
                      BaseButton(
                        label: 'Retry',
                        prefixIcon: Icons.refresh,
                        variant: ButtonVariant.outlined,
                        onPressed: () {
                          // Invalidate the provider to trigger a refresh
                          ref.invalidate(sortingSurveysProvider);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<SelectOption<SortingSurveyStatus?>> _buildStatusOptions() {
    return [
      const SelectOption(
        value: null,
        label: 'All',
        icon: Icons.filter_list_off,
      ),
      ...SortingSurveyStatus.values.map((status) {
        IconData icon;
        switch (status) {
          case SortingSurveyStatus.draft:
            icon = Icons.edit_outlined;
            break;
          case SortingSurveyStatus.published:
            icon = Icons.public_outlined;
            break;
          case SortingSurveyStatus.closed:
            icon = Icons.lock_outlined;
            break;
        }
        return SelectOption(
          value: status,
          label: status.name.toUpperCase(),
          icon: icon,
        );
      }),
    ];
  }

  List<SelectOption<SurveySortOrder>> _buildSortOptions() {
    return SurveySortOrder.values.map((order) {
      IconData icon;
      String label;
      switch (order) {
        case SurveySortOrder.newestFirst:
          icon = Icons.arrow_downward;
          label = 'Newest First';
          break;
        case SurveySortOrder.oldestFirst:
          icon = Icons.arrow_upward;
          label = 'Oldest First';
          break;
        case SurveySortOrder.alphabetical:
          icon = Icons.sort_by_alpha;
          label = 'Alphabetical';
          break;
        case SurveySortOrder.status:
          icon = Icons.filter_list;
          label = 'By Status';
          break;
      }
      return SelectOption(
        value: order,
        label: label,
        icon: icon,
      );
    }).toList();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.ballot_outlined,
            size: 64,
            color: Foundations.colors.textMuted,
          ),
          SizedBox(height: Foundations.spacing.md),
          Text(
            'No surveys found',
            style: TextStyle(
              fontSize: Foundations.typography.lg,
              color: Foundations.colors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSurveyList(List<SortingSurvey> surveys, WidgetRef ref) {
    return ListView.separated(
      padding: EdgeInsets.all(Foundations.spacing.lg),
      itemCount: surveys.length,
      separatorBuilder: (_, __) => SizedBox(height: Foundations.spacing.md),
      itemBuilder: (context, index) {
        final survey = surveys[index];
        return _SurveyCard(survey: survey);
      },
    );
  }

  String _getErrorMessage(DomainException error) {
    return error.originalError;
  }
}

class _SurveyCard extends ConsumerWidget {
  final SortingSurvey survey;

  const _SurveyCard({required this.survey});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeProvider);

    return BaseCard(
      variant: CardVariant.outlined,
      isSelectable: true,
      onTap: () {
        ref.read(selectedSortingSurveyIdProvider.notifier).state = survey.id;

        // Trigger response prefetch
        ref.read(sortingSurveyResponsesPrefetchProvider(survey.id));

        // Navigate to details
        AppRouter.toSortingSurveyDetails(context, surveyId: survey.id);
      },
      child: Padding(
        padding: EdgeInsets.all(Foundations.spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    survey.title,
                    style: TextStyle(
                      fontSize: Foundations.typography.lg,
                      fontWeight: Foundations.typography.semibold,
                      color: theme.isDarkMode
                          ? Foundations.darkColors.textPrimary
                          : Foundations.colors.textPrimary,
                    ),
                  ),
                ),
                _buildStatusChip(survey.status),
              ],
            ),
            if (survey.description.isNotEmpty) ...[
              SizedBox(height: Foundations.spacing.sm),
              Text(
                survey.description,
                style: TextStyle(
                  color: theme.isDarkMode
                      ? Foundations.darkColors.textSecondary
                      : Foundations.colors.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            SizedBox(height: Foundations.spacing.lg),
            Row(
              children: [
                Icon(
                  Icons.person_outline,
                  size: 16,
                  color: Foundations.colors.textMuted,
                ),
                SizedBox(width: Foundations.spacing.xs),
                Text(
                  survey.creatorName,
                  style: TextStyle(
                    color: Foundations.colors.textMuted,
                    fontSize: Foundations.typography.sm,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: Foundations.colors.textMuted,
                ),
                SizedBox(width: Foundations.spacing.xs),
                Text(
                  DateFormat('MMM d, yyyy').format(survey.createdAt),
                  style: TextStyle(
                    color: Foundations.colors.textMuted,
                    fontSize: Foundations.typography.sm,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
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
}
