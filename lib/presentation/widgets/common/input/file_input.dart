import 'package:edconnect_admin/core/design_system/foundations.dart';
import 'package:edconnect_admin/l10n/app_localizations.dart';
import 'package:edconnect_admin/presentation/providers/theme_provider.dart';
import 'package:edconnect_admin/presentation/widgets/common/input/base_input.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FileInput extends ConsumerWidget {
  /// Input label text
  final String? label;

  /// Hint/placeholder text shown when input is empty
  final String? hint;

  /// Description text shown below the input
  final String? description;

  /// Whether this field is required
  final bool isRequired;

  /// Whether the input is disabled
  final bool isDisabled;

  /// List of allowed file extensions (e.g., ['pdf', 'docx'])
  final List<String>? allowedExtensions;

  /// Callback when files are selected or removed
  final ValueChanged<List<PlatformFile>>? onFilesChanged;

  /// Currently selected files to display
  final List<PlatformFile>? selectedFiles;

  /// Maximum number of files that can be selected
  final int? maxFiles;

  /// Whether to show the list of selected files
  final bool showFileList;

  /// Visual size variant
  final InputSize size;

  /// Style variant
  final InputVariant variant;

  /// Whether the input should take full width
  final bool fullWidth;

  /// Custom width
  final double? width;

  const FileInput({
    super.key,
    this.label,
    this.hint,
    this.description,
    this.isRequired = false,
    this.isDisabled = false,
    this.allowedExtensions,
    this.onFilesChanged,
    this.selectedFiles,
    this.maxFiles = 1,
    this.showFileList = true,
    this.size = InputSize.medium,
    this.variant = InputVariant.default_,
    this.fullWidth = true,
    this.width,
  });

  Future<void> _pickFiles(BuildContext context, WidgetRef ref) async {
    if (isDisabled) return;

    final l10n = AppLocalizations.of(context)!;
    final theme = ref.read(appThemeProvider);

    try {
      final result = await FilePicker.platform.pickFiles(
        type: allowedExtensions != null ? FileType.custom : FileType.any,
        allowedExtensions: allowedExtensions,
        allowMultiple: maxFiles != null && maxFiles! > 1,
      );

      if (result != null) {
        if (maxFiles != null && result.files.length > maxFiles!) {
          // Show error snackbar for max files exceeded
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Maximum ${maxFiles!} ${maxFiles == 1 ? 'file' : 'files'} allowed',
                style: TextStyle(
                  color: theme.isDarkMode
                      ? Foundations.darkColors.textPrimary
                      : Foundations.colors.textPrimary,
                ),
              ),
              backgroundColor: theme.isDarkMode
                  ? Foundations.darkColors.backgroundSubtle
                  : Foundations.colors.backgroundSubtle,
            ),
          );
          return;
        }
        onFilesChanged?.call(result.files);
      }
    } catch (e) {
      // Show error snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.errorFileUploadFailed,
            style: TextStyle(
              color: Foundations.colors.textPrimary,
            ),
          ),
          backgroundColor: Foundations.colors.error.withValues(alpha: 0.2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeProvider);
    final isDarkMode = theme.isDarkMode;
    final l10n = AppLocalizations.of(context)!;

    Widget buildFileList() {
      if (!showFileList || selectedFiles == null || selectedFiles!.isEmpty) {
        return const SizedBox.shrink();
      }

      return Container(
        margin: EdgeInsets.only(top: Foundations.spacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: selectedFiles!.map((file) {
            // Icon based on file type
            IconData fileIcon = Icons.insert_drive_file;
            if (file.extension != null) {
              final ext = file.extension!.toLowerCase();
              if (['jpg', 'jpeg', 'png', 'gif', 'webp', 'svg'].contains(ext)) {
                fileIcon = Icons.image;
              } else if (['pdf'].contains(ext)) {
                fileIcon = Icons.picture_as_pdf;
              } else if (['doc', 'docx'].contains(ext)) {
                fileIcon = Icons.description;
              } else if (['xls', 'xlsx', 'csv'].contains(ext)) {
                fileIcon = Icons.table_chart;
              } else if (['ppt', 'pptx'].contains(ext)) {
                fileIcon = Icons.slideshow;
              } else if (['zip', 'rar', '7z', 'tar', 'gz'].contains(ext)) {
                fileIcon = Icons.folder_zip;
              }
            }

            return Container(
              margin: EdgeInsets.only(bottom: Foundations.spacing.xs),
              padding: EdgeInsets.all(Foundations.spacing.sm),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? Foundations.darkColors.backgroundMuted
                        .withValues(alpha: 0.3)
                    : Foundations.colors.backgroundMuted.withValues(alpha: 0.3),
                borderRadius: Foundations.borders.sm,
                border: Border.all(
                  color: isDarkMode
                      ? Foundations.darkColors.border
                      : Foundations.colors.border,
                  width: Foundations.borders.thin,
                ),
              ),
              child: Row(
                children: [
                  // File icon
                  Icon(
                    fileIcon,
                    size: 20,
                    color: isDarkMode
                        ? Foundations.darkColors.textSecondary
                        : Foundations.colors.textSecondary,
                  ),
                  SizedBox(width: Foundations.spacing.sm),

                  // File name and size
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          file.name,
                          style: TextStyle(
                            fontSize: Foundations.typography.sm,
                            color: isDarkMode
                                ? Foundations.darkColors.textPrimary
                                : Foundations.colors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (file.size > 0)
                          Text(
                            _formatFileSize(file.size),
                            style: TextStyle(
                              fontSize: Foundations.typography.xs,
                              color: isDarkMode
                                  ? Foundations.darkColors.textMuted
                                  : Foundations.colors.textMuted,
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Remove button
                  IconButton(
                    iconSize: 18,
                    padding: EdgeInsets.all(Foundations.spacing.xs),
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    icon: Icon(
                      Icons.close,
                      color: isDarkMode
                          ? Foundations.darkColors.textSecondary
                          : Foundations.colors.textSecondary,
                    ),
                    onPressed: isDisabled
                        ? null
                        : () {
                            final newFiles =
                                List<PlatformFile>.from(selectedFiles!)
                                  ..remove(file);
                            onFilesChanged?.call(newFiles);
                          },
                    tooltip: l10n.globalDelete,
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      );
    }

    // Build hint text with file extensions if provided
    String hintText = hint ?? l10n.mediaSelectorInsertImage;
    if (allowedExtensions != null && allowedExtensions!.isNotEmpty) {
      hintText += ' (${allowedExtensions!.map((e) => '.$e').join(', ')})';
    }

    return BaseInput(
      label: label,
      hint: hintText,
      description: description,
      isRequired: isRequired,
      isDisabled: isDisabled,
      readOnly: true,
      onTap: () => _pickFiles(context, ref),
      leadingIcon: Icons.upload_file,
      trailingIcon: Icon(
        Icons.folder_open,
        color: isDisabled
            ? (isDarkMode
                ? Foundations.darkColors.textDisabled
                : Foundations.colors.textDisabled)
            : (isDarkMode
                ? Foundations.darkColors.textSecondary
                : Foundations.colors.textSecondary),
      ),
      size: size,
      variant: variant,
      fullWidth: fullWidth,
      width: width,
      child: buildFileList(),
    );
  }

  // Helper function to format file size
  String _formatFileSize(int bytes) {
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    int i = 0;
    double size = bytes.toDouble();

    while (size >= 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }

    return '${size.toStringAsFixed(size < 10 && i > 0 ? 1 : 0)} ${suffixes[i]}';
  }
}
