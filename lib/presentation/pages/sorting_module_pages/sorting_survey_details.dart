import 'package:edconnect_admin/core/design_system/foundations.dart';
import 'package:edconnect_admin/domain/entities/sorting_survey.dart';
import 'package:edconnect_admin/presentation/pages/sorting_module_pages/sorting_survey_overview_tab.dart';
import 'package:edconnect_admin/presentation/pages/sorting_module_pages/sorting_survey_responses_tab.dart';
import 'package:edconnect_admin/presentation/providers/action_providers.dart';
import 'package:edconnect_admin/presentation/providers/state_providers.dart';
import 'package:edconnect_admin/presentation/providers/theme_provider.dart';
import 'package:edconnect_admin/presentation/widgets/common/buttons/base_button.dart';
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
    final notifierState = ref.watch(sortingSurveyNotifierProvider);
    final surveyAsync = ref.watch(selectedSortingSurveyProvider(surveyId));

    return surveyAsync.when(
      data: (survey) {
        if (survey == null) {
          return const Center(child: Text('Survey not found'));
        }
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
          body: _buildContent(context, ref, survey),
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stack) => Center(
        child: Text('Error: $error'),
      ),
    );
  }

  Widget _buildContent(
      BuildContext context, WidgetRef ref, SortingSurvey survey) {
    return Padding(
      padding: EdgeInsets.all(Foundations.spacing.lg),
      child: Tabs(tabs: [
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
      Future.microtask(() {
        if (context.mounted) {
          Toaster.success(context, 'Survey deleted successfully');
        }
      });
    }
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