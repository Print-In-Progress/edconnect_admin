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

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // File Upload Section
        BaseCard(
          variant: CardVariant.outlined,
          padding: EdgeInsets.all(Foundations.spacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Import File',
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
                allowedExtensions: ['xlsx', 'csv'],
                hint: 'Select file to import',
                description: 'Supported formats: Excel (.xlsx), CSV (.csv)',
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
          _buildPreviewSection(context, importState, isDarkMode),
        ],
      ],
    );
  }

  Widget _buildPreviewSection(
    BuildContext context,
    ImportState state,
    bool isDarkMode,
  ) {
    final responses = state.previewData!['responses'] as Map<String, dynamic>;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Preview',
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
            'Duplicate names found: ${state.duplicates!.join(", ")}',
            isDarkMode,
          ),
        ],
        SizedBox(height: Foundations.spacing.md),
        _buildStatisticsGrid(state, isDarkMode),
        SizedBox(height: Foundations.spacing.lg),
        _buildResponsesPreview(responses, isDarkMode),
      ],
    );
  }

  Widget _buildWarningBanner(String message, bool isDarkMode) {
    return Container(
      padding: EdgeInsets.all(Foundations.spacing.md),
      decoration: BoxDecoration(
        color: Foundations.colors.warning.withOpacity(0.1),
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

  Widget _buildStatisticsGrid(ImportState state, bool isDarkMode) {
    final responses = state.previewData!['responses'] as Map<String, dynamic>;
    final hasPreferences = state.previewData!['has_preferences'] as bool;
    final hasBiologicalSex = state.previewData!['ask_biological_sex'] as bool;
    final parameters = state.previewData!['parameters'] as List;

    return Wrap(
      spacing: Foundations.spacing.md,
      runSpacing: Foundations.spacing.md,
      children: [
        _buildStatCard('Responses', responses.length.toString(), isDarkMode),
        _buildStatCard('Parameters', parameters.length.toString(), isDarkMode),
        _buildStatCard(
          'Preferences',
          hasPreferences ? 'Enabled' : 'Disabled',
          isDarkMode,
        ),
        _buildStatCard(
          'Biological Sex',
          hasBiologicalSex ? 'Asked' : 'Not Asked',
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

  Widget _buildResponsesPreview(
    Map<String, dynamic> responses,
    bool isDarkMode,
  ) {
    return BaseCard(
      variant: CardVariant.outlined,
      padding: EdgeInsets.all(Foundations.spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Response Preview',
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
                    const DataColumn(label: Text('Name')),
                    if (survey.askBiologicalSex)
                      const DataColumn(label: Text('Sex')),
                    ...survey.parameters.map(
                      (param) => DataColumn(
                        label: Text(param['name']),
                      ),
                    ),
                    if (survey.maxPreferences != null)
                      const DataColumn(label: Text('Preferences')),
                  ],
                  rows: responses.entries.map((entry) {
                    final response = entry.value as Map<String, dynamic>;
                    return DataRow(
                      cells: [
                        DataCell(Text(
                            '${response['_first_name']} ${response['_last_name']}')),
                        if (survey.askBiologicalSex)
                          DataCell(Text(_formatSex(response['sex']))),
                        ...survey.parameters.map(
                          (param) => DataCell(
                            Text(response[param['name']]?.toString() ?? ''),
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

  String _formatSex(String? sex) {
    return switch (sex) {
      'm' => 'Male',
      'f' => 'Female',
      'nb' => 'Non-Binary',
      _ => 'Unknown',
    };
  }
}
