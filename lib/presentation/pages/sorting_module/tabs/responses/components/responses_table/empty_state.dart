import 'package:edconnect_admin/core/design_system/foundations.dart';
import 'package:edconnect_admin/domain/entities/sorting_survey.dart';
import 'package:edconnect_admin/presentation/pages/sorting_module/tabs/responses/dialogs/add_response_dialog.dart';
import 'package:edconnect_admin/presentation/pages/sorting_module/tabs/responses/dialogs/import_responses_dialog.dart';
import 'package:edconnect_admin/presentation/providers/action_providers.dart';
import 'package:edconnect_admin/presentation/providers/state_providers.dart';
import 'package:edconnect_admin/presentation/providers/theme_provider.dart';
import 'package:edconnect_admin/presentation/widgets/common/buttons/base_button.dart';
import 'package:edconnect_admin/presentation/widgets/common/dialogs/dialogs.dart';
import 'package:edconnect_admin/presentation/widgets/common/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EmptyResponsesTableState extends ConsumerWidget {
  final SortingSurvey survey;
  final bool hasAnyResponses;
  const EmptyResponsesTableState({
    super.key,
    required this.survey,
    required this.hasAnyResponses,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeProvider);
    return Center(
      child: Padding(
        padding: EdgeInsets.all(Foundations.spacing.xl2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: theme.isDarkMode
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
                color: theme.isDarkMode
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
                color: theme.isDarkMode
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
                                context, 'Response added successfully');
                          },
                        );
                      },
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
