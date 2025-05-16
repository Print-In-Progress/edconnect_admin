import 'package:edconnect_admin/core/design_system/foundations.dart';
import 'package:edconnect_admin/core/routing/app_router.dart';
import 'package:edconnect_admin/domain/entities/sorting_survey.dart';
import 'package:edconnect_admin/l10n/app_localizations.dart';
import 'package:edconnect_admin/presentation/pages/sorting_module/pages/list/components/survey_card.dart';
import 'package:edconnect_admin/presentation/pages/sorting_module/pages/list/components/survey_empty_state.dart';
import 'package:edconnect_admin/presentation/pages/sorting_module/pages/list/components/survey_error_state.dart';
import 'package:edconnect_admin/presentation/pages/sorting_module/pages/list/components/survey_filter_bar.dart';
import 'package:edconnect_admin/presentation/providers/state_providers.dart';
import 'package:edconnect_admin/presentation/providers/theme_provider.dart';
import 'package:edconnect_admin/presentation/widgets/common/buttons/base_button.dart';
import 'package:edconnect_admin/presentation/widgets/common/navigation/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SortingSurveysPage extends ConsumerWidget {
  const SortingSurveysPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterState = ref.watch(surveyFilterProvider);
    final surveysAsync = ref.watch(filteredSortingSurveysProvider);
    final theme = ref.watch(appThemeProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.isDarkMode
          ? Foundations.darkColors.background
          : Foundations.colors.background,
      body: Column(
        children: [
          BaseAppBar(
            title: l10n.sortingSurvey(1),
            actions: [
              BaseButton(
                label: l10n.globalCreateButtonLabel(l10n.sortingSurvey(0)),
                prefixIcon: Icons.add,
                variant: ButtonVariant.filled,
                onPressed: () => AppRouter.toCreateSortingSurvey(context),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.all(Foundations.spacing.lg),
            child: SurveyFilterBar(
              filterState: filterState,
            ),
          ),
          Expanded(
            child: surveysAsync.when(
              data: (surveys) => surveys.isEmpty
                  ? const SurveyEmptyState()
                  : _buildSurveyList(surveys, ref),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => SurveyErrorState(error: error),
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
        return SurveyCard(survey: survey);
      },
    );
  }
}
