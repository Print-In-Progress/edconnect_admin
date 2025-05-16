import 'package:edconnect_admin/core/interfaces/localization_repository.dart';
import 'package:edconnect_admin/core/providers/interface_providers.dart';
import 'package:edconnect_admin/presentation/pages/sorting_module/utils/parameter_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edconnect_admin/core/design_system/color_generator.dart';
import 'package:edconnect_admin/core/design_system/foundations.dart';
import 'package:edconnect_admin/core/models/app_user.dart';
import 'package:edconnect_admin/domain/entities/sorting_survey.dart';
import 'package:edconnect_admin/l10n/app_localizations.dart';
import 'package:edconnect_admin/presentation/pages/sorting_module/tabs/responses/components/responses_table/empty_state.dart';
import 'package:edconnect_admin/presentation/pages/sorting_module/tabs/responses/components/responses_table/table_filters.dart';
import 'package:edconnect_admin/presentation/pages/sorting_module/tabs/responses/dialogs/edit_response_dialog.dart';
import 'package:edconnect_admin/presentation/providers/action_providers.dart';
import 'package:edconnect_admin/presentation/providers/state_providers.dart';
import 'package:edconnect_admin/presentation/providers/theme_provider.dart';
import 'package:edconnect_admin/presentation/widgets/common/buttons/base_icon_button.dart';
import 'package:edconnect_admin/presentation/widgets/common/cards/base_card.dart';
import 'package:edconnect_admin/presentation/widgets/common/dialogs/dialogs.dart';
import 'package:edconnect_admin/presentation/widgets/common/navigation/pagination.dart';
import 'package:edconnect_admin/presentation/widgets/common/toast.dart';
import 'dart:math';

class ResponsesTable extends ConsumerWidget {
  final SortingSurvey survey;
  final AsyncValue<Map<String, Map<String, dynamic>>> filteredResponses;

  const ResponsesTable({
    required this.survey,
    required this.filteredResponses,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(appThemeProvider).isDarkMode;
    final l10n = AppLocalizations.of(context)!;
    final localizations = ref.watch(localizationRepositoryProvider);

    return filteredResponses.when(
      data: (responses) {
        final paginationState =
            ref.watch(paginationStateProvider('responses_${survey.id}'));
        final allEntries = responses.entries.toList();
        final hasAnyResponses = survey.responses.isNotEmpty;

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
              ResponseTableFilter(survey: survey),
              if (responses.isEmpty)
                EmptyResponsesTableState(
                    survey: survey, hasAnyResponses: hasAnyResponses)
              else
                _buildResponsesTableContent(context, ref, isDarkMode,
                    paginatedResponses, l10n, localizations),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) =>
          Center(child: Text(l10n.errorUnexpectedWithError(error.toString()))),
    );
  }

  Widget _buildResponsesTableContent(
      BuildContext context,
      WidgetRef ref,
      bool isDarkMode,
      List<MapEntry<String, Map<String, dynamic>>> paginatedResponses,
      AppLocalizations l10n,
      LocalizationRepository localizations) {
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
                  DataColumn(label: Text(l10n.globalName)),
                  if (survey.askBiologicalSex)
                    DataColumn(label: Text(l10n.globalBiologicalSexLabel)),
                  ...survey.parameters.map(
                    (param) => DataColumn(
                      label: Text(
                          ParameterFormatter.formatParameterNameForDisplay(
                              param['name'])),
                    ),
                  ),
                  if (survey.maxPreferences != null)
                    DataColumn(label: Text(l10n.sortingModulePreferences(0))),
                  DataColumn(label: Text(l10n.globalActionsLabel)),
                ],
                rows: paginatedResponses.map((entry) {
                  final response = entry.value;
                  return DataRow(
                    cells: [
                      DataCell(Text(
                          '${response['_first_name']} ${response['_last_name']}')),
                      if (survey.askBiologicalSex)
                        _buildColoredDataCell(
                            'sex', response['sex'], isDarkMode, localizations),
                      ...survey.parameters.map(
                        (param) => _buildColoredDataCell(
                          param['name'],
                          response[param['name']]?.toString() ?? '',
                          isDarkMode,
                          localizations,
                        ),
                      ),
                      if (survey.maxPreferences != null)
                        _buildPreferencesCell(
                          context,
                          (response['prefs'] as List?)?.cast<String>() ?? [],
                          isDarkMode,
                          accentColor,
                          l10n,
                        ),
                      DataCell(_buildActionButtons(
                          context, ref, entry.key, response, l10n)),
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

  Widget _buildActionButtons(BuildContext context, WidgetRef ref,
      String responseId, Map<String, dynamic> response, AppLocalizations l10n) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        BaseIconButton(
          icon: Icons.edit_outlined,
          onPressed: () {
            EditResponseDialogContent.show(
              context,
              survey,
              responseId,
              response,
              (updatedResponse, responseId) {
                ref
                    .read(sortingSurveyNotifierProvider.notifier)
                    .updateResponse(survey.id, responseId, updatedResponse);
                Toaster.success(context,
                    l10n.successXUpdated(l10n.sortingModuleResponses(1)));
              },
            );
          },
          variant: IconButtonVariant.ghost,
          size: IconButtonSize.small,
          tooltip: l10n.globalEditWithName(l10n.sortingModuleResponses(1)),
        ),
        SizedBox(width: Foundations.spacing.xs),
        BaseIconButton(
          icon: Icons.delete_outline,
          onPressed: () async {
            final bool? confirmed = await Dialogs.confirm(
              context: context,
              title: l10n.globalDeleteWithName(l10n.sortingModuleResponses(1)),
              message: l10n.globalDeleteConfirmationDialogWithName(
                  l10n.sortingModuleResponses(1).toLowerCase()),
              variant: DialogVariant.danger,
              dangerous: true,
              confirmText: AppLocalizations.of(context)!.globalDelete,
            );
            if (confirmed != null && confirmed) {
              ref
                  .read(sortingSurveyNotifierProvider.notifier)
                  .deleteResponse(survey.id, responseId);
            }
          },
          variant: IconButtonVariant.ghost,
          size: IconButtonSize.small,
          tooltip: l10n.globalDeleteWithName(l10n.sortingModuleResponses(1)),
          color: Foundations.colors.error,
        ),
      ],
    );
  }

  DataCell _buildColoredDataCell(String paramName, String value,
      bool isDarkMode, LocalizationRepository localizations) {
    final isSexParameter = paramName == 'sex';
    final isBinary = !isSexParameter &&
        (survey.parameters.firstWhere((p) => p['name'] == paramName)['type'] ==
            'binary');

    final color = ColorGenerator.getColor(
      paramName,
      value,
      isDarkMode: isDarkMode,
      isBinary: isBinary,
    );

    final displayValue = isSexParameter
        ? ParameterFormatter.formatSexForDisplay(value, localizations)
        : ParameterFormatter.formatParameterNameForDisplay(value);

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
      bool isDarkMode, Color accentColor, AppLocalizations l10n) {
    if (prefs.isEmpty) {
      return const DataCell(Text('-'));
    }

    return DataCell(
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l10n.globalXSelected(prefs.length)),
          SizedBox(width: Foundations.spacing.xs),
          Consumer(builder: (context, ref, _) {
            final allUsers = ref.watch(allUsersStreamProvider).value ?? [];

            return BaseIconButton(
              icon: Icons.visibility_outlined,
              variant: IconButtonVariant.ghost,
              size: IconButtonSize.small,
              tooltip: l10n.sortingModulePreferences(0),
              onPressed: () {
                Dialogs.show(
                  context: context,
                  title: l10n.sortingModulePreferences(0),
                  width: 400,
                  variant: DialogVariant.info,
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...prefs.asMap().entries.map((entry) {
                        final index = entry.key + 1;
                        final prefId = entry.value;
                        final prefResponse = survey.responses[prefId];

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
}
