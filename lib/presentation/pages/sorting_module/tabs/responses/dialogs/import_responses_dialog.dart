import 'package:edconnect_admin/core/interfaces/localization_repository.dart';
import 'package:edconnect_admin/core/providers/interface_providers.dart';
import 'package:edconnect_admin/l10n/app_localizations.dart';
import 'package:edconnect_admin/presentation/pages/sorting_module/utils/parameter_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edconnect_admin/core/design_system/foundations.dart';
import 'package:edconnect_admin/domain/entities/sorting_survey.dart';
import 'package:edconnect_admin/presentation/providers/theme_provider.dart';
import 'package:edconnect_admin/presentation/providers/state_providers.dart';
import 'package:edconnect_admin/presentation/widgets/common/cards/base_card.dart';
import 'package:edconnect_admin/presentation/widgets/common/input/file_input.dart';

class ImportResponsesDialog extends ConsumerWidget {
  final SortingSurvey survey;

  const ImportResponsesDialog({
    required this.survey,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeProvider);
    final isDarkMode = theme.isDarkMode;
    final importState = ref.watch(responseImportProvider);
    final l10n = AppLocalizations.of(context)!;
    final LocalizationRepository localizations =
        ref.watch(localizationRepositoryProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BaseCard(
          variant: CardVariant.outlined,
          padding: EdgeInsets.all(Foundations.spacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.globalImportX(l10n.sortingModuleResponses(0)),
                style: TextStyle(
                  fontSize: Foundations.typography.base,
                  fontWeight: Foundations.typography.semibold,
                  color: isDarkMode
                      ? Foundations.darkColors.textPrimary
                      : Foundations.colors.textPrimary,
                ),
              ),
              SizedBox(height: Foundations.spacing.md),
              FileInput(
                allowedExtensions: const ['xlsx', 'csv'],
                hint: l10n.globalSelectFileToImport,
                description: l10n.globalSupportedFormatsWithFormats(
                    'Excel (.xlsx), CSV (.csv)'),
                onFilesChanged: (files) {
                  if (files.isNotEmpty) {
                    ref
                        .read(responseImportProvider.notifier)
                        .parseFile(files.first, survey);
                  }
                },
              ),
            ],
          ),
        ),
        if (importState.error != null) ...[
          SizedBox(height: Foundations.spacing.md),
          Text(
            importState.error!,
            style: TextStyle(
              color: Foundations.colors.error,
              fontSize: Foundations.typography.sm,
            ),
          ),
        ],
        if (importState.isLoading) ...[
          SizedBox(height: Foundations.spacing.xl),
          const Center(child: CircularProgressIndicator()),
        ],
        if (!importState.isLoading && importState.previewData != null) ...[
          SizedBox(height: Foundations.spacing.xl),
          _buildPreviewSection(context, importState, isDarkMode, localizations),
        ],
      ],
    );
  }

  Widget _buildPreviewSection(
    BuildContext context,
    ImportState state,
    bool isDarkMode,
    LocalizationRepository localizations,
  ) {
    final responses = state.previewData!['responses'] as Map<String, dynamic>;
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.globalPreviewLabel,
          style: TextStyle(
            fontSize: Foundations.typography.lg,
            fontWeight: Foundations.typography.semibold,
            color: isDarkMode
                ? Foundations.darkColors.textPrimary
                : Foundations.colors.textPrimary,
          ),
        ),
        if (state.duplicates?.isNotEmpty ?? false) ...[
          SizedBox(height: Foundations.spacing.md),
          _buildWarningBanner(
            '${l10n.sortingModuleDuplicateNamesFound}: ${state.duplicates!.join(", ")}',
            isDarkMode,
          ),
        ],
        SizedBox(height: Foundations.spacing.md),
        _buildStatisticsGrid(state, isDarkMode, l10n),
        SizedBox(height: Foundations.spacing.lg),
        _buildResponsesPreview(responses, isDarkMode, l10n, localizations),
      ],
    );
  }

  Widget _buildWarningBanner(String message, bool isDarkMode) {
    return Container(
      padding: EdgeInsets.all(Foundations.spacing.md),
      decoration: BoxDecoration(
        color: Foundations.colors.warning.withValues(alpha: 0.1),
        borderRadius: Foundations.borders.sm,
        border: Border.all(
          color: Foundations.colors.warning,
          width: Foundations.borders.thin,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Foundations.colors.warning,
            size: 20,
          ),
          SizedBox(width: Foundations.spacing.sm),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: isDarkMode
                    ? Foundations.darkColors.textPrimary
                    : Foundations.colors.textPrimary,
                fontSize: Foundations.typography.sm,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsGrid(
      ImportState state, bool isDarkMode, AppLocalizations l10n) {
    final responses = state.previewData!['responses'] as Map<String, dynamic>;
    final hasPreferences = state.previewData!['has_preferences'] as bool;
    final hasBiologicalSex = state.previewData!['ask_biological_sex'] as bool;
    final parameters = state.previewData!['parameters'] as List;

    return Wrap(
      spacing: Foundations.spacing.md,
      runSpacing: Foundations.spacing.md,
      children: [
        _buildStatCard(l10n.sortingModuleResponses(0),
            responses.length.toString(), isDarkMode),
        _buildStatCard(l10n.sortingModuleParameters,
            parameters.length.toString(), isDarkMode),
        _buildStatCard(
          l10n.sortingModulePreferences(0),
          hasPreferences ? l10n.globalEnabledLabel : l10n.globalDisabledLabel,
          isDarkMode,
        ),
        _buildStatCard(
          l10n.globalBiologicalSexLabel,
          hasBiologicalSex
              ? l10n.globalRequiredLabel
              : l10n.globalNotRequiredLabel,
          isDarkMode,
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, bool isDarkMode) {
    return BaseCard(
      variant: CardVariant.outlined,
      margin: EdgeInsets.zero,
      padding: EdgeInsets.all(Foundations.spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: Foundations.typography.sm,
              color: isDarkMode
                  ? Foundations.darkColors.textMuted
                  : Foundations.colors.textMuted,
            ),
          ),
          SizedBox(height: Foundations.spacing.xs),
          Text(
            value,
            style: TextStyle(
              fontSize: Foundations.typography.lg,
              fontWeight: Foundations.typography.semibold,
              color: isDarkMode
                  ? Foundations.darkColors.textPrimary
                  : Foundations.colors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponsesPreview(Map<String, dynamic> responses, bool isDarkMode,
      AppLocalizations l10n, LocalizationRepository localizations) {
    return BaseCard(
      variant: CardVariant.outlined,
      padding: EdgeInsets.all(Foundations.spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.globalPreviewLabel,
            style: TextStyle(
              fontSize: Foundations.typography.base,
              fontWeight: Foundations.typography.semibold,
              color: isDarkMode
                  ? Foundations.darkColors.textPrimary
                  : Foundations.colors.textPrimary,
            ),
          ),
          SizedBox(height: Foundations.spacing.md),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 300),
              child: SingleChildScrollView(
                child: DataTable(
                  columns: [
                    DataColumn(label: Text(l10n.globalName)),
                    if (survey.askBiologicalSex)
                      DataColumn(label: Text(l10n.globalBiologicalSexLabel)),
                    ...survey.parameters.map(
                      (param) => DataColumn(
                        label: Text(param['name']),
                      ),
                    ),
                    if (survey.maxPreferences != null)
                      DataColumn(label: Text(l10n.sortingModulePreferences(0))),
                  ],
                  rows: responses.entries.map((entry) {
                    final response = entry.value as Map<String, dynamic>;
                    return DataRow(
                      cells: [
                        DataCell(Text(
                            '${response['_first_name']} ${response['_last_name']}')),
                        if (survey.askBiologicalSex)
                          DataCell(Text(ParameterFormatter.formatSexForDisplay(
                              response['sex'], localizations))),
                        ...survey.parameters.map(
                          (param) => DataCell(
                            Text(ParameterFormatter
                                    .formatParameterNameForDisplay(
                                        response[param['name']])
                                .toString()),
                          ),
                        ),
                        if (survey.maxPreferences != null)
                          DataCell(
                            Text((response['prefs'] as List?)?.map((id) {
                                  final prefResponse = responses[id];
                                  return prefResponse != null
                                      ? '${prefResponse['_first_name']} ${prefResponse['_last_name']}'
                                      : 'Unknown';
                                }).join(', ') ??
                                ''),
                          ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
