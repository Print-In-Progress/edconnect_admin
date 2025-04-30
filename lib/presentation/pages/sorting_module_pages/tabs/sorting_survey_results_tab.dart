import 'package:edconnect_admin/core/design_system/color_generator.dart';
import 'package:edconnect_admin/core/design_system/foundations.dart';
import 'package:edconnect_admin/core/models/app_user.dart';
import 'package:edconnect_admin/domain/entities/sorting_survey.dart';
import 'package:edconnect_admin/presentation/pages/sorting_module_pages/dialogs/export_results_dialog.dart';
import 'package:edconnect_admin/presentation/providers/state_providers.dart';
import 'package:edconnect_admin/presentation/providers/theme_provider.dart';
import 'package:edconnect_admin/presentation/widgets/common/buttons/base_button.dart';
import 'package:edconnect_admin/presentation/widgets/common/cards/base_card.dart';
import 'package:edconnect_admin/presentation/widgets/common/chips.dart';
import 'package:edconnect_admin/presentation/widgets/common/dialogs/dialogs.dart';
import 'package:edconnect_admin/presentation/widgets/common/sortable.dart';
import 'package:edconnect_admin/presentation/widgets/common/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/*
Search/filter functionality to temporarily show only students matching specific criteria across all columns

Highlight related items - When a student is selected, highlight their preferred classmates in other columns

Sticky headers to keep column titles visible when scrolling

Column freezing - Allow users to "freeze" a column of interest while scrolling through others
*/

class ResultsTab extends ConsumerStatefulWidget {
  final SortingSurvey survey;
  const ResultsTab({super.key, required this.survey});

  @override
  ConsumerState<ResultsTab> createState() => _ResultsTabState();
}

class _ResultsTabState extends ConsumerState<ResultsTab> {
  Map<String, List<String>> _currentResults = {};
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    // Convert the calculation results to a usable format
    if (widget.survey.calculationResults != null &&
        widget.survey.calculationResults!.isNotEmpty) {
      _currentResults = widget.survey.calculationResults!.map(
          (className, students) =>
              MapEntry(className, (students as List).cast<String>()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(appThemeProvider);
    final isDarkMode = theme.isDarkMode;
    final hasResults = _currentResults.isNotEmpty;
    final allUsers = ref.watch(allUsersStreamProvider).value ?? [];

    if (!hasResults) {
      return _buildNoResultsState(isDarkMode);
    }

    // Create a list of columns for the sortable widget
    final columns = _currentResults.entries.map((entry) {
      final className = entry.key;
      final studentIds = entry.value;

      // Create sortable items from student IDs
      final items = studentIds.map((studentId) {
        return SortableItem<String>(
          id: studentId,
          data: studentId,
        );
      }).toList();

      return SortableColumn<String>(
        id: className,
        title: className, // Still need this for internal purposes
        description:
            '${items.length} students', // Still need this for internal purposes
        // Add custom header widget with statistics
        headerWidget: _buildColumnHeader(className, studentIds, isDarkMode),
        items: items,
      );
    }).toList();

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(Foundations.spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildResultsHeader(isDarkMode),
            SizedBox(height: Foundations.spacing.xs),
            _buildStatistics(isDarkMode),
            if (_hasChanges) ...[
              SizedBox(height: Foundations.spacing.sm),
              Row(
                children: [
                  BaseButton(
                    label: 'Save Changes',
                    prefixIcon: Icons.save_outlined,
                    variant: ButtonVariant.filled,
                    onPressed: _saveChanges,
                  ),
                  SizedBox(width: Foundations.spacing.md),
                  BaseButton(
                    label: 'Discard Changes',
                    prefixIcon: Icons.close,
                    variant: ButtonVariant.outlined,
                    onPressed: _discardChanges,
                  ),
                ],
              ),
              SizedBox(height: Foundations.spacing.sm),
              Text(
                'You have unsaved changes to the class assignments',
                style: TextStyle(
                  color: Foundations.colors.warning,
                  fontSize: Foundations.typography.sm,
                ),
              ),
              SizedBox(height: Foundations.spacing.sm),
            ],
            Center(
              child: SizedBox(
                height: 750,
                child: Sortable<String>(
                  columns: columns,
                  columnWidth:
                      MediaQuery.of(context).size.width > 1200 ? 320 : 280,
                  showEmptyPlaceholder: true,
                  itemSpacing: Foundations.spacing.xs,
                  onItemsReordered: _handleReorder,
                  itemBuilder: (context, item) {
                    return _buildStudentCard(item.data, allUsers, isDarkMode);
                  },
                  emptyPlaceholderBuilder: (context, column) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(Foundations.spacing.lg),
                        child: Text(
                          'Drag students here',
                          style: TextStyle(
                            color: isDarkMode
                                ? Foundations.darkColors.textMuted
                                : Foundations.colors.textMuted,
                            fontSize: Foundations.typography.base,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsHeader(bool isDarkMode) {
    return Row(
      children: [
        Icon(
          Icons.pie_chart_outline,
          size: 20,
          color: isDarkMode
              ? Foundations.darkColors.textMuted
              : Foundations.colors.textMuted,
        ),
        SizedBox(width: Foundations.spacing.sm),
        Text(
          'Class Distribution Results',
          style: TextStyle(
            fontSize: Foundations.typography.lg,
            fontWeight: Foundations.typography.semibold,
            color: isDarkMode
                ? Foundations.darkColors.textPrimary
                : Foundations.colors.textPrimary,
          ),
        ),
        Spacer(),
        BaseButton(
          label: 'Export Results',
          prefixIcon: Icons.download_outlined,
          variant: ButtonVariant.outlined,
          size: ButtonSize.medium,
          onPressed: _exportResults,
        ),
      ],
    );
  }

  Widget _buildStatistics(bool isDarkMode) {
    // Calculate statistics
    final totalClasses = _currentResults.length;
    final totalStudents = _currentResults.values
        .fold(0, (sum, students) => sum + students.length);
    final averagePerClass = totalClasses > 0
        ? (totalStudents / totalClasses).toStringAsFixed(1)
        : '0';

    // Calculate preference satisfaction statistics
    final preferenceSatisfactionData = _calculatePreferenceSatisfaction();
    final satisfiedPrefs =
        preferenceSatisfactionData['satisfiedPreferences'] as int;
    final totalPrefs = preferenceSatisfactionData['totalPreferences'] as int;
    final studentsWithSatisfiedPrefs =
        preferenceSatisfactionData['studentsWithSatisfiedPrefs'] as int;
    final studentsWithPreferences =
        preferenceSatisfactionData['studentsWithPreferences'] as int;

    // Calculate percentage
    final satisfactionRate = totalPrefs > 0
        ? (satisfiedPrefs / totalPrefs * 100).toStringAsFixed(1) + '%'
        : '0%';

    final studentSatisfactionRate = studentsWithPreferences > 0
        ? (studentsWithSatisfiedPrefs / studentsWithPreferences * 100)
                .toStringAsFixed(1) +
            '%'
        : '0%';

    return Row(
      children: [
        // More compact stats in a single row
        _buildCompactStatItem(
          'Students',
          totalStudents.toString(),
          Icons.people_outline,
          isDarkMode,
          subtitle: '$totalClasses classes, ~$averagePerClass per class',
        ),
        SizedBox(width: Foundations.spacing.md),
        _buildCompactStatItem(
          'Preferences Satisfied',
          '$satisfiedPrefs / $totalPrefs',
          Icons.favorite_outline,
          isDarkMode,
          subtitle: satisfactionRate,
        ),
        SizedBox(width: Foundations.spacing.md),
        _buildCompactStatItem(
          'Students With Preferences with at least one satisfied',
          '$studentsWithSatisfiedPrefs / $studentsWithPreferences',
          Icons.check_circle_outline,
          isDarkMode,
          subtitle: studentSatisfactionRate,
        ),
      ],
    );
  }

// A more compact stat display that takes less vertical space
  Widget _buildCompactStatItem(
      String label, String value, IconData icon, bool isDarkMode,
      {String? subtitle}) {
    return Expanded(
      child: BaseCard(
        variant: CardVariant.outlined,
        margin: EdgeInsets.zero,
        padding: EdgeInsets.symmetric(
          horizontal: Foundations.spacing.sm,
          vertical: Foundations.spacing.xs,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isDarkMode
                  ? Foundations.darkColors.textSecondary
                  : Foundations.colors.textSecondary,
            ),
            SizedBox(width: Foundations.spacing.xs),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: Foundations.typography.xs,
                      color: isDarkMode
                          ? Foundations.darkColors.textMuted
                          : Foundations.colors.textMuted,
                    ),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: Foundations.typography.sm,
                      fontWeight: Foundations.typography.medium,
                      color: isDarkMode
                          ? Foundations.darkColors.textPrimary
                          : Foundations.colors.textPrimary,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
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
          ],
        ),
      ),
    );
  }

  Widget _buildStudentCard(
      String studentId, List<AppUser> allUsers, bool isDarkMode) {
    // Find user details
    final user = allUsers.firstWhere(
      (u) => u.id == studentId,
      orElse: () {
        // Check if it's a manual entry
        final response = widget.survey.responses[studentId];
        if (response != null && response['_manual_entry'] == true) {
          return AppUser(
            id: studentId,
            firstName: response['_first_name'] ?? 'Unknown',
            lastName: response['_last_name'] ?? 'Student',
            email: '',
            fcmTokens: [],
            groupIds: [],
            permissions: [],
            deviceIds: {},
            accountType: '',
          );
        }
        return AppUser(
          id: studentId,
          firstName: 'Unknown',
          lastName: 'Student',
          email: '',
          fcmTokens: [],
          groupIds: [],
          permissions: [],
          deviceIds: {},
          accountType: '',
        );
      },
    );

    // Get biological sex if available
    String? sex;
    final response = widget.survey.responses[studentId];
    if (widget.survey.askBiologicalSex && response != null) {
      sex = response['sex'] as String?;
    }
    final Map<String, dynamic> responseWithId = {
      ...response,
      '_student_id': studentId,
    };
    return BaseCard(
      variant: CardVariant.outlined,
      padding: EdgeInsets.all(Foundations.spacing.sm),
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          // Student basic info row
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: ColorGenerator.getColor(
                    user.fullName,
                    user.id,
                    isDarkMode: isDarkMode,
                  ),
                  borderRadius: Foundations.borders.full,
                ),
                child: Center(
                  child: Text(
                    user.initials,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: Foundations.typography.semibold,
                    ),
                  ),
                ),
              ),
              SizedBox(width: Foundations.spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.fullName,
                      style: TextStyle(
                        fontSize: Foundations.typography.base,
                        fontWeight: Foundations.typography.medium,
                        color: isDarkMode
                            ? Foundations.darkColors.textPrimary
                            : Foundations.colors.textPrimary,
                      ),
                    ),
                    if (sex != null) ...[
                      SizedBox(height: Foundations.spacing.xs),
                      BaseChip(
                        label: _formatSex(sex),
                        variant: ChipVariant.default_,
                        size: ChipSize.small,
                        backgroundColor: ColorGenerator.getColor(
                          'sex',
                          sex,
                          isDarkMode: isDarkMode,
                        ).withOpacity(0.1),
                        textColor: ColorGenerator.getColor(
                          'sex',
                          sex,
                          isDarkMode: isDarkMode,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          // Show response details in expansion tile if response exists
          if (response != null) ...[
            ExpansionTile(
              title: Text(
                'Response Details',
                style: TextStyle(
                  fontSize: Foundations.typography.xs,
                  color: isDarkMode
                      ? Foundations.darkColors.textSecondary
                      : Foundations.colors.textSecondary,
                ),
              ),
              dense: true,
              childrenPadding: EdgeInsets.only(
                left: Foundations.spacing.sm,
                right: Foundations.spacing.sm,
                bottom: Foundations.spacing.sm,
              ),
              iconColor: isDarkMode
                  ? Foundations.darkColors.textMuted
                  : Foundations.colors.textMuted,
              shape: const Border(),
              collapsedShape: const Border(),
              children: [
                // Preferences section
                _buildPreferencesSection(responseWithId, allUsers, isDarkMode),

                // Parameters section based on survey parameters
                ...widget.survey.parameters.map((param) {
                  return _buildParameterInfo(param, response, isDarkMode);
                }),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPreferencesSection(
      Map<String, dynamic> response, List<AppUser> allUsers, bool isDarkMode) {
    // We need to get the actual student ID first
    final studentId = response['_student_id'] ?? ''; // This might be missing

    final prefs = response['prefs'] as List?;
    if (prefs == null || prefs.isEmpty) {
      return _buildInfoRow(
        'Preferences',
        'No preferences selected',
        isDarkMode,
        icon: Icons.favorite_border,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Preferences', Icons.favorite_border, isDarkMode),
        SizedBox(height: Foundations.spacing.xs),
        ...prefs.map((prefId) {
          if (prefId is String) {
            // Find preferred student name
            final prefUser = allUsers.firstWhere(
              (u) => u.id == prefId,
              orElse: () {
                // Check if it's a manual entry
                final prefResponse = widget.survey.responses[prefId];
                if (prefResponse != null &&
                    prefResponse['_manual_entry'] == true) {
                  return AppUser(
                    id: prefId,
                    firstName: prefResponse['_first_name'] ?? 'Unknown',
                    lastName: prefResponse['_last_name'] ?? 'Student',
                    email: '',
                    fcmTokens: [],
                    groupIds: [],
                    permissions: [],
                    deviceIds: {},
                    accountType: '',
                  );
                }
                return AppUser(
                  id: prefId,
                  firstName: 'Unknown',
                  lastName: 'Student',
                  email: '',
                  fcmTokens: [],
                  groupIds: [],
                  permissions: [],
                  deviceIds: {},
                  accountType: '',
                );
              },
            );

            // Get the current student's class
            String? currentStudentClass;
            for (final entry in _currentResults.entries) {
              if (entry.value.contains(studentId)) {
                currentStudentClass = entry.key;
                break;
              }
            }

            // Check if preferred student is in the same class
            bool isSatisfied = false;
            if (currentStudentClass != null) {
              isSatisfied =
                  _currentResults[currentStudentClass]!.contains(prefId);
            }

            // Get a color based on the preferred student's name/ID
            final nameColor = ColorGenerator.getColor(
              prefUser.fullName,
              prefUser.id,
              isDarkMode: isDarkMode,
            );

            return Padding(
              padding: EdgeInsets.only(left: Foundations.spacing.md),
              child: Row(
                children: [
                  Icon(
                    isSatisfied
                        ? Icons.check // Use simple checkmark when satisfied
                        : Icons.highlight_off,
                    size: 14,
                    color: isSatisfied
                        ? Foundations.colors.success
                        : Foundations.colors.error.withOpacity(0.7),
                  ),
                  SizedBox(width: Foundations.spacing.xs),
                  Text(
                    prefUser.fullName,
                    style: TextStyle(
                        fontSize: Foundations.typography.xs,
                        fontWeight: isSatisfied
                            ? Foundations.typography.medium
                            : Foundations.typography.regular,
                        color:
                            nameColor // Use color generated from student name

                        ),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }

// Build individual parameter info row based on parameter type
  Widget _buildParameterInfo(Map<String, dynamic> param,
      Map<String, dynamic> response, bool isDarkMode) {
    final paramName = param['name'] as String;
    final paramType = param['type'] as String;
    final displayName = _formatParamName(paramName);

    // Skip sex parameter as it's already shown in the header
    if (paramName == 'sex') return const SizedBox.shrink();

    String valueText = 'Not provided';
    IconData paramIcon;

    if (response.containsKey(paramName)) {
      final value = response[paramName];

      if (paramType == 'binary') {
        paramIcon = Icons.check_box_outline_blank;

        // Format binary value
        if (value.toString().toLowerCase() == 'yes' ||
            value.toString().toLowerCase() == 'true' ||
            value.toString() == '1') {
          valueText = 'Yes';
        } else if (value.toString().toLowerCase() == 'no' ||
            value.toString().toLowerCase() == 'false' ||
            value.toString() == '0') {
          valueText = 'No';
        } else {
          valueText = value.toString();
        }
      } else {
        // Categorical parameter
        paramIcon = Icons.label_outline;
        valueText = _formatParamName(value.toString());
      }
    } else {
      paramIcon = paramType == 'binary'
          ? Icons.check_box_outline_blank
          : Icons.label_outline;
    }

    return _buildInfoRow(displayName, valueText, isDarkMode, icon: paramIcon);
  }

// Build a section title with icon
  Widget _buildSectionTitle(String title, IconData icon, bool isDarkMode) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: isDarkMode
              ? Foundations.darkColors.textMuted
              : Foundations.colors.textMuted,
        ),
        SizedBox(width: Foundations.spacing.xs),
        Text(
          title,
          style: TextStyle(
            fontSize: Foundations.typography.xs,
            fontWeight: Foundations.typography.medium,
            color: isDarkMode
                ? Foundations.darkColors.textMuted
                : Foundations.colors.textMuted,
          ),
        ),
      ],
    );
  }

// Build a generic parameter row
  Widget _buildInfoRow(String label, String value, bool isDarkMode,
      {IconData? icon}) {
    return Padding(
      padding: EdgeInsets.only(top: Foundations.spacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 14,
              color: isDarkMode
                  ? Foundations.darkColors.textMuted
                  : Foundations.colors.textMuted,
            ),
            SizedBox(width: Foundations.spacing.xs),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: Foundations.typography.xs,
                    fontWeight: Foundations.typography.medium,
                    color: isDarkMode
                        ? Foundations.darkColors.textMuted
                        : Foundations.colors.textMuted,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: Foundations.typography.xs,
                    color: isDarkMode
                        ? Foundations.darkColors.textSecondary
                        : Foundations.colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.pie_chart_outline,
            size: 64,
            color: isDarkMode
                ? Foundations.darkColors.textMuted
                : Foundations.colors.textMuted,
          ),
          SizedBox(height: Foundations.spacing.lg),
          Text(
            'No calculation results available',
            style: TextStyle(
              fontSize: Foundations.typography.xl,
              fontWeight: Foundations.typography.semibold,
              color: isDarkMode
                  ? Foundations.darkColors.textPrimary
                  : Foundations.colors.textPrimary,
            ),
          ),
          SizedBox(height: Foundations.spacing.md),
          Text(
            'Use the Calculate tab to generate class distributions',
            style: TextStyle(
              fontSize: Foundations.typography.base,
              color: isDarkMode
                  ? Foundations.darkColors.textSecondary
                  : Foundations.colors.textSecondary,
            ),
          ),
          SizedBox(height: Foundations.spacing.xl),
          BaseButton(
            label: 'Go to Calculate',
            prefixIcon: Icons.calculate_outlined,
            variant: ButtonVariant.filled,
            onPressed: () {
              // Navigate to calculate tab
              ref
                  .read(surveyTabIndexProvider(widget.survey.id).notifier)
                  .state = 2;
            },
          ),
        ],
      ),
    );
  }

  void _handleReorder(
    List<SortableColumn<String>> updatedColumns,
    String sourceColumnId,
    String targetColumnId,
    String itemId,
  ) {
    // Update the results based on the reordering
    final Map<String, List<String>> newResults = {};

    // Create updated columns with fresh headers
    final newColumns = <SortableColumn<String>>[];

    final theme = ref.watch(appThemeProvider);
    final isDarkMode = theme.isDarkMode;

    for (final column in updatedColumns) {
      // Extract student IDs from items
      final studentIds = column.items.map((item) => item.data).toList();

      // Add to results map
      newResults[column.id] = studentIds;

      // Create updated column with fresh header
      newColumns.add(column.copyWith(
        // Update header with new statistics
        headerWidget: _buildColumnHeader(column.id, studentIds, isDarkMode),
      ));
    }

    setState(() {
      _currentResults = newResults;
      _hasChanges = true;
    });
  }

  Future<void> _saveChanges() async {
    try {
      // Show confirmation dialog
      final confirmed = await Dialogs.confirm(
        context: context,
        title: 'Save Changes',
        message:
            'Are you sure you want to save your changes to the class assignments?',
      );

      if (confirmed != true) return;

      // Save the changes
      // await ref
      //     .read(sortingSurveyNotifierProvider.notifier)
      //     .saveCalculationResults(widget.survey.id, _currentResults);

      setState(() {
        _hasChanges = false;
      });

      if (context.mounted) {
        Toaster.success(context, 'Class assignments saved successfully');
      }
    } catch (e) {
      if (context.mounted) {
        Toaster.error(context, 'Failed to save changes',
            description: e.toString());
      }
    }
  }

  void _discardChanges() {
    setState(() {
      // Revert to original results
      if (widget.survey.calculationResults != null) {
        _currentResults = widget.survey.calculationResults!.map(
            (className, students) =>
                MapEntry(className, (students as List).cast<String>()));
      } else {
        _currentResults = {};
      }
      _hasChanges = false;
    });
  }

  Future<void> _exportResults() async {
    // Create a key to access the dialog content
    final dialogKey = GlobalKey<ExportResultsDialogState>();
    bool isExporting = false;

    Dialogs.show(
      context: context,
      title: 'Export Class Distribution Results',
      width: 600,
      scrollable: true,
      content: StatefulBuilder(
        builder: (context, setState) {
          return ExportResultsDialog(
            key: dialogKey,
            survey: widget.survey,
            currentResults: _currentResults,
            onExportStatusChanged: (exporting) {
              // Update loading state when export status changes
              setState(() => isExporting = exporting);
            },
          );
        },
      ),
      actions: [
        BaseButton(
          label: 'Export to PDF',
          prefixIcon: Icons.picture_as_pdf_outlined,
          variant: ButtonVariant.filled,
          isLoading: isExporting,
          onPressed: () {
            // Access dialog using key directly
            dialogKey.currentState?.exportPdf();
          },
        ),
      ],
      showCancelButton: true,
      showCloseIcon: true,
    );
  }

// Calculate statistics for a class
  Map<String, dynamic> _calculateClassStats(List<String> studentIds) {
    // Gender distribution
    Map<String, int> genderCounts = {'m': 0, 'f': 0, 'nb': 0, 'unknown': 0};

    // Binary parameters (yes/no questions)
    Map<String, Map<String, int>> binaryParams = {};

    // Initialize binary parameter counters from survey parameters
    for (var param in widget.survey.parameters) {
      if (param['type'] == 'binary') {
        String paramName = param['name'];
        binaryParams[paramName] = {'yes': 0, 'no': 0};
      }
    }

    // Count responses for each student
    for (String studentId in studentIds) {
      final response = widget.survey.responses[studentId];

      if (response != null) {
        // Count gender
        String sex = response['sex'] as String? ?? 'unknown';
        if (genderCounts.containsKey(sex)) {
          genderCounts[sex] = genderCounts[sex]! + 1;
        } else {
          genderCounts['unknown'] = genderCounts['unknown']! + 1;
        }

        // Count binary parameters
        for (String paramName in binaryParams.keys) {
          String value =
              (response[paramName] ?? 'unknown').toString().toLowerCase();
          if (value == 'yes' || value == 'true' || value == '1') {
            binaryParams[paramName]!['yes'] =
                binaryParams[paramName]!['yes']! + 1;
          } else if (value == 'no' || value == 'false' || value == '0') {
            binaryParams[paramName]!['no'] =
                binaryParams[paramName]!['no']! + 1;
          }
        }
      }
    }

    return {
      'gender': genderCounts,
      'binary_params': binaryParams,
      'total': studentIds.length,
    };
  }

// Create an enhanced header widget
  Widget _buildColumnHeader(
      String className, List<String> studentIds, bool isDarkMode) {
    final stats = _calculateClassStats(studentIds);
    final genderStats = stats['gender'] as Map<String, int>;
    final binaryParams =
        stats['binary_params'] as Map<String, Map<String, int>>;

    return Padding(
      padding: EdgeInsets.all(Foundations.spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Class name and count
          Text(
            className,
            style: TextStyle(
              fontSize: Foundations.typography.base,
              fontWeight: Foundations.typography.semibold,
              color: isDarkMode
                  ? Foundations.darkColors.textPrimary
                  : Foundations.colors.textPrimary,
            ),
          ),
          Text(
            '${studentIds.length} students',
            style: TextStyle(
              fontSize: Foundations.typography.sm,
              color: isDarkMode
                  ? Foundations.darkColors.textMuted
                  : Foundations.colors.textMuted,
            ),
          ),

          SizedBox(height: Foundations.spacing.sm),

          // Gender distribution
          ExpansionTile(
            title: Text('Show class statistics'),
            shape: const Border(),
            children: [
              if (widget.survey.askBiologicalSex)
                _buildDistributionBar(genderStats, isDarkMode),

              // Binary parameters
              ...binaryParams.entries.map((entry) {
                return _buildBinaryParamBar(
                  _formatParamName(entry.key),
                  entry.value,
                  isDarkMode,
                );
              }).toList(),
            ],
          )
        ],
      ),
    );
  }

// Format parameter name for display
  String _formatParamName(String name) {
    return name
        .split('_')
        .map((word) => word.isNotEmpty
            ? '${word[0].toUpperCase()}${word.substring(1)}'
            : '')
        .join(' ');
  }

// Display gender distribution as a colored bar
  Widget _buildDistributionBar(Map<String, int> counts, bool isDarkMode) {
    final total = counts.values.fold(0, (sum, count) => sum + count);
    if (total == 0) return const SizedBox();

    final maleCount = counts['m'] ?? 0;
    final femaleCount = counts['f'] ?? 0;
    final nbCount = counts['nb'] ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gender',
          style: TextStyle(
            fontSize: Foundations.typography.xs,
            fontWeight: Foundations.typography.medium,
            color: isDarkMode
                ? Foundations.darkColors.textSecondary
                : Foundations.colors.textSecondary,
          ),
        ),
        SizedBox(height: Foundations.spacing.xs),
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: Foundations.borders.sm,
                child: Row(
                  children: [
                    // Male proportion
                    if (maleCount > 0)
                      Expanded(
                        flex: maleCount,
                        child: Container(
                          height: 8,
                          color: ColorGenerator.getColor('sex', 'm',
                              isDarkMode: isDarkMode),
                        ),
                      ),
                    // Female proportion
                    if (femaleCount > 0)
                      Expanded(
                        flex: femaleCount,
                        child: Container(
                          height: 8,
                          color: ColorGenerator.getColor('sex', 'f',
                              isDarkMode: isDarkMode),
                        ),
                      ),
                    // Non-binary proportion
                    if (nbCount > 0)
                      Expanded(
                        flex: nbCount,
                        child: Container(
                          height: 8,
                          color: ColorGenerator.getColor('sex', 'nb',
                              isDarkMode: isDarkMode),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: Foundations.spacing.xs),
        Row(
          children: [
            if (maleCount > 0)
              _buildLegendItem(
                  'M',
                  maleCount,
                  ColorGenerator.getColor('sex', 'm', isDarkMode: isDarkMode),
                  isDarkMode),
            if (maleCount > 0 && femaleCount > 0)
              SizedBox(width: Foundations.spacing.xs),
            if (femaleCount > 0)
              _buildLegendItem(
                  'F',
                  femaleCount,
                  ColorGenerator.getColor('sex', 'f', isDarkMode: isDarkMode),
                  isDarkMode),
            if ((maleCount > 0 || femaleCount > 0) && nbCount > 0)
              SizedBox(width: Foundations.spacing.xs),
            if (nbCount > 0)
              _buildLegendItem(
                  'NB',
                  nbCount,
                  ColorGenerator.getColor('sex', 'nb', isDarkMode: isDarkMode),
                  isDarkMode),
          ],
        ),
      ],
    );
  }

// Display binary parameter (yes/no) as a bar
  Widget _buildBinaryParamBar(
      String title, Map<String, int> counts, bool isDarkMode) {
    final yesCount = counts['yes'] ?? 0;
    final noCount = counts['no'] ?? 0;
    final total = yesCount + noCount;

    if (total == 0) return const SizedBox();

    return Padding(
      padding: EdgeInsets.only(top: Foundations.spacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: Foundations.typography.xs,
              fontWeight: Foundations.typography.medium,
              color: isDarkMode
                  ? Foundations.darkColors.textSecondary
                  : Foundations.colors.textSecondary,
            ),
          ),
          SizedBox(height: Foundations.spacing.xs),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: Foundations.borders.sm,
                  child: Row(
                    children: [
                      // Yes proportion
                      if (yesCount > 0)
                        Expanded(
                          flex: yesCount,
                          child: Container(
                            height: 8,
                            color: Foundations.colors.success.withOpacity(0.8),
                          ),
                        ),
                      // No proportion
                      if (noCount > 0)
                        Expanded(
                          flex: noCount,
                          child: Container(
                            height: 8,
                            color: Foundations.colors.error.withOpacity(0.6),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: Foundations.spacing.xs),
          Row(
            children: [
              if (yesCount > 0)
                _buildLegendItem('Yes', yesCount,
                    Foundations.colors.success.withOpacity(0.8), isDarkMode),
              if (yesCount > 0 && noCount > 0)
                SizedBox(width: Foundations.spacing.sm),
              if (noCount > 0)
                _buildLegendItem('No', noCount,
                    Foundations.colors.error.withOpacity(0.6), isDarkMode),
            ],
          ),
        ],
      ),
    );
  }

// Build a small legend item with color indicator
  Widget _buildLegendItem(
      String label, int count, Color color, bool isDarkMode) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: Foundations.borders.full,
          ),
        ),
        SizedBox(width: 4),
        Text(
          '$label: $count',
          style: TextStyle(
            fontSize: 10,
            color: isDarkMode
                ? Foundations.darkColors.textMuted
                : Foundations.colors.textMuted,
          ),
        ),
      ],
    );
  }

  String _formatSex(String sex) {
    switch (sex) {
      case 'm':
        return 'Male';
      case 'f':
        return 'Female';
      case 'nb':
        return 'Non-Binary';
      default:
        return 'Unknown';
    }
  }

  Map<String, dynamic> _calculatePreferenceSatisfaction() {
    int satisfiedPreferences = 0;
    int totalPreferences = 0;
    Set<String> studentsWithSatisfiedPrefs = {};
    Set<String> studentsWithPreferences = {};

    // Loop through each class and its students
    for (final entry in _currentResults.entries) {
      final studentsInClass = Set<String>.from(entry.value);

      // Check each student's preferences
      for (final studentId in entry.value) {
        final response = widget.survey.responses[studentId];
        if (response == null) continue;

        final prefs = response['prefs'] as List?;
        if (prefs == null || prefs.isEmpty) continue;

        // Count how many preferences are satisfied for this student
        int studentSatisfiedPrefs = 0;
        int studentTotalPrefs = 0;

        for (final pref in prefs) {
          if (pref is String) {
            studentTotalPrefs++;
            // Check if preferred student is in the same class
            if (studentsInClass.contains(pref)) {
              studentSatisfiedPrefs++;
            }
          }
        }

        // Track students who have preferences
        if (studentTotalPrefs > 0) {
          studentsWithPreferences.add(studentId);
        }

        // Update counters
        totalPreferences += studentTotalPrefs;
        satisfiedPreferences += studentSatisfiedPrefs;

        // Track students with at least one preference satisfied
        if (studentSatisfiedPrefs > 0) {
          studentsWithSatisfiedPrefs.add(studentId);
        }
      }
    }

    return {
      'satisfiedPreferences': satisfiedPreferences,
      'totalPreferences': totalPreferences,
      'studentsWithSatisfiedPrefs': studentsWithSatisfiedPrefs.length,
      'studentsWithPreferences': studentsWithPreferences.length,
    };
  }
}
