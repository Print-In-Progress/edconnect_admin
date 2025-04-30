import 'package:edconnect_admin/core/design_system/foundations.dart';
import 'package:edconnect_admin/domain/entities/sorting_survey.dart';
import 'package:edconnect_admin/presentation/pages/sorting_module_pages/tabs/sorting_survey_calculate_tab.dart';
import 'package:edconnect_admin/presentation/pages/sorting_module_pages/tabs/sorting_survey_overview_tab.dart';
import 'package:edconnect_admin/presentation/pages/sorting_module_pages/tabs/sorting_survey_responses_tab.dart';
import 'package:edconnect_admin/presentation/pages/sorting_module_pages/tabs/sorting_survey_results_tab.dart';
import 'package:edconnect_admin/presentation/providers/action_providers.dart';
import 'package:edconnect_admin/presentation/providers/state_providers.dart';
import 'package:edconnect_admin/presentation/providers/theme_provider.dart';
import 'package:edconnect_admin/presentation/widgets/common/buttons/base_button.dart';
import 'package:edconnect_admin/presentation/widgets/common/cards/base_card.dart';
import 'package:edconnect_admin/presentation/widgets/common/dialogs/dialogs.dart';
import 'package:edconnect_admin/presentation/widgets/common/loading_indicators/async_value_widget.dart';
import 'package:edconnect_admin/presentation/widgets/common/navigation/app_bar.dart';
import 'package:edconnect_admin/presentation/widgets/common/navigation/tabs.dart';
import 'package:edconnect_admin/presentation/widgets/common/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// TODO: Display Toasts after action is completed

class SortingSurveyDetailsPage extends ConsumerWidget {
  final String surveyId;
  const SortingSurveyDetailsPage({super.key, required this.surveyId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeProvider);
    final isInitialLoading = ref.watch(surveyLoadingStateProvider);
    final notifierState = ref.watch(sortingSurveyNotifierProvider);

    // Only watch the survey data if not in initial loading state
    final surveyAsync = isInitialLoading
        ? const AsyncValue<SortingSurvey?>.loading()
        : ref.watch(selectedSortingSurveyProvider(surveyId));

    if (isInitialLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(surveyLoadingStateProvider.notifier).state = false;
      });
    }

    return Scaffold(
      backgroundColor: theme.isDarkMode
          ? Foundations.darkColors.background
          : Foundations.colors.background,
      appBar: BaseAppBar(
        title: isInitialLoading
            ? 'Loading Survey...'
            : surveyAsync.when(
                data: (survey) => survey?.title ?? 'Survey not found',
                loading: () => 'Loading Survey...',
                error: (_, __) => 'Error',
              ),
        showLeading: true,
        // Show skeleton buttons during loading
        actions: isInitialLoading
            ? [
                Container(
                  width: 100,
                  height: 36,
                  margin: EdgeInsets.only(right: Foundations.spacing.md),
                  decoration: BoxDecoration(
                    color: theme.isDarkMode
                        ? Foundations.darkColors.surfaceActive
                        : Foundations.colors.surfaceActive,
                    borderRadius: Foundations.borders.md,
                  ),
                ),
              ]
            : surveyAsync.when(
                data: (survey) =>
                    _buildActions(context, ref, survey, notifierState),
                loading: () => [
                  Container(
                    width: 100,
                    height: 36,
                    margin: EdgeInsets.only(right: Foundations.spacing.md),
                    decoration: BoxDecoration(
                      color: theme.isDarkMode
                          ? Foundations.darkColors.surfaceActive
                          : Foundations.colors.surfaceActive,
                      borderRadius: Foundations.borders.md,
                    ),
                  ),
                ],
                error: (_, __) => [],
              ),
      ),
      body: isInitialLoading
          ? _buildSkeletonContent(context, ref)
          : AsyncValueWidget(
              value: surveyAsync,
              skipLoadingOnRefresh: true,
              loading: () => _buildSkeletonContent(context, ref),
              data: (survey) {
                if (survey == null) {
                  return const Center(child: Text('Survey not found'));
                }
                return _buildContent(context, ref, survey);
              },
              error: (error, stackTrace) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error: $error'),
                    ElevatedButton(
                      onPressed: () => ref
                          .invalidate(selectedSortingSurveyProvider(surveyId)),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  List<Widget> _buildActions(BuildContext context, WidgetRef ref,
      SortingSurvey? survey, notifierState) {
    if (survey == null) return [];

    return [
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
          onPressed: () => _closeSortingSurvey(context, ref, survey.id),
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
    ];
  }

  Widget _buildContent(
      BuildContext context, WidgetRef ref, SortingSurvey survey) {
    final tabIndex = ref.watch(surveyTabIndexProvider(survey.id));

    return Padding(
      padding: EdgeInsets.all(Foundations.spacing.lg),
      child: Tabs(
          onChanged: (index) {
            ref.read(surveyTabIndexProvider(survey.id).notifier).state = index;
          },
          currentValue: tabIndex,
          tabs: [
            TabItem(
              label: 'Overview',
              icon: Icons.info_outline,
              content: OverviewTab(survey: survey),
            ),
            TabItem(
              label: 'Responses',
              icon: Icons.list_alt_outlined,
              content: ResponsesTab(survey: survey),
            ),
            TabItem(
              label: 'Calculate',
              icon: Icons.calculate_outlined,
              content: CalculateTab(survey: survey),
            ),
            TabItem(
              label: 'Results',
              icon: Icons.pie_chart_outline,
              content: ResultsTab(survey: survey),
            ),
          ]),
    );
  }

  Future<void> _publishSurvey(
      BuildContext context, WidgetRef ref, String id) async {
    await ref
        .read(sortingSurveyNotifierProvider.notifier)
        .publishSortingSurvey(id);

    if (context.mounted) {
      Toaster.success(context, 'Survey published successfully');
    }
  }

  Future<void> _closeSortingSurvey(
      BuildContext context, WidgetRef ref, String id) async {
    await ref
        .read(sortingSurveyNotifierProvider.notifier)
        .closeSortingSurvey(id);

    if (context.mounted) {
      Toaster.success(context, 'Survey closed successfully');
    }
  }

  Future<void> _deleteSurvey(
      BuildContext context, WidgetRef ref, String id) async {
    // Show confirmation dialog
    final bool? confirmed = await Dialogs.confirm(
        context: context,
        title: 'Delete Survey',
        message: 'Are you sure you want to delete this survey?',
        dangerous: true);
    if (confirmed == null || !confirmed) return;

    if (confirmed == true) {
      if (!context.mounted) return;
      Navigator.pop(context);

      await ref
          .read(sortingSurveyNotifierProvider.notifier)
          .deleteSortingSurvey(id);
      Future.microtask(() {
        if (context.mounted) {
          Toaster.success(context, 'Survey deleted successfully');
        }
      });
    }
  }
}

Widget _buildSkeletonContent(BuildContext context, WidgetRef ref) {
  final theme = ref.watch(appThemeProvider);
  final isDarkMode = theme.isDarkMode;

  return Padding(
    padding: EdgeInsets.all(Foundations.spacing.lg),
    child: Column(
      children: [
        // Tabs skeleton
        Container(
          height: 40,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isDarkMode
                    ? Foundations.darkColors.border
                    : Foundations.colors.border,
              ),
            ),
          ),
          child: Row(
            children: List.generate(4, (index) {
              return Padding(
                padding: EdgeInsets.only(right: Foundations.spacing.md),
                child: Container(
                  width: 120,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? Foundations.darkColors.surfaceActive
                        : Foundations.colors.surfaceActive,
                    borderRadius: Foundations.borders.md,
                  ),
                ),
              );
            }),
          ),
        ),
        SizedBox(height: Foundations.spacing.lg),

        // Content skeleton
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Section headers
                _buildSkeletonSection(isDarkMode),
                SizedBox(height: Foundations.spacing.lg),

                // Info cards
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: _buildSkeletonCard(
                        isDarkMode,
                        itemCount: 6,
                      ),
                    ),
                    SizedBox(width: Foundations.spacing.lg),
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          _buildSkeletonCard(
                            isDarkMode,
                            itemCount: 2,
                          ),
                          SizedBox(height: Foundations.spacing.lg),
                          _buildSkeletonCard(
                            isDarkMode,
                            itemCount: 4,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildSkeletonSection(bool isDarkMode) {
  return Container(
    height: 24,
    width: 200,
    decoration: BoxDecoration(
      color: isDarkMode
          ? Foundations.darkColors.surfaceActive
          : Foundations.colors.surfaceActive,
      borderRadius: Foundations.borders.md,
    ),
  );
}

Widget _buildSkeletonCard(bool isDarkMode, {required int itemCount}) {
  return BaseCard(
    variant: CardVariant.outlined,
    child: Padding(
      padding: EdgeInsets.all(Foundations.spacing.lg),
      child: Column(
        children: List.generate(itemCount, (index) {
          return Column(
            children: [
              Container(
                height: 20,
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? Foundations.darkColors.surfaceActive
                      : Foundations.colors.surfaceActive,
                  borderRadius: Foundations.borders.md,
                ),
              ),
              if (index < itemCount - 1)
                Divider(
                  height: Foundations.spacing.xl,
                  color: isDarkMode
                      ? Foundations.darkColors.border
                      : Foundations.colors.border,
                ),
            ],
          );
        }),
      ),
    ),
  );
}
// responses = [
//     "uid1": {
//         "sex": "m",
//         "prefs": ["uid2", "uid3"],
//         "special_needs": "no", 
//         "elementary_school": "Washington"
//         // other parameters
//     },
//     "uid2": {
//         "sex": "f",
//         "prefs": ["uid1", "uid3"],
//         "special_needs": "yes",
//         "elementary_school": "Lincoln"
//         // other parameters
//     },
//     "uid3": {
//         "sex": "nb",
//         "prefs": ["uid1", "uid5"],
//         "special_needs": "no",
//         "elementary_school": "Washington"
//         // other parameters
//     }
//     "manual_uid": {
//       "sex": "m",
//       "prefs": ["uid1", "uid2"],
//       "special_needs": "no",
//       "elementary_school": "Washington"
//       "_first_name": "John",
//       "_last_name": "Doe",
//       "_manual_entry": true,
//       // other parameters
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