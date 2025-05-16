import 'package:edconnect_admin/core/design_system/foundations.dart';
import 'package:edconnect_admin/domain/entities/sorting_survey.dart';
import 'package:edconnect_admin/l10n/app_localizations.dart';
import 'package:edconnect_admin/presentation/pages/sorting_module/components/section_header.dart';
import 'package:edconnect_admin/presentation/pages/sorting_module/tabs/responses/components/responses_table/responses_table.dart';
import 'package:edconnect_admin/presentation/pages/sorting_module/tabs/responses/dialogs/add_response_dialog.dart';
import 'package:edconnect_admin/presentation/pages/sorting_module/tabs/responses/dialogs/export_responses_dialog.dart';
import 'package:edconnect_admin/presentation/pages/sorting_module/tabs/responses/dialogs/import_responses_dialog.dart';
import 'package:edconnect_admin/presentation/pages/sorting_module/tabs/responses/components/parameter_distribution/parameter_grid.dart';
import 'package:edconnect_admin/presentation/pages/sorting_module/tabs/responses/components/stats/stat_grid.dart';
import 'package:edconnect_admin/presentation/providers/action_providers.dart';
import 'package:edconnect_admin/presentation/providers/state_providers.dart';
import 'package:edconnect_admin/presentation/widgets/common/buttons/base_button.dart';
import 'package:edconnect_admin/presentation/widgets/common/dialogs/dialogs.dart';
import 'package:edconnect_admin/presentation/widgets/common/loading_indicators/async_value_widget.dart';
import 'package:edconnect_admin/presentation/widgets/common/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ResponsesTab extends ConsumerWidget {
  final SortingSurvey survey;

  const ResponsesTab({super.key, required this.survey});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surveyAsync = ref.watch(selectedSortingSurveyProvider(survey.id));
    final l10n = AppLocalizations.of(context)!;

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
                SectionHeader(
                    title: l10n.sortingModuleResponseStatisticsLabel,
                    icon: Icons.analytics_outlined),
                SizedBox(height: Foundations.spacing.md),
                StatGrid(survey: survey),
                SizedBox(height: Foundations.spacing.xl),
                SectionHeader(
                    title: l10n.sortingModuleParameterDistributionLabel,
                    icon: Icons.bar_chart),
                SizedBox(height: Foundations.spacing.md),
                ParameterGrid(survey: survey),
                SizedBox(height: Foundations.spacing.xl),
                SectionHeader(
                    title: l10n.sortingModuleParameterDistributionLabel,
                    icon: Icons.table_chart_outlined),
                SizedBox(height: Foundations.spacing.md),
                Wrap(
                  runSpacing: Foundations.spacing.xs,
                  children: [
                    BaseButton(
                      label: l10n.globalAddX(l10n.sortingModuleResponses(1)),
                      prefixIcon: Icons.person_add_outlined,
                      variant: ButtonVariant.outlined,
                      size: ButtonSize.medium,
                      onPressed: () {
                        AddResponseDialogContent.show(
                          context,
                          survey,
                          (response, respondentId) {
                            ref
                                .read(sortingSurveyNotifierProvider.notifier)
                                .addResponse(survey.id, respondentId, response);
                            Toaster.success(
                                context,
                                l10n.successXAdded(
                                    l10n.sortingModuleResponses(1)));
                          },
                        );
                      },
                    ),
                    SizedBox(width: Foundations.spacing.md),
                    BaseButton(
                      label: l10n.globalImportX(
                        l10n.sortingModuleResponses(0),
                      ),
                      prefixIcon: Icons.upload_file_outlined,
                      variant: ButtonVariant.outlined,
                      size: ButtonSize.medium,
                      onPressed: () =>
                          _showImportDialog(context, ref, latestSurvey, l10n),
                    ),
                    SizedBox(width: Foundations.spacing.md),
                    BaseButton(
                      label: l10n.globalExportX(''),
                      prefixIcon: Icons.download_outlined,
                      variant: ButtonVariant.outlined,
                      size: ButtonSize.medium,
                      onPressed: () {
                        Dialogs.show(
                          context: context,
                          title: l10n.globalExportX(
                            l10n.sortingModuleResponses(0),
                          ),
                          content: const ExportResponsesDialog(),
                          showCancelButton: true,
                        );
                      },
                    ),
                    SizedBox(width: Foundations.spacing.md),
                    BaseButton(
                      label: l10n.globalDeleteAllX(''),
                      prefixIcon: Icons.delete_sweep_outlined,
                      variant: ButtonVariant.filled,
                      size: ButtonSize.medium,
                      backgroundColor: Foundations.colors.error,
                      onPressed: () =>
                          _deleteAllResponses(context, ref, latestSurvey, l10n),
                    ),
                  ],
                ),
                SizedBox(height: Foundations.spacing.md),
                ResponsesTable(
                    survey: survey, filteredResponses: filteredResponses)
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
            Text(l10n.errorLoadingX(l10n.sortingSurvey(1))),
            SizedBox(height: Foundations.spacing.md),
            BaseButton(
              label: l10n.globalRetry,
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

  Future<void> _deleteAllResponses(BuildContext context, WidgetRef ref,
      SortingSurvey survey, AppLocalizations l10n) async {
    final bool? confirmed = await Dialogs.confirm(
      context: context,
      title: l10n.globalDeleteAllX(l10n.sortingModuleResponses(0)),
      message: l10n.globalDeleteConfirmationDialogAllWithName(
          l10n.sortingModuleResponses(0)),
      variant: DialogVariant.danger,
      dangerous: true,
      confirmText: l10n.globalDeleteAllX(''),
    );

    if (confirmed == true) {
      await ref
          .read(sortingSurveyNotifierProvider.notifier)
          .deleteAllResponses(survey.id);
      if (context.mounted) {
        Toaster.success(context,
            l10n.successDeletedWithName(l10n.sortingModuleResponses(0)));
      }
    }
  }

  void _showImportDialog(BuildContext context, WidgetRef ref,
      SortingSurvey survey, AppLocalizations l10n) {
    Dialogs.show(
      context: context,
      title: l10n.globalImportX(l10n.sortingModuleResponses(0)),
      scrollable: true,
      width: 800,
      variant: DialogVariant.default_,
      content: ImportResponsesDialog(survey: survey),
      showCancelButton: true,
      actions: [
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
