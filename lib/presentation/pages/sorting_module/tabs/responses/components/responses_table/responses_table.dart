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

    return filteredResponses.when(
      data: (responses) {
        final paginationState =
            ref.watch(paginationStateProvider('responses_${survey.id}'));
        final allEntries = responses.entries.toList();
        final hasAnyResponses = survey.responses.isNotEmpty;

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
              ResponseTableFilter(survey: survey),

              // Conditional content based on responses
              if (responses.isEmpty)
                EmptyResponsesTableState(
                    survey: survey, hasAnyResponses: hasAnyResponses)
              else
                _buildResponsesTableContent(
                    context, ref, isDarkMode, paginatedResponses)
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }

  Widget _buildResponsesTableContent(
      BuildContext context,
      WidgetRef ref,
      bool isDarkMode,
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
                      label: Text(
                          ParameterFormatter.formatParameterNameForDisplay(
                              param['name'])),
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
                      DataCell(_buildActionButtons(
                          context, ref, entry.key, response)),
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
      String responseId, Map<String, dynamic> response) {
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
                Toaster.success(context, 'Response updated successfully');
              },
            );
          },
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
              message: 'Are you sure you want to delete this response?',
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
          tooltip: 'Delete response',
          color: Foundations.colors.error,
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
    final displayValue = isSexParameter
        ? ParameterFormatter.formatSexForDisplay(value)
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
}
