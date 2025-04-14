import 'package:edconnect_admin/core/design_system/foundations.dart';
import 'package:edconnect_admin/domain/entities/sorting_survey.dart';
import 'package:edconnect_admin/presentation/providers/action_providers.dart';
import 'package:edconnect_admin/presentation/providers/state_providers.dart';
import 'package:edconnect_admin/presentation/providers/theme_provider.dart';
import 'package:edconnect_admin/presentation/widgets/common/buttons/base_button.dart';
import 'package:edconnect_admin/presentation/widgets/common/navigation/app_bar.dart';
import 'package:edconnect_admin/presentation/widgets/common/navigation/tabs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SortingSurveyDetailsPage extends ConsumerWidget {
  const SortingSurveyDetailsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeProvider);
    final surveyAsync = ref.watch(selectedSortingSurveyProvider);

    return Scaffold(
      backgroundColor: theme.isDarkMode
          ? Foundations.darkColors.background
          : Foundations.colors.background,
      body: surveyAsync.when(
        data: (survey) {
          if (survey == null) {
            return const Center(child: Text('Survey not found'));
          }
          return _buildContent(context, ref, survey);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildContent(
      BuildContext context, WidgetRef ref, SortingSurvey survey) {
    final notifierState = ref.watch(sortingSurveyNotifierProvider);

    return Column(
      children: [
        BaseAppBar(
          title: survey.title,
          showLeading: true,
          actions: [
            if (survey.status == SortingSurveyStatus.draft) ...[
              BaseButton(
                label: 'Publish',
                prefixIcon: Icons.publish,
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
              prefixIcon: Icons.delete,
              backgroundColor: Foundations.colors.error,
              variant: ButtonVariant.filled,
              isLoading: notifierState.isLoading,
              onPressed: () => _deleteSurvey(context, ref, survey.id),
            ),
          ],
        ),
        Expanded(
          child: BaseTabs(
            tabs: [
              TabItem(
                label: 'Overview',
                icon: Icons.dashboard_outlined,
                content: _OverviewTab(survey: survey),
              ),
              TabItem(
                label: 'Parameters',
                icon: Icons.settings_outlined,
                content: _ParametersTab(survey: survey),
              ),
              TabItem(
                label: 'Responses',
                icon: Icons.people_outline,
                content: _ResponsesTab(survey: survey),
              ),
            ],
          ),
        ),
      ],
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
    // Implement overview tab content
    return const Center(child: Text('Overview Content'));
  }
}

class _ParametersTab extends ConsumerWidget {
  final SortingSurvey survey;

  const _ParametersTab({required this.survey});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Implement parameters tab content
    return const Center(child: Text('Parameters Content'));
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
