import 'dart:typed_data';

import 'package:edconnect_admin/core/design_system/foundations.dart';
import 'package:edconnect_admin/core/models/app_user.dart';
import 'package:edconnect_admin/domain/entities/sorting_survey.dart';
import 'package:edconnect_admin/domain/services/file_export_service.dart';
import 'package:edconnect_admin/domain/services/pdf_service.dart';
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

// Make the state class public by removing underscore
class ExportResultsDialogState extends ConsumerState<ExportResultsDialog> {
  // Track which classes to export
  Map<String, bool> _selectedClasses = {};
  PageSize _selectedPageSize = PageSize.a4;
  bool _selectAllClasses = true;

  // Track which parameters to export
  Map<String, bool> _selectedParameters = {};
  bool _selectAllParameters = false;
  bool _includeGender = false;

  // Export options
  bool _includeSummaryStatistics = false;
  bool _showClassStatistics = false;

  @override
  void initState() {
    super.initState();

    // Initialize classes selection (all selected by default)
    for (final className in widget.currentResults.keys) {
      _selectedClasses[className] = true;
    }

    // Initialize parameters selection (all selected by default)
    for (final param in widget.survey.parameters) {
      final paramName = param['name'] as String;
      if (paramName != 'sex') {
        // Skip sex as it's handled separately
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

  // Handle class selection status
  void _updateClassSelectAllStatus() {
    final allSelected = _selectedClasses.values.every((selected) => selected);

    setState(() {
      _selectAllClasses = allSelected;
    });
  }

  // Handle parameter selection status
  void _updateParameterSelectAllStatus() {
    final allSelected =
        _selectedParameters.values.every((selected) => selected);

    setState(() {
      _selectAllParameters = allSelected;
    });
  }

  // Public method to trigger PDF export from parent
  Future<void> exportPdf() async {
    // Validate that at least one class is selected
    if (_selectedClasses.values.every((selected) => !selected)) {
      Toaster.warning(context, 'Please select at least one class to export');
      return;
    }

    widget.onExportStatusChanged?.call(true);

    try {
      final allUsers = ref.read(allUsersStreamProvider).value ?? [];

      // Generate PDF
      final pdfBytes = await _generatePdf(allUsers);

      // Download the file
      await _downloadPdf(pdfBytes);

      if (mounted) {
        Toaster.success(context, 'Results exported successfully');
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        Toaster.error(context, 'Export failed', description: e.toString());
      }
    } finally {
      widget.onExportStatusChanged?.call(false);
    }
  }

  Future<Uint8List> _generatePdf(List<AppUser> allUsers) async {
    // Create a PDF exporter service extension
    final exportService = SortingResultsPdfService();

    // Generate the PDF with the selected options
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
    // Format timestamp
    final now = DateTime.now();
    final formattedDate =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    // Create file name
    final fileName =
        'class_distribution_${widget.survey.title.replaceAll(' ', '_')}_$formattedDate.pdf';

    try {
      // Use the simplified file export service
      final fileExportService = FileExportService();
      await fileExportService.exportFile(
        bytes: pdfBytes,
        fileName: fileName,
        mimeType: 'application/pdf',
      );
    } catch (e) {
      if (mounted) {
        Toaster.error(context, 'File download failed',
            description: e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(appThemeProvider);
    final isDarkMode = theme.isDarkMode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Classes section
        Text(
          'Select Classes to Export',
          style: TextStyle(
            fontSize: Foundations.typography.base,
            fontWeight: Foundations.typography.semibold,
            color: isDarkMode
                ? Foundations.darkColors.textPrimary
                : Foundations.colors.textPrimary,
          ),
        ),
        SizedBox(height: Foundations.spacing.xs),

        // Select all classes checkbox
        BaseCheckbox(
          value: _selectAllClasses,
          onChanged: (value) {
            _toggleSelectAllClasses(value!);
          },
          label: 'Select all classes',
        ),

        SizedBox(height: Foundations.spacing.xs),

        // Class checkboxes
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
                label:
                    '$className (${widget.currentResults[className]?.length ?? 0} students)',
              ),
            );
          }).toList(),
        ),

        SizedBox(height: Foundations.spacing.lg),

        // Student information section
        Text(
          'Select Information to Include',
          style: TextStyle(
            fontSize: Foundations.typography.base,
            fontWeight: Foundations.typography.semibold,
            color: isDarkMode
                ? Foundations.darkColors.textPrimary
                : Foundations.colors.textPrimary,
          ),
        ),
        SizedBox(height: Foundations.spacing.xs),

        // Include gender checkbox
        if (widget.survey.askBiologicalSex)
          BaseCheckbox(
            value: _includeGender,
            onChanged: (value) {
              setState(() {
                _includeGender = value!;
              });
            },
            label: 'Include gender information',
          ),

        SizedBox(height: Foundations.spacing.sm),

        // Parameters section
        if (widget.survey.parameters.isNotEmpty &&
            widget.survey.parameters.any((p) => p['name'] != 'sex')) ...[
          Text(
            'Additional Parameters',
            style: TextStyle(
              fontSize: Foundations.typography.base,
              fontWeight: Foundations.typography.semibold,
              color: isDarkMode
                  ? Foundations.darkColors.textPrimary
                  : Foundations.colors.textPrimary,
            ),
          ),
          SizedBox(height: Foundations.spacing.xs),

          // Select all parameters checkbox
          BaseCheckbox(
            value: _selectAllParameters,
            onChanged: (value) {
              _toggleSelectAllParameters(value!);
            },
            label: 'Select all parameters',
          ),

          SizedBox(height: Foundations.spacing.xs),

          // Parameter checkboxes
          Wrap(
            spacing: Foundations.spacing.lg,
            runSpacing: Foundations.spacing.xs,
            children: widget.survey.parameters
                .where((p) =>
                    p['name'] != 'sex') // Skip sex as it's handled separately
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

        // Export options
        Text(
          'Export Options',
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
          label: 'Include summary statistics',
        ),

        BaseCheckbox(
          value: _showClassStatistics,
          onChanged: (value) {
            setState(() {
              _showClassStatistics = value!;
            });
          },
          label: 'Include class statistics',
        ),

        SizedBox(height: Foundations.spacing.sm),

        Text(
          'Page Size',
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
          hint: 'Select page size',
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
