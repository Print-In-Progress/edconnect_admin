import 'package:edconnect_admin/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edconnect_admin/core/design_system/foundations.dart';
import 'package:edconnect_admin/domain/entities/sorting_survey.dart';
import 'package:edconnect_admin/presentation/pages/sorting_module/pages/details/components/survey_actions.dart';
import 'package:edconnect_admin/presentation/pages/sorting_module/pages/details/components/skeleton_loader.dart';
import 'package:edconnect_admin/presentation/pages/sorting_module/tabs/calculate/sorting_survey_calculate_tab.dart';
import 'package:edconnect_admin/presentation/pages/sorting_module/tabs/overview/sorting_survey_overview_tab.dart';
import 'package:edconnect_admin/presentation/pages/sorting_module/tabs/responses/sorting_survey_responses_tab.dart';
import 'package:edconnect_admin/presentation/pages/sorting_module/tabs/results/sorting_survey_results_tab.dart';
import 'package:edconnect_admin/presentation/providers/action_providers.dart';
import 'package:edconnect_admin/presentation/providers/state_providers.dart';
import 'package:edconnect_admin/presentation/providers/theme_provider.dart';
import 'package:edconnect_admin/presentation/widgets/common/loading_indicators/async_value_widget.dart';
import 'package:edconnect_admin/presentation/widgets/common/navigation/app_bar.dart';
import 'package:edconnect_admin/presentation/widgets/common/navigation/tabs.dart';

class SortingSurveyDetailsPage extends ConsumerWidget {
  final String surveyId;
  const SortingSurveyDetailsPage({super.key, required this.surveyId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeProvider);
    final isInitialLoading = ref.watch(surveyLoadingStateProvider);
    final notifierState = ref.watch(sortingSurveyNotifierProvider);
    final l10n = AppLocalizations.of(context)!;

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
            ? l10n.globalLoadingWithName(l10n.sortingSurvey(1))
            : surveyAsync.when(
                data: (survey) =>
                    survey?.title ??
                    l10n.globalLoadingWithName(l10n.sortingSurvey(1)),
                loading: () =>
                    l10n.globalLoadingWithName(l10n.sortingSurvey(1)),
                error: (_, __) => l10n.errorUnexpected,
              ),
        showLeading: true,
        actions: isInitialLoading
            ? [_buildSkeletonButton(theme.isDarkMode)]
            : surveyAsync.when(
                data: (survey) => SurveyActions.buildActions(
                    context, ref, survey, notifierState, l10n),
                loading: () => [_buildSkeletonButton(theme.isDarkMode)],
                error: (_, __) => [],
              ),
      ),
      body: isInitialLoading
          ? SurveySkeletonLoader(isDarkMode: theme.isDarkMode)
          : AsyncValueWidget(
              value: surveyAsync,
              skipLoadingOnRefresh: true,
              loading: () => SurveySkeletonLoader(isDarkMode: theme.isDarkMode),
              data: (survey) {
                if (survey == null) {
                  return Center(
                      child: Text(
                          l10n.globalNotFoundWithName(l10n.sortingSurvey(1))));
                }
                return _buildContent(context, ref, survey, l10n);
              },
              error: (error, stackTrace) =>
                  _buildErrorState(context, ref, error, l10n),
            ),
    );
  }

  Widget _buildSkeletonButton(bool isDarkMode) {
    return Container(
      width: 100,
      height: 36,
      margin: EdgeInsets.only(right: Foundations.spacing.md),
      decoration: BoxDecoration(
        color: isDarkMode
            ? Foundations.darkColors.surfaceActive
            : Foundations.colors.surfaceActive,
        borderRadius: Foundations.borders.md,
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref,
      SortingSurvey survey, AppLocalizations l10n) {
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
            label: l10n.sortingModuleOverview,
            icon: Icons.info_outline,
            content: OverviewTab(survey: survey),
          ),
          TabItem(
            label: l10n.sortingModuleResponses(survey.responses.length),
            icon: Icons.list_alt_outlined,
            content: ResponsesTab(survey: survey),
          ),
          TabItem(
            label: l10n.sortingModuleCalculate,
            icon: Icons.calculate_outlined,
            content: CalculateTab(survey: survey),
          ),
          TabItem(
            label: l10n.sortingModuleResults,
            icon: Icons.pie_chart_outline,
            content: ResultsTab(survey: survey),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, Object error,
      AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(l10n.errorUnexpectedWithError(error.toString())),
          ElevatedButton(
            onPressed: () =>
                ref.invalidate(selectedSortingSurveyProvider(surveyId)),
            child: Text(l10n.globalRetry),
          ),
        ],
      ),
    );
  }
}
