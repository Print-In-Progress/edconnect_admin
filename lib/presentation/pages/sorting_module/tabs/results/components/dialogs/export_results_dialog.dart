import 'dart:typed_data';

import 'package:edconnect_admin/core/design_system/foundations.dart';
import 'package:edconnect_admin/core/models/app_user.dart';
import 'package:edconnect_admin/core/providers/interface_providers.dart';
import 'package:edconnect_admin/domain/entities/sorting_survey.dart';
import 'package:edconnect_admin/domain/services/file_export_service.dart';
import 'package:edconnect_admin/domain/services/pdf_service.dart';
import 'package:edconnect_admin/l10n/app_localizations.dart';
import 'package:edconnect_admin/presentation/providers/state_providers.dart';
import 'package:edconnect_admin/presentation/providers/theme_provider.dart';
import 'package:edconnect_admin/presentation/widgets/common/checkbox.dart';
import 'package:edconnect_admin/presentation/widgets/common/dropdown/single_select_dropdown.dart';
import 'package:edconnect_admin/presentation/widgets/common/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExportSettings {
  final Map<String, bool> selectedClasses;
  final Map<String, bool> selectedParameters;
  final bool includeGender;
  final bool includeSummaryStatistics;
  final bool showClassStatistics;
  final PageSize selectedPageSize;

  ExportSettings({
    required this.selectedClasses,
    required this.selectedParameters,
    required this.includeGender,
    required this.includeSummaryStatistics,
    required this.showClassStatistics,
    required this.selectedPageSize,
  });
}

class ExportResultsDialog extends ConsumerStatefulWidget {
  final SortingSurvey survey;
  final Map<String, List<String>> currentResults;
  final Function(bool isExporting)? onExportStatusChanged;

  const ExportResultsDialog({
    super.key,
    required this.survey,
    required this.currentResults,
    this.onExportStatusChanged,
  });

  @override
  ConsumerState<ExportResultsDialog> createState() =>
      ExportResultsDialogState();
}

class ExportResultsDialogState extends ConsumerState<ExportResultsDialog> {
  final Map<String, bool> _selectedClasses = {};
  PageSize _selectedPageSize = PageSize.a4;
  bool _selectAllClasses = true;

  final Map<String, bool> _selectedParameters = {};
  bool _selectAllParameters = false;
  bool _includeGender = false;

  bool _includeSummaryStatistics = false;
  bool _showClassStatistics = false;

  @override
  void initState() {
    super.initState();

    for (final className in widget.currentResults.keys) {
      _selectedClasses[className] = true;
    }

    for (final param in widget.survey.parameters) {
      final paramName = param['name'] as String;
      if (paramName != 'sex') {
        _selectedParameters[paramName] = false;
      }
    }
  }

  void _toggleSelectAllClasses(bool value) {
    setState(() {
      _selectAllClasses = value;
      for (final className in _selectedClasses.keys) {
        _selectedClasses[className] = value;
      }
    });
  }

  void _toggleSelectAllParameters(bool value) {
    setState(() {
      _selectAllParameters = value;
      for (final paramName in _selectedParameters.keys) {
        _selectedParameters[paramName] = value;
      }
    });
  }

  void _updateClassSelectAllStatus() {
    final allSelected = _selectedClasses.values.every((selected) => selected);

    setState(() {
      _selectAllClasses = allSelected;
    });
  }

  void _updateParameterSelectAllStatus() {
    final allSelected =
        _selectedParameters.values.every((selected) => selected);

    setState(() {
      _selectAllParameters = allSelected;
    });
  }

  Future<void> exportPdf() async {
    final l10n = AppLocalizations.of(context)!;
    if (_selectedClasses.values.every((selected) => !selected)) {
      Toaster.warning(
          context, l10n.sortingModuleSelectAtLeastOneClassForExport);
      return;
    }

    widget.onExportStatusChanged?.call(true);

    try {
      final allUsers = ref.read(allUsersStreamProvider).value ?? [];

      final pdfBytes = await _generatePdf(allUsers);

      await _downloadPdf(pdfBytes);

      if (mounted) {
        Toaster.success(context, l10n.successExport);
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        Toaster.error(context, l10n.errorExportFailed,
            description: e.toString());
      }
    } finally {
      widget.onExportStatusChanged?.call(false);
    }
  }

  Future<Uint8List> _generatePdf(List<AppUser> allUsers) async {
    final localizationRepository = ref.watch(localizationRepositoryProvider);

    // Create PDF service with the repository
    final exportService = SortingResultsPdfService(localizationRepository);
    return exportService.generateClassDistributionPdf(
      survey: widget.survey,
      currentResults: widget.currentResults,
      selectedClasses: _selectedClasses,
      selectedParameters: _selectedParameters,
      includeGender: _includeGender,
      includeSummaryStatistics: _includeSummaryStatistics,
      showClassStatistics: _showClassStatistics,
      pageSize: _selectedPageSize,
      allUsers: allUsers,
    );
  }

  Future<void> _downloadPdf(Uint8List pdfBytes) async {
    final now = DateTime.now();
    final l10n = AppLocalizations.of(context)!;
    final formattedDate =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final fileName =
        'class_distribution_${widget.survey.title.replaceAll(' ', '_')}_$formattedDate.pdf';

    try {
      final fileExportService = FileExportService();
      await fileExportService.exportFile(
        bytes: pdfBytes,
        fileName: fileName,
        mimeType: 'application/pdf',
      );
    } catch (e) {
      if (mounted) {
        Toaster.error(context, l10n.errorFileDownloadFailed,
            description: e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(appThemeProvider);
    final isDarkMode = theme.isDarkMode;
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.sortingModuleSelectClassesToExportLabel,
          style: TextStyle(
            fontSize: Foundations.typography.base,
            fontWeight: Foundations.typography.semibold,
            color: isDarkMode
                ? Foundations.darkColors.textPrimary
                : Foundations.colors.textPrimary,
          ),
        ),
        SizedBox(height: Foundations.spacing.xs),
        BaseCheckbox(
          value: _selectAllClasses,
          onChanged: (value) {
            _toggleSelectAllClasses(value!);
          },
          label: l10n.sortingModuleSelectAllClasses,
        ),
        SizedBox(height: Foundations.spacing.xs),
        Wrap(
          spacing: Foundations.spacing.lg,
          runSpacing: Foundations.spacing.xs,
          children: widget.currentResults.keys.map((className) {
            return SizedBox(
              width: 200,
              child: BaseCheckbox(
                value: _selectedClasses[className] ?? false,
                onChanged: (value) {
                  setState(() {
                    _selectedClasses[className] = value!;
                    _updateClassSelectAllStatus();
                  });
                },
                label: '$className ${l10n.sortingModuleNumOfStudents(
                  widget.currentResults[className]?.length ?? 0,
                )}',
              ),
            );
          }).toList(),
        ),
        SizedBox(height: Foundations.spacing.lg),
        Text(
          l10n.sortingModuleSelectInfoToIncludeLabel,
          style: TextStyle(
            fontSize: Foundations.typography.base,
            fontWeight: Foundations.typography.semibold,
            color: isDarkMode
                ? Foundations.darkColors.textPrimary
                : Foundations.colors.textPrimary,
          ),
        ),
        SizedBox(height: Foundations.spacing.xs),
        if (widget.survey.askBiologicalSex)
          BaseCheckbox(
            value: _includeGender,
            onChanged: (value) {
              setState(() {
                _includeGender = value!;
              });
            },
            label: l10n.sortingModuleIncludeGender,
          ),
        SizedBox(height: Foundations.spacing.sm),
        if (widget.survey.parameters.isNotEmpty &&
            widget.survey.parameters.any((p) => p['name'] != 'sex')) ...[
          Text(
            l10n.sortingModuleAdditionalParametersLabel,
            style: TextStyle(
              fontSize: Foundations.typography.base,
              fontWeight: Foundations.typography.semibold,
              color: isDarkMode
                  ? Foundations.darkColors.textPrimary
                  : Foundations.colors.textPrimary,
            ),
          ),
          SizedBox(height: Foundations.spacing.xs),
          BaseCheckbox(
            value: _selectAllParameters,
            onChanged: (value) {
              _toggleSelectAllParameters(value!);
            },
            label: l10n.sortingModuleSelectAllParameters,
          ),
          SizedBox(height: Foundations.spacing.xs),
          Wrap(
            spacing: Foundations.spacing.lg,
            runSpacing: Foundations.spacing.xs,
            children: widget.survey.parameters
                .where((p) => p['name'] != 'sex')
                .map((param) {
              final paramName = param['name'] as String;
              return SizedBox(
                width: 200,
                child: BaseCheckbox(
                  value: _selectedParameters[paramName] ?? false,
                  onChanged: (value) {
                    setState(() {
                      _selectedParameters[paramName] = value!;
                      _updateParameterSelectAllStatus();
                    });
                  },
                  label: _formatParamName(paramName),
                ),
              );
            }).toList(),
          ),
        ],
        SizedBox(height: Foundations.spacing.lg),
        Text(
          l10n.globalExportOptions,
          style: TextStyle(
            fontSize: Foundations.typography.base,
            fontWeight: Foundations.typography.semibold,
            color: isDarkMode
                ? Foundations.darkColors.textPrimary
                : Foundations.colors.textPrimary,
          ),
        ),
        SizedBox(height: Foundations.spacing.xs),
        BaseCheckbox(
          value: _includeSummaryStatistics,
          onChanged: (value) {
            setState(() {
              _includeSummaryStatistics = value!;
            });
          },
          label: l10n.sortingModuleExportIncludeSummaryStatistics,
        ),
        BaseCheckbox(
          value: _showClassStatistics,
          onChanged: (value) {
            setState(() {
              _showClassStatistics = value!;
            });
          },
          label: l10n.sortingModuleIncludeClassStatistics,
        ),
        SizedBox(height: Foundations.spacing.sm),
        Text(
          l10n.globalPageSize,
          style: TextStyle(
            fontSize: Foundations.typography.sm,
            fontWeight: Foundations.typography.medium,
            color: isDarkMode
                ? Foundations.darkColors.textSecondary
                : Foundations.colors.textSecondary,
          ),
        ),
        SizedBox(height: Foundations.spacing.xs),
        BaseSelect<PageSize>(
          value: _selectedPageSize,
          options: PageSize.values
              .map((size) => SelectOption<PageSize>(
                    value: size,
                    label: size.label,
                    icon: Icons.description_outlined,
                  ))
              .toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedPageSize = value;
              });
            }
          },
          width: 200,
          fullWidth: false,
          hint: l10n.globalSelectPageSize,
          size: SelectSize.medium,
          variant: SelectVariant.outlined,
        ),
      ],
    );
  }

  String _formatParamName(String name) {
    return name
        .split('_')
        .map((word) => word.isNotEmpty
            ? '${word[0].toUpperCase()}${word.substring(1)}'
            : '')
        .join(' ');
  }
}
